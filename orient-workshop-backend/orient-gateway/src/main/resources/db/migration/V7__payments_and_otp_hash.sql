-- ===================================================================
-- V7: P1 fixes (2026-08-06).
--   1. otp_records.otp_code widened to hold a SHA-256 hex digest
--      (OTPs are no longer stored in plaintext)
--   2. payments table (payment recording; AR outstanding = amount - paid)
--   3. whatsapp_messages index on external_id already exists (V6) — no-op
-- ===================================================================

-- ---------- 1. OTP HASH AT REST ----------
ALTER TABLE otp_records MODIFY COLUMN otp_code VARCHAR(64) NOT NULL;

-- ---------- 2. PAYMENTS ----------
CREATE TABLE IF NOT EXISTS payments (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    payment_ref   VARCHAR(50) NOT NULL UNIQUE,
    invoice_id    BIGINT NOT NULL,
    branch_id     BIGINT NULL,
    amount        DECIMAL(12,2) NOT NULL,
    method        VARCHAR(30) NOT NULL DEFAULT 'cash',
    reference     VARCHAR(100) DEFAULT '',
    paid_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    recorded_by   BIGINT NULL,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_payment_amount CHECK (amount > 0),
    CONSTRAINT fk_payments_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(id),
    CONSTRAINT fk_payments_branch FOREIGN KEY (branch_id) REFERENCES branches(id),
    INDEX idx_invoice (invoice_id),
    INDEX idx_branch (branch_id)
);
