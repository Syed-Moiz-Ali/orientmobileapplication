package com.orient.workshop.core.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.core.model.entity.ActivityLog;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface CoreActivityLogMapper extends BaseMapper<ActivityLog> {
}
