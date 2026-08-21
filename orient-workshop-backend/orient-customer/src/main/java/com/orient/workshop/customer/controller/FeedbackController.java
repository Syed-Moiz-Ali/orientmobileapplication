package com.orient.workshop.customer.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.core.model.entity.Feedback;
import com.orient.workshop.customer.model.dto.FeedbackRequest;
import com.orient.workshop.customer.model.dto.IdResponse;
import com.orient.workshop.customer.service.FeedbackService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Tag(name = "Customer Portal")
@RestController
@RequiredArgsConstructor
public class FeedbackController {

    private final FeedbackService feedbackService;

    @PostMapping("/feedback")
    public ApiResponse<IdResponse> submit(@AuthenticationPrincipal JwtUserPrincipal principal,
                                           @Valid @RequestBody FeedbackRequest req) {
        return ApiResponse.success(feedbackService.submit(principal, req));
    }

    @GetMapping("/feedback")
    public ApiResponse<List<Feedback>> list(@AuthenticationPrincipal JwtUserPrincipal principal,
                                             @RequestParam(defaultValue = "1") int page,
                                             @RequestParam(defaultValue = "20") int size) {
        // H-1 (tenant isolation): never trust a client-supplied branchId. Scope to the
        // authenticated user's own branch so customers cannot enumerate other branches'
        // feedback. Staff roles with no branch (owner/admin) get a null = global view.
        Long branchId = resolveBranchId(principal);
        return ApiResponse.success(feedbackService.getAll(branchId, page, size));
    }

    @GetMapping("/feedback/stats")
    public ApiResponse<Map<String, Object>> stats(@AuthenticationPrincipal JwtUserPrincipal principal) {
        Long branchId = resolveBranchId(principal);
        return ApiResponse.success(feedbackService.getStats(branchId));
    }

    /**
     * Moderation: staff may approve/reject public visibility of a review.
     * Path-level RBAC: /feedback/** allows staff + customer; this specific
     * action is additionally gated to staff roles by method security.
     */
    @PutMapping("/feedback/{id}/moderation")
    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ADVISOR','SUPERVISOR','OWNER','ADMIN')")
    public ApiResponse<Map<String, Boolean>> moderate(@PathVariable Long id,
                                                      @RequestParam(defaultValue = "true") boolean isPublic) {
        feedbackService.moderate(id, isPublic);
        return ApiResponse.success(Map.of("moderated", true));
    }

    /**
     * P2 (audit): moderation inbox (staff-only).
     */
    @GetMapping("/feedback/pending")
    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('ADVISOR','SUPERVISOR','OWNER','ADMIN')")
    public ApiResponse<List<Feedback>> pending(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "50") int size) {
        return ApiResponse.success(feedbackService.getPendingModeration(page, size));
    }

    private Long resolveBranchId(JwtUserPrincipal principal) {
        if (principal == null) {
            throw new com.orient.workshop.common.exception.ForbiddenException("Authentication required");
        }
        String role = principal.getRole() != null ? principal.getRole().toLowerCase() : "";
        if ("owner".equals(role) || "admin".equals(role) || "crmdashboard".equals(role)) {
            return null;
        }
        return principal.getBranchId();
    }
}
