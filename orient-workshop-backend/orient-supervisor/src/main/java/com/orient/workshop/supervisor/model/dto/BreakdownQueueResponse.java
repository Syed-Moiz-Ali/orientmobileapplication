package com.orient.workshop.supervisor.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class BreakdownQueueResponse {
    private Long id;
    private String breakdownRef;
    private String customerName;
    private String phone;
    private String issue;
    private String vehicleName;
    private String vehiclePlate;
    private String location;
    private String status;
}
