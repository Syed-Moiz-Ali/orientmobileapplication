package com.orient.workshop.technician.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.technician.model.dto.*;
import com.orient.workshop.technician.service.TechnicianJobService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Technician")
@RestController
@RequestMapping("/technicians")
@RequiredArgsConstructor
public class TechnicianJobController {

    private final TechnicianJobService jobService;

    @GetMapping("/assigned-jobs")
    public ApiResponse<List<AssignedJobResponse>> getAssignedJobs(@AuthenticationPrincipal JwtUserPrincipal principal,
                                                                   @RequestParam(required = false) String empId,
                                                                   @RequestParam(defaultValue = "1") int page,
                                                                   @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(jobService.getAssignedJobs(principal));
    }

    @PutMapping("/assigned-jobs/{id}/status")
    public ApiResponse<Void> updateAssignedJobStatus(@AuthenticationPrincipal JwtUserPrincipal principal,
                                                      @PathVariable Long id,
                                                      @Valid @RequestBody UpdateAssignedJobStatusRequest req) {
        jobService.updateAssignedJobStatus(id, principal, req.getStatus());
        return ApiResponse.success(null);
    }

    @GetMapping("/jobs")
    public ApiResponse<List<TechnicianJobResponse>> getJobs(@AuthenticationPrincipal JwtUserPrincipal principal,
                                                             @RequestParam(required = false) String empId,
                                                             @RequestParam(required = false) String status) {
        return ApiResponse.success(jobService.getJobs(principal, status));
    }

    @GetMapping("/jobs/search")
    public ApiResponse<TechnicianJobResponse> searchJob(@AuthenticationPrincipal JwtUserPrincipal principal,
                                                         @RequestParam String q) {
        return ApiResponse.success(jobService.searchJob(principal, q));
    }

    @PutMapping("/jobs/{jobCardNo}/notes")
    public ApiResponse<Void> updateNotes(@AuthenticationPrincipal JwtUserPrincipal principal,
                                          @PathVariable String jobCardNo,
                                          @Valid @RequestBody NotesRequest req) {
        jobService.updateNotes(principal, jobCardNo, req.getNotes());
        return ApiResponse.success(null);
    }
}
