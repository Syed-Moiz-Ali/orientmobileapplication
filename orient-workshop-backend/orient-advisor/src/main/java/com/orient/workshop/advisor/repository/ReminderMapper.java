package com.orient.workshop.advisor.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.advisor.model.entity.Reminder;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface ReminderMapper extends BaseMapper<Reminder> {
    @Select("SELECT * FROM reminders WHERE is_completed = FALSE ORDER BY created_at DESC")
    List<Reminder> findActive();
}
