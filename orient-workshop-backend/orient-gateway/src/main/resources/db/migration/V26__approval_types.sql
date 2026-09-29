ALTER TABLE approvals
    ADD COLUMN approval_type VARCHAR(30) NOT NULL DEFAULT 'estimate' AFTER estimate_id,
    ADD COLUMN target_id VARCHAR(50) NULL AFTER approval_type;

UPDATE approvals
SET target_id = estimate_id
WHERE target_id IS NULL;

ALTER TABLE approvals
    MODIFY target_id VARCHAR(50) NOT NULL,
    ADD UNIQUE KEY uk_approval_type_target (approval_type, target_id),
    ADD INDEX idx_customer_pending_type (customer_id, action, approval_type);
