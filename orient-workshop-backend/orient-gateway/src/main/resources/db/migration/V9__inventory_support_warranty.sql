-- ===================================================================
-- V9: P2 features (2026-08-06).
--   1. leads.external_id unique (Meta sync produced duplicates)
--   2. inventory_items + suppliers + purchase_orders + purchase_order_items
--      (inventory module — the biggest missing enterprise capability)
--   3. support_tickets (customer support inbox)
--   4. warranty tracking (vehicles) — light
-- ===================================================================

-- ---------- 1. LEADS: UNIQUE EXTERNAL ID ----------
-- Clear duplicates first (keep the newest), then enforce uniqueness so
-- concurrent Meta syncs cannot insert the same lead twice.
DELETE l1 FROM leads l1
INNER JOIN leads l2
  ON l1.external_id = l2.external_id
 AND l1.external_id <> ''
 AND l1.id < l2.id;
ALTER TABLE leads ADD UNIQUE INDEX uk_leads_external (external_id);

-- ---------- 2. INVENTORY ----------
CREATE TABLE IF NOT EXISTS suppliers (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    contact_name  VARCHAR(100) DEFAULT '',
    phone         VARCHAR(20) DEFAULT '',
    email         VARCHAR(100) DEFAULT '',
    address       VARCHAR(255) DEFAULT '',
    is_active     BOOLEAN NOT NULL DEFAULT TRUE,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS inventory_items (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    sku            VARCHAR(50) NOT NULL,
    name           VARCHAR(150) NOT NULL,
    category       VARCHAR(50) DEFAULT '',
    branch_id      BIGINT NULL,
    cost_price     DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    selling_price  DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    qty_on_hand    INT NOT NULL DEFAULT 0,
    reorder_level  INT NOT NULL DEFAULT 5,
    supplier_id    BIGINT NULL,
    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_sku (sku, branch_id),
    CONSTRAINT chk_stock_qty CHECK (qty_on_hand >= 0),
    CONSTRAINT chk_reorder CHECK (reorder_level >= 0),
    CONSTRAINT fk_inv_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    INDEX idx_branch (branch_id),
    INDEX idx_name (name)
);

CREATE TABLE IF NOT EXISTS purchase_orders (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    po_ref        VARCHAR(50) NOT NULL UNIQUE,
    supplier_id   BIGINT NULL,
    branch_id     BIGINT NULL,
    status        ENUM('draft','ordered','received','cancelled') DEFAULT 'draft',
    total         DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    ordered_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    received_at   DATETIME NULL,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_po_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);

CREATE TABLE IF NOT EXISTS purchase_order_items (
    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    purchase_order_id BIGINT NOT NULL,
    inventory_item_id BIGINT NULL,
    item_name        VARCHAR(150) DEFAULT '',
    qty              INT NOT NULL DEFAULT 1,
    unit_cost        DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_poi_po FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id) ON DELETE CASCADE,
    CONSTRAINT fk_poi_item FOREIGN KEY (inventory_item_id) REFERENCES inventory_items(id),
    INDEX idx_po (purchase_order_id)
);

-- ---------- 3. SUPPORT TICKETS ----------
CREATE TABLE IF NOT EXISTS support_tickets (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    ticket_ref     VARCHAR(50) NOT NULL UNIQUE,
    customer_id    BIGINT NULL,
    branch_id      BIGINT NULL,
    subject        VARCHAR(150) NOT NULL,
    description    TEXT,
    priority       ENUM('low','medium','high','urgent') DEFAULT 'medium',
    status         ENUM('open','in_progress','resolved','closed') DEFAULT 'open',
    assigned_staff_id BIGINT NULL,
    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_ticket_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
    CONSTRAINT fk_ticket_staff FOREIGN KEY (assigned_staff_id) REFERENCES staff(id),
    INDEX idx_status (status),
    INDEX idx_customer (customer_id)
);

-- ---------- 4. WARRANTY ----------
CREATE TABLE IF NOT EXISTS warranties (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id    BIGINT NOT NULL,
    warranty_ref  VARCHAR(50) NOT NULL UNIQUE,
    type          VARCHAR(30) DEFAULT 'manufacturer',
    start_date    DATE,
    end_date      DATE,
    terms         TEXT,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_warranty_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    INDEX idx_vehicle (vehicle_id)
);
