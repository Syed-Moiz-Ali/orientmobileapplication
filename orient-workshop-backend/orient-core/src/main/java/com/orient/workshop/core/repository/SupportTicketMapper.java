package com.orient.workshop.core.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.core.model.entity.SupportTicket;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface SupportTicketMapper extends BaseMapper<SupportTicket> {

    @Select("SELECT * FROM support_tickets WHERE customer_id = #{customerId} ORDER BY created_at DESC LIMIT #{limit} OFFSET #{offset}")
    List<SupportTicket> findByCustomerPaged(@Param("customerId") Long customerId,
                                            @Param("limit") int limit, @Param("offset") int offset);

    @Select("SELECT * FROM support_tickets ORDER BY created_at DESC LIMIT #{limit} OFFSET #{offset}")
    List<SupportTicket> findPaged(@Param("limit") int limit, @Param("offset") int offset);
}
