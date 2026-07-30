-- H2 schema for development (MySQL compatibility mode)

CREATE TABLE IF NOT EXISTS users (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    phone         VARCHAR(20) DEFAULT NULL UNIQUE,
    email         VARCHAR(100) DEFAULT NULL UNIQUE,
    password_hash VARCHAR(255) DEFAULT '',
    name          VARCHAR(100) DEFAULT '',
    role          VARCHAR(20) NOT NULL DEFAULT 'customer',
    is_active     BOOLEAN DEFAULT TRUE,
    avatar_url    VARCHAR(500) DEFAULT '',
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS otp_records (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    phone         VARCHAR(20) DEFAULT NULL,
    email         VARCHAR(100) DEFAULT NULL,
    otp_code      VARCHAR(6) NOT NULL,
    attempts      INT DEFAULT 0,
    expires_at    TIMESTAMP NOT NULL,
    used          BOOLEAN DEFAULT FALSE,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS refresh_tokens (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id       BIGINT NOT NULL,
    token         VARCHAR(500) NOT NULL UNIQUE,
    expires_at    TIMESTAMP NOT NULL,
    revoked       BOOLEAN DEFAULT FALSE,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS customers (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id         BIGINT,
    is_b2b          BOOLEAN DEFAULT FALSE,
    customer_name   VARCHAR(100) DEFAULT '',
    phone_number    VARCHAR(20) DEFAULT '',
    email           VARCHAR(100) DEFAULT '',
    customer_group  VARCHAR(50) DEFAULT '',
    tags            TEXT,
    gender          VARCHAR(10) DEFAULT '',
    address         TEXT,
    tax_number      VARCHAR(50) DEFAULT '',
    group_tax_number VARCHAR(50) DEFAULT '',
    occupation      VARCHAR(100) DEFAULT '',
    organisation    VARCHAR(100) DEFAULT '',
    source          VARCHAR(50) DEFAULT '',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS vehicles (
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
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE IF NOT EXISTS service_types (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    price       VARCHAR(50) DEFAULT '',
    duration    VARCHAR(20) DEFAULT '',
    is_active   BOOLEAN DEFAULT TRUE,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bookings (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_ref   VARCHAR(50) NOT NULL UNIQUE,
    customer_id   BIGINT NOT NULL,
    vehicle_id    BIGINT NOT NULL,
    vehicle_name  VARCHAR(100) DEFAULT '',
    plate_number  VARCHAR(20) DEFAULT '',
    service_type  VARCHAR(100) DEFAULT '',
    booking_date  TIMESTAMP NOT NULL,
    notes         TEXT,
    status        VARCHAR(20) DEFAULT 'pending',
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
);

CREATE TABLE IF NOT EXISTS breakdowns (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    breakdown_ref VARCHAR(50) NOT NULL UNIQUE,
    customer_id   BIGINT NOT NULL,
    issue         TEXT NOT NULL,
    vehicle_id    BIGINT,
    vehicle_name  VARCHAR(100) DEFAULT '',
    vehicle_plate VARCHAR(20) DEFAULT '',
    location      TEXT,
    status        VARCHAR(20) DEFAULT 'pending',
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE IF NOT EXISTS notifications (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id       BIGINT NOT NULL,
    title         VARCHAR(200) NOT NULL,
    body          TEXT,
    type          VARCHAR(30) DEFAULT 'carReady',
    is_read       BOOLEAN DEFAULT FALSE,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS job_cards (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    job_card_ref    VARCHAR(50) NOT NULL UNIQUE,
    customer_id     BIGINT NOT NULL,
    vehicle_id      BIGINT,
    status          VARCHAR(20) DEFAULT 'pending',
    technician      VARCHAR(100) DEFAULT '',
    created_date    TIMESTAMP,
    last_updated    TIMESTAMP,
    notes           TEXT,
    tag             VARCHAR(50) DEFAULT '',
    customer_requests TEXT,
    garage_recommendations TEXT,
    estimated_delivery TIMESTAMP,
    notify_owner_sms_email BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
);

CREATE TABLE IF NOT EXISTS inspections (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    inspection_ref  VARCHAR(50) NOT NULL UNIQUE,
    job_card_id     BIGINT,
    reference_number VARCHAR(50) DEFAULT '',
    place_of_supply VARCHAR(100) DEFAULT '',
    customer_requests TEXT,
    garage_recommendations TEXT,
    estimated_delivery TIMESTAMP,
    notify_owner_sms_email BOOLEAN DEFAULT FALSE,
    tag             VARCHAR(50) DEFAULT '',
    is_draft        BOOLEAN DEFAULT FALSE,
    sections        TEXT,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (job_card_id) REFERENCES job_cards(id)
);

CREATE TABLE IF NOT EXISTS repair_orders (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    repair_order_ref VARCHAR(50) NOT NULL UNIQUE,
    job_card_id     BIGINT NOT NULL,
    services_total  DECIMAL(12,2) DEFAULT 0.00,
    parts_total     DECIMAL(12,2) DEFAULT 0.00,
    grand_total     DECIMAL(12,2) DEFAULT 0.00,
    tag             VARCHAR(50) DEFAULT '',
    customer_requests TEXT,
    garage_recommendations TEXT,
    estimated_delivery TIMESTAMP,
    notify_owner_sms_email BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (job_card_id) REFERENCES job_cards(id)
);

CREATE TABLE IF NOT EXISTS repair_order_services (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    repair_order_id BIGINT NOT NULL,
    name            VARCHAR(100) NOT NULL,
    qty             INT DEFAULT 1,
    rate            DECIMAL(12,2) DEFAULT 0.00,
    discount_percent DECIMAL(5,2) DEFAULT 0.00,
    discount_amount DECIMAL(12,2) DEFAULT 0.00,
    FOREIGN KEY (repair_order_id) REFERENCES repair_orders(id)
);

CREATE TABLE IF NOT EXISTS repair_order_parts (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    repair_order_id BIGINT NOT NULL,
    name            VARCHAR(100) NOT NULL,
    qty             INT DEFAULT 1,
    rate            DECIMAL(12,2) DEFAULT 0.00,
    discount_percent DECIMAL(5,2) DEFAULT 0.00,
    discount_amount DECIMAL(12,2) DEFAULT 0.00,
    FOREIGN KEY (repair_order_id) REFERENCES repair_orders(id)
);

CREATE TABLE IF NOT EXISTS predefined_services (
    id    BIGINT AUTO_INCREMENT PRIMARY KEY,
    name  VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS predefined_parts (
    id    BIGINT AUTO_INCREMENT PRIMARY KEY,
    name  VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS approvals (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    estimate_id     VARCHAR(50) NOT NULL,
    customer_id     BIGINT NOT NULL,
    customer_name   VARCHAR(100) DEFAULT '',
    vehicle_id      VARCHAR(50) DEFAULT '',
    amount          DECIMAL(12,2) DEFAULT 0.00,
    action          VARCHAR(20) DEFAULT 'pending',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE IF NOT EXISTS reminders (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    reminder_ref    VARCHAR(50) NOT NULL UNIQUE,
    customer_name   VARCHAR(100) DEFAULT '',
    vehicle_id      VARCHAR(50) DEFAULT '',
    task            TEXT NOT NULL,
    due_date        VARCHAR(100) DEFAULT '',
    priority        VARCHAR(10) DEFAULT 'medium',
    is_completed    BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staff (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id         BIGINT,
    emp_id          VARCHAR(20) NOT NULL UNIQUE,
    name            VARCHAR(100) NOT NULL,
    role            VARCHAR(20) NOT NULL,
    branch          VARCHAR(100) DEFAULT '',
    shift           VARCHAR(100) DEFAULT '',
    designation     VARCHAR(100) DEFAULT '',
    department      VARCHAR(100) DEFAULT '',
    avatar_initials VARCHAR(5) DEFAULT '',
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS attendance (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    emp_id          VARCHAR(20) NOT NULL,
    date            DATE NOT NULL,
    status          VARCHAR(20) DEFAULT 'notPunchedIn',
    punch_in        VARCHAR(20) DEFAULT '',
    punch_out       VARCHAR(20) DEFAULT '',
    break_time      VARCHAR(20) DEFAULT '',
    work_hours      VARCHAR(20) DEFAULT '',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (emp_id) REFERENCES staff(emp_id)
);

CREATE TABLE IF NOT EXISTS technician_tasks (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    job_card_no     VARCHAR(50) NOT NULL,
    task_ref        VARCHAR(20) NOT NULL,
    description     TEXT NOT NULL,
    status          VARCHAR(20) DEFAULT 'pending',
    emp_id          VARCHAR(20) DEFAULT '',
    start_time      VARCHAR(20) DEFAULT '',
    end_time        VARCHAR(20) DEFAULT '',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS work_assignments (
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
    status          VARCHAR(20) DEFAULT 'Pending',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (job_card_id) REFERENCES job_cards(id)
);

CREATE TABLE IF NOT EXISTS departments (
    id      BIGINT AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS invoices (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    invoice_ref     VARCHAR(50) NOT NULL UNIQUE,
    customer_id     BIGINT NOT NULL,
    job_card_id     BIGINT,
    amount          DECIMAL(12,2) DEFAULT 0.00,
    status          VARCHAR(20) DEFAULT 'unpaid',
    due_date        DATE,
    issued_date     DATE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE IF NOT EXISTS accounts_receivable (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    ar_ref          VARCHAR(50) NOT NULL UNIQUE,
    customer_id     BIGINT NOT NULL,
    invoice_id      BIGINT,
    invoice_date    DATE,
    due_date        DATE,
    amount          DECIMAL(12,2) DEFAULT 0.00,
    outstanding     DECIMAL(12,2) DEFAULT 0.00,
    aging           VARCHAR(20) DEFAULT 'days0to30',
    contact_person  VARCHAR(100) DEFAULT '',
    phone           VARCHAR(20) DEFAULT '',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE IF NOT EXISTS messages (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    sender_id       BIGINT,
    recipient       VARCHAR(100) NOT NULL,
    recipient_id    BIGINT,
    message         TEXT NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS activity_log (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    type            VARCHAR(30) NOT NULL,
    title           VARCHAR(200) NOT NULL,
    description     TEXT,
    user_id         BIGINT,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS leads (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    lead_number     VARCHAR(50) NOT NULL UNIQUE,
    customer_name   VARCHAR(100) NOT NULL,
    phone           VARCHAR(20) DEFAULT '',
    email           VARCHAR(100) DEFAULT '',
    source          VARCHAR(50) DEFAULT '',
    assigned_to     VARCHAR(100) DEFAULT '',
    status          VARCHAR(20) DEFAULT 'ACTIVE',
    last_activity   VARCHAR(100) DEFAULT '',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS crm_conversations (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_name   VARCHAR(100) DEFAULT '',
    last_message    TEXT,
    time            VARCHAR(50) DEFAULT '',
    channel         VARCHAR(50) DEFAULT '',
    unread          INT DEFAULT 0,
    status          VARCHAR(20) DEFAULT 'active',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS crm_tasks (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    title           VARCHAR(200) NOT NULL,
    assigned_to     VARCHAR(100) DEFAULT '',
    due_date        VARCHAR(50) DEFAULT '',
    priority        VARCHAR(10) DEFAULT 'Medium',
    is_done         BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS crm_integrations (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL UNIQUE,
    connected       BOOLEAN DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS idempotency_keys (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    idempotency_key VARCHAR(100) NOT NULL UNIQUE,
    response_body   TEXT,
    http_status     INT DEFAULT 200,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS sync_logs (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    idempotency_key VARCHAR(100) DEFAULT '',
    endpoint        VARCHAR(200) NOT NULL,
    method          VARCHAR(10) NOT NULL,
    request_body    TEXT,
    status          VARCHAR(20) DEFAULT 'success',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS employee_documents (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    emp_id          VARCHAR(20) NOT NULL,
    employee_name   VARCHAR(100) DEFAULT '',
    designation     VARCHAR(100) DEFAULT '',
    document_type   VARCHAR(100) NOT NULL,
    expiry_date     DATE NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (emp_id) REFERENCES staff(emp_id)
);

-- Seed data
INSERT INTO service_types (name, price, duration) VALUES
('Oil Change', 'From £65', '~1 hr'),
('Tyre Rotation', 'From £55', '~45 min'),
('Full Inspection', 'From £120', '~2 hrs'),
('General Repair', 'POA', 'Varies'),
('MOT Test', 'From £54.85', '~1 hr'),
('Full Service', 'From £280', '~3 hrs');

INSERT INTO departments (name) VALUES
('Engine'), ('Body & Paint'), ('Electrical'), ('Tyres & Alignment'),
('AC & Cooling'), ('Transmission'), ('General Service');

INSERT INTO crm_integrations (name, connected) VALUES
('WhatsApp Business', TRUE),
('Instagram', TRUE),
('Google Ads', TRUE),
('Facebook', FALSE),
('Email (SMTP)', TRUE),
('SMS Gateway', FALSE);

-- =========== PHASE 10: BRANCHES ===========

CREATE TABLE IF NOT EXISTS branches (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    address     TEXT,
    phone       VARCHAR(20) DEFAULT '',
    email       VARCHAR(100) DEFAULT '',
    timezone    VARCHAR(50) DEFAULT 'Asia/Dubai',
    is_active   BOOLEAN DEFAULT TRUE,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO branches (name, address, phone, email) VALUES
('Main Branch - Dubai', 'Sheikh Zayed Rd, Dubai', '+97141234567', 'main@orientworkshop.com');

CREATE TABLE IF NOT EXISTS feedback (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    job_card_id   BIGINT,
    customer_id   BIGINT NOT NULL,
    branch_id     BIGINT,
    rating        TINYINT NOT NULL,
    comment       TEXT,
    is_public     BOOLEAN DEFAULT FALSE,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (job_card_id) REFERENCES job_cards(id),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (branch_id) REFERENCES branches(id)
);

CREATE TABLE IF NOT EXISTS whatsapp_messages (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    branch_id       BIGINT,
    customer_phone  VARCHAR(20) NOT NULL,
    template_name   VARCHAR(100) DEFAULT '',
    message_body    TEXT,
    status          VARCHAR(20) DEFAULT 'sent',
    message_type    VARCHAR(30) DEFAULT 'notification',
    external_id     VARCHAR(100) DEFAULT '',
    sent_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (branch_id) REFERENCES branches(id)
);

ALTER TABLE users ADD COLUMN IF NOT EXISTS branch_id BIGINT DEFAULT NULL;
ALTER TABLE staff ADD COLUMN IF NOT EXISTS branch_id BIGINT DEFAULT NULL;
ALTER TABLE job_cards ADD COLUMN IF NOT EXISTS branch_id BIGINT DEFAULT NULL;
ALTER TABLE customers ADD COLUMN IF NOT EXISTS branch_id BIGINT DEFAULT NULL;
ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS branch_id BIGINT DEFAULT NULL;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS branch_id BIGINT DEFAULT NULL;
ALTER TABLE invoices ADD COLUMN IF NOT EXISTS branch_id BIGINT DEFAULT NULL;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS branch_id BIGINT DEFAULT NULL;
ALTER TABLE work_assignments ADD COLUMN IF NOT EXISTS branch_id BIGINT DEFAULT NULL;
