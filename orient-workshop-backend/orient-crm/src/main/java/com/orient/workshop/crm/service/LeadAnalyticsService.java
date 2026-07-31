package com.orient.workshop.crm.service;

import com.orient.workshop.crm.model.dto.*;
import com.orient.workshop.crm.model.entity.Lead;
import com.orient.workshop.crm.model.entity.LeadActivity;
import com.orient.workshop.crm.repository.LeadActivityMapper;
import com.orient.workshop.crm.repository.LeadMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class LeadAnalyticsService {

    private final LeadMapper leadMapper;
    private final LeadActivityMapper activityMapper;

    public LeadStatsResponse getLeadStats() {
        long total = leadMapper.countAll();
        long active = leadMapper.countByStatus("ACTIVE");
        long won = leadMapper.countByStatus("WON");
        long lost = leadMapper.countByStatus("LOST");
        long unanswered = leadMapper.countByStatus("UNANSWERED");
        BigDecimal totalValue = leadMapper.sumTotalValue();
        BigDecimal wonValue = leadMapper.sumWonValue();
        double conversionRate = total > 0 ? Math.round(won * 1000.0 / total) / 10.0 : 0.0;

        List<LeadStatsResponse.PipelineStage> pipeline = leadMapper.groupByStatusWithValue().stream()
                .map(r -> LeadStatsResponse.PipelineStage.builder()
                        .status(str(r.get("status")))
                        .count(num(r.get("cnt")))
                        .value(r.get("total_value") instanceof Number n ? new BigDecimal(n.toString()) : BigDecimal.ZERO)
                        .build())
                .collect(Collectors.toList());

        return LeadStatsResponse.builder()
                .total(total).active(active).won(won).lost(lost).unanswered(unanswered)
                .totalValue(totalValue).wonValue(wonValue).conversionRate(conversionRate)
                .pipeline(pipeline)
                .build();
    }

    public List<FollowUpResponse> getFollowUps() {
        return leadMapper.findFollowUps().stream()
                .map(this::toFollowUp)
                .collect(Collectors.toList());
    }

    public List<FollowUpResponse> getFollowUpsDue() {
        String today = java.time.LocalDate.now().toString();
        return leadMapper.findFollowUpsDue(today).stream()
                .map(this::toFollowUp)
                .collect(Collectors.toList());
    }

    public List<ActivityFeedItem> getActivityFeed() {
        List<LeadActivity> activities = activityMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<LeadActivity>()
                        .orderByDesc("id").last("LIMIT 20"));
        Map<Long, Lead> leadMap = new HashMap<>();
        for (LeadActivity a : activities) {
            if (a.getLeadId() != null && !leadMap.containsKey(a.getLeadId())) {
                Lead l = leadMapper.selectById(a.getLeadId());
                if (l != null) leadMap.put(a.getLeadId(), l);
            }
        }
        return activities.stream()
                .map(a -> {
                    Lead l = leadMap.get(a.getLeadId());
                    return ActivityFeedItem.builder()
                            .id(String.valueOf(a.getId()))
                            .leadId(a.getLeadId() != null ? String.valueOf(a.getLeadId()) : "")
                            .customerName(l != null ? l.getCustomerName() : "Unknown")
                            .action(a.getAction())
                            .detail(a.getDetail())
                            .createdAt(a.getCreatedAt() != null ? a.getCreatedAt().toString() : "")
                            .build();
                })
                .collect(Collectors.toList());
    }

    private FollowUpResponse toFollowUp(Lead l) {
        return FollowUpResponse.builder()
                .leadId(String.valueOf(l.getId()))
                .leadNumber(l.getLeadNumber())
                .customerName(l.getCustomerName())
                .phone(l.getPhone())
                .source(l.getSource())
                .assignedTo(l.getAssignedTo())
                .status(l.getStatus())
                .followUpDate(l.getFollowUpDate())
                .leadValue(l.getLeadValue() != null ? l.getLeadValue().toPlainString() : "0")
                .build();
    }

    private String str(Object o) { return o != null ? o.toString() : ""; }
    private long num(Object o) { return o instanceof Number n ? n.longValue() : 0L; }
}
