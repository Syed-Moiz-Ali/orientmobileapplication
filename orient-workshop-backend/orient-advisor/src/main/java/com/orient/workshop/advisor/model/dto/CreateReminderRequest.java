package com.orient.workshop.advisor.model.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @NoArgsConstructor @AllArgsConstructor
public class CreateReminderRequest {
    private String customerName;
    private String vehicleId;
    @NotBlank private String task;
    private String dueDate;
    private String priority;
}
