-- ===================================================================
-- V4: Seamless flows — booking/breakdown routing (supervisor -> advisor),
-- per-item work tracking, supervisor completion review.
-- Runs exactly once per database (Flyway versioning).
-- ===================================================================

-- ---------- BOOKINGS: advisor routing + job-card link ----------
ALTER TABLE bookings
    ADD COLUMN advisor_id BIGINT NULL AFTER branch_id,
    ADD COLUMN job_card_id BIGINT NULL AFTER advisor_id;

-- ---------- BREAKDOWNS: advisor routing + job-card link ----------
ALTER TABLE breakdowns
    ADD COLUMN advisor_id BIGINT NULL AFTER status,
    ADD COLUMN job_card_id BIGINT NULL AFTER advisor_id;

-- ---------- TECHNICIAN TASKS: per-item tracking extensions ----------
ALTER TABLE technician_tasks
    ADD COLUMN item_type VARCHAR(20) NOT NULL DEFAULT 'WORK' AFTER description,
    ADD COLUMN qty INT NOT NULL DEFAULT 1 AFTER item_type,
    ADD COLUMN rate DECIMAL(12,2) NOT NULL DEFAULT 0.00 AFTER qty,
    ADD COLUMN photo_refs JSON NULL AFTER rate,
    ADD COLUMN advisor_id BIGINT NULL AFTER emp_id,
    ADD COLUMN reject_reason VARCHAR(500) NOT NULL DEFAULT '' AFTER status;

-- ---------- JOB CARDS: awaitingSupervisor (completion review) ----------
ALTER TABLE job_cards
    MODIFY COLUMN status ENUM('inProgress','pendingApproval','qualityCheck','completed',
                              'cancelled','waitingParts','pending','awaitingSupervisor')
        DEFAULT 'pending';

-- ---------- NOTIFICATIONS: extra event types ----------
ALTER TABLE notifications
    MODIFY COLUMN type ENUM('carReady','bookingConfirmed','invoiceReady','approvalNeeded',
                            'workInProgress','reminder','bookingReceived','bookingAssigned',
                            'breakdownAssigned','workAssigned','jobAwaitingReview',
                            'completionApproved','completionRejected','estimateApproved',
                            'estimateRejected')
        DEFAULT 'carReady';
