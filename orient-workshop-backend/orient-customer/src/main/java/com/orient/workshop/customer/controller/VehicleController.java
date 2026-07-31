package com.orient.workshop.customer.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.customer.model.dto.AddVehicleRequest;
import com.orient.workshop.customer.model.dto.VehicleResponse;
import com.orient.workshop.customer.service.VehicleService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Customer Portal")
@RestController
@RequestMapping("/customers")
@RequiredArgsConstructor
public class VehicleController {

    private final VehicleService vehicleService;

    @GetMapping("/vehicles")
    public ApiResponse<List<VehicleResponse>> getVehicles(@AuthenticationPrincipal JwtUserPrincipal principal,
                                                           @RequestParam(defaultValue = "1") int page,
                                                           @RequestParam(defaultValue = "20") int size) {
        List<VehicleResponse> vehicles = vehicleService.getVehicles(principal);
        return ApiResponse.success(vehicles);
    }

    @PostMapping("/vehicles")
    public ApiResponse<VehicleResponse> addVehicle(@AuthenticationPrincipal JwtUserPrincipal principal,
                                                     @Valid @RequestBody AddVehicleRequest request) {
        VehicleResponse vehicle = vehicleService.addVehicle(principal, request);
        return ApiResponse.success(vehicle);
    }

    @PutMapping("/vehicles/{id}")
    public ApiResponse<VehicleResponse> updateVehicle(@AuthenticationPrincipal JwtUserPrincipal principal,
                                                       @PathVariable Long id,
                                                       @Valid @RequestBody AddVehicleRequest request) {
        VehicleResponse vehicle = vehicleService.updateVehicle(principal, id, request);
        return ApiResponse.success(vehicle);
    }

    @DeleteMapping("/vehicles/{id}")
    public ApiResponse<Void> deleteVehicle(@AuthenticationPrincipal JwtUserPrincipal principal,
                                            @PathVariable Long id) {
        vehicleService.deleteVehicle(principal, id);
        return ApiResponse.success(null);
    }
}

