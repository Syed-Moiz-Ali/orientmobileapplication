-- ===================================================================
-- V13: PREFIXED UNIQUE REFS (owner decision 2026-08-07)
-- Every table gets a 'ref' column: PREFIX + short alphanumeric suffix
-- (CUST-3f9a2c1d), matching the app-generated refs (BK-, JC-, INV-...).
-- Existing rows are backfilled; NEW rows get the ref from the
-- MyBatis-Plus insertFill (MyBatisPlusConfig), which mirrors the same
-- IdGenerator.shortRef format. Column is NOT NULL + UNIQUE.
-- Tables with app-generated refs (booking_ref, job_card_ref, invoice_ref,
-- payment_ref, lead_number, ticket_ref, warranty_ref, po_ref, assignment_ref,
-- ar_ref, inspection_ref, repair_order_ref, reminder_ref, breakdown_ref, emp_id) untouched.
-- ===================================================================

-- users
ALTER TABLE users ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE users SET ref = CONCAT('USR-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE users MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE users ADD UNIQUE KEY uk_users_ref (ref);

-- customers
ALTER TABLE customers ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE customers SET ref = CONCAT('CUST-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE customers MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE customers ADD UNIQUE KEY uk_customers_ref (ref);

-- vehicles
ALTER TABLE vehicles ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE vehicles SET ref = CONCAT('VEH-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE vehicles MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE vehicles ADD UNIQUE KEY uk_vehicles_ref (ref);

-- service_types
ALTER TABLE service_types ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE service_types SET ref = CONCAT('ST-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE service_types MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE service_types ADD UNIQUE KEY uk_service_types_ref (ref);

-- notifications
ALTER TABLE notifications ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE notifications SET ref = CONCAT('NTF-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE notifications MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE notifications ADD UNIQUE KEY uk_notifications_ref (ref);

-- messages
ALTER TABLE messages ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE messages SET ref = CONCAT('MSG-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE messages MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE messages ADD UNIQUE KEY uk_messages_ref (ref);

-- whatsapp_messages
ALTER TABLE whatsapp_messages ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE whatsapp_messages SET ref = CONCAT('WM-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE whatsapp_messages MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE whatsapp_messages ADD UNIQUE KEY uk_whatsapp_messages_ref (ref);

-- approvals
ALTER TABLE approvals ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE approvals SET ref = CONCAT('APP-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE approvals MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE approvals ADD UNIQUE KEY uk_approvals_ref (ref);

-- repair_order_services
ALTER TABLE repair_order_services ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE repair_order_services SET ref = CONCAT('ROS-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE repair_order_services MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE repair_order_services ADD UNIQUE KEY uk_repair_order_services_ref (ref);

-- repair_order_parts
ALTER TABLE repair_order_parts ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE repair_order_parts SET ref = CONCAT('ROP-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE repair_order_parts MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE repair_order_parts ADD UNIQUE KEY uk_repair_order_parts_ref (ref);

-- attendance
ALTER TABLE attendance ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE attendance SET ref = CONCAT('AT-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE attendance MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE attendance ADD UNIQUE KEY uk_attendance_ref (ref);

-- activity_log
ALTER TABLE activity_log ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE activity_log SET ref = CONCAT('AL-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE activity_log MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE activity_log ADD UNIQUE KEY uk_activity_log_ref (ref);

-- employee_documents
ALTER TABLE employee_documents ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE employee_documents SET ref = CONCAT('DOC-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE employee_documents MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE employee_documents ADD UNIQUE KEY uk_employee_documents_ref (ref);

-- crm_conversations
ALTER TABLE crm_conversations ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE crm_conversations SET ref = CONCAT('CV-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE crm_conversations MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE crm_conversations ADD UNIQUE KEY uk_crm_conversations_ref (ref);

-- crm_tasks
ALTER TABLE crm_tasks ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE crm_tasks SET ref = CONCAT('CT-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE crm_tasks MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE crm_tasks ADD UNIQUE KEY uk_crm_tasks_ref (ref);

-- crm_integrations
ALTER TABLE crm_integrations ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE crm_integrations SET ref = CONCAT('CI-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE crm_integrations MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE crm_integrations ADD UNIQUE KEY uk_crm_integrations_ref (ref);

-- lead_activities
ALTER TABLE lead_activities ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE lead_activities SET ref = CONCAT('LA-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE lead_activities MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE lead_activities ADD UNIQUE KEY uk_lead_activities_ref (ref);

-- branches
ALTER TABLE branches ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE branches SET ref = CONCAT('BR-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE branches MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE branches ADD UNIQUE KEY uk_branches_ref (ref);

-- departments
ALTER TABLE departments ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE departments SET ref = CONCAT('DEPT-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE departments MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE departments ADD UNIQUE KEY uk_departments_ref (ref);

-- suppliers
ALTER TABLE suppliers ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE suppliers SET ref = CONCAT('SUP-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE suppliers MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE suppliers ADD UNIQUE KEY uk_suppliers_ref (ref);

-- inventory_items
ALTER TABLE inventory_items ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE inventory_items SET ref = CONCAT('ITM-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE inventory_items MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE inventory_items ADD UNIQUE KEY uk_inventory_items_ref (ref);

-- purchase_order_items
ALTER TABLE purchase_order_items ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE purchase_order_items SET ref = CONCAT('POI-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE purchase_order_items MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE purchase_order_items ADD UNIQUE KEY uk_purchase_order_items_ref (ref);

-- feedback
ALTER TABLE feedback ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE feedback SET ref = CONCAT('FB-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE feedback MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE feedback ADD UNIQUE KEY uk_feedback_ref (ref);

-- device_tokens
ALTER TABLE device_tokens ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE device_tokens SET ref = CONCAT('DT-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE device_tokens MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE device_tokens ADD UNIQUE KEY uk_device_tokens_ref (ref);

-- webhook_subscriptions
ALTER TABLE webhook_subscriptions ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE webhook_subscriptions SET ref = CONCAT('WH-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE webhook_subscriptions MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE webhook_subscriptions ADD UNIQUE KEY uk_webhook_subscriptions_ref (ref);

-- api_keys
ALTER TABLE api_keys ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE api_keys SET ref = CONCAT('KEY-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE api_keys MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE api_keys ADD UNIQUE KEY uk_api_keys_ref (ref);

-- subscriptions
ALTER TABLE subscriptions ADD COLUMN ref VARCHAR(32) DEFAULT NULL;
UPDATE subscriptions SET ref = CONCAT('SUB-', SUBSTRING(MD5(CONCAT(id, RAND())), 1, 6)) WHERE ref IS NULL;
ALTER TABLE subscriptions MODIFY ref VARCHAR(32) NOT NULL;
ALTER TABLE subscriptions ADD UNIQUE KEY uk_subscriptions_ref (ref);

