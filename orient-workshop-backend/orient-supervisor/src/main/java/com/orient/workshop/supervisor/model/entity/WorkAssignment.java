package com.orient.workshop.supervisor.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("work_assignments")
public class WorkAssignment {
    @TableId(type = IdType.AUTO) private Long id;
    private String assignmentRef;
    private Long jobCardId;
    private Long branchId;
    private String description;
    private String department;
    private String technicianName;
    private LocalDate dateOfWork;
    private Integer statusPercent;
    private String stdTime;
    private String remarks;
    private String status;
    @TableField(fill = FieldFill.INSERT) private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE) private LocalDateTime updatedAt;
}
