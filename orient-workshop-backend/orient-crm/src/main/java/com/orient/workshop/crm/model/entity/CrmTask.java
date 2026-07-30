package com.orient.workshop.crm.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("crm_tasks")
public class CrmTask {
    @TableId(type = IdType.AUTO) private Long id;
    private String title;
    private String assignedTo;
    private String dueDate;
    private String priority;
    private Boolean isDone;
    @TableField(fill = FieldFill.INSERT) private java.time.LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE) private java.time.LocalDateTime updatedAt;
}
