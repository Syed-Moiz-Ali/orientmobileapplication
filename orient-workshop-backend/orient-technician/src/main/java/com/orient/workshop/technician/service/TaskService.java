package com.orient.workshop.technician.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.exception.ForbiddenException;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.technician.model.dto.CompleteJobRequest;
import com.orient.workshop.technician.model.dto.TaskActionRequest;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.model.entity.Staff;
import com.orient.workshop.core.model.entity.TechnicianTask;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.core.repository.StaffMapper;
import com.orient.workshop.core.repository.TechnicianTaskMapper;
import com.orient.workshop.core.service.WorkItemService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TaskService {

    private final TechnicianTaskMapper taskMapper;
    private final StaffMapper staffMapper;
    private final JobCardMapper jobCardMapper;
    private final WorkItemService workItemService;

    @Transactional
    public void startTask(JwtUserPrincipal principal, String jobCardNo, String taskRef, TaskActionRequest req) {
        Staff staff = resolveStaff(principal);
        verifyOwnership(staff, jobCardNo);
        TechnicianTask task = findTask(jobCardNo, taskRef);
        task.setStatus("inProgress");
        task.setStartTime(req.getStartTime() != null ? req.getStartTime() : "");
        taskMapper.updateById(task);
    }

    @Transactional
    public void completeTask(JwtUserPrincipal principal, String jobCardNo, String taskRef, TaskActionRequest req) {
        Staff staff = resolveStaff(principal);
        verifyOwnership(staff, jobCardNo);
        TechnicianTask task = findTask(jobCardNo, taskRef);
        task.setStatus("completed");
        task.setEndTime(req.getEndTime() != null ? req.getEndTime() : "");
        taskMapper.updateById(task);
        // Seamless flow — when all work items are done the job moves to the
        // supervisor completion-review queue.
        workItemService.checkJobCompletionAfterUpdate(jobCardNo);
    }

    @Transactional
    public void updateTaskStatus(JwtUserPrincipal principal, String jobCardNo, String taskRef, TaskActionRequest req) {
        Staff staff = resolveStaff(principal);
        verifyOwnership(staff, jobCardNo);
        TechnicianTask task = findTask(jobCardNo, taskRef);
        task.setStatus(req.getStatus() != null ? req.getStatus() : task.getStatus());
        taskMapper.updateById(task);
        if ("completed".equals(task.getStatus())) {
            workItemService.checkJobCompletionAfterUpdate(jobCardNo);
        }
    }

    @Transactional
    public void completeJob(JwtUserPrincipal principal, CompleteJobRequest req) {
        Staff staff = resolveStaff(principal);
        verifyOwnership(staff, req.getJobCardNo());
        if (req.getTasks() != null) {
            for (CompleteJobRequest.TaskCompletion tc : req.getTasks()) {
                TechnicianTask task = taskMapper.selectOne(
                        new LambdaQueryWrapper<TechnicianTask>()
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

    private void verifyOwnership(Staff staff, String jobCardNo) {
        JobCard card = jobCardMapper.selectOne(
                new LambdaQueryWrapper<JobCard>()
                        .eq(JobCard::getJobCardRef, jobCardNo));
        if (card == null) throw new NotFoundException("Job card not found: " + jobCardNo);
        if (card.getTechnician() == null || !card.getTechnician().equals(staff.getName())) {
            throw new ForbiddenException("Job card is not assigned to the current user");
        }
    }

    private Staff resolveStaff(JwtUserPrincipal principal) {
        if (principal == null || principal.getUserId() == null) {
            throw new ForbiddenException("Authenticated user not found");
        }
        return staffMapper.findByUserId(principal.getUserId())
                .orElseThrow(() -> new ForbiddenException(
                        "No staff record linked to the authenticated user"));
    }

    private TechnicianTask findTask(String jobCardNo, String taskRef) {
        List<TechnicianTask> tasks = taskMapper.findByJobCardNo(jobCardNo);
        return tasks.stream()
                .filter(t -> t.getTaskRef().equals(taskRef))
                .findFirst()
                .orElseThrow(() -> new NotFoundException("Task not found: " + taskRef));
    }
}
