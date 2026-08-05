package com.orient.workshop.core.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class WorkItemActionRequest {
    private String status;
    private String startTime;
    private String endTime;
    private String notes;
}
