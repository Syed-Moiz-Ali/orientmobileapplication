# 00 — Verified Phase Dependencies & Execution DAG (21 Phases)

**Document ID:** `phases/redesign_v2/00_PHASE_DEPENDENCIES.md`  
**Total Implementation Phases:** Exactly **21 Sequentially Gated Units** (Right-sized for manageable Codex execution)  
**Execution Model:** Strict DAG (Directed Acyclic Graph)  
**Status:** BINDING EXECUTION DEPENDENCY PIPELINE  

---

## 1. High-Level Dependency Graph (DAG)

```text
                                [PHASE 01: Concept A Tokens (shared_core)]
                                                    │
                                                    ▼
                                [PHASE 02: Shared Primitives (shared_core)]
                                                    │
                          ┌─────────────────────────┴─────────────────────────┐
                          ▼                                                   ▼
           [PHASE 03: Data Components]                         [PHASE 04: Navigation Shells]
             (Tables, Pods, HUD)                                   (AppBars, Rails, Docks)
                          │                                                   │
                          ├─────────────────────────┬─────────────────────────┤
                          │                         ▼                         │
                          │             [PHASE 05: Shared Auth]               │
                          │                         │                         │
                          ▼                         ▼                         ▼
              [PHASE 06: Advisor Radar] ──► [PHASE 07: Intake Studio]         │
                          │                         │                         │
                          ▼                         ▼                         │
              [PHASE 08: Inspection HUD] ─► [PHASE 09: Repair Order Studio]   │
                          │                                                   │
                          ▼                                                   │
              [PHASE 10: Tech Console]                                        │
                          │                                                   │
                          ▼                                                   │
              [PHASE 11: Supervisor Bay]                                      │
                          │                                                   │
                          ▼                                                   │
              [PHASE 12: Staff Common]                                        │
                          │                                                   │
                          ├───────────────────────────────────────────────────┤
                          ▼                                                   ▼
              [PHASE 13: Owner Cockpit]                           [PHASE 16: Customer Garage]
                          │                                                   │
                          ▼                                                   ▼
              [PHASE 14: Owner Job Ops]                           [PHASE 17: Customer Booking]
                          │                                                   │
                          ▼                                                   ▼
              [PHASE 15: Owner Analytics]                         [PHASE 18: Customer Status]
                          │                                                   │
                          └─────────────────────────┬─────────────────────────┘
                                                    ▼
                                        [PHASE 19: CRM Deal Radar]
                                                    │
                                                    ▼
                                        [PHASE 20: CRM Comms & Reps]
                                                    │
                                                    ▼
                                        [PHASE 21: Final Monorepo Audit]
```

---

## 2. Phase-by-Phase Dependency Register

| Phase ID & Name | Required Prerequisites | Direct Downstream Dependents | Scope & Focus |
| :--- | :--- | :--- | :--- |
| **Phase 01: Tokens & Palette** | None (Concept A Approved) | Phase 02 | `shared_core`: `ConceptATokens`, colors, typography, dimensions. |
| **Phase 02: Shared Primitives** | Phase 01 | Phase 03, Phase 04 | `shared_core`: Buttons, inputs, form sections, pills, dialogs, sheets. |
| **Phase 03: Data Components** | Phase 02 | Phase 06, 13, 16, 19 | `shared_core`: `AppTable`, `TelemetryMetricPod`, `SpatialDamageHud`. |
| **Phase 04: Navigation Shells** | Phase 02 | Phase 05, 06, 13, 16, 19 | `shared_navigation`: AppBars, rails, bottom navigation, split scaffolds. |
| **Phase 05: Shared Auth** | Phase 02, Phase 04 | Phase 21 | `shared_auth`: Login, OTP, Forgot Password, Logout. |
| **Phase 06: Staff Advisor Radar** | Phase 03, Phase 04 | Phase 07, Phase 08 | `staff_app`: Advisor Home, Jobs, Reports, Job Detail, Sheets. |
| **Phase 07: Staff Intake Studio** | Phase 06 | Phase 08 | `staff_app`: Camera scanner, customer intake wizard, check-in, delivery. |
| **Phase 08: Staff Inspection HUD** | Phase 07 | Phase 09 | `staff_app`: Choose inspection, checkpoint sheet HUD, preview report. |
| **Phase 09: Staff Repair Estimates**| Phase 08 | Phase 10 | `staff_app`: Repair order studio, part picker, task assignment. |
| **Phase 10: Staff Tech Console** | Phase 09 | Phase 11 | `staff_app`: Tech dashboard, today jobs, productivity, job sheet. |
| **Phase 11: Staff Supervisor Bay** | Phase 10 | Phase 12 | `staff_app`: Supervisor dashboard, floor queues, review, bay scheduler. |
| **Phase 12: Staff Common Profile** | Phase 11 | Phase 13 | `staff_app`: Profile, attendance punch clock, shift details, settings. |
| **Phase 13: Owner Cockpit** | Phase 03, Phase 04 | Phase 14 | `owner_app`: Executive dashboard, top sales, activity feed, messages. |
| **Phase 14: Owner Job Operations** | Phase 13 | Phase 15 | `owner_app`: Job cards list, job detail, job status, pending approvals. |
| **Phase 15: Owner Analytics** | Phase 14 | Phase 21 | `owner_app`: Accounts receivable, inventory, team, compliance, settings. |
| **Phase 16: Customer Garage** | Phase 03, Phase 04 | Phase 17 | `customer_app`: Garage home, bookings tab, vehicles tab, profile, add car. |
| **Phase 17: Customer Booking** | Phase 16 | Phase 18 | `customer_app`: Book service wizard, booking detail, breakdown roadside. |
| **Phase 18: Customer Status & Pay** | Phase 17 | Phase 21 | `customer_app`: Service status telemetry, approvals, invoice payment. |
| **Phase 19: CRM Deal Radar** | Phase 03, Phase 04 | Phase 20 | `crm_app`: Deal radar dashboard, leads pipeline, tasks, lead sheet. |
| **Phase 20: CRM Comms & Ops** | Phase 19 | Phase 21 | `crm_app`: Conversations, sales team performance, reports, settings. |
| **Phase 21: Final Monorepo Audit** | Phases 05, 12, 15, 18, 20| Production Release | Full monorepo compilation, golden test pass, bilingual verification. |
