package com.orient.workshop.core.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("warranties")
public class Warranty {
    @TableId(type = IdType.AUTO)
    private Long id;
    // P1 (V13): prefixed unique ref (public identifier).
    private Long vehicleId;
    private String warrantyRef;
    private String type;
    private LocalDate startDate;
    private LocalDate endDate;
    private String terms;
    @TableField(fill = FieldFill.INSERT) private LocalDateTime createdAt;
}
