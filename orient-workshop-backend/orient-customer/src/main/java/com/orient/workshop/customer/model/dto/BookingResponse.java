package com.orient.workshop.customer.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BookingResponse {
    // FE-FIX (frontend pass): expose the id so the app can cancel/reference
    // a specific booking (the customer app needs it for Cancel Booking).
    private Long id;
    // P1 (V13): prefixed unique ref (BK-...) — the public identifier.
    private String bookingRef;
    private String service;
    private String vehicleName;
    private String plateNumber;
    private String date;
    private String time;
    private String status;
}
