package com.orient.workshop.advisor.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.advisor.model.dto.AssignTechnicianRequest;
import com.orient.workshop.advisor.model.dto.JobCardDetailResponse;
import com.orient.workshop.advisor.model.dto.JobCardResponse;
import com.orient.workshop.advisor.model.dto.UpdateStatusRequest;
import com.orient.workshop.advisor.service.JobCardService;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.common.response.PageResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Advisor")
@RestController
@RequestMapping("/advisor/job-cards")
@RequiredArgsConstructor
public class JobCardController {

    private final JobCardService jobCardService;

    @GetMapping
    public ApiResponse<PageResponse<JobCardResponse>> listJobCards(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String search,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int limit) {
        PageResponse<JobCardResponse> result = jobCardService.listJobCards(status, search, page, limit);
        return ApiResponse.success(result);
    }

    @GetMapping("/{id}")
    public ApiResponse<JobCardDetailResponse> getJobCard(@PathVariable Long id) {
        return ApiResponse.success(jobCardService.getJobCard(id));
    }

    @PutMapping("/{id}/status")
    public ApiResponse<Void> updateStatus(@PathVariable Long id, @Valid @RequestBody UpdateStatusRequest req) {
        jobCardService.updateStatus(id, req.getStatus());
        return ApiResponse.success(null);
    }

    @PutMapping("/{id}/technician")
    public ApiResponse<Void> assignTechnician(@PathVariable Long id, @Valid @RequestBody AssignTechnicianRequest req) {
        jobCardService.assignTechnician(id, req.getTechnician());
        return ApiResponse.success(null);
    }
}

