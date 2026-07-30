package com.orient.workshop.owner.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class JobStatusResponse {
    private String jobCardId;
    private String customerName;
    private String vehicleInfo;
    private String assignedTo;
    private String createdDate;
    private String dueDate;
    private String stage;
    private double estimatedAmount;
}
