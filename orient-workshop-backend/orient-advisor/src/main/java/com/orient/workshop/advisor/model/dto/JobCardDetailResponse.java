package com.orient.workshop.advisor.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class JobCardDetailResponse {
    private String id;
    private Long dbId;
    private String customerName;
    private String phoneNumber;
    private String email;
    private String customerGroup;
    private String vehicleInfo;
    private String registrationNumber;
    private String vin;
    private String make;
    private String model;
    private String modelYear;
    private String vehicleColor;
    private String mileage;
    private String time;
    private String createdDate;
    private String lastUpdated;
    private String status;
    private String technician;
    private String notes;
    private Integer odometer;
    private String fuelLevel;
    private String tag;
    private String customerRequests;
    private String garageRecommendations;
    private String estimatedDelivery;
}
