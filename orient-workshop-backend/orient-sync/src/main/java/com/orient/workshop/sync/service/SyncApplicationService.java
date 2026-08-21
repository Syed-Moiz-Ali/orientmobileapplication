package com.orient.workshop.sync.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.orient.workshop.advisor.model.entity.Approval;
import com.orient.workshop.advisor.model.entity.Inspection;
import com.orient.workshop.advisor.model.entity.RepairOrder;
import com.orient.workshop.advisor.model.entity.RepairOrderPartItem;
import com.orient.workshop.advisor.model.entity.RepairOrderServiceItem;
import com.orient.workshop.advisor.repository.ApprovalMapper;
import com.orient.workshop.advisor.repository.InspectionMapper;
import com.orient.workshop.advisor.repository.RepairOrderMapper;
import com.orient.workshop.advisor.repository.RepairOrderPartMapper;
import com.orient.workshop.advisor.repository.RepairOrderServiceMapper;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.exception.ForbiddenException;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.common.util.IdGenerator;
import com.orient.workshop.core.model.entity.Booking;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.repository.BookingMapper;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.supervisor.model.entity.WorkAssignment;
import com.orient.workshop.supervisor.repository.WorkAssignmentMapper;
import com.orient.workshop.sync.model.entity.SyncLog;
import com.orient.workshop.sync.repository.SyncLogMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.function.Supplier;
import java.util.function.Consumer;

@Slf4j
@Service
@RequiredArgsConstructor
public class SyncApplicationService {
    private static final Object[] IDEMPOTENCY_LOCKS = new Object[1024];

    static {
        for (int i = 0; i < IDEMPOTENCY_LOCKS.length; i++) {
            IDEMPOTENCY_LOCKS[i] = new Object();
        }
    }

    private final JobCardMapper jobCardMapper;
    private final SyncLogMapper syncLogMapper;
    private final InspectionMapper inspectionMapper;
    private final BookingMapper bookingMapper;
    private final RepairOrderMapper repairOrderMapper;
    private final RepairOrderServiceMapper repairOrderServiceMapper;
    private final RepairOrderPartMapper repairOrderPartMapper;
    private final ApprovalMapper approvalMapper;
    private final CustomerMapper customerMapper;
    private final WorkAssignmentMapper workAssignmentMapper;
    private final ObjectMapper objectMapper;

    @Transactional
    public Map<String, String> syncInspection(JwtUserPrincipal principal, String id,
                                              Map<String, Object> body, String idempotencyKey) {
        String endpoint = "/sync/inspections/" + id;
        return withIdempotencyLock(principal, endpoint, body, idempotencyKey, () -> {
            Map<String, String> result = record(principal, "inspection", id, endpoint, body, idempotencyKey);
            if (isReplay(result)) return result;
            applyInspection(principal, id, body);
            return result;
        });
    }

    @Transactional
    public Map<String, String> syncJobComplete(JwtUserPrincipal principal, String id,
                                               Map<String, Object> body, String idempotencyKey) {
        String endpoint = "/sync/jobs/complete/" + id;
        return withIdempotencyLock(principal, endpoint, body, idempotencyKey, () -> {
            Map<String, String> result = record(principal, "job_complete", id, endpoint, body, idempotencyKey);
            if (isReplay(result)) return result;
            JobCard card = requireScopedJobCard(principal, id);
            card.setStatus("completed");
            jobCardMapper.updateById(card);
            return result;
        });
    }

    @Transactional
    public Map<String, String> syncRepairOrder(JwtUserPrincipal principal, String id,
                                               Map<String, Object> body, String idempotencyKey) {
        String endpoint = "/sync/repair-orders/" + id;
        return withIdempotencyLock(principal, endpoint, body, idempotencyKey, () -> {
            Map<String, String> result = record(principal, "repair_order", id, endpoint, body, idempotencyKey);
            if (isReplay(result)) return result;
            applyRepairOrder(principal, id, body);
            return result;
        });
    }

