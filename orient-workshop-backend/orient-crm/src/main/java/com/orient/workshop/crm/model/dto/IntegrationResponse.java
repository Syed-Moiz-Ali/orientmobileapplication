package com.orient.workshop.crm.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class IntegrationResponse {
    private String name;
    private boolean connected;
    private LocalDateTime lastSyncAt;
    private String syncStatus;
    private long leadCount;
}
