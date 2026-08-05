package com.orient.workshop.advisor.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.orient.workshop.advisor.model.dto.*;
import com.orient.workshop.advisor.model.entity.Approval;
import com.orient.workshop.advisor.model.entity.RepairOrder;
import com.orient.workshop.advisor.model.entity.RepairOrderPartItem;
import com.orient.workshop.advisor.model.entity.RepairOrderServiceItem;
import com.orient.workshop.advisor.repository.ApprovalMapper;
import com.orient.workshop.advisor.repository.RepairOrderMapper;
import com.orient.workshop.advisor.repository.RepairOrderPartMapper;
import com.orient.workshop.advisor.repository.RepairOrderServiceMapper;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.exception.ForbiddenException;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.model.entity.Vehicle;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.core.repository.VehicleMapper;
import com.orient.workshop.core.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Phase 2 — the customer approves/rejects/revises their estimate in the
 * customer app. Works for walk-ins too: the intake created the customer
 * record with a phone; after the same-phone login merge (CustomerService)
 * the approval is bound to the logged-in user.
 */
@Service
@RequiredArgsConstructor
public class CustomerApprovalService {

    private static final DateTimeFormatter DATE_TIME_FMT =
            DateTimeFormatter.ofPattern("d MMM yyyy · hh:mm a");

    private final ApprovalMapper approvalMapper;
    private final RepairOrderMapper repairOrderMapper;
    private final RepairOrderServiceMapper serviceMapper;
    private final RepairOrderPartMapper partMapper;
    private final CustomerMapper customerMapper;
    private final JobCardMapper jobCardMapper;
    private final VehicleMapper vehicleMapper;
    private final NotificationService notificationService;

    public List<CustomerApprovalSummaryResponse> getPendingApprovals(JwtUserPrincipal principal) {
        Customer customer = resolveCustomer(principal);
        List<Approval> approvals = approvalMapper.selectList(
                new LambdaQueryWrapper<Approval>()
                        .eq(Approval::getCustomerId, customer.getId())
                        .eq(Approval::getAction, "pending")
                        .orderByDesc(Approval::getCreatedAt));
        return approvals.stream().map(a -> CustomerApprovalSummaryResponse.builder()
                .estimateId(a.getEstimateId())
                .customerName(a.getCustomerName())
                .amount(a.getAmount())
                .status(a.getAction())
                .createdAt(a.getCreatedAt() != null ? a.getCreatedAt().format(DATE_TIME_FMT) : "")
                .build()).collect(Collectors.toList());
    }

    public CustomerApprovalDetailResponse getApprovalDetail(JwtUserPrincipal principal, String estimateId) {
        Customer customer = resolveCustomer(principal);
        Approval approval = requireApproval(estimateId, customer.getId());
        RepairOrder ro = repairOrderMapper.selectOne(
                new LambdaQueryWrapper<RepairOrder>().eq(RepairOrder::getRepairOrderRef, estimateId));

        List<CustomerApprovalDetailResponse.LineItem> services = List.of();
        List<CustomerApprovalDetailResponse.LineItem> parts = List.of();
        if (ro != null) {
            services = serviceMapper.findByRepairOrderId(ro.getId()).stream()
                    .map(CustomerApprovalService::toLineItem).collect(Collectors.toList());
            parts = partMapper.findByRepairOrderId(ro.getId()).stream()
                    .map(CustomerApprovalService::toLineItem).collect(Collectors.toList());
        }

        String vehicleInfo = "";
        if (ro != null && ro.getJobCardId() != null) {
            JobCard card = jobCardMapper.selectById(ro.getJobCardId());
            if (card != null && card.getVehicleId() != null) {
                Vehicle v = vehicleMapper.selectById(card.getVehicleId());
                if (v != null) {
                    vehicleInfo = ((v.getMake() != null ? v.getMake() : "") + " "
                            + (v.getModel() != null ? v.getModel() : "")).trim();
                }
            }
        }

        return CustomerApprovalDetailResponse.builder()
                .estimateId(approval.getEstimateId())
                .customerName(approval.getCustomerName())
                .vehicleInfo(vehicleInfo)
                .servicesTotal(ro != null ? ro.getServicesTotal() : 0)
                .partsTotal(ro != null ? ro.getPartsTotal() : 0)
                .grandTotal(ro != null ? ro.getGrandTotal() : approval.getAmount())
                .status(approval.getAction())
                .createdAt(approval.getCreatedAt() != null ? approval.getCreatedAt().format(DATE_TIME_FMT) : "")
                .services(services)
                .parts(parts)
                .build();
    }

