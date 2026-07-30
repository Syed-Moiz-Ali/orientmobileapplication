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
public class ActiveServiceResponse {
    private String jobCardId;
    private String plateNumber;
    private String vehicleName;
    private String service;
    private String started;
    private String estCompletion;
    private int progressPercent;
    private String currentStage;
    private String technicianName;
    private List<ServiceStageDto> stages;
}
