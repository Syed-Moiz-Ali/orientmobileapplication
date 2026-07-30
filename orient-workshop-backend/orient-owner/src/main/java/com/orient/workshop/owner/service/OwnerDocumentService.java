package com.orient.workshop.owner.service;

import com.orient.workshop.owner.model.dto.DocumentExpiryResponse;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Service
public class OwnerDocumentService {

    public List<DocumentExpiryResponse> getExpiringDocuments() {
        LocalDate now = LocalDate.now();
        return List.of(
            doc("E001", "Ali Hassan", "Technician", "Passport", now.plusDays(19), 19, "critical"),
            doc("E002", "Ravi Kumar", "Advisor", "Visa", now.plusDays(36), 36, "urgent"),
            doc("E003", "Mohammed Salim", "Technician", "Driving License", now.plusDays(80), 80, "warning")
        );
    }

    private DocumentExpiryResponse doc(String empId, String name, String desig, String type, LocalDate expiry, int days, String urgency) {
        return DocumentExpiryResponse.builder()
                .empId(empId).employeeName(name).designation(desig)
                .documentType(type).expiryDate(expiry.toString())
                .daysLeft(days).urgency(urgency).build();
    }
}
