-- Job description is now a list of numbered rows, each with a priority.
-- Store the structured rows as JSON; customer_requests keeps a plain-text
-- composition for existing consumers / search.
ALTER TABLE job_cards
    ADD COLUMN job_description_json TEXT NULL AFTER customer_requests;
