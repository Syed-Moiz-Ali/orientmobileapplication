package com.orient.workshop.sync.controller;

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
import com.orient.workshop.common.response.ApiResponse;
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
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.function.Consumer;

@Slf4j
@Tag(name = "Sync")
@RestController
@RequestMapping("/sync")
@RequiredArgsConstructor
public class SyncController {

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

    @PostMapping("/inspections/{id}")
    public ApiResponse<Map<String, String>> syncInspection(@PathVariable String id,
                                                           @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
                                                           @RequestBody Map<String, Object> body) {
        Map<String, String> result = record("inspection", id, "/sync/inspections/" + id, body, idempotencyKey);
        if (isReplay(result)) return ApiResponse.success(result);
        applyInspection(id, body);
        return ApiResponse.success(result);
    }

    @PostMapping("/jobs/complete/{id}")
    public ApiResponse<Map<String, String>> syncJobComplete(@PathVariable String id,
                                                            @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
                                                            @RequestBody Map<String, Object> body) {
        Map<String, String> result = record("job_complete", id, "/sync/jobs/complete/" + id, body, idempotencyKey);
        if (isReplay(result)) return ApiResponse.success(result);
        applyJobComplete(id);
        return ApiResponse.success(result);
    }

    @PostMapping("/repair-orders/{id}")
    public ApiResponse<Map<String, String>> syncRepairOrder(@PathVariable String id,
                                                            @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
                                                            @RequestBody Map<String, Object> body) {
        Map<String, String> result = record("repair_order", id, "/sync/repair-orders/" + id, body, idempotencyKey);
        if (isReplay(result)) return ApiResponse.success(result);
        // FIX (audit P0): repair orders were log-only — the workshop never saw
        // offline-created repair orders. Now they are persisted with line items.
        applyRepairOrder(id, body);
        return ApiResponse.success(result);
    }

    @PostMapping("/bookings")
    public ApiResponse<Map<String, String>> syncBooking(@AuthenticationPrincipal JwtUserPrincipal principal,
                                                        @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
                                                        @RequestBody Map<String, Object> body) {
        String entityId = firstNonBlank(body.get("bookingRef"), body.get("id"));
        if (entityId == null) {
            entityId = IdGenerator.shortRef("SYNC-BK");
        }
        Map<String, String> result = record("booking", entityId, "/sync/bookings", body, idempotencyKey);
        if (isReplay(result)) return ApiResponse.success(result);
        // FIX (audit P0): bookings were log-only — persist the row so the
        // supervisor queue actually sees offline customer bookings.
        applyBooking(principal, body);
        return ApiResponse.success(result);
    }

    @PostMapping("/work-assignments")
    public ApiResponse<Map<String, String>> syncWorkAssignment(@AuthenticationPrincipal JwtUserPrincipal principal,
                                                               @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
                                                               @RequestBody Map<String, Object> body) {
        String entityId = firstNonBlank(body.get("assignmentRef"), body.get("id"));
        if (entityId == null) {
            entityId = IdGenerator.shortRef("SYNC-WA");
        }
        Map<String, String> result = record("work_assignment", entityId, "/sync/work-assignments", body, idempotencyKey);
        if (isReplay(result)) return ApiResponse.success(result);
        // FIX (audit P0): work assignments were log-only — persist them so the
        // technician actually receives the assigned work.
        applyWorkAssignment(principal, body);
        return ApiResponse.success(result);
    }

    // ===== persistence =====

    private boolean isReplay(Map<String, String> result) {
        return Boolean.parseBoolean(result.getOrDefault("replayed", "false"));
    }

    private Map<String, String> record(String entityType, String entityId, String endpoint,
                                       Map<String, Object> body, String idempotencyKey) {
        if (idempotencyKey != null && !idempotencyKey.isBlank()) {
            Optional<SyncLog> existing = syncLogMapper.findByKey(idempotencyKey);
            if (existing.isPresent()) {
                SyncLog record = existing.get();
                log.info("sync replayed for key {} (sync_log id {})", idempotencyKey, record.getId());
                return Map.of("id", String.valueOf(record.getId()), "synced", "true", "recorded", "true", "replayed", "true");
            }
        }
        SyncLog record = SyncLog.builder()
                .idempotencyKey(idempotencyKey != null ? idempotencyKey : "")
                .entityType(entityType)
                .entityId(entityId)
                .endpoint(endpoint)
                .method("POST")
                .requestBody(json(body))
                .payload(json(body))
                .status("processed")
                .processedAt(LocalDateTime.now())
                .build();
        syncLogMapper.insert(record);
        log.info("sync recorded: {} {} (sync_log id {})", entityType, entityId, record.getId());
        return Map.of("id", String.valueOf(record.getId()), "synced", "true", "recorded", "true");
    }

    // ===== semantic apply (best effort; payload is always stored above) =====

