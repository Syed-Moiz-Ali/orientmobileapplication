package com.orient.workshop.advisor.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.advisor.model.entity.RepairOrderPartItem;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface RepairOrderPartMapper extends BaseMapper<RepairOrderPartItem> {
}
