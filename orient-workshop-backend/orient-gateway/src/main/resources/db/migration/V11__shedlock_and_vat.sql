-- ===================================================================
-- V11: P3 (2026-08-06).
--   1. shedlock — distributed scheduler lock table (multi-replica safe)
--   2. invoices: UAE VAT 5% (tax_rate + tax_amount)
-- ===================================================================

CREATE TABLE IF NOT EXISTS shedlock (
    name       VARCHAR(64)  NOT NULL,
    lock_until TIMESTAMP(3) NOT NULL,
    locked_at  TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    locked_by  VARCHAR(255) NOT NULL,
    PRIMARY KEY (name)
);

ALTER TABLE invoices
    ADD COLUMN tax_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00 AFTER amount,
    ADD COLUMN tax_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00 AFTER tax_rate,
    ADD COLUMN grand_total DECIMAL(12,2) NOT NULL DEFAULT 0.00 AFTER tax_amount;
