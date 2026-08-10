package com.orient.workshop.customer.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VehicleResponse {
    private String id;
    // P1 (V13): prefixed unique ref (VEH-000001) — the public identifier.
    private String ref;
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
