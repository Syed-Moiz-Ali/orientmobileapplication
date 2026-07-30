# Orient Mobile Application — Java Spring Boot Backend Plan

## Overview

Build a **scalable, maintainable Java Spring Boot backend** for the Orient workshop management system. The Flutter frontend (4 apps across 6 roles) communicates via a RESTful JSON API (90 endpoints). This plan covers every layer: project structure, database schema, auth, API modules, service design, caching, offline sync, media handling, and deployment.

---

## 1. Technology Stack

| Component | Choice | Rationale |
|---|---|---|
| **Language** | Java 21 (LTS) | Latest LTS with records, sealed classes, virtual threads |
| **Framework** | Spring Boot 3.4.x | Industry standard, mature ecosystem |
| **Build Tool** | Maven | Wide plugin ecosystem, stable |
| **Database** | MySQL 8.0+ | Relational, strong Spring Boot/MyBatis support |
| **ORM** | MyBatis-Plus | Flexible SQL control, great for reporting queries |
| **Auth** | Spring Security 6 + JWT (jjwt) | RBAC across 6 roles, stateless API |
| **API Docs** | SpringDoc OpenAPI 3 (Swagger) | Auto-generated docs from annotations |
| **Validation** | Jakarta Bean Validation | `@Valid`, custom validators |
| **Caching** | Redis (via Spring Cache) | Session store, frequently accessed data |
| **File Storage** | Local filesystem (`/data/media/`) | On-premise deployment; NFS mount for HA |
| **Task Scheduling** | Spring `@Scheduled` + Quartz | OTP expiry, reminders, cleanup jobs |
| **Testing** | JUnit 5 + Mockito + TestContainers | Unit, integration, DB testing |
| **Logging** | Logback + SLF4J | Structured JSON logs for ELK |
| **API Base Path** | `/api/v1` | Configurable via `server.servlet.context-path` |
| **Deployment** | JAR + systemd service | On-premise; simple, reliable |

---

## 2. Project Structure (Maven Multi-Module)

```
orient-workshop-backend/
├── pom.xml                          # Parent POM (multi-module)
├── .gitignore
├── README.md
│
├── orient-common/                   # Shared utilities (pom)
│   ├── pom.xml
│   └── src/main/java/com/orient/workshop/common/
│       ├── exception/               # GlobalExceptionHandler, AppException, ErrorCode
│       ├── response/                # ApiResponse<T>, PageResponse<T>
│       ├── util/                    # StringUtil, DateUtil, PhoneUtil
│       ├── constant/                # ApiConstants, RoleConstants
│       └── config/                  # JacksonConfig, CorsConfig
│
├── orient-auth/                     # Authentication & Authorization (jar)
│   ├── pom.xml
│   └── src/main/java/com/orient/workshop/auth/
│       ├── config/                  # SecurityConfig, JwtConfig
│       ├── controller/              # AuthController
│       ├── service/                 # AuthService, OtpService, JwtService
│       ├── model/                   # OtpRecord (Redis), LoginRequest, TokenResponse
│       ├── filter/                  # JwtAuthenticationFilter, RoleFilter
│       └── util/                    # JwtUtil
│
├── orient-customer/                 # Customer Portal APIs (jar)
│   ├── pom.xml
│   └── src/main/java/com/orient/workshop/customer/
│       ├── controller/              # CustomerController, VehicleController, BookingController...
│       ├── service/                 # CustomerService, VehicleService, BookingService...
│       ├── repository/              # CustomerRepository (MyBatis Mapper)
│       ├── model/                   # Customer, Vehicle, Booking, Breakdown, Notification
│       ├── dto/                     # *Request, *Response DTOs
│       └── mapper/                  # CustomerMapper, VehicleMapper (XML or annotation)
│
├── orient-advisor/                  # Advisor Staff APIs (jar)
│   ├── pom.xml
│   └── src/main/java/com/orient/workshop/advisor/
│       ├── controller/              # JobCardController, InspectionController, ApprovalController...
│       ├── service/                 # JobCardService, InspectionService, ApprovalService...
│       ├── repository/              # JobCardMapper, InspectionMapper...
│       ├── model/                   # JobCard, Inspection, RepairOrder, Reminder, Approval...
│       └── dto/                     # *Request, *Response DTOs
│
├── orient-supervisor/               # Supervisor Staff APIs (jar)
│   ├── pom.xml
│   └── src/main/java/com/orient/workshop/supervisor/
│       ├── controller/              # KpiController, WorkAssignmentController...
│       ├── service/                 # KpiService, WorkAssignmentService...
│       ├── repository/              # WorkAssignmentMapper...
│       ├── model/                   # WorkAssignment, Department, Technician...
│       └── dto/
│
├── orient-technician/               # Technician Staff APIs (jar)
│   ├── pom.xml
│   └── src/main/java/com/orient/workshop/technician/
│       ├── controller/              # ProfileController, AttendanceController, JobController...
│       ├── service/                 # AttendanceService, JobService, ProductivityService...
│       ├── repository/              # AttendanceMapper, TaskMapper...
│       ├── model/                   # Attendance, WorkTask, TechnicianJob...
│       └── dto/
│
├── orient-owner/                    # Owner Dashboard APIs (jar)
│   ├── pom.xml
│   └── src/main/java/com/orient/workshop/owner/
│       ├── controller/              # DashboardController, InvoiceController, ArController...
│       ├── service/                 # DashboardService, SalesTrendService, InvoiceService...
│       ├── repository/              # DashboardMapper (complex aggregation queries)
│       ├── model/                   # KpiCard, SalesTrend, DocumentExpiry, Invoice, Message...
│       └── dto/
│
├── orient-crm/                      # CRM Dashboard APIs (jar)
│   ├── pom.xml
│   └── src/main/java/com/orient/workshop/crm/
│       ├── controller/              # CrmDashboardController, LeadController, TaskController...
│       ├── service/                 # CrmService, LeadService, IntegrationService...
│       ├── repository/              # LeadMapper, ConversationMapper...
│       ├── model/                   # Lead, Conversation, CrmTask, Integration, CrmKpi...
│       └── dto/
│
├── orient-media/                    # Media Upload/Download (jar)
│   ├── pom.xml
│   └── src/main/java/com/orient/workshop/media/
│       ├── controller/              # MediaController
│       ├── service/                 # MediaService, FileStorageService
│       ├── config/                  # FileStorageConfig
│       └── model/                   # MediaFile
│
├── orient-sync/                     # Offline Sync & Idempotency (jar)
│   ├── pom.xml
│   └── src/main/java/com/orient/workshop/sync/
│       ├── controller/              # SyncController (idempotent POST handlers)
│       ├── service/                 # SyncService, IdempotencyService
│       ├── repository/              # SyncLogMapper, IdempotencyKeyMapper
│       ├── model/                   # SyncLog, IdempotencyRecord
│       └── filter/                  # IdempotencyFilter
│
├── orient-scheduler/                # Scheduled/Batch Jobs (jar)
│   ├── pom.xml
│   └── src/main/java/com/orient/workshop/scheduler/
│       ├── job/                     # OtpCleanupJob, ReminderJob, InvoiceOverdueJob
│       └── config/                  # SchedulerConfig
│
├── orient-gateway/                  # API Gateway (Spring Boot app)
│   ├── pom.xml
│   ├── src/main/java/com/orient/workshop/gateway/
│   │   ├── OrientGatewayApplication.java
│   │   ├── config/                  # RouteConfig, RateLimitConfig, SwaggerConfig
│   │   ├── filter/                  # RequestLoggingFilter, RateLimitFilter
│   │   └── util/                    # RequestContext
│   └── src/main/resources/
│       ├── application.yml
│       ├── application-dev.yml
│       └── application-prod.yml
│
└── docs/
    ├── DATABASE_SCHEMA.md
    ├── API_REFERENCE.md
    └── DEPLOYMENT.md
```

