-- Orient Workshop Database Schema
-- MySQL 8.0+

CREATE DATABASE IF NOT EXISTS orient_workshop
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE orient_workshop;

-- =========== AUTH & USERS ===========

CREATE TABLE users (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    phone         VARCHAR(20) DEFAULT NULL UNIQUE,
    email         VARCHAR(100) DEFAULT NULL UNIQUE,
    password_hash VARCHAR(255) DEFAULT '',
    name          VARCHAR(100) DEFAULT '',
    role          ENUM('owner','advisor','technician','customer','supervisor','crmDashboard') NOT NULL DEFAULT 'customer',
    is_active     BOOLEAN DEFAULT TRUE,
    avatar_url    VARCHAR(500) DEFAULT '',
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_phone (phone),
    INDEX idx_email (email),
    INDEX idx_role (role)
) ENGINE=InnoDB;

CREATE TABLE otp_records (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    phone         VARCHAR(20) DEFAULT NULL,
    email         VARCHAR(100) DEFAULT NULL,
    otp_code      VARCHAR(6) NOT NULL,
    attempts      INT DEFAULT 0,
    expires_at    DATETIME NOT NULL,
    used          BOOLEAN DEFAULT FALSE,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_phone_otp (phone, otp_code),
    INDEX idx_email_otp (email, otp_code),
    INDEX idx_expires (expires_at)
) ENGINE=InnoDB;

CREATE TABLE refresh_tokens (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id       BIGINT NOT NULL,
    token         VARCHAR(500) NOT NULL UNIQUE,
    expires_at    DATETIME NOT NULL,
    revoked       BOOLEAN DEFAULT FALSE,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_token (token),
    INDEX idx_user (user_id)
) ENGINE=InnoDB;

-- =========== CUSTOMERS ===========

CREATE TABLE customers (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id         BIGINT,
    is_b2b          BOOLEAN DEFAULT FALSE,
    customer_name   VARCHAR(100) DEFAULT '',
    phone_number    VARCHAR(20) DEFAULT '',
    email           VARCHAR(100) DEFAULT '',
    customer_group  VARCHAR(50) DEFAULT '',
    tags            JSON,
    gender          VARCHAR(10) DEFAULT '',
    address         TEXT,
    tax_number      VARCHAR(50) DEFAULT '',
    group_tax_number VARCHAR(50) DEFAULT '',
    occupation      VARCHAR(100) DEFAULT '',
    organisation    VARCHAR(100) DEFAULT '',
    source          VARCHAR(50) DEFAULT '',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_phone (phone_number),
    INDEX idx_name (customer_name)
) ENGINE=InnoDB;

-- =========== VEHICLES ===========

CREATE TABLE vehicles (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id         BIGINT NOT NULL,
    registration_number VARCHAR(50) DEFAULT '',
    vin                 VARCHAR(50) DEFAULT '',
    make                VARCHAR(50) DEFAULT '',
    model               VARCHAR(50) DEFAULT '',
    model_year          INT DEFAULT 0,
    purchase_date       DATE,
    cylinders           INT DEFAULT 0,
    engine_capacity     VARCHAR(20) DEFAULT '',
    vehicle_color       VARCHAR(30) DEFAULT '',
    engine_number       VARCHAR(50) DEFAULT '',
    insurance_provider  VARCHAR(100) DEFAULT '',
    insurance_tax_number VARCHAR(50) DEFAULT '',
    insurance_address   TEXT,
    policy_number       VARCHAR(50) DEFAULT '',
    insurance_expiry_date DATE,
    plate_number        VARCHAR(20) DEFAULT '',
    mileage             VARCHAR(20) DEFAULT '',
    last_service        VARCHAR(20) DEFAULT '',
    next_due            VARCHAR(20) DEFAULT '',
    health_score        INT DEFAULT 100,
    INDEX idx_customer (customer_id),
    INDEX idx_plate (plate_number),
    INDEX idx_vin (vin),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
) ENGINE=InnoDB;

-- =========== SERVICE TYPES ===========

