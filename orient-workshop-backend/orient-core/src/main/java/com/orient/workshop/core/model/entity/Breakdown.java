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
@TableName("breakdowns")
public class Breakdown {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String breakdownRef;
    private Long customerId;
    private String issue;
    private Long vehicleId;
    private String vehicleName;
    private String vehiclePlate;
    private String location;
    private String status;
    private Long advisorId;
    private Long jobCardId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
