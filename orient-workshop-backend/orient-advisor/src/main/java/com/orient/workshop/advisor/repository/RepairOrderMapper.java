package com.orient.workshop.advisor.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.advisor.model.entity.RepairOrder;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface RepairOrderMapper extends BaseMapper<RepairOrder> {

    @Select("SELECT * FROM repair_orders WHERE job_card_id = #{jobCardId} ORDER BY created_at DESC")
    List<RepairOrder> findByJobCardId(@Param("jobCardId") Long jobCardId);
}
