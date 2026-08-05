package com.orient.workshop.owner.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.owner.model.entity.ActivityLog;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ActivityLogMapper extends BaseMapper<ActivityLog> {
}
