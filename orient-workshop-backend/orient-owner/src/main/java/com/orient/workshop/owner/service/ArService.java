package com.orient.workshop.owner.service;

import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.owner.model.dto.ArRecordResponse;
import com.orient.workshop.owner.model.dto.ArSummaryResponse;
import com.orient.workshop.owner.model.entity.Invoice;
import com.orient.workshop.owner.repository.InvoiceMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ArService {

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private final InvoiceMapper invoiceMapper;
    private final CustomerMapper customerMapper;

    public ArSummaryResponse getSummary() {
        long d0to30 = 0, d31to60 = 0, d61to90 = 0, d90plus = 0;
        long totalOutstanding = 0;
        for (Invoice inv : outstandingInvoices()) {
            long outstanding = Math.round(inv.getAmount() != null ? inv.getAmount().doubleValue() : 0.0);
            String bucket = agingBucket(inv);
            switch (bucket) {
                case "days0to30" -> d0to30 += outstanding;
                case "days31to60" -> d31to60 += outstanding;
                case "days61to90" -> d61to90 += outstanding;
                default -> d90plus += outstanding;
            }
            totalOutstanding += outstanding;
        }
        return ArSummaryResponse.builder()
                .totalOutstanding(totalOutstanding)
                .days0to30(d0to30)
                .days31to60(d31to60)
                .days61to90(d61to90)
                .days90plus(d90plus)
                .build();
    }

    public List<ArRecordResponse> getRecords() {
        Map<Long, Customer> customers = customerMapper.selectList(null).stream()
                .collect(Collectors.toMap(Customer::getId, Function.identity()));
        return outstandingInvoices().stream()
                .map(inv -> {
                    Customer customer = customers.get(inv.getCustomerId());
                    String name = customer != null && customer.getCustomerName() != null
                            ? customer.getCustomerName() : "";
                    return ArRecordResponse.builder()
                            .arId(inv.getInvoiceRef())
                            .customer(name)
                            .invoiceDate(inv.getIssuedDate() != null ? inv.getIssuedDate().format(DATE_FMT) : "")
                            .dueDate(inv.getDueDate() != null ? inv.getDueDate().format(DATE_FMT) : "")
                            .amount(inv.getAmount() != null ? inv.getAmount().doubleValue() : 0.0)
                            .outstanding(inv.getAmount() != null ? inv.getAmount().doubleValue() : 0.0)
                            .aging(agingBucket(inv))
                            .contactPerson(name)
                            .phone(customer != null && customer.getPhoneNumber() != null ? customer.getPhoneNumber() : "")
                            .build();
                })
                .collect(Collectors.toList());
    }

    private List<Invoice> outstandingInvoices() {
        return invoiceMapper.selectList(null).stream()
                .filter(inv -> inv.getStatus() == null || !"paid".equalsIgnoreCase(inv.getStatus()))
                .collect(Collectors.toList());
    }

    private String agingBucket(Invoice inv) {
        LocalDate refDate = inv.getDueDate() != null ? inv.getDueDate() : inv.getIssuedDate();
        if (refDate == null) return "days0to30";
        long days = ChronoUnit.DAYS.between(refDate, LocalDate.now());
        if (days <= 30) return "days0to30";
        if (days <= 60) return "days31to60";
        if (days <= 90) return "days61to90";
        return "days90plus";
    }
}
