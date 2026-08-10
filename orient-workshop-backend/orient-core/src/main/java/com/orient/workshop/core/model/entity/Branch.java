package com.orient.workshop.core.model.entity;
import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("branches")
public class Branch {
    @TableId(type = IdType.AUTO)
    private Long id;
    // P1 (V13): prefixed unique ref (public identifier).
    @TableField(fill = FieldFill.INSERT)
    // P1 (V13): prefixed unique ref (public identifier).
    private String ref;
    private String name;
    private String address;
    private String phone;
    private String email;
    private String timezone;
    private Boolean isActive;
    @TableField(fill = FieldFill.INSERT) private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE) private LocalDateTime updatedAt;
}
