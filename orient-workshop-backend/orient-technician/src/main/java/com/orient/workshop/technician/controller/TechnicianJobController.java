package com.orient.workshop.technician.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.technician.model.dto.*;
import com.orient.workshop.technician.service.TechnicianJobService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Technician")
@RestController
@RequestMapping("/technicians")
@RequiredArgsConstructor
public class TechnicianJobController {

    private final TechnicianJobService jobService;

    @GetMapping("/assigned-jobs")
    public ApiResponse<List<AssignedJobResponse>> getAssignedJobs(@RequestParam String empId,
                                                                   @RequestParam(defaultValue = "1") int page,
                                                                   @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(jobService.getAssignedJobs(empId));
    }

    @PutMapping("/assigned-jobs/{id}/status")
    public ApiResponse<Void> updateAssignedJobStatus(@PathVariable Long id,
                                                      @Valid @RequestBody UpdateAssignedJobStatusRequest req) {
        jobService.updateAssignedJobStatus(id, req.getEmpId(), req.getStatus());
        return ApiResponse.success(null);
    }

    @GetMapping("/jobs")
    public ApiResponse<List<TechnicianJobResponse>> getJobs(@RequestParam String empId,
                                                             @RequestParam(required = false) String status) {
        return ApiResponse.success(jobService.getJobs(empId, status));
    }

    @GetMapping("/jobs/search")
    public ApiResponse<TechnicianJobResponse> searchJob(@RequestParam String q) {
        return ApiResponse.success(jobService.searchJob(q));
    }

    @PutMapping("/jobs/{jobCardNo}/notes")
    public ApiResponse<Void> updateNotes(@PathVariable String jobCardNo,
                                          @Valid @RequestBody NotesRequest req) {
        jobService.updateNotes(jobCardNo, req.getNotes());
        return ApiResponse.success(null);
    }
}

