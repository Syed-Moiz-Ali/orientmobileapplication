package com.orient.workshop.core.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.core.model.entity.TechnicianTask;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface TechnicianTaskMapper extends BaseMapper<TechnicianTask> {
    @Select("SELECT * FROM technician_tasks WHERE job_card_no = #{jobCardNo} ORDER BY task_ref ASC")
    List<TechnicianTask> findByJobCardNo(@Param("jobCardNo") String jobCardNo);
}
