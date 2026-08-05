package com.orient.workshop.customer.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class FeedbackRequest {
    private Long jobCardId;
    private Integer rating;
    private String comment;
    private Boolean isPublic;
}
