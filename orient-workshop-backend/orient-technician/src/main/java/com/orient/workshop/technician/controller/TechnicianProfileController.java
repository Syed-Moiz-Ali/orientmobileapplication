package com.orient.workshop.technician.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.technician.model.dto.TechnicianProfileResponse;
import com.orient.workshop.technician.service.TechnicianProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Technician")
@RestController
@RequestMapping("/technicians")
@RequiredArgsConstructor
public class TechnicianProfileController {

    private final TechnicianProfileService profileService;

    @GetMapping("/profile")
    public ApiResponse<TechnicianProfileResponse> getProfile(@RequestParam(defaultValue = "EMP-001") String empId) {
        return ApiResponse.success(profileService.getProfile(empId));
    }
}

