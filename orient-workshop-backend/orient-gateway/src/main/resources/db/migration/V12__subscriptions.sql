-- ===================================================================
-- V12: SaaS billing MVP (2026-08-06).
--   1. subscriptions — per-branch plan subscription (SaaS tiers)
-- ===================================================================

CREATE TABLE IF NOT EXISTS subscriptions (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    branch_id   BIGINT NULL,
    plan        VARCHAR(30) NOT NULL DEFAULT 'starter',
    status      ENUM('active','trial','expired','cancelled') DEFAULT 'trial',
    started_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    renews_at   DATE NULL,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_subscription_branch (branch_id),
    CONSTRAINT chk_plan CHECK (plan IN ('starter','pro','enterprise'))
);
