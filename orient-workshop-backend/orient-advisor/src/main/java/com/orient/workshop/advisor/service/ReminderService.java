package com.orient.workshop.advisor.service;

import com.orient.workshop.advisor.model.dto.CreateReminderRequest;
import com.orient.workshop.advisor.model.dto.ReminderResponse;
import com.orient.workshop.advisor.model.entity.Reminder;
import com.orient.workshop.advisor.repository.ReminderMapper;
import com.orient.workshop.common.exception.NotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReminderService {

    private final ReminderMapper reminderMapper;
    private long counter = 0;

    public List<ReminderResponse> getReminders() {
        return reminderMapper.findActive().stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Transactional
    public ReminderResponse createReminder(CreateReminderRequest req) {
        String ref = "REM-" + String.format("%03d", ++counter);
        Reminder r = Reminder.builder()
                .reminderRef(ref)
                .customerName(req.getCustomerName())
                .vehicleId(req.getVehicleId())
                .task(req.getTask())
                .dueDate(req.getDueDate())
                .priority(req.getPriority() != null ? req.getPriority() : "medium")
                .isCompleted(false)
                .build();
        reminderMapper.insert(r);
        return toResponse(r);
    }

    @Transactional
    public void deleteReminder(Long id) {
        Reminder r = reminderMapper.selectById(id);
        if (r == null) throw new NotFoundException("Reminder not found");
        r.setIsCompleted(true);
        reminderMapper.updateById(r);
    }

    private ReminderResponse toResponse(Reminder r) {
        return ReminderResponse.builder()
                .id(r.getReminderRef())
                .customerName(r.getCustomerName())
                .vehicleId(r.getVehicleId())
                .task(r.getTask())
                .dueDate(r.getDueDate())
                .priority(r.getPriority())
                .build();
    }
}
