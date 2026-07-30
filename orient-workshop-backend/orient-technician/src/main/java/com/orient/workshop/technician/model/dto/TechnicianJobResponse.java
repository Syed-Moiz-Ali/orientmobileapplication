package com.orient.workshop.technician.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class TechnicianJobResponse {
    private String jobCardNo;
    private String dateOfWork;
    private String startTime;
    private String vehicleBrand;
    private String vehicleModel;
    private String plateNumber;
    private String status;
    private List<TaskResponse> tasks;
    private String notes;
}
