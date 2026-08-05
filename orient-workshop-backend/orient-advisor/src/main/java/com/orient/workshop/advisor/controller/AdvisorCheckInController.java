package com.orient.workshop.advisor.controller;

import io.swagger.v3.oas.annotations.tags.Tag;
import com.orient.workshop.advisor.model.dto.CheckInRequest;
import com.orient.workshop.advisor.model.dto.CheckInResponse;
import com.orient.workshop.advisor.service.AdvisorBookingService;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Advisor Portal")
@RestController
@RequestMapping("/advisor")
@RequiredArgsConstructor
public class AdvisorCheckInController {

    private final AdvisorBookingService advisorBookingService;

    @PostMapping("/bookings/{bookingId}/check-in")
    public ApiResponse<CheckInResponse> checkIn(
            @PathVariable Long bookingId,
            @RequestBody CheckInRequest request,
            @AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(advisorBookingService.checkIn(bookingId, request, principal));
    }
}
