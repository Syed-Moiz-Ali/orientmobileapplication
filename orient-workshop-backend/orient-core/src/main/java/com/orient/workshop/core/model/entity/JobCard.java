package com.orient.workshop.core.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("job_cards")
public class JobCard {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String jobCardRef;
    private Long customerId;
    private Long branchId;
    private Long vehicleId;
    private String status;
    private String technician;
    private LocalDateTime createdDate;
    private LocalDateTime lastUpdated;
    private String notes;
    private String tag;
    private String customerRequests;
    private String garageRecommendations;
    private LocalDateTime estimatedDelivery;
    private Boolean notifyOwnerSmsEmail;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
