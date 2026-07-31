-- ============================================================
-- Migration: Advanced CRM (lead value/notes/follow-up + activities + team)
-- Run against the existing `orient_workshop` database.
-- ============================================================

ALTER TABLE leads ADD COLUMN notes TEXT AFTER last_activity;
ALTER TABLE leads ADD COLUMN lead_value DECIMAL(12,2) DEFAULT 0 AFTER notes;
ALTER TABLE leads ADD COLUMN follow_up_date VARCHAR(50) DEFAULT '' AFTER lead_value;

CREATE TABLE IF NOT EXISTS lead_activities (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    lead_id     BIGINT NOT NULL,
    action      VARCHAR(50) NOT NULL,
    detail      VARCHAR(255) DEFAULT '',
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_lead_activities_lead (lead_id)
) ENGINE=InnoDB;
