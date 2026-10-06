package com.orient.workshop.media.model.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Index row for an uploaded media file. The bytes live on the media
 * filesystem; this row records the module/record it belongs to and its URL so
 * the file can be listed and served later.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("media_assets")
public class MediaAsset {
    @TableId(type = IdType.AUTO)
    private Long id;
    @TableField(fill = FieldFill.INSERT)
    private String ref;
    private String tenant;
    private String module;
    private String recordId;
    private String itemId;
    private String mediaType;
    private String url;
    private String note;
    private String fileName;
    private String contentType;
    private Long sizeBytes;
    private Long createdBy;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
