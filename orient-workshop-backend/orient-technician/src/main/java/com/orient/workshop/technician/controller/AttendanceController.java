package com.orient.workshop.technician.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.exception.ForbiddenException;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.technician.model.dto.*;
import com.orient.workshop.technician.service.AttendanceService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Set;

@Tag(name = "Technician")
@RestController
@RequestMapping("/technicians/attendance")
@RequiredArgsConstructor
public class AttendanceController {

    private static final Set<String> ALLOWED_WRITE_ROLES = Set.of("technician", "supervisor", "owner");

    private final AttendanceService attendanceService;

    @PostMapping("/punch-in")
    public ApiResponse<AttendanceResponse> punchIn(@AuthenticationPrincipal JwtUserPrincipal principal,
                                                   @Valid @RequestBody PunchInRequest req) {
        requireWriteRole(principal);
        return ApiResponse.success(attendanceService.punchIn(principal, req));
    }

    @PostMapping("/punch-out")
    public ApiResponse<Void> punchOut(@AuthenticationPrincipal JwtUserPrincipal principal,
                                      @Valid @RequestBody PunchOutRequest req) {
        requireWriteRole(principal);
        attendanceService.punchOut(principal, req);
        return ApiResponse.success(null);
    }

    @PostMapping("/break-start")
    public ApiResponse<Void> breakStart(@AuthenticationPrincipal JwtUserPrincipal principal,
                                        @Valid @RequestBody AttendanceStatusRequest req) {
        requireWriteRole(principal);
        attendanceService.breakStart(principal, req);
        return ApiResponse.success(null);
    }

    @PostMapping("/break-end")
    public ApiResponse<Void> breakEnd(@AuthenticationPrincipal JwtUserPrincipal principal,
                                      @Valid @RequestBody AttendanceStatusRequest req) {
        requireWriteRole(principal);
        attendanceService.breakEnd(principal, req);
        return ApiResponse.success(null);
    }

    @GetMapping
    public ApiResponse<AttendanceResponse> getAttendance(@AuthenticationPrincipal JwtUserPrincipal principal,
                                                          @RequestParam(required = false) String empId,
                                                          @RequestParam(required = false) String date) {
        return ApiResponse.success(attendanceService.getAttendance(principal, date));
    }

    private void requireWriteRole(JwtUserPrincipal principal) {
        if (principal == null || principal.getRole() == null
                || !ALLOWED_WRITE_ROLES.contains(principal.getRole().toLowerCase())) {
            throw new ForbiddenException("Attendance writes are only allowed for technician, supervisor or owner");
        }
    }
}
