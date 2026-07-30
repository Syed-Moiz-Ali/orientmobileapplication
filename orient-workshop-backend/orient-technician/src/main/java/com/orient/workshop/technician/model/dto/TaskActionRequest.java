package com.orient.workshop.technician.model.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @NoArgsConstructor @AllArgsConstructor
public class TaskActionRequest {
    private String startTime;
    private String endTime;
    private String status;
}
