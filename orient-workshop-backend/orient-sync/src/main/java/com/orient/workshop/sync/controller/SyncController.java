package com.orient.workshop.sync.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.repository.JobCardMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Tag(name = "Sync")
@RestController
@RequestMapping("/sync")
@RequiredArgsConstructor
public class SyncController {

    private final JobCardMapper jobCardMapper;

    @PostMapping("/inspections/{id}")
    public ApiResponse<Map<String, String>> syncInspection(@PathVariable String id, @RequestBody Map<String, Object> body) {
        return ApiResponse.success(Map.of("id", id, "synced", "true"));
    }

    @PostMapping("/jobs/complete/{id}")
    public ApiResponse<Map<String, String>> syncJobComplete(@PathVariable String id, @RequestBody Map<String, Object> body) {
        return ApiResponse.success(Map.of("id", id, "synced", "true"));
    }

    @PostMapping("/repair-orders/{id}")
    public ApiResponse<Map<String, String>> syncRepairOrder(@PathVariable String id, @RequestBody Map<String, Object> body) {
        return ApiResponse.success(Map.of("id", id, "synced", "true"));
    }
}

