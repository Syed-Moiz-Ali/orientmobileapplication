package com.orient.workshop.owner.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("activity_log")
public class ActivityLog {
    @TableId(type = IdType.AUTO) private Long id;
    private String type;
    private String title;
    private String description;
    private Long userId;
    @TableField(fill = FieldFill.INSERT) private LocalDateTime createdAt;
}
