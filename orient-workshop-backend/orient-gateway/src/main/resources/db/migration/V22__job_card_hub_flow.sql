ALTER TABLE job_cards
    MODIFY COLUMN status ENUM('inProgress','pendingApproval','qualityCheck','completed',
                              'cancelled','waitingParts','pending','awaitingSupervisor',
                              'vehicleReceived','inspected','approved','workAssigned',
                              'waitingCustomerApproval','delivered','qualityCheckPassed')
    DEFAULT 'pending';

ALTER TABLE technician_tasks
    ADD COLUMN estimated_hours DECIMAL(8,2) NULL AFTER rate;
