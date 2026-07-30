package com.orient.workshop.owner.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class DocumentExpiryResponse {
    private String empId;
    private String employeeName;
    private String designation;
    private String documentType;
    private String expiryDate;
    private int daysLeft;
    private String urgency;
}
