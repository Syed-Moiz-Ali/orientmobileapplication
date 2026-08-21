package com.orient.workshop.sync.filter;

import com.orient.workshop.sync.model.entity.IdempotencyRecord;
import com.orient.workshop.sync.repository.IdempotencyKeyMapper;
import com.orient.workshop.sync.service.IdempotencyScope;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.annotation.Order;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.util.ContentCachingResponseWrapper;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.Optional;

/**
 * H-6: idempotency for write requests (POST/PUT/PATCH) carrying an Idempotency-Key.
 *
 * - /auth/** and /media/** are excluded entirely (never cache credentials/media).
 * - Keys are stored as a SHA-256 hash of user + branch + method + path + key,
 *   never the raw value.
 * - Lookups respect the TTL (7 days by default).
 * - Insert is atomic: the unique index on idempotency_key resolves races; a
 *   duplicate insert replays the already-stored response instead of re-executing.
 * - Error responses (4xx/5xx) are never cached, so a retry actually retries.
 */
@Slf4j
@Component
@Order(1)
public class IdempotencyFilter implements Filter {

    private final IdempotencyKeyMapper idempotencyKeyMapper;

    /** TTL for stored idempotent responses, in days (app.sync.idempotency-ttl-days). */
    private final int ttlDays;

    public IdempotencyFilter(IdempotencyKeyMapper idempotencyKeyMapper,
                             @Value("${app.sync.idempotency-ttl-days:7}") int ttlDays) {
        this.idempotencyKeyMapper = idempotencyKeyMapper;
        this.ttlDays = ttlDays;
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpReq = (HttpServletRequest) request;
        String idempotencyKey = httpReq.getHeader("Idempotency-Key");

        if (idempotencyKey == null || idempotencyKey.isBlank()
                || !isWritableMethod(httpReq.getMethod())
                || isExcludedPath(httpReq)) {
            chain.doFilter(request, response);
            return;
        }

        JwtUserPrincipal principal = currentPrincipal();
        String hashedKey = IdempotencyScope.scopedHash(
                principal,
                httpReq.getMethod(),
                httpReq.getRequestURI().substring(httpReq.getContextPath().length()),
                idempotencyKey,
                branchId(principal, httpReq));
        LocalDateTime cutoff = LocalDateTime.now().minusDays(ttlDays);

        Optional<IdempotencyRecord> existing = idempotencyKeyMapper.findByKeyWithinTtl(hashedKey, cutoff);
        if (existing.isPresent()) {
            replay(existing.get(), (HttpServletResponse) response);
            return;
        }

        ContentCachingResponseWrapper responseWrapper =
                new ContentCachingResponseWrapper((HttpServletResponse) response);
        chain.doFilter(request, responseWrapper);

        int status = responseWrapper.getStatus();
        byte[] body = responseWrapper.getContentAsByteArray();

        // Never cache error responses: a failed request must be retryable.
        if (status >= 200 && status < 400) {
            String responseBody = body.length > 0 ? new String(body, StandardCharsets.UTF_8) : null;
            try {
                idempotencyKeyMapper.insert(IdempotencyRecord.builder()
                        .idempotencyKey(hashedKey)
                        .responseBody(responseBody)
                        .httpStatus(status)
                        .build());
            } catch (DuplicateKeyException e) {
                // Concurrent request with the same key won the race — replay its result.
                IdempotencyRecord winner = idempotencyKeyMapper.findByKeyWithinTtl(hashedKey, cutoff).orElse(null);
                if (winner != null) {
                    responseWrapper.resetBuffer();
                    replay(winner, responseWrapper);
                }
                responseWrapper.copyBodyToResponse();
                return;
            }
        }
        responseWrapper.copyBodyToResponse();
    }

    private boolean isWritableMethod(String method) {
        return "POST".equalsIgnoreCase(method)
                || "PUT".equalsIgnoreCase(method)
                || "PATCH".equalsIgnoreCase(method);
    }

    private boolean isExcludedPath(HttpServletRequest request) {
        String path = request.getRequestURI().substring(request.getContextPath().length());
        return path.contains("/auth/") || path.contains("/media/");
    }

    private JwtUserPrincipal currentPrincipal() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof JwtUserPrincipal principal) {
            return principal;
        }
        return null;
    }

    private Long branchId(JwtUserPrincipal principal, HttpServletRequest request) {
        if (principal != null && principal.getBranchId() != null) return principal.getBranchId();
        String branchHeader = request.getHeader("X-Branch-Id");
        if (branchHeader == null || branchHeader.isBlank()) return null;
        try {
            return Long.parseLong(branchHeader);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private void replay(IdempotencyRecord record, HttpServletResponse httpRes) throws IOException {
        httpRes.setStatus(record.getHttpStatus() != null ? record.getHttpStatus() : 200);
        httpRes.setContentType("application/json");
        if (record.getResponseBody() != null && !record.getResponseBody().isBlank()) {
            httpRes.getWriter().write(record.getResponseBody());
        }
    }

}
