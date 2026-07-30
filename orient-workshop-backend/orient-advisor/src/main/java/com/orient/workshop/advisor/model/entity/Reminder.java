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
    @TableField(fill = FieldFill.INSERT) private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE) private LocalDateTime updatedAt;
}
