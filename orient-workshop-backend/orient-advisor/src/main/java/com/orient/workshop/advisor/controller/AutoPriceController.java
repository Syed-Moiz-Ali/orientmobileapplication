package com.orient.workshop.advisor.controller;

import com.orient.workshop.advisor.repository.RepairOrderServiceMapper;
import com.orient.workshop.common.response.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.Map;

@Tag(name = "Advisor")
@RestController
@RequestMapping("/advisor/auto-price")
@RequiredArgsConstructor
public class AutoPriceController {

    private final RepairOrderServiceMapper serviceMapper;

    /**
     * P3 (audit): AI-lite auto-pricing — suggests a rate for a service based
     * on the average historical rate charged for the same service name.
     * Transparent and explainable; the advisor can override.
     */
    @GetMapping
    public ApiResponse<Map<String, Object>> suggest(@RequestParam String name) {
        Map<String, Object> row = serviceMapper.avgRateForName(name);
        Object avg = row != null ? row.get("avg_rate") : null;
        Object cnt = row != null ? row.get("cnt") : null;
        long count = cnt != null ? ((Number) cnt).longValue() : 0L;
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("service", name);
        if (count > 0 && avg != null) {
            BigDecimal rate = new BigDecimal(avg.toString()).setScale(2, java.math.RoundingMode.HALF_UP);
            result.put("suggestedRate", rate);
            result.put("samples", count);
            result.put("note", "Average of " + count + " historical quote(s)");
        } else {
            result.put("suggestedRate", null);
            result.put("samples", 0);
            result.put("note", "No history yet — quote manually");
        }
        return ApiResponse.success(result);
    }
}
