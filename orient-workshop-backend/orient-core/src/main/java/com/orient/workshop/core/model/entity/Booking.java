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
@TableName("bookings")
public class Booking {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String bookingRef;
    private Long customerId;
    private Long branchId;
    private Long vehicleId;
    private String vehicleName;
    private String plateNumber;
    private String serviceType;
    private LocalDateTime bookingDate;
    private String notes;
    private String status;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
