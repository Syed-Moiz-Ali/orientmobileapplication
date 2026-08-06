package com.orient.workshop.core.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("purchase_orders")
public class PurchaseOrder {
    @TableId(type = IdType.AUTO) private Long id;
    private String poRef;
    private Long supplierId;
    private Long branchId;
    private String status;
    private BigDecimal total;
    private LocalDateTime orderedAt;
    private LocalDateTime receivedAt;
    @TableField(fill = FieldFill.INSERT) private LocalDateTime createdAt;
}
