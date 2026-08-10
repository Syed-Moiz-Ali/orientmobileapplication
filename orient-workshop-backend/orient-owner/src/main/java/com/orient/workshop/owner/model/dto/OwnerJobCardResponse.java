package com.orient.workshop.owner.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class OwnerJobCardResponse {
    private String id;
    // P1 (V13): prefixed unique ref (JC-...).
    private String jobCardRef;
    private String customerName;
    private String vehicle;
    private String plateNumber;
    private String services;
    private String technician;
    private String estCompletion;
    private double amount;
    private String status;
}
