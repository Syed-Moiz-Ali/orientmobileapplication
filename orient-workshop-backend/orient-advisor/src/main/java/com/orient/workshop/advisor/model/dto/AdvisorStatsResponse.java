package com.orient.workshop.advisor.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class AdvisorStatsResponse {
    private int newJobCardsToday;
    private int inspectionsToday;
    private int pendingApprovals;
    private int vehiclesWaiting;
    private int readyForDelivery;
    private int totalOpenJobCards;
}
