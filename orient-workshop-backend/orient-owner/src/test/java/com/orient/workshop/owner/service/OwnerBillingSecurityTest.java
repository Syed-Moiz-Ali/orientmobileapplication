package com.orient.workshop.owner.service;

import com.orient.workshop.advisor.model.entity.RepairOrder;
import com.orient.workshop.advisor.repository.RepairOrderMapper;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.exception.ForbiddenException;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.core.service.ActivityService;
import com.orient.workshop.core.service.NotificationService;
import com.orient.workshop.owner.model.dto.RecordPaymentRequest;
import com.orient.workshop.owner.model.entity.Invoice;
import com.orient.workshop.owner.model.entity.Payment;
import com.orient.workshop.owner.repository.InvoiceMapper;
import com.orient.workshop.owner.repository.PaymentMapper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class OwnerBillingSecurityTest {

    @Mock private InvoiceMapper invoiceMapper;
    @Mock private CustomerMapper customerMapper;
    @Mock private JobCardMapper jobCardMapper;
    @Mock private RepairOrderMapper repairOrderMapper;
    @Mock private NotificationService notificationService;
    @Mock private PaymentMapper paymentMapper;
    @Mock private ActivityService activityService;

    @Test
    void invoice_vat5percent_computedCorrectly() {
        // Repair order grand total = 1000. VAT 5% = 50. grandTotal = 1050.
        InvoiceService svc = new InvoiceService(invoiceMapper, customerMapper, jobCardMapper,
                repairOrderMapper, notificationService);

        when(jobCardMapper.selectById(1L)).thenReturn(
                com.orient.workshop.core.model.entity.JobCard.builder().id(1L).customerId(1L).branchId(1L).build());
        when(invoiceMapper.findByJobCardId(1L)).thenReturn(List.of());
        when(repairOrderMapper.findByJobCardId(1L)).thenReturn(
                List.of(RepairOrder.builder().grandTotal(1000.0).build()));
        when(customerMapper.selectById(1L)).thenReturn(
                Customer.builder().id(1L).customerName("Acme Garage").userId(99L).build());

        String ref = svc.createFromJobCard(1L);

        assertThat(ref).isNotNull();
        ArgumentCaptor<Invoice> captor = ArgumentCaptor.forClass(Invoice.class);
        verify(invoiceMapper).insert(captor.capture());
        Invoice inserted = captor.getValue();

        assertThat(inserted.getAmount()).isEqualByComparingTo(new BigDecimal("1000.00"));
        assertThat(inserted.getTaxAmount()).isEqualByComparingTo(new BigDecimal("50.00"));
        assertThat(inserted.getGrandTotal()).isEqualByComparingTo(new BigDecimal("1050.00"));
    }

    @Test
    void invoice_idempotent_secondCallDoesNotDuplicate() {
        InvoiceService svc = new InvoiceService(invoiceMapper, customerMapper, jobCardMapper,
                repairOrderMapper, notificationService);

        when(jobCardMapper.selectById(1L)).thenReturn(
                com.orient.workshop.core.model.entity.JobCard.builder().id(1L).customerId(1L).branchId(1L).build());
        when(invoiceMapper.findByJobCardId(1L)).thenReturn(List.of(Invoice.builder().build()));

        String ref = svc.createFromJobCard(1L);

        assertThat(ref).isNull();
        verify(invoiceMapper, never()).insert((Invoice) any());
    }

    @Test
    void payment_crossBranch_isRejected() {
        // Invoice belongs to branch 1; caller is from branch 2 -> must be forbidden.
        PaymentService svc = new PaymentService(paymentMapper, invoiceMapper, activityService,
                customerMapper, notificationService);

        when(invoiceMapper.selectById(10L)).thenReturn(
                Invoice.builder().id(10L).branchId(1L).amount(new BigDecimal("500.00")).build());

        RecordPaymentRequest req = RecordPaymentRequest.builder()
                .invoiceId(10L).amount(new BigDecimal("100.00")).build();
        JwtUserPrincipal principal = JwtUserPrincipal.builder()
                .userId(5L).role("advisor").branchId(2L).build();

        assertThatThrownBy(() -> svc.recordPayment(principal, req))
                .isInstanceOf(ForbiddenException.class);

        verify(paymentMapper, never()).insert((Payment) any());
    }

    @Test
    void payment_sameBranch_succeeds() {
        PaymentService svc = new PaymentService(paymentMapper, invoiceMapper, activityService,
                customerMapper, notificationService);

        when(invoiceMapper.selectById(10L)).thenReturn(
                Invoice.builder().id(10L).branchId(1L).customerId(1L).amount(new BigDecimal("500.00")).build());
        when(paymentMapper.sumPaidByInvoice(10L)).thenReturn(BigDecimal.ZERO);
        when(customerMapper.selectById(1L)).thenReturn(
                Customer.builder().id(1L).userId(99L).build());

        RecordPaymentRequest req = RecordPaymentRequest.builder()
                .invoiceId(10L).amount(new BigDecimal("100.00")).build();
        JwtUserPrincipal principal = JwtUserPrincipal.builder()
                .userId(5L).role("advisor").branchId(1L).build();

        var result = svc.recordPayment(principal, req);

        assertThat(result.remaining()).isEqualByComparingTo(new BigDecimal("400.00"));
        verify(paymentMapper).insert((Payment) any());
    }

    @Test
    void payment_exceedsOutstanding_isRejected() {
        PaymentService svc = new PaymentService(paymentMapper, invoiceMapper, activityService,
                customerMapper, notificationService);

        when(invoiceMapper.selectById(10L)).thenReturn(
                Invoice.builder().id(10L).branchId(1L).amount(new BigDecimal("500.00")).build());
        when(paymentMapper.sumPaidByInvoice(10L)).thenReturn(new BigDecimal("450.00"));

        RecordPaymentRequest req = RecordPaymentRequest.builder()
                .invoiceId(10L).amount(new BigDecimal("100.00")).build();
        JwtUserPrincipal principal = JwtUserPrincipal.builder()
                .userId(5L).role("advisor").branchId(1L).build();

        assertThatThrownBy(() -> svc.recordPayment(principal, req))
                .isInstanceOf(com.orient.workshop.common.exception.BadRequestException.class);

        verify(paymentMapper, never()).insert((Payment) any());
    }
}
