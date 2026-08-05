package com.orient.workshop.owner.controller;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.owner.model.dto.InvoiceResponse;
import com.orient.workshop.owner.service.InvoiceService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "Customer Invoices")
@RestController
@RequestMapping("/customers/invoices")
@RequiredArgsConstructor
public class CustomerInvoiceController {

    private final InvoiceService invoiceService;
    private final CustomerMapper customerMapper;

    @GetMapping
    public ApiResponse<List<InvoiceResponse>> getMyInvoices(@AuthenticationPrincipal JwtUserPrincipal principal) {
        Customer customer = principal != null && principal.getUserId() != null
                ? customerMapper.findByUserId(principal.getUserId()).orElse(null)
                : null;
        if (customer == null) {
            throw new NotFoundException("No customer profile linked to this account yet");
        }
        return ApiResponse.success(invoiceService.getInvoicesForCustomer(customer.getId()));
    }
}
