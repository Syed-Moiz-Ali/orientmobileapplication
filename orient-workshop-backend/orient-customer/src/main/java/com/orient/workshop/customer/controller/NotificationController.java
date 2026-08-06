package com.orient.workshop.customer.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.customer.model.dto.NotificationResponse;
import com.orient.workshop.customer.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Customer Portal")
@RestController
@RequestMapping("/customers/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    public ApiResponse<List<NotificationResponse>> getNotifications(@AuthenticationPrincipal JwtUserPrincipal principal,
                                                                      @RequestParam(defaultValue = "1") int page,
                                                                      @RequestParam(defaultValue = "20") int size) {
        List<NotificationResponse> notifications = notificationService.getNotifications(principal, page, size);
        return ApiResponse.success(notifications);
    }

    @PutMapping("/{id}/read")
    public ApiResponse<Void> markRead(@AuthenticationPrincipal JwtUserPrincipal principal,
                                       @PathVariable Long id) {
        notificationService.markRead(principal, id);
        return ApiResponse.success(null);
    }

    @PutMapping("/read-all")
    public ApiResponse<Void> markAllRead(@AuthenticationPrincipal JwtUserPrincipal principal) {
        notificationService.markAllRead(principal);
        return ApiResponse.success(null);
    }
}

