# Orient Workshop — Database Schema

Generated from the Flyway migrations (`orient-gateway/src/main/resources/db/migration/V1..V12`).
This is the ground truth the API entities map to — response models in the collection
are cross-checked against these tables.

**50 tables.**

## `accounts_receivable`
- `id` — BIGINT
- `ar_ref` — VARCHAR(50)
- `customer_id` — BIGINT
- `invoice_id` — BIGINT
- `invoice_date` — DATE
- `due_date` — DATE
- `amount` — DECIMAL(12,2)
- `outstanding` — DECIMAL(12,2)
- `aging` — ENUM('DAYS0TO30','DAYS31TO60','DAYS61TO90','DAYS90PLUS')
- `contact_person` — VARCHAR(100)
- `phone` — VARCHAR(20)
- `created_at` — DATETIME
- `updated_at` — DATETIME

## `activity_log`
- `id` — BIGINT
- `type` — ENUM('JOB_CARD','INSPECTION','APPROVAL','INVOICE','PARTS','PAYMENT','TECHNICIAN')
- `title` — VARCHAR(200)
- `description` — TEXT
- `user_id` — BIGINT
- `created_at` — DATETIME

## `api_keys`
- `id` — BIGINT
- `name` — VARCHAR(100)
- `role` — VARCHAR(30)
- `is_active` — BOOLEAN
- `created_by` — BIGINT
- `last_used_at` — DATETIME
- `created_at` — DATETIME

## `approvals`
- `id` — BIGINT
- `estimate_id` — VARCHAR(50)
- `customer_id` — BIGINT
- `customer_name` — VARCHAR(100)
- `vehicle_id` — VARCHAR(50)
- `amount` — DECIMAL(12,2)
- `action` — ENUM('PENDING','APPROVED','REJECTED')
- `created_at` — DATETIME
- `updated_at` — DATETIME

## `attendance`
- `id` — BIGINT
- `emp_id` — VARCHAR(20)
- `date` — DATE
- `status` — ENUM('NOTPUNCHEDIN','WORKING','ONBREAK','PUNCHEDOUT')
- `punch_in` — VARCHAR(20)
- `punch_out` — VARCHAR(20)
- `break_time` — VARCHAR(20)
- `work_hours` — VARCHAR(20)
- `created_at` — DATETIME
- `updated_at` — DATETIME

## `bookings`
- `id` — BIGINT
- `booking_ref` — VARCHAR(50)
- `customer_id` — BIGINT
- `vehicle_id` — BIGINT
- `vehicle_name` — VARCHAR(100)
- `plate_number` — VARCHAR(20)
- `service_type` — VARCHAR(100)
- `booking_date` — DATETIME
- `notes` — TEXT
- `status` — ENUM('CONFIRMED','COMPLETED','PENDING','CANCELLED')
- `created_at` — DATETIME
- `updated_at` — DATETIME

## `branches`
- `id` — BIGINT
- `name` — VARCHAR(100)
- `address` — TEXT
- `phone` — VARCHAR(20)
- `email` — VARCHAR(100)
- `timezone` — VARCHAR(50)
- `is_active` — BOOLEAN
- `created_at` — DATETIME
- `updated_at` — DATETIME

## `breakdowns`
- `id` — BIGINT
- `breakdown_ref` — VARCHAR(50)
- `customer_id` — BIGINT
- `issue` — TEXT
- `vehicle_id` — BIGINT
- `vehicle_name` — VARCHAR(100)
- `vehicle_plate` — VARCHAR(20)
- `location` — TEXT
- `status` — ENUM('PENDING','DISPATCHED','RESOLVED','CANCELLED')
- `created_at` — DATETIME
- `updated_at` — DATETIME

## `crm_conversations`
- `id` — BIGINT
- `customer_name` — VARCHAR(100)
- `last_message` — TEXT
- `time` — VARCHAR(50)
- `channel` — VARCHAR(50)
- `unread` — INT
- `status` — VARCHAR(20)
- `created_at` — DATETIME
- `updated_at` — DATETIME

## `crm_integrations`
- `id` — BIGINT
- `name` — VARCHAR(100)
- `connected` — BOOLEAN

## `crm_tasks`
- `id` — BIGINT
- `title` — VARCHAR(200)
- `assigned_to` — VARCHAR(100)
- `due_date` — VARCHAR(50)
- `priority` — ENUM('HIGH','MEDIUM','LOW')
- `is_done` — BOOLEAN
- `created_at` — DATETIME
- `updated_at` — DATETIME

