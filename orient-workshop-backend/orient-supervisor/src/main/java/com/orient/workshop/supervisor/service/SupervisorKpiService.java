package com.orient.workshop.supervisor.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.model.entity.Staff;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.core.repository.StaffMapper;
import com.orient.workshop.supervisor.model.dto.*;
import com.orient.workshop.supervisor.repository.SupervisorStatsMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.NumberFormat;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SupervisorKpiService {

    private final JobCardMapper jobCardMapper;
    private final StaffMapper staffMapper;
    private final SupervisorStatsMapper statsMapper;

    public List<KpiResponse> getKpis() {
        long pending = jobCardMapper.countOpen();
        long completedToday = jobCardMapper.countCompletedToday();
        long advisors = staffMapper.selectCount(
                new QueryWrapper<Staff>().eq("role", "advisor").eq("is_active", true));
        long technicians = staffMapper.selectCount(
                new QueryWrapper<Staff>().eq("role", "technician").eq("is_active", true));
        long idleTechnicians = Math.max(technicians - statsMapper.countActiveAssignments(), 0);

        return List.of(
            kpi(String.valueOf(pending), "Total Job Cards Pending", "Open job cards"),
            kpi(String.valueOf(completedToday), "Today Delivery Job Cards", "Completed today"),
            kpi(String.valueOf(advisors), "Total Advisors Present", "Active advisors"),
            kpi(String.valueOf(idleTechnicians), "Total Idle Technicians", "No open assignment")
        );
    }

    public List<AdvisorJobCountResponse> getAdvisorJobs() {
        return jobCardMapper.selectList(null).stream()
                .filter(c -> c.getTechnician() != null && !c.getTechnician().isBlank())
                .collect(Collectors.groupingBy(JobCard::getTechnician, Collectors.counting()))
                .entrySet().stream()
                .sorted(Map.Entry.<String, Long>comparingByValue().reversed())
                .map(e -> advisorJob(e.getKey(), e.getValue().intValue()))
                .collect(Collectors.toList());
    }

    public List<JobTypeResponse> getJobTypes() {
        return jobCardMapper.selectList(null).stream()
                .filter(c -> c.getTag() != null && !c.getTag().isBlank())
                .collect(Collectors.groupingBy(JobCard::getTag, Collectors.counting()))
                .entrySet().stream()
                .sorted(Map.Entry.<String, Long>comparingByValue().reversed())
                .map(e -> jobType(e.getKey(), e.getValue().intValue()))
                .collect(Collectors.toList());
    }

    public List<RevenueMetricResponse> getRevenueMetrics() {
        BigDecimal total = statsMapper.sumRepairGrand();
        BigDecimal service = statsMapper.sumRepairServices();
        BigDecimal parts = statsMapper.sumRepairParts();
        // FIX (audit P0): removed the two fabricated "$0" revenue cards
        // ("Labour Revenue" / "Other Revenue") — no separate data source exists.
        return List.of(
            revenue(formatCurrency(total), "Total Revenue", ""),
            revenue(formatCurrency(service), "Service Revenue", ""),
            revenue(formatCurrency(parts), "Parts Revenue", "")
        );
    }

    public List<PendingStatusResponse> getPendingStatuses() {
        long waitingParts = jobCardMapper.selectCount(
                new QueryWrapper<JobCard>().eq("status", "waitingParts"));
        long completed = jobCardMapper.selectCount(
                new QueryWrapper<JobCard>().eq("status", "completed"));
        long invoiced = statsMapper.invoicedJobCardIds().stream().distinct().count();
        long completedNotInvoiced = Math.max(completed - invoiced, 0);
        return List.of(
            pending(String.valueOf(waitingParts), "Waiting for Parts"),
            pending(String.valueOf(completedNotInvoiced), "Job Completed Not Invoiced"),
            pending(String.valueOf(statsMapper.countDraftInspections()), "Waiting for Inspection"),
            pending(String.valueOf(statsMapper.countPendingApprovals()), "Waiting for Approval")
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

    private String formatCurrency(BigDecimal v) {
        BigDecimal value = v != null ? v : BigDecimal.ZERO;
        return "AED " + NumberFormat.getNumberInstance(Locale.US)
                .format(value.setScale(2, RoundingMode.HALF_UP));
    }
}
