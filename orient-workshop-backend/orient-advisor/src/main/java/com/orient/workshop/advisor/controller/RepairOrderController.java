package com.orient.workshop.advisor.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.advisor.model.dto.RepairOrderRequest;
import com.orient.workshop.advisor.model.dto.RepairOrderResponse;
import com.orient.workshop.advisor.service.RepairOrderService;
import com.orient.workshop.common.response.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Advisor")
@RestController
@RequiredArgsConstructor
public class RepairOrderController {

    private final RepairOrderService repairOrderService;

    @PostMapping("/repair-orders")
    public ApiResponse<RepairOrderResponse> createRepairOrder(@Valid @RequestBody RepairOrderRequest req) {
        return ApiResponse.success(repairOrderService.createRepairOrder(req));
    }
}

