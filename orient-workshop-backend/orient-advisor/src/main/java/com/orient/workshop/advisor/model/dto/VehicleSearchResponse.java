package com.orient.workshop.advisor.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class VehicleSearchResponse {
    private String regNo;
    private String vin;
    private String make;
    private String model;
    private String plateNumber;
    private String customerName;
    private String phone;
    private String email;
    private String emirate;
    private String plateCode;
}
