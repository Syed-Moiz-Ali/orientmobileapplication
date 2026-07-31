package com.orient.workshop.crm.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class FollowUpResponse {
    private String leadId;
    private String leadNumber;
    private String customerName;
    private String phone;
    private String source;
    private String assignedTo;
    private String status;
    private String followUpDate;
    private String leadValue;
}
