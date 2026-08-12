package com.orient.workshop.advisor.service;

import com.orient.workshop.advisor.model.dto.JobCardDetailResponse;
import com.orient.workshop.advisor.model.dto.JobCardResponse;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.common.response.PageResponse;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.model.entity.TechnicianTask;
import com.orient.workshop.core.model.entity.Vehicle;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.core.repository.TechnicianTaskMapper;
import com.orient.workshop.core.repository.VehicleMapper;
import com.orient.workshop.advisor.model.dto.BatchTaskRequest;
import com.orient.workshop.advisor.model.dto.DeliveryRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class JobCardService {

    private static final Set<String> VALID_STATUSES = Set.of(
            "inProgress", "pendingApproval", "qualityCheck", "completed",
            "cancelled", "waitingParts", "pending", "awaitingSupervisor",
            "vehicleReceived", "waitingCustomerApproval", "delivered", "qualityCheckPassed");

    private final JobCardMapper jobCardMapper;
    private final CustomerMapper customerMapper;
    private final VehicleMapper vehicleMapper;
    private final TechnicianTaskMapper technicianTaskMapper;
    private final com.orient.workshop.core.service.ActivityService activityService;
    private final com.orient.workshop.core.service.WebhookService webhookService;

    public PageResponse<JobCardResponse> listJobCards(String status, String search, int page, int limit,
                                                      JwtUserPrincipal principal) {
        // FIX (audit QA BUG-007): page=0 produced a negative OFFSET ((0-1)*limit)
        // which MySQL rejects with a SQL syntax error -> 500. Clamp both params.
        int safePage = Math.max(page, 1);
        int safeLimit = Math.min(Math.max(limit, 1), 100);
        int offset = (safePage - 1) * safeLimit;
        Long branchId = scopedBranchId(principal);
        List<JobCard> cards;
        long total;

        if (search != null && !search.isBlank()) {
            if (branchId != null) {
                cards = jobCardMapper.searchCardsByBranch(search, branchId, safeLimit, offset);
                total = jobCardMapper.countSearchByBranch(search, branchId);
            } else {
                cards = jobCardMapper.searchCards(search, safeLimit, offset);
                total = jobCardMapper.countSearch(search);
            }
        } else if (status != null && !status.isBlank()) {
            if (branchId != null) {
                cards = jobCardMapper.findByStatusAndBranch(status, branchId, safeLimit, offset);
                total = jobCardMapper.countByStatusAndBranch(status, branchId);
            } else {
                cards = jobCardMapper.findByStatus(status, safeLimit, offset);
                total = jobCardMapper.countByStatus(status);
            }
        } else {
            if (branchId != null) {
                cards = jobCardMapper.findRecentByBranch(branchId, safeLimit, offset);
                total = jobCardMapper.countAllByBranch(branchId);
            } else {
                cards = jobCardMapper.findRecent(safeLimit, offset);
                total = jobCardMapper.countAll();
            }
        }

        List<JobCardResponse> items = toResponses(cards);
        return PageResponse.of(items, safePage, safeLimit, total);
    }

    public JobCardDetailResponse getJobCard(Long id, JwtUserPrincipal principal) {
        JobCard card = jobCardMapper.selectById(id);
        if (card == null || !inScope(card, principal)) {
            throw new NotFoundException("Job card not found");
        }
        return toDetailResponse(card);
    }

    @Transactional
    public void updateStatus(String id, String status, JwtUserPrincipal principal) {
        if (status == null || !VALID_STATUSES.contains(status)) {
            throw new BadRequestException("Invalid status '" + status + "'. Allowed values: "
                    + String.join(", ", VALID_STATUSES));
        }
        JobCard card = findByIdOrRef(id);
        if (card == null || !inScope(card, principal)) {
            throw new NotFoundException("Job card not found");
        }
        card.setStatus(status);
        jobCardMapper.updateById(card);
    }

    @Transactional
    public void assignTechnician(String id, String technician, JwtUserPrincipal principal) {
        JobCard card = findByIdOrRef(id);
        if (card == null || !inScope(card, principal)) {
            throw new NotFoundException("Job card not found");
        }
        card.setTechnician(technician);
        if (!List.of("completed", "delivered", "cancelled").contains(card.getStatus())) {
            card.setStatus("inProgress");
        }
        jobCardMapper.updateById(card);
    }

    private JobCard findByIdOrRef(String id) {
        if (id == null || id.isBlank()) return null;
        if (id.matches("\\d+")) {
            JobCard byId = jobCardMapper.selectById(Long.valueOf(id));
            if (byId != null) return byId;
        }
        return jobCardMapper.selectOne(new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<JobCard>().eq("job_card_ref", id));
    }

    @Transactional
    public void assignTasks(String jobCardRef, BatchTaskRequest request, JwtUserPrincipal principal) {
        JobCard card = jobCardMapper.selectOne(new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<JobCard>().eq("job_card_ref", jobCardRef));
        if (card == null || !inScope(card, principal)) {
            throw new NotFoundException("Job card not found");
        }
        
        if (request.getTasks() != null) {
            for (BatchTaskRequest.TaskItem task : request.getTasks()) {
                TechnicianTask tTask = TechnicianTask.builder()
                        .jobCardNo(jobCardRef)
                        .description(task.getDescription())
                        .empId(task.getTechnicianEmpId())
                        .status("pending")
                        .build();
                technicianTaskMapper.insert(tTask);
            }
        }
        
        card.setStatus("inProgress");
        jobCardMapper.updateById(card);
    }

    @Transactional
    public void deliver(String jobCardRef, DeliveryRequest request, JwtUserPrincipal principal) {
        JobCard card = jobCardMapper.selectOne(new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<JobCard>().eq("job_card_ref", jobCardRef));
        if (card == null || !inScope(card, principal)) {
            throw new NotFoundException("Job card not found");
        }

        // Fix: 'delivered' was missing from the job_cards.status ENUM (V6 adds
        // it). Only a job that passed completion/QC may be delivered.
        String current = card.getStatus();
        if (!List.of("completed", "qualityCheckPassed", "awaitingSupervisor").contains(current)) {
            throw new BadRequestException("Job card must be completed or QC-passed before delivery (current: " + current + ")");
        }

        card.setStatus("delivered");
        card.setUpdatedAt(java.time.LocalDateTime.now());
        jobCardMapper.updateById(card);

        // P1: activity feed writer.
        activityService.log("job_card", "Vehicle delivered",
                "Job " + card.getJobCardRef() + " marked delivered",
                principal != null ? principal.getUserId() : null);

        // P3: outbound webhook (job.delivered).
        webhookService.dispatch("job.delivered", Map.of("jobCardRef", card.getJobCardRef()));
    }

    private List<JobCardResponse> toResponses(List<JobCard> cards) {
        if (cards.isEmpty()) return Collections.emptyList();

        Set<Long> customerIds = cards.stream()
                .map(JobCard::getCustomerId).filter(Objects::nonNull).collect(Collectors.toSet());
        Set<Long> vehicleIds = cards.stream()
                .map(JobCard::getVehicleId).filter(Objects::nonNull).collect(Collectors.toSet());

        Map<Long, Customer> customers = customerIds.isEmpty() ? Collections.emptyMap()
                : customerMapper.selectBatchIds(customerIds).stream()
                        .collect(Collectors.toMap(Customer::getId, Function.identity()));
        Map<Long, Vehicle> vehicles = vehicleIds.isEmpty() ? Collections.emptyMap()
                : vehicleMapper.selectBatchIds(vehicleIds).stream()
                        .collect(Collectors.toMap(Vehicle::getId, Function.identity()));

        return cards.stream().map(c -> toResponse(c, customers, vehicles)).collect(Collectors.toList());
    }

    private JobCardResponse toResponse(JobCard c, Map<Long, Customer> customers, Map<Long, Vehicle> vehicles) {
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        String custName = "";
        if (c.getCustomerId() != null) {
            Customer cust = customers.get(c.getCustomerId());
            if (cust != null) custName = cust.getCustomerName();
        }
        String vehicleInfo = "";
        if (c.getVehicleId() != null) {
            Vehicle v = vehicles.get(c.getVehicleId());
            if (v != null) vehicleInfo = (v.getMake() != null ? v.getMake() : "") + " "
                    + (v.getModel() != null ? v.getModel() : "");
            vehicleInfo = vehicleInfo.trim();
        }
        return JobCardResponse.builder()
                .id(c.getJobCardRef())
                .dbId(c.getId())
                .customerName(custName)
                .vehicleInfo(vehicleInfo)
                .time(c.getCreatedAt() != null ? c.getCreatedAt().format(DateTimeFormatter.ofPattern("hh:mm a")) : "")
                .createdDate(c.getCreatedAt() != null ? c.getCreatedAt().format(fmt) : "")
                .lastUpdated(c.getUpdatedAt() != null ? c.getUpdatedAt().format(fmt) : "")
                .status(c.getStatus())
                .technician(c.getTechnician() != null ? c.getTechnician() : "")
                .build();
    }

    private JobCardDetailResponse toDetailResponse(JobCard c) {
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        return JobCardDetailResponse.builder()
                .id(c.getJobCardRef())
                .status(c.getStatus())
                .technician(c.getTechnician())
                .notes(c.getNotes())
                .tag(c.getTag())
                .customerRequests(c.getCustomerRequests())
                .garageRecommendations(c.getGarageRecommendations())
                .createdDate(c.getCreatedAt() != null ? c.getCreatedAt().format(fmt) : "")
                .lastUpdated(c.getUpdatedAt() != null ? c.getUpdatedAt().format(fmt) : "")
                .estimatedDelivery(c.getEstimatedDelivery() != null ? c.getEstimatedDelivery().toString() : "")
                .build();
    }

    private boolean inScope(JobCard card, JwtUserPrincipal principal) {
        Long branchId = scopedBranchId(principal);
        return branchId == null || card.getBranchId() == null || branchId.equals(card.getBranchId());
    }

    private Long scopedBranchId(JwtUserPrincipal principal) {
        if (principal == null || principal.getBranchId() == null) return null;
        String role = principal.getRole() != null ? principal.getRole().toLowerCase() : "";
        if ("owner".equals(role) || "crmdashboard".equals(role) || "admin".equals(role)) return null;
        return principal.getBranchId();
    }
}
