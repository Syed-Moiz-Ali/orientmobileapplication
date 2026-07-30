package com.orient.workshop.customer.service;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.core.model.entity.Feedback;
import com.orient.workshop.core.repository.FeedbackMapper;
import com.orient.workshop.customer.model.dto.IdResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class FeedbackService {

    private final FeedbackMapper feedbackMapper;

    @Transactional
    public IdResponse submit(JwtUserPrincipal principal, Long jobCardId, int rating, String comment) {
        Feedback fb = Feedback.builder()
                .jobCardId(jobCardId)
                .customerId(principal.getUserId())
                .branchId(principal.getBranchId())
                .rating(rating)
                .comment(comment)
                .isPublic(true)
                .build();
        feedbackMapper.insert(fb);
        return IdResponse.builder().id(String.valueOf(fb.getId())).build();
    }

    public List<Feedback> getAll(Long branchId) {
        if (branchId != null) {
            return feedbackMapper.selectList(
                    new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Feedback>()
                            .eq(Feedback::getBranchId, branchId));
        }
        return feedbackMapper.selectList(null);
    }

    public Map<String, Object> getStats(Long branchId) {
        List<Feedback> all = getAll(branchId);
        double avg = all.stream().mapToInt(Feedback::getRating).average().orElse(0);
        long total = all.size();
        Map<String, Object> stats = new HashMap<>();
        stats.put("averageRating", Math.round(avg * 10) / 10.0);
        stats.put("totalReviews", total);
        stats.put("distribution", Map.of(
            "5", all.stream().filter(f -> f.getRating() == 5).count(),
            "4", all.stream().filter(f -> f.getRating() == 4).count(),
            "3", all.stream().filter(f -> f.getRating() == 3).count(),
            "2", all.stream().filter(f -> f.getRating() == 2).count(),
            "1", all.stream().filter(f -> f.getRating() == 1).count()
        ));
        return stats;
    }
}
