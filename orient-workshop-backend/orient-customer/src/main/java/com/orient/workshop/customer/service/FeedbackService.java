package com.orient.workshop.customer.service;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.exception.ForbiddenException;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.model.entity.Feedback;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.core.repository.FeedbackMapper;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.customer.model.dto.FeedbackRequest;
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
    private final CustomerMapper customerMapper;
    private final JobCardMapper jobCardMapper;
    private final CustomerService customerService;

    @Transactional
    public IdResponse submit(JwtUserPrincipal principal, FeedbackRequest req) {
        Customer customer = resolveCustomer(principal);

        // FIX (audit QA BUG-029): the app sends `overall`; the API documented
        // `overallRating`. Normalize both, and let the legacy `rating` fall back
        // to the overall score instead of rejecting modern clients.
        Integer overall = req.getOverallRating() != null ? req.getOverallRating() : req.getOverall();
        Integer rating = req.getRating() != null ? req.getRating() : overall;
        if (rating == null || rating < 1 || rating > 5) {
            throw new BadRequestException("rating must be between 1 and 5");
        }
        // validate every dimension, not just `rating`
        validateDimension("overallRating", overall);
        validateDimension("workQuality", req.getWorkQuality());
        validateDimension("communication", req.getCommunication());
        validateDimension("timeliness", req.getTimeliness());
        validateDimension("valueForMoney", req.getValueForMoney());
        if (req.getJobCardId() != null && jobCardMapper.selectById(req.getJobCardId()) == null) {
            throw new BadRequestException("Job card not found with id: " + req.getJobCardId());
        }

        Feedback fb = Feedback.builder()
                .jobCardId(req.getJobCardId())
                .customerId(customer.getId())
                .branchId(principal.getBranchId())
                .rating(overall != null ? overall : rating)
                .overallRating(overall)
                .workQuality(req.getWorkQuality())
                .communication(req.getCommunication())
                .timeliness(req.getTimeliness())
                .valueForMoney(req.getValueForMoney())
                .wouldRecommend(req.getWouldRecommend())
                .comment(req.getComment())
                // fixed: new feedback is NOT public until moderated
                .isPublic(false)
                .isModerated(false)
                .build();
        feedbackMapper.insert(fb);
        return IdResponse.builder().id(String.valueOf(fb.getId())).build();
    }

    private void validateDimension(String field, Integer value) {
        if (value != null && (value < 1 || value > 5)) {
            throw new BadRequestException(field + " must be between 1 and 5");
        }
    }

    /**
     * Public reads only return moderated + public feedback (fixed: previously
     * served every row regardless of is_public / is_moderated).
     */
    public List<Feedback> getAll(Long branchId, int page, int size) {
        int offset = Math.max(page - 1, 0) * size;
        if (branchId != null) {
            return feedbackMapper.findPublicByBranchPaged(branchId, size, offset);
        }
        return feedbackMapper.findPublicPaged(size, offset);
    }

    public Map<String, Object> getStats(Long branchId) {
        List<Feedback> all = branchId != null
                ? feedbackMapper.findPublicByBranchPaged(branchId, Integer.MAX_VALUE, 0)
                : feedbackMapper.findPublicPaged(Integer.MAX_VALUE, 0);
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

    /**
     * Moderation: staff may approve/reject public visibility.
     */
    @Transactional
    public void moderate(Long feedbackId, boolean isPublic) {
        Feedback fb = feedbackMapper.selectById(feedbackId);
        if (fb == null) {
            throw new NotFoundException("Feedback not found with id: " + feedbackId);
        }
        fb.setIsPublic(isPublic);
        fb.setIsModerated(true);
        feedbackMapper.updateById(fb);
    }

    /**
     * P2 (audit): moderation inbox — pending (unmoderated) feedback for staff.
     */
    public List<Feedback> getPendingModeration(int page, int size) {
        int limit = Math.min(Math.max(size, 1), 100);
        int offset = Math.max(page - 1, 0) * limit;
        return feedbackMapper.findUnmoderatedPaged(limit, offset);
    }

    private Customer resolveCustomer(JwtUserPrincipal principal) {
        if (principal == null || principal.getUserId() == null) {
            throw new ForbiddenException("Authenticated user not found");
        }
        return customerMapper.findByUserId(principal.getUserId())
                .or(() -> {
                    if (principal.getPhone() == null || principal.getPhone().isBlank()) {
                        return java.util.Optional.empty();
                    }
                    return customerMapper.findByPhone(principal.getPhone());
                })
                .orElseGet(() -> customerService.findOrCreateCustomer(
                        principal.getUserId(), principal.getBranchId()));
    }
}
