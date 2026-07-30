package com.orient.workshop.crm.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.crm.model.dto.*;
import com.orient.workshop.crm.service.*;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "CRM")
@RestController
@RequestMapping("/crm")
@RequiredArgsConstructor
public class CrmController {

    private final CrmDashboardService dashboardService;
    private final IntegrationService integrationService;
    private final SalesTeamService salesTeamService;
    private final ConversationService conversationService;
    private final LeadService leadService;
    private final CrmTaskService taskService;

    @GetMapping("/dashboard/kpis")
    public ApiResponse<List<CrmKpiResponse>> getKpis() {
        return ApiResponse.success(dashboardService.getKpis());
    }

    @GetMapping("/channels")
    public ApiResponse<List<ChannelResponse>> getChannels() {
        return ApiResponse.success(dashboardService.getChannels());
    }

    @GetMapping("/conversion-trend")
    public ApiResponse<List<ConversionTrendResponse>> getConversionTrend() {
        return ApiResponse.success(dashboardService.getConversionTrend());
    }

    @GetMapping("/salesperson-performance")
    public ApiResponse<List<SalespersonPerfResponse>> getSalespersonPerformance() {
        return ApiResponse.success(dashboardService.getSalespersonPerformance());
    }

    @GetMapping("/response-times")
    public ApiResponse<List<ResponseTimeResponse>> getResponseTimes() {
        return ApiResponse.success(dashboardService.getResponseTimes());
    }

    @GetMapping("/lead-sources")
    public ApiResponse<List<LeadSourceResponse>> getLeadSources() {
        return ApiResponse.success(dashboardService.getLeadSources());
    }

    @GetMapping("/key-metrics")
    public ApiResponse<KeyMetricResponse> getKeyMetrics() {
        return ApiResponse.success(dashboardService.getKeyMetrics());
    }

    @GetMapping("/integrations")
    public ApiResponse<List<IntegrationResponse>> getIntegrations() {
        return ApiResponse.success(integrationService.getIntegrations());
    }

    @GetMapping("/sales-team")
    public ApiResponse<List<SalesTeamResponse>> getSalesTeam() {
        return ApiResponse.success(salesTeamService.getSalesTeam());
    }

    @GetMapping("/conversations")
    public ApiResponse<List<ConversationResponse>> getConversations() {
        return ApiResponse.success(conversationService.getConversations());
    }

    @GetMapping("/leads")
    public ApiResponse<List<LeadResponse>> getLeads(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String source,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(leadService.getLeads(status, source));
    }

    @GetMapping("/tasks")
    public ApiResponse<List<CrmTaskResponse>> getTasks(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(taskService.getTasks());
    }

    @PutMapping("/tasks/{id}")
    public ApiResponse<Void> updateTask(@PathVariable Long id, @RequestBody com.orient.workshop.crm.model.dto.UpdateTaskRequest req) {
        taskService.updateTask(id, req);
        return ApiResponse.success(null);
    }
}

