package com.orient.workshop.owner.controller;

import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.common.util.IdGenerator;
import com.orient.workshop.core.model.entity.SupportTicket;
import com.orient.workshop.core.repository.SupportTicketMapper;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Set;

@Tag(name = "Owner")
@RestController
@RequestMapping("/owner/tickets")
@RequiredArgsConstructor
public class OwnerTicketController {

    private static final Set<String> VALID_STATUSES = Set.of("open", "in_progress", "resolved", "closed");

    private final SupportTicketMapper ticketMapper;

    @GetMapping
    public ApiResponse<List<SupportTicket>> list(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "50") int size,
            @RequestParam(required = false) String status) {
        int limit = Math.min(Math.max(size, 1), 100);
        int offset = Math.max(page - 1, 0) * limit;
        List<SupportTicket> all = ticketMapper.findPaged(limit, offset);
        if (status != null && !status.isBlank()) {
            all = all.stream().filter(t -> status.equalsIgnoreCase(t.getStatus())).toList();
        }
        return ApiResponse.success(all);
    }

    @PutMapping("/{id}/status")
    public ApiResponse<Map<String, String>> updateStatus(@PathVariable Long id, @RequestParam String status) {
        if (!VALID_STATUSES.contains(status)) {
            throw new BadRequestException("Invalid status: " + status + ". Allowed: " + VALID_STATUSES);
        }
        SupportTicket ticket = ticketMapper.selectById(id);
        if (ticket == null) throw new NotFoundException("Ticket not found: " + id);
        ticket.setStatus(status);
        ticketMapper.updateById(ticket);
        return ApiResponse.success(Map.of("ticketRef", ticket.getTicketRef(), "status", ticket.getStatus()));
    }

    /**
     * Simple ticket creation for staff/owner-side entries (support desk).
     */
    @PostMapping
    public ApiResponse<SupportTicket> create(@RequestBody SupportTicket req) {
        if (req.getSubject() == null || req.getSubject().isBlank()) {
            throw new BadRequestException("Subject is required");
        }
        SupportTicket ticket = SupportTicket.builder()
                .ticketRef(IdGenerator.shortRef("TK"))
                .customerId(req.getCustomerId())
                .branchId(req.getBranchId() != null && req.getBranchId() > 0 ? req.getBranchId() : null)
                .subject(req.getSubject().trim())
                .description(req.getDescription() != null ? req.getDescription() : "")
                .priority(req.getPriority() != null ? req.getPriority() : "medium")
                .status("open")
                .assignedStaffId(req.getAssignedStaffId())
                .build();
        ticketMapper.insert(ticket);
        return ApiResponse.success(ticket);
    }
}
