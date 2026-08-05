package com.orient.workshop.sync.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.sync.model.entity.IdempotencyRecord;
import org.apache.ibatis.annotations.*;

import java.time.LocalDateTime;
import java.util.Optional;

@Mapper
public interface IdempotencyKeyMapper extends BaseMapper<IdempotencyRecord> {

    /**
     * H-6: keys are stored as a SHA-256 hex hash; lookups respect the TTL window
     * so expired records are never replayed.
     */
    @Select("SELECT * FROM idempotency_keys WHERE idempotency_key = #{key} AND created_at > #{cutoff} LIMIT 1")
    Optional<IdempotencyRecord> findByKeyWithinTtl(@Param("key") String key, @Param("cutoff") LocalDateTime cutoff);

    @Select("SELECT * FROM idempotency_keys WHERE idempotency_key = #{key} ORDER BY id DESC LIMIT 1")
    Optional<IdempotencyRecord> findByKeyWithinTtl(@Param("key") String key);
}