### Module Dependency Flow

```
orient-gateway (Spring Boot main app)
  ├── orient-common (shared utilities)
  ├── orient-auth (JWT filter, security)
  ├── orient-customer
  ├── orient-advisor
  ├── orient-supervisor
  ├── orient-technician
  ├── orient-owner
  ├── orient-crm
  ├── orient-media
  ├── orient-sync
  └── orient-scheduler
```

---

## 3. Database Schema (MySQL)

### 3.1 Core Tables

```sql
-- =========== AUTH & USERS ===========

CREATE TABLE users (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    phone         VARCHAR(20) NOT NULL UNIQUE,
    name          VARCHAR(100),
    email         VARCHAR(100),
    role          ENUM('owner','advisor','technician','customer','supervisor','crmDashboard') NOT NULL,
    is_active     BOOLEAN DEFAULT TRUE,
    avatar_url    VARCHAR(500),
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_phone (phone),
    INDEX idx_role (role)
);

CREATE TABLE otp_records (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    phone         VARCHAR(20) NOT NULL,
    otp_code      VARCHAR(6) NOT NULL,
    attempts      INT DEFAULT 0,
    expires_at    DATETIME NOT NULL,
    used          BOOLEAN DEFAULT FALSE,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_phone_otp (phone, otp_code)
);

CREATE TABLE refresh_tokens (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id       BIGINT NOT NULL,
    token         VARCHAR(500) NOT NULL UNIQUE,
    expires_at    DATETIME NOT NULL,
    revoked       BOOLEAN DEFAULT FALSE,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_token (token)
);

-- =========== CUSTOMERS ===========

CREATE TABLE customers (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id         BIGINT,
    is_b2b          BOOLEAN DEFAULT FALSE,
    customer_name   VARCHAR(100),
    phone_number    VARCHAR(20),
    email           VARCHAR(100),
    customer_group  VARCHAR(50),
    tags            JSON,
    gender          VARCHAR(10),
    address         TEXT,
    tax_number      VARCHAR(50),
    group_tax_number VARCHAR(50),
    occupation      VARCHAR(100),
    organisation    VARCHAR(100),
    source          VARCHAR(50),
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_phone (phone_number),
    INDEX idx_name (customer_name)
);

-- =========== VEHICLES ===========

CREATE TABLE vehicles (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id         BIGINT NOT NULL,
    registration_number VARCHAR(50),
    vin                 VARCHAR(50),
    make                VARCHAR(50),
    model               VARCHAR(50),
    model_year          INT,
    purchase_date       DATE,
    cylinders           INT,
    engine_capacity     VARCHAR(20),
    vehicle_color       VARCHAR(30),
    engine_number       VARCHAR(50),
    insurance_provider  VARCHAR(100),
    insurance_tax_number VARCHAR(50),
    insurance_address   TEXT,
    policy_number       VARCHAR(50),
    insurance_expiry_date DATE,
    plate_number        VARCHAR(20),
    mileage             VARCHAR(20),
    last_service        VARCHAR(20),
    next_due            VARCHAR(20),
    health_score        INT DEFAULT 100,
    INDEX idx_customer (customer_id),
    INDEX idx_plate (plate_number),
    INDEX idx_vin (vin),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- =========== SERVICE TYPES ===========

CREATE TABLE service_types (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    price       VARCHAR(50),
    duration    VARCHAR(20),
    is_active   BOOLEAN DEFAULT TRUE,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =========== BOOKINGS ===========

CREATE TABLE bookings (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_ref   VARCHAR(50) NOT NULL UNIQUE,
    customer_id   BIGINT NOT NULL,
    vehicle_id    BIGINT NOT NULL,
    vehicle_name  VARCHAR(100),
    plate_number  VARCHAR(20),
    service_type  VARCHAR(100),
    booking_date  DATETIME NOT NULL,
    notes         TEXT,
    status        ENUM('confirmed','completed','pending','cancelled') DEFAULT 'pending',
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
    INDEX idx_customer (customer_id),
    INDEX idx_status (status),
    INDEX idx_date (booking_date)
);

-- =========== BREAKDOWNS ===========

CREATE TABLE breakdowns (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    breakdown_ref VARCHAR(50) NOT NULL UNIQUE,
    customer_id   BIGINT NOT NULL,
    issue         TEXT NOT NULL,
    vehicle_id    BIGINT,
    vehicle_name  VARCHAR(100),
    vehicle_plate VARCHAR(20),
    location      TEXT,
    status        ENUM('pending','dispatched','resolved','cancelled') DEFAULT 'pending',
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    INDEX idx_customer (customer_id)
);

-- =========== NOTIFICATIONS ===========

CREATE TABLE notifications (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id       BIGINT NOT NULL,
    title         VARCHAR(200) NOT NULL,
    body          TEXT,
    type          ENUM('carReady','bookingConfirmed','invoiceReady','approvalNeeded','workInProgress','reminder'),
    is_read       BOOLEAN DEFAULT FALSE,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_user_read (user_id, is_read)
);

-- =========== JOB CARDS ===========

CREATE TABLE job_cards (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    job_card_ref    VARCHAR(50) NOT NULL UNIQUE,
    customer_id     BIGINT NOT NULL,
    vehicle_id      BIGINT,
    status          ENUM('inProgress','pendingApproval','qualityCheck','completed','cancelled','waitingParts','pending') DEFAULT 'pending',
    technician      VARCHAR(100),
    created_date    DATETIME,
    last_updated    DATETIME,
    notes           TEXT,
    tag             VARCHAR(50),
    customer_requests TEXT,
    garage_recommendations TEXT,
    estimated_delivery DATETIME,
    notify_owner_sms_email BOOLEAN DEFAULT FALSE,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
    INDEX idx_status (status),
    INDEX idx_customer (customer_id),
    INDEX idx_ref (job_card_ref),
    INDEX idx_technician (technician)
);

-- =========== INSPECTIONS ===========

CREATE TABLE inspections (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    inspection_ref  VARCHAR(50) NOT NULL UNIQUE,
    job_card_id     BIGINT,
    reference_number VARCHAR(50),
    place_of_supply VARCHAR(100),
    customer_requests TEXT,
    garage_recommendations TEXT,
    estimated_delivery DATETIME,
    notify_owner_sms_email BOOLEAN DEFAULT FALSE,
    tag             VARCHAR(50),
    is_draft        BOOLEAN DEFAULT FALSE,
    sections        JSON,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (job_card_id) REFERENCES job_cards(id),
    INDEX idx_job_card (job_card_id)
);

-- =========== REPAIR ORDERS ===========

CREATE TABLE repair_orders (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    repair_order_ref VARCHAR(50) NOT NULL UNIQUE,
    job_card_id     BIGINT NOT NULL,
    services_total  DECIMAL(12,2) DEFAULT 0,
    parts_total     DECIMAL(12,2) DEFAULT 0,
    grand_total     DECIMAL(12,2) DEFAULT 0,
    tag             VARCHAR(50),
    customer_requests TEXT,
    garage_recommendations TEXT,
    estimated_delivery DATETIME,
    notify_owner_sms_email BOOLEAN DEFAULT FALSE,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (job_card_id) REFERENCES job_cards(id),
    INDEX idx_job_card (job_card_id)
);

CREATE TABLE repair_order_services (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    repair_order_id BIGINT NOT NULL,
    name            VARCHAR(100) NOT NULL,
    qty             INT DEFAULT 1,
    rate            DECIMAL(12,2) DEFAULT 0,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    discount_amount DECIMAL(12,2) DEFAULT 0,
    FOREIGN KEY (repair_order_id) REFERENCES repair_orders(id)
);

CREATE TABLE repair_order_parts (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    repair_order_id BIGINT NOT NULL,
    name            VARCHAR(100) NOT NULL,
    qty             INT DEFAULT 1,
    rate            DECIMAL(12,2) DEFAULT 0,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    discount_amount DECIMAL(12,2) DEFAULT 0,
    FOREIGN KEY (repair_order_id) REFERENCES repair_orders(id)
);

-- =========== PREDEFINED SERVICES & PARTS ===========

CREATE TABLE predefined_services (
    id    BIGINT AUTO_INCREMENT PRIMARY KEY,
    name  VARCHAR(100) NOT NULL UNIQUE
);

-- Seed: A/C Overhauling, Air Filter, Battery, Brake, Clutch, Cooling System,
-- Engine Oil, Fuel Filter, Power Steering, Radiator, Spark Plug, Timing Belt,
-- Wheel Alignment, Wheel Balancing, Wind Screen, AC Service, Brake Pads,
-- Brake Discs, Suspension System, Transmission Fluid

CREATE TABLE predefined_parts (
    id    BIGINT AUTO_INCREMENT PRIMARY KEY,
    name  VARCHAR(100) NOT NULL UNIQUE
);

-- Seed: A/C heater core, Alloy wheel, Alternator, Brake booster, Clutch cable,
-- Engine air filter, Fuel filter, Oil filter, Spark plug, Wiper blade,
-- Brake pad set, Radiator cap, Drive belt, Battery, Coolant

-- =========== APPROVALS ===========

CREATE TABLE approvals (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    estimate_id     VARCHAR(50) NOT NULL,
    customer_id     BIGINT NOT NULL,
    customer_name   VARCHAR(100),
    vehicle_id      VARCHAR(50),
    amount          DECIMAL(12,2) DEFAULT 0,
    action          ENUM('pending','approved','rejected') DEFAULT 'pending',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    INDEX idx_estimate (estimate_id),
    INDEX idx_action (action)
);

-- =========== REMINDERS ===========

CREATE TABLE reminders (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    reminder_ref    VARCHAR(50) NOT NULL UNIQUE,
    customer_name   VARCHAR(100),
    vehicle_id      VARCHAR(50),
    task            TEXT NOT NULL,
    due_date        VARCHAR(100),
    priority        ENUM('high','medium','low') DEFAULT 'medium',
    is_completed    BOOLEAN DEFAULT FALSE,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =========== STAFF ===========

CREATE TABLE staff (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id         BIGINT,
    emp_id          VARCHAR(20) NOT NULL UNIQUE,
    name            VARCHAR(100) NOT NULL,
    role            ENUM('advisor','technician','supervisor') NOT NULL,
    branch          VARCHAR(100),
    shift           VARCHAR(100),
    designation     VARCHAR(100),
    department      VARCHAR(100),
    avatar_initials VARCHAR(5),
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_emp_id (emp_id),
    INDEX idx_role (role)
);

-- =========== ATTENDANCE ===========

CREATE TABLE attendance (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    emp_id          VARCHAR(20) NOT NULL,
    date            DATE NOT NULL,
    status          ENUM('notPunchedIn','working','onBreak','punchedOut') DEFAULT 'notPunchedIn',
    punch_in        VARCHAR(20),
    punch_out       VARCHAR(20),
    break_time      VARCHAR(20),
    work_hours      VARCHAR(20),
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_emp_date (emp_id, date),
    FOREIGN KEY (emp_id) REFERENCES staff(emp_id),
    INDEX idx_emp_date (emp_id, date)
);

-- =========== TECHNICIAN TASKS ===========

CREATE TABLE technician_tasks (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    job_card_no     VARCHAR(50) NOT NULL,
    task_ref        VARCHAR(20) NOT NULL,
    description     TEXT NOT NULL,
    status          ENUM('pending','inProgress','completed') DEFAULT 'pending',
    emp_id          VARCHAR(20),
    start_time      VARCHAR(20),
    end_time        VARCHAR(20),
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (job_card_no) REFERENCES job_cards(job_card_ref),
    FOREIGN KEY (emp_id) REFERENCES staff(emp_id),
    INDEX idx_job_card (job_card_no),
    INDEX idx_emp (emp_id)
);

-- =========== WORK ASSIGNMENTS ===========

CREATE TABLE work_assignments (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    assignment_ref  VARCHAR(50) NOT NULL UNIQUE,
    job_card_id     BIGINT NOT NULL,
    description     TEXT NOT NULL,
    department      VARCHAR(100),
    technician_name VARCHAR(100),
    date_of_work    DATE,
    status_percent  INT DEFAULT 0,
    std_time        VARCHAR(20),
    remarks         TEXT,
    status          ENUM('Pending','In Progress','Completed') DEFAULT 'Pending',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (job_card_id) REFERENCES job_cards(id),
    INDEX idx_job_card (job_card_id),
    INDEX idx_technician (technician_name)
);

-- =========== DEPARTMENTS ===========

CREATE TABLE departments (
    id      BIGINT AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(100) NOT NULL UNIQUE
);

-- Seed: Engine, Body & Paint, Electrical, Tyres & Alignment, AC & Cooling,
-- Transmission, General Service

-- =========== INVOICES ===========

CREATE TABLE invoices (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    invoice_ref     VARCHAR(50) NOT NULL UNIQUE,
    customer_id     BIGINT NOT NULL,
    job_card_id     BIGINT,
    amount          DECIMAL(12,2) DEFAULT 0,
    status          ENUM('paid','unpaid','overdue') DEFAULT 'unpaid',
    due_date        DATE,
    issued_date     DATE,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    INDEX idx_status (status),
    INDEX idx_customer (customer_id)
);

-- =========== ACCOUNTS RECEIVABLE ===========

CREATE TABLE accounts_receivable (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    ar_ref          VARCHAR(50) NOT NULL UNIQUE,
    customer_id     BIGINT NOT NULL,
    invoice_id      BIGINT,
    invoice_date    DATE,
    due_date        DATE,
    amount          DECIMAL(12,2) DEFAULT 0,
    outstanding     DECIMAL(12,2) DEFAULT 0,
    aging           ENUM('days0to30','days31to60','days61to90','days90plus') DEFAULT 'days0to30',
    contact_person  VARCHAR(100),
    phone           VARCHAR(20),
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    INDEX idx_customer (customer_id),
    INDEX idx_aging (aging)
);

-- =========== MESSAGES ===========

CREATE TABLE messages (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    sender_id       BIGINT,
    recipient       VARCHAR(100) NOT NULL,
    recipient_id    BIGINT,
    message         TEXT NOT NULL,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id)
);

-- =========== ACTIVITY LOG ===========

CREATE TABLE activity_log (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    type            ENUM('job_card','inspection','approval','invoice','parts','payment','technician') NOT NULL,
    title           VARCHAR(200) NOT NULL,
    description     TEXT,
    user_id         BIGINT,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_type (type),
    INDEX idx_created (created_at),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- =========== CRM TABLES ===========

CREATE TABLE leads (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    lead_number     VARCHAR(50) NOT NULL UNIQUE,
    customer_name   VARCHAR(100) NOT NULL,
    phone           VARCHAR(20),
    email           VARCHAR(100),
    source          VARCHAR(50),
    assigned_to     VARCHAR(100),
    status          ENUM('ACTIVE','WON','UNANSWERED','LOST') DEFAULT 'ACTIVE',
    last_activity   VARCHAR(100),
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_status (status),
    INDEX idx_source (source),
    INDEX idx_assigned (assigned_to)
);

CREATE TABLE crm_conversations (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_name   VARCHAR(100),
    last_message    TEXT,
    time            VARCHAR(50),
    channel         VARCHAR(50),
    unread          INT DEFAULT 0,
    status          VARCHAR(20) DEFAULT 'active',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE crm_tasks (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    title           VARCHAR(200) NOT NULL,
    assigned_to     VARCHAR(100),
    due_date        VARCHAR(50),
    priority        ENUM('High','Medium','Low') DEFAULT 'Medium',
    is_done         BOOLEAN DEFAULT FALSE,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE crm_integrations (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL UNIQUE,
    connected       BOOLEAN DEFAULT FALSE
);

-- =========== SYNC & IDEMPOTENCY ===========

CREATE TABLE idempotency_keys (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    idempotency_key VARCHAR(100) NOT NULL UNIQUE,
    response_body   JSON,
    http_status     INT DEFAULT 200,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_key (idempotency_key)
);

CREATE TABLE sync_logs (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    idempotency_key VARCHAR(100),
    endpoint        VARCHAR(200) NOT NULL,
    method          VARCHAR(10) NOT NULL,
    request_body    JSON,
    status          ENUM('success','conflict','error') DEFAULT 'success',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_key (idempotency_key),
    INDEX idx_created (created_at)
);

-- =========== EMPLOYEE DOCUMENTS (Owner Dashboard) ===========

CREATE TABLE employee_documents (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    emp_id          VARCHAR(20) NOT NULL,
    employee_name   VARCHAR(100),
    designation     VARCHAR(100),
    document_type   VARCHAR(100) NOT NULL,
    expiry_date     DATE NOT NULL,
    days_left       INT GENERATED ALWAYS AS (DATEDIFF(expiry_date, CURDATE())) STORED,
    urgency         VARCHAR(20) GENERATED ALWAYS AS (
                        CASE
                            WHEN DATEDIFF(expiry_date, CURDATE()) <= 30 THEN 'critical'
                            WHEN DATEDIFF(expiry_date, CURDATE()) <= 60 THEN 'urgent'
                            WHEN DATEDIFF(expiry_date, CURDATE()) <= 90 THEN 'warning'
                            ELSE 'normal'
                        END
                    ) STORED,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (emp_id) REFERENCES staff(emp_id),
    INDEX idx_emp (emp_id),
    INDEX idx_expiry (expiry_date)
);
```

