package com.orient.workshop.whatsapp.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.orient.workshop.core.model.entity.WhatsappMessage;
import com.orient.workshop.core.repository.WhatsappMessageMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class WhatsAppService {

    private final WhatsappMessageMapper messageMapper;
    private final ObjectMapper objectMapper;

    @Value("${app.whatsapp.access-token:}")
    private String accessToken;

    @Value("${app.whatsapp.phone-number-id:}")
    private String phoneNumberId;

    @Value("${app.whatsapp.api-base:https://graph.facebook.com/v20.0}")
    private String apiBase;

    @Transactional
    public Map<String, String> send(Long branchId, String customerPhone, String templateName, String messageBody) {
        WhatsappMessage msg = WhatsappMessage.builder()
                .branchId(branchId)
                .customerPhone(customerPhone)
                .templateName(templateName != null ? templateName : "")
                .messageBody(messageBody)
                .status("sent")
                .messageType("notification")
                .build();

        if (accessToken == null || accessToken.isBlank()) {
            log.warn("WhatsApp access token not configured; falling back to log-only mode for {} [{}]",
                    customerPhone, templateName);
            messageMapper.insert(msg);
            return Map.of("id", String.valueOf(msg.getId()), "status", "sent");
        }

        String externalId = callMetaApi(customerPhone, messageBody);
        if (externalId != null) {
            msg.setExternalId(externalId);
            msg.setStatus("sent");
            messageMapper.insert(msg);
            log.info("WhatsApp sent to {}: [{}] {} (wamid {})", customerPhone, templateName, messageBody, externalId);
            return Map.of("id", String.valueOf(msg.getId()), "status", "sent");
        }

        msg.setStatus("failed");
        messageMapper.insert(msg);
        log.error("WhatsApp send to {} failed", customerPhone);
        return Map.of("id", String.valueOf(msg.getId()), "status", "failed");
    }

    private String callMetaApi(String to, String messageBody) {
        try {
            Map<String, Object> text = Map.of("body", messageBody != null ? messageBody : "");
            Map<String, Object> payload = Map.of(
                    "messaging_product", "whatsapp",
                    "to", to,
                    "type", "text",
                    "text", text);

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(apiBase + "/" + phoneNumberId + "/messages"))
                    .timeout(Duration.ofSeconds(15))
                    .header("Authorization", "Bearer " + accessToken)
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(objectMapper.writeValueAsString(payload)))
                    .build();

            HttpResponse<String> response = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(10))
                    .build()
                    .send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() >= 200 && response.statusCode() < 300) {
                @SuppressWarnings("unchecked")
                Map<String, Object> body = objectMapper.readValue(response.body(), Map.class);
                Object messages = body.get("messages");
                if (messages instanceof List<?> list && !list.isEmpty()) {
                    @SuppressWarnings("unchecked")
                    Map<String, Object> first = (Map<String, Object>) list.get(0);
                    Object id = first.get("id");
                    return id != null ? id.toString() : "";
                }
                return "";
            }
            log.warn("Meta API returned {}: {}", response.statusCode(), response.body());
            return null;
        } catch (Exception e) {
            log.error("Meta API call failed", e);
            return null;
        }
    }

    @Transactional
    public void handleWebhook(Map<String, Object> payload) {
        int updated = 0;
        Object externalId = payload.get("externalId");
        Object status = payload.get("status");
        if (externalId != null && status != null) {
            updated = updateStatus(externalId.toString(), status.toString());
        }
        Object entries = payload.get("entry");
        if (entries instanceof List<?> entryList) {
            for (Object entryObj : entryList) {
                if (!(entryObj instanceof Map<?, ?> entry)) continue;
                Object changes = entry.get("changes");
                if (!(changes instanceof List<?> changeList)) continue;
                for (Object changeObj : changeList) {
                    if (!(changeObj instanceof Map<?, ?> change)) continue;
                    Object value = change.get("value");
                    if (!(value instanceof Map<?, ?> valueMap)) continue;
                    Object statuses = valueMap.get("statuses");
                    if (!(statuses instanceof List<?> statusList)) continue;
                    for (Object statusObj : statusList) {
                        if (!(statusObj instanceof Map<?, ?> statusMap)) continue;
                        Object id = statusMap.get("id");
                        Object st = statusMap.get("status");
                        if (id != null && st != null) {
                            updated += updateStatus(id.toString(), st.toString());
                        }
                    }
                }
            }
        }
        log.info("WhatsApp webhook processed, {} message status(es) updated", updated);
    }

    private int updateStatus(String externalId, String status) {
        if (externalId.isBlank()) return 0;
        WhatsappMessage msg = messageMapper.selectOne(
                new LambdaQueryWrapper<WhatsappMessage>()
                        .eq(WhatsappMessage::getExternalId, externalId)
                        .last("LIMIT 1"));
        if (msg == null) {
            log.debug("No whatsapp_messages row found for external id {}", externalId);
            return 0;
        }
        msg.setStatus(status);
        messageMapper.updateById(msg);
        return 1;
    }

    public List<WhatsappMessage> getHistory(String customerPhone) {
        return messageMapper.selectList(
                new LambdaQueryWrapper<WhatsappMessage>()
                        .eq(WhatsappMessage::getCustomerPhone, customerPhone)
                        .orderByDesc(WhatsappMessage::getSentAt));
    }
}
