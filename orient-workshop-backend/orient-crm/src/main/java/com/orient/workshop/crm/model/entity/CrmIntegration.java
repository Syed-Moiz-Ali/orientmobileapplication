package com.orient.workshop.crm.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("crm_integrations")
public class CrmIntegration {
    @TableId(type = IdType.AUTO) private Long id;
    // P1 (V13): prefixed unique ref (public identifier).
    @TableField(fill = FieldFill.INSERT)
    // P1 (V13): prefixed unique ref (public identifier).
    private String ref;
    private String name;
    private Boolean connected;
    private String credentials;
    private LocalDateTime lastSyncAt;
    private String syncStatus;
}
