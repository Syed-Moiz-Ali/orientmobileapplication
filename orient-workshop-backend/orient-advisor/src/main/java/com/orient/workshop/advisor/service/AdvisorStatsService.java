package com.orient.workshop.advisor.service;

import com.orient.workshop.advisor.model.dto.AdvisorStatsResponse;
import com.orient.workshop.advisor.repository.ApprovalMapper;
import com.orient.workshop.core.repository.JobCardMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AdvisorStatsService {

    private final JobCardMapper jobCardMapper;
    private final ApprovalMapper approvalMapper;

    public AdvisorStatsResponse getStats() {
        return AdvisorStatsResponse.builder()
                .newJobCardsToday(jobCardMapper.countToday())
                .inspectionsToday(0)
                .pendingApprovals((int) approvalMapper.findPending().size())
                .vehiclesWaiting(0)
                .readyForDelivery(0)
                .totalOpenJobCards(jobCardMapper.countOpen())
                .build();
    }
}
