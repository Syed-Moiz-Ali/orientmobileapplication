package com.orient.workshop.technician.model.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data @NoArgsConstructor @AllArgsConstructor
public class CompleteJobRequest {
    private String jobCardNo;
    private String empId;
    private String status;
    private List<TaskCompletion> tasks;
    private String notes;

    @Data @NoArgsConstructor @AllArgsConstructor
    public static class TaskCompletion {
        private String id;
        private String status;
        private String startTime;
        private String endTime;
    }
}
