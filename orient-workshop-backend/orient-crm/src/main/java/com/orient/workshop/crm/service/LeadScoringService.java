package com.orient.workshop.crm.service;

import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.crm.model.entity.Lead;
import com.orient.workshop.crm.repository.LeadMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * P3 (audit): AI-lite lead scoring — a transparent heuristic score (0-100)
 * with explainable factors, ready to be replaced by a model later.
 */
@Service
@RequiredArgsConstructor
public class LeadScoringService {

    private static final DateTimeFormatter ISO = DateTimeFormatter.ISO_LOCAL_DATE_TIME;

    private final LeadMapper leadMapper;

    public Map<String, Object> score(Long leadId) {
        Lead lead = leadMapper.selectById(leadId);
        if (lead == null) throw new NotFoundException("Lead not found: " + leadId);

        int score = 50;
        Map<String, String> factors = new LinkedHashMap<>();

        // Status momentum
        switch (lead.getStatus() == null ? "ACTIVE" : lead.getStatus().toUpperCase()) {
            case "WON" -> { score += 40; factors.put("status", "WON (+40)"); }
            case "PROPOSAL", "QUALIFIED" -> { score += 20; factors.put("status", lead.getStatus() + " (+20)"); }
            case "CONTACTED" -> { score += 10; factors.put("status", "CONTACTED (+10)"); }
            case "NO_RESPONSE", "UNANSWERED" -> { score -= 10; factors.put("status", lead.getStatus() + " (-10)"); }
            case "LOST" -> { score -= 30; factors.put("status", "LOST (-30)"); }
            default -> { }
        }

        // Lead value (AED) — up to +15
        if (lead.getLeadValue() != null && lead.getLeadValue().doubleValue() > 0) {
            int bonus = Math.min(15, (int) (lead.getLeadValue().doubleValue() / 1000.0));
            if (bonus > 0) {
                score += bonus;
                factors.put("value", "AED " + lead.getLeadValue().toPlainString() + " (+" + bonus + ")");
            }
        }

        // Recency decay — stale leads score lower
        LocalDateTime lastActivity = parse(lead.getLastActivity());
        if (lastActivity != null) {
            long days = ChronoUnit.DAYS.between(lastActivity, LocalDateTime.now());
            int decay = (int) Math.min(25, Math.max(0, days / 2));
            if (decay > 0) {
                score -= decay;
                factors.put("recency", days + "d since activity (-" + decay + ")");
            }
        }

        // Overdue follow-up penalty
        if (lead.getFollowUpDate() != null && !lead.getFollowUpDate().isBlank()) {
            LocalDateTime followUp = parse(lead.getFollowUpDate());
            if (followUp != null && followUp.isBefore(LocalDateTime.now())) {
                long overdue = ChronoUnit.DAYS.between(followUp.toLocalDate(), LocalDateTime.now().toLocalDate());
                int penalty = (int) Math.min(20, Math.max(1, overdue * 2));
                score -= penalty;
                factors.put("overdue", overdue + "d overdue (-" + penalty + ")");
            }
        }

        score = Math.max(0, Math.min(100, score));
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("leadId", leadId);
        result.put("leadNumber", lead.getLeadNumber());
        result.put("score", score);
        result.put("tier", score >= 75 ? "HOT" : score >= 50 ? "WARM" : "COLD");
        result.put("factors", factors);
        return result;
    }

    private LocalDateTime parse(String s) {
        if (s == null || s.isBlank()) return null;
        try {
            return LocalDateTime.parse(s, ISO);
        } catch (Exception e) {
            try {
                return LocalDateTime.parse(s);
            } catch (Exception e2) {
                return null;
            }
        }
    }
}
