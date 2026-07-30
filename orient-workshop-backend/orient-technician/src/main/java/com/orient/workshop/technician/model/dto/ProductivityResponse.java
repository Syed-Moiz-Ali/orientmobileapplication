package com.orient.workshop.technician.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class ProductivityResponse {
    private int assignedJobs;
    private int inProgress;
    private int completedToday;
    private int efficiency;
    private String avgTimePerJob;
    private String totalHoursWorked;
}
