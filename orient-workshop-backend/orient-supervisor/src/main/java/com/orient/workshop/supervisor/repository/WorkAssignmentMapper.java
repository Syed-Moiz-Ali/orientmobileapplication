package com.orient.workshop.supervisor.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.supervisor.model.entity.WorkAssignment;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface WorkAssignmentMapper extends BaseMapper<WorkAssignment> {
    @Select("SELECT * FROM work_assignments ORDER BY created_at DESC")
    List<WorkAssignment> findAll();
}
