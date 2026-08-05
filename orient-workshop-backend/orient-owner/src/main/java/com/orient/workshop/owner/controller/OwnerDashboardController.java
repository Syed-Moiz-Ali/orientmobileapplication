package com.orient.workshop.owner.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.owner.model.dto.*;
import com.orient.workshop.owner.service.*;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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
    public ApiResponse<List<KpiCardResponse>> getKpis() {
        return ApiResponse.success(dashboardService.getKpis());
    }

    @GetMapping("/dashboard/sales-trend")
    public ApiResponse<List<TrendPointResponse>> getSalesTrend() {
        return ApiResponse.success(dashboardService.getSalesTrend());
    }

    @GetMapping("/dashboard/profit-trend")
    public ApiResponse<List<TrendPointResponse>> getProfitTrend() {
        return ApiResponse.success(dashboardService.getProfitTrend());
    }

    @GetMapping("/dashboard/expenses-trend")
    public ApiResponse<List<TrendPointResponse>> getExpensesTrend() {
        return ApiResponse.success(dashboardService.getExpensesTrend());
    }

    @GetMapping("/dashboard/job-card-register")
    public ApiResponse<List<JobCardRegisterResponse>> getJobCardRegister() {
        return ApiResponse.success(dashboardService.getJobCardRegister());
    }

    @GetMapping("/dashboard/top-sales")
    public ApiResponse<List<TopSalesCategoryResponse>> getTopSales() {
        return ApiResponse.success(dashboardService.getTopSales());
    }

    @GetMapping("/job-cards")
    public ApiResponse<List<OwnerJobCardResponse>> getJobCards() {
        return ApiResponse.success(jobCardService.getJobCards());
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
    public ApiResponse<List<InvoiceResponse>> getInvoices(@RequestParam(required = false) String status) {
        return ApiResponse.success(invoiceService.getInvoices(status));
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

    @GetMapping("/activity")
    public ApiResponse<List<ActivityResponse>> getActivity(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int limit) {
        return ApiResponse.success(activityService.getActivity(page, limit));
    }
}

