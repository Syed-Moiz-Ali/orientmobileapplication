package com.orient.workshop.owner.controller;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.core.model.entity.Subscription;
import com.orient.workshop.core.repository.SubscriptionMapper;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.Set;

/**
 * P3 (audit): SaaS billing MVP — per-branch plan subscription.
 * The SaaS tiering story starts here; billing/Stripe integration is a later
 * module, this records the commercial plan state.
 */
@Tag(name = "Owner")
@RestController
@RequestMapping("/owner/subscription")
@RequiredArgsConstructor
public class SubscriptionController {

    private static final Set<String> PLANS = Set.of("starter", "pro", "enterprise");

    private final SubscriptionMapper subscriptionMapper;

    @GetMapping
    public ApiResponse<Subscription> get(@AuthenticationPrincipal JwtUserPrincipal principal) {
        Long branchId = resolveBranch(principal);
        return ApiResponse.success(
                subscriptionMapper.findByBranchId(branchId)
                        .orElseGet(() -> Subscription.builder()
                                .branchId(branchId)
                                .plan("starter")
                                .status("trial")
                                .startedAt(LocalDateTime.now())
                                .renewsAt(LocalDate.now().plusDays(14))
                                .build()));
    }

    @PutMapping
    public ApiResponse<Subscription> setPlan(@RequestParam String plan,
                                             @AuthenticationPrincipal JwtUserPrincipal principal) {
        if (!PLANS.contains(plan)) {
            throw new BadRequestException("Invalid plan: " + plan + ". Allowed: " + PLANS);
        }
        Long branchId = resolveBranch(principal);
        Subscription sub = subscriptionMapper.findByBranchId(branchId).orElse(null);
        if (sub == null) {
            sub = Subscription.builder()
                    .branchId(branchId)
                    .plan(plan)
                    .status("trial")
                    .startedAt(LocalDateTime.now())
                    .renewsAt(LocalDate.now().plusDays(14))
                    .build();
            subscriptionMapper.insert(sub);
        } else {
            sub.setPlan(plan);
            if ("trial".equals(sub.getStatus())) sub.setStatus("active");
            subscriptionMapper.updateById(sub);
        }
        return ApiResponse.success(sub);
    }

    private Long resolveBranch(JwtUserPrincipal principal) {
        if (principal != null && principal.getBranchId() != null && principal.getBranchId() > 0) {
            return principal.getBranchId();
        }
        // No branch claim — the org-level subscription.
        return 1L;
    }
}
