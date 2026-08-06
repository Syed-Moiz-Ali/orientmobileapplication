package com.orient.workshop.customer.controller;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.common.util.IdGenerator;
import com.orient.workshop.core.model.entity.SupportTicket;
import com.orient.workshop.core.repository.SupportTicketMapper;
import com.orient.workshop.customer.service.CustomerService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Tag(name = "Customer Portal")
@RestController
@RequestMapping("/customers/tickets")
@RequiredArgsConstructor
public class CustomerTicketController {

    private final SupportTicketMapper ticketMapper;
    private final CustomerService customerService;

    @GetMapping
    public ApiResponse<List<SupportTicket>> myTickets(
            @AuthenticationPrincipal JwtUserPrincipal principal,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "50") int size) {
        Long customerId = customerService.findOrCreateCustomer(principal.getUserId(), principal.getBranchId()).getId();
        int limit = Math.min(Math.max(size, 1), 100);
        int offset = Math.max(page - 1, 0) * limit;
        return ApiResponse.success(ticketMapper.findByCustomerPaged(customerId, limit, offset));
    }

    @PostMapping
    public ApiResponse<Map<String, String>> create(
            @AuthenticationPrincipal JwtUserPrincipal principal,
            @RequestBody SupportTicket req) {
        if (req.getSubject() == null || req.getSubject().isBlank()) {
            throw new BadRequestException("Subject is required");
        }
        Long customerId = customerService.findOrCreateCustomer(principal.getUserId(), principal.getBranchId()).getId();
        SupportTicket ticket = SupportTicket.builder()
                .ticketRef(IdGenerator.shortRef("TK"))
                .customerId(customerId)
                .branchId(principal.getBranchId() != null && principal.getBranchId() > 0
                        ? principal.getBranchId() : null)
                .subject(req.getSubject().trim())
                .description(req.getDescription() != null ? req.getDescription() : "")
                .priority(req.getPriority() != null ? req.getPriority() : "medium")
                .status("open")
                .build();
        ticketMapper.insert(ticket);
        return ApiResponse.success(Map.of("ticketRef", ticket.getTicketRef(), "status", ticket.getStatus()));
    }
}
