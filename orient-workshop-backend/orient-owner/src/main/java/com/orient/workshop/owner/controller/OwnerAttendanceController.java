package com.orient.workshop.owner.controller;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.common.util.DateParse;
import com.orient.workshop.owner.model.dto.OwnerAttendanceResponse;
import com.orient.workshop.owner.repository.OwnerAttendanceMapper;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

@Tag(name = "Owner")
@RestController
@RequestMapping("/owner/attendance")
@RequiredArgsConstructor
public class OwnerAttendanceController {

    private final OwnerAttendanceMapper attendanceMapper;

    @GetMapping
    public ApiResponse<List<OwnerAttendanceResponse>> daily(
            @AuthenticationPrincipal JwtUserPrincipal principal,
            @RequestParam(required = false) String date) {
        LocalDate selectedDate = date == null || date.isBlank()
                ? LocalDate.now()
                : DateParse.parseLocalDate(date, "date");
        Long branchId = principal != null ? principal.getBranchId() : null;
        return ApiResponse.success(
                attendanceMapper.findDailyAttendance(selectedDate, branchId));
    }
}
