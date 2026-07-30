package com.orient.workshop.advisor.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("inspections")
public class Inspection {
    @TableId(type = IdType.AUTO) private Long id;
    private String inspectionRef;
    private Long jobCardId;
    private String referenceNumber;
    private String placeOfSupply;
    private String customerRequests;
    private String garageRecommendations;
    private LocalDateTime estimatedDelivery;
    private Boolean notifyOwnerSmsEmail;
    private String tag;
    private Boolean isDraft;
    private String sections;
    @TableField(fill = FieldFill.INSERT) private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE) private LocalDateTime updatedAt;
}
