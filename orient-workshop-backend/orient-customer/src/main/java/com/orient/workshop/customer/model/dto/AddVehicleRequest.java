package com.orient.workshop.customer.model.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class AddVehicleRequest {
    private String brand;
    private String model;
    private String plateNumber;
    private String vin;
    private String color;
    private int year;
    private String mileage;
    private String lastService;
    private String nextDue;
    private int healthScore;
}
