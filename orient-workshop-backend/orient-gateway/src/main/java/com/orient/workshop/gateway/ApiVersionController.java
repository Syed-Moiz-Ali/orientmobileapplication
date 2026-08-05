package com.orient.workshop.gateway;

import com.orient.workshop.common.api.ApiVersionInterceptor;
import com.orient.workshop.common.response.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Public API version metadata (see docs/API_VERSIONING.md).
 * GET /api/v1/version -> current URL version, supported versions and the
 * negotiation header contract.
 */
@Tag(name = "Version")
@RestController
@RequestMapping("/version")
@RequiredArgsConstructor
public class ApiVersionController {

    @Value("${app.api.version:1}")
    private String currentVersion;

    @Value("${app.api.supported-versions:1}")
    private List<String> supportedVersions;

    @GetMapping
    public ApiResponse<Map<String, Object>> version() {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("apiVersion", currentVersion);
        data.put("supportedVersions", supportedVersions);
        data.put("urlPrefix", "/api/v" + currentVersion);
        data.put("negotiationHeader", ApiVersionInterceptor.VERSION_HEADER);
        data.put("mediaRange", "application/vnd.orient.v{version}+json");
        data.put("defaultWhenAbsent", currentVersion);
        return ApiResponse.success(data);
    }
}
