package com.orient.workshop.supervisor.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class WorkAssignmentRequest {
    private List<AssignmentItem> items;

    @Data @Builder @NoArgsConstructor @AllArgsConstructor
    public static class AssignmentItem {
        private String jobCardId;
        private String description;
        private String department;
        private String technicianName;
        private String dateOfWork;
        private Integer statusPercent;
        private String stdTime;
        private String remarks;
    }
}
