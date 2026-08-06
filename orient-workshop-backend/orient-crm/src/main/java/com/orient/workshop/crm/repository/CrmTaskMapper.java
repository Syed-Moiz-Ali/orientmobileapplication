package com.orient.workshop.crm.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.crm.model.entity.CrmTask;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface CrmTaskMapper extends BaseMapper<CrmTask> {

    @Select("SELECT * FROM crm_tasks ORDER BY id DESC LIMIT #{limit} OFFSET #{offset}")
    List<CrmTask> findPaged(@Param("limit") int limit, @Param("offset") int offset);
}
