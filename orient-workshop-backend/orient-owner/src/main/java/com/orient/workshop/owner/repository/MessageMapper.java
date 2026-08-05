package com.orient.workshop.owner.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.owner.model.entity.Message;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface MessageMapper extends BaseMapper<Message> {

    @Select("SELECT * FROM messages ORDER BY created_at DESC LIMIT #{limit} OFFSET #{offset}")
    List<Message> findPaged(@Param("limit") int limit, @Param("offset") int offset);
}
