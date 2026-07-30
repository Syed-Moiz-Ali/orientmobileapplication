package com.orient.workshop.supervisor.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class WorkAssignmentResponse {
    private List<AssignmentResult> results;

    @Data @Builder @NoArgsConstructor @AllArgsConstructor
    public static class AssignmentResult {
        private String id;
        private String jobCard;
        private String status;
    }
}
