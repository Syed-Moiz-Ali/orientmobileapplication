package com.orient.workshop.crm.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class ConversationResponse {
    private String id;
    private String customerName;
    private String lastMessage;
    private String time;
    private String channel;
    private int unread;
    private String status;
}
