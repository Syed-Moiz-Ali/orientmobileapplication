package com.orient.workshop.supervisor.controller;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.core.model.entity.Notification;
import com.orient.workshop.core.repository.NotificationMapper;
import com.orient.workshop.supervisor.model.dto.StaffNotificationResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Phase 6 — in-app notification feed for staff roles (advisor, supervisor,
 * technician, owner). Same semantics as the customer feed.
 */
@Tag(name = "Staff Notifications")
@RestController
@RequestMapping("/staff/notifications")
@RequiredArgsConstructor
public class StaffNotificationController {

    private static final DateTimeFormatter TIME_FMT =
            DateTimeFormatter.ofPattern("d MMM · HH:mm");

    private final NotificationMapper notificationMapper;

    @GetMapping
    public ApiResponse<List<StaffNotificationResponse>> getNotifications(
            @AuthenticationPrincipal JwtUserPrincipal principal) {
        List<Notification> notifications = notificationMapper.findByUserId(principal.getUserId());
        return ApiResponse.success(notifications.stream()
                .map(n -> StaffNotificationResponse.builder()
                        .id(String.valueOf(n.getId()))
                        .title(n.getTitle())
                        .body(n.getBody())
                        .time(n.getCreatedAt() != null ? n.getCreatedAt().format(TIME_FMT) : "")
                        .type(n.getType() != null ? n.getType() : "reminder")
                        .isRead(n.getIsRead() != null && n.getIsRead())
                        .build())
                .collect(Collectors.toList()));
    }

    @PutMapping("/{id}/read")
    public ApiResponse<Void> markRead(@AuthenticationPrincipal JwtUserPrincipal principal,
                                      @PathVariable Long id) {
        Notification n = notificationMapper.selectById(id);
        if (n != null && n.getUserId().equals(principal.getUserId())) {
            n.setIsRead(true);
            notificationMapper.updateById(n);
        }
        return ApiResponse.success(null);
    }

    @PutMapping("/read-all")
    public ApiResponse<Void> markAllRead(@AuthenticationPrincipal JwtUserPrincipal principal) {
        notificationMapper.markAllRead(principal.getUserId());
        return ApiResponse.success(null);
    }
}
