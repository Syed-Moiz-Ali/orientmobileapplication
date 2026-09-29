CREATE TABLE inspection_templates (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description VARCHAR(500) DEFAULT '',
    estimated_minutes INT DEFAULT 15,
    is_default BOOLEAN DEFAULT FALSE,
    active BOOLEAN DEFAULT TRUE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE inspection_template_sections (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    template_id BIGINT NOT NULL,
    section_key VARCHAR(100) NOT NULL,
    label VARCHAR(150) NOT NULL,
    display_order INT DEFAULT 0,
    CONSTRAINT fk_inspection_template_section
        FOREIGN KEY (template_id) REFERENCES inspection_templates(id) ON DELETE CASCADE,
    UNIQUE KEY uk_template_section_key (template_id, section_key)
);

CREATE TABLE inspection_template_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    section_id BIGINT NOT NULL,
    label VARCHAR(255) NOT NULL,
    display_order INT DEFAULT 0,
    active BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_inspection_template_item
        FOREIGN KEY (section_id) REFERENCES inspection_template_sections(id) ON DELETE CASCADE
);

INSERT INTO inspection_templates
    (name, description, estimated_minutes, is_default, active, display_order)
VALUES
    ('Comprehensive Vehicle Health Check',
     'Standard workshop inspection covering exterior, under-vehicle, under-hood and battery checks.',
     15, TRUE, TRUE, 1);

SET @inspection_template_id = LAST_INSERT_ID();

INSERT INTO inspection_template_sections (template_id, section_key, label, display_order)
VALUES (@inspection_template_id, 'interior_exterior', '01. INTERIOR/EXTERIOR', 1);
SET @inspection_section_id = LAST_INSERT_ID();
INSERT INTO inspection_template_items (section_id, label, display_order) VALUES
(@inspection_section_id, 'Head Light / Tail Light / Turn Signals', 1),
(@inspection_section_id, 'Wiper Blade', 2),
(@inspection_section_id, 'Mirror', 3),
(@inspection_section_id, 'Emergency Brake Adjustment', 4),
(@inspection_section_id, 'Horn Operation', 5),
(@inspection_section_id, 'Fuel Tank Cap Gasket', 6),
(@inspection_section_id, 'A/C Filter', 7),
(@inspection_section_id, 'Seat Belts', 8),
(@inspection_section_id, 'Dashboard Lights', 9),
(@inspection_section_id, 'Clutch Operation', 10);

INSERT INTO inspection_template_sections (template_id, section_key, label, display_order)
VALUES (@inspection_template_id, 'under_vehicle', '02. UNDER VEHICLE', 2);
SET @inspection_section_id = LAST_INSERT_ID();
INSERT INTO inspection_template_items (section_id, label, display_order) VALUES
(@inspection_section_id, 'Shock Absorbers / Suspension', 1),
(@inspection_section_id, 'Steering Gear Box', 2),
(@inspection_section_id, 'Exhaust Pipes', 3),
(@inspection_section_id, 'Engine Oil / Fluid Leaks', 4),
(@inspection_section_id, 'Brake Lines', 5),
(@inspection_section_id, 'U-Joints', 6),
(@inspection_section_id, 'Fuel Lines', 7),
(@inspection_section_id, 'Inspect Nuts and Bolts on Body Chassis', 8);

INSERT INTO inspection_template_sections (template_id, section_key, label, display_order)
VALUES (@inspection_template_id, 'under_hood', '03. UNDER HOOD', 3);
SET @inspection_section_id = LAST_INSERT_ID();
INSERT INTO inspection_template_items (section_id, label, display_order) VALUES
(@inspection_section_id, 'Fluid Level: Oil / Battery / Power Steering', 1),
(@inspection_section_id, 'Engine Air Filter', 2),
(@inspection_section_id, 'Drive Belts', 3),
(@inspection_section_id, 'Engine Coolant Protection', 4),
(@inspection_section_id, 'Cooling System Hoses / Heater Hoses', 5),
(@inspection_section_id, 'Radiator Core', 6);

INSERT INTO inspection_template_sections (template_id, section_key, label, display_order)
VALUES (@inspection_template_id, 'battery', '04. BATTERY PERFORMANCE', 4);
SET @inspection_section_id = LAST_INSERT_ID();
INSERT INTO inspection_template_items (section_id, label, display_order) VALUES
(@inspection_section_id, 'Battery Terminal / Cables / Mounting', 1),
(@inspection_section_id, 'Storage Capacity Test', 2);