    @Transactional
    public void applyJobComplete(String id) {
        try {
            JobCard card = findJobCard(id);
            if (card == null) {
                log.warn("sync jobs/complete: no job card found for {}", id);
                return;
            }
            card.setStatus("completed");
            jobCardMapper.updateById(card);
            log.info("sync jobs/complete: job card {} ({}) marked completed", card.getId(), card.getJobCardRef());
        } catch (Exception e) {
            log.warn("sync jobs/complete: could not mark job card {} completed: {}", id, e.getMessage());
        }
    }

    @Transactional
    public void applyRepairOrder(String id, Map<String, Object> body) {
        try {
            Object jobCardIdValue = body.get("jobCardId");
            if (jobCardIdValue == null) {
                log.debug("sync repair-orders/{}: no jobCardId in payload, persistence only", id);
                return;
            }
            long jobCardId = Long.parseLong(jobCardIdValue.toString());
            JobCard card = jobCardMapper.selectById(jobCardId);
            if (card == null) {
                log.warn("sync repair-orders/{}: job card {} not found", id, jobCardId);
                return;
            }

            String ref = (id != null && !id.isBlank()) ? id : IdGenerator.shortRef("RO");
            RepairOrder ro = RepairOrder.builder()
                    .repairOrderRef(ref)
                    .jobCardId(jobCardId)
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

            // Mirror the online create: move the job card into pendingApproval
            // and auto-create the customer approval row.
            if (card.getStatus() == null || "pending".equals(card.getStatus())) {
                card.setStatus("pendingApproval");
                jobCardMapper.updateById(card);
            }
            if (card.getCustomerId() != null) {
                Customer customer = customerMapper.selectById(card.getCustomerId());
                String customerName = customer != null && customer.getCustomerName() != null
                        ? customer.getCustomerName() : "";
                approvalMapper.insert(Approval.builder()
                        .estimateId(ref)
                        .customerId(card.getCustomerId())
                        .customerName(customerName)
                        .vehicleId(card.getVehicleId() != null ? String.valueOf(card.getVehicleId()) : "")
                        .amount(ro.getGrandTotal())
                        .action("pending")
                        .build());
            }
            log.info("sync repair-orders/{}: persisted RO {} (services {}, parts {}, total {})",
                    id, ref, servicesTotal, partsTotal, ro.getGrandTotal());
        } catch (Exception e) {
            log.warn("sync repair-orders/{}: could not apply payload (stored anyway): {}", id, e.getMessage());
        }
    }

    @Transactional
    public void applyBooking(JwtUserPrincipal principal, Map<String, Object> body) {
        try {
            // Resolve the customer from the authenticated principal — the
            // offline payload has no identity of its own.
            Customer customer = null;
            if (principal != null && principal.getUserId() != null) {
                customer = customerMapper.findByUserId(principal.getUserId()).orElse(null);
            }
            if (customer == null) {
                log.warn("sync bookings: no customer resolved for principal, persistence only");
                return;
            }
            String ref = firstNonBlank(body.get("bookingRef"), body.get("id"));
            if (ref == null) ref = IdGenerator.shortRef("BK");
            LocalDateTime bookingDate = null;
            Object dateValue = body.get("bookingDate");
            if (dateValue != null) {
                try {
                    bookingDate = LocalDateTime.parse(dateValue.toString());
                } catch (Exception e) {
                    log.debug("sync bookings: unparseable bookingDate '{}'", dateValue);
                }
            }
            Booking booking = Booking.builder()
                    .bookingRef(ref)
                    .customerId(customer.getId())
                    .branchId(principal != null ? principal.getBranchId() : null)
                    .vehicleName(stringValue(body, "vehicleName"))
                    .plateNumber(stringValue(body, "plateNumber"))
                    .serviceType(stringValue(body, "serviceType"))
                    .bookingDate(bookingDate)
                    .notes(stringValue(body, "notes"))
                    .status("pending")
                    .build();
            bookingMapper.insert(booking);
            log.info("sync bookings: persisted booking {} for customer {}", ref, customer.getId());
        } catch (Exception e) {
            log.warn("sync bookings: could not apply payload (stored anyway): {}", e.getMessage());
        }
    }

    @Transactional
    public void applyWorkAssignment(JwtUserPrincipal principal, Map<String, Object> body) {
        try {
            JobCard card = findJobCard(String.valueOf(body.getOrDefault("jobCardId", "")));
            if (card == null) {
                log.warn("sync work-assignments: no job card found in payload, persistence only");
                return;
            }
            List<?> items = listValue(body, "items");
            if (items == null) return;
            int created = 0;
            for (Object raw : items) {
                if (!(raw instanceof Map)) continue;
                @SuppressWarnings("unchecked")
                Map<String, Object> item = (Map<String, Object>) raw;
                WorkAssignment wa = WorkAssignment.builder()
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
                        .build();
                workAssignmentMapper.insert(wa);
                created++;
            }
            if (created > 0) {
                card.setStatus("inProgress");
                jobCardMapper.updateById(card);
            }
            log.info("sync work-assignments: persisted {} assignment(s) for job card {}", created, card.getJobCardRef());
        } catch (Exception e) {
            log.warn("sync work-assignments: could not apply payload (stored anyway): {}", e.getMessage());
        }
    }

