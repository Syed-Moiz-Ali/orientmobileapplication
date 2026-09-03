package com.orient.workshop.advisor.model.dto;

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
public class CheckInRequest {
    private Long bookingId;
    private Integer odometer;
    private String fuelLevel;
    private String existingDamages;
    private String notes;
}
