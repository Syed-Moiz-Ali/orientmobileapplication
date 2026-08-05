package com.orient.workshop.owner.service;

import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.owner.model.dto.InvoiceResponse;
import com.orient.workshop.owner.model.entity.Invoice;
import com.orient.workshop.owner.repository.InvoiceMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class InvoiceService {

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private final InvoiceMapper invoiceMapper;
    private final CustomerMapper customerMapper;

    public List<InvoiceResponse> getInvoices(String status) {
        Map<Long, Customer> customers = customerMapper.selectList(null).stream()
                .collect(Collectors.toMap(Customer::getId, Function.identity()));
        return invoiceMapper.selectList(null).stream()
                .filter(inv -> status == null || status.isBlank() || status.equalsIgnoreCase(inv.getStatus()))
                .map(inv -> {
                    Customer customer = customers.get(inv.getCustomerId());
                    String name = customer != null && customer.getCustomerName() != null
                            ? customer.getCustomerName() : "";
                    return InvoiceResponse.builder()
                            .id(inv.getInvoiceRef())
                            .customerName(name)
                            .date(inv.getIssuedDate() != null ? inv.getIssuedDate().format(DATE_FMT) : "")
                            .amount(inv.getAmount() != null ? inv.getAmount().doubleValue() : 0.0)
                            .status(inv.getStatus() != null ? inv.getStatus() : "")
                            .build();
                })
                .collect(Collectors.toList());
    }
}
