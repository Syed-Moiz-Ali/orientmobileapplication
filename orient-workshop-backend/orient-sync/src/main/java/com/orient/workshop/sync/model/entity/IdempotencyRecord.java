package com.orient.workshop.sync.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("idempotency_keys")
public class IdempotencyRecord {
    @TableId(type = IdType.AUTO) private Long id;
    private String idempotencyKey;
    private String responseBody;
    private Integer httpStatus;
    @TableField(fill = FieldFill.INSERT) private LocalDateTime createdAt;
}
