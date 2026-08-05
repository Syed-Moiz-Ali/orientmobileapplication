package com.orient.workshop.advisor.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.advisor.model.entity.RepairOrderServiceItem;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface RepairOrderServiceMapper extends BaseMapper<RepairOrderServiceItem> {
}
