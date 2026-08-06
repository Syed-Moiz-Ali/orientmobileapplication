package com.orient.workshop.advisor.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.advisor.model.entity.RepairOrderServiceItem;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface RepairOrderServiceMapper extends BaseMapper<RepairOrderServiceItem> {

    @Select("SELECT * FROM repair_order_services WHERE repair_order_id = #{repairOrderId} ORDER BY id ASC")
    List<RepairOrderServiceItem> findByRepairOrderId(@Param("repairOrderId") Long repairOrderId);

    // P3 (audit): auto-pricing — average historical rate for a service name.
    @Select("SELECT AVG(rate) AS avg_rate, COUNT(*) AS cnt FROM repair_order_services " +
            "WHERE LOWER(name) LIKE CONCAT('%', LOWER(#{name}), '%')")
    java.util.Map<String, Object> avgRateForName(@Param("name") String name);
}
