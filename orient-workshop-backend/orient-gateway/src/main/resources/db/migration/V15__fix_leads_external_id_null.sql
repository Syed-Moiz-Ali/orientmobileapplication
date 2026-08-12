-- FIX (audit QA BUG-018): leads created without an external_id collided on the
-- unique index uk_leads_external. The column defaulted to '' (empty string),
-- and MySQL treats '' as a duplicate while NULL is exempt from uniqueness.
-- Make the column nullable with no default: manual/walk-in leads insert NULL and
-- no longer fail; Meta-synced leads still carry a real external_id (dedup joins
-- already filter external_id <> '').
ALTER TABLE leads
    MODIFY COLUMN external_id VARCHAR(100) NULL DEFAULT NULL;
