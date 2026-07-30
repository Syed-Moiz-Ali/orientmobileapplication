package com.orient.workshop.owner.model.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @NoArgsConstructor @AllArgsConstructor
public class MessageRequest {
    @NotBlank private String recipient;
    @NotBlank private String message;
}
