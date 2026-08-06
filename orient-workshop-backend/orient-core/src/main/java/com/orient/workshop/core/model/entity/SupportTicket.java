package com.orient.workshop.core.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("support_tickets")
public class SupportTicket {
    @TableId(type = IdType.AUTO) private Long id;
    private String ticketRef;
    private Long customerId;
    private Long branchId;
    private String subject;
    private String description;
    private String priority;
    private String status;
    private Long assignedStaffId;
    @TableField(fill = FieldFill.INSERT) private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE) private LocalDateTime updatedAt;
}
