package com.orient.workshop.advisor.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("repair_order_parts")
public class RepairOrderPartItem {
    @TableId(type = IdType.AUTO) private Long id;
    private Long repairOrderId;
    private String name;
    private Integer qty;
    private Double rate;
    private Double discountPercent;
    private Double discountAmount;
}
