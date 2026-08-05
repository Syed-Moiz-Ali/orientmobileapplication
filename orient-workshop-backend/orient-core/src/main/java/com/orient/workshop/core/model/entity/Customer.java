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
@TableName("customers")
public class Customer {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private Long branchId;
    private Boolean isB2b;
    private String customerName;
    private String phoneNumber;
    private String email;
    private String customerGroup;
    private String tags;
    private String gender;
    private String address;
    private String taxNumber;
    private String groupTaxNumber;
    private String occupation;
    private String organisation;
    private String source;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
