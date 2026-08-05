package com.orient.workshop.customer.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BookingAvailabilityResponse {
    private String date;
    private String serviceType;
    private List<String> availableSlots;
    private List<String> bookedSlots;
    private int workshopCapacity;
    private int bookedCount;
}
