package com.orient.workshop.customer.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.core.model.entity.Feedback;
import com.orient.workshop.customer.model.dto.IdResponse;
import com.orient.workshop.customer.service.FeedbackService;
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
                                           @RequestBody Map<String, Object> body) {
        Long jobCardId = body.get("jobCardId") != null ? Long.valueOf(body.get("jobCardId").toString()) : null;
        int rating = Integer.parseInt(body.getOrDefault("rating", "5").toString());
        String comment = (String) body.getOrDefault("comment", "");
        return ApiResponse.success(feedbackService.submit(principal, jobCardId, rating, comment));
    }

    @GetMapping("/feedback")
    public ApiResponse<List<Feedback>> list(@RequestParam(required = false) Long branchId,
                                             @RequestParam(defaultValue = "1") int page,
                                             @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(feedbackService.getAll(branchId));
    }

    @GetMapping("/feedback/stats")
    public ApiResponse<Map<String, Object>> stats(@RequestParam(required = false) Long branchId) {
        return ApiResponse.success(feedbackService.getStats(branchId));
    }
}

