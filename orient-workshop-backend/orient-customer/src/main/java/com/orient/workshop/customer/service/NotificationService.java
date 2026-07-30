package com.orient.workshop.customer.service;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.customer.model.dto.NotificationResponse;
import com.orient.workshop.core.model.entity.Notification;
import com.orient.workshop.core.repository.NotificationMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationMapper notificationMapper;

    public List<NotificationResponse> getNotifications(JwtUserPrincipal principal) {
        List<Notification> notifications = notificationMapper.findByUserId(principal.getUserId());
        return notifications.stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Transactional
    public void markRead(JwtUserPrincipal principal, Long notificationId) {
        Notification n = notificationMapper.selectById(notificationId);
        if (n != null && n.getUserId().equals(principal.getUserId())) {
            n.setIsRead(true);
            notificationMapper.updateById(n);
        }
    }

    @Transactional
    public void markAllRead(JwtUserPrincipal principal) {
        notificationMapper.markAllRead(principal.getUserId());
    }

    private NotificationResponse toResponse(Notification n) {
        String time = n.getCreatedAt() != null
                ? n.getCreatedAt().format(DateTimeFormatter.ofPattern("d MMM · HH:mm"))
                : "";
        return NotificationResponse.builder()
                .id(String.valueOf(n.getId()))
                .title(n.getTitle())
                .body(n.getBody())
                .time(time)
                .type(n.getType() != null ? n.getType() : "carReady")
                .isRead(n.getIsRead() != null && n.getIsRead())
                .build();
    }
}
