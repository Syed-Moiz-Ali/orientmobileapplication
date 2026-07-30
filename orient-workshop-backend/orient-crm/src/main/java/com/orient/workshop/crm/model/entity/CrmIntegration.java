package com.orient.workshop.crm.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("crm_integrations")
public class CrmIntegration {
    @TableId(type = IdType.AUTO) private Long id;
    private String name;
    private Boolean connected;
}
