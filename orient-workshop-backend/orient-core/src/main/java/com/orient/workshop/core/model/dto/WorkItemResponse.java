package com.orient.workshop.core.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class WorkItemResponse {
    private Long id;
    private String taskRef;
    private String jobCardRef;
    private String description;
    private String itemType;
    private String status;
    private String empId;
    private String empName;
    private String startTime;
    private String endTime;
    private Integer qty;
    private Double rate;
    private String rejectReason;
}
