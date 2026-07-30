package com.orient.workshop.advisor.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class JobCardDetailResponse {
    private String id;
    private String customerName;
    private String vehicleInfo;
    private String time;
    private String createdDate;
    private String lastUpdated;
    private String status;
    private String technician;
    private String notes;
    private String tag;
    private String customerRequests;
    private String garageRecommendations;
    private String estimatedDelivery;
}
