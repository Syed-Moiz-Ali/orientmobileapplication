package com.orient.workshop.advisor.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class InspectionRequest {
    private String type;
    private String status;
    private String createdDate;
    private String lastUpdated;
    private String technician;
    private CustomerInfo customer;
    private VehicleInfo vehicle;
    private AdditionalInfo additional;
    private String jobCardId;
    private String referenceNumber;
    private String placeOfSupply;
    private String customerRequests;
    private String garageRecommendations;
    private String estimatedDelivery;
    private Boolean notifyOwnerSmsEmail;
    private String tag;
    private Map<String, Map<String, Object>> sections;

    @Data @Builder @NoArgsConstructor @AllArgsConstructor
    public static class CustomerInfo {
        private Boolean isB2B;
        private String customerName;
        private String phoneNumber;
        private String email;
        private String customerGroup;
        private java.util.List<String> tags;
        private String gender;
        private String address;
        private String taxNumber;
        private String groupTaxNumber;
        private String occupation;
        private String organisation;
        private String source;
    }

    @Data @Builder @NoArgsConstructor @AllArgsConstructor
    public static class VehicleInfo {
        private String registrationNumber;
        private String vin;
        private String make;
        private String model;
        private Integer modelYear;
        private String purchaseDate;
        private Integer cylinders;
        private String engineCapacity;
        private String vehicleColor;
        private String engineNumber;
        private String insuranceProvider;
        private String insuranceTaxNumber;
        private String insuranceAddress;
        private String policyNumber;
        private String insuranceExpiryDate;
    }

    @Data @Builder @NoArgsConstructor @AllArgsConstructor
    public static class AdditionalInfo {
        private String odometerReading;
        private Integer fuelLevel;
        private Boolean customerConsent;
    }
}
