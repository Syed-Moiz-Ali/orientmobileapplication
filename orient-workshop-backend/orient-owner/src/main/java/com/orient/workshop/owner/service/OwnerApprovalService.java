package com.orient.workshop.owner.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.orient.workshop.advisor.model.entity.Approval;
import com.orient.workshop.advisor.repository.ApprovalMapper;
import com.orient.workshop.owner.model.dto.ApprovalCategoryResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class OwnerApprovalService {

    private final ApprovalMapper approvalMapper;

    public List<ApprovalCategoryResponse> getApprovalCategories() {
        long pending = countByAction("pending");
        long approved = countByAction("approved");
        long rejected = countByAction("rejected");
        long total = approvalMapper.selectCount(null);

        return List.of(
            cat("Pending", pending + " awaiting review", (int) pending),
            cat("Approved", (int) approved + " approved", (int) approved),
            cat("Rejected", (int) rejected + " rejected", (int) rejected),
            cat("Total Approvals", (int) total + " all time", (int) total)
        );
    }

    private long countByAction(String action) {
        return approvalMapper.selectCount(new QueryWrapper<Approval>().eq("action", action));
    }

    private ApprovalCategoryResponse cat(String title, String subtitle, int count) {
        return ApprovalCategoryResponse.builder().title(title).subtitle(subtitle).count(count).build();
    }
}
