package com.orient.workshop.advisor.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.orient.workshop.advisor.model.dto.AdvisorStatsResponse;
import com.orient.workshop.advisor.model.entity.Inspection;
import com.orient.workshop.advisor.repository.ApprovalMapper;
import com.orient.workshop.advisor.repository.InspectionMapper;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.repository.JobCardMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AdvisorStatsService {

    private final JobCardMapper jobCardMapper;
    private final ApprovalMapper approvalMapper;
    private final InspectionMapper inspectionMapper;

    public AdvisorStatsResponse getStats() {
        long inspectionsToday = inspectionMapper.selectCount(
                new QueryWrapper<Inspection>().apply("DATE(created_at) = CURDATE()"));
        long vehiclesWaiting = jobCardMapper.selectCount(
                new QueryWrapper<JobCard>().eq("status", "pending"));
        long readyForDelivery = jobCardMapper.selectCount(
                new QueryWrapper<JobCard>().eq("status", "completed"));
        return AdvisorStatsResponse.builder()
                .newJobCardsToday(jobCardMapper.countToday())
                .inspectionsToday((int) inspectionsToday)
                .pendingApprovals((int) approvalMapper.findPending().size())
                .vehiclesWaiting((int) vehiclesWaiting)
                .readyForDelivery((int) readyForDelivery)
                .totalOpenJobCards(jobCardMapper.countOpen())
                .build();
    }
}
