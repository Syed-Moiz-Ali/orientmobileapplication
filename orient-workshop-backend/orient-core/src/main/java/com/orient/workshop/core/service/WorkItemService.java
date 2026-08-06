package com.orient.workshop.core.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.exception.ForbiddenException;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.core.model.dto.*;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.model.entity.Staff;
import com.orient.workshop.core.model.entity.TechnicianTask;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.core.repository.StaffMapper;
import com.orient.workshop.core.repository.TechnicianTaskMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Phase 3 — per-item work tracking. Every inspection/work item has its own
 * row; the advisor assigns technicians per item, the technician advances each
 * item's status, and when ALL items of a job are completed the job moves to
 * the supervisor completion-review queue.
 */
@Service
@RequiredArgsConstructor
public class WorkItemService {

    private static final Set<String> VALID_ITEM_STATUSES = Set.of("pending", "inProgress", "completed");

    private final TechnicianTaskMapper taskMapper;
    private final JobCardMapper jobCardMapper;
    private final StaffMapper staffMapper;
    private final NotificationService notificationService;

    // ---------- Listing ----------

    public List<WorkItemResponse> listForJobCard(String jobCardRef) {
        // P1 (audit): batched staff lookup — empName() ran one query per task.
        List<TechnicianTask> tasks = taskMapper.findByJobCardNo(jobCardRef);
        return toResponses(tasks);
    }

    public List<WorkItemResponse> listMyItems(String empId) {
        if (empId == null || empId.isBlank()) return List.of();
        return toResponses(taskMapper.findByEmpId(empId));
    }

    private List<WorkItemResponse> toResponses(List<TechnicianTask> tasks) {
        if (tasks.isEmpty()) return List.of();
        List<String> empIds = tasks.stream()
                .map(TechnicianTask::getEmpId)
                .filter(e -> e != null && !e.isBlank())
                .distinct()
                .collect(Collectors.toList());
        Map<String, String> names = empIds.isEmpty() ? Map.of()
                : staffMapper.findByEmpIds(empIds).stream()
                        .collect(Collectors.toMap(Staff::getEmpId,
                                s -> s.getName() != null ? s.getName() : "",
                                (a, b) -> a));
        return tasks.stream().map(t -> toResponse(t, names)).collect(Collectors.toList());
    }

    // ---------- Assignment (advisor) ----------

    @Transactional
    public void assign(Long taskId, String empId) {
        TechnicianTask task = requireTask(taskId);
        Staff tech = requireTechnician(empId);
        task.setEmpId(tech.getEmpId());
        task.setRejectReason("");
        taskMapper.updateById(task);

        if (tech.getUserId() != null) {
            notificationService.emit(tech.getUserId(), null,
                    "workAssigned", "Work item assigned",
                    task.getDescription() + " · " + task.getJobCardNo());
        }
    }

    @Transactional
    public void assignBatch(AssignWorkItemBatchRequest req) {
        if (req.getItems() == null || req.getItems().isEmpty()) {
            throw new BadRequestException("At least one work item assignment is required");
        }
        for (AssignWorkItemBatchRequest.Item item : req.getItems()) {
            if (item.getTaskId() == null || item.getEmpId() == null || item.getEmpId().isBlank()) {
                throw new BadRequestException("taskId and empId are required for every assignment");
            }
            assign(item.getTaskId(), item.getEmpId());
        }
    }

    // ---------- Technician actions ----------

    @Transactional
    public void updateStatus(Long taskId, String empId, String status) {
        TechnicianTask task = requireTask(taskId);
        requireOwnership(task, empId);
        if (status == null || !VALID_ITEM_STATUSES.contains(status)) {
            throw new BadRequestException("Invalid status '" + status + "'. Allowed: pending, inProgress, completed");
        }
        task.setStatus(status);
        taskMapper.updateById(task);
        checkJobCompletion(task);
    }

    @Transactional
    public void start(Long taskId, String empId, String startTime) {
        TechnicianTask task = requireTask(taskId);
        requireOwnership(task, empId);
        task.setStatus("inProgress");
        task.setStartTime(startTime != null ? startTime : "");
        taskMapper.updateById(task);
    }

    @Transactional
    public void complete(Long taskId, String empId, String endTime) {
        TechnicianTask task = requireTask(taskId);
        requireOwnership(task, empId);
        task.setStatus("completed");
        task.setEndTime(endTime != null ? endTime : "");
        taskMapper.updateById(task);
        checkJobCompletion(task);
    }

