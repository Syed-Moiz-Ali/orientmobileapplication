package com.orient.workshop.technician.service;

import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.technician.model.dto.TechnicianProfileResponse;
import com.orient.workshop.core.model.entity.Staff;
import com.orient.workshop.core.repository.StaffMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class TechnicianProfileService {

    private final StaffMapper staffMapper;

    public TechnicianProfileResponse getProfile(String empId) {
        Staff staff = staffMapper.findByEmpId(empId)
                .orElseThrow(() -> new NotFoundException("Staff not found with empId: " + empId));

        String initials = getInitials(staff.getName());
        return TechnicianProfileResponse.builder()
                .name(staff.getName())
                .empId(staff.getEmpId())
                .role(staff.getRole())
                .branch(staff.getBranch() != null ? staff.getBranch() : "Main Branch - Dubai")
                .shift(staff.getShift() != null ? staff.getShift() : "Morning (8:00 AM - 5:00 PM)")
                .avatarInitials(initials)
                .build();
    }

    private String getInitials(String name) {
        if (name == null || name.isBlank()) return "T";
        String[] parts = name.trim().split("\\s+");
        if (parts.length == 1) return String.valueOf(parts[0].charAt(0)).toUpperCase();
        return (String.valueOf(parts[0].charAt(0)) + String.valueOf(parts[parts.length - 1].charAt(0))).toUpperCase();
    }
}
