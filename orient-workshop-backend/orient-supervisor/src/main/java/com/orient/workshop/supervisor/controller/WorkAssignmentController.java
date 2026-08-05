package com.orient.workshop.supervisor.controller;

import io.swagger.v3.oas.annotations.tags.Tag;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.supervisor.model.dto.AssignedJobResponse;
import com.orient.workshop.supervisor.model.dto.AvailableTechnicianResponse;
import com.orient.workshop.supervisor.model.dto.WorkAssignmentRequest;
import com.orient.workshop.supervisor.model.dto.WorkAssignmentResponse;
import com.orient.workshop.supervisor.service.WorkAssignmentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Supervisor")
@RestController
@RequiredArgsConstructor
public class WorkAssignmentController {

    private final WorkAssignmentService workAssignmentService;

    @PostMapping("/work-assignments")
    public ApiResponse<WorkAssignmentResponse> createAssignments(@AuthenticationPrincipal JwtUserPrincipal principal,
                                                                  @Valid @RequestBody WorkAssignmentRequest req) {
        return ApiResponse.success(workAssignmentService.createAssignments(principal, req));
    }

    @GetMapping("/supervisor/assigned-jobs")
    public ApiResponse<List<AssignedJobResponse>> getAssignedJobs() {
        return ApiResponse.success(workAssignmentService.getAssignedJobs());
    }

    @GetMapping("/supervisor/technicians/available")
    public ApiResponse<List<AvailableTechnicianResponse>> getAvailableTechnicians() {
        return ApiResponse.success(workAssignmentService.getAvailableTechnicians());
    }
}