### 3.2 Entity Relationship Summary

```
users ──┬─ customers (1:1 via user_id)
         ├─ staff (1:1 via user_id)
         ├─ notifications
         ├─ messages (sender)
         └─ refresh_tokens

customers ──┬─ vehicles
             ├─ bookings
             ├─ breakdowns
             ├─ job_cards
             ├─ approvals
             ├─ invoices
             └─ accounts_receivable

job_cards ──┬─ inspections
             ├─ repair_orders
             ├─ work_assignments
             ├─ technician_tasks
             └─ invoices

staff ──┬─ attendance
         └─ technician_tasks
```

---

## 4. Authentication & Authorization

### 4.1 OTP Authentication Flow

```
POST /auth/send-otp
  → Validate phone (E.164 format, UAE +971 prefix)
  → Generate 6-digit random OTP
  → Store OTP in MySQL (otp_records) with 5-min TTL
  → Optionally send via SMS gateway (Twilio/Kannel/HTTP API)
  → Return 200 OK

POST /auth/verify-otp
  → Validate phone + OTP
  → Check attempts < 5, check expiry, check not used
  → If valid: mark OTP used, generate JWT + refresh token
  → Look up user by phone; auto-create if new
  → Return { role, token, refreshToken }

POST /auth/refresh
  → Validate refresh token (not revoked, not expired)
  → Issue new JWT + new refresh token, revoke old
  → Return { role, token, refreshToken }

POST /auth/logout
  → Revoke current refresh token (from DB)
  → Return 200 OK
```

