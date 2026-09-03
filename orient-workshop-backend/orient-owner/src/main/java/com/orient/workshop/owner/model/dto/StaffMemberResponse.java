package com.orient.workshop.owner.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/** Owner-facing staff record enriched with credentials stored on the linked user. */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StaffMemberResponse {
    private Long id;
    private Long userId;
    private String empId;
    private String name;
    private String role;
    private String email;
    private String phone;
    private Long branchId;
    private String branch;
    private String shift;
    private String designation;
    private String department;
    private String avatarInitials;
    private Boolean isActive;
}
