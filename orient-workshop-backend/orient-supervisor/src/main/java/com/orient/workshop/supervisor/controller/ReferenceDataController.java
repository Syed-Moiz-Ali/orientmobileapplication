package com.orient.workshop.supervisor.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.supervisor.service.ReferenceDataService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Supervisor")
@RestController
@RequiredArgsConstructor
public class ReferenceDataController {

    private final ReferenceDataService referenceDataService;

    @GetMapping("/departments")
    public ApiResponse<List<String>> getDepartments() {
        return ApiResponse.success(referenceDataService.getDepartments());
    }

    @GetMapping("/technicians")
    public ApiResponse<List<String>> getTechnicians() {
        return ApiResponse.success(referenceDataService.getTechnicians());
    }
}

