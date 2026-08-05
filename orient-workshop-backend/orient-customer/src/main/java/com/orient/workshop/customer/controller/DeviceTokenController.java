package com.orient.workshop.customer.controller;

import io.swagger.v3.oas.annotations.tags.Tag;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.core.model.entity.DeviceToken;
import com.orient.workshop.core.repository.DeviceTokenMapper;
import com.orient.workshop.customer.model.dto.DeviceTokenRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Notifications")
@RestController
@RequestMapping("/notifications")
@RequiredArgsConstructor
public class DeviceTokenController {

    private final DeviceTokenMapper deviceTokenMapper;

    @PostMapping("/device-token")
    public ApiResponse<Void> registerToken(
            @RequestBody DeviceTokenRequest request,
            @AuthenticationPrincipal JwtUserPrincipal principal) {
        
        Long userId = principal != null ? principal.getUserId() : null;
        
        DeviceToken token = DeviceToken.builder()
                .userId(userId)
                .token(request.getToken())
                .platform(request.getPlatform())
                .build();
        deviceTokenMapper.insert(token);
        
        return ApiResponse.success(null);
    }
}
