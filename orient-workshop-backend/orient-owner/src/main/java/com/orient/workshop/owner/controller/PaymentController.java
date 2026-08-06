package com.orient.workshop.owner.controller;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.owner.model.dto.RecordPaymentRequest;
import com.orient.workshop.owner.model.entity.Payment;
import com.orient.workshop.owner.service.PaymentService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Tag(name = "Owner")
@RestController
@RequestMapping("/owner")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;

    @PostMapping("/payments")
    public ApiResponse<Map<String, Object>> recordPayment(
            @AuthenticationPrincipal JwtUserPrincipal principal,
            @Valid @RequestBody RecordPaymentRequest req) {
        PaymentService.PaymentRecordResult result = paymentService.recordPayment(principal, req);
        return ApiResponse.success(Map.of(
                "paymentRef", result.paymentRef(),
                "remaining", result.remaining().toPlainString()
        ));
    }

    @GetMapping("/invoices/{id}/payments")
    public ApiResponse<List<Payment>> paymentsForInvoice(@PathVariable Long id) {
        return ApiResponse.success(paymentService.paymentsForInvoice(id));
    }
}
