package com.orient.workshop.advisor.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.advisor.model.entity.Inspection;
import org.apache.ibatis.annotations.*;

import java.util.Optional;

@Mapper
public interface InspectionMapper extends BaseMapper<Inspection> {
    @Select("SELECT * FROM inspections WHERE id = #{id} AND is_draft = TRUE LIMIT 1")
    Optional<Inspection> findDraftById(@Param("id") Long id);
}
