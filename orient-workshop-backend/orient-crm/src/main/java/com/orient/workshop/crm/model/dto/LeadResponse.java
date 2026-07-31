package com.orient.workshop.crm.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class LeadResponse {
    private String id;
    private int sno;
    private String leadNumber;
    private String customerName;
    private String phone;
    private String email;
    private String source;
    private String assignedTo;
    private String status;
    private String lastActivity;
    private String notes;
    private java.math.BigDecimal leadValue;
    private String followUpDate;
}
