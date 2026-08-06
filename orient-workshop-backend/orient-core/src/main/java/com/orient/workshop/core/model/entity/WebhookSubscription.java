package com.orient.workshop.core.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("webhook_subscriptions")
public class WebhookSubscription {
    @TableId(type = IdType.AUTO) private Long id;
    private String eventType;
    private String url;
    private String secret;
    private Boolean isActive;
    @TableField(fill = FieldFill.INSERT) private LocalDateTime createdAt;
}
