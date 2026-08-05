package com.orient.workshop.core.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("notifications")
public class Notification {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private Long branchId;
    private String title;
    private String body;
    private String type;
    @Builder.Default
    private Boolean isRead = false;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