## `customers`
- `id` — BIGINT
- `user_id` — BIGINT
- `is_b2b` — BOOLEAN
- `customer_name` — VARCHAR(100)
- `phone_number` — VARCHAR(20)
- `email` — VARCHAR(100)
- `customer_group` — VARCHAR(50)
- `tags` — JSON
- `gender` — VARCHAR(10)
- `address` — TEXT
- `tax_number` — VARCHAR(50)
- `group_tax_number` — VARCHAR(50)
- `occupation` — VARCHAR(100)
- `organisation` — VARCHAR(100)
- `source` — VARCHAR(50)
- `created_at` — DATETIME
- `updated_at` — DATETIME

## `departments`
- `id` — BIGINT
- `name` — VARCHAR(100)

## `device_tokens`
- `id` — BIGINT
- `user_id` — BIGINT
- `token` — VARCHAR(512)
- `platform` — VARCHAR(20)
- `created_at` — DATETIME
- `updated_at` — DATETIME

## `employee_documents`
- `id` — BIGINT
- `emp_id` — VARCHAR(20)
- `employee_name` — VARCHAR(100)
- `designation` — VARCHAR(100)
- `document_type` — VARCHAR(100)
- `expiry_date` — DATE
- `days_left` — INT
- `urgency` — VARCHAR(20)
- `created_at` — DATETIME
- `updated_at` — DATETIME

## `feedback`
- `id` — BIGINT
- `job_card_id` — BIGINT
- `customer_id` — BIGINT
- `branch_id` — BIGINT
- `rating` — TINYINT
- `comment` — TEXT
- `is_public` — BOOLEAN
- `created_at` — DATETIME

## `idempotency_keys`
- `id` — BIGINT
- `idempotency_key` — VARCHAR(100)
- `response_body` — JSON
- `http_status` — INT
- `created_at` — DATETIME

## `inspections`
- `id` — BIGINT
- `inspection_ref` — VARCHAR(50)
- `job_card_id` — BIGINT
- `reference_number` — VARCHAR(50)
- `place_of_supply` — VARCHAR(100)
- `customer_requests` — TEXT
- `garage_recommendations` — TEXT
- `estimated_delivery` — DATETIME
- `notify_owner_sms_email` — BOOLEAN
- `tag` — VARCHAR(50)
- `is_draft` — BOOLEAN
- `sections` — JSON
- `created_at` — DATETIME
- `updated_at` — DATETIME

## `inventory_items`
- `id` — BIGINT
- `sku` — VARCHAR(50)
- `name` — VARCHAR(150)
- `category` — VARCHAR(50)
- `branch_id` — BIGINT
- `cost_price` — DECIMAL(12,2)
- `selling_price` — DECIMAL(12,2)
- `qty_on_hand` — INT
- `reorder_level` — INT
- `supplier_id` — BIGINT
- `created_at` — DATETIME
- `updated_at` — DATETIME

## `invoices`
- `id` — BIGINT
- `invoice_ref` — VARCHAR(50)
- `customer_id` — BIGINT
- `job_card_id` — BIGINT
- `amount` — DECIMAL(12,2)
- `status` — ENUM('PAID','UNPAID','OVERDUE')
- `due_date` — DATE
- `issued_date` — DATE
- `created_at` — DATETIME
- `updated_at` — DATETIME

## `job_cards`
- `id` — BIGINT
- `job_card_ref` — VARCHAR(50)
- `customer_id` — BIGINT
- `vehicle_id` — BIGINT
- `status` — ENUM('INPROGRESS','PENDINGAPPROVAL','QUALITYCHECK','COMPLETED','CANCELLED','WAITINGPARTS','PENDING')
- `technician` — VARCHAR(100)
- `created_date` — DATETIME
- `last_updated` — DATETIME
- `notes` — TEXT
- `tag` — VARCHAR(50)
- `customer_requests` — TEXT
- `garage_recommendations` — TEXT
- `estimated_delivery` — DATETIME
- `notify_owner_sms_email` — BOOLEAN
- `created_at` — DATETIME
- `updated_at` — DATETIME

## `lead_activities`
- `id` — BIGINT
- `lead_id` — BIGINT
- `action` — VARCHAR(50)
- `detail` — TEXT
- `created_at` — DATETIME

## `leads`
- `id` — BIGINT
- `lead_number` — VARCHAR(50)
- `customer_name` — VARCHAR(100)
- `phone` — VARCHAR(20)
- `email` — VARCHAR(100)
- `source` — VARCHAR(50)
- `assigned_to` — VARCHAR(100)
- `status` — ENUM('ACTIVE','WON','UNANSWERED','LOST')
- `last_activity` — VARCHAR(100)
- `created_at` — DATETIME
- `updated_at` — DATETIME

## `messages`
- `id` — BIGINT
- `sender_id` — BIGINT
- `recipient` — VARCHAR(100)
- `recipient_id` — BIGINT
- `message` — TEXT
- `created_at` — DATETIME

