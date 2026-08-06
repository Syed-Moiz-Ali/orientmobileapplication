-- ===================================================================
-- V10: P3 enterprise (2026-08-06).
--   1. api_keys — server-to-server integration keys (SHA-256 hash at rest)
--   2. webhook_subscriptions — outbound event webhooks
-- ===================================================================

CREATE TABLE IF NOT EXISTS api_keys (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    name         VARCHAR(100) NOT NULL,
    key_hash     VARCHAR(64) NOT NULL UNIQUE,
    key_prefix   VARCHAR(20) NOT NULL,
    role         VARCHAR(30) NOT NULL DEFAULT 'owner',
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    created_by   BIGINT NULL,
    last_used_at DATETIME NULL,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_hash (key_hash)
);

CREATE TABLE IF NOT EXISTS webhook_subscriptions (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    event_type    VARCHAR(50) NOT NULL,
    url           VARCHAR(500) NOT NULL,
    secret        VARCHAR(100) DEFAULT '',
    is_active     BOOLEAN NOT NULL DEFAULT TRUE,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_event (event_type)
);
