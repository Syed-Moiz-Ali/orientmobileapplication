package com.orient.workshop.advisor.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.advisor.model.dto.AssignTechnicianRequest;
import com.orient.workshop.advisor.model.dto.JobCardDetailResponse;
import com.orient.workshop.advisor.model.dto.JobCardResponse;
import com.orient.workshop.advisor.model.dto.UpdateStatusRequest;
import com.orient.workshop.advisor.service.JobCardService;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.common.response.PageResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Advisor")
@RestController
@RequestMapping("/advisor/job-cards")
@RequiredArgsConstructor
public class JobCardController {

    private final JobCardService jobCardService;

    @GetMapping
    public ApiResponse<PageResponse<JobCardResponse>> listJobCards(
            @AuthenticationPrincipal JwtUserPrincipal principal,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String search,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int limit) {
        PageResponse<JobCardResponse> result = jobCardService.listJobCards(status, search, page, limit, principal);
        return ApiResponse.success(result);
    }

    @GetMapping("/{id}")
    public ApiResponse<JobCardDetailResponse> getJobCard(@AuthenticationPrincipal JwtUserPrincipal principal,
                                                          @PathVariable Long id) {
        return ApiResponse.success(jobCardService.getJobCard(id, principal));
    }

    @PutMapping("/{id}/status")
    public ApiResponse<Void> updateStatus(@AuthenticationPrincipal JwtUserPrincipal principal,
                                          @PathVariable Long id, @Valid @RequestBody UpdateStatusRequest req) {
        jobCardService.updateStatus(id, req.getStatus(), principal);
        return ApiResponse.success(null);
    }

    @PutMapping("/{id}/technician")
    public ApiResponse<Void> assignTechnician(@AuthenticationPrincipal JwtUserPrincipal principal,
                                              @PathVariable Long id, @Valid @RequestBody AssignTechnicianRequest req) {
        jobCardService.assignTechnician(id, req.getTechnician(), principal);
        return ApiResponse.success(null);
    }
}

