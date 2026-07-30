package com.orient.workshop.core.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.core.model.entity.Staff;
import org.apache.ibatis.annotations.*;

import java.util.Optional;

@Mapper
public interface StaffMapper extends BaseMapper<Staff> {
    @Select("SELECT * FROM staff WHERE emp_id = #{empId} AND is_active = TRUE LIMIT 1")
    Optional<Staff> findByEmpId(@Param("empId") String empId);
}
