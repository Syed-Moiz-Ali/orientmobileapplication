# Orient Workshop — Operations Runbook

> P3 (audit): this runbook formalises backup, restore, rollback and health
> procedures that were previously undocumented. All commands assume the
> production layout: JAR at `/opt/orient-api/orient-gateway.jar`, env at
> `/etc/orient/orient-api.env`, systemd unit `orient-api`, DB `orient_workshop`.

## 1. Backup (automated)

`scripts/backup.sh` dumps the database (consistent snapshot) + media and
prunes after 14 days. Install as a cron job:

```bash
sudo cp scripts/backup.sh /opt/orient/scripts/backup.sh
sudo chmod +x /opt/orient/scripts/backup.sh
sudo crontab -e
# 0 2 * * * /opt/orient/scripts/backup.sh >> /var/log/orient-backup.log 2>&1
```

Config via env: `BACKUP_ROOT`, `RETENTION_DAYS`, `DB_*`, `MEDIA_DIR`.

**RPO/RTO:** backups are daily → worst-case 24h data loss. For a lower RPO
(< 15 min), enable MySQL binary logging and ship `binlog` files alongside the
dump (out of scope here — do before any paid multi-branch launch).

## 2. Restore

```bash
# Stop the app so no writes race the restore
sudo systemctl stop orient-api

# Restore the database (latest backup)
LATEST=$(ls -t /opt/orient/backups/db/*.sql.gz | head -1)
gunzip -c "$LATEST" | mysql -u"$DB_USERNAME" -p"$DB_PASSWORD" orient_workshop

# Restore media
LATEST_MEDIA=$(ls -t /opt/orient/backups/media/*.tar.gz | head -1)
tar -xzf "$LATEST_MEDIA" -C /

# Start and verify
sudo systemctl start orient-api
curl -fsS http://localhost:8080/api/v1/health   # expect 200
```

> Flyway note: restoring an older dump may roll the schema back; on next boot
> Flyway will re-apply later migrations, which is **not** a full rollback of
> schema changes. For true rollback of a bad release, prefer §3.

## 3. Release rollback

A bad deploy (crash loop, data corruption) is rolled back by keeping the
previous JAR:

```bash
sudo systemctl stop orient-api
sudo cp /opt/orient-api/orient-gateway.jar.prev /opt/orient-api/orient-gateway.jar 2>/dev/null \
  || echo "no .prev found — restore from backup"
sudo systemctl start orient-api
curl -fsS http://localhost:8080/api/v1/health
```

The deploy script should keep the previous JAR. Until then:

```bash
# before deploying a new JAR:
cp /opt/orient-api/orient-gateway.jar /opt/orient-api/orient-gateway.jar.prev
```

## 4. Health checks & monitoring

- **Liveness:** `GET /api/v1/health` → 200 (static).
- **Readiness (DB/Redis):** `GET /api/v1/actuator/health` → 200 UP / 503 DOWN.
- **Wire into Uptime Kuma / Prometheus Blackbox:** probe both endpoints every
  30 s.
- **Logs:** `journalctl -u orient-api -f` (systemd) — aggregate with Loki or
  CloudWatch when multi-branch.
- **Alerts:** DB disk > 80%, `systemctl is-active orient-api` failed, HTTP 5xx
  rate > 1% — all require an external monitor (Kuma/Alertmanager).

## 5. Security checklist (ops)

- Secrets live ONLY in `/etc/orient/orient-api.env` (chmod 600, root-owned).
- The app boots with `--spring.profiles.active=prod` (no dev default since
  the audit fix) — verify: `systemctl show orient-api | grep ExecStart`.
- If `app.otp.fixed-value` is set anywhere outside dev, the OTP falls back to
  SecureRandom and logs a warning — check startup logs for it.
- Rotate `JWT_SECRET` + `ENCRYPTION_KEY` immediately if the repo was ever
  cloned by an untrusted party (they were committed historically).

## 6. Data hygiene

- `sync_logs` retains raw sync payloads indefinitely — add a retention job
  (e.g. monthly `DELETE FROM sync_logs WHERE created_at < NOW() - INTERVAL 90 DAY`)
  to bound PII.
- `otp_records` are auto-cleaned by the scheduler (`OtpCleanupJob`).
