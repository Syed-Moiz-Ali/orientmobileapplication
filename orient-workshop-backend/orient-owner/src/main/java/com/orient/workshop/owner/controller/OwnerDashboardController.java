package com.orient.workshop.owner.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.exception.ForbiddenException;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.owner.model.dto.*;
import com.orient.workshop.owner.service.*;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Tag(name = "Owner Dashboard")
@RestController
@RequestMapping("/owner")
@RequiredArgsConstructor
public class OwnerDashboardController {

    private final OwnerDashboardService dashboardService;
    private final OwnerJobCardService jobCardService;
    private final OwnerDocumentService documentService;
    private final OwnerApprovalService approvalService;
    private final InvoiceService invoiceService;
    private final ArService arService;
    private final MessageService messageService;
    private final ActivityService activityService;

    @GetMapping("/dashboard/kpis")
    public ApiResponse<List<KpiCardResponse>> getKpis(@AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(dashboardService.getKpis(resolveBranchId(principal)));
    }

    @GetMapping("/dashboard/sales-trend")
    public ApiResponse<List<TrendPointResponse>> getSalesTrend(@AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(dashboardService.getSalesTrend(resolveBranchId(principal)));
    }

    @GetMapping("/dashboard/profit-trend")
    public ApiResponse<List<TrendPointResponse>> getProfitTrend(@AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(dashboardService.getProfitTrend(resolveBranchId(principal)));
    }

    @GetMapping("/dashboard/expenses-trend")
    public ApiResponse<List<TrendPointResponse>> getExpensesTrend() {
        return ApiResponse.success(dashboardService.getExpensesTrend());
    }

    @GetMapping("/dashboard/forecast")
    public ApiResponse<Map<String, Object>> getForecast(@AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(dashboardService.getForecast(resolveBranchId(principal)));
    }

    @GetMapping("/dashboard/job-card-register")
    public ApiResponse<List<JobCardRegisterResponse>> getJobCardRegister(@AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(dashboardService.getJobCardRegister(resolveBranchId(principal)));
    }

    @GetMapping("/dashboard/top-sales")
    public ApiResponse<List<TopSalesCategoryResponse>> getTopSales(@AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(dashboardService.getTopSales(resolveBranchId(principal)));
    }

    @GetMapping("/job-cards")
    public ApiResponse<List<OwnerJobCardResponse>> getJobCards() {
        return ApiResponse.success(jobCardService.getJobCards());
    }

    @GetMapping("/job-cards/export")
    public ApiResponse<String> exportJobCards() {
        return ApiResponse.success(jobCardService.exportCsv());
    }

    /**
     * P1 (audit): real status update — the owner app previously faked
     * "Mark as Complete" locally because no backend endpoint existed.
     */
    @PutMapping("/job-cards/{id}/status")
    public ApiResponse<Void> updateJobCardStatus(
            @PathVariable String id,
            @RequestParam(required = false) String status) {
        jobCardService.updateStatus(id, status != null ? status : "completed");
        return ApiResponse.success(null);
    }

    @GetMapping("/documents/expiry")
    public ApiResponse<List<DocumentExpiryResponse>> getDocumentExpiry() {
        return ApiResponse.success(documentService.getExpiringDocuments());
    }

    @GetMapping("/jobs/status")
    public ApiResponse<List<JobStatusResponse>> getJobsByStatus(
            @RequestParam(required = false) String stage,
            @RequestParam(required = false) String search) {
        return ApiResponse.success(jobCardService.getJobsByStage(stage, search));
    }

    @GetMapping("/approvals/categories")
    public ApiResponse<List<ApprovalCategoryResponse>> getApprovalCategories() {
        return ApiResponse.success(approvalService.getApprovalCategories());
    }

    @GetMapping("/jobs/pending")
    public ApiResponse<List<PendingJobResponse>> getPendingJobs() {
        return ApiResponse.success(jobCardService.getPendingJobs());
    }

    @GetMapping("/jobs/active")
    public ApiResponse<List<OwnerJobCardResponse>> getActiveJobs() {
        return ApiResponse.success(jobCardService.getActiveJobs());
    }

    @GetMapping("/invoices")
    public ApiResponse<List<InvoiceResponse>> getInvoices(@AuthenticationPrincipal JwtUserPrincipal principal,
                                                          @RequestParam(required = false) String status) {
        return ApiResponse.success(invoiceService.getInvoices(resolveBranchId(principal), status));
    }

    @GetMapping("/accounts-receivable/summary")
    public ApiResponse<ArSummaryResponse> getArSummary() {
        return ApiResponse.success(arService.getSummary());
    }

    @GetMapping("/accounts-receivable/records")
    public ApiResponse<List<ArRecordResponse>> getArRecords() {
        return ApiResponse.success(arService.getRecords());
    }

    @GetMapping("/messages")
    public ApiResponse<List<MessageResponse>> getMessages(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(messageService.getMessages(page, size));
    }

    @PostMapping("/messages")
    public ApiResponse<MessageResponse> sendMessage(@Valid @RequestBody MessageRequest req) {
        return ApiResponse.success(messageService.sendMessage(req));
    }

    @GetMapping("/activity/export")
    public ApiResponse<String> exportActivity() {
        return ApiResponse.success(activityService.exportCsv());
    }

    @GetMapping("/activity")
    public ApiResponse<List<ActivityResponse>> getActivity(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int limit) {
        return ApiResponse.success(activityService.getActivity(page, limit));
    }

    /**
     * Resolves the branch scope for the current request. Owners/admins with no single
     * branch claim get a null (= global) view; all other roles are restricted to their
     * own branch so cross-branch data leaks are impossible at the API boundary.
     */
    private Long resolveBranchId(JwtUserPrincipal principal) {
        if (principal == null) {
            throw new ForbiddenException("Authentication required");
        }
        String role = principal.getRole() != null ? principal.getRole().toLowerCase() : "";
        if ("owner".equals(role) || "admin".equals(role) || "crmdashboard".equals(role)) {
            return null;
        }
        return principal.getBranchId();
    }
}

