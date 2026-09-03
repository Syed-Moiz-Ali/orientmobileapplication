package com.orient.workshop.owner.repository;

import com.orient.workshop.owner.model.dto.OwnerAttendanceResponse;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDate;
import java.util.List;

@Mapper
public interface OwnerAttendanceMapper {
    @Select("""
            SELECT s.id AS staff_id, s.emp_id, s.name, s.role,
                   s.branch_id, s.branch, #{date} AS date,
                   COALESCE(a.status, 'notPunchedIn') AS status,
                   COALESCE(a.punch_in, '') AS punch_in,
                   COALESCE(a.punch_out, '') AS punch_out,
                   COALESCE(a.break_time, '') AS break_time,
                   COALESCE(a.work_hours, '') AS work_hours
              FROM staff s
              LEFT JOIN attendance a
                ON a.emp_id = s.emp_id AND a.date = #{date}
             WHERE s.is_active = TRUE
               AND s.role IN ('advisor', 'supervisor', 'technician')
               AND (#{branchId} IS NULL OR s.branch_id = #{branchId})
             ORDER BY s.role, s.name
            """)
    List<OwnerAttendanceResponse> findDailyAttendance(
            @Param("date") LocalDate date,
            @Param("branchId") Long branchId);
}
