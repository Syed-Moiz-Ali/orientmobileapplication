package com.orient.workshop.core.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("vehicles")
public class Vehicle {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long customerId;
    private Long branchId;
    private String registrationNumber;
    private String vin;
    private String make;
    private String model;
    private Integer modelYear;
    private LocalDate purchaseDate;
    private Integer cylinders;
    private String engineCapacity;
    private String vehicleColor;
    private String engineNumber;
    private String insuranceProvider;
    private String insuranceTaxNumber;
    private String insuranceAddress;
    private String policyNumber;
    private LocalDate insuranceExpiryDate;
    private String plateNumber;
    private String mileage;
    private String lastService;
    private String nextDue;
    private Integer healthScore;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
