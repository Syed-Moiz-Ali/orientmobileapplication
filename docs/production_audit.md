# Production Audit

## P0-01 Idempotency Architecture

- Issue ID: P0-01
- Severity: P0
- Status: VERIFIED
- Affected files:
  - `packages/shared_core/lib/src/local/helpers/id_generator.dart`
  - `packages/shared_core/test/id_generator_test.dart`
  - `orient-workshop-backend/orient-sync/src/main/java/com/orient/workshop/sync/filter/IdempotencyFilter.java`
  - `orient-workshop-backend/orient-sync/src/main/java/com/orient/workshop/sync/service/IdempotencyScope.java`
  - `orient-workshop-backend/orient-sync/src/test/java/com/orient/workshop/sync/service/IdempotencyScopeTest.java`
- Root cause: Flutter generated device-local date/counter IDs and backend idempotency keyed only on the raw `Idempotency-Key`, allowing cross-user and cross-endpoint collisions.
- Solution: Flutter now generates prefixed UUID v4 IDs. Backend idempotency hashes user, branch, method, normalized endpoint, and idempotency key before storage/replay.
- Tests added:
  - `IdempotencyScopeTest` covers same scope replay identity, different users, different endpoints, and different branches.
  - `SyncApplicationServiceConcurrencyTest` covers concurrent retry serialization for the same scoped key.
  - `id_generator_test.dart` now verifies UUID v4 shape and non-counter behavior.
- Verification result:
  - `flutter test test/id_generator_test.dart` from `packages/shared_core`: passed.
  - `.\mvnw -pl orient-sync -am test`: passed.
  - `.\mvnw test`: passed; gateway Docker/Testcontainers checks were skipped by the existing test when Docker was unavailable.

## P0-02 Sync False Success

- Issue ID: P0-02
- Severity: P0
- Status: VERIFIED
- Affected files:
  - `orient-workshop-backend/orient-sync/src/main/java/com/orient/workshop/sync/controller/SyncController.java`
  - `orient-workshop-backend/orient-sync/src/main/java/com/orient/workshop/sync/service/SyncApplicationService.java`
- Root cause: Sync mutation methods caught exceptions, logged warnings, and still returned HTTP success, causing Flutter to drop queued operations after failed business mutations.
- Solution: Business mutations now throw typed exceptions (`BadRequestException`, `ForbiddenException`, `NotFoundException`) and no longer swallow failures.
- Tests added: covered by compile path and focused sync/idempotency tests; deeper rollback integration tests remain TODO.
- Verification result:
  - `.\mvnw -pl orient-sync -am test`: passed.
  - `.\mvnw test`: passed with Docker-dependent gateway tests skipped.

## P0-03 Sync Transaction Boundaries

- Issue ID: P0-03
- Severity: P0
- Status: VERIFIED
- Affected files:
  - `orient-workshop-backend/orient-sync/src/main/java/com/orient/workshop/sync/controller/SyncController.java`
  - `orient-workshop-backend/orient-sync/src/main/java/com/orient/workshop/sync/service/SyncApplicationService.java`
- Root cause: `@Transactional` was applied to controller methods called internally from the same bean, bypassing Spring's transactional proxy.
- Solution: `SyncController` now only accepts requests and delegates to `SyncApplicationService`, where public transactional methods perform log recording and business mutations in one transaction.
- Tests added: compile/regression test coverage for affected module; DB rollback integration tests remain TODO.
- Verification result:
  - `.\mvnw -pl orient-sync -am test`: passed.

## P0-04 Sync Authorization

- Issue ID: P0-04
- Severity: P0
- Status: VERIFIED
- Affected files:
  - `orient-workshop-backend/orient-auth/src/main/java/com/orient/workshop/auth/config/SecurityConfig.java`
  - `orient-workshop-backend/orient-auth/src/test/java/com/orient/workshop/auth/config/SecurityMatrixTest.java`
  - `orient-workshop-backend/orient-sync/src/main/java/com/orient/workshop/sync/service/SyncApplicationService.java`
- Root cause: A broad `/sync/**` rule allowed all staff roles, including technicians, to hit advisor/supervisor sync mutation paths.
- Solution: `/sync/inspections/**`, `/sync/repair-orders/**`, `/sync/bookings`, `/sync/jobs/complete/**`, and `/sync/work-assignments` now have endpoint-specific RBAC. Sync service also validates branch scope for job cards/bookings where data is available.
- Tests added: Security matrix tests for technician inspection denial, technician job-complete allow, advisor job-complete denial, advisor sync allow-list, and advisor work-assignment denial.
- Verification result:
  - `.\mvnw -pl orient-auth -Dtest=SecurityMatrixTest test`: passed.
  - `.\mvnw test`: passed with Docker-dependent gateway tests skipped.

## P0-05 Branch / Tenant Isolation

