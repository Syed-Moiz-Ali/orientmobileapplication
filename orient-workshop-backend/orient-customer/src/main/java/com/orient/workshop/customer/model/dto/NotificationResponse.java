package com.orient.workshop.customer.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationResponse {
    private String id;
    // P1 (V13): prefixed unique ref (NTF-000001).
    private String ref;
    private String title;
    private String body;
    private String time;
    private String type;
    private boolean isRead;
}
