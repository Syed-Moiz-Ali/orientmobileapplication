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

    @Select("SELECT * FROM refresh_tokens WHERE token = #{token} LIMIT 1")
    Optional<RefreshTokenEntity> findByToken(@Param("token") String token);

    @Update("UPDATE refresh_tokens SET revoked = TRUE WHERE user_id = #{userId}")
    void revokeByUserId(@Param("userId") Long userId);

    @Update("UPDATE refresh_tokens SET revoked = TRUE WHERE id = #{id}")
    void revokeById(@Param("id") Long id);

    /**
     * Atomic conditional revoke: only one caller can rotate a given token.
     * Returns the number of affected rows (1 = this request won the rotation,
     * 0 = token was already revoked by a concurrent/previous request).
     */
    @Update("UPDATE refresh_tokens SET revoked = TRUE WHERE id = #{id} AND revoked = FALSE")
    int revokeByIdIfNotRevoked(@Param("id") Long id);
}
