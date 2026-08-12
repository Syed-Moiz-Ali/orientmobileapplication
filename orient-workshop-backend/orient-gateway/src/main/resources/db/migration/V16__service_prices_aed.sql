-- FIX (audit QA BUG-019): service_types were seeded with GBP prices ("From £65")
-- while the product is UAE (Dubai branch, +971 phones, Asia/Dubai timezone, AED
-- everywhere in the backend). Re-seed prices in AED. 'General Repair' stays POA.
UPDATE service_types SET price = 'From AED 65'    WHERE name = 'Oil Change';
UPDATE service_types SET price = 'From AED 55'    WHERE name = 'Tyre Rotation';
UPDATE service_types SET price = 'From AED 120'   WHERE name = 'Full Inspection';
UPDATE service_types SET price = 'From AED 54.85' WHERE name = 'MOT Test';
UPDATE service_types SET price = 'From AED 280'   WHERE name = 'Full Service';
