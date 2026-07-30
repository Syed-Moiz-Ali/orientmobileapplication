package com.orient.workshop.supervisor.service;

import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.supervisor.model.dto.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SupervisorKpiService {

    private final JobCardMapper jobCardMapper;

    public List<KpiResponse> getKpis() {
        int pending = (int) jobCardMapper.countAll() - jobCardMapper.countCompletedToday() - jobCardMapper.countCancelled();
        return List.of(
            kpi(String.valueOf(pending), "Total Job Cards Pending", "+4 from yesterday"),
            kpi("8", "Today Delivery Job Cards", "On schedule"),
            kpi("18", "Total Advisors Present", "2 out of 20"),
            kpi("3", "Total Idle Technicians", "Assign them now"),
            kpi("12", "Waiting to Assign Stock", "Requires attention")
        );
    }

    public List<AdvisorJobCountResponse> getAdvisorJobs() {
        return List.of(
            advisorJob("John Smith", 20),
            advisorJob("Sarah Lee", 13),
            advisorJob("Mike Anwar", 18),
            advisorJob("Emma Wilson", 10)
        );
    }

    public List<JobTypeResponse> getJobTypes() {
        return List.of(
            jobType("Regular Service", 38),
            jobType("Insurance", 28),
            jobType("Contract", 15)
        );
    }

    public List<RevenueMetricResponse> getRevenueMetrics() {
        return List.of(
            revenue("$45,280", "Total Revenue", "+12.4%"),
            revenue("$18,920", "Service Revenue", "+8.2%"),
            revenue("$8,450", "Parts Revenue", "+3.1%"),
            revenue("$12,680", "Labour Revenue", "+24.3%"),
            revenue("$5,230", "Other Revenue", "+18.7%")
        );
    }

    public List<PendingStatusResponse> getPendingStatuses() {
        return List.of(
            pending("10", "Waiting for Parts"),
            pending("2", "Job Completed Not Invoiced"),
            pending("4", "Waiting for Inspection"),
            pending("6", "Waiting for Approval")
        );
    }

    private KpiResponse kpi(String value, String label, String sub) {
        return KpiResponse.builder().value(value).label(label).sub(sub).build();
    }
    private AdvisorJobCountResponse advisorJob(String name, int count) {
        return AdvisorJobCountResponse.builder().name(name).count(count).build();
    }
    private JobTypeResponse jobType(String label, int count) {
        return JobTypeResponse.builder().label(label).count(count).build();
    }
    private RevenueMetricResponse revenue(String amount, String label, String change) {
        return RevenueMetricResponse.builder().amount(amount).label(label).change(change).build();
    }
    private PendingStatusResponse pending(String count, String label) {
        return PendingStatusResponse.builder().count(count).label(label).build();
    }
}
