package com.orient.workshop.whatsapp.service;

import com.orient.workshop.core.model.entity.WhatsappMessage;
import com.orient.workshop.core.repository.WhatsappMessageMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class WhatsAppService {

    private final WhatsappMessageMapper messageMapper;

    @Transactional
    public Map<String, String> send(Long branchId, String customerPhone, String templateName, String messageBody) {
        WhatsappMessage msg = WhatsappMessage.builder()
                .branchId(branchId)
                .customerPhone(customerPhone)
                .templateName(templateName)
                .messageBody(messageBody)
                .status("sent")
                .messageType("notification")
                .build();
        messageMapper.insert(msg);

        log.info("WhatsApp sent to {}: [{}] {}", customerPhone, templateName, messageBody);

        return Map.of("id", String.valueOf(msg.getId()), "status", "sent");
    }

    public void handleWebhook(Map<String, Object> payload) {
        String externalId = (String) payload.getOrDefault("externalId", "");
        String status = (String) payload.getOrDefault("status", "delivered");
        log.info("WhatsApp webhook: {} -> {}", externalId, status);
    }

    public List<WhatsappMessage> getHistory(String customerPhone) {
        return messageMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<WhatsappMessage>()
                        .eq(WhatsappMessage::getCustomerPhone, customerPhone)
                        .orderByDesc(WhatsappMessage::getSentAt));
    }
}
