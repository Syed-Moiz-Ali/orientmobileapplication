package com.orient.workshop.sync.service;

import com.orient.workshop.auth.filter.JwtUserPrincipal;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;

public final class IdempotencyScope {
    private IdempotencyScope() {
    }

    public static String scopedHash(JwtUserPrincipal principal, String method, String path,
                                    String idempotencyKey, Long branchId) {
        String userId = principal != null && principal.getUserId() != null
                ? principal.getUserId().toString() : "anonymous";
        String scopedBranch = branchId != null ? branchId.toString() : "none";
        String normalizedPath = normalizePath(path);
        return sha256Hex(userId + "|" + scopedBranch + "|"
                + safe(method).toUpperCase() + "|" + normalizedPath + "|"
                + safe(idempotencyKey).trim());
    }

    public static String normalizePath(String path) {
        if (path == null || path.isBlank()) return "/";
        int queryIndex = path.indexOf('?');
        String withoutQuery = queryIndex >= 0 ? path.substring(0, queryIndex) : path;
        return withoutQuery.replaceAll("/{2,}", "/");
    }

    private static String safe(String value) {
        return value == null ? "" : value;
    }

    private static String sha256Hex(String value) {
        try {
            return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256")
                    .digest(value.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 unavailable", e);
        }
    }
}
