package com.orient.workshop.supervisor.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.supervisor.model.dto.*;
import com.orient.workshop.supervisor.service.SupervisorKpiService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Supervisor")
@RestController
@RequestMapping("/supervisor")
@RequiredArgsConstructor
public class SupervisorDashboardController {

    private final SupervisorKpiService kpiService;

    @GetMapping("/kpis")
    public ApiResponse<List<KpiResponse>> getKpis() {
        return ApiResponse.success(kpiService.getKpis());
    }

    @GetMapping("/advisor-jobs")
    public ApiResponse<List<AdvisorJobCountResponse>> getAdvisorJobs() {
        return ApiResponse.success(kpiService.getAdvisorJobs());
    }

    @GetMapping("/job-types")
    public ApiResponse<List<JobTypeResponse>> getJobTypes() {
        return ApiResponse.success(kpiService.getJobTypes());
    }

    @GetMapping("/revenue-metrics")
    public ApiResponse<List<RevenueMetricResponse>> getRevenueMetrics() {
        return ApiResponse.success(kpiService.getRevenueMetrics());
    }

    @GetMapping("/pending-statuses")
    public ApiResponse<List<PendingStatusResponse>> getPendingStatuses() {
        return ApiResponse.success(kpiService.getPendingStatuses());
    }
}

