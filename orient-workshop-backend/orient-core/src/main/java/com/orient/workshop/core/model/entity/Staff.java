package com.orient.workshop.core.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("staff")
public class Staff {
    @TableId(type = IdType.AUTO) private Long id;
    private Long userId;
    private String empId;
    private String name;
    private String role;
    private Long branchId;
    private String branch;
    private String shift;
    private String designation;
    private String department;
    private String avatarInitials;
    private Boolean isActive;
    @TableField(fill = FieldFill.INSERT) private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE) private LocalDateTime updatedAt;
}
