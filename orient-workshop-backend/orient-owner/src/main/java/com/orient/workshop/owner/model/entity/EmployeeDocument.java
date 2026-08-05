package com.orient.workshop.owner.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("employee_documents")
public class EmployeeDocument {
    @TableId(type = IdType.AUTO) private Long id;
    private String empId;
    private String employeeName;
    private String designation;
    private String documentType;
    private LocalDate expiryDate;
    private Integer daysLeft;
    private String urgency;
    @TableField(fill = FieldFill.INSERT) private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE) private LocalDateTime updatedAt;
}