    @Transactional
    public Map<String, String> syncBooking(JwtUserPrincipal principal, Map<String, Object> body,
                                           String idempotencyKey) {
        return withIdempotencyLock(principal, "/sync/bookings", body, idempotencyKey, () -> {
            String entityId = firstNonBlank(body.get("bookingRef"), body.get("id"));
            if (entityId == null) entityId = IdGenerator.shortRef("SYNC-BK");
            Map<String, String> result = record(principal, "booking", entityId,
                    "/sync/bookings", body, idempotencyKey);
            if (isReplay(result)) return result;
            applyBooking(principal, body);
            return result;
        });
    }

    @Transactional
    public Map<String, String> syncWorkAssignment(JwtUserPrincipal principal, Map<String, Object> body,
                                                  String idempotencyKey) {
        return withIdempotencyLock(principal, "/sync/work-assignments", body, idempotencyKey, () -> {
            String entityId = firstNonBlank(body.get("assignmentRef"), body.get("id"));
            if (entityId == null) entityId = IdGenerator.shortRef("SYNC-WA");
            Map<String, String> result = record(principal, "work_assignment", entityId,
                    "/sync/work-assignments", body, idempotencyKey);
            if (isReplay(result)) return result;
            applyWorkAssignment(principal, body);
            return result;
        });
    }

    private Map<String, String> withIdempotencyLock(JwtUserPrincipal principal, String endpoint,
                                                    Map<String, Object> body, String idempotencyKey,
                                                    Supplier<Map<String, String>> action) {
        String scopedKey = scopedKey(principal, endpoint, body, idempotencyKey);
        if (scopedKey == null) return action.get();
        synchronized (lockFor(scopedKey)) {
            return action.get();
        }
    }

    private Object lockFor(String scopedKey) {
        int index = Math.floorMod(scopedKey.hashCode(), IDEMPOTENCY_LOCKS.length);
        return IDEMPOTENCY_LOCKS[index];
    }

    private boolean isReplay(Map<String, String> result) {
        return Boolean.parseBoolean(result.getOrDefault("replayed", "false"));
    }

    private Map<String, String> record(JwtUserPrincipal principal, String entityType, String entityId,
                                       String endpoint, Map<String, Object> body, String idempotencyKey) {
        String storedKey = scopedKey(principal, endpoint, body, idempotencyKey);
        if (storedKey != null) {
            Optional<SyncLog> existing = syncLogMapper.findByKey(storedKey);
            if (existing.isPresent()) {
                SyncLog record = existing.get();
                return Map.of("id", String.valueOf(record.getId()), "synced", "true",
                        "recorded", "true", "replayed", "true");
            }
        }
        SyncLog record = SyncLog.builder()
                .idempotencyKey(storedKey != null ? storedKey : "")
                .entityType(entityType)
                .entityId(entityId)
                .endpoint(endpoint)
                .method("POST")
                .requestBody(json(body))
                .payload(json(body))
                .status("processed")
                .processedAt(LocalDateTime.now())
                .build();
        try {
            syncLogMapper.insert(record);
        } catch (DuplicateKeyException e) {
            Optional<SyncLog> existing = storedKey != null ? syncLogMapper.findByKey(storedKey) : Optional.empty();
            if (existing.isPresent()) {
                SyncLog replay = existing.get();
                return Map.of("id", String.valueOf(replay.getId()), "synced", "true",
                        "recorded", "true", "replayed", "true");
            }
            throw e;
        }
        return Map.of("id", String.valueOf(record.getId()), "synced", "true", "recorded", "true");
    }

    private String scopedKey(JwtUserPrincipal principal, String endpoint, Map<String, Object> body,
                             String idempotencyKey) {
        if (idempotencyKey == null || idempotencyKey.isBlank()) return null;
        return IdempotencyScope.scopedHash(principal, "POST", endpoint, idempotencyKey, branchId(principal, body));
    }

