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
import com.orient.workshop.core.model.entity.InventoryItem;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.core.repository.InventoryItemMapper;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.core.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class RepairOrderService {

    private static final BigDecimal ZERO = BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);

    private final RepairOrderMapper repairOrderMapper;
    private final RepairOrderServiceMapper serviceMapper;
    private final RepairOrderPartMapper partMapper;
    private final JobCardMapper jobCardMapper;
    private final CustomerMapper customerMapper;
    private final ApprovalMapper approvalMapper;
    private final NotificationService notificationService;
    private final TaskGeneratorService taskGeneratorService;
    private final InventoryItemMapper inventoryItemMapper;

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

        BigDecimal servicesTotal = persistServices(ro.getId(), req.getServices());
        BigDecimal partsTotal = persistParts(ro.getId(), jc.getBranchId(), req.getParts());

        ro.setServicesTotal(servicesTotal.doubleValue());
        ro.setPartsTotal(partsTotal.doubleValue());
        ro.setGrandTotal(servicesTotal.add(partsTotal).doubleValue());
        repairOrderMapper.updateById(ro);

        log.info("Repair order {} created for jobCardId={}, grandTotal={}", ref, jobCardId, ro.getGrandTotal());

        taskGeneratorService.generateForJobCard(jobCardId);
        createApproval(jc, ref, ro);

        return RepairOrderResponse.builder().id(ref).build();
    }

    @Transactional
    public void sendEstimate(Long id, com.orient.workshop.auth.filter.JwtUserPrincipal principal) {
        RepairOrder ro = repairOrderMapper.selectById(id);
        if (ro == null) {
            throw new NotFoundException("Repair order not found");
        }

        if (ro.getJobCardId() != null) {
            JobCard jc = jobCardMapper.selectById(ro.getJobCardId());
            if (jc != null) {
                jc.setStatus("waitingCustomerApproval");
                jobCardMapper.updateById(jc);
                Customer customer = jc.getCustomerId() != null
                        ? customerMapper.selectById(jc.getCustomerId()) : null;
                if (customer != null && customer.getUserId() != null) {
                    notificationService.emit(customer.getUserId(), jc.getBranchId(),
                            "approvalNeeded", "Approve your estimate",
                            "Estimate " + ro.getRepairOrderRef() + " · "
                                    + String.format("%.2f", ro.getGrandTotal())
                                    + " · review the work and approve to start.");
                }
            }
        }
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

    private BigDecimal persistServices(Long repairOrderId, List<RepairOrderRequest.LineItem> items) {
        BigDecimal total = ZERO;
        if (items == null) return ZERO;
        for (RepairOrderRequest.LineItem li : items) {
            BigDecimal lineTotal = lineTotal(li);
            total = total.add(lineTotal);
            serviceMapper.insert(RepairOrderServiceItem.builder()
                    .repairOrderId(repairOrderId)
                    .name(li.getName())
                    .qty(li.getQty() != null ? li.getQty() : 1)
                    .rate(li.getRate() != null ? li.getRate() : 0)
                    .discountPercent(li.getDiscountPercent() != null ? li.getDiscountPercent() : 0)
                    .discountAmount(li.getDiscountAmount() != null ? li.getDiscountAmount() : 0)
                    .build());
        }
        return total;
    }

    private BigDecimal persistParts(Long repairOrderId, Long branchId, List<RepairOrderRequest.LineItem> items) {
        BigDecimal total = ZERO;
        if (items == null) return ZERO;
        for (RepairOrderRequest.LineItem li : items) {
            BigDecimal lineTotal = lineTotal(li);
            total = total.add(lineTotal);
            partMapper.insert(RepairOrderPartItem.builder()
                    .repairOrderId(repairOrderId)
                    .name(li.getName())
                    .qty(li.getQty() != null ? li.getQty() : 1)
                    .rate(li.getRate() != null ? li.getRate() : 0)
                    .discountPercent(li.getDiscountPercent() != null ? li.getDiscountPercent() : 0)
                    .discountAmount(li.getDiscountAmount() != null ? li.getDiscountAmount() : 0)
                    .build());

            // H-2: decrement inventory when a part is consumed. Best-effort by name match
            // within the branch; unmatched names (free-text parts) are skipped safely.
            int qty = li.getQty() != null ? li.getQty() : 1;
            if (branchId != null && li.getName() != null && !li.getName().isBlank()) {
                InventoryItem item = inventoryItemMapper.findByNameAndBranch(branchId, li.getName().trim())
                        .orElse(null);
                if (item != null) {
                    int updated = inventoryItemMapper.decrementStock(item.getId(), qty);
                    if (updated == 0) {
                        log.warn("Part '{}' (id {}) stock could not be decremented by {} (insufficient or missing)",
                                li.getName(), item.getId(), qty);
                    } else {
                        log.info("Part '{}' decremented by {} (remaining lookup on next read)", li.getName(), qty);
                    }
                }
            }
        }
        return total;
    }

    /**
     * P3 (audit): line-item total computed with BigDecimal to avoid floating-point
     * rounding errors in billing. total = qty * rate * (1 - discPct/100) - discAmt,
     * floored at zero, rounded to 2 decimal places.
     */
    private BigDecimal lineTotal(RepairOrderRequest.LineItem li) {
        BigDecimal qty = BigDecimal.valueOf(li.getQty() != null ? li.getQty() : 1);
        BigDecimal rate = BigDecimal.valueOf(li.getRate() != null ? li.getRate() : 0);
        BigDecimal discPct = BigDecimal.valueOf(li.getDiscountPercent() != null ? li.getDiscountPercent() : 0);
        BigDecimal discAmt = BigDecimal.valueOf(li.getDiscountAmount() != null ? li.getDiscountAmount() : 0);

        BigDecimal discountFactor = BigDecimal.ONE.subtract(discPct.divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP));
        BigDecimal total = qty.multiply(rate).multiply(discountFactor).subtract(discAmt);
        return total.max(ZERO).setScale(2, RoundingMode.HALF_UP);
    }
}
