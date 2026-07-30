package com.orient.workshop.owner.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class ArRecordResponse {
    private String arId;
    private String customer;
    private String invoiceDate;
    private String dueDate;
    private double amount;
    private double outstanding;
    private String aging;
    private String contactPerson;
    private String phone;
}
