package com.orient.workshop.core.model.entity;
import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("whatsapp_messages")
public class WhatsappMessage {
    @TableId(type = IdType.AUTO) private Long id;
    // P1 (V13): prefixed unique ref (public identifier).
    @TableField(fill = FieldFill.INSERT)
    // P1 (V13): prefixed unique ref (public identifier).
    private String ref;
    private Long branchId;
    private String customerPhone;
    private String templateName;
    private String messageBody;
    private String status;
    private String messageType;
    private String externalId;
    @TableField(fill = FieldFill.INSERT) private LocalDateTime sentAt;
}
