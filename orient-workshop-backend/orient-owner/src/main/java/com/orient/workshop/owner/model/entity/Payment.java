package com.orient.workshop.owner.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("payments")
public class Payment {
    @TableId(type = IdType.AUTO) private Long id;
    private String paymentRef;
    private Long invoiceId;
    private Long branchId;
    private BigDecimal amount;
    private String method;
    private String reference;
    private LocalDateTime paidAt;
    private Long recordedBy;
    @TableField(fill = FieldFill.INSERT) private LocalDateTime createdAt;
}
