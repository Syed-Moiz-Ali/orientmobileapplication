package com.orient.workshop.owner.service;

import com.orient.workshop.owner.model.dto.ArRecordResponse;
import com.orient.workshop.owner.model.dto.ArSummaryResponse;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ArService {

    public ArSummaryResponse getSummary() {
        return ArSummaryResponse.builder()
                .totalOutstanding(566000)
                .days0to30(250000)
                .days31to60(180000)
                .days61to90(86000)
                .days90plus(50000)
                .build();
    }

    public List<ArRecordResponse> getRecords() {
        return List.of(
            ar("AR-001", "ABC Motors LLC", "01/06/2026", "01/07/2026", 50000, 50000, "days31to60", "John Smith", "+971501234567"),
            ar("AR-002", "Dubai Auto Services", "15/06/2026", "15/07/2026", 35000, 35000, "days0to30", "Mike Johnson", "+971501234568"),
            ar("AR-003", "Premium Cars LLC", "01/03/2026", "01/04/2026", 25000, 25000, "days90plus", "Sarah Lee", "+971501234569")
        );
    }

    private ArRecordResponse ar(String id, String customer, String invDate, String dueDate, double amount, double outstanding, String aging, String contact, String phone) {
        return ArRecordResponse.builder().arId(id).customer(customer).invoiceDate(invDate).dueDate(dueDate)
                .amount(amount).outstanding(outstanding).aging(aging).contactPerson(contact).phone(phone).build();
    }
}
