package com.orient.workshop.advisor.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.advisor.model.dto.ApprovalActionRequest;
import com.orient.workshop.advisor.model.dto.PendingApprovalResponse;
import com.orient.workshop.advisor.service.ApprovalService;
import com.orient.workshop.common.response.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Advisor")
@RestController
@RequestMapping("/advisor/approvals")
@RequiredArgsConstructor
public class ApprovalController {

    private final ApprovalService approvalService;

    @GetMapping("/pending")
    public ApiResponse<List<PendingApprovalResponse>> getPending() {
        return ApiResponse.success(approvalService.getPendingApprovals());
    }

    @PostMapping("/{estimateId}")
    public ApiResponse<Void> processApproval(@PathVariable String estimateId,
                                              @Valid @RequestBody ApprovalActionRequest req) {
        approvalService.processApproval(estimateId, req);
        return ApiResponse.success(null);
    }
}

