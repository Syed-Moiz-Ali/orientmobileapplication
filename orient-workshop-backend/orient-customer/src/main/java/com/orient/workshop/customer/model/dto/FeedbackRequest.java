package com.orient.workshop.customer.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class FeedbackRequest {
    private Long jobCardId;
    private Integer rating; // Kept for backwards compatibility
    // FIX (audit QA BUG-029): the customer app sends `overall`; accept it as an
    // alias for overallRating so submissions actually succeed.
    private Integer overall;
    private Integer overallRating;
    private Integer workQuality;
    private Integer communication;
    private Integer timeliness;
    private Integer valueForMoney;
    private Boolean wouldRecommend;
    private String comment;
    private Boolean isPublic;
}
