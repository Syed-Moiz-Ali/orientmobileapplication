package com.orient.workshop.technician.controller;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.exception.ForbiddenException;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.core.model.dto.WorkItemActionRequest;
import com.orient.workshop.core.model.dto.WorkItemResponse;
import com.orient.workshop.core.model.entity.Staff;
import com.orient.workshop.core.repository.StaffMapper;
import com.orient.workshop.core.service.WorkItemService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Technician Work Items")
@RestController
@RequestMapping("/technicians/work-items")
@RequiredArgsConstructor
public class WorkItemController {

    private final WorkItemService workItemService;
    private final StaffMapper staffMapper;

    @GetMapping
    public ApiResponse<List<WorkItemResponse>> getMyWorkItems(@AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(workItemService.listMyItems(resolveEmpId(principal)));
    }

    @PutMapping("/{taskId}/status")
    public ApiResponse<Void> updateStatus(@AuthenticationPrincipal JwtUserPrincipal principal,
                                          @PathVariable Long taskId,
                                          @RequestBody WorkItemActionRequest req) {
        workItemService.updateStatus(taskId, resolveEmpId(principal), req.getStatus());
        return ApiResponse.success(null);
    }

    @PutMapping("/{taskId}/start")
    public ApiResponse<Void> start(@AuthenticationPrincipal JwtUserPrincipal principal,
                                   @PathVariable Long taskId,
                                   @RequestBody(required = false) WorkItemActionRequest req) {
        workItemService.start(taskId, resolveEmpId(principal), req != null ? req.getStartTime() : null);
        return ApiResponse.success(null);
    }

    @PutMapping("/{taskId}/complete")
    public ApiResponse<Void> complete(@AuthenticationPrincipal JwtUserPrincipal principal,
                                      @PathVariable Long taskId,
                                      @RequestBody(required = false) WorkItemActionRequest req) {
        workItemService.complete(taskId, resolveEmpId(principal), req != null ? req.getEndTime() : null);
        return ApiResponse.success(null);
    }

    @PutMapping("/{taskId}/notes")
    public ApiResponse<Void> notes(@AuthenticationPrincipal JwtUserPrincipal principal,
                                   @PathVariable Long taskId,
                                   @RequestBody WorkItemActionRequest req) {
        workItemService.updateNotes(taskId, resolveEmpId(principal), req.getNotes());
        return ApiResponse.success(null);
    }

    private String resolveEmpId(JwtUserPrincipal principal) {
        if (principal == null || principal.getUserId() == null) {
            throw new ForbiddenException("Authenticated user not found");
        }
        return staffMapper.findByUserId(principal.getUserId())
                .map(Staff::getEmpId)
                .orElseThrow(() -> new ForbiddenException("No staff record linked to the authenticated user"));
    }
}
