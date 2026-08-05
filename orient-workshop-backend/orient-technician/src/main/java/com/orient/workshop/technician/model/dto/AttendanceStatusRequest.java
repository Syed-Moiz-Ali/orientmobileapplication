package com.orient.workshop.technician.model.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @NoArgsConstructor @AllArgsConstructor
public class AttendanceStatusRequest {
    private String empId;
    private String status;
}
