package com.orient.workshop.auth.model.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @NoArgsConstructor @AllArgsConstructor
public class ResetPasswordRequest {
    @NotBlank(message = "Type is required (sms or email)")
    private String type;

    private String phone;

    private String email;

    @NotBlank @Size(min = 6, max = 6)
    private String otp;

    @NotBlank @Size(min = 6)
    private String newPassword;
}
