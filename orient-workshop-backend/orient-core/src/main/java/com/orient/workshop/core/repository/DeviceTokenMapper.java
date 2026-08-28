package com.orient.workshop.core.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.core.model.entity.DeviceToken;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface DeviceTokenMapper extends BaseMapper<DeviceToken> {
    @Select("SELECT * FROM device_tokens WHERE user_id = #{userId}")
    List<DeviceToken> findByUserId(@Param("userId") Long userId);
}
