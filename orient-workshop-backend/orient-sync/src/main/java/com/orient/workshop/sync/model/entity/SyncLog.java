package com.orient.workshop.sync.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("sync_logs")
public class SyncLog {
    @TableId(type = IdType.AUTO) private Long id;
    private String idempotencyKey;
    private String entityType;
    private String entityId;
    private String endpoint;
    private String method;
    private String requestBody;
    private String payload;
    private String status;
    private LocalDateTime processedAt;
    @TableField(fill = FieldFill.INSERT) private LocalDateTime createdAt;
}