    private Long branchId(JwtUserPrincipal principal, Map<String, Object> body) {
        if (principal != null && principal.getBranchId() != null) return principal.getBranchId();
        Object branch = body != null ? body.get("branchId") : null;
        if (branch instanceof Number n) return n.longValue();
        if (branch != null && !branch.toString().isBlank()) {
            try {
                return Long.parseLong(branch.toString());
            } catch (NumberFormatException ignored) {
            }
        }
        return null;
    }

    private void applyRepairOrder(JwtUserPrincipal principal, String id, Map<String, Object> body) {
        Object jobCardIdValue = body.get("jobCardId");
        if (jobCardIdValue == null) throw new BadRequestException("jobCardId is required");
        JobCard card = requireScopedJobCard(principal, jobCardIdValue.toString());
        String ref = (id != null && !id.isBlank()) ? id : IdGenerator.shortRef("RO");
        RepairOrder ro = RepairOrder.builder()
                .repairOrderRef(ref)
                .jobCardId(card.getId())
                .servicesTotal(0.0)
                .partsTotal(0.0)
                .grandTotal(0.0)
                .tag(stringValue(body, "tag"))
                .customerRequests(stringValue(body, "customerRequests"))
                .garageRecommendations(stringValue(body, "garageRecommendations"))
                .notifyOwnerSmsEmail(boolValue(body, "notifyOwnerSmsEmail"))
                .build();
        repairOrderMapper.insert(ro);
        double servicesTotal = persistServiceItems(ro.getId(), listValue(body, "serviceLines"));
        double partsTotal = persistPartItems(ro.getId(), listValue(body, "partLines"));
        ro.setServicesTotal(servicesTotal);
        ro.setPartsTotal(partsTotal);
        ro.setGrandTotal(servicesTotal + partsTotal);
        repairOrderMapper.updateById(ro);
        if (card.getStatus() == null || "pending".equals(card.getStatus())) {
            card.setStatus("pendingApproval");
            jobCardMapper.updateById(card);
        }
        if (card.getCustomerId() != null) {
            Customer customer = customerMapper.selectById(card.getCustomerId());
            approvalMapper.insert(Approval.builder()
                    .estimateId(ref)
                    .customerId(card.getCustomerId())
                    .customerName(customer != null && customer.getCustomerName() != null ? customer.getCustomerName() : "")
                    .vehicleId(card.getVehicleId() != null ? String.valueOf(card.getVehicleId()) : "")
                    .amount(ro.getGrandTotal())
                    .action("pending")
                    .build());
        }
    }

    private void applyBooking(JwtUserPrincipal principal, Map<String, Object> body) {
        Customer customer = null;
        if (principal != null && principal.getUserId() != null) {
            customer = customerMapper.findByUserId(principal.getUserId()).orElse(null);
        }
        if (customer == null) throw new ForbiddenException("Customer account is not scoped to the authenticated user");
        String ref = firstNonBlank(body.get("bookingRef"), body.get("id"));
        if (ref == null) ref = IdGenerator.shortRef("BK");
        Booking booking = Booking.builder()
                .bookingRef(ref)
                .customerId(customer.getId())
                .branchId(principal != null ? principal.getBranchId() : null)
                .vehicleName(stringValue(body, "vehicleName"))
                .plateNumber(stringValue(body, "plateNumber"))
                .serviceType(stringValue(body, "serviceType"))
                .bookingDate(parseLocalDateTime(body.get("bookingDate")))
                .notes(stringValue(body, "notes"))
                .status("pending")
                .build();
        bookingMapper.insert(booking);
    }

