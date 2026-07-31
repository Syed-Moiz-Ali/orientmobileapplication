package com.orient.workshop.crm.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.crm.model.dto.IntegrationResponse;
import com.orient.workshop.crm.model.entity.CrmIntegration;
import com.orient.workshop.crm.repository.CrmIntegrationMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
public class IntegrationService {

    private final CrmIntegrationMapper integrationMapper;
    private final LeadService leadService;
    private final MetaLeadFetcher metaLeadFetcher;

    public IntegrationService(CrmIntegrationMapper integrationMapper, LeadService leadService,
                              @Lazy MetaLeadFetcher metaLeadFetcher) {
        this.integrationMapper = integrationMapper;
        this.leadService = leadService;
        this.metaLeadFetcher = metaLeadFetcher;
    }

    @Value("${app.jwt.secret:orient-workshop-jwt-secret-key-must-be-at-least-256-bits-long-for-hs256}")
    private String secret;

    public List<IntegrationResponse> getIntegrations() {
        return integrationMapper.selectList(null).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public IntegrationResponse connect(String name, Map<String, String> credentials) {
        if (credentials == null || credentials.isEmpty()) {
            throw new BadRequestException("Credentials are required");
        }
        CrmIntegration integration = findByName(name);
        integration.setConnected(true);
        integration.setCredentials(encrypt(jsonOf(credentials)));
        integration.setSyncStatus("IDLE");
        integrationMapper.updateById(integration);
        log.info("Integration {} connected", name);
        return toResponse(integration);
    }

    @Transactional
    public IntegrationResponse disconnect(String name) {
        CrmIntegration integration = findByName(name);
        integration.setConnected(false);
        integration.setCredentials(null);
        integration.setSyncStatus("DISCONNECTED");
        integrationMapper.updateById(integration);
        log.info("Integration {} disconnected", name);
        return toResponse(integration);
    }

    @Transactional
    public IntegrationResponse triggerSync(String name) {
        CrmIntegration integration = findByName(name);
        if (integration.getConnected() == null || !integration.getConnected()) {
            throw new BadRequestException("Integration is not connected: " + name);
        }
        integration.setSyncStatus("SYNCING");
        integrationMapper.updateById(integration);
        try {
            metaLeadFetcher.sync(name);
            integration = findByName(name);
            integration.setSyncStatus("SUCCESS");
            integration.setLastSyncAt(LocalDateTime.now());
            integrationMapper.updateById(integration);
        } catch (Exception e) {
            log.error("Sync failed for integration {}", name, e);
            integration = findByName(name);
            integration.setSyncStatus("ERROR");
            integrationMapper.updateById(integration);
        }
        return toResponse(integration);
    }

    public Map<String, String> getCredentials(String name) {
        CrmIntegration integration = findByName(name);
        if (integration.getCredentials() == null || integration.getCredentials().isBlank()) {
            return Map.of();
        }
        return parseJson(decrypt(integration.getCredentials()));
    }

    public boolean isConnected(String name) {
        CrmIntegration integration = findByName(name);
        return integration.getConnected() != null && integration.getConnected();
    }

    private CrmIntegration findByName(String name) {
        CrmIntegration integration = integrationMapper.selectOne(
                new QueryWrapper<CrmIntegration>().eq("name", name));
        if (integration == null) {
            integration = CrmIntegration.builder()
                    .name(name)
                    .connected(false)
                    .syncStatus("IDLE")
                    .build();
            integrationMapper.insert(integration);
        }
        return integration;
    }

    private IntegrationResponse toResponse(CrmIntegration i) {
        long count = "META".equalsIgnoreCase(i.getName()) || "ZOHO".equalsIgnoreCase(i.getName())
                ? leadService.countBySource(i.getName().toUpperCase())
                : 0;
        return IntegrationResponse.builder()
                .name(i.getName())
                .connected(i.getConnected() != null && i.getConnected())
                .lastSyncAt(i.getLastSyncAt())
                .syncStatus(i.getSyncStatus())
                .leadCount(count)
                .build();
    }

    // ===== AES encryption helpers =====

    private String encrypt(String plain) {
        try {
            byte[] key = padKey(secret);
            SecretKeySpec spec = new SecretKeySpec(key, "AES");
            Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
            cipher.init(Cipher.ENCRYPT_MODE, spec);
            return Base64.getEncoder().encodeToString(cipher.doFinal(plain.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception e) {
            throw new RuntimeException("Failed to encrypt credentials", e);
        }
    }

    private String decrypt(String encoded) {
        try {
            byte[] key = padKey(secret);
            SecretKeySpec spec = new SecretKeySpec(key, "AES");
            Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
            cipher.init(Cipher.DECRYPT_MODE, spec);
            return new String(cipher.doFinal(Base64.getDecoder().decode(encoded)), StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new RuntimeException("Failed to decrypt credentials", e);
        }
    }

    private byte[] padKey(String s) {
        byte[] raw = s.getBytes(StandardCharsets.UTF_8);
        byte[] key = new byte[16];
        System.arraycopy(raw, 0, key, 0, Math.min(raw.length, 16));
        return key;
    }

    @SuppressWarnings("unchecked")
    private Map<String, String> parseJson(String json) {
        try {
            return new com.fasterxml.jackson.databind.ObjectMapper()
                    .readValue(json, Map.class);
        } catch (Exception e) {
            return Map.of();
        }
    }

    private String jsonOf(Map<String, String> map) {
        try {
            return new com.fasterxml.jackson.databind.ObjectMapper().writeValueAsString(map);
        } catch (Exception e) {
            return "{}";
        }
    }
}
