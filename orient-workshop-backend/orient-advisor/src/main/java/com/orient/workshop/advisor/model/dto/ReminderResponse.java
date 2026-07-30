package com.orient.workshop.advisor.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class ReminderResponse {
    private String id;
    private String customerName;
    private String vehicleId;
    private String task;
    private String dueDate;
    private String priority;
}
