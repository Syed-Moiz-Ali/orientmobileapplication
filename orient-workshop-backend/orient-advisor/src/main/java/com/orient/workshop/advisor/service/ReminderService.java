package com.orient.workshop.advisor.service;

import com.orient.workshop.advisor.model.dto.CreateReminderRequest;
import com.orient.workshop.advisor.model.dto.ReminderResponse;
import com.orient.workshop.advisor.model.entity.Reminder;
import com.orient.workshop.advisor.repository.ReminderMapper;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.common.util.IdGenerator;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReminderService {

    private final ReminderMapper reminderMapper;

    public List<ReminderResponse> getReminders() {
        // Fix: soft-delete persisted via the `deleted` column (V2) — the old
        // in-memory set resurrected deleted reminders on every restart.
        return reminderMapper.findActive().stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public ReminderResponse createReminder(CreateReminderRequest req) {
        String ref = IdGenerator.shortRef("REM");
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
        if (Boolean.TRUE.equals(r.getIsCompleted())) {
            throw new NotFoundException("Reminder not found");
        }
        // Fix: persisted soft delete.
        r.setDeleted(true);
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
