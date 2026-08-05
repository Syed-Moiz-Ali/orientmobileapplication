package com.orient.workshop.supervisor.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class AwaitingCompletionResponse {
    private Long jobCardId;
    private String jobCardRef;
    private String customerName;
    private String vehicleInfo;
    private String technician;
    private int done;
    private int total;
    private String updatedAt;
    private List<WorkItemDetail> items;

    @Data @Builder @NoArgsConstructor @AllArgsConstructor
    public static class WorkItemDetail {
        private Long id;
        private String taskRef;
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
}
