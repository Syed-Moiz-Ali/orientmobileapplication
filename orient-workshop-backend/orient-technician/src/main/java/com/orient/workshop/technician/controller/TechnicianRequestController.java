package com.orient.workshop.technician.controller;

import io.swagger.v3.oas.annotations.tags.Tag;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.core.service.NotificationService;
import com.orient.workshop.technician.model.dto.EscalationRequestDto;
import com.orient.workshop.technician.model.dto.PartsRequestDto;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Technician")
@RestController
@RequestMapping("/technician")
@RequiredArgsConstructor
public class TechnicianRequestController {

    private final NotificationService notificationService;

    @PostMapping("/parts-requests")
    public ApiResponse<Void> requestParts(@RequestBody PartsRequestDto req, @AuthenticationPrincipal JwtUserPrincipal principal) {
        String body = String.format("Part: %s, Number: %s, Qty: %d, Urgency: %s, Notes: %s",
                req.getPartName(), req.getPartNumber(), req.getQuantity(), req.getUrgency(), req.getNotes());
        notificationService.emit(principal.getUserId(), principal.getBranchId(), "PARTS_REQUEST",
                "Parts Request for " + req.getJobCardRef(), body);
        return ApiResponse.success(null);
    }

    @PostMapping("/escalations")
    public ApiResponse<Void> escalateIssue(@RequestBody EscalationRequestDto req, @AuthenticationPrincipal JwtUserPrincipal principal) {
        String body = String.format("Type: %s, Description: %s", req.getIssueType(), req.getDescription());
        notificationService.emit(principal.getUserId(), principal.getBranchId(), "ESCALATION",
                "Escalation for " + req.getJobCardRef(), body);
        return ApiResponse.success(null);
    }
}
