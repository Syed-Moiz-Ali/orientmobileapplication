package com.orient.workshop.owner.controller;

import com.orient.workshop.auth.filter.ApiKeyFilter;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.core.model.entity.ApiKey;
import com.orient.workshop.core.repository.ApiKeyMapper;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.security.SecureRandom;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * P3 (audit): API key administration — server-to-server integrations.
 * The plaintext key is shown ONCE at creation; only its SHA-256 hash is stored.
 */
@Slf4j
@Tag(name = "Owner")
@RestController
@RequestMapping("/owner/api-keys")
@RequiredArgsConstructor
public class ApiKeyController {

    private static final Set<String> VALID_ROLES = Set.of("owner", "admin", "crmDashboard");
    private static final SecureRandom RANDOM = new SecureRandom();

    private final ApiKeyMapper apiKeyMapper;

    @GetMapping
    public ApiResponse<List<ApiKey>> list() {
        return ApiResponse.success(apiKeyMapper.findAllOrdered());
    }

    @PostMapping
    public ApiResponse<Map<String, Object>> create(@RequestParam String name,
                                                   @RequestParam(defaultValue = "owner") String role,
                                                   @AuthenticationPrincipal JwtUserPrincipal principal) {
        if (name == null || name.isBlank()) throw new BadRequestException("name is required");
        if (!VALID_ROLES.contains(role)) {
            throw new BadRequestException("Invalid role: " + role + ". Allowed: " + VALID_ROLES);
        }
        String raw = "orient_" + hex(16);
        String prefix = raw.substring(0, 12) + "…";
        ApiKey key = ApiKey.builder()
                .name(name.trim())
                .keyHash(ApiKeyFilter.hash(raw))
                .keyPrefix(prefix)
                .role(role)
                .isActive(true)
                .createdBy(principal != null ? principal.getUserId() : null)
                .build();
        apiKeyMapper.insert(key);
        log.info("API key '{}' created (prefix {}) by user {}", name, prefix,
                principal != null ? principal.getUserId() : "api");
        return ApiResponse.success(Map.of(
                "id", String.valueOf(key.getId()),
                "name", key.getName(),
                "key", raw,               // shown once
                "prefix", key.getKeyPrefix()
        ));
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Map<String, Object>> revoke(@PathVariable Long id) {
        ApiKey key = apiKeyMapper.selectById(id);
        if (key == null) throw new NotFoundException("API key not found: " + id);
        key.setIsActive(false);
        apiKeyMapper.updateById(key);
        return ApiResponse.success(Map.of("revoked", key.getKeyPrefix()));
    }

    private static String hex(int bytes) {
        StringBuilder sb = new StringBuilder(bytes * 2);
        for (int i = 0; i < bytes; i++) {
            sb.append(String.format("%02x", RANDOM.nextInt(256)));
        }
        return sb.toString();
    }
}
