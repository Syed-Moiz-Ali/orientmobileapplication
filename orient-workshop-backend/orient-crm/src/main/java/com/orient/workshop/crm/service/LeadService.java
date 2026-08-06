package com.orient.workshop.crm.service;

import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.common.util.IdGenerator;
import com.orient.workshop.crm.model.dto.LeadActivityResponse;
import com.orient.workshop.crm.model.dto.LeadResponse;
import com.orient.workshop.crm.model.entity.Lead;
import com.orient.workshop.crm.model.entity.LeadActivity;
import com.orient.workshop.crm.repository.LeadActivityMapper;
import com.orient.workshop.crm.repository.LeadMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Set;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class LeadService {

    private static final Set<String> VALID_STATUSES = Set.of(
            "ACTIVE", "WON", "UNANSWERED", "LOST", "NO_RESPONSE");

    private final LeadMapper leadMapper;
    private final LeadActivityMapper activityMapper;
    private final AtomicInteger sno = new AtomicInteger(0);

    public List<LeadResponse> getLeads(String status, String source, int page, int size) {
        int offset = Math.max(page - 1, 0) * size;
        List<Lead> leads;
        if (status != null && !status.isBlank() && source != null && !source.isBlank()) {
            leads = leadMapper.findByFilters(status, source, offset, size);
        } else if (status != null && !status.isBlank()) {
            leads = leadMapper.findByFilters(status, null, offset, size);
        } else if (source != null && !source.isBlank()) {
            leads = leadMapper.findByFilters(null, source, offset, size);
        } else {
            leads = leadMapper.findPage(offset, size);
        }
        return toResponses(leads);
    }

    public List<LeadResponse> getAllLeads() {
        return toResponses(leadMapper.findPage(0, 500));
    }

    @Transactional
    public LeadResponse createLead(LeadResponse req) {
        String status = req.getStatus() != null ? req.getStatus() : "ACTIVE";
        validateStatus(status);
        Lead lead = Lead.builder()
                .leadNumber(req.getLeadNumber() != null ? req.getLeadNumber() : generateLeadNumber())
                .customerName(req.getCustomerName())
                .phone(req.getPhone() != null ? req.getPhone() : "")
                .email(req.getEmail() != null ? req.getEmail() : "")
                .source(req.getSource() != null ? req.getSource() : "MANUAL")
                .assignedTo(req.getAssignedTo() != null ? req.getAssignedTo() : "")
                .status(status)
                .lastActivity(req.getLastActivity() != null ? req.getLastActivity() : "Just now")
                .notes(req.getNotes())
                .leadValue(req.getLeadValue() != null ? req.getLeadValue() : BigDecimal.ZERO)
                .followUpDate(req.getFollowUpDate() != null ? req.getFollowUpDate() : "")
                .build();
        leadMapper.insert(lead);
        recordActivity(lead.getId(), "CREATED", "Lead created from " + lead.getSource());
        return toResponse(lead);
    }

    @Transactional
    public LeadResponse updateLead(Long id, LeadResponse req) {
        Lead lead = leadMapper.selectById(id);
        if (lead == null) throw new NotFoundException("Lead not found with id: " + id);

        String oldStatus = lead.getStatus();
        String oldAssignee = lead.getAssignedTo();

        if (req.getCustomerName() != null) lead.setCustomerName(req.getCustomerName());
        if (req.getPhone() != null) lead.setPhone(req.getPhone());
        if (req.getEmail() != null) lead.setEmail(req.getEmail());
        if (req.getSource() != null) lead.setSource(req.getSource());
        if (req.getAssignedTo() != null) lead.setAssignedTo(req.getAssignedTo());
        if (req.getStatus() != null) {
            validateStatus(req.getStatus());
            lead.setStatus(req.getStatus());
        }
        if (req.getLastActivity() != null) lead.setLastActivity(req.getLastActivity());
        if (req.getNotes() != null) lead.setNotes(req.getNotes());
        if (req.getLeadValue() != null) lead.setLeadValue(req.getLeadValue());
        if (req.getFollowUpDate() != null) lead.setFollowUpDate(req.getFollowUpDate());
        leadMapper.updateById(lead);

        if (req.getStatus() != null && !req.getStatus().equals(oldStatus)) {
            recordActivity(lead.getId(), "STATUS", "Status changed from " + oldStatus + " to " + req.getStatus());
        }
        if (req.getAssignedTo() != null && !req.getAssignedTo().equals(oldAssignee)) {
            recordActivity(lead.getId(), "ASSIGNED",
                    (oldAssignee == null || oldAssignee.isBlank() ? "Unassigned" : oldAssignee)
                            + " -> " + (req.getAssignedTo().isBlank() ? "Unassigned" : req.getAssignedTo()));
        }
        return toResponse(lead);
    }

    @Transactional
    public void deleteLead(Long id) {
        if (leadMapper.selectById(id) == null) throw new NotFoundException("Lead not found with id: " + id);
        leadMapper.deleteById(id);
    }

    public List<LeadActivityResponse> getActivities(Long leadId) {
        if (leadMapper.selectById(leadId) == null) throw new NotFoundException("Lead not found with id: " + leadId);
        return activityMapper.findByLeadId(leadId).stream()
                .map(a -> LeadActivityResponse.builder()
                        .id(String.valueOf(a.getId()))
                        .action(a.getAction())
                        .detail(a.getDetail())
                        .createdAt(a.getCreatedAt() != null ? a.getCreatedAt().toString() : "")
                        .build())
                .collect(Collectors.toList());
    }

    @Transactional
    public Lead upsertByExternalId(String externalId, LeadResponse req) {
        Lead existing = leadMapper.findByExternalId(externalId);
        if (existing != null) {
            existing.setCustomerName(req.getCustomerName());
            existing.setPhone(req.getPhone());
            existing.setEmail(req.getEmail());
            existing.setSource(req.getSource());
            existing.setLastActivity(req.getLastActivity());
            if (req.getAssignedTo() != null) existing.setAssignedTo(req.getAssignedTo());
            // P2 (audit): the update path previously never refreshed these.
            if (req.getStatus() != null) existing.setStatus(req.getStatus());
            if (req.getLeadValue() != null) existing.setLeadValue(req.getLeadValue());
            if (req.getFollowUpDate() != null) existing.setFollowUpDate(req.getFollowUpDate());
            leadMapper.updateById(existing);
            return existing;
        }
        // P2 (audit): race-safe upsert — the unique index on external_id
        // (V9) makes concurrent syncs insert-on-duplicate instead of 500ing.
        Lead lead = Lead.builder()
                .leadNumber(req.getLeadNumber() != null ? req.getLeadNumber() : generateLeadNumber())
                .customerName(req.getCustomerName())
                .phone(req.getPhone() != null ? req.getPhone() : "")
                .email(req.getEmail() != null ? req.getEmail() : "")
                .source(req.getSource() != null ? req.getSource() : "META")
                .assignedTo(req.getAssignedTo() != null ? req.getAssignedTo() : "")
                .status(req.getStatus() != null ? req.getStatus() : "ACTIVE")
                .lastActivity(req.getLastActivity() != null ? req.getLastActivity() : "Just now")
                .notes("")
                .leadValue(BigDecimal.ZERO)
                .followUpDate("")
                .externalId(externalId)
                .build();
        try {
            leadMapper.insert(lead);
            recordActivity(lead.getId(), "IMPORTED", "Lead imported from " + lead.getSource());
            return lead;
        } catch (org.springframework.dao.DuplicateKeyException e) {
            // Lost the race — another sync inserted it; fetch and update.
            Lead winner = leadMapper.findByExternalId(externalId);
            if (winner != null) {
                winner.setCustomerName(req.getCustomerName());
                winner.setPhone(req.getPhone());
                winner.setEmail(req.getEmail());
                winner.setLastActivity(req.getLastActivity());
                leadMapper.updateById(winner);
                return winner;
            }
            throw e;
        }
    }

    public long countBySource(String source) {
        return leadMapper.selectCount(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<Lead>()
                        .eq("source", source));
    }

    private void recordActivity(Long leadId, String action, String detail) {
        try {
            LeadActivity activity = LeadActivity.builder()
                    .leadId(leadId).action(action).detail(detail)
                    .build();
            activityMapper.insert(activity);
        } catch (Exception ignored) {
        }
    }

    private List<LeadResponse> toResponses(List<Lead> leads) {
        return leads.stream().map(this::toResponse).collect(Collectors.toList());
    }

    private LeadResponse toResponse(Lead l) {
        return LeadResponse.builder()
                .id(l.getId() != null ? String.valueOf(l.getId()) : "")
                .sno(sno.incrementAndGet())
                .leadNumber(l.getLeadNumber())
                .customerName(l.getCustomerName())
                .phone(l.getPhone())
                .email(l.getEmail())
                .source(l.getSource())
                .assignedTo(l.getAssignedTo())
                .status(l.getStatus())
                .lastActivity(l.getLastActivity())
                .notes(l.getNotes())
                .leadValue(l.getLeadValue() != null ? l.getLeadValue() : BigDecimal.ZERO)
                .followUpDate(l.getFollowUpDate())
                .build();
    }

    private String generateLeadNumber() {
        return IdGenerator.shortRef("LD");
    }

    private void validateStatus(String status) {
        if (status == null || !VALID_STATUSES.contains(status)) {
            throw new BadRequestException("Invalid lead status '" + status + "'. Allowed values: "
                    + String.join(", ", VALID_STATUSES));
        }
    }
}
