package com.orient.workshop.advisor.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.advisor.model.dto.AdvisorStatsResponse;
import com.orient.workshop.advisor.service.AdvisorStatsService;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Advisor")
@RestController
@RequestMapping("/advisor")
@RequiredArgsConstructor
public class AdvisorDashboardController {

    private final AdvisorStatsService statsService;

    @GetMapping("/stats")
    public ApiResponse<AdvisorStatsResponse> getStats(@AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(statsService.getStats(principal));
    }
}

