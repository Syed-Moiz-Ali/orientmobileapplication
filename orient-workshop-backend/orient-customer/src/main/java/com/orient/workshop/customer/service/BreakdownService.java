package com.orient.workshop.customer.service;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.util.IdGenerator;
import com.orient.workshop.customer.model.dto.BreakdownRequest;
import com.orient.workshop.customer.model.dto.IdResponse;
import com.orient.workshop.core.model.entity.Breakdown;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.repository.BreakdownMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class BreakdownService {

    private final BreakdownMapper breakdownMapper;
    private final CustomerService customerService;

    @Transactional
    public IdResponse createBreakdown(JwtUserPrincipal principal, BreakdownRequest req) {
        Customer customer = customerService.findOrCreateCustomer(principal.getUserId(), principal.getBranchId());

        String ref = IdGenerator.shortRef("BD");

        Breakdown breakdown = Breakdown.builder()
                .breakdownRef(ref)
                .customerId(customer.getId())
                .issue(req.getIssue())
                .vehicleId(req.getVehicleId() != null ? Long.parseLong(req.getVehicleId()) : null)
                .vehicleName(req.getVehicleName())
                .vehiclePlate(req.getVehiclePlate())
                .location(req.getLocation())
                .status("pending")
                .build();
        breakdownMapper.insert(breakdown);

        return IdResponse.builder().id(ref).build();
    }
}
