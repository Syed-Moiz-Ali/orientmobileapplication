package com.orient.workshop.advisor.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.advisor.model.entity.RepairOrder;
import org.apache.ibatis.annotations.*;

@Mapper
public interface RepairOrderMapper extends BaseMapper<RepairOrder> {
}
