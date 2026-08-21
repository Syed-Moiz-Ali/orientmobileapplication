package com.orient.workshop.owner.service;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.common.util.IdGenerator;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.core.service.NotificationService;
import com.orient.workshop.owner.model.dto.RecordPaymentRequest;
import com.orient.workshop.owner.model.entity.Invoice;
import com.orient.workshop.owner.model.entity.Payment;
import com.orient.workshop.owner.repository.InvoiceMapper;
import com.orient.workshop.owner.repository.PaymentMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;

/**
 * P1 (audit): payment recording. Previously there was no way to record a
 * payment — AR outstanding always equalled the full invoice amount and no
 * invoice could ever become paid.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PaymentService {

    private static final BigDecimal ZERO = BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);

    private final PaymentMapper paymentMapper;
    private final InvoiceMapper invoiceMapper;
    private final com.orient.workshop.core.service.ActivityService activityService;
    private final CustomerMapper customerMapper;
    private final NotificationService notificationService;

    @Transactional
    public PaymentRecordResult recordPayment(JwtUserPrincipal principal, RecordPaymentRequest req) {
        if (req.getInvoiceId() == null) {
            throw new BadRequestException("invoiceId is required");
        }
        if (req.getAmount() == null || req.getAmount().compareTo(ZERO) <= 0) {
            throw new BadRequestException("amount must be greater than 0");
        }
        String method = req.getMethod() != null && !req.getMethod().isBlank()
                ? req.getMethod() : "cash";

        Invoice invoice = invoiceMapper.selectById(req.getInvoiceId());
        if (invoice == null) {
            throw new NotFoundException("Invoice not found with id: " + req.getInvoiceId());
        }

        // H-1 (tenant isolation): the caller must belong to the invoice's branch.
        // Super-users (owner/admin with null branch scope) may record any payment.
        if (invoice.getBranchId() != null && principal != null && principal.getBranchId() != null
                && !invoice.getBranchId().equals(principal.getBranchId())) {
            throw new com.orient.workshop.common.exception.ForbiddenException(
                    "Invoice does not belong to your branch");
        }

        BigDecimal outstanding = outstanding(invoice);
        if (req.getAmount().compareTo(outstanding) > 0) {
            throw new BadRequestException("Payment exceeds the outstanding amount ("
                    + outstanding.setScale(2, RoundingMode.HALF_UP) + ")");
        }

        Payment payment = Payment.builder()
                .paymentRef(IdGenerator.shortRef("PAY"))
                .invoiceId(invoice.getId())
                // FIX (audit): branch 0 is a legacy phantom tenant — never
                // store it; fall back to the principal's real branch or NULL.
                .branchId(resolveBranch(invoice.getBranchId(), principal))
                .amount(req.getAmount().setScale(2, RoundingMode.HALF_UP))
                .method(method)
                .reference(req.getReference() != null ? req.getReference() : "")
                .paidAt(LocalDateTime.now())
                .recordedBy(principal != null ? principal.getUserId() : null)
                .build();
        paymentMapper.insert(payment);

        BigDecimal remaining = outstanding.subtract(payment.getAmount());
        if (remaining.compareTo(ZERO) <= 0 && !"paid".equalsIgnoreCase(invoice.getStatus())) {
            invoice.setStatus("paid");
            invoiceMapper.updateById(invoice);
        }

        log.info("Payment {} recorded for invoice {} ({}), remaining {}",
                payment.getPaymentRef(), invoice.getInvoiceRef(), method, remaining);

        // P1: activity feed writer.
        activityService.log("payment", "Payment received",
                payment.getPaymentRef() + " · " + method + " · "
                        + payment.getAmount().toPlainString() + " for invoice "
                        + invoice.getInvoiceRef(),
                principal != null ? principal.getUserId() : null);

        // FE-FIX (pre-deployment, P2-9): the customer was never told their
        // payment was recorded — only the invoice silently flipped to paid.
        if (invoice.getCustomerId() != null) {
            try {
                Customer customer = customerMapper.selectById(invoice.getCustomerId());
                if (customer != null && customer.getUserId() != null) {
                    notificationService.emit(customer.getUserId(), invoice.getBranchId(),
                            "paymentReceived", "Payment received",
                            "Payment " + payment.getPaymentRef() + " of AED "
                                    + payment.getAmount().setScale(2, RoundingMode.HALF_UP)
                                    + " recorded for invoice " + invoice.getInvoiceRef()
                                    + (remaining.compareTo(ZERO) <= 0 ? " — fully paid." : "."));
                }
            } catch (Exception e) {
                log.warn("Could not notify customer of payment {}: {}", payment.getPaymentRef(), e.getMessage());
            }
        }

        return new PaymentRecordResult(payment.getPaymentRef(), remaining.setScale(2, RoundingMode.HALF_UP));
    }

    /**
     * Outstanding = invoice amount − total payments.
     */
    public BigDecimal outstanding(Invoice invoice) {
        BigDecimal amount = invoice.getAmount() != null ? invoice.getAmount() : ZERO;
        BigDecimal paid = paymentMapper.sumPaidByInvoice(invoice.getId());
        BigDecimal out = amount.subtract(paid != null ? paid : ZERO);
        return out.max(ZERO).setScale(2, RoundingMode.HALF_UP);
    }

    public BigDecimal paidAmount(Long invoiceId) {
        BigDecimal paid = paymentMapper.sumPaidByInvoice(invoiceId);
        return paid != null ? paid.setScale(2, RoundingMode.HALF_UP) : ZERO;
    }

    private Long resolveBranch(Long invoiceBranch, JwtUserPrincipal principal) {
        if (invoiceBranch != null && invoiceBranch > 0) return invoiceBranch;
        if (principal != null && principal.getBranchId() != null && principal.getBranchId() > 0) {
            return principal.getBranchId();
        }
        return null;
    }

    public List<Payment> paymentsForInvoice(Long invoiceId) {
        return paymentMapper.findByInvoiceId(invoiceId);
    }

    public record PaymentRecordResult(String paymentRef, BigDecimal remaining) {
    }
}
