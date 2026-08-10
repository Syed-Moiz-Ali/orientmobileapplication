package com.orient.workshop.advisor.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("repair_order_services")
public class RepairOrderServiceItem {
    @TableId(type = IdType.AUTO) private Long id;
    // P1 (V13): prefixed unique ref (public identifier).
    @TableField(fill = FieldFill.INSERT)
    // P1 (V13): prefixed unique ref (public identifier).
    private String ref;
    private Long repairOrderId;
    private String name;
    private Integer qty;
    private Double rate;
    private Double discountPercent;
    private Double discountAmount;
}
