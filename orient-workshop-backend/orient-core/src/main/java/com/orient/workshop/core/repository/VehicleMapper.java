package com.orient.workshop.core.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.core.model.entity.Vehicle;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface VehicleMapper extends BaseMapper<Vehicle> {

    @Select("SELECT * FROM vehicles WHERE customer_id = #{customerId} ORDER BY id DESC")
    List<Vehicle> findByCustomerId(@Param("customerId") Long customerId);

    @Select("SELECT * FROM vehicles WHERE customer_id = #{customerId} AND branch_id = #{branchId} ORDER BY id DESC")
    List<Vehicle> findByCustomerIdAndBranch(@Param("customerId") Long customerId, @Param("branchId") Long branchId);

    @Select("SELECT * FROM vehicles WHERE registration_number LIKE CONCAT('%',#{q},'%') " +
            "OR vin LIKE CONCAT('%',#{q},'%') OR plate_number LIKE CONCAT('%',#{q},'%') LIMIT 20")
    List<Vehicle> search(@Param("q") String q);
}
