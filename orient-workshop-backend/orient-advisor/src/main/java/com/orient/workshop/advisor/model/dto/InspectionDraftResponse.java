package com.orient.workshop.advisor.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class InspectionDraftResponse {
    private String id;
    private String jobCardId;
    private String referenceNumber;
    private String placeOfSupply;
    private String customerRequests;
    private String garageRecommendations;
    private String estimatedDelivery;
    private Boolean notifyOwnerSmsEmail;
    private String tag;
    private Boolean isDraft;
    private Map<String, Map<String, Object>> sections;
}
