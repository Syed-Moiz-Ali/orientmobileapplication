package com.orient.workshop.crm.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("leads")
public class Lead {
    @TableId(type = IdType.AUTO) private Long id;
    private String leadNumber;
    private String customerName;
    private String phone;
    private String email;
    private String source;
    private String assignedTo;
    private String status;
    private String lastActivity;
    private String externalId;
    private String notes;
    private java.math.BigDecimal leadValue;
    private String followUpDate;
    @TableField(fill = FieldFill.INSERT) private java.time.LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE) private java.time.LocalDateTime updatedAt;
}
