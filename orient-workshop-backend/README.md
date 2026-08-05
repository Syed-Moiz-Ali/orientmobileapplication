# Orient Workshop Backend

## Tech Stack
- Java 17, Spring Boot 3.4, Maven
- MySQL 8.0, Redis 7
- MyBatis-Plus, JWT, Spring Security

## Quick Start (Development)

**Prerequisites:**
- Java 17+ (JAVA_HOME set)
- MySQL 8.0 running on localhost:3306 with root/root

**Step 1: Create and seed database**
```sql
CREATE DATABASE orient_workshop;
SOURCE docs/DATABASE_SCHEMA.sql;
```

Schema is managed by **Flyway** on application startup (`mysql` / `prod` profiles):
- `orient-gateway/src/main/resources/db/migration/V1__baseline.sql` — exact copy of `docs/DATABASE_SCHEMA.sql`.
- `V2__sync_and_crm_fixes.sql` — deltas (lead_activities, crm_integrations.credentials/last_sync_at/sync_status, leads.external_id/notes/lead_value/follow_up_date + `NO_RESPONSE` status, sync_logs entity columns).
- Existing databases are baselined at V1 automatically (`baseline-on-migrate=true`, `baseline-version=1`); new databases run V1 then V2.
- Docker Compose still mounts `docs/DATABASE_SCHEMA.sql` as the init script; `deploy/initdb/01-app-user.sql` creates the `orient_app` MySQL user.

**Step 2: Start the app**
```powershell
.\mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=dev
```

Or build and run:
```powershell
.\mvnw.cmd package -pl orient-gateway -am -DskipTests
java -jar orient-gateway/target/orient-gateway-*.jar --spring.profiles.active=dev
```

**Step 3: Test**
```
GET http://localhost:8080/api/v1/health
POST http://localhost:8080/api/v1/auth/send-otp
{"type": "sms", "phone": "971501234567"}
```

OTP is hardcoded to `123456` in dev mode.

## WhatsApp (Meta Cloud API)

Configured via environment variables (all optional; when `WHATSAPP_ACCESS_TOKEN` is unset the service falls back to log-only mode):
- `WHATSAPP_ACCESS_TOKEN` — Meta Graph API token (Bearer)
- `WHATSAPP_PHONE_NUMBER_ID` — sender phone number ID
- `WHATSAPP_API_BASE` — default `https://graph.facebook.com/v20.0`
- `WHATSAPP_VERIFY_TOKEN` — webhook verification token (`GET /whatsapp/webhook?hub.mode=subscribe&hub.verify_token=...&hub.challenge=...`)
- `WHATSAPP_APP_SECRET` — used to verify `X-Hub-Signature-256` on `POST /whatsapp/webhook` (HMAC-SHA256 of the raw body)

## Sync endpoints (offline → online persistence)

All write to `sync_logs` and honor the `Idempotency-Key` header; responses are `{id, synced, recorded}`:
- `POST /sync/inspections/{id}` — stores payload; upserts an `inspections` row when the body contains `jobCardId`
- `POST /sync/jobs/complete/{id}` — stores payload; marks the job card `completed`
- `POST /sync/repair-orders/{id}` — stores payload
- `POST /sync/bookings` — stores payload
- `POST /sync/work-assignments` — stores payload

## Docker Deployment
```bash
docker-compose up -d
```

## On-Premise Deployment
```bash
sudo ./deploy/deploy.sh
```

## API Docs
Swagger UI: http://localhost:8080/api/v1/swagger-ui.html
Postman: docs/OrientWorkshop.postman_collection.json

## Project Structure
```
orient-core/          -- Shared entities + mappers (Customer, Vehicle, JobCard, etc.)
orient-common/        -- Utility classes, exceptions, ApiResponse
orient-auth/          -- OTP + Password auth, JWT, Spring Security
orient-customer/      -- Customer portal APIs
orient-advisor/       -- Advisor staff APIs
orient-supervisor/    -- Supervisor dashboard APIs
orient-technician/    -- Technician mobile APIs
orient-owner/         -- Owner dashboard APIs
orient-crm/           -- CRM dashboard APIs
orient-media/         -- File upload/download
orient-sync/          -- Offline sync with idempotency
orient-scheduler/     -- Scheduled cleanup jobs
orient-gateway/       -- Main Spring Boot application
```
