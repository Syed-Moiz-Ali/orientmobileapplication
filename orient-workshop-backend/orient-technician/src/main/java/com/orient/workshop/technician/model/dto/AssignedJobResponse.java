package com.orient.workshop.technician.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class AssignedJobResponse {
    private String id;
    private String customerName;
    private String customerPhone;
    private String customerEmail;
    private String vehicle;
    private String plateNumber;
    private String service;
    private String amount;
    private String status;
}
