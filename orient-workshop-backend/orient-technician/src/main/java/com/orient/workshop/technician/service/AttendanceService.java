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

        String punchIn = req.getPunchIn() != null && !req.getPunchIn().isBlank()
                ? req.getPunchIn()
                : LocalTime.now().format(TIME_FMT);

        Attendance attendance = attendanceMapper.findByEmpIdAndDate(staff.getEmpId(), date)
                .orElseGet(() -> Attendance.builder()
                        .empId(staff.getEmpId())
                        .date(date)
                        .build());

        attendance.setStatus(req.getStatus() != null ? req.getStatus() : "working");
        attendance.setPunchIn(punchIn);

        if (attendance.getId() == null) {
            try {
                attendanceMapper.insert(attendance);
            } catch (DuplicateKeyException e) {
                log.info("Concurrent punch-in detected for empId={} date={}; updating existing record",
                        staff.getEmpId(), date);
                attendance = attendanceMapper.findByEmpIdAndDate(staff.getEmpId(), date)
                        .orElseThrow(() -> new NotFoundException("Attendance record disappeared"));
                attendance.setStatus(req.getStatus() != null ? req.getStatus() : "working");
                attendance.setPunchIn(punchIn);
                attendanceMapper.updateById(attendance);
            }
        } else {
            attendanceMapper.updateById(attendance);
        }
        return toResponse(attendance);
    }

    @Transactional
    public void punchOut(JwtUserPrincipal principal, PunchOutRequest req) {
        Staff staff = resolveStaff(principal);
        LocalDate date = parseDate(req.getDate());

        Attendance attendance = attendanceMapper.findByEmpIdAndDate(staff.getEmpId(), date)
                .orElseThrow(() -> new NotFoundException("No attendance record found for today"));

        attendance.setStatus(req.getStatus() != null ? req.getStatus() : "punchedOut");
        attendance.setPunchOut(req.getPunchOut());
        attendance.setBreakTime(req.getBreakTime());
        attendance.setWorkHours(req.getWorkHours());
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
}
