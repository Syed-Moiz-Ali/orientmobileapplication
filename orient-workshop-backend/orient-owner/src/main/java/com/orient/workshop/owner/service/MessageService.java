package com.orient.workshop.owner.service;

import com.orient.workshop.owner.model.dto.MessageRequest;
import com.orient.workshop.owner.model.dto.MessageResponse;
import com.orient.workshop.owner.model.entity.Message;
import com.orient.workshop.owner.repository.MessageMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MessageService {

    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("h:mm a");

    private final MessageMapper messageMapper;

    public List<MessageResponse> getMessages(int page, int size) {
        int offset = Math.max(page - 1, 0) * size;
        return messageMapper.findPaged(size, offset).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public MessageResponse sendMessage(MessageRequest req) {
        Message msg = Message.builder()
                .recipient(req.getRecipient())
                .message(req.getMessage())
                .build();
        messageMapper.insert(msg);
        return toResponse(msg);
    }

    private MessageResponse toResponse(Message m) {
        return MessageResponse.builder()
                .id(String.valueOf(m.getId()))
                .recipient(m.getRecipient())
                .message(m.getMessage())
                .time(m.getCreatedAt() != null ? m.getCreatedAt().format(TIME_FMT) : "")
                .build();
    }
}
