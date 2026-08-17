package com.orient.workshop.auth.security;

import java.util.Locale;
import org.springframework.stereotype.Component;

/** Server-side application boundary for the first-party clients. */
@Component
public class AppAccessPolicy {
    public boolean isAllowed(String appName, String role) {
        if (appName == null || appName.isBlank()) return true;
        if (role == null || role.isBlank()) return false;

        return switch (appName.trim().toLowerCase(Locale.ROOT)) {
            case "customer" -> "customer".equalsIgnoreCase(role);
            case "staff" -> switch (role.toLowerCase(Locale.ROOT)) {
                case "advisor", "supervisor", "technician" -> true;
                default -> false;
            };
            case "owner" -> "owner".equalsIgnoreCase(role);
            case "crm" -> "crmdashboard".equalsIgnoreCase(role);
            default -> false;
        };
    }
}
