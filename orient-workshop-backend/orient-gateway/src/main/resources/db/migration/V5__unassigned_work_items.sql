-- ===================================================================
-- V5: technician_tasks.emp_id is optional until the advisor assigns a
-- technician per item. The FK + DEFAULT '' rejected unassigned rows
-- (MyBatis skips null -> column DEFAULT '' -> FK lookup of '' fails).
-- ===================================================================

ALTER TABLE technician_tasks DROP FOREIGN KEY technician_tasks_ibfk_2;
ALTER TABLE technician_tasks MODIFY COLUMN emp_id VARCHAR(20) DEFAULT NULL;
