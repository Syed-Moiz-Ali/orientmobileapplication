package com.orient.workshop.sync.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.sync.model.entity.SyncLog;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.Optional;

@Mapper
public interface SyncLogMapper extends BaseMapper<SyncLog> {

    @Select("SELECT * FROM sync_logs WHERE idempotency_key = #{key} ORDER BY id DESC LIMIT 1")
    Optional<SyncLog> findByKey(@Param("key") String key);
}
