package com.orient.workshop.supervisor.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class StaffNotificationResponse {
    private String id;
    private String title;
    private String body;
    private String time;
    private String type;
    private Boolean isRead;
}
