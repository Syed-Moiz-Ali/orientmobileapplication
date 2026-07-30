package com.orient.workshop.advisor.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.advisor.model.dto.CustomerSearchResponse;
import com.orient.workshop.advisor.model.dto.VehicleSearchResponse;
import com.orient.workshop.advisor.service.SearchService;
import com.orient.workshop.common.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Advisor")
@RestController
@RequiredArgsConstructor
public class SearchController {

    private final SearchService searchService;

    @GetMapping("/customers/search")
    public ApiResponse<List<CustomerSearchResponse>> searchCustomers(@RequestParam String q) {
        return ApiResponse.success(searchService.searchCustomers(q));
    }

    @GetMapping("/vehicles/search")
    public ApiResponse<List<VehicleSearchResponse>> searchVehicles(@RequestParam String q) {
        return ApiResponse.success(searchService.searchVehicles(q));
    }
}

