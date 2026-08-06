#!/bin/bash
# ===================================================================
# Orient Workshop — database + media backup (P3, audit item).
# Run daily via cron:
#   0 2 * * * /opt/orient/scripts/backup.sh >> /var/log/orient-backup.log 2>&1
# Restores: see docs/OPERATIONS.md.
# ===================================================================
set -euo pipefail

BACKUP_ROOT="${BACKUP_ROOT:-/opt/orient/backups}"
RETENTION_DAYS="${RETENTION_DAYS:-14}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-3306}"
DB_NAME="${DB_NAME:-orient_workshop}"
DB_USER="${DB_USERNAME:-orient}"
DB_PASSWORD="${DB_PASSWORD:-}"
MEDIA_DIR="${MEDIA_DIR:-/data/orient/media}"
TS=$(date +%Y%m%d-%H%M%S)

mkdir -p "$BACKUP_ROOT/db" "$BACKUP_ROOT/media"

echo "=== Backup started: $TS ==="

# 1. Database dump (single transaction = consistent snapshot)
if [ -n "$DB_PASSWORD" ]; then
  mysqldump -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" \
    --single-transaction --routines --triggers "$DB_NAME" \
    > "$BACKUP_ROOT/db/$DB_NAME-$TS.sql"
else
  mysqldump -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" \
    --single-transaction --routines --triggers "$DB_NAME" \
    > "$BACKUP_ROOT/db/$DB_NAME-$TS.sql"
fi
gzip "$BACKUP_ROOT/db/$DB_NAME-$TS.sql"
echo "DB dump: $BACKUP_ROOT/db/$DB_NAME-$TS.sql.gz"

# 2. Media files
tar -czf "$BACKUP_ROOT/media/media-$TS.tar.gz" -C "$(dirname "$MEDIA_DIR")" "$(basename "$MEDIA_DIR")" 2>/dev/null || echo "WARN: media dir missing, skipping"
echo "Media archive: $BACKUP_ROOT/media/media-$TS.tar.gz"

# 3. Retention: prune backups older than RETENTION_DAYS
find "$BACKUP_ROOT/db"    -name "*.sql.gz" -mtime +"$RETENTION_DAYS" -delete
find "$BACKUP_ROOT/media" -name "*.tar.gz" -mtime +"$RETENTION_DAYS" -delete
echo "Pruned backups older than ${RETENTION_DAYS} days."

echo "=== Backup complete: $TS ==="
