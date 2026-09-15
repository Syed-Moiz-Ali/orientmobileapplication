package com.orient.workshop.core.service;

import com.google.firebase.messaging.BatchResponse;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.MessagingErrorCode;
import com.google.firebase.messaging.MulticastMessage;
import com.google.firebase.messaging.SendResponse;
import com.orient.workshop.core.model.entity.DeviceToken;
import com.orient.workshop.core.repository.DeviceTokenMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class FcmNotificationService {

    private final ObjectProvider<FirebaseMessaging> firebaseMessaging;
    private final DeviceTokenMapper deviceTokenMapper;
    private final DeviceTokenService deviceTokenService;

    @Async
    public void sendToUser(Long userId, String type, String title, String body) {
        FirebaseMessaging messaging = firebaseMessaging.getIfAvailable();
        if (messaging == null) return;

        List<DeviceToken> registrations = deviceTokenMapper.findByUserId(userId);
        if (registrations.isEmpty()) return;

        for (int start = 0; start < registrations.size(); start += 500) {
            List<DeviceToken> batch = registrations.subList(
                    start, Math.min(start + 500, registrations.size()));
            MulticastMessage message = MulticastMessage.builder()
                    .setNotification(com.google.firebase.messaging.Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build())
                    .putData("type", type == null ? "general" : type)
                    .addAllTokens(batch.stream().map(DeviceToken::getToken).toList())
                    .build();
            try {
                BatchResponse response = messaging.sendEachForMulticast(message);
                removeInvalidTokens(batch, response.getResponses());
                if (response.getFailureCount() > 0) {
                    log.warn("FCM delivery to user {}: {} succeeded, {} failed",
                            userId, response.getSuccessCount(), response.getFailureCount());
                }
            } catch (Exception exception) {
                // Push is supplementary: a provider outage must never roll back
                // the durable in-app notification stored by NotificationService.
                log.warn("FCM delivery failed for user {}: {}", userId, exception.getMessage());
            }
        }
    }

    private void removeInvalidTokens(List<DeviceToken> registrations, List<SendResponse> responses) {
        List<String> invalid = new ArrayList<>();
        for (int index = 0; index < responses.size(); index++) {
            SendResponse response = responses.get(index);
            if (response.isSuccessful() || response.getException() == null) continue;
            MessagingErrorCode code = response.getException().getMessagingErrorCode();
            if (code == MessagingErrorCode.UNREGISTERED || code == MessagingErrorCode.INVALID_ARGUMENT) {
                invalid.add(registrations.get(index).getToken());
            }
        }
        deviceTokenService.removeTokens(invalid);
    }
}
