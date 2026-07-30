package com.orient.workshop.whatsapp.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.core.model.entity.WhatsappMessage;
import com.orient.workshop.whatsapp.service.WhatsAppService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Tag(name = "WhatsApp")
@RestController
@RequestMapping("/whatsapp")
@RequiredArgsConstructor
public class WhatsAppController {

    private final WhatsAppService whatsAppService;

    @PostMapping("/send")
    public ApiResponse<Map<String, String>> send(@AuthenticationPrincipal JwtUserPrincipal principal,
                                                  @RequestBody Map<String, String> req) {
        return ApiResponse.success(whatsAppService.send(
                principal.getBranchId(),
                req.get("customerPhone"),
                req.get("templateName"),
                req.get("message")));
    }

    @PostMapping("/webhook")
    public ApiResponse<Void> webhook(@RequestBody Map<String, Object> payload) {
        whatsAppService.handleWebhook(payload);
        return ApiResponse.success(null);
    }

    @GetMapping("/messages")
    public ApiResponse<List<WhatsappMessage>> getHistory(@RequestParam String customerPhone,
                                                          @RequestParam(defaultValue = "1") int page,
                                                          @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(whatsAppService.getHistory(customerPhone));
    }
}

