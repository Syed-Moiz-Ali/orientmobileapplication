package com.orient.workshop.crm.service;

import com.orient.workshop.crm.model.dto.LeadResponse;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;

@Service
public class LeadService {

    private final AtomicInteger sno = new AtomicInteger(0);

    public List<LeadResponse> getLeads(String status, String source) {
        return getMockLeads().stream()
                .filter(l -> status == null || l.getStatus().equalsIgnoreCase(status))
                .filter(l -> source == null || l.getSource().equalsIgnoreCase(source))
                .collect(Collectors.toList());
    }

    private List<LeadResponse> getMockLeads() {
        return List.of(
            lead("LD-2026-001", "Ahmed Hassan", "+971501234567", "ahmed@email.com", "WhatsApp", "Ahmed Al Maktoum", "ACTIVE", "2 hours ago"),
            lead("LD-2026-002", "John Anderson", "+971501234568", "john@email.com", "Instagram", "Fatima Hassan", "ACTIVE", "1 day ago"),
            lead("LD-2026-003", "Sarah Williams", "+971501234569", "sarah@email.com", "Google Ads", "Ahmed Al Maktoum", "WON", "3 days ago"),
            lead("LD-2026-004", "Mike Brown", "+971501234570", "mike@email.com", "Website", "Khalid Ali", "UNANSWERED", "5 days ago"),
            lead("LD-2026-005", "Lisa Chen", "+971501234571", "lisa@email.com", "WhatsApp", "Fatima Hassan", "LOST", "1 week ago")
        );
    }

    private LeadResponse lead(String number, String name, String phone, String email, String source, String assigned, String status, String activity) {
        return LeadResponse.builder()
                .sno(sno.incrementAndGet()).leadNumber(number).customerName(name).phone(phone).email(email)
                .source(source).assignedTo(assigned).status(status).lastActivity(activity).build();
    }
}
