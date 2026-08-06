package com.orient.workshop.core.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.core.model.entity.WebhookSubscription;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface WebhookSubscriptionMapper extends BaseMapper<WebhookSubscription> {

    @Select("SELECT * FROM webhook_subscriptions WHERE event_type = #{eventType} AND is_active = TRUE")
    List<WebhookSubscription> findActiveByEvent(@Param("eventType") String eventType);
}
