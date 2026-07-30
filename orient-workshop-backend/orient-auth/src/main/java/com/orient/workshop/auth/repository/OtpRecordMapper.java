package com.orient.workshop.auth.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.auth.model.entity.OtpRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.Optional;

@Mapper
public interface OtpRecordMapper extends BaseMapper<OtpRecord> {

    @Select("SELECT * FROM otp_records WHERE phone = #{phone} AND used = FALSE AND expires_at > NOW() ORDER BY id DESC LIMIT 1")
    Optional<OtpRecord> findValidByPhone(@Param("phone") String phone);

    @Select("SELECT * FROM otp_records WHERE email = #{email} AND used = FALSE AND expires_at > NOW() ORDER BY id DESC LIMIT 1")
    Optional<OtpRecord> findValidByEmail(@Param("email") String email);

    @Update("UPDATE otp_records SET used = TRUE WHERE id = #{id}")
    void markUsed(@Param("id") Long id);

    @Update("DELETE FROM otp_records WHERE expires_at < NOW()")
    void deleteExpired();
}
