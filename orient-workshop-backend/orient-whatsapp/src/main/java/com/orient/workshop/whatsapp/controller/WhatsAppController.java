package com.orient.workshop.whatsapp.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.core.model.entity.WhatsappMessage;
import com.orient.workshop.whatsapp.service.WhatsAppService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.HexFormat;
import java.util.List;
import java.util.Map;

@Slf4j
@Tag(name = "WhatsApp")
@RestController
@RequestMapping("/whatsapp")
@RequiredArgsConstructor
public class WhatsAppController {

    private final WhatsAppService whatsAppService;
    private final ObjectMapper objectMapper;

    @Value("${app.whatsapp.verify-token:}")
    private String verifyToken;

    @Value("${app.whatsapp.app-secret:}")
    private String appSecret;

    @PostMapping("/send")
    public ApiResponse<Map<String, String>> send(@AuthenticationPrincipal JwtUserPrincipal principal,
                                                  @RequestBody Map<String, String> req) {
        return ApiResponse.success(whatsAppService.send(
                principal.getBranchId(),
                req.get("customerPhone"),
                req.get("templateName"),
                req.get("message")));
    }

    @GetMapping("/webhook")
    public ResponseEntity<String> verifyWebhook(@RequestParam(name = "hub.mode", required = false) String mode,
                                                @RequestParam(name = "hub.verify_token", required = false) String token,
                                                @RequestParam(name = "hub.challenge", required = false) String challenge) {
        if (!"subscribe".equals(mode)
                || verifyToken == null || verifyToken.isBlank()
                || !verifyToken.equals(token)) {
            log.warn("WhatsApp webhook verification failed: mode={} token={}", mode, token);
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Verification failed");
        }
        log.info("WhatsApp webhook verified");
        return ResponseEntity.ok(challenge != null ? challenge : "");
    }

    @PostMapping("/webhook")
    public ResponseEntity<String> webhook(HttpServletRequest request,
                                          @RequestBody(required = false) byte[] rawBody) {
        if (rawBody == null || rawBody.length == 0) {
            return ResponseEntity.badRequest().body("Empty body");
        }
        if (appSecret != null && !appSecret.isBlank()) {
            String signature = request.getHeader("X-Hub-Signature-256");
            if (signature == null || !signatureIsValid(signature, rawBody)) {
                log.warn("WhatsApp webhook rejected: invalid X-Hub-Signature-256");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid signature");
            }
        } else {
            log.warn("WhatsApp app secret not configured; skipping webhook signature verification");
        }
        try {
            Map<String, Object> payload = objectMapper.readValue(rawBody, Map.class);
            whatsAppService.handleWebhook(payload);
            return ResponseEntity.ok("OK");
        } catch (Exception e) {
            log.error("Failed to process WhatsApp webhook", e);
            return ResponseEntity.badRequest().body("Invalid payload");
        }
    }

    private boolean signatureIsValid(String signature, byte[] rawBody) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(appSecret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            byte[] digest = mac.doFinal(rawBody);
            String expected = "sha256=" + HexFormat.of().formatHex(digest);
            boolean valid = expected.equalsIgnoreCase(signature);
            if (!valid) {
                log.warn("Expected sha256 signature {}, got {}", expected, signature);
            }
            return valid;
        } catch (Exception e) {
            log.error("Signature verification failed", e);
            return false;
        }
    }

    @GetMapping("/messages")
    public ApiResponse<List<WhatsappMessage>> getHistory(@RequestParam String customerPhone,
                                                          @RequestParam(defaultValue = "1") int page,
                                                          @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(whatsAppService.getHistory(customerPhone));
    }
}
