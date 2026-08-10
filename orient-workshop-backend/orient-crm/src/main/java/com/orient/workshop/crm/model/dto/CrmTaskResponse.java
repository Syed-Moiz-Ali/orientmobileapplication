package com.orient.workshop.crm.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class CrmTaskResponse {
    private String id;
    // P1 (V13): prefixed unique ref (CT-000001).
    private String ref;
    private String title;
    private String assignedTo;
    private String dueDate;
    private String priority;
    private boolean isDone;
}
