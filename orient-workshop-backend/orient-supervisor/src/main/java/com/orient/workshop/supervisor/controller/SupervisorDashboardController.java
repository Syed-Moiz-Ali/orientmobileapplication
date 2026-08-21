package com.orient.workshop.supervisor.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.supervisor.model.dto.*;
import com.orient.workshop.supervisor.service.SupervisorKpiService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Supervisor")
@RestController
@RequestMapping("/supervisor")
@RequiredArgsConstructor
public class SupervisorDashboardController {

    private final SupervisorKpiService kpiService;

    @GetMapping("/kpis")
    public ApiResponse<List<KpiResponse>> getKpis(@AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(kpiService.getKpis(principal));
    }

    @GetMapping("/advisor-jobs")
    public ApiResponse<List<AdvisorJobCountResponse>> getAdvisorJobs(@AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(kpiService.getAdvisorJobs(principal));
    }

    @GetMapping("/job-types")
    public ApiResponse<List<JobTypeResponse>> getJobTypes(@AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(kpiService.getJobTypes(principal));
    }

    @GetMapping("/revenue-metrics")
    public ApiResponse<List<RevenueMetricResponse>> getRevenueMetrics(@AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(kpiService.getRevenueMetrics(principal));
    }

    @GetMapping("/pending-statuses")
    public ApiResponse<List<PendingStatusResponse>> getPendingStatuses(@AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(kpiService.getPendingStatuses(principal));
    }
}

