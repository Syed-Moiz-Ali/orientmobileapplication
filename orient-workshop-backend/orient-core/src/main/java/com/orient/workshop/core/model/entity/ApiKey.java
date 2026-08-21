package com.orient.workshop.core.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("api_keys")
public class ApiKey {
    @TableId(type = IdType.AUTO)
    private Long id;
    // P1 (V13): prefixed unique ref (public identifier).
    @TableField(fill = FieldFill.INSERT)
    // P1 (V13): prefixed unique ref (public identifier).
    private String ref;
    private String name;
    private String keyHash;
    private String keyPrefix;
    private String role;
    private Long branchId;
    private Boolean isActive;
    private Long createdBy;
    private LocalDateTime lastUsedAt;
    @TableField(fill = FieldFill.INSERT) private LocalDateTime createdAt;
}
