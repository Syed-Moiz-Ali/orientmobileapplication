-- ===================================================================
-- V2: Schema deltas missing from the V1 baseline (docs/DATABASE_SCHEMA.sql)
--
-- Fully IDEMPOTENT: every ADD COLUMN is guarded against information_schema,
-- so this migration succeeds on:
--   * fresh databases (V1 baseline first, then V2 creates/alters),
--   * databases created directly from docs/DATABASE_SCHEMA.sql (baseline at V1),
--   * partially-migrated databases (columns/tables already applied manually,
--     e.g. via the old MIGRATION_LEADS_INTEGRATIONS.sql scripts) - already
--     present objects are simply skipped.
--
-- MODIFY/ALTER DEFAULT statements are naturally idempotent (re-running with
-- the same definition is a no-op) and are kept plain.
-- ===================================================================

-- ---------- FEEDBACK ----------
-- Present in V1 on fresh installs; kept idempotent so databases that were
-- previously created directly from docs/DATABASE_SCHEMA.sql are covered too.
CREATE TABLE IF NOT EXISTS feedback (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    job_card_id   BIGINT,
    customer_id   BIGINT NOT NULL,
    branch_id     BIGINT,
    rating        TINYINT NOT NULL,
    comment       TEXT,
    is_public     BOOLEAN DEFAULT FALSE,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (job_card_id) REFERENCES job_cards(id),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (branch_id) REFERENCES branches(id),
    INDEX idx_branch_rating (branch_id, rating)
) ENGINE=InnoDB;

-- ---------- CRM LEAD ACTIVITIES ----------
-- Referenced by LeadActivityMapper / LeadActivity entity (orient-crm).
CREATE TABLE IF NOT EXISTS lead_activities (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    lead_id     BIGINT NOT NULL,
    action      VARCHAR(50) NOT NULL DEFAULT '',
    detail      TEXT,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_lead (lead_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB;

-- ---------- CRM INTEGRATIONS ----------
-- Referenced by CrmIntegration entity + IntegrationService (orient-crm).
SET @col := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'crm_integrations' AND COLUMN_NAME = 'credentials');
SET @ddl := IF(@col = 0, 'ALTER TABLE crm_integrations ADD COLUMN credentials TEXT NULL', 'SELECT 1');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'crm_integrations' AND COLUMN_NAME = 'last_sync_at');
SET @ddl := IF(@col = 0, 'ALTER TABLE crm_integrations ADD COLUMN last_sync_at DATETIME NULL', 'SELECT 1');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'crm_integrations' AND COLUMN_NAME = 'sync_status');
SET @ddl := IF(@col = 0, 'ALTER TABLE crm_integrations ADD COLUMN sync_status VARCHAR(20) NOT NULL DEFAULT ''IDLE''', 'SELECT 1');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ---------- LEADS ----------
-- Referenced by Lead entity / LeadMapper (orient-crm).
SET @col := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'external_id');
SET @ddl := IF(@col = 0, 'ALTER TABLE leads ADD COLUMN external_id VARCHAR(100) DEFAULT ''''', 'SELECT 1');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'notes');
SET @ddl := IF(@col = 0, 'ALTER TABLE leads ADD COLUMN notes TEXT', 'SELECT 1');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'lead_value');
SET @ddl := IF(@col = 0, 'ALTER TABLE leads ADD COLUMN lead_value DECIMAL(12,2) DEFAULT 0.00', 'SELECT 1');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'follow_up_date');
SET @ddl := IF(@col = 0, 'ALTER TABLE leads ADD COLUMN follow_up_date VARCHAR(50) DEFAULT ''''', 'SELECT 1');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- NO_RESPONSE status used by CrmDashboardService KPI aggregation (idempotent MODIFY).
ALTER TABLE leads
    MODIFY status ENUM('ACTIVE','WON','UNANSWERED','LOST','NO_RESPONSE') DEFAULT 'ACTIVE';

-- ---------- SYNC LOGS ----------
-- Extends the sync_logs table so /sync endpoints can persist entity-level
-- records (see SyncLog entity in orient-sync).
SET @col := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sync_logs' AND COLUMN_NAME = 'entity_type');
SET @ddl := IF(@col = 0, 'ALTER TABLE sync_logs ADD COLUMN entity_type VARCHAR(50) DEFAULT ''''', 'SELECT 1');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sync_logs' AND COLUMN_NAME = 'entity_id');
SET @ddl := IF(@col = 0, 'ALTER TABLE sync_logs ADD COLUMN entity_id VARCHAR(100) DEFAULT ''''', 'SELECT 1');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sync_logs' AND COLUMN_NAME = 'payload');
SET @ddl := IF(@col = 0, 'ALTER TABLE sync_logs ADD COLUMN payload TEXT', 'SELECT 1');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sync_logs' AND COLUMN_NAME = 'processed_at');
SET @ddl := IF(@col = 0, 'ALTER TABLE sync_logs ADD COLUMN processed_at DATETIME NULL', 'SELECT 1');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

ALTER TABLE sync_logs
    MODIFY status ENUM('success','conflict','error','processed') DEFAULT 'success';

-- ---------- ROLES ----------
-- SecurityConfig RBAC uses ROLE_ADMIN (RoleConstants.ADMIN); add to the ENUM.
ALTER TABLE users
    MODIFY role ENUM('owner','advisor','technician','customer','supervisor','crmDashboard','admin') NOT NULL DEFAULT 'customer';

-- ---------- INSPECTION OWNERSHIP ----------
-- Advisor drafts are owned per user (draft ownership is persisted server-side).
SET @col := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'inspections' AND COLUMN_NAME = 'advisor_id');
SET @ddl := IF(@col = 0, 'ALTER TABLE inspections ADD COLUMN advisor_id BIGINT NULL', 'SELECT 1');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ---------- REMINDER SOFT DELETE ----------
SET @col := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'reminders' AND COLUMN_NAME = 'deleted');
SET @ddl := IF(@col = 0, 'ALTER TABLE reminders ADD COLUMN deleted BOOLEAN NOT NULL DEFAULT FALSE', 'SELECT 1');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ---------- FEEDBACK MODERATION ----------
-- is_moderated: default false so new feedback needs moderation before publishing.
SET @col := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'feedback' AND COLUMN_NAME = 'is_moderated');
SET @ddl := IF(@col = 0, 'ALTER TABLE feedback ADD COLUMN is_moderated BOOLEAN NOT NULL DEFAULT FALSE', 'SELECT 1');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Defensive: older manual feedback tables may miss columns FeedbackMapper needs.
SET @col := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'feedback' AND COLUMN_NAME = 'branch_id');
SET @ddl := IF(@col = 0, 'ALTER TABLE feedback ADD COLUMN branch_id BIGINT NULL', 'SELECT 1');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'feedback' AND COLUMN_NAME = 'job_card_id');
SET @ddl := IF(@col = 0, 'ALTER TABLE feedback ADD COLUMN job_card_id BIGINT NULL', 'SELECT 1');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Default is_public to TRUE to match the FeedbackService default (app opted in).
ALTER TABLE feedback
    ALTER COLUMN is_public SET DEFAULT TRUE;
