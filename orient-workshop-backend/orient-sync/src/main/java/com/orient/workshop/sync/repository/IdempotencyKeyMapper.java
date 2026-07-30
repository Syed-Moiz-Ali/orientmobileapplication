package com.orient.workshop.sync.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.sync.model.entity.IdempotencyRecord;
import org.apache.ibatis.annotations.*;

import java.util.Optional;

@Mapper
public interface IdempotencyKeyMapper extends BaseMapper<IdempotencyRecord> {
    @Select("SELECT * FROM idempotency_keys WHERE idempotency_key = #{key} LIMIT 1")
    Optional<IdempotencyRecord> findByKey(@Param("key") String key);
}
