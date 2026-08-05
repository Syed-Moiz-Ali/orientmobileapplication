package com.orient.workshop.technician.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PartsRequestDto {
    private String jobCardRef;
    private String partName;
    private String partNumber;
    private Integer quantity;
    private String urgency;
    private String notes;
}
