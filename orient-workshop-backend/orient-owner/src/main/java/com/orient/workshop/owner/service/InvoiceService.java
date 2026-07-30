package com.orient.workshop.owner.service;

import com.orient.workshop.owner.model.dto.InvoiceResponse;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class InvoiceService {

    public List<InvoiceResponse> getInvoices(String status) {
        return List.of(
            inv("INV-2026-0001", "Ahmed Hassan", "01/07/2026", 3800.0, "unpaid"),
            inv("INV-2026-0002", "John Anderson", "28/06/2026", 5200.0, "paid"),
            inv("INV-2026-0003", "Sarah Williams", "25/06/2026", 2100.0, "unpaid")
        ).stream().filter(i -> status == null || i.getStatus().equals(status)).collect(java.util.stream.Collectors.toList());
    }

    private InvoiceResponse inv(String id, String name, String date, double amount, String status) {
        return InvoiceResponse.builder().id(id).customerName(name).date(date).amount(amount).status(status).build();
    }
}
