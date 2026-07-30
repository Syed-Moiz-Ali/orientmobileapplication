package com.orient.workshop.technician.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class TechnicianProfileResponse {
    private String name;
    private String empId;
    private String role;
    private String branch;
    private String shift;
    private String avatarInitials;
}
