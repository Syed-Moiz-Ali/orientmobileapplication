package com.orient.workshop.advisor.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class PendingApprovalResponse {
    private String estimateId;
    private String customerName;
    private String vehicleId;
    private double amount;
    private String timeAgo;
}
