package com.orient.workshop.owner.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OwnerAttendanceResponse {
    private Long staffId;
    private String empId;
    private String name;
    private String role;
    private Long branchId;
    private String branch;
    private LocalDate date;
    private String status;
    private String punchIn;
    private String punchOut;
    private String breakTime;
    private String workHours;
}