- Issue ID: P0-05
- Severity: P0
- Status: IN_PROGRESS
- Affected files:
  - `orient-workshop-backend/orient-sync/src/main/java/com/orient/workshop/sync/service/SyncApplicationService.java`
  - `orient-workshop-backend/orient-core/src/main/java/com/orient/workshop/core/repository/BookingMapper.java`
  - `orient-workshop-backend/orient-core/src/main/java/com/orient/workshop/core/repository/BreakdownMapper.java`
  - `orient-workshop-backend/orient-core/src/main/java/com/orient/workshop/core/repository/JobCardMapper.java`
  - `orient-workshop-backend/orient-supervisor/src/main/java/com/orient/workshop/supervisor/controller/SupervisorDashboardController.java`
  - `orient-workshop-backend/orient-supervisor/src/main/java/com/orient/workshop/supervisor/controller/SupervisorQueueController.java`
  - `orient-workshop-backend/orient-supervisor/src/main/java/com/orient/workshop/supervisor/service/SupervisorKpiService.java`
  - `orient-workshop-backend/orient-supervisor/src/main/java/com/orient/workshop/supervisor/service/SupervisorQueueService.java`
  - `orient-workshop-backend/orient-supervisor/src/main/java/com/orient/workshop/supervisor/repository/SupervisorStatsMapper.java`
- Root cause: Several sync mutations trusted payload IDs and did not consistently compare entities against the authenticated branch.
- Solution: Initial sync service branch checks were added for job cards and linked bookings. Supervisor queue/KPI endpoints now receive the authenticated principal, branch-scope queue reads, branch-scope KPI/revenue/pending metrics, and fail closed on cross-branch supervisor mutations.
- Tests added:
  - `SupervisorQueueServiceBranchIsolationTest` covers assigning an advisor from another branch and assigning a booking from another branch.
- Verification result:
  - `.\mvnw -pl orient-supervisor -am test`: passed.
  - `.\mvnw test`: passed with Docker-dependent gateway tests skipped.
  - Repository-wide branch isolation remains IN_PROGRESS for advisor, technician, owner, CRM, media, and remaining customer APIs.

## WF-P0-01 Authoritative Job Workflow

- Issue ID: WF-P0-01
- Severity: P0
- Status: IN_PROGRESS
- Affected files:
  - `orient-workshop-backend/orient-core/src/main/java/com/orient/workshop/core/service/JobWorkflowService.java`
  - `orient-workshop-backend/orient-core/src/main/java/com/orient/workshop/core/service/JobInvoiceGateway.java`
  - `orient-workshop-backend/orient-core/src/main/java/com/orient/workshop/core/service/WorkItemService.java`
  - `orient-workshop-backend/orient-owner/src/main/java/com/orient/workshop/owner/service/InvoiceService.java`
  - `orient-workshop-backend/orient-supervisor/src/main/java/com/orient/workshop/supervisor/service/SupervisorQueueService.java`
  - `orient-workshop-backend/orient-advisor/src/main/java/com/orient/workshop/advisor/service/JobCardService.java`
  - `orient-workshop-backend/orient-owner/src/main/java/com/orient/workshop/owner/service/OwnerJobCardService.java`
  - `orient-workshop-backend/orient-technician/src/main/java/com/orient/workshop/technician/service/TechnicianJobService.java`
- Root cause: Job card status transitions were split across supervisor QC, advisor delivery/raw status, owner raw status, technician parent-job status, and work-item completion paths.
- Solution: Added core `JobWorkflowService` as the authoritative transition service for submit-for-QC, QC approve/reject, delivery, owner cancel, and guarded advisor operational status updates. Invoice generation now plugs into workflow through `JobInvoiceGateway`. Technician parent-job completion is blocked; technicians complete work items and the workflow submits the job for QC when all items are complete.
- Tests added:
  - `JobWorkflowServiceTest` verifies QC approval requires all work complete, successful QC approval moves to ready-for-collection and creates an invoice, and delivery cannot bypass QC approval.
- Verification result:
  - `.\mvnw -pl orient-core test`: passed.
  - `.\mvnw -pl orient-supervisor,orient-advisor,orient-technician,orient-owner -am test`: passed.
  - `.\mvnw test`: passed with Docker-dependent gateway tests skipped.
- Remaining work: The full `fix3.txt` workflow is not complete. Raw/bypass paths still need deeper removal across sync/customer/advisor repair-order approval, booking/check-in, breakdown, CRM, Flutter provider refresh, and cross-app E2E coverage.

## Blocked / Remaining

- Docker/Testcontainers: `.\mvnw test` attempted gateway integration tests, but the existing tests skipped after Testcontainers could not find a valid Docker environment. A running Docker Desktop/Testcontainers-compatible environment is required for those checks.
- Remaining workflow items from `fix3.txt` plus P1/P2 items from `fix.txt` are TODO and not yet production-ready: full customer-to-invoice E2E, booking concurrency, approval/revision handoff, delivery/payment/CRM decisions, logout/session isolation, pending media, dead-letter queue, Flutter route guards, CI release gates, signing, environment hardening, Melos consistency, broader Flutter/backend/E2E coverage, performance, accessibility, and observability.
