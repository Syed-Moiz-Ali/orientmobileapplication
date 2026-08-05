package com.orient.workshop.core.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.core.model.entity.Breakdown;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface BreakdownMapper extends BaseMapper<Breakdown> {

    @Select("SELECT * FROM breakdowns WHERE advisor_id IS NULL ORDER BY created_at DESC")
    List<Breakdown> findUnassigned();

    @Select("SELECT * FROM breakdowns WHERE advisor_id = #{advisorId} ORDER BY created_at DESC")
    List<Breakdown> findByAdvisorId(@Param("advisorId") Long advisorId);
}
