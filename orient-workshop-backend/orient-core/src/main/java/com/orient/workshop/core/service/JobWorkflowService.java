package com.orient.workshop.core.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.exception.ForbiddenException;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.model.entity.Staff;
import com.orient.workshop.core.model.entity.TechnicianTask;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.core.repository.StaffMapper;
import com.orient.workshop.core.repository.TechnicianTaskMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class JobWorkflowService {

    public static final String WORK_IN_PROGRESS = "inProgress";
    public static final String WAITING_PARTS = "waitingParts";
    public static final String AWAITING_QC = "awaitingSupervisor";
    public static final String READY_FOR_COLLECTION = "completed";
    public static final String DELIVERED = "delivered";
    public static final String CANCELLED = "cancelled";

    private static final Set<String> QC_READY_STATES = Set.of(AWAITING_QC, "qualityCheck");
    private static final Set<String> ADVISOR_OPERATIONAL_STATES = Set.of(
            WORK_IN_PROGRESS, WAITING_PARTS, "pending", "pendingApproval",
            "vehicleReceived", "waitingCustomerApproval", "qualityCheck");

    private final JobCardMapper jobCardMapper;
    private final TechnicianTaskMapper taskMapper;
    private final StaffMapper staffMapper;
    private final CustomerMapper customerMapper;
    private final NotificationService notificationService;
    private final ActivityService activityService;
    private final WebhookService webhookService;
    private final List<JobInvoiceGateway> invoiceGateways;

    @Transactional
    public void submitForQcIfAllWorkComplete(String jobCardRef) {
        if (jobCardRef == null || jobCardRef.isBlank()) return;
        JobCard card = findByRef(jobCardRef);
        if (card != null) submitForQcIfAllWorkComplete(card);
    }

    @Transactional
    public void submitForQcIfAllWorkComplete(JobCard card) {
        if (card == null || AWAITING_QC.equals(card.getStatus()) || CANCELLED.equals(card.getStatus())) return;
        long total = taskMapper.countTotal(card.getJobCardRef());
        if (total == 0 || taskMapper.countIncomplete(card.getJobCardRef()) != 0) return;
        transition(card, AWAITING_QC);
        notifySupervisors(card);
        activityService.log("job_card", "Ready for QC",
                "Job " + card.getJobCardRef() + " submitted for supervisor QC", null);
        webhookService.dispatch("job.qc.awaiting", Map.of("jobCardRef", card.getJobCardRef()));
    }

    @Transactional
    public void approveQc(Long jobCardId, Long branchId, Long userId) {
        approveQc(requireById(jobCardId), branchId, userId);
    }

    @Transactional
    public void approveQcByRef(String jobCardRef, Long branchId, Long userId) {
        approveQc(requireByRef(jobCardRef), branchId, userId);
    }

    @Transactional
    public void rejectQc(Long jobCardId, Long branchId, Long userId, String reason) {
        rejectQc(requireById(jobCardId), branchId, userId, reason);
    }

    @Transactional
    public void rejectQcByRef(String jobCardRef, Long branchId, Long userId, String reason) {
        rejectQc(requireByRef(jobCardRef), branchId, userId, reason);
    }

    @Transactional
    public void deliverByRef(String jobCardRef, Long branchId, Long userId) {
        deliver(requireByRef(jobCardRef), branchId, userId);
    }

    @Transactional
    public void deliverById(Long jobCardId, Long branchId, Long userId) {
        deliver(requireById(jobCardId), branchId, userId);
    }

    @Transactional
    public void cancel(Long jobCardId, Long branchId, Long userId) {
        JobCard card = requireById(jobCardId);
        requireBranchAccess(branchId, card.getBranchId());
        if (DELIVERED.equals(card.getStatus())) throw new BadRequestException("Delivered jobs cannot be cancelled");
        transition(card, CANCELLED);
        activityService.log("job_card", "Job cancelled", "Job " + card.getJobCardRef() + " cancelled", userId);
        webhookService.dispatch("job.cancelled", Map.of("jobCardRef", card.getJobCardRef()));
    }

    @Transactional
    public void advisorOperationalStatus(String idOrRef, String status, Long branchId) {
        if (status == null || !ADVISOR_OPERATIONAL_STATES.contains(status)) {
            throw new BadRequestException("Use workflow command endpoints for final job states");
        }
        JobCard card = requireByIdOrRef(idOrRef);
        requireBranchAccess(branchId, card.getBranchId());
        if (Set.of(READY_FOR_COLLECTION, DELIVERED, CANCELLED).contains(card.getStatus())) {
            throw new BadRequestException("Final job cards cannot be moved with a raw status update");
        }
        transition(card, status);
    }

    private void approveQc(JobCard card, Long branchId, Long userId) {
        requireBranchAccess(branchId, card.getBranchId());
        requireState(card, QC_READY_STATES, "QC approval requires a job awaiting supervisor review");
        requireAllWorkComplete(card);
        transition(card, READY_FOR_COLLECTION);
        notifyCustomerReady(card);
        invoiceGateways.stream().findFirst().ifPresent(gateway -> gateway.createFromJobCard(card.getId()));
        activityService.log("invoice", "Invoice raised",
                "Invoice for completed job " + card.getJobCardRef(), userId);
        webhookService.dispatch("job.completed", Map.of("jobCardRef", card.getJobCardRef()));
    }

    private void rejectQc(JobCard card, Long branchId, Long userId, String reason) {
        requireBranchAccess(branchId, card.getBranchId());
        requireState(card, QC_READY_STATES, "QC rejection requires a job awaiting supervisor review");
        String resolvedReason = reason != null && !reason.isBlank() ? reason.trim() : "Work needs revision";
        transition(card, WORK_IN_PROGRESS);
        for (TechnicianTask task : taskMapper.findByJobCardNo(card.getJobCardRef())) {
            if (!"completed".equals(task.getStatus())) continue;
            task.setStatus("pending");
            task.setRejectReason(resolvedReason);
            taskMapper.updateById(task);
            notifyTechnicianRevision(card, task, resolvedReason);
        }
        activityService.log("job_card", "QC rejected",
                "Job " + card.getJobCardRef() + " sent back: " + resolvedReason, userId);
        webhookService.dispatch("job.qc.rejected", Map.of("jobCardRef", card.getJobCardRef()));
    }

    private void deliver(JobCard card, Long branchId, Long userId) {
        requireBranchAccess(branchId, card.getBranchId());
        requireState(card, Set.of(READY_FOR_COLLECTION, "qualityCheckPassed"),
                "Vehicle delivery requires successful QC and invoice readiness");
        transition(card, DELIVERED);
        activityService.log("job_card", "Vehicle delivered",
                "Job " + card.getJobCardRef() + " marked delivered", userId);
        webhookService.dispatch("job.delivered", Map.of("jobCardRef", card.getJobCardRef()));
    }

    private void requireAllWorkComplete(JobCard card) {
        if (taskMapper.countTotal(card.getJobCardRef()) == 0 || taskMapper.countIncomplete(card.getJobCardRef()) != 0) {
            throw new BadRequestException("QC approval requires all technician work items to be completed");
        }
    }

    private void transition(JobCard card, String status) {
        card.setStatus(status);
        card.setUpdatedAt(LocalDateTime.now());
        jobCardMapper.updateById(card);
    }

    private JobCard requireByIdOrRef(String idOrRef) {
        if (idOrRef == null || idOrRef.isBlank()) throw new NotFoundException("Job card not found");
        if (idOrRef.matches("\\d+")) {
            JobCard byId = jobCardMapper.selectById(Long.valueOf(idOrRef));
            if (byId != null) return byId;
        }
        return requireByRef(idOrRef);
    }

    private JobCard requireById(Long id) {
        JobCard card = id != null ? jobCardMapper.selectById(id) : null;
        if (card == null) throw new NotFoundException("Job card not found");
        return card;
    }

    private JobCard requireByRef(String jobCardRef) {
        JobCard card = findByRef(jobCardRef);
        if (card == null) throw new NotFoundException("Job card not found");
        return card;
    }

    private JobCard findByRef(String jobCardRef) {
        if (jobCardRef == null || jobCardRef.isBlank()) return null;
        return jobCardMapper.selectOne(new QueryWrapper<JobCard>().eq("job_card_ref", jobCardRef));
    }

    private void requireState(JobCard card, Set<String> allowed, String message) {
        if (!allowed.contains(card.getStatus())) {
            throw new BadRequestException(message + " (current: " + card.getStatus() + ")");
        }
    }

    private void requireBranchAccess(Long principalBranchId, Long entityBranchId) {
        if (principalBranchId != null && !principalBranchId.equals(entityBranchId)) {
            throw new ForbiddenException("Job card is outside the authenticated branch");
        }
    }

    private void notifyCustomerReady(JobCard card) {
        Customer customer = card.getCustomerId() != null ? customerMapper.selectById(card.getCustomerId()) : null;
        if (customer != null && customer.getUserId() != null) {
            notificationService.emit(customer.getUserId(), card.getBranchId(),
                    "completionApproved", "Your car is ready!",
                    card.getJobCardRef() + " has been checked and approved. You can collect your car.");
        }
    }

    private void notifyTechnicianRevision(JobCard card, TechnicianTask task, String reason) {
        Staff tech = task.getEmpId() != null ? staffMapper.findByEmpId(task.getEmpId()).orElse(null) : null;
        if (tech != null && tech.getUserId() != null) {
            notificationService.emit(tech.getUserId(), card.getBranchId(),
                    "completionRejected", "Work sent back for revision",
                    card.getJobCardRef() + " - " + task.getDescription() + " - " + reason);
        }
    }

    private void notifySupervisors(JobCard card) {
        List<Staff> supervisors = staffMapper.selectList(
                new LambdaQueryWrapper<Staff>()
                        .eq(Staff::getRole, "supervisor")
                        .eq(Staff::getIsActive, true)
                        .eq(card.getBranchId() != null && card.getBranchId() > 0,
                                Staff::getBranchId, card.getBranchId()));
        for (Staff supervisor : supervisors) {
            if (supervisor.getUserId() == null) continue;
            notificationService.emit(supervisor.getUserId(), card.getBranchId(),
                    "jobAwaitingReview", "Job awaiting your review",
                    card.getJobCardRef() + " - all work items completed. Approve or send back.");
        }
    }
}
