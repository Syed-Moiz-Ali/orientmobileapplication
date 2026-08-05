package com.orient.workshop.supervisor.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class AssignableStaffResponse {
    private Long id;
    private String name;
    private String empId;
    private String role;

    public static List<AssignableStaffResponse> ofList(java.util.Collection<com.orient.workshop.core.model.entity.Staff> staffList) {
        return staffList.stream().map(s -> AssignableStaffResponse.builder()
                .id(s.getId())
                .name(s.getName())
                .empId(s.getEmpId())
                .role(s.getRole())
                .build()).toList();
    }
}
