package com.orient.workshop.whatsapp.model.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class SendMessageRequest {
    @NotBlank private String customerPhone;
    private String templateName;
    private String message;
}
