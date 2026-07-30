package com.orient.workshop.technician.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.technician.model.dto.CompleteJobRequest;
import com.orient.workshop.technician.model.dto.TaskActionRequest;
import com.orient.workshop.technician.service.TaskService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Technician")
@RestController
@RequiredArgsConstructor
public class TaskController {

    private final TaskService taskService;

    @PutMapping("/technicians/jobs/{jobCardNo}/tasks/{taskId}/start")
    public ApiResponse<Void> startTask(@PathVariable String jobCardNo, @PathVariable String taskId,
                                        @RequestBody TaskActionRequest req) {
        taskService.startTask(jobCardNo, taskId, req);
        return ApiResponse.success(null);
    }

    @PutMapping("/technicians/jobs/{jobCardNo}/tasks/{taskId}/complete")
    public ApiResponse<Void> completeTask(@PathVariable String jobCardNo, @PathVariable String taskId,
                                           @RequestBody TaskActionRequest req) {
        taskService.completeTask(jobCardNo, taskId, req);
        return ApiResponse.success(null);
    }

    @PutMapping("/technicians/jobs/{jobCardNo}/tasks/{taskId}/status")
    public ApiResponse<Void> updateTaskStatus(@PathVariable String jobCardNo, @PathVariable String taskId,
                                               @RequestBody TaskActionRequest req) {
        taskService.updateTaskStatus(jobCardNo, taskId, req);
        return ApiResponse.success(null);
    }

    @PostMapping("/jobs/complete")
    public ApiResponse<Void> completeJob(@Valid @RequestBody CompleteJobRequest req) {
        taskService.completeJob(req);
        return ApiResponse.success(null);
    }
}

