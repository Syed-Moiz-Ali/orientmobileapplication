package com.orient.workshop.core.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("inventory_items")
public class InventoryItem {
    @TableId(type = IdType.AUTO)
    private Long id;
    // P1 (V13): prefixed unique ref (public identifier).
    @TableField(fill = FieldFill.INSERT)
    // P1 (V13): prefixed unique ref (public identifier).
    private String ref;
    private String sku;
    private String name;
    private String category;
    private Long branchId;
    private BigDecimal costPrice;
    private BigDecimal sellingPrice;
    private Integer qtyOnHand;
    private Integer reorderLevel;
    private Long supplierId;
    @TableField(fill = FieldFill.INSERT) private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE) private LocalDateTime updatedAt;
}
