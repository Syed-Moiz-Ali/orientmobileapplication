package com.orient.workshop.sync.filter;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.orient.workshop.sync.model.entity.IdempotencyRecord;
import com.orient.workshop.sync.repository.IdempotencyKeyMapper;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.util.ContentCachingResponseWrapper;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

@Component
@Order(1)
@RequiredArgsConstructor
public class IdempotencyFilter implements Filter {

    private final IdempotencyKeyMapper idempotencyKeyMapper;
    private final ObjectMapper objectMapper;

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpReq = (HttpServletRequest) request;
        String idempotencyKey = httpReq.getHeader("Idempotency-Key");

        if (idempotencyKey != null && !idempotencyKey.isBlank()
                && "POST".equalsIgnoreCase(httpReq.getMethod())) {

            var existing = idempotencyKeyMapper.findByKey(idempotencyKey);
            if (existing.isPresent()) {
                IdempotencyRecord record = existing.get();
                HttpServletResponse httpRes = (HttpServletResponse) response;
                httpRes.setStatus(record.getHttpStatus() != null ? record.getHttpStatus() : 200);
                httpRes.setContentType("application/json");
                if (record.getResponseBody() != null) {
                    httpRes.getWriter().write(record.getResponseBody());
                }
                return;
            }

            ContentCachingResponseWrapper responseWrapper = new ContentCachingResponseWrapper((HttpServletResponse) response);
            chain.doFilter(request, responseWrapper);

            byte[] body = responseWrapper.getContentAsByteArray();
            String responseBody = new String(body, StandardCharsets.UTF_8);
            int status = responseWrapper.getStatus();

            idempotencyKeyMapper.insert(IdempotencyRecord.builder()
                    .idempotencyKey(idempotencyKey)
                    .responseBody(responseBody)
                    .httpStatus(status)
                    .build());

            responseWrapper.copyBodyToResponse();
        } else {
            chain.doFilter(request, response);
        }
    }
}
