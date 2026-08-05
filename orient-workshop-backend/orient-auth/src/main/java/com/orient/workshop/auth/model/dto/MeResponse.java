package com.orient.workshop.auth.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Unified session/profile payload returned by GET /auth/me.
 * Identifies the caller (from the JWT) and enriches it with the role-specific
 * record (staff / customer) and branch info, so clients can decide the
 * dashboard route from a single call.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MeResponse {

    private Long userId;
    private String name;
    private String phone;
    private String email;
    private String role;
    private Boolean isActive;

    private Long branchId;
    private String branchName;

    // Staff (advisor / supervisor / technician / owner via staff record)
    private Long staffId;
    private String empId;
    private String avatarInitials;
    private String shift;
    private String designation;
    private String department;

    // Customer
    private Long customerId;
    private String memberId;
}
