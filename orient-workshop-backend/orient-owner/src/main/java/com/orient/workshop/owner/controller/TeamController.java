package com.orient.workshop.owner.controller;

import com.orient.workshop.auth.model.entity.User;
import com.orient.workshop.auth.repository.UserMapper;
import com.orient.workshop.auth.service.PasswordService;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.common.util.PhoneUtil;
import com.orient.workshop.core.model.entity.Staff;
import com.orient.workshop.core.repository.StaffMapper;
import com.orient.workshop.owner.model.dto.StaffMemberRequest;
import com.orient.workshop.owner.model.dto.StaffMemberResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.function.Function;
import java.util.stream.Collectors;
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

    private static final Set<String> VALID_ROLES = Set.of("advisor", "supervisor", "technician");

    private final StaffMapper staffMapper;
    private final UserMapper userMapper;
    private final PasswordService passwordService;

    @GetMapping
    public ApiResponse<List<StaffMemberResponse>> listStaff() {
        List<Staff> staff = staffMapper.selectList(null);
        Set<Long> userIds = staff.stream()
                .map(Staff::getUserId)
                .filter(java.util.Objects::nonNull)
                .collect(Collectors.toSet());
        Map<Long, User> usersById = userIds.isEmpty()
                ? Collections.emptyMap()
                : userMapper.selectBatchIds(userIds).stream()
                        .collect(Collectors.toMap(User::getId, Function.identity()));
        return ApiResponse.success(staff.stream()
                .map(member -> toResponse(member, usersById.get(member.getUserId())))
                .toList());
    }

    @Transactional
    @PostMapping
    public ApiResponse<StaffMemberResponse> createStaff(@RequestBody StaffMemberRequest req) {
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

        if (req.getPhone() == null || req.getPhone().isBlank()) {
            throw new BadRequestException("Mobile number is required for staff login");
        }
        String normalizedPhone = PhoneUtil.normalize(req.getPhone());
        if (!PhoneUtil.isValid(normalizedPhone)) {
            throw new BadRequestException("Invalid mobile number");
        }
        if (req.getEmail() == null || req.getEmail().isBlank() || !req.getEmail().contains("@")) {
            throw new BadRequestException("A valid email is required for staff login");
        }
        String normalizedEmail = req.getEmail().trim().toLowerCase();
        if (req.getPassword() == null || req.getPassword().length() < PasswordService.MIN_PASSWORD_LENGTH) {
            throw new BadRequestException(
                    "Password must be at least " + PasswordService.MIN_PASSWORD_LENGTH + " characters");
        }
        if (userMapper.findByPhone(normalizedPhone).isPresent()) {
            throw new BadRequestException("Mobile number is already linked to another account");
        }
        if (userMapper.findByEmail(normalizedEmail).isPresent()) {
            throw new BadRequestException("Email is already linked to another account");
        }

        // Owner-provisioned staff can use the same sign-in options exposed by
        // staff_app: password with email/phone, or OTP with email/phone.
        User linkedUser = User.builder()
                .phone(normalizedPhone)
                .email(normalizedEmail)
                .passwordHash(passwordService.hash(req.getPassword()))
                .name(req.getName().trim())
                .role(role)
                .branchId(req.getBranchId() != null && req.getBranchId() > 0 ? req.getBranchId() : null)
                .isActive(true)
                .build();
        userMapper.insert(linkedUser);

        Staff staff = Staff.builder()
                .empId(req.getEmpId().trim())
                .userId(linkedUser.getId())
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
                linkedUser.getId());
        return ApiResponse.success(toResponse(staff, linkedUser));
    }

    @Transactional
    @PutMapping("/{id}")
    public ApiResponse<StaffMemberResponse> updateStaff(@PathVariable Long id, @RequestBody StaffMemberRequest req) {
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
        if (staff.getUserId() != null && req.getIsActive() != null) {
            User user = userMapper.selectById(staff.getUserId());
            if (user != null) {
                user.setIsActive(req.getIsActive());
                userMapper.updateById(user);
            }
        }
        User linkedUser = staff.getUserId() != null ? userMapper.selectById(staff.getUserId()) : null;
        return ApiResponse.success(toResponse(staff, linkedUser));
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

    private StaffMemberResponse toResponse(Staff staff, User user) {
        return StaffMemberResponse.builder()
                .id(staff.getId())
                .userId(staff.getUserId())
                .empId(staff.getEmpId())
                .name(staff.getName())
                .role(staff.getRole())
                .email(user != null ? user.getEmail() : null)
                .phone(user != null ? user.getPhone() : null)
                .branchId(staff.getBranchId())
                .branch(staff.getBranch())
                .shift(staff.getShift())
                .designation(staff.getDesignation())
                .department(staff.getDepartment())
                .avatarInitials(staff.getAvatarInitials())
                .isActive(staff.getIsActive())
                .build();
    }
}
