package com.orient.workshop.customer.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DeviceTokenRequest {
    @NotBlank
    private String token;
    @NotBlank
    @Pattern(regexp = "android|ios", flags = Pattern.Flag.CASE_INSENSITIVE)
    private String platform;
}
