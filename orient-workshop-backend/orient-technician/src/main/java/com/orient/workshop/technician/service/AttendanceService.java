package com.orient.workshop.technician.service;

import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.technician.model.dto.*;
import com.orient.workshop.core.model.entity.Attendance;
import com.orient.workshop.core.repository.AttendanceMapper;
import com.orient.workshop.core.repository.StaffMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@Service
@RequiredArgsConstructor
public class AttendanceService {

    private final AttendanceMapper attendanceMapper;
    private final StaffMapper staffMapper;

    @Transactional
    public AttendanceResponse punchIn(PunchInRequest req) {
        staffMapper.findByEmpId(req.getEmpId())
                .orElseThrow(() -> new NotFoundException("Staff not found"));

        LocalDate date = req.getDate() != null
                ? LocalDate.parse(req.getDate())
                : LocalDate.now();

        Attendance attendance = Attendance.builder()
                .empId(req.getEmpId())
                .date(date)
                .status(req.getStatus() != null ? req.getStatus() : "working")
                .punchIn(req.getPunchIn() != null ? req.getPunchIn() : LocalDate.now().format(DateTimeFormatter.ofPattern("hh:mm a")))
                .build();
        attendanceMapper.insert(attendance);

        return toResponse(attendance);
    }

    @Transactional
    public void punchOut(PunchOutRequest req) {
        LocalDate date = req.getDate() != null
                ? LocalDate.parse(req.getDate())
                : LocalDate.now();

        Attendance attendance = attendanceMapper.findByEmpIdAndDate(req.getEmpId(), date)
                .orElseThrow(() -> new NotFoundException("No attendance record found for today"));

        attendance.setStatus(req.getStatus() != null ? req.getStatus() : "punchedOut");
        attendance.setPunchOut(req.getPunchOut());
        attendance.setBreakTime(req.getBreakTime());
        attendance.setWorkHours(req.getWorkHours());
        attendanceMapper.updateById(attendance);
    }

    @Transactional
    public void breakStart(AttendanceStatusRequest req) {
        LocalDate today = LocalDate.now();
        Attendance attendance = attendanceMapper.findByEmpIdAndDate(req.getEmpId(), today)
                .orElseThrow(() -> new NotFoundException("No attendance record found"));
        attendance.setStatus("onBreak");
        attendanceMapper.updateById(attendance);
    }

    @Transactional
    public void breakEnd(AttendanceStatusRequest req) {
        LocalDate today = LocalDate.now();
        Attendance attendance = attendanceMapper.findByEmpIdAndDate(req.getEmpId(), today)
                .orElseThrow(() -> new NotFoundException("No attendance record found"));
        attendance.setStatus("working");
        attendanceMapper.updateById(attendance);
    }

    public AttendanceResponse getAttendance(String empId, String dateStr) {
        LocalDate date = dateStr != null ? LocalDate.parse(dateStr) : LocalDate.now();
        Attendance attendance = attendanceMapper.findByEmpIdAndDate(empId, date)
                .orElse(null);

        if (attendance == null) {
            return AttendanceResponse.builder().status("notPunchedIn").build();
        }
        return toResponse(attendance);
    }

    private AttendanceResponse toResponse(Attendance a) {
        return AttendanceResponse.builder()
                .status(a.getStatus())
                .punchIn(a.getPunchIn() != null ? a.getPunchIn() : "")
                .punchOut(a.getPunchOut() != null ? a.getPunchOut() : "")
                .breakTime(a.getBreakTime() != null ? a.getBreakTime() : "")
                .workHours(a.getWorkHours() != null ? a.getWorkHours() : "")
                .build();
    }
}
