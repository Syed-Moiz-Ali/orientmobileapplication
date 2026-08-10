package com.orient.workshop.technician.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class AttendanceResponse {
    // P1 (V13): prefixed unique ref (AT-000001).
    private String ref;
    private String status;
    private String punchIn;
    private String punchOut;
    private String breakTime;
    private String workHours;
}
