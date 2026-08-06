package com.orient.workshop.technician.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.technician.model.dto.TechnicianProfileResponse;
import com.orient.workshop.technician.service.TechnicianProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Technician")
@RestController
@RequestMapping("/technicians")
@RequiredArgsConstructor
public class TechnicianProfileController {

    private final TechnicianProfileService profileService;

    @GetMapping("/profile")
    public ApiResponse<TechnicianProfileResponse> getProfile(@AuthenticationPrincipal JwtUserPrincipal principal) {
        // S-16: identity comes from the JWT principal, never a query param —
        // previously any authenticated user could read any profile by empId
        // and the app defaulted to EMP-001.
        return ApiResponse.success(profileService.getProfileForPrincipal(principal));
    }
}

