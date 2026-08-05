package com.orient.workshop.sync.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.orient.workshop.advisor.model.entity.Inspection;
import com.orient.workshop.advisor.repository.InspectionMapper;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.common.util.IdGenerator;
import com.orient.workshop.core.model.entity.Booking;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.repository.BookingMapper;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.sync.model.entity.SyncLog;
import com.orient.workshop.sync.repository.SyncLogMapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
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
    private final ObjectMapper objectMapper;

    @PostMapping("/inspections/{id}")
    public ApiResponse<Map<String, String>> syncInspection(@PathVariable String id,
                                                           @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
                                                           @RequestBody Map<String, Object> body) {
        Map<String, String> result = record("inspection", id, "/sync/inspections/" + id, body, idempotencyKey);
        applyInspection(id, body);
        return ApiResponse.success(result);
    }

    @PostMapping("/jobs/complete/{id}")
    public ApiResponse<Map<String, String>> syncJobComplete(@PathVariable String id,
                                                            @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
                                                            @RequestBody Map<String, Object> body) {
        Map<String, String> result = record("job_complete", id, "/sync/jobs/complete/" + id, body, idempotencyKey);
        applyJobComplete(id);
        return ApiResponse.success(result);
    }

    @PostMapping("/repair-orders/{id}")
    public ApiResponse<Map<String, String>> syncRepairOrder(@PathVariable String id,
                                                            @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
                                                            @RequestBody Map<String, Object> body) {
        Map<String, String> result = record("repair_order", id, "/sync/repair-orders/" + id, body, idempotencyKey);
        return ApiResponse.success(result);
    }

    @PostMapping("/bookings")
    public ApiResponse<Map<String, String>> syncBooking(@RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
                                                        @RequestBody Map<String, Object> body) {
        String entityId = firstNonBlank(body.get("bookingRef"), body.get("id"));
        if (entityId == null) {
            entityId = IdGenerator.shortRef("SYNC-BK");
        }
        Map<String, String> result = record("booking", entityId, "/sync/bookings", body, idempotencyKey);
        return ApiResponse.success(result);
    }

    @PostMapping("/work-assignments")
    public ApiResponse<Map<String, String>> syncWorkAssignment(@RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
                                                               @RequestBody Map<String, Object> body) {
        String entityId = firstNonBlank(body.get("assignmentRef"), body.get("id"));
        if (entityId == null) {
            entityId = IdGenerator.shortRef("SYNC-WA");
        }
        Map<String, String> result = record("work_assignment", entityId, "/sync/work-assignments", body, idempotencyKey);
        return ApiResponse.success(result);
    }

    // ===== persistence =====

    private Map<String, String> record(String entityType, String entityId, String endpoint,
                                       Map<String, Object> body, String idempotencyKey) {
        if (idempotencyKey != null && !idempotencyKey.isBlank()) {
            Optional<SyncLog> existing = syncLogMapper.findByKey(idempotencyKey);
            if (existing.isPresent()) {
                SyncLog record = existing.get();
                log.info("sync replayed for key {} (sync_log id {})", idempotencyKey, record.getId());
                return Map.of("id", String.valueOf(record.getId()), "synced", "true", "recorded", "true");
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

    private void applyJobComplete(String id) {
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

    private void applyInspection(String id, Map<String, Object> body) {
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
}