    @Transactional
    public void processApproval(JwtUserPrincipal principal, String estimateId, CustomerApprovalActionRequest req) {
        Customer customer = resolveCustomer(principal);
        Approval approval = requireApproval(estimateId, customer.getId());

        String action = req != null && req.getAction() != null ? req.getAction().trim().toLowerCase() : "";
        String stored = switch (action) {
            case "approve" -> "approved";
            case "reject" -> "rejected";
            case "revise" -> "pending";
            default -> throw new BadRequestException("Invalid action '" + action
                    + "'. Allowed values: approve, reject, revise");
        };
        approval.setAction(stored);
        approvalMapper.updateById(approval);

        if ("approved".equals(stored)) {
            RepairOrder ro = repairOrderMapper.selectOne(
                    new LambdaQueryWrapper<RepairOrder>().eq(RepairOrder::getRepairOrderRef, estimateId));
            if (ro != null && ro.getJobCardId() != null) {
                JobCard card = jobCardMapper.selectById(ro.getJobCardId());
                if (card != null && !"awaitingSupervisor".equals(card.getStatus())) {
                    card.setStatus("inProgress");
                    jobCardMapper.updateById(card);
                }
            }
        }
        if (customer.getUserId() != null) {
            String type = switch (stored) {
                case "approved" -> "estimateApproved";
                case "rejected" -> "estimateRejected";
                default -> "estimateApproved";
            };
            String title = switch (stored) {
                case "approved" -> "Estimate approved";
                case "rejected" -> "Estimate rejected";
                default -> "Changes requested";
            };
            notificationService.emit(customer.getUserId(), customer.getBranchId(), type, title,
                    "Estimate " + estimateId + (stored.equals("approved")
                            ? " — work will start shortly." : " — the workshop has been informed."));
        }
    }

    private Customer resolveCustomer(JwtUserPrincipal principal) {
        if (principal == null || principal.getUserId() == null) {
            throw new ForbiddenException("Authenticated user not found");
        }
        Customer customer = customerMapper.findByUserId(principal.getUserId())
                .orElse(null);
        if (customer == null) {
            throw new NotFoundException("No customer profile linked to this account yet");
        }
        return customer;
    }

    private Approval requireApproval(String estimateId, Long customerId) {
        Approval approval = approvalMapper.selectOne(
                new LambdaQueryWrapper<Approval>()
                        .eq(Approval::getEstimateId, estimateId)
                        .eq(Approval::getCustomerId, customerId));
        if (approval == null) {
            throw new NotFoundException("Approval not found for estimate " + estimateId);
        }
        return approval;
    }

    private static CustomerApprovalDetailResponse.LineItem toLineItem(RepairOrderServiceItem s) {
        return CustomerApprovalDetailResponse.LineItem.builder()
                .name(s.getName())
                .qty(s.getQty())
                .rate(s.getRate())
                .discountPercent(s.getDiscountPercent())
                .discountAmount(s.getDiscountAmount())
                .build();
    }

    private static CustomerApprovalDetailResponse.LineItem toLineItem(RepairOrderPartItem p) {
        return CustomerApprovalDetailResponse.LineItem.builder()
                .name(p.getName())
                .qty(p.getQty())
                .rate(p.getRate())
                .discountPercent(p.getDiscountPercent())
                .discountAmount(p.getDiscountAmount())
                .build();
    }
}
