package com.orient.workshop.advisor.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class CustomerApprovalSummaryResponse {
    private String estimateId;
    private String customerName;
    private Double amount;
    private String status;
    private String createdAt;
}
