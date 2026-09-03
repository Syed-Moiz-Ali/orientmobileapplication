package com.orient.workshop.technician.service;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.exception.ForbiddenException;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.common.util.DateParse;
import com.orient.workshop.technician.model.dto.*;
import com.orient.workshop.core.model.entity.Attendance;
import com.orient.workshop.core.model.entity.Staff;
import com.orient.workshop.core.repository.AttendanceMapper;
import com.orient.workshop.core.repository.StaffMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.Duration;
import java.time.format.DateTimeFormatter;

@Slf4j
@Service
@RequiredArgsConstructor
public class AttendanceService {

    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("hh:mm a");

    private final AttendanceMapper attendanceMapper;
    private final StaffMapper staffMapper;

    @Transactional
    public AttendanceResponse punchIn(JwtUserPrincipal principal, PunchInRequest req) {
        Staff staff = resolveStaff(principal);
        LocalDate date = parseDate(req.getDate());

        String punchIn = LocalTime.now().format(TIME_FMT);

        Attendance attendance = attendanceMapper.findByEmpIdAndDate(staff.getEmpId(), date)
                .orElseGet(() -> Attendance.builder()
                        .ref(com.orient.workshop.common.util.IdGenerator.shortRef("ATT"))
                        .empId(staff.getEmpId())
                        .date(date)
                        .build());

        if (attendance.getId() != null) {
            // Idempotent repeat taps must never overwrite the original arrival
            // time or allow a completed shift to be reopened.
            if ("punchedOut".equals(attendance.getStatus())) {
                throw new ForbiddenException("Today's shift has already been completed");
            }
            return toResponse(attendance);
        }

        attendance.setStatus("working");
        attendance.setPunchIn(punchIn);

        if (attendance.getId() == null) {
            try {
                attendanceMapper.insert(attendance);
            } catch (DuplicateKeyException e) {
                log.info("Concurrent punch-in detected for empId={} date={}; updating existing record",
                        staff.getEmpId(), date);
                attendance = attendanceMapper.findByEmpIdAndDate(staff.getEmpId(), date)
                        .orElseThrow(() -> new NotFoundException("Attendance record disappeared"));
                return toResponse(attendance);
            }
        }
        return toResponse(attendance);
    }

    @Transactional
    public void punchOut(JwtUserPrincipal principal, PunchOutRequest req) {
        Staff staff = resolveStaff(principal);
        LocalDate date = parseDate(req.getDate());

        Attendance attendance = attendanceMapper.findByEmpIdAndDate(staff.getEmpId(), date)
                .orElseThrow(() -> new NotFoundException("No attendance record found for today"));

        if ("punchedOut".equals(attendance.getStatus())) return;

        String punchOut = LocalTime.now().format(TIME_FMT);
        attendance.setStatus("punchedOut");
        attendance.setPunchOut(punchOut);
        attendance.setWorkHours(calculateWorkHours(attendance.getPunchIn(), punchOut));
        attendanceMapper.updateById(attendance);
    }

    @Transactional
    public void breakStart(JwtUserPrincipal principal, AttendanceStatusRequest req) {
        Staff staff = resolveStaff(principal);
        Attendance attendance = attendanceMapper.findByEmpIdAndDate(staff.getEmpId(), LocalDate.now())
                .orElseThrow(() -> new NotFoundException("No attendance record found"));
        attendance.setStatus("onBreak");
        attendanceMapper.updateById(attendance);
    }

    @Transactional
    public void breakEnd(JwtUserPrincipal principal, AttendanceStatusRequest req) {
        Staff staff = resolveStaff(principal);
        Attendance attendance = attendanceMapper.findByEmpIdAndDate(staff.getEmpId(), LocalDate.now())
                .orElseThrow(() -> new NotFoundException("No attendance record found"));
        attendance.setStatus("working");
        attendanceMapper.updateById(attendance);
    }

    public AttendanceResponse getAttendance(JwtUserPrincipal principal, String dateStr) {
        Staff staff = resolveStaff(principal);
        LocalDate date = parseDate(dateStr);
        Attendance attendance = attendanceMapper.findByEmpIdAndDate(staff.getEmpId(), date)
                .orElse(null);

        if (attendance == null) {
            return AttendanceResponse.builder().status("notPunchedIn").build();
        }
        return toResponse(attendance);
    }

    private Staff resolveStaff(JwtUserPrincipal principal) {
        if (principal == null || principal.getUserId() == null) {
            throw new ForbiddenException("Authenticated user not found");
        }
        return staffMapper.findByUserId(principal.getUserId())
                .orElseThrow(() -> new ForbiddenException(
                        "No staff record linked to the authenticated user"));
    }

    private LocalDate parseDate(String dateStr) {
        if (dateStr == null || dateStr.isBlank()) return LocalDate.now();
        return DateParse.parseLocalDate(dateStr, "date");
    }

    private AttendanceResponse toResponse(Attendance a) {
        return AttendanceResponse.builder()
                .ref(a.getRef())
                .status(a.getStatus())
                .punchIn(a.getPunchIn() != null ? a.getPunchIn() : "")
                .punchOut(a.getPunchOut() != null ? a.getPunchOut() : "")
                .breakTime(a.getBreakTime() != null ? a.getBreakTime() : "")
                .workHours(a.getWorkHours() != null ? a.getWorkHours() : "")
                .build();
    }

    private String calculateWorkHours(String punchIn, String punchOut) {
        if (punchIn == null || punchIn.isBlank()) return "0h 0m";
        LocalTime start = LocalTime.parse(punchIn, TIME_FMT);
        LocalTime end = LocalTime.parse(punchOut, TIME_FMT);
        long minutes = Duration.between(start, end).toMinutes();
        if (minutes < 0) minutes += 24 * 60;
        return String.format("%dh %dm", minutes / 60, minutes % 60);
    }
}
