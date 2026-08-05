package com.orient.workshop.core.model.entity;
import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("feedback")
public class Feedback {
    @TableId(type = IdType.AUTO) private Long id;
    private Long jobCardId;
    private Long customerId;
    private Long branchId;
    private Integer rating; // Overall rating alias
    private Integer overallRating;
    private Integer workQuality;
    private Integer communication;
    private Integer timeliness;
    private Integer valueForMoney;
    private Boolean wouldRecommend;
    private String comment;
    @Builder.Default private Boolean isPublic = true;
    @TableField(exist = false) @Builder.Default private Boolean isModerated = false;
    @TableField(fill = FieldFill.INSERT) private LocalDateTime createdAt;
}
