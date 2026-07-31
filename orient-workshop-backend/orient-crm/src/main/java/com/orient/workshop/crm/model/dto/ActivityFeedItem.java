package com.orient.workshop.crm.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class ActivityFeedItem {
    private String id;
    private String leadId;
    private String customerName;
    private String action;
    private String detail;
    private String createdAt;
}
