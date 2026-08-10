package com.orient.workshop.auth.model.entity;

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
@TableName("users")
public class User {

    @TableId(type = IdType.AUTO)
    private Long id;
    // P1 (V13): prefixed unique ref (public identifier).
    @TableField(fill = FieldFill.INSERT)
    // P1 (V13): prefixed unique ref (public identifier).
    private String ref;

    private String phone;

    private String email;

    private String passwordHash;

    private String name;

    private String role;

    private Long branchId;

    @Builder.Default
    private Boolean isActive = true;

    private String avatarUrl;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
