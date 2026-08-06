package com.orient.workshop.advisor.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("reminders")
public class Reminder {
    @TableId(type = IdType.AUTO) private Long id;
    private String reminderRef;
    private String customerName;
    private String vehicleId;
    private String task;
    private String dueDate;
    private String priority;
    private Boolean isCompleted;
    // V2 added `deleted` for persisted soft-delete — previously deletion was
    // tracked in an in-memory set that resurrected reminders on restart.
    @Builder.Default private Boolean deleted = false;
    @TableField(fill = FieldFill.INSERT) private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE) private LocalDateTime updatedAt;
}
