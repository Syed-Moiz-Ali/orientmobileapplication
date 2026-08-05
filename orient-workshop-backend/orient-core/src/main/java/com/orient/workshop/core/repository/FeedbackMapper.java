package com.orient.workshop.core.repository;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.core.model.entity.Feedback;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface FeedbackMapper extends BaseMapper<Feedback> {

    @Select("SELECT * FROM feedback WHERE branch_id = #{branchId} ORDER BY created_at DESC LIMIT #{limit} OFFSET #{offset}")
    List<Feedback> findByBranchPaged(@Param("branchId") Long branchId, @Param("limit") int limit, @Param("offset") int offset);

    @Select("SELECT COUNT(*) FROM feedback WHERE branch_id = #{branchId}")
    long countByBranch(@Param("branchId") Long branchId);

    @Select("SELECT * FROM feedback ORDER BY created_at DESC LIMIT #{limit} OFFSET #{offset}")
    List<Feedback> findAllPaged(@Param("limit") int limit, @Param("offset") int offset);

    @Select("SELECT COUNT(*) FROM feedback")
    long countAll();
}
