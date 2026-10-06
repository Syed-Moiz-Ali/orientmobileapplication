package com.orient.workshop.media.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.media.model.entity.MediaAsset;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface MediaAssetMapper extends BaseMapper<MediaAsset> {

    @Select("SELECT * FROM media_assets WHERE module = #{module} AND record_id = #{recordId} "
            + "ORDER BY created_at DESC, id DESC")
    List<MediaAsset> findByRecord(@Param("module") String module, @Param("recordId") String recordId);
}
