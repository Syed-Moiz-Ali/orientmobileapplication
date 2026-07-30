package com.orient.workshop.auth.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.auth.model.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.Optional;

@Mapper
public interface UserMapper extends BaseMapper<User> {

    @Select("SELECT * FROM users WHERE phone = #{phone} AND is_active = TRUE LIMIT 1")
    Optional<User> findByPhone(@Param("phone") String phone);

    @Select("SELECT * FROM users WHERE email = #{email} AND is_active = TRUE LIMIT 1")
    Optional<User> findByEmail(@Param("email") String email);
}
