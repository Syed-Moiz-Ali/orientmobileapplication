package com.orient.workshop.core.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("technician_tasks")
public class TechnicianTask {
    @TableId(type = IdType.AUTO) private Long id;
    private String jobCardNo;
    private String taskRef;
    private String description;
    private String itemType;
    private Integer qty;
    private Double rate;
    private String status;
    private String empId;
    private Long advisorId;
    private String rejectReason;
    private String startTime;
    private String endTime;
    private String photoRefs;
    @TableField(fill = FieldFill.INSERT) private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE) private LocalDateTime updatedAt;
}
