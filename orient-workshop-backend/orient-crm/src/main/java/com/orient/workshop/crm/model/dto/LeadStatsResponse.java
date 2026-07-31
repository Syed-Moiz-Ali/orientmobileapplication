package com.orient.workshop.crm.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class LeadStatsResponse {
    private long total;
    private long active;
    private long won;
    private long lost;
    private long unanswered;
    private BigDecimal totalValue;
    private BigDecimal wonValue;
    private double conversionRate;
    private List<PipelineStage> pipeline;

    @Data @Builder @NoArgsConstructor @AllArgsConstructor
    public static class PipelineStage {
        private String status;
        private long count;
        private BigDecimal value;
    }
}