    @Transactional
    public void applyInspection(String id, Map<String, Object> body) {
        try {
            Object jobCardIdValue = body.get("jobCardId");
            if (jobCardIdValue == null) {
                log.debug("sync inspections/{}: no jobCardId in payload, persistence only", id);
                return;
            }
            long jobCardId = Long.parseLong(jobCardIdValue.toString());
            Inspection inspection = null;
            if (id != null && isNumeric(id)) {
                inspection = inspectionMapper.selectById(Long.valueOf(id));
            }
            boolean isNew = inspection == null;
            if (isNew) {
                inspection = Inspection.builder()
                        .inspectionRef("INSP-" + IdGenerator.shortSuffix())
                        .isDraft(true)
                        .build();
            }
            inspection.setJobCardId(jobCardId);
            copyString(body, "referenceNumber", inspection::setReferenceNumber);
            copyString(body, "placeOfSupply", inspection::setPlaceOfSupply);
            copyString(body, "customerRequests", inspection::setCustomerRequests);
            copyString(body, "garageRecommendations", inspection::setGarageRecommendations);
            copyString(body, "tag", inspection::setTag);
            if (isNew) {
                inspectionMapper.insert(inspection);
                log.info("sync inspections/{}: created inspection {} for job card {}", id, inspection.getId(), jobCardId);
            } else {
                inspectionMapper.updateById(inspection);
                log.info("sync inspections/{}: updated inspection {} for job card {}", id, inspection.getId(), jobCardId);
            }
            linkBookingFromPayload(body, jobCardId);
        } catch (Exception e) {
            log.warn("sync inspections/{}: could not apply inspection payload (stored anyway): {}", id, e.getMessage());
        }
    }

    // ===== line-item persistence (server-side totals, same math as online path) =====

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
            double lineTotal = Math.max(0, qty * rate * (1 - discPct / 100.0) - discAmt);
            total += lineTotal;
            repairOrderServiceMapper.insert(RepairOrderServiceItem.builder()
                    .repairOrderId(repairOrderId)
                    .name(stringValue(m, "name"))
                    .qty((int) qty)
                    .rate(rate)
                    .discountPercent(discPct)
                    .discountAmount(discAmt)
                    .build());
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
            double lineTotal = Math.max(0, qty * rate * (1 - discPct / 100.0) - discAmt);
            total += lineTotal;
            repairOrderPartMapper.insert(RepairOrderPartItem.builder()
                    .repairOrderId(repairOrderId)
                    .name(stringValue(m, "name"))
                    .qty((int) qty)
                    .rate(rate)
                    .discountPercent(discPct)
                    .discountAmount(discAmt)
                    .build());
        }
        return Math.round(total * 100.0) / 100.0;
    }

    private void linkBookingFromPayload(Map<String, Object> body, Long jobCardId) {
        try {
            Object bookingIdValue = body.get("bookingId");
            if (bookingIdValue == null || bookingIdValue.toString().isBlank()) return;
            long bookingId = Long.parseLong(bookingIdValue.toString());
            Booking booking = bookingMapper.selectById(bookingId);
            if (booking != null && booking.getJobCardId() == null) {
                booking.setJobCardId(jobCardId);
                booking.setStatus("confirmed");
                bookingMapper.updateById(booking);
                log.info("sync: linked booking {} to job card {}", bookingId, jobCardId);
            }
        } catch (Exception e) {
            log.warn("sync: could not link booking from payload: {}", e.getMessage());
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

    // ===== helpers =====

    private String json(Map<String, Object> body) {
        try {
            return objectMapper.writeValueAsString(body);
        } catch (Exception e) {
            return "{}";
        }
    }

    private String firstNonBlank(Object... values) {
        for (Object v : values) {
            if (v != null && !v.toString().isBlank()) return v.toString();
        }
        return null;
    }

    private boolean isNumeric(String s) {
        if (s == null || s.isEmpty()) return false;
        for (int i = 0; i < s.length(); i++) {
            if (!Character.isDigit(s.charAt(i))) return false;
        }
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
            try {
                return com.orient.workshop.common.util.DateParse.parseLocalDate(v.toString(), "dateOfWork");
            } catch (Exception e2) {
                return null;
            }
        }
    }

    private List<?> listValue(Map<String, Object> m, String key) {
        Object v = m.get(key);
        if (v instanceof List) return (List<?>) v;
        return null;
    }
}
