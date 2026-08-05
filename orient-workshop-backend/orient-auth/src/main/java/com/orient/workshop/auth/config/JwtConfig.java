package com.orient.workshop.auth.config;

import jakarta.annotation.PostConstruct;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "app.jwt")
public class JwtConfig {

    public static final int MIN_SECRET_LENGTH = 32;

    public static final String[] KNOWN_PLACEHOLDERS = {
            "your-256-bit-secret-key-change-in-production",
            "change-me",
            "orient-workshop-jwt-secret-key-must-be-at-least-256-bits-long-for-hs256"
    };

    private String secret;
    private long accessTokenExpiry;
    private long refreshTokenExpiry;

    @PostConstruct
    public void validate() {
        validateSecret(this.secret);
    }

    /**
     * Fail-fast JWT secret validation. Called both from the configuration properties
     * binding (JwtConfig) and from JwtUtil's constructor so any boot path is covered.
     */
    public static void validateSecret(String secret) {
        if (secret == null || secret.isBlank()) {
            throw new IllegalStateException(
                    "app.jwt.secret is not configured. Set JWT_SECRET (>= " + MIN_SECRET_LENGTH
                            + " chars) before starting the service.");
        }
        if (secret.length() < MIN_SECRET_LENGTH) {
            throw new IllegalStateException(
                    "app.jwt.secret must be at least " + MIN_SECRET_LENGTH + " characters (got " + secret.length() + ").");
        }
        for (String placeholder : KNOWN_PLACEHOLDERS) {
            if (placeholder.equalsIgnoreCase(secret)) {
                throw new IllegalStateException(
                        "app.jwt.secret is set to a known placeholder value. Refusing to start with a publicly-known secret.");
            }
        }
    }

    public String getSecret() { return secret; }
    public void setSecret(String secret) { this.secret = secret; }

    public long getAccessTokenExpiry() { return accessTokenExpiry; }
    public void setAccessTokenExpiry(long accessTokenExpiry) { this.accessTokenExpiry = accessTokenExpiry; }

    public long getRefreshTokenExpiry() { return refreshTokenExpiry; }
    public void setRefreshTokenExpiry(long refreshTokenExpiry) { this.refreshTokenExpiry = refreshTokenExpiry; }
}
