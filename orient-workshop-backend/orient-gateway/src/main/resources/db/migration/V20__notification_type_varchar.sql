-- V20: Extend notifications.type column to VARCHAR(64) to support all notification events seamlessly
ALTER TABLE notifications MODIFY COLUMN type VARCHAR(64) DEFAULT 'carReady';
