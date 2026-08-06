package com.orient.workshop.owner.controller;

import com.orient.workshop.auth.model.entity.User;
import com.orient.workshop.auth.repository.UserMapper;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.common.util.PhoneUtil;
import com.orient.workshop.core.model.entity.Staff;
import com.orient.workshop.core.repository.StaffMapper;
import com.orient.workshop.owner.model.dto.StaffMemberRequest;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * P3 (audit): staff/role administration — the missing admin flow that the
 * OTP-role-removal promised. Owners can list staff, create staff accounts
 * (linked to a user login via OTP), change roles/branches, and deactivate.
 */
@Slf4j
@Tag(name = "Owner")
@RestController
@RequestMapping("/owner/team")
@RequiredArgsConstructor
public class TeamController {

    private static final Set<String> VALID_ROLES = Set.of("advisor", "supervisor", "technician", "sales");

    private final StaffMapper staffMapper;
    private final UserMapper userMapper;

    @GetMapping
    public ApiResponse<List<Staff>> listStaff() {
        return ApiResponse.success(staffMapper.selectList(null));
    }

    @Transactional
    @PostMapping
    public ApiResponse<Staff> createStaff(@RequestBody StaffMemberRequest req) {
        if (req.getName() == null || req.getName().isBlank()) {
            throw new BadRequestException("Staff name is required");
        }
        if (req.getEmpId() == null || req.getEmpId().isBlank()) {
            throw new BadRequestException("empId is required");
        }
        String role = req.getRole() != null ? req.getRole().toLowerCase() : "advisor";
        if (!VALID_ROLES.contains(role)) {
            throw new BadRequestException("Invalid role: " + role + ". Allowed: " + VALID_ROLES);
        }
        if (staffMapper.findByEmpId(req.getEmpId().trim()).isPresent()) {
            throw new BadRequestException("empId already exists: " + req.getEmpId());
        }

        // Link a user account so the staff member can log in via OTP with their
        // phone. The role is set server-side from this admin action only.
        User linkedUser = null;
        if (req.getPhone() != null && !req.getPhone().isBlank()) {
            String normalized = PhoneUtil.normalize(req.getPhone());
            linkedUser = userMapper.findByPhone(normalized).orElseGet(() -> {
                User nu = User.builder()
                        .phone(normalized)
                        .name(req.getName().trim())
                        .role(role)
                        .build();
                userMapper.insert(nu);
                return nu;
            });
            // OTP login would otherwise keep a customer role — align it.
            linkedUser.setRole(role);
            if (linkedUser.getName() == null || linkedUser.getName().isBlank()) {
                linkedUser.setName(req.getName().trim());
            }
            userMapper.updateById(linkedUser);
        }

        Staff staff = Staff.builder()
                .empId(req.getEmpId().trim())
                .userId(linkedUser != null ? linkedUser.getId() : null)
                .name(req.getName().trim())
                .role(role)
                .branchId(req.getBranchId() != null && req.getBranchId() > 0 ? req.getBranchId() : null)
                .branch(req.getBranch() != null ? req.getBranch() : "")
                .shift(req.getShift() != null ? req.getShift() : "")
                .designation(req.getDesignation() != null ? req.getDesignation() : "")
                .department(req.getDepartment() != null ? req.getDepartment() : "")
                .isActive(true)
                .build();
        staffMapper.insert(staff);
        log.info("Staff created: {} ({}), role {}, linked user {}",
                staff.getName(), staff.getEmpId(), role,
                linkedUser != null ? linkedUser.getId() : "none");
        return ApiResponse.success(staff);
    }

    @Transactional
    @PutMapping("/{id}")
    public ApiResponse<Staff> updateStaff(@PathVariable Long id, @RequestBody StaffMemberRequest req) {
        Staff staff = staffMapper.selectById(id);
        if (staff == null) throw new NotFoundException("Staff not found: " + id);

        if (req.getName() != null && !req.getName().isBlank()) staff.setName(req.getName().trim());
        if (req.getRole() != null && !req.getRole().isBlank()) {
            String role = req.getRole().toLowerCase();
            if (!VALID_ROLES.contains(role)) {
                throw new BadRequestException("Invalid role: " + role + ". Allowed: " + VALID_ROLES);
            }
            staff.setRole(role);
            // Keep the linked user's role in sync (it gates the JWT authorities).
            if (staff.getUserId() != null) {
                User user = userMapper.selectById(staff.getUserId());
                if (user != null) {
                    user.setRole(role);
                    userMapper.updateById(user);
                }
            }
        }
        if (req.getBranchId() != null && req.getBranchId() > 0) staff.setBranchId(req.getBranchId());
        if (req.getBranch() != null) staff.setBranch(req.getBranch());
        if (req.getShift() != null) staff.setShift(req.getShift());
        if (req.getDesignation() != null) staff.setDesignation(req.getDesignation());
        if (req.getDepartment() != null) staff.setDepartment(req.getDepartment());
        if (req.getIsActive() != null) staff.setIsActive(req.getIsActive());
        staffMapper.updateById(staff);
        return ApiResponse.success(staff);
    }

    @Transactional
    @PutMapping("/{id}/deactivate")
    public ApiResponse<Map<String, Object>> deactivate(@PathVariable Long id) {
        Staff staff = staffMapper.selectById(id);
        if (staff == null) throw new NotFoundException("Staff not found: " + id);
        staff.setIsActive(false);
        staffMapper.updateById(staff);
        // The JWT filter re-checks users.is_active each request — deactivating
        // the linked user kills their sessions immediately.
        if (staff.getUserId() != null) {
            User user = userMapper.selectById(staff.getUserId());
            if (user != null) {
                user.setIsActive(false);
                userMapper.updateById(user);
            }
        }
        log.info("Staff {} deactivated (user {})", staff.getEmpId(), staff.getUserId());
        return ApiResponse.success(Map.of("deactivated", staff.getEmpId()));
    }
}
