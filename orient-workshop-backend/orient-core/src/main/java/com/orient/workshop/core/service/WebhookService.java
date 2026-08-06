package com.orient.workshop.core.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.orient.workshop.core.model.entity.WebhookSubscription;
import com.orient.workshop.core.repository.WebhookSubscriptionMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Base64;
import java.util.List;
import java.util.Map;

/**
 * P3 (audit): outbound webhooks. Events are dispatched asynchronously to every
 * active subscription for the event type; each request carries an
 * X-Orient-Signature HMAC-SHA256 header computed with the subscription secret
 * so receivers can verify authenticity. Failures never break the workflow.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class WebhookService {

    private static final HttpClient HTTP = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(5))
            .build();

    private final WebhookSubscriptionMapper subscriptionMapper;
    private final ObjectMapper objectMapper;

    @Async
    public void dispatch(String eventType, Object payload) {
        List<WebhookSubscription> subs = subscriptionMapper.findActiveByEvent(eventType);
        if (subs.isEmpty()) return;
        String body;
        try {
            body = objectMapper.writeValueAsString(Map.of("event", eventType, "payload", payload));
        } catch (Exception e) {
            log.warn("webhook serialization failed for {}: {}", eventType, e.getMessage());
            return;
        }
        for (WebhookSubscription sub : subs) {
            try {
                HttpRequest.Builder builder = HttpRequest.newBuilder()
                        .uri(URI.create(sub.getUrl()))
                        .timeout(Duration.ofSeconds(8))
                        .header("Content-Type", "application/json")
                        .POST(HttpRequest.BodyPublishers.ofString(body));
                if (sub.getSecret() != null && !sub.getSecret().isBlank()) {
                    builder.header("X-Orient-Signature", sign(body, sub.getSecret()));
                }
                HTTP.send(builder.build(), HttpResponse.BodyHandlers.discarding());
            } catch (Exception e) {
                log.warn("webhook {} -> {} failed: {}", eventType, sub.getUrl(), e.getMessage());
            }
        }
    }

    public static String sign(String body, String secret) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            return Base64.getEncoder().encodeToString(mac.doFinal(body.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception e) {
            return "";
        }
    }
}
