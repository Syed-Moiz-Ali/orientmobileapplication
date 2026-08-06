package com.orient.workshop.crm.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.crm.model.dto.*;
import com.orient.workshop.crm.service.*;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

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
    private final MetaLeadFetcher metaLeadFetcher;
    private final TeamService teamService;
    private final LeadAnalyticsService analyticsService;

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
        return ApiResponse.success(leadService.getLeads(status, source, page, size));
    }

    @PostMapping("/leads")
    public ApiResponse<LeadResponse> createLead(@RequestBody LeadResponse req) {
        return ApiResponse.success(leadService.createLead(req));
    }

    @PutMapping("/leads/{id}")
    public ApiResponse<LeadResponse> updateLead(@PathVariable Long id, @RequestBody LeadResponse req) {
        return ApiResponse.success(leadService.updateLead(id, req));
    }

    @DeleteMapping("/leads/{id}")
    public ApiResponse<Void> deleteLead(@PathVariable Long id) {
        leadService.deleteLead(id);
        return ApiResponse.success(null);
    }

    @GetMapping("/leads/{id}/activities")
    public ApiResponse<List<LeadActivityResponse>> getLeadActivities(@PathVariable Long id) {
        return ApiResponse.success(leadService.getActivities(id));
    }

    @GetMapping("/team-members")
    public ApiResponse<List<TeamMemberResponse>> getTeamMembers() {
        return ApiResponse.success(teamService.getTeamMembers());
    }

    @GetMapping("/leads/stats")
    public ApiResponse<LeadStatsResponse> getLeadStats() {
        return ApiResponse.success(analyticsService.getLeadStats());
    }

    @GetMapping("/leads/follow-ups")
    public ApiResponse<List<FollowUpResponse>> getFollowUps(
            @RequestParam(defaultValue = "false") boolean dueOnly) {
        return ApiResponse.success(dueOnly ? analyticsService.getFollowUpsDue() : analyticsService.getFollowUps());
    }

    @GetMapping("/activity-feed")
    public ApiResponse<List<ActivityFeedItem>> getActivityFeed() {
        return ApiResponse.success(analyticsService.getActivityFeed());
    }

    @PutMapping("/integrations/{name}/connect")
    public ApiResponse<IntegrationResponse> connectIntegration(
            @PathVariable String name,
            @RequestBody Map<String, String> credentials) {
        return ApiResponse.success(integrationService.connect(name, credentials));
    }

    @PostMapping("/integrations/{name}/disconnect")
    public ApiResponse<IntegrationResponse> disconnectIntegration(@PathVariable String name) {
        return ApiResponse.success(integrationService.disconnect(name));
    }

    @PostMapping("/integrations/{name}/sync")
    public ApiResponse<IntegrationResponse> syncIntegration(@PathVariable String name) {
        return ApiResponse.success(integrationService.triggerSync(name));
    }

    @GetMapping("/tasks")
    public ApiResponse<List<CrmTaskResponse>> getTasks(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(taskService.getTasks(page, size));
    }

    @PostMapping("/tasks")
    public ApiResponse<CrmTaskResponse> createTask(@RequestBody CrmTaskRequest req) {
        return ApiResponse.success(taskService.createTask(req));
    }

    @PutMapping("/tasks/{id}")
    public ApiResponse<CrmTaskResponse> updateTask(@PathVariable Long id, @RequestBody CrmTaskRequest req) {
        return ApiResponse.success(taskService.updateTask(id, req));
    }

    @DeleteMapping("/tasks/{id}")
    public ApiResponse<Void> deleteTask(@PathVariable Long id) {
        taskService.deleteTask(id);
        return ApiResponse.success(null);
    }
}

