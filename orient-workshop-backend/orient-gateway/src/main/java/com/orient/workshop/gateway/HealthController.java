package com.orient.workshop.gateway;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@Tag(name = "System")
@RestController
public class HealthController {

    @GetMapping("/health")
    public ApiResponse<Map<String, Object>> health() {
        return ApiResponse.success(Map.of(
                "status", "UP",
                "service", "orient-workshop-backend",
                "version", "1.0.0-SNAPSHOT"
        ));
    }

    @GetMapping("/debug/principal")
    public ApiResponse<Map<String, Object>> debug(@AuthenticationPrincipal JwtUserPrincipal principal) {
        if (principal == null) {
            return ApiResponse.success(Map.of("principal", "null"));
        }
        return ApiResponse.success(Map.of(
                "userId", String.valueOf(principal.getUserId()),
                "phone", principal.getPhone(),
                "role", principal.getRole(),
                "branchId", String.valueOf(principal.getBranchId())
        ));
    }
}

