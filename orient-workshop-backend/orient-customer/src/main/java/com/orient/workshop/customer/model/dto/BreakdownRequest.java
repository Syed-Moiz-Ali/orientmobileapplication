package com.orient.workshop.customer.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BreakdownRequest {
    private String issue;
    private String vehicleId;
    private String vehicleName;
    private String vehiclePlate;
    private String location;
}
