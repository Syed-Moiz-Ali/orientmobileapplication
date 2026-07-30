package com.orient.workshop.advisor.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.advisor.model.dto.ReportResponse;
import com.orient.workshop.advisor.service.ReportService;
import com.orient.workshop.common.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Advisor")
@RestController
@RequestMapping("/advisor")
@RequiredArgsConstructor
public class ReportController {

    private final ReportService reportService;

    @GetMapping("/reports")
    public ApiResponse<ReportResponse> getReports(@RequestParam(defaultValue = "today") String range) {
        return ApiResponse.success(reportService.getReports(range));
    }
}

