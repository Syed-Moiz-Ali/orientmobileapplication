package com.orient.workshop.advisor.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("repair_orders")
public class RepairOrder {
    @TableId(type = IdType.AUTO) private Long id;
    private String repairOrderRef;
    private Long jobCardId;
    private Double servicesTotal;
    private Double partsTotal;
    private Double grandTotal;
    private String tag;
    private String customerRequests;
    private String garageRecommendations;
    private LocalDateTime estimatedDelivery;
    private Boolean notifyOwnerSmsEmail;
    @TableField(fill = FieldFill.INSERT) private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE) private LocalDateTime updatedAt;
}
