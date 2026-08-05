package com.orient.workshop.auth.filter;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;
import io.github.bucket4j.Refill;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletRequestWrapper;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

/**
 * Rate limiting (H-2).
 *
 * Registered ONLY via SecurityConfig.addFilterBefore (this class intentionally has no
 * @Component annotation, so it is not double-registered). Buckets are keyed by
 * IP + username/phone (never the raw token), evicted after 10 minutes of idleness,
 * and the map is capped at ~100k entries with oldest-first removal.
 *
 * /auth/** endpoints get a stricter per-IP budget.
 */
@Slf4j
public class RateLimitFilter implements Filter {

    private static final long IDLE_EVICTION_NANOS = Duration.ofMinutes(10).toNanos();
    private static final long MAX_BUCKETS = 100_000;

    private final int capacity;
    private final int refillPeriodMinutes;
    private final int authCapacity;
    private final ObjectMapper objectMapper = new ObjectMapper();

    private final ConcurrentHashMap<String, BucketState> buckets = new ConcurrentHashMap<>();

    public RateLimitFilter(
            @Value("${app.rate-limit.capacity:100}") int capacity,
            @Value("${app.rate-limit.refill-period-minutes:1}") int refillPeriodMinutes,
            @Value("${app.rate-limit.auth-capacity:20}") int authCapacity) {
        this.capacity = capacity;
        this.refillPeriodMinutes = refillPeriodMinutes;
        this.authCapacity = authCapacity;
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        long now = System.nanoTime();
        evictIdle(now);
        ensureCapacity();

        HttpServletRequest httpReq = (HttpServletRequest) request;
        HttpServletResponse httpRes = (HttpServletResponse) response;

        // X-Username header wins (cheap); otherwise for /auth/** JSON bodies the
        // request is buffered once and re-served downstream, and the parsed
        // identifier is used as part of the bucket key.
        String key = httpReq.getRemoteAddr();
        String headerUser = httpReq.getHeader("X-Username");
        if (headerUser != null && !headerUser.isBlank()) {
            key = key + ":" + headerUser.trim().toLowerCase();
        } else if (shouldParseBody(httpReq)) {
            RepeatableReadRequestWrapper wrapper;
            try {
                wrapper = new RepeatableReadRequestWrapper(httpReq);
            } catch (IOException e) {
                log.debug("Could not buffer request body for rate limiting: {}", e.getMessage());
                wrapper = null;
            }
            if (wrapper != null) {
                try {
                    byte[] body = wrapper.getBodyBytes();
                    if (body.length > 0) {
                        Map<?, ?> parsed = objectMapper.readValue(body, Map.class);
                        Object phone = parsed.get("phone");
                        Object email = parsed.get("email");
                        Object user = phone != null ? phone : email;
                        if (user != null && !String.valueOf(user).isBlank()) {
                            key = key + ":" + String.valueOf(user).trim().toLowerCase();
                        }
                    }
                } catch (Exception e) {
                    log.debug("Could not parse request body for rate limiting: {}", e.getMessage());
                }
                // The wrapper re-serves the buffered body downstream, so the
                // controller still sees the full payload.
                httpReq = wrapper;
            }
        }

        boolean authPath = isAuthPath(httpReq);

        Bucket bucket = buckets.computeIfAbsent(key, k -> new BucketState(now))
                .bucketFor(authPath);

        if (bucket.tryConsume(1)) {
            chain.doFilter(httpReq, response);
        } else {
            httpRes.setStatus(429);
            httpRes.setHeader("Retry-After", String.valueOf(refillPeriodSeconds()));
            httpRes.setContentType(MediaType.APPLICATION_JSON_VALUE);
            httpRes.setCharacterEncoding(StandardCharsets.UTF_8.name());
            Map<String, Object> body = new LinkedHashMap<>();
            body.put("code", 429);
            body.put("message", "Too many requests. Please slow down.");
            body.put("timestamp", System.currentTimeMillis());
            httpRes.getWriter().write(objectMapper.writeValueAsString(body));
        }
    }

    private boolean shouldParseBody(HttpServletRequest request) {
        String contentType = request.getContentType();
        boolean jsonBody = contentType != null && contentType.toLowerCase().contains("application/json");
        boolean writable = "POST".equalsIgnoreCase(request.getMethod())
                || "PUT".equalsIgnoreCase(request.getMethod())
                || "PATCH".equalsIgnoreCase(request.getMethod());
        return jsonBody && writable && isAuthPath(request);
    }

    private boolean isAuthPath(HttpServletRequest request) {
        return request.getRequestURI().contains("/auth/");
    }

    private Bucket newBucket(int tokens) {
        return Bucket.builder()
                .addLimit(Bandwidth.classic(tokens, Refill.greedy(tokens, Duration.ofMinutes(refillPeriodMinutes))))
                .build();
    }

    private long refillPeriodSeconds() {
        return Math.max(1, refillPeriodMinutes * 60L);
    }

    private void evictIdle(long now) {
        if (buckets.isEmpty()) return;
        for (Map.Entry<String, BucketState> entry : buckets.entrySet()) {
            if (now - entry.getValue().lastAccessNanos.get() > IDLE_EVICTION_NANOS) {
                buckets.remove(entry.getKey());
            }
        }
    }

    private void ensureCapacity() {
        if (buckets.size() < MAX_BUCKETS) return;
        int toRemove = (int) (MAX_BUCKETS / 10);
        buckets.entrySet().stream()
                .sorted(Map.Entry.comparingByValue(
                        (a, b) -> Long.compare(a.lastAccessNanos.get(), b.lastAccessNanos.get())))
                .limit(toRemove)
                .forEach(e -> buckets.remove(e.getKey()));
    }

    private final class BucketState {
        private final AtomicLong lastAccessNanos;
        private final Bucket general;
        private final Bucket auth;

        private BucketState(long now) {
            this.lastAccessNanos = new AtomicLong(now);
            this.general = newBucket(capacity);
            this.auth = newBucket(authCapacity);
        }

        Bucket bucketFor(boolean authPath) {
            lastAccessNanos.set(System.nanoTime());
            return authPath ? auth : general;
        }
    }

    /**
     * Buffers the request body once and re-serves it on every subsequent read.
     * Unlike ContentCachingRequestWrapper (inspection only), this lets downstream
     * components (Spring MVC) read the full payload after the filter consumed it.
     */
    private static final class RepeatableReadRequestWrapper extends HttpServletRequestWrapper {

        private final byte[] body;

        private RepeatableReadRequestWrapper(HttpServletRequest request) throws IOException {
            super(request);
            this.body = request.getInputStream().readAllBytes();
        }

        private byte[] getBodyBytes() {
            return body;
        }

        @Override
        public ServletInputStream getInputStream() {
            ByteArrayInputStream buffer = new ByteArrayInputStream(body);
            return new ServletInputStream() {
                @Override
                public int read() {
                    return buffer.read();
                }

                @Override
                public boolean isFinished() {
                    return buffer.available() == 0;
                }

                @Override
                public boolean isReady() {
                    return true;
                }

                @Override
                public void setReadListener(ReadListener readListener) {
                    // Not needed: the stream is fully buffered in memory.
                }
            };
        }

        @Override
        public BufferedReader getReader() {
            return new BufferedReader(new InputStreamReader(getInputStream(), StandardCharsets.UTF_8));
        }
    }
}
