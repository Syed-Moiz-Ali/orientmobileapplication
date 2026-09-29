package com.orient.workshop.advisor.controller;

import com.orient.workshop.advisor.model.dto.InspectionTemplateResponse;
import com.orient.workshop.advisor.service.InspectionTemplateService;
import com.orient.workshop.common.response.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Inspection Templates")
@RestController
@RequiredArgsConstructor
@RequestMapping("/advisor/inspection-templates")
public class InspectionTemplateController {
    private final InspectionTemplateService service;

    @GetMapping("/default")
    public ApiResponse<InspectionTemplateResponse> getDefaultTemplate() {
        return ApiResponse.success(service.getDefaultTemplate());
    }
}
