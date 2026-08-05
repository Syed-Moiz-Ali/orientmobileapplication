package com.orient.workshop.advisor.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.advisor.model.entity.RepairOrderPartItem;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface RepairOrderPartMapper extends BaseMapper<RepairOrderPartItem> {

    @Select("SELECT * FROM repair_order_parts WHERE repair_order_id = #{repairOrderId} ORDER BY id ASC")
    List<RepairOrderPartItem> findByRepairOrderId(@Param("repairOrderId") Long repairOrderId);
}
