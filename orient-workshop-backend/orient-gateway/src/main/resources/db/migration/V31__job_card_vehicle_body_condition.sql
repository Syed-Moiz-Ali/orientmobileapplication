ALTER TABLE job_cards
    ADD COLUMN vehicle_body_condition JSON NULL AFTER job_description_json;
