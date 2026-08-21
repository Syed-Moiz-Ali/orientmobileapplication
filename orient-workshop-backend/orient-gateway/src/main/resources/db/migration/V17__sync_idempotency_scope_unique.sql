-- P0-01: non-empty sync log idempotency keys are scoped SHA-256 hashes
-- (user + branch + method + endpoint + key). Multiple empty keys are allowed
-- for non-idempotent requests; non-empty keys must be unique to prevent a
-- concurrent retry from creating duplicate business mutations.
SET @col := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sync_logs' AND COLUMN_NAME = 'idempotency_key_unique');
SET @ddl := IF(@col = 0,
    'ALTER TABLE sync_logs ADD COLUMN idempotency_key_unique VARCHAR(100) GENERATED ALWAYS AS (NULLIF(idempotency_key, '''')) STORED',
    'SELECT 1');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @idx := (SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sync_logs' AND INDEX_NAME = 'uk_sync_logs_idempotency_key_unique');
SET @ddl := IF(@idx = 0,
    'ALTER TABLE sync_logs ADD UNIQUE KEY uk_sync_logs_idempotency_key_unique (idempotency_key_unique)',
    'SELECT 1');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