CREATE TABLE service_types (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    price       VARCHAR(50) DEFAULT '',
    duration    VARCHAR(20) DEFAULT '',
    is_active   BOOLEAN DEFAULT TRUE,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

INSERT INTO service_types (name, price, duration) VALUES
('Oil Change', 'From £65', '~1 hr'),
('Tyre Rotation', 'From £55', '~45 min'),
('Full Inspection', 'From £120', '~2 hrs'),
('General Repair', 'POA', 'Varies'),
('MOT Test', 'From £54.85', '~1 hr'),
('Full Service', 'From £280', '~3 hrs');

-- =========== BOOKINGS ===========

CREATE TABLE bookings (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_ref   VARCHAR(50) NOT NULL UNIQUE,
    customer_id   BIGINT NOT NULL,
    vehicle_id    BIGINT NOT NULL,
    vehicle_name  VARCHAR(100) DEFAULT '',
    plate_number  VARCHAR(20) DEFAULT '',
    service_type  VARCHAR(100) DEFAULT '',
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
) ENGINE=InnoDB;

-- =========== BREAKDOWNS ===========

CREATE TABLE breakdowns (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    breakdown_ref VARCHAR(50) NOT NULL UNIQUE,
    customer_id   BIGINT NOT NULL,
    issue         TEXT NOT NULL,
    vehicle_id    BIGINT,
    vehicle_name  VARCHAR(100) DEFAULT '',
    vehicle_plate VARCHAR(20) DEFAULT '',
    location      TEXT,
    status        ENUM('pending','dispatched','resolved','cancelled') DEFAULT 'pending',
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    INDEX idx_customer (customer_id)
) ENGINE=InnoDB;

-- =========== NOTIFICATIONS ===========

CREATE TABLE notifications (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id       BIGINT NOT NULL,
    title         VARCHAR(200) NOT NULL,
    body          TEXT,
    type          ENUM('carReady','bookingConfirmed','invoiceReady','approvalNeeded','workInProgress','reminder') DEFAULT 'carReady',
    is_read       BOOLEAN DEFAULT FALSE,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_user_read (user_id, is_read)
) ENGINE=InnoDB;

-- =========== JOB CARDS ===========

CREATE TABLE job_cards (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    job_card_ref    VARCHAR(50) NOT NULL UNIQUE,
    customer_id     BIGINT NOT NULL,
    vehicle_id      BIGINT,
    status          ENUM('inProgress','pendingApproval','qualityCheck','completed','cancelled','waitingParts','pending') DEFAULT 'pending',
    technician      VARCHAR(100) DEFAULT '',
    created_date    DATETIME,
    last_updated    DATETIME,
    notes           TEXT,
    tag             VARCHAR(50) DEFAULT '',
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
) ENGINE=InnoDB;

-- =========== INSPECTIONS ===========

CREATE TABLE inspections (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    inspection_ref  VARCHAR(50) NOT NULL UNIQUE,
    job_card_id     BIGINT,
    reference_number VARCHAR(50) DEFAULT '',
    place_of_supply VARCHAR(100) DEFAULT '',
    customer_requests TEXT,
    garage_recommendations TEXT,
    estimated_delivery DATETIME,
    notify_owner_sms_email BOOLEAN DEFAULT FALSE,
    tag             VARCHAR(50) DEFAULT '',
    is_draft        BOOLEAN DEFAULT FALSE,
    sections        JSON,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (job_card_id) REFERENCES job_cards(id),
    INDEX idx_job_card (job_card_id)
) ENGINE=InnoDB;

-- =========== REPAIR ORDERS ===========

CREATE TABLE repair_orders (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    repair_order_ref VARCHAR(50) NOT NULL UNIQUE,
    job_card_id     BIGINT NOT NULL,
    services_total  DECIMAL(12,2) DEFAULT 0.00,
    parts_total     DECIMAL(12,2) DEFAULT 0.00,
    grand_total     DECIMAL(12,2) DEFAULT 0.00,
    tag             VARCHAR(50) DEFAULT '',
    customer_requests TEXT,
    garage_recommendations TEXT,
    estimated_delivery DATETIME,
    notify_owner_sms_email BOOLEAN DEFAULT FALSE,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (job_card_id) REFERENCES job_cards(id),
    INDEX idx_job_card (job_card_id)
) ENGINE=InnoDB;

CREATE TABLE repair_order_services (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    repair_order_id BIGINT NOT NULL,
    name            VARCHAR(100) NOT NULL,
    qty             INT DEFAULT 1,
    rate            DECIMAL(12,2) DEFAULT 0.00,
    discount_percent DECIMAL(5,2) DEFAULT 0.00,
    discount_amount DECIMAL(12,2) DEFAULT 0.00,
    FOREIGN KEY (repair_order_id) REFERENCES repair_orders(id)
) ENGINE=InnoDB;

CREATE TABLE repair_order_parts (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    repair_order_id BIGINT NOT NULL,
    name            VARCHAR(100) NOT NULL,
    qty             INT DEFAULT 1,
    rate            DECIMAL(12,2) DEFAULT 0.00,
    discount_percent DECIMAL(5,2) DEFAULT 0.00,
    discount_amount DECIMAL(12,2) DEFAULT 0.00,
    FOREIGN KEY (repair_order_id) REFERENCES repair_orders(id)
) ENGINE=InnoDB;

-- =========== PREDEFINED SERVICES & PARTS ===========

CREATE TABLE predefined_services (
    id    BIGINT AUTO_INCREMENT PRIMARY KEY,
    name  VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

INSERT INTO predefined_services (name) VALUES
('A/C Overhauling'), ('Air Filter'), ('Battery'), ('Brake'), ('Clutch'),
('Cooling System'), ('Engine Oil'), ('Fuel Filter'), ('Power Steering'), ('Radiator'),
('Spark Plug'), ('Timing Belt'), ('Wheel Alignment'), ('Wheel Balancing'), ('Wind Screen'),
('AC Service'), ('Brake Pads'), ('Brake Discs'), ('Suspension System'), ('Transmission Fluid');

CREATE TABLE predefined_parts (
    id    BIGINT AUTO_INCREMENT PRIMARY KEY,
    name  VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

INSERT INTO predefined_parts (name) VALUES
('A/C heater core'), ('Alloy wheel'), ('Alternator'), ('Brake booster'), ('Clutch cable'),
('Engine air filter'), ('Fuel filter'), ('Oil filter'), ('Spark plug'), ('Wiper blade'),
('Brake pad set'), ('Radiator cap'), ('Drive belt'), ('Battery'), ('Coolant');

-- =========== APPROVALS ===========

CREATE TABLE approvals (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    estimate_id     VARCHAR(50) NOT NULL,
    customer_id     BIGINT NOT NULL,
    customer_name   VARCHAR(100) DEFAULT '',
    vehicle_id      VARCHAR(50) DEFAULT '',
    amount          DECIMAL(12,2) DEFAULT 0.00,
    action          ENUM('pending','approved','rejected') DEFAULT 'pending',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    INDEX idx_estimate (estimate_id),
    INDEX idx_action (action)
) ENGINE=InnoDB;

-- =========== REMINDERS ===========

CREATE TABLE reminders (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    reminder_ref    VARCHAR(50) NOT NULL UNIQUE,
    customer_name   VARCHAR(100) DEFAULT '',
    vehicle_id      VARCHAR(50) DEFAULT '',
    task            TEXT NOT NULL,
    due_date        VARCHAR(100) DEFAULT '',
    priority        ENUM('high','medium','low') DEFAULT 'medium',
    is_completed    BOOLEAN DEFAULT FALSE,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =========== STAFF ===========

CREATE TABLE staff (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id         BIGINT,
    emp_id          VARCHAR(20) NOT NULL UNIQUE,
    name            VARCHAR(100) NOT NULL,
    role            ENUM('advisor','technician','supervisor') NOT NULL,
    branch          VARCHAR(100) DEFAULT '',
    shift           VARCHAR(100) DEFAULT '',
    designation     VARCHAR(100) DEFAULT '',
    department      VARCHAR(100) DEFAULT '',
    avatar_initials VARCHAR(5) DEFAULT '',
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_emp_id (emp_id),
    INDEX idx_role (role)
) ENGINE=InnoDB;

-- =========== ATTENDANCE ===========

CREATE TABLE attendance (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    emp_id          VARCHAR(20) NOT NULL,
    date            DATE NOT NULL,
    status          ENUM('notPunchedIn','working','onBreak','punchedOut') DEFAULT 'notPunchedIn',
    punch_in        VARCHAR(20) DEFAULT '',
    punch_out       VARCHAR(20) DEFAULT '',
    break_time      VARCHAR(20) DEFAULT '',
    work_hours      VARCHAR(20) DEFAULT '',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_emp_date (emp_id, date),
    FOREIGN KEY (emp_id) REFERENCES staff(emp_id),
    INDEX idx_emp_date (emp_id, date)
) ENGINE=InnoDB;

-- =========== TECHNICIAN TASKS ===========

CREATE TABLE technician_tasks (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    job_card_no     VARCHAR(50) NOT NULL,
    task_ref        VARCHAR(20) NOT NULL,
    description     TEXT NOT NULL,
    status          ENUM('pending','inProgress','completed') DEFAULT 'pending',
    emp_id          VARCHAR(20) DEFAULT '',
    start_time      VARCHAR(20) DEFAULT '',
    end_time        VARCHAR(20) DEFAULT '',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (job_card_no) REFERENCES job_cards(job_card_ref),
    FOREIGN KEY (emp_id) REFERENCES staff(emp_id),
    INDEX idx_job_card (job_card_no),
    INDEX idx_emp (emp_id)
) ENGINE=InnoDB;

-- =========== WORK ASSIGNMENTS ===========

CREATE TABLE work_assignments (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    assignment_ref  VARCHAR(50) NOT NULL UNIQUE,
    job_card_id     BIGINT NOT NULL,
    description     TEXT NOT NULL,
    department      VARCHAR(100) DEFAULT '',
    technician_name VARCHAR(100) DEFAULT '',
    date_of_work    DATE,
    status_percent  INT DEFAULT 0,
    std_time        VARCHAR(20) DEFAULT '',
    remarks         TEXT,
    status          ENUM('Pending','In Progress','Completed') DEFAULT 'Pending',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (job_card_id) REFERENCES job_cards(id),
    INDEX idx_job_card (job_card_id),
    INDEX idx_technician (technician_name)
) ENGINE=InnoDB;

-- =========== DEPARTMENTS ===========

CREATE TABLE departments (
    id      BIGINT AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

INSERT INTO departments (name) VALUES
('Engine'), ('Body & Paint'), ('Electrical'), ('Tyres & Alignment'),
('AC & Cooling'), ('Transmission'), ('General Service');

-- =========== INVOICES ===========

CREATE TABLE invoices (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    invoice_ref     VARCHAR(50) NOT NULL UNIQUE,
    customer_id     BIGINT NOT NULL,
    job_card_id     BIGINT,
    amount          DECIMAL(12,2) DEFAULT 0.00,
    status          ENUM('paid','unpaid','overdue') DEFAULT 'unpaid',
    due_date        DATE,
    issued_date     DATE,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    INDEX idx_status (status),
    INDEX idx_customer (customer_id)
) ENGINE=InnoDB;

-- =========== ACCOUNTS RECEIVABLE ===========

CREATE TABLE accounts_receivable (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    ar_ref          VARCHAR(50) NOT NULL UNIQUE,
    customer_id     BIGINT NOT NULL,
    invoice_id      BIGINT,
    invoice_date    DATE,
    due_date        DATE,
    amount          DECIMAL(12,2) DEFAULT 0.00,
    outstanding     DECIMAL(12,2) DEFAULT 0.00,
    aging           ENUM('days0to30','days31to60','days61to90','days90plus') DEFAULT 'days0to30',
    contact_person  VARCHAR(100) DEFAULT '',
    phone           VARCHAR(20) DEFAULT '',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    INDEX idx_customer (customer_id),
    INDEX idx_aging (aging)
) ENGINE=InnoDB;

-- =========== MESSAGES ===========

CREATE TABLE messages (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    sender_id       BIGINT,
    recipient       VARCHAR(100) NOT NULL,
    recipient_id    BIGINT,
    message         TEXT NOT NULL,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id)
) ENGINE=InnoDB;

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
) ENGINE=InnoDB;

-- =========== CRM TABLES ===========

CREATE TABLE leads (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    lead_number     VARCHAR(50) NOT NULL UNIQUE,
    customer_name   VARCHAR(100) NOT NULL,
    phone           VARCHAR(20) DEFAULT '',
    email           VARCHAR(100) DEFAULT '',
    source          VARCHAR(50) DEFAULT '',
    assigned_to     VARCHAR(100) DEFAULT '',
    status          ENUM('ACTIVE','WON','UNANSWERED','LOST') DEFAULT 'ACTIVE',
    last_activity   VARCHAR(100) DEFAULT '',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_status (status),
    INDEX idx_source (source),
    INDEX idx_assigned (assigned_to)
) ENGINE=InnoDB;

CREATE TABLE crm_conversations (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_name   VARCHAR(100) DEFAULT '',
    last_message    TEXT,
    time            VARCHAR(50) DEFAULT '',
    channel         VARCHAR(50) DEFAULT '',
    unread          INT DEFAULT 0,
    status          VARCHAR(20) DEFAULT 'active',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE crm_tasks (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    title           VARCHAR(200) NOT NULL,
    assigned_to     VARCHAR(100) DEFAULT '',
    due_date        VARCHAR(50) DEFAULT '',
    priority        ENUM('High','Medium','Low') DEFAULT 'Medium',
    is_done         BOOLEAN DEFAULT FALSE,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE crm_integrations (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL UNIQUE,
    connected       BOOLEAN DEFAULT FALSE
) ENGINE=InnoDB;

-- =========== SYNC & IDEMPOTENCY ===========

CREATE TABLE idempotency_keys (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    idempotency_key VARCHAR(100) NOT NULL UNIQUE,
    response_body   JSON,
    http_status     INT DEFAULT 200,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_key (idempotency_key),
    INDEX idx_created (created_at)
) ENGINE=InnoDB;

CREATE TABLE sync_logs (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    idempotency_key VARCHAR(100) DEFAULT '',
    endpoint        VARCHAR(200) NOT NULL,
    method          VARCHAR(10) NOT NULL,
    request_body    JSON,
    status          ENUM('success','conflict','error') DEFAULT 'success',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_key (idempotency_key),
    INDEX idx_created (created_at)
) ENGINE=InnoDB;

-- =========== EMPLOYEE DOCUMENTS ===========

CREATE TABLE employee_documents (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    emp_id          VARCHAR(20) NOT NULL,
    employee_name   VARCHAR(100) DEFAULT '',
    designation     VARCHAR(100) DEFAULT '',
    document_type   VARCHAR(100) NOT NULL,
    expiry_date     DATE NOT NULL,
    days_left       INT DEFAULT 0,
    urgency         VARCHAR(20) DEFAULT 'normal',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (emp_id) REFERENCES staff(emp_id),
    INDEX idx_emp (emp_id),
    INDEX idx_expiry (expiry_date)
) ENGINE=InnoDB;

-- =========== BRANCHES ===========

CREATE TABLE branches (
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

INSERT INTO branches (name, address, phone, email) VALUES
('Main Branch - Dubai', 'Sheikh Zayed Rd, Dubai', '+97141234567', 'main@orientworkshop.com');

-- =========== FEEDBACK ===========

CREATE TABLE feedback (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    job_card_id   BIGINT,
    customer_id   BIGINT NOT NULL,
    branch_id     BIGINT,
    rating        TINYINT NOT NULL,
    comment       TEXT,
    is_public     BOOLEAN DEFAULT FALSE,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (job_card_id) REFERENCES job_cards(id),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (branch_id) REFERENCES branches(id)
) ENGINE=InnoDB;

-- =========== WHATSAPP MESSAGES ===========

CREATE TABLE whatsapp_messages (
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

-- =========== ADD BRANCH_ID TO EXISTING TABLES ===========

ALTER TABLE users ADD COLUMN branch_id BIGINT DEFAULT NULL AFTER email,
    ADD INDEX idx_branch (branch_id);

ALTER TABLE staff ADD COLUMN branch_id BIGINT DEFAULT NULL AFTER role,
    ADD INDEX idx_branch (branch_id);

ALTER TABLE job_cards ADD COLUMN branch_id BIGINT DEFAULT NULL AFTER customer_id,
    ADD INDEX idx_branch (branch_id);

ALTER TABLE customers ADD COLUMN branch_id BIGINT DEFAULT NULL AFTER user_id,
    ADD INDEX idx_branch (branch_id);

ALTER TABLE vehicles ADD COLUMN branch_id BIGINT DEFAULT NULL AFTER customer_id;
ALTER TABLE bookings ADD COLUMN branch_id BIGINT DEFAULT NULL AFTER customer_id;
ALTER TABLE invoices ADD COLUMN branch_id BIGINT DEFAULT NULL AFTER customer_id;
ALTER TABLE notifications ADD COLUMN branch_id BIGINT DEFAULT NULL AFTER user_id;
ALTER TABLE work_assignments ADD COLUMN branch_id BIGINT DEFAULT NULL AFTER job_card_id;

-- =========== PERFORMANCE INDEXES ===========

ALTER TABLE job_cards ADD INDEX idx_status_created (status, created_at);
ALTER TABLE job_cards ADD INDEX idx_customer_status (customer_id, status);
ALTER TABLE bookings ADD INDEX idx_customer_date (customer_id, booking_date);
ALTER TABLE work_assignments ADD INDEX idx_tech_date (technician_name, date_of_work);
ALTER TABLE invoices ADD INDEX idx_customer_status (customer_id, status);
ALTER TABLE feedback ADD INDEX idx_branch_rating (branch_id, rating);
ALTER TABLE whatsapp_messages ADD INDEX idx_phone_sent (customer_phone, sent_at);
ALTER TABLE notifications ADD INDEX idx_user_created (user_id, created_at);
ALTER TABLE inspections ADD INDEX idx_jobcard (job_card_id);
ALTER TABLE repair_orders ADD INDEX idx_jobcard (job_card_id);
ALTER TABLE technician_tasks ADD INDEX idx_jobcard_status (job_card_no, status);
ALTER TABLE approvals ADD INDEX idx_customer_estimate (customer_id, estimate_id);
