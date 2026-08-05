package com.orient.workshop.common.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.List;

@Configuration
public class CorsConfig {

    /**
     * M-13: CORS uses an explicit allowlist (app.cors.allowed-origins).
     * Credentials (cookies/Authorization) are only enabled when every configured
     * origin is an exact origin (no wildcards) — wildcard + credentials is invalid.
     */
    @Bean
    public CorsFilter corsFilter(
            @Value("${app.cors.allowed-origins:http://localhost:*,https://*.orient.app}") List<String> allowedOrigins) {
        CorsConfiguration config = new CorsConfiguration();

        if (allowedOrigins != null && !allowedOrigins.isEmpty()) {
            boolean allExact = allowedOrigins.stream()
                    .filter(o -> o != null && !o.isBlank())
                    .noneMatch(o -> o.contains("*"));
            List<String> origins = allowedOrigins.stream()
                    .filter(o -> o != null && !o.isBlank())
                    .toList();
            if (allExact) {
                config.setAllowedOrigins(origins);
                config.setAllowCredentials(true);
            } else {
                config.setAllowedOriginPatterns(origins);
            }
            config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
            config.setAllowedHeaders(List.of("*"));
            config.setMaxAge(3600L);
        }

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return new CorsFilter(source);
    }
}
