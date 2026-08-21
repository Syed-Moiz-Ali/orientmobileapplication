package com.orient.workshop.supervisor.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
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

    public List<KpiResponse> getKpis(JwtUserPrincipal principal) {
        Long branchId = branchId(principal);
        long pending = branchId != null ? jobCardMapper.countOpenByBranch(branchId) : jobCardMapper.countOpen();
        long completedToday = branchId != null
                ? jobCardMapper.countCompletedTodayByBranch(branchId)
                : jobCardMapper.countCompletedToday();
        long advisors = staffMapper.selectCount(
                staffQuery("advisor", branchId));
        long technicians = staffMapper.selectCount(
                staffQuery("technician", branchId));
        long activeAssignments = branchId != null
                ? statsMapper.countActiveAssignmentsByBranch(branchId)
                : statsMapper.countActiveAssignments();
        long idleTechnicians = Math.max(technicians - activeAssignments, 0);

        return List.of(
            kpi(String.valueOf(pending), "Total Job Cards Pending", "Open job cards"),
            kpi(String.valueOf(completedToday), "Today Delivery Job Cards", "Completed today"),
            kpi(String.valueOf(advisors), "Total Advisors Present", "Active advisors"),
            kpi(String.valueOf(idleTechnicians), "Total Idle Technicians", "No open assignment")
        );
    }

    public List<AdvisorJobCountResponse> getAdvisorJobs(JwtUserPrincipal principal) {
        Long branchId = branchId(principal);
        return jobCardMapper.selectList(jobCardQuery(branchId)).stream()
                .filter(c -> c.getTechnician() != null && !c.getTechnician().isBlank())
                .collect(Collectors.groupingBy(JobCard::getTechnician, Collectors.counting()))
                .entrySet().stream()
                .sorted(Map.Entry.<String, Long>comparingByValue().reversed())
                .map(e -> advisorJob(e.getKey(), e.getValue().intValue()))
                .collect(Collectors.toList());
    }

    public List<JobTypeResponse> getJobTypes(JwtUserPrincipal principal) {
        Long branchId = branchId(principal);
        return jobCardMapper.selectList(jobCardQuery(branchId)).stream()
                .filter(c -> c.getTag() != null && !c.getTag().isBlank())
                .collect(Collectors.groupingBy(JobCard::getTag, Collectors.counting()))
                .entrySet().stream()
                .sorted(Map.Entry.<String, Long>comparingByValue().reversed())
                .map(e -> jobType(e.getKey(), e.getValue().intValue()))
                .collect(Collectors.toList());
    }

    public List<RevenueMetricResponse> getRevenueMetrics(JwtUserPrincipal principal) {
        Long branchId = branchId(principal);
        BigDecimal total = branchId != null ? statsMapper.sumRepairGrandByBranch(branchId) : statsMapper.sumRepairGrand();
        BigDecimal service = branchId != null ? statsMapper.sumRepairServicesByBranch(branchId) : statsMapper.sumRepairServices();
        BigDecimal parts = branchId != null ? statsMapper.sumRepairPartsByBranch(branchId) : statsMapper.sumRepairParts();
        // FIX (audit P0): removed the two fabricated "$0" revenue cards
        // ("Labour Revenue" / "Other Revenue") — no separate data source exists.
        return List.of(
            revenue(formatCurrency(total), "Total Revenue", ""),
            revenue(formatCurrency(service), "Service Revenue", ""),
            revenue(formatCurrency(parts), "Parts Revenue", "")
        );
    }

    public List<PendingStatusResponse> getPendingStatuses(JwtUserPrincipal principal) {
        Long branchId = branchId(principal);
        long waitingParts = jobCardMapper.selectCount(
                jobCardQuery(branchId).eq("status", "waitingParts"));
        long completed = jobCardMapper.selectCount(
                jobCardQuery(branchId).eq("status", "completed"));
        long invoiced = (branchId != null
                ? statsMapper.invoicedJobCardIdsByBranch(branchId)
                : statsMapper.invoicedJobCardIds()).stream().distinct().count();
        long completedNotInvoiced = Math.max(completed - invoiced, 0);
        return List.of(
            pending(String.valueOf(waitingParts), "Waiting for Parts"),
            pending(String.valueOf(completedNotInvoiced), "Job Completed Not Invoiced"),
            pending(String.valueOf(branchId != null
                    ? statsMapper.countDraftInspectionsByBranch(branchId)
                    : statsMapper.countDraftInspections()), "Waiting for Inspection"),
            pending(String.valueOf(branchId != null
                    ? statsMapper.countPendingApprovalsByBranch(branchId)
                    : statsMapper.countPendingApprovals()), "Waiting for Approval")
        );
    }

    private QueryWrapper<Staff> staffQuery(String role, Long branchId) {
        QueryWrapper<Staff> query = new QueryWrapper<Staff>()
                .eq("role", role)
                .eq("is_active", true);
        if (branchId != null) query.eq("branch_id", branchId);
        return query;
    }

    private QueryWrapper<JobCard> jobCardQuery(Long branchId) {
        QueryWrapper<JobCard> query = new QueryWrapper<>();
        if (branchId != null) query.eq("branch_id", branchId);
        return query;
    }

    private Long branchId(JwtUserPrincipal principal) {
        return principal != null ? principal.getBranchId() : null;
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
