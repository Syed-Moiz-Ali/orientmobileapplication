package com.orient.workshop.technician.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.technician.model.dto.ProductivityResponse;
import com.orient.workshop.technician.service.TechnicianJobService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Technician")
@RestController
@RequestMapping("/technicians")
@RequiredArgsConstructor
public class ProductivityController {

    private final TechnicianJobService jobService;

    @GetMapping("/productivity")
    public ApiResponse<ProductivityResponse> getProductivity(@AuthenticationPrincipal JwtUserPrincipal principal,
                                                              @RequestParam(required = false) String empId) {
        return ApiResponse.success(jobService.getProductivity(principal));
    }
}
