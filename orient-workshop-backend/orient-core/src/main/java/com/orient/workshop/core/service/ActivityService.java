package com.orient.workshop.core.service;

import com.orient.workshop.core.model.entity.ActivityLog;
import com.orient.workshop.core.repository.CoreActivityLogMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * P1 (audit): the owner activity feed was always empty because nothing ever
 * wrote to activity_log. This is the single writer for workflow events.
 * Bean name avoids clashing with the owner module's ActivityService.
 * The `type` column is an ENUM: job_card|inspection|approval|invoice|parts|
 * payment|technician.
 */
@Slf4j
@Service("coreActivityService")
@RequiredArgsConstructor
public class ActivityService {

    private final CoreActivityLogMapper activityLogMapper;

    @Transactional
    public void log(String type, String title, String description, Long userId) {
        if (type == null || type.isBlank()) return;
        try {
            activityLogMapper.insert(ActivityLog.builder()
                    .type(type)
                    .title(title)
                    .description(description)
                    .userId(userId)
                    .build());
        } catch (Exception e) {
            // The feed must never break the workflow that triggered it.
            log.warn("activity log skipped ({}): {}", type, e.getMessage());
        }
    }
}
