-- V21: Extend vehicles.plate_number to VARCHAR(32) to support custom and international formats
ALTER TABLE vehicles MODIFY COLUMN plate_number VARCHAR(32) DEFAULT '';
