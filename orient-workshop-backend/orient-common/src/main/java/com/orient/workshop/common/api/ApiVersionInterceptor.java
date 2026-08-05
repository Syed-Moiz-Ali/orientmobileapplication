package com.orient.workshop.common.api;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * API version negotiation (see docs/API_VERSIONING.md).
 *
 * <p>URL versioning is handled by {@code server.servlet.context-path}
 * ({@code /api/v1} by default, overridable via {@code API_CONTEXT_PATH}).
 * This interceptor adds header-based negotiation on top of it: clients may
 * send {@code X-API-Version} (or {@code Accept: application/vnd.orient.vX+json})
 * to pin a version. Unsupported versions are rejected with 406 and the list
 * of supported versions.
 *
 * <p>No request is rejected when the header is absent — it defaults to the
 * current version, keeping all existing clients backward compatible.
 */
@Slf4j
@Component
public class ApiVersionInterceptor implements HandlerInterceptor {

    /** Canonical header name for explicit version pinning. */
    public static final String VERSION_HEADER = "X-API-Version";

    /** Supported media-range form: application/vnd.orient.v{version}+json */
    public static final String VND_MEDIA_PREFIX = "application/vnd.orient.v";

    private final List<String> supportedVersions;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public ApiVersionInterceptor(
            @Value("${app.api.supported-versions:1}") List<String> supportedVersions) {
        this.supportedVersions = List.copyOf(supportedVersions);
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws IOException {
        String requested = request.getHeader(VERSION_HEADER);
        if (requested == null || requested.isBlank()) {
            requested = extractFromAccept(request.getHeader("Accept"));
        }
        if (requested == null) {
            return true; // no explicit version -> current version, fully backward compatible
        }
        if (!supportedVersions.contains(requested.trim())) {
            log.warn("Unsupported API version requested: {}", requested.trim());
            response.setStatus(HttpServletResponse.SC_NOT_ACCEPTABLE);
            response.setContentType(MediaType.APPLICATION_JSON_VALUE);
            response.setCharacterEncoding(StandardCharsets.UTF_8.name());
            Map<String, Object> body = new LinkedHashMap<>();
            body.put("code", 406);
            body.put("message", "Unsupported API version '" + requested.trim()
                    + "'. Supported versions: " + supportedVersions);
            body.put("supportedVersions", supportedVersions);
            body.put("timestamp", System.currentTimeMillis());
            response.getWriter().write(objectMapper.writeValueAsString(body));
            return false;
        }
        return true;
    }

    /** Parses "Accept: application/vnd.orient.v2+json" -> "2". */
    private String extractFromAccept(String acceptHeader) {
        if (acceptHeader == null) return null;
        int idx = acceptHeader.indexOf(VND_MEDIA_PREFIX);
        if (idx < 0) return null;
        StringBuilder version = new StringBuilder();
        for (int i = idx + VND_MEDIA_PREFIX.length(); i < acceptHeader.length(); i++) {
            char c = acceptHeader.charAt(i);
            if (Character.isDigit(c)) {
                version.append(c);
            } else {
                break;
            }
        }
        return version.length() > 0 ? version.toString() : null;
    }
}
