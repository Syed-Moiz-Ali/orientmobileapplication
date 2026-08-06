package com.orient.workshop.owner.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("invoices")
public class Invoice {
    @TableId(type = IdType.AUTO) private Long id;
    private String invoiceRef;
    private Long customerId;
    private Long jobCardId;
    private Long branchId;
    private BigDecimal amount;
    // P3 (audit): UAE VAT 5% — server-computed, never client-supplied.
    private BigDecimal taxRate;
    private BigDecimal taxAmount;
    private BigDecimal grandTotal;
    private String status;
    private LocalDate dueDate;
    private LocalDate issuedDate;
    @TableField(fill = FieldFill.INSERT) private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE) private LocalDateTime updatedAt;
}
