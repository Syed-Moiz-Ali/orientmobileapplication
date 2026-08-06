package com.orient.workshop.owner.model.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @JsonIgnoreProperties(ignoreUnknown = true)
public class StaffMemberRequest {
    private String name;
    private String empId;
    private String role;
    private String phone;
    private Long branchId;
    private String branch;
    private String shift;
    private String designation;
    private String department;
    private Boolean isActive;
}
