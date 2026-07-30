package com.orient.workshop.owner.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class ArSummaryResponse {
    private long totalOutstanding;
    private long days0to30;
    private long days31to60;
    private long days61to90;
    private long days90plus;
}
