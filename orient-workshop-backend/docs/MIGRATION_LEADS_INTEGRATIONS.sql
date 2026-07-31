-- ============================================================
-- Migration: feedback table + lead integrations (Meta/Zoho)
-- Run against the existing `orient_workshop` database.
-- ============================================================

-- 1. Feedback table (missing in existing DB)
CREATE TABLE IF NOT EXISTS feedback (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    job_card_id   BIGINT,
    customer_id   BIGINT NOT NULL,
    branch_id     BIGINT,
    rating        TINYINT NOT NULL,
    comment       TEXT,
    is_public     BOOLEAN DEFAULT FALSE,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. Leads: external_id for dedup
ALTER TABLE leads ADD COLUMN external_id VARCHAR(100) DEFAULT '' AFTER last_activity;
CREATE INDEX idx_leads_external_id ON leads(external_id);

-- 3. crm_integrations: credentials + sync tracking
ALTER TABLE crm_integrations ADD COLUMN credentials TEXT AFTER connected;
ALTER TABLE crm_integrations ADD COLUMN last_sync_at TIMESTAMP NULL AFTER credentials;
ALTER TABLE crm_integrations ADD COLUMN sync_status VARCHAR(20) DEFAULT 'IDLE' AFTER last_sync_at;

-- 4. Meta/Zoho integration rows (idempotent)
INSERT IGNORE INTO crm_integrations (name, connected, sync_status) VALUES ('META', FALSE, 'IDLE');
INSERT IGNORE INTO crm_integrations (name, connected, sync_status) VALUES ('ZOHO', FALSE, 'IDLE');
