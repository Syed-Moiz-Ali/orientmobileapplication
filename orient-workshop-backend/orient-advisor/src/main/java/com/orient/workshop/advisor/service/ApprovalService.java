package com.orient.workshop.advisor.service;

import com.orient.workshop.advisor.model.dto.ApprovalActionRequest;
import com.orient.workshop.advisor.model.dto.PendingApprovalResponse;
import com.orient.workshop.advisor.model.entity.Approval;
import com.orient.workshop.advisor.repository.ApprovalMapper;
import com.orient.workshop.common.exception.NotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ApprovalService {

    private final ApprovalMapper approvalMapper;

    public List<PendingApprovalResponse> getPendingApprovals() {
        List<Approval> approvals = approvalMapper.findPending();
        return approvals.stream().map(a -> PendingApprovalResponse.builder()
                .estimateId(a.getEstimateId())
                .customerName(a.getCustomerName())
                .vehicleId(a.getVehicleId())
                .amount(a.getAmount() != null ? a.getAmount() : 0)
                .timeAgo(timeAgo(a.getCreatedAt()))
                .build()).collect(Collectors.toList());
    }

    @Transactional
    public void processApproval(String estimateId, ApprovalActionRequest req) {
        Approval approval = approvalMapper.selectOne(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Approval>()
                        .eq(Approval::getEstimateId, estimateId));
        if (approval == null) throw new NotFoundException("Approval not found");
        approval.setAction(req.getAction());
        approval.setCustomerName(req.getCustomerName());
        approval.setAmount(req.getAmount());
        approvalMapper.updateById(approval);
    }

    private String timeAgo(LocalDateTime dateTime) {
        if (dateTime == null) return "";
        Duration d = Duration.between(dateTime, LocalDateTime.now());
        if (d.toMinutes() < 1) return "Just now";
        if (d.toMinutes() < 60) return d.toMinutes() + " mins ago";
        if (d.toHours() < 24) return d.toHours() + " hours ago";
        return d.toDays() + " days ago";
    }
}
