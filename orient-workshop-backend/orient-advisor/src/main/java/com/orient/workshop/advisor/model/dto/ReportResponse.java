package com.orient.workshop.advisor.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class ReportResponse {
    private int totalJobs;
    private int completedJobs;
    private int inProgressJobs;
    private int cancelledJobs;
    private List<ActivityDto> weeklyActivity;
    private List<StatusBreakdownDto> statusBreakdown;

    @Data @Builder @NoArgsConstructor @AllArgsConstructor
    public static class ActivityDto {
        private String day;
        private int count;
    }

    @Data @Builder @NoArgsConstructor @AllArgsConstructor
    public static class StatusBreakdownDto {
        private String status;
        private int count;
        private double percentage;
    }
}
