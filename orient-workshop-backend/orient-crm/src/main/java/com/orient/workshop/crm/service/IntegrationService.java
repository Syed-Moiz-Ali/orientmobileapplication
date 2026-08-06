package com.orient.workshop.crm.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.crm.model.dto.IntegrationResponse;
import com.orient.workshop.crm.model.entity.CrmIntegration;
import com.orient.workshop.crm.repository.CrmIntegrationMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Base64;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
public class IntegrationService {

    /**
     * CR-6: integration credentials are encrypted with a DEDICATED key
     * (app.encryption-key) — never the JWT signing secret — using AES-256-GCM
     * with a random 12-byte IV per encryption. The IV is prepended to the
     * ciphertext and the whole blob is base64-encoded.
     */
    private static final String AES_GCM = "AES/GCM/NoPadding";
    private static final int GCM_IV_BYTES = 12;
    private static final int GCM_TAG_BITS = 128;
    private static final String DEV_FALLBACK_KEY = "orient-dev-only-encryption-key-0123456789";

    private final CrmIntegrationMapper integrationMapper;
    private final LeadService leadService;
    private final MetaLeadFetcher metaLeadFetcher;
    private final byte[] encryptionKey;

    public IntegrationService(CrmIntegrationMapper integrationMapper, LeadService leadService,
                              @Lazy MetaLeadFetcher metaLeadFetcher, Environment environment) {
        this.integrationMapper = integrationMapper;
        this.leadService = leadService;
        this.metaLeadFetcher = metaLeadFetcher;
        this.encryptionKey = resolveEncryptionKey(environment);
    }

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
            // P2 (audit): Zoho/Google-Sheets were routed to the META fetcher and
            // ALWAYS errored. Only META has a fetcher today; other providers
            // report an honest "UNSUPPORTED" status instead of a fake ERROR.
            if ("META".equalsIgnoreCase(name)) {
                metaLeadFetcher.sync(name);
                integration = findByName(name);
                integration.setSyncStatus("SUCCESS");
                integration.setLastSyncAt(LocalDateTime.now());
            } else {
                integration = findByName(name);
                integration.setSyncStatus("UNSUPPORTED");
                integration.setLastSyncAt(LocalDateTime.now());
                log.info("Integration {} connected but has no fetcher yet — status UNSUPPORTED", name);
            }
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

    // ===== AES-GCM encryption helpers (CR-6) =====

    /**
     * Resolves the dedicated encryption key. Requires app.encryption-key (>= 16 chars)
     * and refuses to start with one that equals the JWT secret. A dev-only fallback key
     * is used when the property is missing AND the dev profile is active.
     */
    private byte[] resolveEncryptionKey(Environment environment) {
        String configured = environment.getProperty("app.encryption-key");
        if (configured == null || configured.isBlank()) {
            boolean devProfile = Arrays.stream(environment.getActiveProfiles())
                    .anyMatch(p -> "dev".equalsIgnoreCase(p));
            if (!devProfile) {
                throw new IllegalStateException(
                        "app.encryption-key is not configured. Set ENCRYPTION_KEY (>= 16 chars) before starting the service.");
            }
            log.warn("app.encryption-key not set; using DEV-ONLY fallback key. Never use this outside the dev profile.");
            configured = DEV_FALLBACK_KEY;
        }
        if (configured.length() < 16) {
            throw new IllegalStateException("app.encryption-key must be at least 16 characters");
        }
        String jwtSecret = environment.getProperty("app.jwt.secret");
        if (jwtSecret != null && jwtSecret.equals(configured)) {
            throw new IllegalStateException("app.encryption-key must NOT be the same as app.jwt.secret");
        }
        try {
            return MessageDigest.getInstance("SHA-256").digest(configured.getBytes(StandardCharsets.UTF_8));
        } catch (Exception e) {
            throw new IllegalStateException("Failed to derive encryption key", e);
        }
    }

    private String encrypt(String plain) {
        try {
            byte[] iv = new byte[GCM_IV_BYTES];
            new SecureRandom().nextBytes(iv);
            Cipher cipher = Cipher.getInstance(AES_GCM);
            cipher.init(Cipher.ENCRYPT_MODE, new SecretKeySpec(encryptionKey, "AES"),
                    new GCMParameterSpec(GCM_TAG_BITS, iv));
            byte[] ciphertext = cipher.doFinal(plain.getBytes(StandardCharsets.UTF_8));
            byte[] blob = new byte[iv.length + ciphertext.length];
            System.arraycopy(iv, 0, blob, 0, iv.length);
            System.arraycopy(ciphertext, 0, blob, iv.length, ciphertext.length);
            return Base64.getEncoder().encodeToString(blob);
        } catch (Exception e) {
            throw new RuntimeException("Failed to encrypt credentials", e);
        }
    }

    private String decrypt(String encoded) {
        try {
            byte[] blob = Base64.getDecoder().decode(encoded);
            if (blob.length < GCM_IV_BYTES + GCM_TAG_BITS / 8) {
                throw new IllegalArgumentException("Encrypted blob is too short");
            }
            byte[] iv = Arrays.copyOfRange(blob, 0, GCM_IV_BYTES);
            byte[] ciphertext = Arrays.copyOfRange(blob, GCM_IV_BYTES, blob.length);
            Cipher cipher = Cipher.getInstance(AES_GCM);
            cipher.init(Cipher.DECRYPT_MODE, new SecretKeySpec(encryptionKey, "AES"),
                    new GCMParameterSpec(GCM_TAG_BITS, iv));
            return new String(cipher.doFinal(ciphertext), StandardCharsets.UTF_8);
        } catch (Exception e) {
            // Credentials stored with the legacy AES/ECB + JWT-secret scheme cannot be
            // migrated silently; the integration must be reconnected.
            throw new IllegalStateException(
                    "Failed to decrypt integration credentials (legacy blobs require reconnect)", e);
        }
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
