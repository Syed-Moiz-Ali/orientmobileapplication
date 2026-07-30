package com.orient.workshop.advisor.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class RepairOrderRequest {
    private String jobCardId;
    private List<LineItem> services;
    private List<LineItem> parts;
    private Double servicesTotal;
    private Double partsTotal;
    private Double grandTotal;
    private String tag;
    private String customerRequests;
    private String garageRecommendations;
    private String estimatedDelivery;
    private Boolean notifyOwnerSmsEmail;

    @Data @Builder @NoArgsConstructor @AllArgsConstructor
    public static class LineItem {
        private String name;
        private Integer qty;
        private Double rate;
        private Double discountPercent;
        private Double discountAmount;
    }
}
