package com.orient.workshop.advisor.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class AdvisorTechnicianResponse {
    private Long id;
    private String name;
    private String empId;
}