## `notifications`
- `id` — BIGINT
- `user_id` — BIGINT
- `title` — VARCHAR(200)
- `body` — TEXT
- `type` — ENUM('CARREADY','BOOKINGCONFIRMED','INVOICEREADY','APPROVALNEEDED','WORKINPROGRESS','REMINDER')
- `is_read` — BOOLEAN
- `created_at` — DATETIME

## `otp_records`
- `id` — BIGINT
- `phone` — VARCHAR(20)
- `email` — VARCHAR(100)
- `otp_code` — VARCHAR(6)
- `attempts` — INT
- `expires_at` — DATETIME
- `used` — BOOLEAN
- `created_at` — DATETIME

## `payments`
- `id` — BIGINT
- `payment_ref` — VARCHAR(50)
- `invoice_id` — BIGINT
- `branch_id` — BIGINT
- `amount` — DECIMAL(12,2)
- `method` — VARCHAR(30)
- `reference` — VARCHAR(100)
- `paid_at` — DATETIME
- `recorded_by` — BIGINT
- `created_at` — DATETIME

## `predefined_parts`
- `id` — BIGINT
- `name` — VARCHAR(100)

## `predefined_services`
- `id` — BIGINT
- `name` — VARCHAR(100)

## `purchase_order_items`
- `id` — BIGINT
- `purchase_order_id` — BIGINT
- `inventory_item_id` — BIGINT
- `item_name` — VARCHAR(150)
- `qty` — INT
- `unit_cost` — DECIMAL(12,2)

## `purchase_orders`
- `id` — BIGINT
- `po_ref` — VARCHAR(50)
- `supplier_id` — BIGINT
- `branch_id` — BIGINT
- `status` — ENUM('DRAFT','ORDERED','RECEIVED','CANCELLED')
- `total` — DECIMAL(12,2)
- `ordered_at` — DATETIME
- `received_at` — DATETIME
- `created_at` — DATETIME

## `refresh_tokens`
- `id` — BIGINT
- `user_id` — BIGINT
- `token` — VARCHAR(500)
- `expires_at` — DATETIME
- `revoked` — BOOLEAN
- `created_at` — DATETIME

## `reminders`
- `id` — BIGINT
- `reminder_ref` — VARCHAR(50)
- `customer_name` — VARCHAR(100)
- `vehicle_id` — VARCHAR(50)
- `task` — TEXT
- `due_date` — VARCHAR(100)
- `priority` — ENUM('HIGH','MEDIUM','LOW')
- `is_completed` — BOOLEAN
- `created_at` — DATETIME
- `updated_at` — DATETIME

## `repair_order_parts`
- `id` — BIGINT
- `repair_order_id` — BIGINT
- `name` — VARCHAR(100)
- `qty` — INT
- `rate` — DECIMAL(12,2)
- `discount_percent` — DECIMAL(5,2)
- `discount_amount` — DECIMAL(12,2)

## `repair_order_services`
- `id` — BIGINT
- `repair_order_id` — BIGINT
- `name` — VARCHAR(100)
- `qty` — INT
- `rate` — DECIMAL(12,2)
- `discount_percent` — DECIMAL(5,2)
- `discount_amount` — DECIMAL(12,2)

## `repair_orders`
- `id` — BIGINT
- `repair_order_ref` — VARCHAR(50)
- `job_card_id` — BIGINT
- `services_total` — DECIMAL(12,2)
- `parts_total` — DECIMAL(12,2)
- `grand_total` — DECIMAL(12,2)
- `tag` — VARCHAR(50)
- `customer_requests` — TEXT
- `garage_recommendations` — TEXT
- `estimated_delivery` — DATETIME
- `notify_owner_sms_email` — BOOLEAN
- `created_at` — DATETIME
- `updated_at` — DATETIME

## `service_types`
- `id` — BIGINT
- `name` — VARCHAR(100)
- `price` — VARCHAR(50)
- `duration` — VARCHAR(20)
- `is_active` — BOOLEAN
- `created_at` — DATETIME

## `shedlock`
- `name` — VARCHAR(64)
- `lock_until` — TIMESTAMP(3)
- `locked_at` — TIMESTAMP(3)
- `locked_by` — VARCHAR(255)

## `staff`
- `id` — BIGINT
- `user_id` — BIGINT
- `emp_id` — VARCHAR(20)
- `name` — VARCHAR(100)
- `role` — ENUM('ADVISOR','TECHNICIAN','SUPERVISOR')
- `branch` — VARCHAR(100)
- `shift` — VARCHAR(100)
- `designation` — VARCHAR(100)
- `department` — VARCHAR(100)
- `avatar_initials` — VARCHAR(5)
- `is_active` — BOOLEAN
- `created_at` — DATETIME
- `updated_at` — DATETIME

## `subscriptions`
- `id` — BIGINT
- `branch_id` — BIGINT
- `plan` — VARCHAR(30)
- `status` — ENUM('ACTIVE','TRIAL','EXPIRED','CANCELLED')
- `started_at` — DATETIME
- `renews_at` — DATE
- `created_at` — DATETIME
- `updated_at` — DATETIME

