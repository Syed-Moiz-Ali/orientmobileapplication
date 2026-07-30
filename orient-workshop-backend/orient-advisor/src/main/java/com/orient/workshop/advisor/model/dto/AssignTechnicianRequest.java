package com.orient.workshop.advisor.model.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @NoArgsConstructor @AllArgsConstructor
public class AssignTechnicianRequest {
    @NotBlank private String technician;
}
