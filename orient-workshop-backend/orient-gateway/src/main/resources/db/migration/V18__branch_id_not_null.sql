-- ===================================================================
-- V18: enforce branch_id NOT NULL on tenant-scoped tables.
-- Multi-tenant isolation requires every tenant row to belong to a branch.
-- Legacy NULL rows are backfilled to the seeded main branch (id = 1), which
-- is created in V1__baseline.sql. After backfill, the column is made NOT NULL
-- with a default of 1 so future inserts cannot silently create orphan rows.
-- ===================================================================

-- Backfill legacy NULLs to the main branch.
UPDATE users              SET branch_id = 1 WHERE branch_id IS NULL;
UPDATE staff              SET branch_id = 1 WHERE branch_id IS NULL;
UPDATE customers          SET branch_id = 1 WHERE branch_id IS NULL;
UPDATE vehicles           SET branch_id = 1 WHERE branch_id IS NULL;
UPDATE job_cards          SET branch_id = 1 WHERE branch_id IS NULL;
UPDATE bookings           SET branch_id = 1 WHERE branch_id IS NULL;
UPDATE invoices           SET branch_id = 1 WHERE branch_id IS NULL;
UPDATE notifications      SET branch_id = 1 WHERE branch_id IS NULL;
UPDATE work_assignments   SET branch_id = 1 WHERE branch_id IS NULL;

-- Enforce NOT NULL + default on each tenant-scoped table.
ALTER TABLE users             MODIFY COLUMN branch_id BIGINT NOT NULL DEFAULT 1;
ALTER TABLE staff             MODIFY COLUMN branch_id BIGINT NOT NULL DEFAULT 1;
ALTER TABLE customers         MODIFY COLUMN branch_id BIGINT NOT NULL DEFAULT 1;
ALTER TABLE vehicles          MODIFY COLUMN branch_id BIGINT NOT NULL DEFAULT 1;
ALTER TABLE job_cards         MODIFY COLUMN branch_id BIGINT NOT NULL DEFAULT 1;
ALTER TABLE bookings          MODIFY COLUMN branch_id BIGINT NOT NULL DEFAULT 1;
ALTER TABLE invoices          MODIFY COLUMN branch_id BIGINT NOT NULL DEFAULT 1;
ALTER TABLE notifications     MODIFY COLUMN branch_id BIGINT NOT NULL DEFAULT 1;
ALTER TABLE work_assignments  MODIFY COLUMN branch_id BIGINT NOT NULL DEFAULT 1;
