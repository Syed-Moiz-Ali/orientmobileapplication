package com.orient.workshop.customer.model.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BreakdownRequest {
    // FIX (audit QA BUG-011): empty bodies previously hit the DB NOT NULL
    // constraint and surfaced as a confusing 409 instead of a clean 400.
    @NotBlank(message = "Issue is required")
    private String issue;
    private String vehicleId;
    private String vehicleName;
    private String vehiclePlate;
    private String location;
}
