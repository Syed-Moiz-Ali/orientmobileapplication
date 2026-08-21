package com.orient.workshop.supervisor.controller;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.supervisor.model.dto.*;
import com.orient.workshop.supervisor.service.SupervisorQueueService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Supervisor Queue")
@RestController
@RequiredArgsConstructor
public class SupervisorQueueController {

    private final SupervisorQueueService queueService;

    // ---------- Booking routing ----------

    @GetMapping("/supervisor/bookings")
    public ApiResponse<List<BookingQueueResponse>> getBookingQueue(@AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(queueService.getBookingQueue(principal));
    }

    @PutMapping("/supervisor/bookings/{id}/assign")
    public ApiResponse<Void> assignBooking(@PathVariable Long id,
                                           @AuthenticationPrincipal JwtUserPrincipal principal,
                                           @RequestBody AssignAdvisorRequest req) {
        queueService.assignBooking(principal, id, req);
        return ApiResponse.success(null);
    }

    // ---------- Breakdown routing ----------

    @GetMapping("/supervisor/breakdowns")
    public ApiResponse<List<BreakdownQueueResponse>> getBreakdownQueue(@AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(queueService.getBreakdownQueue(principal));
    }

    @PutMapping("/supervisor/breakdowns/{id}/assign")
    public ApiResponse<Void> assignBreakdown(@PathVariable Long id,
                                             @AuthenticationPrincipal JwtUserPrincipal principal,
                                             @RequestBody AssignAdvisorRequest req) {
        queueService.assignBreakdown(principal, id, req);
        return ApiResponse.success(null);
    }

    // ---------- Completion review ----------

    @GetMapping("/supervisor/jobs/awaiting")
    public ApiResponse<List<AwaitingCompletionResponse>> getAwaitingCompletion(@AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(queueService.getAwaitingCompletion(principal));
    }

    @PutMapping("/supervisor/jobs/{jobCardId}/approve-completion")
    public ApiResponse<Void> approveCompletion(@PathVariable Long jobCardId,
                                               @AuthenticationPrincipal JwtUserPrincipal principal) {
        queueService.approveCompletion(principal, jobCardId);
        return ApiResponse.success(null);
    }

    @PutMapping("/supervisor/jobs/{jobCardId}/reject-completion")
    public ApiResponse<Void> rejectCompletion(@PathVariable Long jobCardId,
                                              @AuthenticationPrincipal JwtUserPrincipal principal,
                                              @RequestBody(required = false) RejectCompletionRequest req) {
        queueService.rejectCompletion(principal, jobCardId, req);
        return ApiResponse.success(null);
    }

    @PostMapping("/supervisor/job-cards/{jobCardRef}/qc-review")
    public ApiResponse<Void> qcReview(@PathVariable String jobCardRef,
                                      @AuthenticationPrincipal JwtUserPrincipal principal,
                                      @RequestBody QcReviewRequest req) {
        queueService.qcReview(principal, jobCardRef, req);
        return ApiResponse.success(null);
    }

    // ---------- Reference ----------

    @GetMapping("/supervisor/assignable-advisors")
    public ApiResponse<List<AssignableStaffResponse>> getAssignableAdvisors(@AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(queueService.getAssignableAdvisors(principal));
    }
}
