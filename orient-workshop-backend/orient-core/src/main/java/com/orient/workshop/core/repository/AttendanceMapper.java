package com.orient.workshop.core.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.core.model.entity.Attendance;
import org.apache.ibatis.annotations.*;

import java.time.LocalDate;
import java.util.Optional;

@Mapper
public interface AttendanceMapper extends BaseMapper<Attendance> {
    @Select("SELECT * FROM attendance WHERE emp_id = #{empId} AND date = #{date} LIMIT 1")
    Optional<Attendance> findByEmpIdAndDate(@Param("empId") String empId, @Param("date") LocalDate date);
}
