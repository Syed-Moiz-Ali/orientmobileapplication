ALTER TABLE vehicles
    ADD COLUMN emirate VARCHAR(50) DEFAULT '' AFTER registration_number,
    ADD COLUMN plate_code VARCHAR(20) DEFAULT '' AFTER emirate,
    ADD COLUMN fuel_type VARCHAR(30) DEFAULT '' AFTER vehicle_color,
    ADD COLUMN lpo_number VARCHAR(50) DEFAULT '' AFTER policy_number,
    ADD COLUMN accident_number VARCHAR(50) DEFAULT '' AFTER lpo_number;

ALTER TABLE job_cards
    ADD COLUMN job_category VARCHAR(30) DEFAULT 'Regular' AFTER customer_requests,
    ADD COLUMN markup_type VARCHAR(50) DEFAULT '' AFTER job_category,
    ADD COLUMN order_type VARCHAR(50) DEFAULT '' AFTER markup_type;
