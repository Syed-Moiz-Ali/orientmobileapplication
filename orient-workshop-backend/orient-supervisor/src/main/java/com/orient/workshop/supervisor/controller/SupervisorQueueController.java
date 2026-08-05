package com.orient.workshop.supervisor.controller;

import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.supervisor.model.dto.*;
import com.orient.workshop.supervisor.service.SupervisorQueueService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Supervisor Queue")
@RestController
@RequiredArgsConstructor
public class SupervisorQueueController {

    private final SupervisorQueueService queueService;

    // ---------- Booking routing ----------

    @GetMapping("/supervisor/bookings")
    public ApiResponse<List<BookingQueueResponse>> getBookingQueue() {
        return ApiResponse.success(queueService.getBookingQueue());
    }

    @PutMapping("/supervisor/bookings/{id}/assign")
    public ApiResponse<Void> assignBooking(@PathVariable Long id,
                                           @RequestBody AssignAdvisorRequest req) {
        queueService.assignBooking(id, req);
        return ApiResponse.success(null);
    }

    // ---------- Breakdown routing ----------

    @GetMapping("/supervisor/breakdowns")
    public ApiResponse<List<BreakdownQueueResponse>> getBreakdownQueue() {
        return ApiResponse.success(queueService.getBreakdownQueue());
    }

    @PutMapping("/supervisor/breakdowns/{id}/assign")
    public ApiResponse<Void> assignBreakdown(@PathVariable Long id,
                                             @RequestBody AssignAdvisorRequest req) {
        queueService.assignBreakdown(id, req);
        return ApiResponse.success(null);
    }

    // ---------- Completion review ----------

    @GetMapping("/supervisor/jobs/awaiting")
    public ApiResponse<List<AwaitingCompletionResponse>> getAwaitingCompletion() {
        return ApiResponse.success(queueService.getAwaitingCompletion());
    }

    @PutMapping("/supervisor/jobs/{jobCardId}/approve-completion")
    public ApiResponse<Void> approveCompletion(@PathVariable Long jobCardId) {
        queueService.approveCompletion(jobCardId);
        return ApiResponse.success(null);
    }

    @PutMapping("/supervisor/jobs/{jobCardId}/reject-completion")
    public ApiResponse<Void> rejectCompletion(@PathVariable Long jobCardId,
                                              @RequestBody(required = false) RejectCompletionRequest req) {
        queueService.rejectCompletion(jobCardId, req);
        return ApiResponse.success(null);
    }

    @PostMapping("/supervisor/job-cards/{jobCardRef}/qc-review")
    public ApiResponse<Void> qcReview(@PathVariable String jobCardRef, @RequestBody QcReviewRequest req) {
        queueService.qcReview(jobCardRef, req);
        return ApiResponse.success(null);
    }

    // ---------- Reference ----------

    @GetMapping("/supervisor/assignable-advisors")
    public ApiResponse<List<AssignableStaffResponse>> getAssignableAdvisors() {
        return ApiResponse.success(queueService.getAssignableAdvisors());
    }
}