### 4.2 JWT Token Design

```yaml
jwt:
  secret: ${JWT_SECRET}
  access-token-expiry: 86400000     # 24h in ms
  refresh-token-expiry: 2592000000  # 30d in ms
```

JWT Claims:
```json
{
  "sub": "user_id",
  "phone": "971501234567",
  "role": "advisor",
  "iat": 1680000000,
  "exp": 1680086400
}
```

### 4.3 Spring Security Configuration

```
SecurityFilterChain:
  1. Disable CSRF (stateless API)
  2. Stateless session management
  3. JwtAuthenticationFilter (reads Authorization: Bearer header)
  4. Role-based access via @PreAuthorize or custom RoleFilter
  5. Permit all: /auth/**, /swagger-ui/**, /v3/api-docs/**
  6. Authenticate: everything else under /api/v1/**
```

### 4.4 Role Permissions Matrix

| Role | Accessible Modules |
|---|---|
| `customer` | `/customers/**`, `/bookings`, `/services/**` |
| `advisor` | `/advisor/**`, `/inspections/**`, `/repair-orders/**`, `/customers/search`, `/vehicles/search` |
| `technician` | `/technicians/**`, `/jobs/**` |
| `supervisor` | `/supervisor/**`, `/work-assignments`, `/departments`, `/technicians` |
| `owner` | `/owner/**` |
| `crmDashboard` | `/crm/**` |

