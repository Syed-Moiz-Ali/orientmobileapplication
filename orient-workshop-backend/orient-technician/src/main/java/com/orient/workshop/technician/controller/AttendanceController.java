package com.orient.workshop.technician.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.technician.model.dto.*;
import com.orient.workshop.technician.service.AttendanceService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Technician")
@RestController
@RequestMapping("/technicians/attendance")
@RequiredArgsConstructor
public class AttendanceController {

    private final AttendanceService attendanceService;

    @PostMapping("/punch-in")
    public ApiResponse<AttendanceResponse> punchIn(@Valid @RequestBody PunchInRequest req) {
        return ApiResponse.success(attendanceService.punchIn(req));
    }

    @PostMapping("/punch-out")
    public ApiResponse<Void> punchOut(@Valid @RequestBody PunchOutRequest req) {
        attendanceService.punchOut(req);
        return ApiResponse.success(null);
    }

    @PostMapping("/break-start")
    public ApiResponse<Void> breakStart(@Valid @RequestBody AttendanceStatusRequest req) {
        attendanceService.breakStart(req);
        return ApiResponse.success(null);
    }

    @PostMapping("/break-end")
    public ApiResponse<Void> breakEnd(@Valid @RequestBody AttendanceStatusRequest req) {
        attendanceService.breakEnd(req);
        return ApiResponse.success(null);
    }

    @GetMapping
    public ApiResponse<AttendanceResponse> getAttendance(@RequestParam String empId,
                                                          @RequestParam(required = false) String date) {
        return ApiResponse.success(attendanceService.getAttendance(empId, date));
    }
}

