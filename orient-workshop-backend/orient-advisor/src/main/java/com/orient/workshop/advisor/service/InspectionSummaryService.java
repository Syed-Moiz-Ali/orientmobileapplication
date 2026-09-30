package com.orient.workshop.advisor.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.orient.workshop.advisor.model.entity.Inspection;
import com.orient.workshop.advisor.repository.InspectionMapper;
import com.orient.workshop.common.exception.NotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * P3 (audit): AI-lite inspection summary — a transparent, template-based
 * summary generated from the stored inspection sections (no external AI).
 * Ready to be upgraded to a real LLM later; the contract stays the same.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class InspectionSummaryService {

    private final InspectionMapper inspectionMapper;
    private final ObjectMapper objectMapper;

    /**
     * Latest inspection attached to a job card, summarised for the advisor
     * workflow. Returns {@code {found:false}} when the job card has no
     * inspection yet so the client can render an empty state.
     */
    public Map<String, Object> summarizeForJobCard(Long jobCardId) {
        Inspection inspection = inspectionMapper.findLatestByJobCardId(jobCardId).orElse(null);
        if (inspection == null) {
            Map<String, Object> empty = new LinkedHashMap<>();
            empty.put("found", false);
            return empty;
        }
        Map<String, Object> result = new LinkedHashMap<>(summarize(inspection.getId()));
        result.put("found", true);
        result.put("inspectionId", inspection.getId());
        result.put("inspectionRef", inspection.getInspectionRef());
        return result;
    }

    public Map<String, Object> summarize(Long inspectionId) {
        Inspection inspection = inspectionMapper.selectById(inspectionId);
        if (inspection == null) throw new NotFoundException("Inspection not found: " + inspectionId);

        List<String> lines = new ArrayList<>();
        int good = 0, fair = 0, poor = 0, total = 0;

        Map<String, Map<String, Object>> sections = parseSections(inspection.getSections());
        for (Map.Entry<String, Map<String, Object>> section : sections.entrySet()) {
            String sectionName = section.getKey();
            List<String> issueItems = new ArrayList<>();
            Map<String, Object> items = section.getValue();
            for (Map.Entry<String, Object> item : items.entrySet()) {
                total++;
                // Stored checklist items are shaped {"status":"poor"}; older or
                // alternative payloads may store the status as a plain string.
                Object raw = item.getValue();
                String st;
                if (raw instanceof Map<?, ?> detail) {
                    Object status = detail.get("status");
                    st = status != null ? status.toString().toLowerCase() : "good";
                } else {
                    st = raw != null ? raw.toString().toLowerCase() : "good";
                }
                switch (st) {
                    case "fair" -> { fair++; issueItems.add(item.getKey() + " (fair)"); }
                    case "poor" -> { poor++; issueItems.add(item.getKey() + " (poor)"); }
                    default -> good++;
                }
            }
            if (!issueItems.isEmpty()) {
                lines.add("• " + sectionName + ": " + String.join(", ", issueItems));
            }
        }

        StringBuilder narrative = new StringBuilder();
        narrative.append("Inspected ").append(total).append(" item(s) across ")
                .append(sections.size()).append(" section(s). ");
        if (poor > 0) {
            narrative.append(poor).append(" item(s) need attention").append(fair > 0 ? ", " + fair + " show wear" : "").append(".");
        } else if (fair > 0) {
            narrative.append(fair).append(" item(s) show wear and may need service soon.");
        } else {
            narrative.append("No issues found — all items are in good condition.");
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("inspectionId", inspectionId);
        result.put("inspectionRef", inspection.getInspectionRef());
        result.put("summary", narrative.toString());
        result.put("counts", Map.of("good", good, "fair", fair, "poor", poor, "total", total));
        result.put("issues", lines);
        result.put("note", "Template-based summary — upgrade to an LLM later; contract unchanged");
        return result;
    }

    @SuppressWarnings("unchecked")
    private Map<String, Map<String, Object>> parseSections(String sectionsJson) {
        if (sectionsJson == null || sectionsJson.isBlank()) return Map.of();
        try {
            Map<String, Object> raw = objectMapper.readValue(sectionsJson, Map.class);
            Map<String, Map<String, Object>> result = new LinkedHashMap<>();
            for (Map.Entry<String, Object> e : raw.entrySet()) {
                if (e.getValue() instanceof Map) {
                    result.put(e.getKey(), (Map<String, Object>) e.getValue());
                }
            }
            return result;
        } catch (Exception e) {
            log.warn("Could not parse inspection sections: {}", e.getMessage());
            return Map.of();
        }
    }
}