---

## 5. API Module Mapping (All 90 Endpoints)

Each module maps API endpoints to Controller classes:

| # | Method | Path | Module | Controller | Service |
|---|---|---|---|---|---|
| 1 | POST | `/auth/send-otp` | auth | `AuthController` | `OtpService` |
| 2 | POST | `/auth/verify-otp` | auth | `AuthController` | `AuthService` |
| 3 | POST | `/auth/refresh` | auth | `AuthController` | `JwtService` |
| 4 | POST | `/auth/logout` | auth | `AuthController` | `JwtService` |
| 5 | GET | `/customers/profile` | customer | `CustomerController` | `CustomerService` |
| 6 | GET | `/customers/vehicles` | customer | `VehicleController` | `VehicleService` |
| 7 | POST | `/customers/vehicles` | customer | `VehicleController` | `VehicleService` |
| 8 | GET | `/customers/bookings` | customer | `BookingController` | `BookingService` |
| 9 | POST | `/bookings` | customer | `BookingController` | `BookingService` |
| 10 | GET | `/customers/services/active` | customer | `ServiceTrackingController` | `ServiceTrackingService` |
| 11 | GET | `/services/types` | customer | `ServiceTypeController` | `ServiceTypeService` |
| 12 | POST | `/customers/breakdowns` | customer | `BreakdownController` | `BreakdownService` |
| 13 | GET | `/customers/notifications` | customer | `NotificationController` | `NotificationService` |
| 14 | PUT | `/customers/notifications/{id}/read` | customer | `NotificationController` | `NotificationService` |
| 15 | PUT | `/customers/notifications/read-all` | customer | `NotificationController` | `NotificationService` |
| 16 | GET | `/advisor/stats` | advisor | `AdvisorDashboardController` | `AdvisorStatsService` |
| 17 | GET | `/advisor/job-cards` | advisor | `JobCardController` | `JobCardService` |
| 18 | GET | `/advisor/job-cards/{id}` | advisor | `JobCardController` | `JobCardService` |
| 19 | PUT | `/advisor/job-cards/{id}/status` | advisor | `JobCardController` | `JobCardService` |
| 20 | PUT | `/advisor/job-cards/{id}/technician` | advisor | `JobCardController` | `JobCardService` |
| 21 | POST | `/inspections` | advisor | `InspectionController` | `InspectionService` |
| 22 | PUT | `/inspections/{id}/draft` | advisor | `InspectionDraftController` | `InspectionDraftService` |
| 23 | GET | `/inspections/{id}/draft` | advisor | `InspectionDraftController` | `InspectionDraftService` |
| 24 | DELETE | `/inspections/{id}/draft` | advisor | `InspectionDraftController` | `InspectionDraftService` |
| 25 | GET | `/advisor/approvals/pending` | advisor | `ApprovalController` | `ApprovalService` |
| 26 | POST | `/advisor/approvals/{id}` | advisor | `ApprovalController` | `ApprovalService` |
| 27 | GET | `/advisor/reminders` | advisor | `ReminderController` | `ReminderService` |
| 28 | POST | `/advisor/reminders` | advisor | `ReminderController` | `ReminderService` |
| 29 | DELETE | `/advisor/reminders/{id}` | advisor | `ReminderController` | `ReminderService` |
| 30 | POST | `/repair-orders` | advisor | `RepairOrderController` | `RepairOrderService` |
| 31 | POST | `/repair-orders/{id}/media` | media | `MediaController` | `MediaService` |
| 32 | GET | `/advisor/reports` | advisor | `ReportController` | `ReportService` |
| 33 | GET | `/customers/search` | advisor | `SearchController` | `SearchService` |
| 34 | GET | `/vehicles/search` | advisor | `SearchController` | `SearchService` |
| 35 | GET | `/supervisor/kpis` | supervisor | `KpiController` | `SupervisorKpiService` |
| 36 | GET | `/supervisor/advisor-jobs` | supervisor | `SupervisorDashboardController` | `SupervisorDashboardService` |
| 37 | GET | `/supervisor/job-types` | supervisor | `SupervisorDashboardController` | `SupervisorDashboardService` |
| 38 | GET | `/supervisor/revenue-metrics` | supervisor | `SupervisorDashboardController` | `SupervisorDashboardService` |
| 39 | GET | `/supervisor/pending-statuses` | supervisor | `SupervisorDashboardController` | `SupervisorDashboardService` |
| 40 | GET | `/departments` | supervisor | `ReferenceDataController` | `ReferenceDataService` |
| 41 | GET | `/technicians` | supervisor | `ReferenceDataController` | `ReferenceDataService` |
| 42 | POST | `/work-assignments` | supervisor | `WorkAssignmentController` | `WorkAssignmentService` |
| 43 | GET | `/supervisor/assigned-jobs` | supervisor | `WorkAssignmentController` | `WorkAssignmentService` |
| 44 | GET | `/technicians/profile` | technician | `TechnicianProfileController` | `TechnicianProfileService` |
| 45 | POST | `/technicians/attendance/punch-in` | technician | `AttendanceController` | `AttendanceService` |
| 46 | POST | `/technicians/attendance/punch-out` | technician | `AttendanceController` | `AttendanceService` |
| 47 | POST | `/technicians/attendance/break-start` | technician | `AttendanceController` | `AttendanceService` |
| 48 | POST | `/technicians/attendance/break-end` | technician | `AttendanceController` | `AttendanceService` |
| 49 | GET | `/technicians/attendance` | technician | `AttendanceController` | `AttendanceService` |
| 50 | GET | `/technicians/assigned-jobs` | technician | `TechnicianJobController` | `TechnicianJobService` |
| 51 | PUT | `/technicians/assigned-jobs/{id}/status` | technician | `TechnicianJobController` | `TechnicianJobService` |
| 52 | GET | `/technicians/jobs` | technician | `TechnicianJobController` | `TechnicianJobService` |
| 53 | GET | `/technicians/jobs/search` | technician | `TechnicianJobController` | `TechnicianJobService` |
| 54 | PUT | `/technicians/jobs/{jobCardNo}/tasks/{taskId}/start` | technician | `TaskController` | `TaskService` |
| 55 | PUT | `/technicians/jobs/{jobCardNo}/tasks/{taskId}/complete` | technician | `TaskController` | `TaskService` |
| 56 | PUT | `/technicians/jobs/{jobCardNo}/tasks/{taskId}/status` | technician | `TaskController` | `TaskService` |
| 57 | POST | `/jobs/complete` | technician | `JobCompletionController` | `JobCompletionService` |
| 58 | PUT | `/technicians/jobs/{jobCardNo}/notes` | technician | `TechnicianJobController` | `TechnicianJobService` |
| 59 | GET | `/technicians/productivity` | technician | `ProductivityController` | `ProductivityService` |
| 60 | GET | `/owner/dashboard/kpis` | owner | `OwnerDashboardController` | `OwnerDashboardService` |
| 61 | GET | `/owner/dashboard/sales-trend` | owner | `OwnerDashboardController` | `SalesTrendService` |
| 62 | GET | `/owner/dashboard/profit-trend` | owner | `OwnerDashboardController` | `SalesTrendService` |
| 63 | GET | `/owner/dashboard/expenses-trend` | owner | `OwnerDashboardController` | `SalesTrendService` |
| 64 | GET | `/owner/dashboard/job-card-register` | owner | `OwnerDashboardController` | `OwnerDashboardService` |
| 65 | GET | `/owner/dashboard/top-sales` | owner | `OwnerDashboardController` | `TopSalesService` |
| 66 | GET | `/owner/job-cards` | owner | `OwnerJobCardController` | `OwnerJobCardService` |
| 67 | GET | `/owner/documents/expiry` | owner | `OwnerDocumentController` | `DocumentExpiryService` |
| 68 | GET | `/owner/jobs/status` | owner | `OwnerJobStatusController` | `OwnerJobStatusService` |
| 69 | GET | `/owner/approvals/categories` | owner | `OwnerApprovalController` | `OwnerApprovalService` |
| 70 | GET | `/owner/jobs/pending` | owner | `OwnerJobController` | `OwnerJobService` |
| 71 | GET | `/owner/jobs/active` | owner | `OwnerJobController` | `OwnerJobService` |
| 72 | GET | `/owner/invoices` | owner | `InvoiceController` | `InvoiceService` |
| 73 | GET | `/owner/accounts-receivable/summary` | owner | `ArController` | `ArService` |
| 74 | GET | `/owner/accounts-receivable/records` | owner | `ArController` | `ArService` |
| 75 | GET | `/owner/messages` | owner | `MessageController` | `MessageService` |
| 76 | POST | `/owner/messages` | owner | `MessageController` | `MessageService` |
| 77 | GET | `/owner/activity` | owner | `ActivityController` | `ActivityService` |
| 78 | GET | `/crm/dashboard/kpis` | crm | `CrmDashboardController` | `CrmDashboardService` |
| 79 | GET | `/crm/channels` | crm | `CrmDashboardController` | `CrmDashboardService` |
| 80 | GET | `/crm/conversion-trend` | crm | `CrmDashboardController` | `CrmDashboardService` |
| 81 | GET | `/crm/salesperson-performance` | crm | `CrmDashboardController` | `CrmDashboardService` |
| 82 | GET | `/crm/response-times` | crm | `CrmDashboardController` | `CrmDashboardService` |
| 83 | GET | `/crm/lead-sources` | crm | `CrmDashboardController` | `CrmDashboardService` |
| 84 | GET | `/crm/key-metrics` | crm | `CrmDashboardController` | `CrmDashboardService` |
| 85 | GET | `/crm/integrations` | crm | `IntegrationController` | `IntegrationService` |
| 86 | GET | `/crm/sales-team` | crm | `SalesTeamController` | `SalesTeamService` |
| 87 | GET | `/crm/conversations` | crm | `ConversationController` | `ConversationService` |
| 88 | GET | `/crm/leads` | crm | `LeadController` | `LeadService` |
| 89 | GET | `/crm/tasks` | crm | `CrmTaskController` | `CrmTaskService` |
| 90 | PUT | `/crm/tasks/{id}` | crm | `CrmTaskController` | `CrmTaskService` |

