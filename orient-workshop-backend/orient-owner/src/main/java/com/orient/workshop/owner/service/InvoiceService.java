package com.orient.workshop.owner.service;

import com.orient.workshop.advisor.model.entity.RepairOrder;
import com.orient.workshop.advisor.repository.RepairOrderMapper;
import com.orient.workshop.common.util.IdGenerator;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.core.service.JobInvoiceGateway;
import com.orient.workshop.core.service.NotificationService;
import com.orient.workshop.owner.model.dto.InvoiceResponse;
import com.orient.workshop.owner.model.entity.Invoice;
import com.orient.workshop.owner.repository.InvoiceMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class InvoiceService implements JobInvoiceGateway {

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    // P3 (audit): UAE VAT 5%.
    private static final BigDecimal VAT_RATE = new BigDecimal("0.05");

    private final InvoiceMapper invoiceMapper;
    private final CustomerMapper customerMapper;
    private final JobCardMapper jobCardMapper;
    private final RepairOrderMapper repairOrderMapper;
    private final NotificationService notificationService;

    private InvoiceResponse toResponse(Invoice inv, String customerName) {
        return InvoiceResponse.builder()
                .id(inv.getInvoiceRef())
                .customerName(customerName != null ? customerName : "")
                .date(inv.getIssuedDate() != null ? inv.getIssuedDate().format(DATE_FMT) : "")
                .amount(inv.getAmount() != null ? inv.getAmount().doubleValue() : 0.0)
                .taxRate(inv.getTaxRate() != null ? inv.getTaxRate().doubleValue() : 0.0)
                .taxAmount(inv.getTaxAmount() != null ? inv.getTaxAmount().doubleValue() : 0.0)
                .grandTotal(inv.getGrandTotal() != null ? inv.getGrandTotal().doubleValue()
                        : (inv.getAmount() != null ? inv.getAmount().doubleValue() : 0.0))
                .status(inv.getStatus() != null ? inv.getStatus() : "")
                .build();
    }

    public List<InvoiceResponse> getInvoices(String status) {
        Map<Long, Customer> customers = customerMapper.selectList(null).stream()
                .collect(Collectors.toMap(Customer::getId, Function.identity()));
        return invoiceMapper.selectList(null).stream()
                .filter(inv -> status == null || status.isBlank() || status.equalsIgnoreCase(inv.getStatus()))
                .map(inv -> {
                    Customer customer = customers.get(inv.getCustomerId());
                    String name = customer != null && customer.getCustomerName() != null
                            ? customer.getCustomerName() : "";
                    return toResponse(inv, name);
                })
                .collect(Collectors.toList());
    }

    /**
     * Phase 4 — auto-raise an invoice from the job card's repair order once
     * the supervisor has approved completion.
     */
    @Transactional
    @Override
    public String createFromJobCard(Long jobCardId) {
        JobCard card = jobCardId != null ? jobCardMapper.selectById(jobCardId) : null;
        if (card == null) return null;

        // Skip if an invoice already exists for this job card.
        if (!invoiceMapper.findByJobCardId(jobCardId).isEmpty()) return null;

        List<RepairOrder> orders = repairOrderMapper.findByJobCardId(jobCardId);
        BigDecimal amount = orders.stream()
                .map(ro -> ro.getGrandTotal() != null ? BigDecimal.valueOf(ro.getGrandTotal()) : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        String ref = IdGenerator.shortRef("INV");
        LocalDate today = LocalDate.now();
        // P3: UAE VAT 5% computed server-side (was absent entirely).
        BigDecimal taxAmount = amount.multiply(VAT_RATE).setScale(2, RoundingMode.HALF_UP);
        BigDecimal grandTotal = amount.add(taxAmount).setScale(2, RoundingMode.HALF_UP);
        Invoice invoice = Invoice.builder()
                .invoiceRef(ref)
                .customerId(card.getCustomerId())
                .jobCardId(jobCardId)
                .branchId(card.getBranchId())
                .amount(amount.setScale(2, RoundingMode.HALF_UP))
                .taxRate(VAT_RATE)
                .taxAmount(taxAmount)
                .grandTotal(grandTotal)
                .status("unpaid")
                .dueDate(today.plusDays(30))
                .issuedDate(today)
                .build();
        invoiceMapper.insert(invoice);

        Customer customer = card.getCustomerId() != null ? customerMapper.selectById(card.getCustomerId()) : null;
        if (customer != null && customer.getUserId() != null) {
            notificationService.emit(customer.getUserId(), card.getBranchId(),
                    "invoiceReady", "Invoice ready",
                    "Invoice " + ref + " · " + String.format("%.2f", grandTotal)
                            + " — you can view it in the app.");
        }
        return ref;
    }

    public List<InvoiceResponse> getInvoicesForCustomer(Long customerId) {
        return invoiceMapper.findByCustomerId(customerId).stream()
                .map(inv -> toResponse(inv, ""))
                .collect(Collectors.toList());
    }
}