    private void applyWorkAssignment(JwtUserPrincipal principal, Map<String, Object> body) {
        JobCard card = requireScopedJobCard(principal, String.valueOf(body.getOrDefault("jobCardId", "")));
        List<?> items = listValue(body, "items");
        if (items == null || items.isEmpty()) throw new BadRequestException("items are required");
        int created = 0;
        for (Object raw : items) {
            if (!(raw instanceof Map)) continue;
            @SuppressWarnings("unchecked")
            Map<String, Object> item = (Map<String, Object>) raw;
            workAssignmentMapper.insert(WorkAssignment.builder()
                    .assignmentRef(IdGenerator.shortRef("ASN"))
                    .jobCardId(card.getId())
                    .branchId(principal != null ? principal.getBranchId() : null)
                    .description(stringValue(item, "description"))
                    .department(stringValue(item, "department"))
                    .technicianName(stringValue(item, "technicianName"))
                    .dateOfWork(parseLocalDate(item.get("dateOfWork")))
                    .statusPercent(intValue(item, "statusPercent", 0))
                    .stdTime(stringValue(item, "stdTime"))
                    .remarks(stringValue(item, "remarks"))
                    .status("Pending")
                    .build());
            created++;
        }
        if (created == 0) throw new BadRequestException("No valid assignment items supplied");
        card.setStatus("inProgress");
        jobCardMapper.updateById(card);
    }

    private void applyInspection(JwtUserPrincipal principal, String id, Map<String, Object> body) {
        Object jobCardIdValue = body.get("jobCardId");
        if (jobCardIdValue == null) throw new BadRequestException("jobCardId is required");
        JobCard card = requireScopedJobCard(principal, jobCardIdValue.toString());
        Inspection inspection = null;
        if (id != null && isNumeric(id)) inspection = inspectionMapper.selectById(Long.valueOf(id));
        boolean isNew = inspection == null;
        if (isNew) {
            inspection = Inspection.builder()
                    .inspectionRef("INSP-" + IdGenerator.shortSuffix())
                    .isDraft(true)
                    .build();
        }
        inspection.setJobCardId(card.getId());
        copyString(body, "referenceNumber", inspection::setReferenceNumber);
        copyString(body, "placeOfSupply", inspection::setPlaceOfSupply);
        copyString(body, "customerRequests", inspection::setCustomerRequests);
        copyString(body, "garageRecommendations", inspection::setGarageRecommendations);
        copyString(body, "tag", inspection::setTag);
        if (isNew) inspectionMapper.insert(inspection); else inspectionMapper.updateById(inspection);
        linkBookingFromPayload(principal, body, card.getId());
    }

    private JobCard requireScopedJobCard(JwtUserPrincipal principal, String id) {
        JobCard card = findJobCard(id);
        if (card == null) throw new NotFoundException("Job card not found");
        if (principal != null && principal.getBranchId() != null
                && card.getBranchId() != null && !principal.getBranchId().equals(card.getBranchId())) {
            throw new ForbiddenException("Job card is outside the authenticated branch");
        }
        return card;
    }

    private double persistServiceItems(long repairOrderId, List<?> items) {
        double total = 0;
        if (items == null) return 0;
        for (Object raw : items) {
            if (!(raw instanceof Map)) continue;
            @SuppressWarnings("unchecked")
            Map<String, Object> m = (Map<String, Object>) raw;
            double qty = doubleValue(m, "qty", 1);
            double rate = doubleValue(m, "rate", 0);
            double discPct = doubleValue(m, "discountPercent", 0);
            double discAmt = doubleValue(m, "discountAmount", 0);
            total += Math.max(0, qty * rate * (1 - discPct / 100.0) - discAmt);
            repairOrderServiceMapper.insert(RepairOrderServiceItem.builder()
                    .repairOrderId(repairOrderId).name(stringValue(m, "name")).qty((int) qty)
                    .rate(rate).discountPercent(discPct).discountAmount(discAmt).build());
        }
        return Math.round(total * 100.0) / 100.0;
    }