---

## 6. Key Service Design Patterns

### 6.1 API Response Envelope

```java
public class ApiResponse<T> {
    private int code;
    private String message;
    private T data;
    private long timestamp;
}

public class PageResponse<T> {
    private List<T> content;
    private int page;
    private int size;
    private long totalElements;
    private int totalPages;
}
```

### 6.2 Service Layer Pattern

```java
public interface JobCardService {
    PageResponse<JobCardResponse> listJobCards(String status, String search, int page, int limit);
    JobCardDetailResponse getJobCard(Long id);
    void updateStatus(Long id, String status);
    void assignTechnician(Long id, String technician);
}
```

### 6.3 Reporting/Aggregation Strategy

For dashboard KPIs (owner, supervisor, CRM), use **raw SQL via MyBatis** for complex aggregations:

```xml
<select id="getRevenueMetrics" resultType="RevenueMetricDTO">
    SELECT
        'Total Revenue' as label,
        SUM(grand_total) as amount,
        CONCAT('+', ROUND(
            (SUM(grand_total) - LAG(SUM(grand_total)) OVER (ORDER BY MONTH(created_at)))
            / LAG(SUM(grand_total)) OVER (ORDER BY MONTH(created_at)) * 100, 1), '%'
        ) as `change`
    FROM repair_orders
    WHERE created_at >= DATE_SUB(NOW(), INTERVAL 1 MONTH)
</select>
```

