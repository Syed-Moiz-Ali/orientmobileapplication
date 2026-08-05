package com.orient.workshop.owner.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.orient.workshop.owner.model.dto.ActivityResponse;
import com.orient.workshop.owner.model.entity.ActivityLog;
import com.orient.workshop.owner.repository.ActivityLogMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ActivityService {

    private final ActivityLogMapper activityLogMapper;

    public List<ActivityResponse> getActivity(int page, int limit) {
        int offset = Math.max(page - 1, 0) * Math.max(limit, 1);
        List<ActivityLog> rows = activityLogMapper.selectList(
                new QueryWrapper<ActivityLog>()
                        .orderByDesc("created_at")
                        .last("LIMIT " + Math.max(limit, 1) + " OFFSET " + offset));
        return rows.stream()
                .map(a -> ActivityResponse.builder()
                        .id(String.valueOf(a.getId()))
                        .type(a.getType() != null ? a.getType() : "")
                        .title(a.getTitle() != null ? a.getTitle() : "")
                        .description(a.getDescription() != null ? a.getDescription() : "")
                        .timestamp(a.getCreatedAt() != null ? a.getCreatedAt().toString() : "")
                        .build())
                .collect(Collectors.toList());
    }
}
