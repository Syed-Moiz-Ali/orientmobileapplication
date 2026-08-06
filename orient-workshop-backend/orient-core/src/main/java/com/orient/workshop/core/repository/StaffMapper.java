package com.orient.workshop.core.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.core.model.entity.Staff;
import org.apache.ibatis.annotations.*;

import java.util.List;
import java.util.Optional;

@Mapper
public interface StaffMapper extends BaseMapper<Staff> {
    @Select("SELECT * FROM staff WHERE emp_id = #{empId} AND is_active = TRUE LIMIT 1")
    Optional<Staff> findByEmpId(@Param("empId") String empId);

    @Select("SELECT * FROM staff WHERE user_id = #{userId} AND is_active = TRUE LIMIT 1")
    Optional<Staff> findByUserId(@Param("userId") Long userId);

    @Select("SELECT * FROM staff WHERE role = #{role} AND is_active = TRUE")
    List<Staff> findByRole(@Param("role") String role);

    @Select("SELECT * FROM staff WHERE role = #{role} AND branch_id = #{branchId} AND is_active = TRUE")
    List<Staff> findByRoleAndBranch(@Param("role") String role, @Param("branchId") Long branchId);

    // P1 (audit): batched lookup — work-item lists previously ran one query per staff.
    @Select("<script>SELECT * FROM staff WHERE emp_id IN <foreach collection='empIds' item='e' open='(' separator=',' close=')'>#{e}</foreach></script>")
    List<Staff> findByEmpIds(@Param("empIds") List<String> empIds);
}