### 6.4 Inspection JSON Storage

The inspection data (4 sections, 26+ items) is stored as a MySQL `JSON` column:

```json
{
  "interior_exterior": {
    "Head Light/Tail Light/Turn Signals": { "status": "good", "photos": [], "note": "" },
    "Wiper Blade": { "status": "fair", "photos": [], "note": "Cracked" }
  },
  "under_vehicle": { "Fluid Leaks": { "status": "fair" } },
  "under_hood": { "Fluid Levels": { "status": "fair", "note": "Coolant low" } },
  "battery": { "Terminals/Cables": { "status": "good" } }
}
```

MyBatis maps this with a `TypeHandler`:
```java
public class InspectionSectionsTypeHandler extends BaseTypeHandler<Map<String, Object>> {
    // Uses Jackson ObjectMapper to serialize/deserialize JSON column
}
```

---

## 7. Offline Sync & Idempotency

### 7.1 Idempotency Filter

```
X-Idempotency-Key: <uuid>

Request comes in:
  1. IdempotencyFilter checks X-Idempotency-Key header
  2. Look up key in idempotency_keys table
  3. If found -> return cached response (same HTTP status + body)
  4. If not -> proceed, store key + response after handler
```

### 7.2 Conflict Handling

When a merge conflict is detected (optimistic locking via `updated_at`):
```
HTTP 409 Conflict
{
  "code": 409,
  "message": "Conflict: resource has been modified since last sync",
  "data": {
    "serverVersion": { ... current server state ... },
    "yourVersion": { ... what client sent ... }
  }
}
```

### 7.3 Sync Endpoints (Idempotent POST)

| Sync Endpoint | Corresponding Create | Idempotency Key |
|---|---|---|
| `POST /sync/inspections/{id}` | `POST /inspections` | Inspection UUID |
| `POST /sync/jobs/complete/{id}` | `POST /jobs/complete` | Job card UUID |
| `POST /sync/work-assignments` | `POST /work-assignments` | Batch UUID |
| `POST /sync/bookings` | `POST /bookings` | Booking UUID |
| `POST /sync/repair-orders/{id}` | `POST /repair-orders` | Repair order UUID |

---

## 8. Caching Strategy (Redis)

| Cache Key | TTL | Purpose |
|---|---|---|
| `otp:{phone}` | 5 min | OTP code + attempts |
| `refresh:{token}` | 30 days | Active refresh tokens |
| `service:types` | 1 hour | Service types list |
| `technicians:list` | 10 min | Technician name list |
| `departments:list` | 1 hour | Department list |
| `dashboard:owner:kpis` | 5 min | Owner dashboard KPIs |
| `dashboard:crm:kpis` | 5 min | CRM KPIs |

Use Spring `@Cacheable`:
```java
@Cacheable(value = "serviceTypes", unless = "#result == null")
public List<ServiceType> getServiceTypes() { ... }
```

---

## 9. Media Upload Handling

### 9.1 Storage

- Local filesystem: `/data/orient/media/{module}/{id}/`
- Organize by module: `inspections/`, `repair-orders/`
- File naming: `{uuid}_{original_filename}`
- Supported: images (jpg, png, webp), videos (mp4), audio (m4a, wav)

### 9.2 Upload Endpoint

```
POST /repair-orders/{id}/media
Content-Type: multipart/form-data

Fields: file (binary), itemId (string), type (photo/video/audio)

Response:
{ "url": "/media/repair-orders/RO-001/abc123_photo.jpg" }
```

### 9.3 Serving Media

```java
@Override
public void addResourceHandlers(ResourceHandlerRegistry registry) {
    registry.addResourceHandler("/media/**")
            .addResourceLocations("file:/data/orient/media/");
}
```

---

## 10. Scheduled Jobs

| Job | Frequency | Description |
|---|---|---|
| `OtpCleanupJob` | Every 15 min | Delete expired OTP records > 1 hour old |
| `ReminderNotificationJob` | Every 30 min | Create notifications for due reminders |
| `InvoiceOverdueJob` | Daily midnight | Update invoice statuses to overdue |
| `DocumentExpiryCheckJob` | Daily 6 AM | Update urgency levels on documents |
| `IdempotencyKeyCleanupJob` | Daily 3 AM | Delete keys older than 7 days |
| `SyncLogCleanupJob` | Weekly | Archive sync logs > 30 days |

---

## 11. Application Configuration

### 11.1 application.yml

```yaml
server:
  port: 8080
  servlet:
    context-path: /api/v1

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/orient_workshop?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
    username: ${DB_USERNAME:root}
    password: ${DB_PASSWORD:root}
    driver-class-name: com.mysql.cj.jdbc.Driver
  data:
    redis:
      host: ${REDIS_HOST:localhost}
      port: ${REDIS_PORT:6379}
  servlet:
    multipart:
      max-file-size: 50MB
      max-request-size: 100MB

app:
  jwt:
    secret: ${JWT_SECRET}
    access-token-expiry: 86400000
    refresh-token-expiry: 2592000000
  otp:
    length: 6
    expiry-minutes: 5
    max-attempts: 5
  media:
    upload-path: /data/orient/media
    allowed-types: image/jpeg,image/png,image/webp,video/mp4,audio/m4a,audio/wav
  sync:
    idempotency-ttl-days: 7

mybatis-plus:
  configuration:
    map-underscore-to-camel-case: true
  global-config:
    db-config:
      id-type: auto

springdoc:
  api-docs:
    path: /v3/api-docs
  swagger-ui:
    path: /swagger-ui.html
```

---

## 12. Error Handling

