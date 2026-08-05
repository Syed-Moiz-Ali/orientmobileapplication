-- ===================================================================
-- V3: Tables that were added to docs/DATABASE_SCHEMA.sql AFTER existing
-- databases were created. Databases baselined at V1 (older schema) lack
-- them; fresh databases already have them, so everything is guarded with
-- IF NOT EXISTS / conditional inserts. Idempotent.
-- ===================================================================

-- ---------- BRANCHES ----------
CREATE TABLE IF NOT EXISTS branches (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    address     TEXT,
    phone       VARCHAR(20) DEFAULT '',
    email       VARCHAR(100) DEFAULT '',
    timezone    VARCHAR(50) DEFAULT 'Asia/Dubai',
    is_active   BOOLEAN DEFAULT TRUE,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Seed the default branch only when the table was just created (empty).
SET @branch_count := (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'branches');
INSERT INTO branches (name, address, phone, email)
SELECT 'Main Branch - Dubai', 'Sheikh Zayed Rd, Dubai', '+97141234567', 'main@orientworkshop.com'
WHERE (SELECT COUNT(*) FROM branches) = 0;

-- ---------- WHATSAPP MESSAGES ----------
CREATE TABLE IF NOT EXISTS whatsapp_messages (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    branch_id       BIGINT,
    customer_phone  VARCHAR(20) NOT NULL,
    template_name   VARCHAR(100) DEFAULT '',
    message_body    TEXT,
    status          ENUM('sent','delivered','read','failed') DEFAULT 'sent',
    message_type    ENUM('notification','booking_confirm','car_ready','invoice','promotion') DEFAULT 'notification',
    external_id     VARCHAR(100) DEFAULT '',
    sent_at         DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (branch_id) REFERENCES branches(id),
    INDEX idx_phone (customer_phone)
) ENGINE=InnoDB;
