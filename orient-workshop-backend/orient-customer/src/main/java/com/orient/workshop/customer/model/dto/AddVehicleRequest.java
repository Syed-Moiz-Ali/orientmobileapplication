package com.orient.workshop.customer.model.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.validation.constraints.NotBlank;
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
    // FIX (audit QA BUG-011): empty bodies created junk vehicle rows.
    @NotBlank(message = "Brand is required")
    private String brand;
    private String model;
    @NotBlank(message = "Plate number is required")
    private String plateNumber;
    private String vin;
    private String color;
    private int year;
    private String mileage;
    private String lastService;
    private String nextDue;
    private int healthScore;
}
