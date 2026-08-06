package com.orient.workshop.core.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.core.model.entity.Warranty;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface WarrantyMapper extends BaseMapper<Warranty> {

    @Select("SELECT * FROM warranties WHERE vehicle_id = #{vehicleId} ORDER BY end_date DESC")
    List<Warranty> findByVehicleId(@Param("vehicleId") Long vehicleId);
}
