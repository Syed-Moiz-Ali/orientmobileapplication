package com.orient.workshop.whatsapp.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.whatsapp.model.entity.CrmConversation;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface WhatsappConversationMapper extends BaseMapper<CrmConversation> {

    @Select("SELECT * FROM crm_conversations WHERE customer_name = #{customerName} AND channel = #{channel} ORDER BY id DESC LIMIT 1")
    CrmConversation findLatestByNameAndChannel(@Param("customerName") String customerName,
                                               @Param("channel") String channel);

    @Select("SELECT * FROM crm_conversations ORDER BY updated_at DESC")
    List<CrmConversation> findAllOrdered();
}
