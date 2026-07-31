package com.orient.workshop.customer.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.customer.model.dto.CustomerProfileResponse;
import com.orient.workshop.customer.model.dto.IdResponse;
import com.orient.workshop.customer.service.CustomerService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Customer Portal")
@RestController
@RequestMapping("/customers")
@RequiredArgsConstructor
public class CustomerController {

    private final CustomerService customerService;

    @GetMapping("/profile")
    public ApiResponse<CustomerProfileResponse> getProfile(@AuthenticationPrincipal JwtUserPrincipal principal) {
        CustomerProfileResponse profile = customerService.getProfile(principal);
        return ApiResponse.success(profile);
    }
}

