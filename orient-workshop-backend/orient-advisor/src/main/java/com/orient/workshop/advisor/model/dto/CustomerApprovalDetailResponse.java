package com.orient.workshop.advisor.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class CustomerApprovalDetailResponse {
    private String estimateId;
    private String customerName;
    private String vehicleInfo;
    private Double servicesTotal;
    private Double partsTotal;
    private Double grandTotal;
    private String status;
    private String createdAt;
    private List<LineItem> services;
    private List<LineItem> parts;

    @Data @Builder @NoArgsConstructor @AllArgsConstructor
    public static class LineItem {
        private String name;
        private Integer qty;
        private Double rate;
        private Double discountPercent;
        private Double discountAmount;
    }
}
