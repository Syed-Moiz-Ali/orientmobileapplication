package com.orient.workshop.advisor.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.advisor.model.dto.CreateReminderRequest;
import com.orient.workshop.advisor.model.dto.ReminderResponse;
import com.orient.workshop.advisor.service.ReminderService;
import com.orient.workshop.common.response.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Advisor")
@RestController
@RequestMapping("/advisor/reminders")
@RequiredArgsConstructor
public class ReminderController {

    private final ReminderService reminderService;

    @GetMapping
    public ApiResponse<List<ReminderResponse>> getReminders() {
        return ApiResponse.success(reminderService.getReminders());
    }

    @PostMapping
    public ApiResponse<ReminderResponse> createReminder(@Valid @RequestBody CreateReminderRequest req) {
        return ApiResponse.success(reminderService.createReminder(req));
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> deleteReminder(@PathVariable Long id) {
        reminderService.deleteReminder(id);
        return ApiResponse.success(null);
    }
}