    @Transactional
    public void updateNotes(Long taskId, String empId, String notes) {
        TechnicianTask task = requireTask(taskId);
        requireOwnership(task, empId);
        task.setDescription(task.getDescription() + (notes != null && !notes.isBlank()
                ? " — " + notes.trim() : ""));
        taskMapper.updateById(task);
    }

    // ---------- Completion gate ----------

    /**
     * Public gate used by the legacy task endpoints too: when every work item
     * of a job is completed the job moves to the supervisor review queue.
     */
    @Transactional
    public void checkJobCompletionAfterUpdate(String jobCardRef) {
        if (jobCardRef == null || jobCardRef.isBlank()) return;
        JobCard card = jobCardMapper.selectOne(
                new LambdaQueryWrapper<JobCard>().eq(JobCard::getJobCardRef, jobCardRef));
        if (card == null) return;
        moveToAwaitingIfComplete(card);
    }

    private void checkJobCompletion(TechnicianTask task) {
        moveToAwaitingIfComplete(jobCard(task.getJobCardNo()));
    }

    private JobCard jobCard(String jobCardRef) {
        return jobCardMapper.selectOne(
                new LambdaQueryWrapper<JobCard>().eq(JobCard::getJobCardRef, jobCardRef));
    }

    private void moveToAwaitingIfComplete(JobCard card) {
        if (card == null) return;
        if ("awaitingSupervisor".equals(card.getStatus())) return;
        if ("cancelled".equals(card.getStatus())) return;

        long incomplete = taskMapper.countIncomplete(card.getJobCardRef());
        if (incomplete == 0 && taskMapper.countTotal(card.getJobCardRef()) > 0) {
            card.setStatus("awaitingSupervisor");
            jobCardMapper.updateById(card);
            notifySupervisors(card);
        }
    }

    private void notifySupervisors(JobCard card) {
        List<Staff> supervisors = staffMapper.selectList(
                new LambdaQueryWrapper<Staff>()
                        .eq(Staff::getRole, "supervisor")
                        .eq(Staff::getIsActive, true)
                        .eq(card.getBranchId() != null && card.getBranchId() > 0,
                                Staff::getBranchId, card.getBranchId()));
        for (Staff s : supervisors) {
            if (s.getUserId() == null) continue;
            notificationService.emit(s.getUserId(), card.getBranchId(),
                    "jobAwaitingReview", "Job awaiting your review",
                    card.getJobCardRef() + " · all work items completed — approve or send back.");
        }
    }

    // ---------- helpers ----------

    private TechnicianTask requireTask(Long taskId) {
        TechnicianTask task = taskMapper.selectById(taskId);
        if (task == null) throw new NotFoundException("Work item not found");
        return task;
    }

    private Staff requireTechnician(String empId) {
        if (empId == null || empId.isBlank()) {
            throw new BadRequestException("empId is required");
        }
        return staffMapper.findByEmpId(empId)
                .orElseThrow(() -> new BadRequestException("Technician not found with empId: " + empId));
    }

    private void requireOwnership(TechnicianTask task, String empId) {
        if (empId == null || empId.isBlank()) {
            throw new ForbiddenException("Authenticated staff not found");
        }
        if (!empId.equals(task.getEmpId())) {
            throw new ForbiddenException("Work item is not assigned to the current user");
        }
    }

    private WorkItemResponse toResponse(TechnicianTask t, Map<String, String> empNames) {
        return WorkItemResponse.builder()
                .id(t.getId())
                .taskRef(t.getTaskRef())
                .jobCardRef(t.getJobCardNo())
                .description(t.getDescription())
                .itemType(t.getItemType() != null ? t.getItemType() : "WORK")
                .status(t.getStatus() != null ? t.getStatus() : "pending")
                .empId(t.getEmpId() != null ? t.getEmpId() : "")
                .empName(t.getEmpId() != null ? empNames.getOrDefault(t.getEmpId(), "") : "")
                .startTime(t.getStartTime() != null ? t.getStartTime() : "")
                .endTime(t.getEndTime() != null ? t.getEndTime() : "")
                .qty(t.getQty() != null ? t.getQty() : 1)
                .rate(t.getRate() != null ? t.getRate() : 0)
                .rejectReason(t.getRejectReason() != null ? t.getRejectReason() : "")
                .build();
    }
}
