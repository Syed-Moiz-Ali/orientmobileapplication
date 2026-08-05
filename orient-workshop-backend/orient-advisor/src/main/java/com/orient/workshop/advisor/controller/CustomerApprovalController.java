package com.orient.workshop.advisor.controller;

import com.orient.workshop.advisor.model.dto.CustomerApprovalActionRequest;
import com.orient.workshop.advisor.model.dto.CustomerApprovalDetailResponse;
import com.orient.workshop.advisor.model.dto.CustomerApprovalSummaryResponse;
import com.orient.workshop.advisor.service.CustomerApprovalService;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Customer-facing estimate approval (path /customers/** so the CUSTOMER role
 * passes the security matrix). Endpoint ownership enforced by customer id.
 */
@Tag(name = "Customer Approvals")
@RestController
@RequestMapping("/customers/approvals")
@RequiredArgsConstructor
public class CustomerApprovalController {

    private final CustomerApprovalService approvalService;

    @GetMapping("/pending")
    public ApiResponse<List<CustomerApprovalSummaryResponse>> getPendingApprovals(
            @AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(approvalService.getPendingApprovals(principal));
    }

    @GetMapping("/{estimateId}")
    public ApiResponse<CustomerApprovalDetailResponse> getApprovalDetail(
            @AuthenticationPrincipal JwtUserPrincipal principal, @PathVariable String estimateId) {
        return ApiResponse.success(approvalService.getApprovalDetail(principal, estimateId));
    }

    @PutMapping("/{estimateId}")
    public ApiResponse<Void> processApproval(
            @AuthenticationPrincipal JwtUserPrincipal principal,
            @PathVariable String estimateId,
            @RequestBody CustomerApprovalActionRequest req) {
        approvalService.processApproval(principal, estimateId, req);
        return ApiResponse.success(null);
    }
}
