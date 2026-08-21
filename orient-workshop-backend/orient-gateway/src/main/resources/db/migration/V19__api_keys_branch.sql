-- ===================================================================
-- V19: add branch_id to api_keys for tenant-scoped server-to-server keys.
-- API keys inherit the branch of their creator (nullable = org-level / global
-- key, used only when created_by is an owner/admin).
-- ===================================================================

ALTER TABLE api_keys ADD COLUMN branch_id BIGINT DEFAULT NULL AFTER role,
    ADD INDEX idx_branch (branch_id);

UPDATE api_keys SET branch_id = 1 WHERE branch_id IS NULL;
