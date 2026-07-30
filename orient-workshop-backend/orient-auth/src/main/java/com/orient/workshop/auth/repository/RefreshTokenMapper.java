package com.orient.workshop.auth.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.auth.model.entity.RefreshTokenEntity;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.Optional;

@Mapper
public interface RefreshTokenMapper extends BaseMapper<RefreshTokenEntity> {

    @Select("SELECT * FROM refresh_tokens WHERE token = #{token} AND revoked = FALSE AND expires_at > NOW() LIMIT 1")
    Optional<RefreshTokenEntity> findValidByToken(@Param("token") String token);

    @Update("UPDATE refresh_tokens SET revoked = TRUE WHERE user_id = #{userId}")
    void revokeByUserId(@Param("userId") Long userId);

    @Update("UPDATE refresh_tokens SET revoked = TRUE WHERE id = #{id}")
    void revokeById(@Param("id") Long id);
}
