package com.orient.workshop.core.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.core.model.entity.Notification;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface NotificationMapper extends BaseMapper<Notification> {

    @Select("SELECT * FROM notifications WHERE user_id = #{userId} ORDER BY created_at DESC")
    List<Notification> findByUserId(@Param("userId") Long userId);

    @Select("SELECT * FROM notifications WHERE user_id = #{userId} ORDER BY created_at DESC LIMIT #{limit} OFFSET #{offset}")
    List<Notification> findByUserIdPaged(@Param("userId") Long userId, @Param("limit") int limit, @Param("offset") int offset);

    @Update("UPDATE notifications SET is_read = TRUE WHERE user_id = #{userId}")
    void markAllRead(@Param("userId") Long userId);
}
