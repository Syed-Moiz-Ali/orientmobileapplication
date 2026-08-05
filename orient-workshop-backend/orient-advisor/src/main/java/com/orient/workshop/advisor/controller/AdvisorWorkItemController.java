package com.orient.workshop.advisor.controller;

import com.orient.workshop.advisor.model.dto.AdvisorBookingResponse;
import com.orient.workshop.advisor.model.dto.AdvisorTechnicianResponse;
import com.orient.workshop.advisor.service.AdvisorBookingService;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.core.model.dto.AssignWorkItemBatchRequest;
import com.orient.workshop.core.model.dto.AssignWorkItemRequest;
import com.orient.workshop.core.model.dto.WorkItemResponse;
import com.orient.workshop.core.model.entity.Staff;
import com.orient.workshop.core.repository.StaffMapper;
import com.orient.workshop.core.service.WorkItemService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@Tag(name = "Advisor Work Items")
@RestController
@RequiredArgsConstructor
public class AdvisorWorkItemController {

    private final WorkItemService workItemService;
    private final AdvisorBookingService advisorBookingService;
    private final StaffMapper staffMapper;

    // ---------- Assigned bookings (supervisor -> advisor routing) ----------

    @GetMapping("/advisor/bookings")
    public ApiResponse<List<AdvisorBookingResponse>> getAssignedBookings(
            @AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(advisorBookingService.getAssignedBookings(principal));
    }

    // ---------- Work item visibility & per-item assignment ----------

    @GetMapping("/advisor/job-cards/{jobCardRef}/work-items")
    public ApiResponse<List<WorkItemResponse>> getWorkItems(@PathVariable String jobCardRef) {
        return ApiResponse.success(workItemService.listForJobCard(jobCardRef));
    }

    @PutMapping("/advisor/work-items/{taskId}/assign")
    public ApiResponse<Void> assignWorkItem(@PathVariable Long taskId,
                                            @RequestBody AssignWorkItemRequest req) {
        workItemService.assign(taskId, req.getEmpId());
        return ApiResponse.success(null);
    }

    @PutMapping("/advisor/work-items/assign")
    public ApiResponse<Void> assignWorkItems(@RequestBody AssignWorkItemBatchRequest req) {
        workItemService.assignBatch(req);
        return ApiResponse.success(null);
    }

    @GetMapping("/advisor/technicians")
    public ApiResponse<List<AdvisorTechnicianResponse>> getTechnicians() {
        List<AdvisorTechnicianResponse> technicians = staffMapper.selectList(null).stream()
                .filter(s -> "technician".equalsIgnoreCase(s.getRole()))
                .filter(s -> Boolean.TRUE.equals(s.getIsActive()))
                .map(s -> AdvisorTechnicianResponse.builder()
                        .id(s.getId())
                        .name(s.getName())
                        .empId(s.getEmpId())
                        .build())
                .collect(Collectors.toList());
        return ApiResponse.success(technicians);
    }
}
