package com.orient.workshop.crm.service;

import com.orient.workshop.crm.model.dto.CrmTaskResponse;
import com.orient.workshop.crm.model.dto.UpdateTaskRequest;
import com.orient.workshop.crm.model.entity.CrmTask;
import com.orient.workshop.crm.repository.CrmTaskMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CrmTaskService {

    private final CrmTaskMapper taskMapper;

    public List<CrmTaskResponse> getTasks() {
        return taskMapper.selectList(null).stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Transactional
    public void updateTask(Long id, UpdateTaskRequest req) {
        CrmTask task = taskMapper.selectById(id);
        if (task != null) {
            task.setIsDone(req.isDone());
            taskMapper.updateById(task);
        }
    }

    private CrmTaskResponse toResponse(CrmTask t) {
        return CrmTaskResponse.builder()
                .id(String.valueOf(t.getId()))
                .title(t.getTitle())
                .assignedTo(t.getAssignedTo())
                .dueDate(t.getDueDate())
                .priority(t.getPriority())
                .isDone(t.getIsDone() != null && t.getIsDone())
                .build();
    }
}
