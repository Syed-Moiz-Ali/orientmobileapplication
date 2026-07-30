package com.orient.workshop.customer.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.customer.model.dto.BreakdownRequest;
import com.orient.workshop.customer.model.dto.IdResponse;
import com.orient.workshop.customer.service.BreakdownService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Customer Portal")
@RestController
@RequestMapping("/customers")
@RequiredArgsConstructor
public class BreakdownController {

    private final BreakdownService breakdownService;

    @PostMapping("/breakdowns")
    public ApiResponse<IdResponse> createBreakdown(@AuthenticationPrincipal JwtUserPrincipal principal,
                                                     @Valid @RequestBody BreakdownRequest request) {
        IdResponse response = breakdownService.createBreakdown(principal, request);
        return ApiResponse.success(response);
    }
}

