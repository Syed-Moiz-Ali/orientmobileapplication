package com.orient.workshop.owner.service;

import com.orient.workshop.owner.model.dto.ActivityResponse;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ActivityService {

    public List<ActivityResponse> getActivity(int page, int limit) {
        return List.of(
            act("a1", "job_card", "New job card created", "Ahmed Hassan · Toyota Camry · Full Service", "2026-07-27T12:34:56"),
            act("a2", "inspection", "Inspection completed", "BMW 3 Series · All sections passed", "2026-07-27T12:04:56"),
            act("a3", "approval", "Estimate approved", "Nissan Patrol · EST-2024-089 · AED 1,250", "2026-07-27T11:34:56"),
            act("a4", "invoice", "Invoice raised", "Ford Focus · INV-2026-003 · AED 3,800", "2026-07-27T10:34:56"),
            act("a5", "parts", "Parts arrived", "Order #PO-042 · Brake pads, Oil filters", "2026-07-27T09:34:56"),
            act("a6", "payment", "Payment received", "Honda Accord · INV-2026-001 · AED 2,450", "2026-07-27T06:34:56")
        );
    }

    private ActivityResponse act(String id, String type, String title, String desc, String ts) {
        return ActivityResponse.builder().id(id).type(type).title(title).description(desc).timestamp(ts).build();
    }
}
