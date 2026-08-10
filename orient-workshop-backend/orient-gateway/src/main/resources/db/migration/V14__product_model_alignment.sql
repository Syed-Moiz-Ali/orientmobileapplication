-- ===================================================================
-- V14: PRODUCT-MODEL ALIGNMENT (owner decision 2026-08-07)
-- The product has NO "User" entity — it has customer, owner, staff
-- (advisor/supervisor/technician roles) and CRM. The accounts table is
-- internal auth, so its ref column is dropped.
-- Customers keep CUST- and the value is aligned with memberId's format:
-- CUST-000045 (zero-padded), so the customer id is identical everywhere.
-- Staff keep their emp_id (EADV.../ESUP.../ETCH...) as the public id.
-- ===================================================================

-- 1) Drop the account-table ref (users = internal auth store, not an entity)
ALTER TABLE users DROP KEY uk_users_ref;
ALTER TABLE users DROP COLUMN ref;

-- 2) Re-align customer refs with the memberId format (CUST-000045)
UPDATE customers SET ref = CONCAT('CUST-', LPAD(id, 6, '0')) WHERE ref IS NOT NULL;
