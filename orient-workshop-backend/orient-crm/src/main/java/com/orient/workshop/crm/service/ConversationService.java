package com.orient.workshop.crm.service;

import com.orient.workshop.crm.model.dto.ConversationResponse;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.concurrent.atomic.AtomicLong;

@Service
public class ConversationService {

    private final AtomicLong counter = new AtomicLong(0);

    public List<ConversationResponse> getConversations() {
        return List.of(
            conv("Ahmed Hassan", "When can I bring my car in?", "2 min ago", "whatsapp", 2, "active"),
            conv("John Anderson", "Thanks for the quick service!", "15 min ago", "instagram", 0, "active"),
            conv("Sarah Williams", "Is the estimate ready?", "1 hour ago", "whatsapp", 1, "active"),
            conv("Mike Brown", "I need to reschedule", "3 hours ago", "email", 0, "active"),
            conv("Lisa Chen", "How much for brake replacement?", "1 day ago", "website", 0, "inactive")
        );
    }

    private ConversationResponse conv(String name, String msg, String time, String channel, int unread, String status) {
        return ConversationResponse.builder()
                .id("c" + counter.incrementAndGet()).customerName(name).lastMessage(msg)
                .time(time).channel(channel).unread(unread).status(status).build();
    }
}
