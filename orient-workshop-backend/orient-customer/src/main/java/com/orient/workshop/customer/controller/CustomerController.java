package com.orient.workshop.customer.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.customer.model.dto.VehicleResponse;
import com.orient.workshop.customer.model.dto.NotificationResponse;
import com.orient.workshop.customer.model.dto.CustomerProfileResponse;
import com.orient.workshop.customer.model.dto.ActiveServiceResponse;
import com.orient.workshop.customer.model.dto.IdResponse;
import com.orient.workshop.customer.service.CustomerService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

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

    @GetMapping("/vehicles")
    public ApiResponse<List<VehicleResponse>> getVehicles(@AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(customerService.getVehicles(principal));
    }

    @PostMapping("/vehicles")
    public ApiResponse<VehicleResponse> addVehicle(@AuthenticationPrincipal JwtUserPrincipal principal, @RequestBody VehicleResponse request) {
        return ApiResponse.success(customerService.addVehicle(principal, request));
    }

    @PutMapping("/vehicles/{id}")
    public ApiResponse<VehicleResponse> updateVehicle(@AuthenticationPrincipal JwtUserPrincipal principal, @PathVariable Long id, @RequestBody VehicleResponse request) {
        return ApiResponse.success(customerService.updateVehicle(principal, id, request));
    }

    @DeleteMapping("/vehicles/{id}")
    public ApiResponse<Void> deleteVehicle(@AuthenticationPrincipal JwtUserPrincipal principal, @PathVariable Long id) {
        customerService.deleteVehicle(principal, id);
        return ApiResponse.success(null);
    }

    @GetMapping("/notifications")
    public ApiResponse<List<NotificationResponse>> getNotifications(@AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(customerService.getNotifications(principal));
    }

    @GetMapping("/services/active")
    public ApiResponse<ActiveServiceResponse> getActiveService(@AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(customerService.getActiveService(principal));
    }
}

