package com.orient.workshop.core.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.core.model.entity.ApiKey;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;
import java.util.Optional;

@Mapper
public interface ApiKeyMapper extends BaseMapper<ApiKey> {

    @Select("SELECT * FROM api_keys WHERE key_hash = #{hash} LIMIT 1")
    Optional<ApiKey> findByHash(@Param("hash") String hash);

    @Select("SELECT * FROM api_keys ORDER BY created_at DESC")
    List<ApiKey> findAllOrdered();

    @Update("UPDATE api_keys SET last_used_at = NOW() WHERE id = #{id}")
    void touch(@Param("id") Long id);
}
