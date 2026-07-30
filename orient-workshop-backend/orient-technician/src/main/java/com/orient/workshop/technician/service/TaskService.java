package com.orient.workshop.technician.service;

import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.technician.model.dto.CompleteJobRequest;
import com.orient.workshop.technician.model.dto.TaskActionRequest;
import com.orient.workshop.core.model.entity.TechnicianTask;
import com.orient.workshop.core.repository.TechnicianTaskMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TaskService {

    private final TechnicianTaskMapper taskMapper;

    @Transactional
    public void startTask(String jobCardNo, String taskRef, TaskActionRequest req) {
        TechnicianTask task = findTask(jobCardNo, taskRef);
        task.setStatus("inProgress");
        task.setStartTime(req.getStartTime() != null ? req.getStartTime() : "");
        taskMapper.updateById(task);
    }

    @Transactional
    public void completeTask(String jobCardNo, String taskRef, TaskActionRequest req) {
        TechnicianTask task = findTask(jobCardNo, taskRef);
        task.setStatus("completed");
        task.setEndTime(req.getEndTime() != null ? req.getEndTime() : "");
        taskMapper.updateById(task);
    }

    @Transactional
    public void updateTaskStatus(String jobCardNo, String taskRef, TaskActionRequest req) {
        TechnicianTask task = findTask(jobCardNo, taskRef);
        task.setStatus(req.getStatus() != null ? req.getStatus() : task.getStatus());
        taskMapper.updateById(task);
    }

    @Transactional
    public void completeJob(CompleteJobRequest req) {
        if (req.getTasks() != null) {
            for (CompleteJobRequest.TaskCompletion tc : req.getTasks()) {
                TechnicianTask task = taskMapper.selectOne(
                        new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<TechnicianTask>()
                                .eq(TechnicianTask::getJobCardNo, req.getJobCardNo())
                                .eq(TechnicianTask::getTaskRef, tc.getId()));
                if (task != null) {
                    task.setStatus(tc.getStatus() != null ? tc.getStatus() : "completed");
                    task.setStartTime(tc.getStartTime());
                    task.setEndTime(tc.getEndTime());
                    taskMapper.updateById(task);
                }
            }
        }
    }

    private TechnicianTask findTask(String jobCardNo, String taskRef) {
        List<TechnicianTask> tasks = taskMapper.findByJobCardNo(jobCardNo);
        return tasks.stream()
                .filter(t -> t.getTaskRef().equals(taskRef))
                .findFirst()
                .orElseThrow(() -> new NotFoundException("Task not found: " + taskRef));
    }
}
