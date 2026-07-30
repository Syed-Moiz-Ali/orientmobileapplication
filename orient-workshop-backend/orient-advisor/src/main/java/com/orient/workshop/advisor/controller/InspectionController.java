package com.orient.workshop.advisor.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.advisor.model.dto.InspectionDraftResponse;
import com.orient.workshop.advisor.model.dto.InspectionRequest;
import com.orient.workshop.advisor.model.dto.InspectionResponse;
import com.orient.workshop.advisor.service.InspectionService;
import com.orient.workshop.common.response.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Advisor")
@RestController
@RequestMapping("/inspections")
@RequiredArgsConstructor
public class InspectionController {

    private final InspectionService inspectionService;

    @PostMapping
    public ApiResponse<InspectionResponse> createInspection(@Valid @RequestBody InspectionRequest req) {
        InspectionResponse response = inspectionService.createInspection(req);
        return ApiResponse.success(response);
    }

    @GetMapping("/{id}/draft")
    public ApiResponse<InspectionDraftResponse> getDraft(@PathVariable Long id) {
        return ApiResponse.success(inspectionService.getDraft(id));
    }

    @PutMapping("/{id}/draft")
    public ApiResponse<Void> saveDraft(@PathVariable Long id, @RequestBody InspectionRequest req) {
        inspectionService.saveDraft(id, req);
        return ApiResponse.success(null);
    }

    @DeleteMapping("/{id}/draft")
    public ApiResponse<Void> deleteDraft(@PathVariable Long id) {
        inspectionService.deleteDraft(id);
        return ApiResponse.success(null);
    }
}

