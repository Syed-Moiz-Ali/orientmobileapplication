-- Persist an index of every uploaded media file so uploaded photos/videos/
-- signatures/documents can be listed and linked back to their record without
-- guessing the storage folder. The bytes stay on the media filesystem; this
-- table records where they are.
CREATE TABLE media_assets (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    ref          VARCHAR(50) NOT NULL UNIQUE,
    tenant       VARCHAR(100) NOT NULL,
    module       VARCHAR(50) NOT NULL,
    record_id    VARCHAR(50) NOT NULL,
    item_id      VARCHAR(100) DEFAULT '',
    media_type   VARCHAR(30) DEFAULT 'photo',
    url          VARCHAR(500) NOT NULL,
    file_name    VARCHAR(150) NOT NULL,
    content_type VARCHAR(100) DEFAULT '',
    size_bytes   BIGINT DEFAULT 0,
    created_by   BIGINT NULL,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_media_record (module, record_id),
    INDEX idx_media_created_by (created_by)
) ENGINE=InnoDB;
