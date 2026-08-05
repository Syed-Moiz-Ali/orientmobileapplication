package com.orient.workshop.supervisor.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class BookingQueueResponse {
    private Long id;
    private String bookingRef;
    private String customerName;
    private String phone;
    private String vehicleName;
    private String plateNumber;
    private String serviceType;
    private String bookingDate;
    private String notes;
    private String status;
}
