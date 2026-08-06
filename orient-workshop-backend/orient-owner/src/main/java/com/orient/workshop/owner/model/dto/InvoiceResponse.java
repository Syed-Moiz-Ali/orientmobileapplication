package com.orient.workshop.owner.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class InvoiceResponse {
    private String id;
    private String customerName;
    private String date;
    private double amount;
    // P3: UAE VAT (server-computed).
    private double taxRate;
    private double taxAmount;
    private double grandTotal;
    private String status;
}
