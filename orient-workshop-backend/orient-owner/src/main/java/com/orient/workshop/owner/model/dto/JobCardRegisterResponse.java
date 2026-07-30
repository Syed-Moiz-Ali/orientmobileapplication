package com.orient.workshop.owner.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class JobCardRegisterResponse {
    private String label;
    private int open;
    private int completed;
    private int total;
}
