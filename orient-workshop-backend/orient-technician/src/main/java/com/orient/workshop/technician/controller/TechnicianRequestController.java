package com.orient.workshop.technician.controller;

import io.swagger.v3.oas.annotations.tags.Tag;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.core.model.entity.Staff;
import com.orient.workshop.core.repository.StaffMapper;
import com.orient.workshop.core.service.NotificationService;
import com.orient.workshop.technician.model.dto.EscalationRequestDto;
import com.orient.workshop.technician.model.dto.PartsRequestDto;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Technician")
@RestController
@RequestMapping("/technician")
@RequiredArgsConstructor
public class TechnicianRequestController {

    private final NotificationService notificationService;
    private final StaffMapper staffMapper;

    @PostMapping("/parts-requests")
    public ApiResponse<Void> requestParts(@RequestBody PartsRequestDto req, @AuthenticationPrincipal JwtUserPrincipal principal) {
        String body = String.format("Part: %s, Number: %s, Qty: %d, Urgency: %s, Notes: %s",
                req.getPartName(), req.getPartNumber(), req.getQuantity(), req.getUrgency(), req.getNotes());
        // Fix: notify supervisors (and owners) — previously the notification was
        // emitted to the REQUESTER, so parts requests never reached anyone.
        notifySupervisors(principal, "PARTS_REQUEST", "Parts Request for " + req.getJobCardRef(), body);
        return ApiResponse.success(null);
    }

    @PostMapping("/escalations")
    public ApiResponse<Void> escalateIssue(@RequestBody EscalationRequestDto req, @AuthenticationPrincipal JwtUserPrincipal principal) {
        String body = String.format("Type: %s, Description: %s", req.getIssueType(), req.getDescription());
        notifySupervisors(principal, "ESCALATION", "Escalation for " + req.getJobCardRef(), body);
        return ApiResponse.success(null);
    }

    private void notifySupervisors(JwtUserPrincipal principal, String type, String title, String body) {
        Long branchId = principal != null ? principal.getBranchId() : null;
        List<Staff> supervisors = branchId != null
                ? staffMapper.findByRoleAndBranch("supervisor", branchId)
                : staffMapper.findByRole("supervisor");
        // Fall back to all supervisors when the branch has none provisioned.
        if (supervisors.isEmpty()) {
            supervisors = staffMapper.findByRole("supervisor");
        }
        for (Staff s : supervisors) {
            if (s.getUserId() != null) {
                notificationService.emit(s.getUserId(), branchId, type, title, body);
            }
        }
    }
}
