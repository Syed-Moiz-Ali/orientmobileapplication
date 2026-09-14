package com.orient.workshop.advisor.model.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BatchTaskRequest {
    private String jobCardId;
    private List<TaskItem> tasks;
    private List<TaskItem> items;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TaskItem {
        private Long taskId;
        private String description;
        private String technicianEmpId;
        private Double estimatedHours;
        private String priority;
    }
}
