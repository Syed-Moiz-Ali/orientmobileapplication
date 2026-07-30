package com.orient.workshop.supervisor.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class AssignedJobResponse {
    private String jobCard;
    private String customer;
    private String vehicle;
    private String dateAssigned;
    private int done;
    private int total;
    private String status;
}
