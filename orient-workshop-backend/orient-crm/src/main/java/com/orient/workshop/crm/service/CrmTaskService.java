package com.orient.workshop.crm.service;

import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.crm.model.dto.CrmTaskRequest;
import com.orient.workshop.crm.model.dto.CrmTaskResponse;
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

    public List<CrmTaskResponse> getTasks(int page, int size) {
        // P1 (audit): page/size were accepted by the controller but ignored —
        // every call returned the entire task table.
        int limit = Math.min(Math.max(size, 1), 100);
        int offset = Math.max(page - 1, 0) * limit;
        return taskMapper.findPaged(limit, offset).stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Transactional
    public CrmTaskResponse createTask(CrmTaskRequest req) {
        if (req.getTitle() == null || req.getTitle().isBlank()) {
            throw new BadRequestException("Task title is required");
        }
        CrmTask task = CrmTask.builder()
                .title(req.getTitle())
                .assignedTo(req.getAssignedTo() != null ? req.getAssignedTo() : "")
                .dueDate(req.getDueDate() != null ? req.getDueDate() : "")
                .priority(req.getPriority() != null ? req.getPriority() : "Medium")
                .isDone(req.getIsDone() != null && req.getIsDone())
                .build();
        taskMapper.insert(task);
        return toResponse(task);
    }

    @Transactional
    public CrmTaskResponse updateTask(Long id, CrmTaskRequest req) {
        CrmTask task = taskMapper.selectById(id);
        if (task == null) throw new NotFoundException("Task not found with id: " + id);
        if (req.getTitle() != null) task.setTitle(req.getTitle());
        if (req.getAssignedTo() != null) task.setAssignedTo(req.getAssignedTo());
        if (req.getDueDate() != null) task.setDueDate(req.getDueDate());
        if (req.getPriority() != null) task.setPriority(req.getPriority());
        if (req.getIsDone() != null) task.setIsDone(req.getIsDone());
        taskMapper.updateById(task);
        return toResponse(task);
    }

    @Transactional
    public void deleteTask(Long id) {
        if (taskMapper.selectById(id) == null) throw new NotFoundException("Task not found with id: " + id);
        taskMapper.deleteById(id);
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
