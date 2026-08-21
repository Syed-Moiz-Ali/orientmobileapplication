package com.orient.workshop.auth.filter;

import lombok.Builder;
import lombok.Data;

/**
 * Principal for API-key authenticated requests (server-to-server).
 */
@Data
@Builder
public class ApiKeyPrincipal {
    private Long keyId;
    private String name;
    private String role;
    private Long branchId;
}
