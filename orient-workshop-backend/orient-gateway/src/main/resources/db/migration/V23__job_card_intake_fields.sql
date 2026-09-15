ALTER TABLE job_cards
    ADD COLUMN odometer INT NULL AFTER notes,
    ADD COLUMN fuel_level VARCHAR(20) DEFAULT '' AFTER odometer;
