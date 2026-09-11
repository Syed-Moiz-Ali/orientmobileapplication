package com.orient.workshop.auth.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.auth.model.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.Optional;

@Mapper
public interface UserMapper extends BaseMapper<User> {

    // Identity lookups include inactive users. Authentication services decide
    // whether access is allowed; filtering here made inactive accounts look
    // nonexistent and also bypassed friendly duplicate/inactive validation.
    @Select("SELECT * FROM users WHERE phone = #{phone} LIMIT 1")
    Optional<User> findByPhone(@Param("phone") String phone);

    @Select("SELECT * FROM users WHERE email = #{email} LIMIT 1")
    Optional<User> findByEmail(@Param("email") String email);
}
