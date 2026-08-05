package com.orient.workshop.technician.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.technician.model.dto.CompleteJobRequest;
import com.orient.workshop.technician.model.dto.TaskActionRequest;
import com.orient.workshop.technician.service.TaskService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Technician")
@RestController
@RequiredArgsConstructor
public class TaskController {

    private final TaskService taskService;

    @PutMapping("/technicians/jobs/{jobCardNo}/tasks/{taskId}/start")
    public ApiResponse<Void> startTask(@AuthenticationPrincipal JwtUserPrincipal principal,
                                        @PathVariable String jobCardNo, @PathVariable String taskId,
                                        @RequestBody TaskActionRequest req) {
        taskService.startTask(principal, jobCardNo, taskId, req);
        return ApiResponse.success(null);
    }

    @PutMapping("/technicians/jobs/{jobCardNo}/tasks/{taskId}/complete")
    public ApiResponse<Void> completeTask(@AuthenticationPrincipal JwtUserPrincipal principal,
                                           @PathVariable String jobCardNo, @PathVariable String taskId,
                                           @RequestBody TaskActionRequest req) {
        taskService.completeTask(principal, jobCardNo, taskId, req);
        return ApiResponse.success(null);
    }

    @PutMapping("/technicians/jobs/{jobCardNo}/tasks/{taskId}/status")
    public ApiResponse<Void> updateTaskStatus(@AuthenticationPrincipal JwtUserPrincipal principal,
                                               @PathVariable String jobCardNo, @PathVariable String taskId,
                                               @RequestBody TaskActionRequest req) {
        taskService.updateTaskStatus(principal, jobCardNo, taskId, req);
        return ApiResponse.success(null);
    }

    @PostMapping("/jobs/complete")
    public ApiResponse<Void> completeJob(@AuthenticationPrincipal JwtUserPrincipal principal,
                                          @Valid @RequestBody CompleteJobRequest req) {
        taskService.completeJob(principal, req);
        return ApiResponse.success(null);
    }
}
