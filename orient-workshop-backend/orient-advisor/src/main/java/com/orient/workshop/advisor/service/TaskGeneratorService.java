package com.orient.workshop.advisor.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.orient.workshop.advisor.model.entity.Inspection;
import com.orient.workshop.advisor.model.entity.RepairOrder;
import com.orient.workshop.advisor.model.entity.RepairOrderServiceItem;
import com.orient.workshop.advisor.repository.InspectionMapper;
import com.orient.workshop.advisor.repository.RepairOrderMapper;
import com.orient.workshop.advisor.repository.RepairOrderServiceMapper;
import com.orient.workshop.common.util.IdGenerator;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.model.entity.TechnicianTask;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.core.repository.TechnicianTaskMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Phase 3 — turns the advisor's work into individually tracked technician
 * work items:
 *  - every repair-order SERVICE line item  -> itemType = WORK
 *  - every inspection checklist entry with status fair/poor -> itemType = INSPECTION
 * Each item gets its own technician_tasks row with status pending and can be
 * assigned to a different technician.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class TaskGeneratorService {

    private static final Set<String> ISSUE_STATUSES = Set.of("fair", "poor");

    private final JobCardMapper jobCardMapper;
    private final InspectionMapper inspectionMapper;
    private final RepairOrderMapper repairOrderMapper;
    private final RepairOrderServiceMapper serviceMapper;
    private final TechnicianTaskMapper taskMapper;
    private final ObjectMapper objectMapper;

    @Transactional
    public void generateForJobCard(Long jobCardId) {
        JobCard card = jobCardMapper.selectById(jobCardId);
        if (card == null || card.getJobCardRef() == null) return;

        Set<String> existing = new HashSet<>();
        taskMapper.findByJobCardNo(card.getJobCardRef())
                .forEach(t -> existing.add(t.getDescription()));

        generateWorkItems(card, existing);
        generateInspectionItems(card, existing);
    }

    private void generateWorkItems(JobCard card, Set<String> existing) {
        List<RepairOrder> orders = repairOrderMapper.findByJobCardId(card.getId());
        for (RepairOrder ro : orders) {
            List<RepairOrderServiceItem> services = serviceMapper.findByRepairOrderId(ro.getId());
            for (RepairOrderServiceItem s : services) {
                String name = s.getName() != null ? s.getName() : "Service Work";
                if (existing.contains(name)) continue;
                existing.add(name);
                insert(card, name, "WORK", s.getQty() != null ? s.getQty() : 1,
                        s.getRate() != null ? s.getRate() : 0);
            }
        }
    }

    private void generateInspectionItems(JobCard card, Set<String> existing) {
        List<Inspection> inspections = inspectionMapper.findByJobCardId(card.getId());
        for (Inspection ins : inspections) {
            if (ins.getSections() == null || ins.getSections().isBlank()) continue;
            try {
                Map<String, Map<String, Object>> sections =
                        objectMapper.readValue(ins.getSections(), new TypeReference<>() {});
                for (Map.Entry<String, Map<String, Object>> section : sections.entrySet()) {
                    Map<String, Object> items = section.getValue();
                    if (items == null) continue;
                    for (Map.Entry<String, Object> item : items.entrySet()) {
                        Map<?, ?> detail = item.getValue() instanceof Map<?, ?> m ? m : Map.of();
                        String status = detail.get("status") != null ? detail.get("status").toString() : "";
                        if (!ISSUE_STATUSES.contains(status.toLowerCase())) continue;
                        String name = item.getKey();
                        String desc = status.equalsIgnoreCase("poor")
                                ? name + " (urgent)" : name;
                        if (existing.contains(desc)) continue;
                        existing.add(desc);
                        insert(card, desc, "INSPECTION", 1, 0);
                    }
                }
            } catch (Exception e) {
                log.error("Failed to parse inspection sections for job {}: {}", card.getJobCardRef(), e.getMessage());
            }
        }
    }

    private void insert(JobCard card, String description, String itemType, int qty, double rate) {
        taskMapper.insert(TechnicianTask.builder()
                .jobCardNo(card.getJobCardRef())
                .taskRef(IdGenerator.shortRef("T"))
                .description(description)
                .itemType(itemType)
                .qty(qty)
                .rate(rate)
                .status("pending")
                .build());
        log.info("Generated {} work item '{}' for job {}", itemType, description, card.getJobCardRef());
    }
}