## `suppliers`
- `id` — BIGINT
- `name` — VARCHAR(100)
- `contact_name` — VARCHAR(100)
- `phone` — VARCHAR(20)
- `email` — VARCHAR(100)
- `address` — VARCHAR(255)
- `is_active` — BOOLEAN
- `created_at` — DATETIME
- `updated_at` — DATETIME

## `support_tickets`
- `id` — BIGINT
- `ticket_ref` — VARCHAR(50)
- `customer_id` — BIGINT
- `branch_id` — BIGINT
- `subject` — VARCHAR(150)
- `description` — TEXT
- `priority` — ENUM('LOW','MEDIUM','HIGH','URGENT')
- `status` — ENUM('OPEN','IN_PROGRESS','RESOLVED','CLOSED')
- `assigned_staff_id` — BIGINT
- `created_at` — DATETIME
- `updated_at` — DATETIME

## `sync_logs`
- `id` — BIGINT
- `idempotency_key` — VARCHAR(100)
- `endpoint` — VARCHAR(200)
- `method` — VARCHAR(10)
- `request_body` — JSON
- `status` — ENUM('SUCCESS','CONFLICT','ERROR')
- `created_at` — DATETIME

## `technician_tasks`
- `id` — BIGINT
- `job_card_no` — VARCHAR(50)
- `task_ref` — VARCHAR(20)
- `description` — TEXT
- `status` — ENUM('PENDING','INPROGRESS','COMPLETED')
- `emp_id` — VARCHAR(20)
- `start_time` — VARCHAR(20)
- `end_time` — VARCHAR(20)
- `created_at` — DATETIME
- `updated_at` — DATETIME

## `users`
- `id` — BIGINT
- `phone` — VARCHAR(20)
- `email` — VARCHAR(100)
- `password_hash` — VARCHAR(255)
- `name` — VARCHAR(100)
- `role` — ENUM('OWNER','ADVISOR','TECHNICIAN','CUSTOMER','SUPERVISOR','CRMDASHBOARD')
- `is_active` — BOOLEAN
- `avatar_url` — VARCHAR(500)
- `created_at` — DATETIME
- `updated_at` — DATETIME

## `vehicles`
- `id` — BIGINT
- `customer_id` — BIGINT
- `registration_number` — VARCHAR(50)
- `vin` — VARCHAR(50)
- `make` — VARCHAR(50)
- `model` — VARCHAR(50)
- `model_year` — INT
- `purchase_date` — DATE
- `cylinders` — INT
- `engine_capacity` — VARCHAR(20)
- `vehicle_color` — VARCHAR(30)
- `engine_number` — VARCHAR(50)
- `insurance_provider` — VARCHAR(100)
- `insurance_tax_number` — VARCHAR(50)
- `insurance_address` — TEXT
- `policy_number` — VARCHAR(50)
- `insurance_expiry_date` — DATE
- `plate_number` — VARCHAR(20)
- `mileage` — VARCHAR(20)
- `last_service` — VARCHAR(20)
- `next_due` — VARCHAR(20)
- `health_score` — INT

## `warranties`
- `id` — BIGINT
- `vehicle_id` — BIGINT
- `warranty_ref` — VARCHAR(50)
- `type` — VARCHAR(30)
- `start_date` — DATE
- `end_date` — DATE
- `terms` — TEXT
- `created_at` — DATETIME

## `webhook_subscriptions`
- `id` — BIGINT
- `event_type` — VARCHAR(50)
- `url` — VARCHAR(500)
- `secret` — VARCHAR(100)
- `is_active` — BOOLEAN
- `created_at` — DATETIME

## `whatsapp_messages`
- `id` — BIGINT
- `branch_id` — BIGINT
- `customer_phone` — VARCHAR(20)
- `template_name` — VARCHAR(100)
- `message_body` — TEXT
- `status` — ENUM('SENT','DELIVERED','READ','FAILED')
- `message_type` — ENUM('NOTIFICATION','BOOKING_CONFIRM','CAR_READY','INVOICE','PROMOTION')
- `external_id` — VARCHAR(100)
- `sent_at` — DATETIME

## `work_assignments`
- `id` — BIGINT
- `assignment_ref` — VARCHAR(50)
- `job_card_id` — BIGINT
- `description` — TEXT
- `department` — VARCHAR(100)
- `technician_name` — VARCHAR(100)
- `date_of_work` — DATE
- `status_percent` — INT
- `std_time` — VARCHAR(20)
- `remarks` — TEXT
- `status` — ENUM('PENDING','IN PROGRESS','COMPLETED')
- `created_at` — DATETIME
- `updated_at` — DATETIME
