package com.orient.workshop.owner.controller;

import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.core.model.entity.WebhookSubscription;
import com.orient.workshop.core.repository.WebhookSubscriptionMapper;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Tag(name = "Owner")
@RestController
@RequestMapping("/owner/webhooks")
@RequiredArgsConstructor
public class WebhookController {

    private final WebhookSubscriptionMapper subscriptionMapper;

    @GetMapping
    public ApiResponse<List<WebhookSubscription>> list() {
        return ApiResponse.success(subscriptionMapper.selectList(null));
    }

    @PostMapping
    public ApiResponse<WebhookSubscription> create(@RequestBody WebhookSubscription req) {
        if (req.getEventType() == null || req.getEventType().isBlank()
                || req.getUrl() == null || req.getUrl().isBlank()) {
            throw new BadRequestException("eventType and url are required");
        }
        WebhookSubscription sub = WebhookSubscription.builder()
                .eventType(req.getEventType().trim())
                .url(req.getUrl().trim())
                .secret(req.getSecret() != null ? req.getSecret() : "")
                .isActive(true)
                .build();
        subscriptionMapper.insert(sub);
        return ApiResponse.success(sub);
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Map<String, String>> delete(@PathVariable Long id) {
        if (subscriptionMapper.selectById(id) == null) {
            throw new NotFoundException("Webhook not found: " + id);
        }
        subscriptionMapper.deleteById(id);
        return ApiResponse.success(Map.of("deleted", "true"));
    }
}
