package com.orient.workshop.technician.model.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @NoArgsConstructor @AllArgsConstructor
public class PunchOutRequest {
    @NotBlank private String empId;
    private String status;
    private String punchIn;
    private String punchOut;
    private String breakTime;
    private String workHours;
    private String date;
}
