package com.orient.workshop.customer.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.customer.model.dto.ActiveServiceResponse;
import com.orient.workshop.customer.model.dto.ServiceTypeResponse;
import com.orient.workshop.customer.service.ServiceTrackingService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "Customer Portal")
@RestController
@RequiredArgsConstructor
public class ServiceTrackingController {

    private final ServiceTrackingService serviceTrackingService;

    @GetMapping("/customers/services/active")
    public ApiResponse<ActiveServiceResponse> getActiveService(@AuthenticationPrincipal JwtUserPrincipal principal) {
        ActiveServiceResponse response = serviceTrackingService.getActiveService(principal);
        return ApiResponse.success(response);
    }

    @GetMapping("/services/types")
    public ApiResponse<List<ServiceTypeResponse>> getServiceTypes() {
        List<ServiceTypeResponse> types = serviceTrackingService.getServiceTypes();
        return ApiResponse.success(types);
    }
}

