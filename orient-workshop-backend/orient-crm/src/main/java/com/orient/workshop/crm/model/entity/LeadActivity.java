package com.orient.workshop.crm.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("lead_activities")
public class LeadActivity {
    @TableId(type = IdType.AUTO) private Long id;
    private Long leadId;
    private String action;
    private String detail;
    @TableField(fill = FieldFill.INSERT) private LocalDateTime createdAt;
}
