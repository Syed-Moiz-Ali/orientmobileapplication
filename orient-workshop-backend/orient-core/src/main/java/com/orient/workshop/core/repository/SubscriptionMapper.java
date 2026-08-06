package com.orient.workshop.core.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.core.model.entity.Subscription;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.Optional;

@Mapper
public interface SubscriptionMapper extends BaseMapper<Subscription> {

    @Select("SELECT * FROM subscriptions WHERE branch_id = #{branchId} LIMIT 1")
    Optional<Subscription> findByBranchId(@Param("branchId") Long branchId);
}
