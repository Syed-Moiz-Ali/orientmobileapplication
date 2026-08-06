package com.orient.workshop.advisor.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.advisor.model.dto.InspectionDraftResponse;
import com.orient.workshop.advisor.model.dto.InspectionRequest;
import com.orient.workshop.advisor.model.dto.InspectionResponse;
import com.orient.workshop.advisor.service.InspectionService;
import com.orient.workshop.advisor.service.InspectionSummaryService;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Tag(name = "Advisor")
@RestController
@RequestMapping("/inspections")
@RequiredArgsConstructor
public class InspectionController {

    private final InspectionService inspectionService;
    private final InspectionSummaryService inspectionSummaryService;

    @PostMapping
    public ApiResponse<InspectionResponse> createInspection(@AuthenticationPrincipal JwtUserPrincipal principal,
                                                            @Valid @RequestBody InspectionRequest req) {
        InspectionResponse response = inspectionService.createInspection(principal, req);
        return ApiResponse.success(response);
    }

    @PutMapping("/{id}")
    public ApiResponse<Void> updateInspection(@AuthenticationPrincipal JwtUserPrincipal principal,
                                              @PathVariable Long id, @RequestBody InspectionRequest req) {
        inspectionService.updateInspection(principal, id, req);
        return ApiResponse.success(null);
    }

    @GetMapping("/{id}/draft")
    public ApiResponse<InspectionDraftResponse> getDraft(@AuthenticationPrincipal JwtUserPrincipal principal,
                                                          @PathVariable Long id) {
        return ApiResponse.success(inspectionService.getDraft(principal, id));
    }

    @PutMapping("/{id}/draft")
    public ApiResponse<Void> saveDraft(@AuthenticationPrincipal JwtUserPrincipal principal,
                                       @PathVariable Long id, @RequestBody InspectionRequest req) {
        inspectionService.saveDraft(principal, id, req);
        return ApiResponse.success(null);
    }

    @DeleteMapping("/{id}/draft")
    public ApiResponse<Void> deleteDraft(@AuthenticationPrincipal JwtUserPrincipal principal,
                                         @PathVariable Long id) {
        inspectionService.deleteDraft(principal, id);
        return ApiResponse.success(null);
    }

    /**
     * P3 (audit): AI-lite inspection summary — transparent template-based
     * narrative from the stored sections.
     */
    @GetMapping("/{id}/summary")
    public ApiResponse<Map<String, Object>> summary(@PathVariable Long id) {
        return ApiResponse.success(inspectionSummaryService.summarize(id));
    }
}
