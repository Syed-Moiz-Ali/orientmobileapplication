package com.orient.workshop.auth.model.entity;

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
@TableName("otp_records")
public class OtpRecord {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String phone;

    private String email;

    private String otpCode;

    @Builder.Default
    private Integer attempts = 0;

    private LocalDateTime expiresAt;

    @Builder.Default
    private Boolean used = false;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
