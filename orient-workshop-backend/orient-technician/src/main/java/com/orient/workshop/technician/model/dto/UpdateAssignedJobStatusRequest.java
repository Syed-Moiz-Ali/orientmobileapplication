package com.orient.workshop.technician.model.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @NoArgsConstructor @AllArgsConstructor
public class UpdateAssignedJobStatusRequest {
    @NotBlank private String empId;
    private String status;
}
