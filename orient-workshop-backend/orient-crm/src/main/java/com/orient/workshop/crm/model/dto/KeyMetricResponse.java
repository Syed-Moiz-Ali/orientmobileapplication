package com.orient.workshop.crm.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class KeyMetricResponse {
    private double winRate;
    private String avgResponseTime;
    private double satisfaction;
    private int roi;
}
