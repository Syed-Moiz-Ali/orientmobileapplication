-- ===================================================================
-- V8: normalize legacy branch_id = 0 (phantom tenant) to NULL.
-- The old JWT branchId claim encoded null as 0, so rows created while
-- that bug shipped carry branch_id = 0 which matches no branch row and
-- breaks new FKs (e.g. payments.fk_payments_branch).
-- ===================================================================

UPDATE invoices       SET branch_id = NULL WHERE branch_id = 0;
UPDATE bookings       SET branch_id = NULL WHERE branch_id = 0;
UPDATE job_cards      SET branch_id = NULL WHERE branch_id = 0;
UPDATE vehicles       SET branch_id = NULL WHERE branch_id = 0;
UPDATE notifications  SET branch_id = NULL WHERE branch_id = 0;
UPDATE work_assignments SET branch_id = NULL WHERE branch_id = 0;
UPDATE customers      SET branch_id = NULL WHERE branch_id = 0;
UPDATE users          SET branch_id = NULL WHERE branch_id = 0;
UPDATE staff          SET branch_id = NULL WHERE branch_id = 0;
