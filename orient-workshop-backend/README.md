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
