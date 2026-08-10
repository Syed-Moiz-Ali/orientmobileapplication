package com.orient.workshop.crm.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.orient.workshop.crm.model.dto.ConversationResponse;
import com.orient.workshop.crm.model.entity.CrmConversation;
import com.orient.workshop.crm.repository.CrmConversationMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ConversationService {

    private final CrmConversationMapper conversationMapper;

    public List<ConversationResponse> getConversations() {
        return conversationMapper.selectList(
                        new QueryWrapper<CrmConversation>().orderByDesc("updated_at"))
                .stream()
                .map(c -> ConversationResponse.builder()
                        .id(String.valueOf(c.getId()))
                        .ref(c.getRef())
                        .customerName(c.getCustomerName() != null ? c.getCustomerName() : "")
                        .lastMessage(c.getLastMessage() != null ? c.getLastMessage() : "")
                        .time(c.getTime() != null ? c.getTime() : "")
                        .channel(c.getChannel() != null ? c.getChannel() : "")
                        .unread(c.getUnread() != null ? c.getUnread() : 0)
                        .status(c.getStatus() != null ? c.getStatus() : "active")
                        .build())
                .collect(Collectors.toList());
    }
}
