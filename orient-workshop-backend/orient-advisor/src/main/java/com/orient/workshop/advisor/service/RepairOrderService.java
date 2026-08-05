package com.orient.workshop.advisor.service;

import com.orient.workshop.advisor.model.dto.RepairOrderRequest;
import com.orient.workshop.advisor.model.dto.RepairOrderResponse;
import com.orient.workshop.advisor.model.entity.Approval;
import com.orient.workshop.advisor.model.entity.RepairOrder;
import com.orient.workshop.advisor.model.entity.RepairOrderPartItem;
import com.orient.workshop.advisor.model.entity.RepairOrderServiceItem;
import com.orient.workshop.advisor.repository.ApprovalMapper;
import com.orient.workshop.advisor.repository.RepairOrderMapper;
import com.orient.workshop.advisor.repository.RepairOrderPartMapper;
import com.orient.workshop.advisor.repository.RepairOrderServiceMapper;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.common.util.DateParse;
import com.orient.workshop.common.util.IdGenerator;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.core.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class RepairOrderService {

    private final RepairOrderMapper repairOrderMapper;
    private final RepairOrderServiceMapper serviceMapper;
    private final RepairOrderPartMapper partMapper;
    private final JobCardMapper jobCardMapper;
    private final CustomerMapper customerMapper;
    private final ApprovalMapper approvalMapper;
    private final NotificationService notificationService;
    private final TaskGeneratorService taskGeneratorService;

    @Transactional
    public RepairOrderResponse createRepairOrder(RepairOrderRequest req) {
        if (req.getJobCardId() == null || req.getJobCardId().isBlank()) {
            throw new BadRequestException("jobCardId is required");
        }
        Long jobCardId;
        try {
            jobCardId = Long.parseLong(req.getJobCardId());
        } catch (NumberFormatException e) {
            throw new BadRequestException("Invalid jobCardId '" + req.getJobCardId() + "'");
        }
        JobCard jc = jobCardMapper.selectById(jobCardId);
        if (jc == null) {
            throw new BadRequestException("Job card not found with id: " + jobCardId);
        }

        String ref = IdGenerator.shortRef("RO");

        RepairOrder ro = RepairOrder.builder()
                .repairOrderRef(ref)
                .jobCardId(jobCardId)
                .servicesTotal(0.0)
                .partsTotal(0.0)
                .grandTotal(0.0)
                .tag(req.getTag())
                .customerRequests(req.getCustomerRequests())
                .garageRecommendations(req.getGarageRecommendations())
                .estimatedDelivery(DateParse.parseLocalDateTime(req.getEstimatedDelivery(), "estimatedDelivery"))
                .notifyOwnerSmsEmail(req.getNotifyOwnerSmsEmail())
                .build();
        repairOrderMapper.insert(ro);

        double servicesTotal = persistServices(ro.getId(), req.getServices());
        double partsTotal = persistParts(ro.getId(), req.getParts());

        ro.setServicesTotal(servicesTotal);
        ro.setPartsTotal(partsTotal);
        ro.setGrandTotal(servicesTotal + partsTotal);
        repairOrderMapper.updateById(ro);

        log.info("Repair order {} created for jobCardId={}, grandTotal={}", ref, jobCardId, ro.getGrandTotal());

        // Phase 2 — every work list line item becomes a tracked technician work item
        taskGeneratorService.generateForJobCard(jobCardId);

        // Phase 2 — estimate approval row is auto-created for the customer to approve
        createApproval(jc, ref, ro);

        return RepairOrderResponse.builder().id(ref).build();
    }

    private void createApproval(JobCard jc, String ref, RepairOrder ro) {
        Customer customer = jc.getCustomerId() != null ? customerMapper.selectById(jc.getCustomerId()) : null;
        String customerName = customer != null && customer.getCustomerName() != null
                ? customer.getCustomerName() : "";
        approvalMapper.insert(Approval.builder()
                .estimateId(ref)
                .customerId(jc.getCustomerId())
                .customerName(customerName)
                .vehicleId(jc.getVehicleId() != null ? String.valueOf(jc.getVehicleId()) : "")
                .amount(ro.getGrandTotal())
                .action("pending")
                .build());

        if (jc.getStatus() == null || !"awaitingSupervisor".equals(jc.getStatus())) {
            jc.setStatus("pendingApproval");
            jobCardMapper.updateById(jc);
        }

        if (customer != null && customer.getUserId() != null) {
            notificationService.emit(customer.getUserId(), jc.getBranchId(),
                    "approvalNeeded", "Approve your estimate",
                    "Estimate " + ref + " · " + String.format("%.2f", ro.getGrandTotal())
                            + " · review the work and approve to start.");
        }
    }

    private double persistServices(Long repairOrderId, List<RepairOrderRequest.LineItem> items) {
        double total = 0;
        if (items == null) return 0;
        for (RepairOrderRequest.LineItem li : items) {
            double lineTotal = lineTotal(li);
            total += lineTotal;
            serviceMapper.insert(RepairOrderServiceItem.builder()
                    .repairOrderId(repairOrderId)
                    .name(li.getName())
                    .qty(li.getQty() != null ? li.getQty() : 1)
                    .rate(li.getRate() != null ? li.getRate() : 0)
                    .discountPercent(li.getDiscountPercent() != null ? li.getDiscountPercent() : 0)
                    .discountAmount(li.getDiscountAmount() != null ? li.getDiscountAmount() : 0)
                    .build());
        }
        return round2(total);
    }

    private double persistParts(Long repairOrderId, List<RepairOrderRequest.LineItem> items) {
        double total = 0;
        if (items == null) return 0;
        for (RepairOrderRequest.LineItem li : items) {
            double lineTotal = lineTotal(li);
            total += lineTotal;
            partMapper.insert(RepairOrderPartItem.builder()
                    .repairOrderId(repairOrderId)
                    .name(li.getName())
                    .qty(li.getQty() != null ? li.getQty() : 1)
                    .rate(li.getRate() != null ? li.getRate() : 0)
                    .discountPercent(li.getDiscountPercent() != null ? li.getDiscountPercent() : 0)
                    .discountAmount(li.getDiscountAmount() != null ? li.getDiscountAmount() : 0)
                    .build());
        }
        return round2(total);
    }

    private double lineTotal(RepairOrderRequest.LineItem li) {
        double qty = li.getQty() != null ? li.getQty() : 1;
        double rate = li.getRate() != null ? li.getRate() : 0;
        double discPct = li.getDiscountPercent() != null ? li.getDiscountPercent() : 0;
        double discAmt = li.getDiscountAmount() != null ? li.getDiscountAmount() : 0;
        double total = qty * rate * (1 - discPct / 100.0) - discAmt;
        return Math.max(0, total);
    }

    private double round2(double value) {
        return Math.round(value * 100.0) / 100.0;
    }
}
