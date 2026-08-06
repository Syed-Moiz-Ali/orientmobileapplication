-- ===================================================================
-- V6: P0 integrity fixes (2026-08-06 audit).
--   1. device_tokens table (entity existed, table never created)
--   2. vehicles.created_at/updated_at (entity writes them; columns missing)
--   3. ENUM drift: job_cards.status, bookings.status, notifications.type,
--      staff.role — code writes values the schema rejects (409 crashes)
--   4. feedback phantom columns (entity writes them; columns missing)
--   5. Missing indexes (branch_id x5, leads.follow_up_date,
--      whatsapp_messages.external_id, inspections.advisor_id)
--   6. CHECK constraints (ratings / percentages / amounts)
--   7. Referential integrity (lead_activities cascade, invoices + bookings
--      job_card_id FKs, technician_tasks emp_id nullable FK restored)
--   8. Drop genuinely dead tables (predefined_services/predefined_parts
--      have no entity or mapper anywhere)
--
-- Idempotent: every DDL is guarded against information_schema so the script
-- applies cleanly to BOTH fresh databases and legacy DBs that already
-- received some of these columns manually.
-- ===================================================================

-- ---------- 1. DEVICE TOKENS ----------
CREATE TABLE IF NOT EXISTS device_tokens (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT NOT NULL,
    token       VARCHAR(512) NOT NULL,
    platform    VARCHAR(20) NOT NULL DEFAULT 'android',
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_token (user_id, token),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- ---------- 2. VEHICLES TIMESTAMPS ----------
SET @col := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vehicles' AND COLUMN_NAME = 'created_at');
SET @ddl := IF(@col = 0, 'ALTER TABLE vehicles ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vehicles' AND COLUMN_NAME = 'updated_at');
SET @ddl := IF(@col = 0, 'ALTER TABLE vehicles ADD COLUMN updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER created_at', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ---------- 3. ENUM EXTENSIONS ----------
-- job_cards.status: values written by AdvisorBookingService.checkIn
-- (vehicleReceived), RepairOrderService.sendEstimate (waitingCustomerApproval),
-- JobCardService.deliver (delivered), SupervisorQueueService.qcReview
-- (qualityCheckPassed).
ALTER TABLE job_cards
    MODIFY COLUMN status ENUM('inProgress','pendingApproval','qualityCheck','completed',
                              'cancelled','waitingParts','pending','awaitingSupervisor',
                              'vehicleReceived','waitingCustomerApproval','delivered',
                              'qualityCheckPassed')
        DEFAULT 'pending';

-- bookings.status: values written by AdvisorBookingService.checkIn
-- (vehicle_received) and validated by BookingService.updateStatus (in_service).
ALTER TABLE bookings
    MODIFY COLUMN status ENUM('confirmed','completed','pending','cancelled',
                              'vehicle_received','in_service')
        DEFAULT 'pending';

-- bookings.vehicle_id was NOT NULL with a FK, but BookingService.createBooking
-- accepts a null vehicleId (customer booking without a registered vehicle) —
-- every such insert failed with a FK/not-null error.
ALTER TABLE bookings
    MODIFY COLUMN vehicle_id BIGINT NULL;

-- notifications.type: values written by TechnicianRequestController
-- (PARTS_REQUEST, ESCALATION).
ALTER TABLE notifications
    MODIFY COLUMN type ENUM('carReady','bookingConfirmed','invoiceReady','approvalNeeded',
                            'workInProgress','reminder','bookingReceived','bookingAssigned',
                            'breakdownAssigned','workAssigned','jobAwaitingReview',
                            'completionApproved','completionRejected','estimateApproved',
                            'estimateRejected','PARTS_REQUEST','ESCALATION')
        DEFAULT 'carReady';

-- staff.role: 'sales' used by CRM TeamService.
ALTER TABLE staff
    MODIFY COLUMN role ENUM('advisor','technician','supervisor','sales')
        NOT NULL;

-- ---------- 4. FEEDBACK PHANTOM COLUMNS ----------
-- Feedback entity (orient-core) declares these; without the columns,
-- any populated dimension broke INSERT.
SET @col := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'feedback' AND COLUMN_NAME = 'overall_rating');
SET @ddl := IF(@col = 0, 'ALTER TABLE feedback ADD COLUMN overall_rating TINYINT NULL AFTER rating', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'feedback' AND COLUMN_NAME = 'work_quality');
SET @ddl := IF(@col = 0, 'ALTER TABLE feedback ADD COLUMN work_quality TINYINT NULL AFTER overall_rating', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'feedback' AND COLUMN_NAME = 'communication');
SET @ddl := IF(@col = 0, 'ALTER TABLE feedback ADD COLUMN communication TINYINT NULL AFTER work_quality', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'feedback' AND COLUMN_NAME = 'timeliness');
SET @ddl := IF(@col = 0, 'ALTER TABLE feedback ADD COLUMN timeliness TINYINT NULL AFTER communication', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'feedback' AND COLUMN_NAME = 'value_for_money');
SET @ddl := IF(@col = 0, 'ALTER TABLE feedback ADD COLUMN value_for_money TINYINT NULL AFTER timeliness', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'feedback' AND COLUMN_NAME = 'would_recommend');
SET @ddl := IF(@col = 0, 'ALTER TABLE feedback ADD COLUMN would_recommend BOOLEAN NULL AFTER value_for_money', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ---------- 5. MISSING INDEXES ----------
SET @idx := (SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vehicles' AND INDEX_NAME = 'idx_branch');
SET @ddl := IF(@idx = 0, 'ALTER TABLE vehicles ADD INDEX idx_branch (branch_id)', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @idx := (SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'bookings' AND INDEX_NAME = 'idx_branch');
SET @ddl := IF(@idx = 0, 'ALTER TABLE bookings ADD INDEX idx_branch (branch_id)', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @idx := (SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'invoices' AND INDEX_NAME = 'idx_branch');
SET @ddl := IF(@idx = 0, 'ALTER TABLE invoices ADD INDEX idx_branch (branch_id)', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @idx := (SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'notifications' AND INDEX_NAME = 'idx_branch');
SET @ddl := IF(@idx = 0, 'ALTER TABLE notifications ADD INDEX idx_branch (branch_id)', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @idx := (SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'work_assignments' AND INDEX_NAME = 'idx_branch');
SET @ddl := IF(@idx = 0, 'ALTER TABLE work_assignments ADD INDEX idx_branch (branch_id)', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @idx := (SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND INDEX_NAME = 'idx_follow_up');
SET @ddl := IF(@idx = 0, 'ALTER TABLE leads ADD INDEX idx_follow_up (follow_up_date)', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @idx := (SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'whatsapp_messages' AND INDEX_NAME = 'idx_external');
SET @ddl := IF(@idx = 0, 'ALTER TABLE whatsapp_messages ADD INDEX idx_external (external_id)', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @idx := (SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'inspections' AND INDEX_NAME = 'idx_advisor');
SET @ddl := IF(@idx = 0, 'ALTER TABLE inspections ADD INDEX idx_advisor (advisor_id)', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ---------- 6. CHECK CONSTRAINTS (MySQL 8.0.16+) ----------
SET @chk := (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'feedback' AND CONSTRAINT_NAME = 'chk_feedback_rating');
SET @ddl := IF(@chk = 0, 'ALTER TABLE feedback ADD CONSTRAINT chk_feedback_rating CHECK (rating BETWEEN 1 AND 5)', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @chk := (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'work_assignments' AND CONSTRAINT_NAME = 'chk_assignment_percent');
SET @ddl := IF(@chk = 0, 'ALTER TABLE work_assignments ADD CONSTRAINT chk_assignment_percent CHECK (status_percent BETWEEN 0 AND 100)', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @chk := (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vehicles' AND CONSTRAINT_NAME = 'chk_health_score');
SET @ddl := IF(@chk = 0, 'ALTER TABLE vehicles ADD CONSTRAINT chk_health_score CHECK (health_score BETWEEN 0 AND 100)', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @chk := (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'invoices' AND CONSTRAINT_NAME = 'chk_invoice_amount');
SET @ddl := IF(@chk = 0, 'ALTER TABLE invoices ADD CONSTRAINT chk_invoice_amount CHECK (amount >= 0)', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @chk := (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'approvals' AND CONSTRAINT_NAME = 'chk_approval_amount');
SET @ddl := IF(@chk = 0, 'ALTER TABLE approvals ADD CONSTRAINT chk_approval_amount CHECK (amount >= 0)', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ---------- 7. REFERENTIAL INTEGRITY ----------
-- Orphans from before V6 would block the FK; clear them first.
DELETE FROM lead_activities WHERE lead_id IS NOT NULL AND lead_id NOT IN (SELECT id FROM leads);
SET @fk := (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'lead_activities' AND CONSTRAINT_NAME = 'fk_lead_activities_lead');
SET @ddl := IF(@fk = 0, 'ALTER TABLE lead_activities ADD CONSTRAINT fk_lead_activities_lead FOREIGN KEY (lead_id) REFERENCES leads(id) ON DELETE CASCADE', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

DELETE FROM invoices WHERE job_card_id IS NOT NULL AND job_card_id NOT IN (SELECT id FROM job_cards);
SET @fk := (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'invoices' AND CONSTRAINT_NAME = 'fk_invoices_job_card');
SET @ddl := IF(@fk = 0, 'ALTER TABLE invoices ADD CONSTRAINT fk_invoices_job_card FOREIGN KEY (job_card_id) REFERENCES job_cards(id)', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

DELETE FROM bookings WHERE job_card_id IS NOT NULL AND job_card_id NOT IN (SELECT id FROM job_cards);
SET @fk := (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'bookings' AND CONSTRAINT_NAME = 'fk_bookings_job_card');
SET @ddl := IF(@fk = 0, 'ALTER TABLE bookings ADD CONSTRAINT fk_bookings_job_card FOREIGN KEY (job_card_id) REFERENCES job_cards(id)', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- V5 dropped this FK to allow unassigned rows; restore it as a nullable FK
-- so phantom employees cannot be referenced. Clear orphaned emp_ids first.
UPDATE technician_tasks SET emp_id = NULL WHERE emp_id = '';
UPDATE technician_tasks t SET t.emp_id = NULL WHERE t.emp_id IS NOT NULL AND t.emp_id != '' AND NOT EXISTS (SELECT 1 FROM staff s WHERE s.emp_id = t.emp_id);
SET @fk := (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'technician_tasks' AND CONSTRAINT_NAME = 'fk_technician_tasks_emp');
SET @ddl := IF(@fk = 0, 'ALTER TABLE technician_tasks ADD CONSTRAINT fk_technician_tasks_emp FOREIGN KEY (emp_id) REFERENCES staff(emp_id)', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ---------- 8. DROP DEAD TABLES ----------
-- No entity, no mapper, no query references these anywhere in the backend.
DROP TABLE IF EXISTS predefined_services;
DROP TABLE IF EXISTS predefined_parts;
