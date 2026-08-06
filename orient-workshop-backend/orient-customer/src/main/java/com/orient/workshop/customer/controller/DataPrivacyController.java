package com.orient.workshop.customer.controller;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.customer.service.DataPrivacyService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Tag(name = "Customer Portal")
@RestController
@RequestMapping("/customers/data")
@RequiredArgsConstructor
public class DataPrivacyController {

    private final DataPrivacyService privacyService;

    /**
     * P3 (audit): PDPL/GDPR data-subject export — everything we hold.
     */
    @GetMapping("/export")
    public ApiResponse<Map<String, Object>> export(@AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(privacyService.export(principal));
    }

    /**
     * P3 (audit): PDPL/GDPR erasure — deletes personal data and anonymises the
     * customer record (financial records retained for accounting).
     */
    @DeleteMapping
    public ApiResponse<Map<String, String>> erase(@AuthenticationPrincipal JwtUserPrincipal principal) {
        privacyService.erase(principal);
        return ApiResponse.success(Map.of("erased", "true"));
    }
}
