package com.orient.workshop.advisor.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.advisor.model.entity.Approval;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface ApprovalMapper extends BaseMapper<Approval> {
    @Select("SELECT * FROM approvals WHERE action = 'pending' ORDER BY created_at DESC")
    List<Approval> findPending();
}
