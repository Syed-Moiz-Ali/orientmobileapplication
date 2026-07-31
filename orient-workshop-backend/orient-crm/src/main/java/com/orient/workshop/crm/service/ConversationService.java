package com.orient.workshop.crm.service;

import com.orient.workshop.crm.model.dto.ConversationResponse;
import com.orient.workshop.crm.repository.LeadMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.concurrent.atomic.AtomicLong;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ConversationService {

    private final LeadMapper leadMapper;
    private final AtomicLong counter = new AtomicLong(0);

    public List<ConversationResponse> getConversations() {
        return leadMapper.findPage(0, 100).stream()
                .map(l -> ConversationResponse.builder()
                        .id("c" + counter.incrementAndGet())
                        .customerName(l.getCustomerName())
                        .lastMessage("New lead from " + (l.getSource() != null && !l.getSource().isBlank() ? l.getSource() : "an unknown source"))
                        .time(l.getLastActivity() != null && !l.getLastActivity().isBlank() ? l.getLastActivity() : "")
                        .channel(l.getSource() != null ? l.getSource().toLowerCase() : "")
                        .unread(0)
                        .status(l.getStatus() != null ? l.getStatus().toLowerCase() : "active")
                        .build())
                .collect(Collectors.toList());
    }
}
