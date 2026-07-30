package com.orient.workshop.customer.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateBookingRequest {
    private String vehicleId;
    private String vehicleName;
    private String plateNumber;
    private String serviceType;
    private String bookingDate;
    private String notes;
}