### 12.1 Exception Hierarchy

```
AppException (RuntimeException)
  ├── BadRequestException (400)
  ├── UnauthorizedException (401)
  ├── ForbiddenException (403)
  ├── NotFoundException (404)
  ├── ConflictException (409)
  ├── TooManyRequestsException (429)
  └── InternalServerException (500)
```

### 12.2 GlobalExceptionHandler

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(AppException.class)
    public ApiResponse<Void> handleAppException(AppException e) {
        return ApiResponse.error(e.getCode(), e.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ApiResponse<Map<String, String>> handleValidation(ConstraintViolationException e) {
        Map<String, String> errors = new HashMap<>();
        e.getConstraintViolations().forEach(v ->
            errors.put(v.getPropertyPath().toString(), v.getMessage()));
        return ApiResponse.error(400, "Validation failed", errors);
    }
}
```

---

## 13. Implementation Phases

### Phase 1: Project Bootstrap & Auth (Week 1)
- Initialize Maven multi-module project
- Set up Spring Boot + MyBatis-Plus + MySQL connection
- Configure JWT (jjwt) + Spring Security
- Implement `orient-auth`: OTP send/verify/refresh/logout endpoints
- Implement `orient-common`: ApiResponse, AppException, GlobalExceptionHandler
- Create database schema migration scripts
- Write integration tests for auth flow
- Verify end-to-end: Flutter login -> OTP -> JWT -> authenticated request

### Phase 2: Customer & Booking APIs (Week 2)
- Customer profile CRUD
- Vehicle management (list, add)
- Booking creation + listing
- Service types + active service tracking
- Breakdown/emergency endpoint
- Notification CRUD + mark-read

### Phase 3: Advisor Module (Week 3)
- Dashboard stats aggregation (job counts by status)
- Job card CRUD + status workflow + technician assignment
- Inspection lifecycle (create, draft save/load/delete)
- Approval management (pending list, approve/reject)
- Reminder CRUD
- Repair order creation (services + parts with discount calculation)
- Search (customers + vehicles)

### Phase 4: Technician Module (Week 4)
- Technician profile
- Attendance system (punch-in, punch-out, break)
- Assigned jobs + job detail
- Task management (start, complete, status update)
- Job completion flow
- Notes update
- Productivity stats

### Phase 5: Supervisor Module (Week 4-5)
- KPI dashboard aggregation queries
- Advisor job counts
- Job types breakdown
- Revenue metrics
- Pending status counts
- Reference data (departments, technicians)
- Work assignments (batch create) + assigned jobs list

### Phase 6: Owner Dashboard (Week 5-6)
- Dashboard KPIs (16 cards) with aggregation
- Sales/profit/expenses trends
- Job card register
- Top sales categories (customer, brand, advisor, etc.)
- Owner job cards view
- Document expiry (with computed urgency)
- Job status by stage
- Approval categories with counts
- Pending + active jobs
- Invoices CRUD
- Accounts receivable (summary + records with aging)
- Messages + activity feed

### Phase 7: CRM Module (Week 6)
- Dashboard KPIs
- Channel analytics
- Conversion trends
- Salesperson performance
- Response times, lead sources, key metrics
- Integrations status
- Sales team list
- Conversations list
- Leads CRUD with filtering
- Tasks CRUD + completion toggle

### Phase 8: Media, Sync & Scheduler (Week 7)
- Media upload/download with file validation
- Idempotency filter + key management
- Sync conflict detection (HTTP 409)
- Activity log recording
- Scheduled jobs (OTP cleanup, reminders, overdue, document expiry)
- Rate limiting
- Request logging filter

### Phase 9: Testing, Security & Deployment (Week 8)
- Unit tests for all services (JUnit 5 + Mockito)
- Integration tests with TestContainers (MySQL)
- API contract tests (match frontend expectations)
- Security audit (JWT, role checks, input validation)
- Performance testing (JMeter for dashboard queries)
- Swagger/OpenAPI docs review
- Dockerfile + docker-compose.yml
- Deployment scripts + systemd service
- Database backup strategy
- Monitoring setup (health endpoint, metrics)

---

## 14. Naming Conventions

| Layer | Convention | Example |
|---|---|---|
| Package | `com.orient.workshop.{module}` | `com.orient.workshop.advisor` |
| Controller | `{Entity}Controller` | `JobCardController` |
| Service | `{Entity}Service` | `JobCardService` |
| Repository (Mapper) | `{Entity}Mapper` | `JobCardMapper` |
| Request DTO | `{Action}Request` | `CreateJobCardRequest` |
| Response DTO | `{Entity}Response` / `{Entity}DetailResponse` | `JobCardResponse` |
| Entity/Model | `{Entity}` | `JobCard`, `Customer` |
| Enum | PascalCase | `JobCardStatus`, `UserRole` |
| DB Table | `snake_case` | `job_cards`, `repair_orders` |
| DB Column | `snake_case` | `created_at`, `job_card_ref` |
| API Path | `kebab-case` | `/advisor/job-cards` |

---

## 15. Maven Dependencies (Key)

```xml
<!-- Parent POM dependencies -->
<dependencies>
    <!-- Spring Boot Starters -->
    <dependency>spring-boot-starter-web</dependency>
    <dependency>spring-boot-starter-security</dependency>
    <dependency>spring-boot-starter-data-redis</dependency>
    <dependency>spring-boot-starter-validation</dependency>

    <!-- MyBatis-Plus -->
    <dependency>
        <groupId>com.baomidou</groupId>
        <artifactId>mybatis-plus-spring-boot3-starter</artifactId>
        <version>3.5.9</version>
    </dependency>

    <!-- MySQL -->
    <dependency>
        <groupId>com.mysql</groupId>
        <artifactId>mysql-connector-j</artifactId>
        <scope>runtime</scope>
    </dependency>

    <!-- JWT -->
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt-api</artifactId>
        <version>0.12.6</version>
    </dependency>
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt-impl</artifactId>
        <version>0.12.6</version>
        <scope>runtime</scope>
    </dependency>
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt-jackson</artifactId>
        <version>0.12.6</version>
        <scope>runtime</scope>
    </dependency>

    <!-- API Docs -->
    <dependency>
        <groupId>org.springdoc</groupId>
        <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
        <version>2.7.0</version>
    </dependency>

    <!-- Lombok (optional but recommended) -->
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>

    <!-- Testing -->
    <dependency>spring-boot-starter-test</dependency>
    <dependency>org.testcontainers:mysql:1.20.4</dependency>
</dependencies>
```