    private double persistPartItems(long repairOrderId, List<?> items) {
        double total = 0;
        if (items == null) return 0;
        for (Object raw : items) {
            if (!(raw instanceof Map)) continue;
            @SuppressWarnings("unchecked")
            Map<String, Object> m = (Map<String, Object>) raw;
            double qty = doubleValue(m, "qty", 1);
            double rate = doubleValue(m, "rate", 0);
            double discPct = doubleValue(m, "discountPercent", 0);
            double discAmt = doubleValue(m, "discountAmount", 0);
            total += Math.max(0, qty * rate * (1 - discPct / 100.0) - discAmt);
            repairOrderPartMapper.insert(RepairOrderPartItem.builder()
                    .repairOrderId(repairOrderId).name(stringValue(m, "name")).qty((int) qty)
                    .rate(rate).discountPercent(discPct).discountAmount(discAmt).build());
        }
        return Math.round(total * 100.0) / 100.0;
    }

    private void linkBookingFromPayload(JwtUserPrincipal principal, Map<String, Object> body, Long jobCardId) {
        Object bookingIdValue = body.get("bookingId");
        if (bookingIdValue == null || bookingIdValue.toString().isBlank()) return;
        Booking booking = bookingMapper.selectById(Long.parseLong(bookingIdValue.toString()));
        if (booking == null) return;
        if (principal != null && principal.getBranchId() != null
                && booking.getBranchId() != null && !principal.getBranchId().equals(booking.getBranchId())) {
            throw new ForbiddenException("Booking is outside the authenticated branch");
        }
        if (booking.getJobCardId() == null) {
            booking.setJobCardId(jobCardId);
            booking.setStatus("confirmed");
            bookingMapper.updateById(booking);
        }
    }

    private JobCard findJobCard(String id) {
        if (id == null || id.isBlank()) return null;
        if (isNumeric(id)) {
            JobCard byId = jobCardMapper.selectById(Long.valueOf(id));
            if (byId != null) return byId;
        }
        return jobCardMapper.selectOne(new QueryWrapper<JobCard>().eq("job_card_ref", id));
    }

    private String json(Map<String, Object> body) {
        try {
            return objectMapper.writeValueAsString(body);
        } catch (Exception e) {
            throw new BadRequestException("Request body is not serializable");
        }
    }

    private String firstNonBlank(Object... values) {
        for (Object v : values) if (v != null && !v.toString().isBlank()) return v.toString();
        return null;
    }

    private boolean isNumeric(String s) {
        if (s == null || s.isEmpty()) return false;
        for (int i = 0; i < s.length(); i++) if (!Character.isDigit(s.charAt(i))) return false;
        return true;
    }

    private void copyString(Map<String, Object> body, String key, Consumer<String> setter) {
        Object v = body.get(key);
        if (v != null && !v.toString().isBlank()) setter.accept(v.toString());
    }

    private String stringValue(Map<String, Object> m, String key) {
        Object v = m.get(key);
        return v != null ? v.toString() : null;
    }

    private Boolean boolValue(Map<String, Object> m, String key) {
        Object v = m.get(key);
        return v instanceof Boolean ? (Boolean) v : null;
    }

    private Double doubleValue(Map<String, Object> m, String key, double def) {
        Object v = m.get(key);
        if (v instanceof Number n) return n.doubleValue();
        if (v != null) {
            try {
                return Double.parseDouble(v.toString());
            } catch (NumberFormatException ignored) {
            }
        }
        return def;
    }

    private Integer intValue(Map<String, Object> m, String key, int def) {
        Object v = m.get(key);
        if (v instanceof Number n) return n.intValue();
        if (v != null) {
            try {
                return Integer.parseInt(v.toString());
            } catch (NumberFormatException ignored) {
            }
        }
        return def;
    }

    private java.time.LocalDate parseLocalDate(Object v) {
        if (v == null || v.toString().isBlank()) return null;
        try {
            return java.time.LocalDate.parse(v.toString());
        } catch (Exception e) {
            return com.orient.workshop.common.util.DateParse.parseLocalDate(v.toString(), "dateOfWork");
        }
    }

    private LocalDateTime parseLocalDateTime(Object v) {
        if (v == null || v.toString().isBlank()) return null;
        return LocalDateTime.parse(v.toString());
    }

    private List<?> listValue(Map<String, Object> m, String key) {
        Object v = m.get(key);
        return v instanceof List ? (List<?>) v : null;
    }
}
