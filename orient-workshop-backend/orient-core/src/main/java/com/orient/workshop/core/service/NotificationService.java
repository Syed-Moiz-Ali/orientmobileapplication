package com.orient.workshop.core.service;

import com.orient.workshop.core.model.entity.Notification;
import com.orient.workshop.core.repository.NotificationMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Phase 0 — single notification entry point for every workflow event.
 * Creates an in-app notification row; external channels (WhatsApp/SMS/email)
 * can hook into this service when providers are configured.
 *
 * Explicit bean name to avoid clashing with the customer module's
 * NotificationService when both are component-scanned by the gateway.
 */
@Service("coreNotificationService")
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationMapper notificationMapper;

    @Transactional
    public void emit(Long userId, String type, String title, String body) {
        emit(userId, null, type, title, body);
    }

    @Transactional
    public void emit(Long userId, Long branchId, String type, String title, String body) {
        if (userId == null) return;
        notificationMapper.insert(Notification.builder()
                .userId(userId)
                .branchId(branchId)
                .type(type)
                .title(title)
                .body(body)
                .isRead(false)
                .build());
    }
}
