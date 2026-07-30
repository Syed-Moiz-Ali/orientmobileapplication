package com.orient.workshop.owner.service;

import com.orient.workshop.owner.model.dto.MessageRequest;
import com.orient.workshop.owner.model.dto.MessageResponse;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicLong;

@Service
public class MessageService {

    private final List<MessageResponse> messages = new ArrayList<>();
    private final AtomicLong counter = new AtomicLong(0);

    {
        messages.add(msg("m1", "John Smith", "Parts have arrived for JC-1245", "2:30 PM"));
    }

    public List<MessageResponse> getMessages() {
        return messages;
    }

    public MessageResponse sendMessage(MessageRequest req) {
        String id = "m" + counter.incrementAndGet();
        MessageResponse msg = MessageResponse.builder()
                .id(id).recipient(req.getRecipient())
                .message(req.getMessage()).time(java.time.LocalTime.now().format(java.time.format.DateTimeFormatter.ofPattern("h:mm a")))
                .build();
        messages.add(0, msg);
        return msg;
    }

    private MessageResponse msg(String id, String recipient, String message, String time) {
        return MessageResponse.builder().id(id).recipient(recipient).message(message).time(time).build();
    }
}
