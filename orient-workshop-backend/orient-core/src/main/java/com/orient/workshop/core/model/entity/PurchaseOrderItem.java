package com.orient.workshop.core.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("purchase_order_items")
public class PurchaseOrderItem {
    @TableId(type = IdType.AUTO) private Long id;
    private Long purchaseOrderId;
    private Long inventoryItemId;
    private String itemName;
    private Integer qty;
    private BigDecimal unitCost;
}
