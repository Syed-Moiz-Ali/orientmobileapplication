package com.orient.workshop.sync.controller;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.sync.service.SyncApplicationService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Tag(name = "Sync")
@RestController
@RequestMapping("/sync")
@RequiredArgsConstructor
public class SyncController {
    private final SyncApplicationService syncApplicationService;

    @PostMapping("/inspections/{id}")
    public ApiResponse<Map<String, String>> syncInspection(
            @AuthenticationPrincipal JwtUserPrincipal principal,
            @PathVariable String id,
            @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
            @RequestBody Map<String, Object> body) {
        return ApiResponse.success(syncApplicationService.syncInspection(principal, id, body, idempotencyKey));
    }

    @PostMapping("/jobs/complete/{id}")
    public ApiResponse<Map<String, String>> syncJobComplete(
            @AuthenticationPrincipal JwtUserPrincipal principal,
            @PathVariable String id,
            @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
            @RequestBody Map<String, Object> body) {
        return ApiResponse.success(syncApplicationService.syncJobComplete(principal, id, body, idempotencyKey));
    }

    @PostMapping("/repair-orders/{id}")
    public ApiResponse<Map<String, String>> syncRepairOrder(
            @AuthenticationPrincipal JwtUserPrincipal principal,
            @PathVariable String id,
            @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
            @RequestBody Map<String, Object> body) {
        return ApiResponse.success(syncApplicationService.syncRepairOrder(principal, id, body, idempotencyKey));
    }

    @PostMapping("/bookings")
    public ApiResponse<Map<String, String>> syncBooking(
            @AuthenticationPrincipal JwtUserPrincipal principal,
            @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
            @RequestBody Map<String, Object> body) {
        return ApiResponse.success(syncApplicationService.syncBooking(principal, body, idempotencyKey));
    }

    @PostMapping("/work-assignments")
    public ApiResponse<Map<String, String>> syncWorkAssignment(
            @AuthenticationPrincipal JwtUserPrincipal principal,
            @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
            @RequestBody Map<String, Object> body) {
        return ApiResponse.success(syncApplicationService.syncWorkAssignment(principal, body, idempotencyKey));
    }
}
