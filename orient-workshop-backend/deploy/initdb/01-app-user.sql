-- App DB user for the Orient Workshop API.
-- Mounted into the MySQL container at /docker-entrypoint-initdb.d/ and executed
-- once on first container start (after 01-schema.sql from docs/DATABASE_SCHEMA.sql).
-- NOTE: the official mysql image runs init scripts as root and does NOT
-- substitute ${...} env placeholders; to use a different password, change the
-- value below and set DB_USERNAME=orient_app / DB_PASSWORD accordingly in
-- docker-compose.yml.
CREATE USER IF NOT EXISTS 'orient_app'@'%' IDENTIFIED BY 'orient_app_dev';
GRANT ALL PRIVILEGES ON orient_workshop.* TO 'orient_app'@'%';
FLUSH PRIVILEGES;
