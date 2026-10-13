# ORIENT Mobile — 2026 UI/UX Redesign Program

This folder is the complete redesign plan for the Orient Workshop ERP mobile suite.
It is analysis + strategy + an ordered set of **executable Codex implementation
prompts**, including a **visual proof-of-concept gate** that must be approved
before the design system rollout begins.

No application code has been changed by this plan.

---

## 1. Purpose

Transform the four Flutter apps in this monorepo into one professionally designed,
cohesive 2026 product family:

- visually premium and calm (proven by rendered prototypes, not prose),
- task-driven and information-dense where it matters,
- genuinely responsive across small phones → tablets → desktop/web widths,
- fully bilingual (English LTR + Arabic RTL),
- accessible and testable,

while **preserving every existing business workflow, API contract, permission
rule, route, offline-sync behavior and state management decision**.

---

## 2. What was discovered

| Dimension | Finding |
|---|---|
| Stack | Flutter monorepo, Melos 8, Dart SDK ^3.9.2, Material 3 |
| Apps | `staff_app` (advisor / supervisor / technician), `owner_app`, `customer_app`, `crm_app` |
| Shared packages | `shared_core` (design system, network, sync, models), `shared_auth` (login/OTP/recovery), `shared_models` (enums) |
| Navigation | `go_router` 17 per app; role-gated redirects; tab workspaces per role |
| State | Riverpod 2.6 everywhere; Hive offline cache + real sync engine |
| Design system | Tokens + responsive layer exist; roughly two-thirds of screens still hand-roll containers, colors, search fields, loading and error states |
| Localization | **None** — no `flutter_localizations`, no ARB, no locale provider, no RTL. All strings hard-coded English |
| Accessibility | `TextScaler.linear(0.85)` forced in all four apps |
| Dark mode | `AppTheme.dark` exists but unused |
| Screens | ~100 screens/tabs/pages/sheets discovered (see `00_SCREEN_COVERAGE_MATRIX.md`) |
| Tests | `melos run test` per unit; widget + golden tests in staff/customer apps and shared packages; CI = analyze + tests + backend + E2E + 4 APK builds |

---

## 3. Design direction (summary)

**"Precision Workshop OS"** — calm, editorial, engineering-grade:

- One cobalt brand primary (#3157D5) on a cool-slate canvas; navy command
  surfaces reserved for high-emphasis telemetry.
- Plus Jakarta Sans + IBM Plex Sans Arabic; tabular numerals for data.
- One card/row/list/table grammar across all four apps.
- Cobalt-tinted selection that never relies on color alone; motion from tokens
  only; honest offline states.

The direction is **validated visually in Phase 00** (runnable prototype + EN/AR
screenshot review) and frozen in `00_VISUAL_DIRECTION.md` before any rollout.
Details: `00_REDESIGN_VISION.md`, `00_DESIGN_SYSTEM_SPEC.md`.

---

## 4. Phase roadmap (27 phases)

```
PHASE_00  VISUAL DESIGN VALIDATION  ← gate: prototype + screenshot sign-off
PHASE_01  Design System Foundation
PHASE_02  Localization & RTL Foundation
PHASE_03A Shared Primitives: Actions, Inputs & Surfaces
PHASE_03B Shared Data Display, Feedback & Chart Language
PHASE_04  Responsive Shell & Navigation
PHASE_05  Authentication & Onboarding
PHASE_06  Staff — Advisor Home & Jobs
PHASE_07A Staff — Advisor Intake & Check-in
PHASE_07B Staff — Advisor Inspection
PHASE_08  Staff — Advisor Estimate, Delivery & Assignment
PHASE_09  Staff — Supervisor Workspace
PHASE_10  Staff — Technician Workspace
PHASE_11  Staff — Common Surfaces
PHASE_12  Owner — Dashboard Experience
PHASE_13A Owner — Job Lifecycle Surfaces
PHASE_13B Owner — Resource Surfaces
PHASE_14  Owner — Finance, Compliance & Subscription
PHASE_15A Customer — Workspace Shell, Home & Profile
PHASE_15B Customer — Bookings, Garage & Vehicle Form
PHASE_16  Customer — Booking Flow, Success & Booking Detail
PHASE_17  Customer — Service Status, Approvals & Invoices
PHASE_18  Customer — Notifications, Roadside & Feedback
PHASE_19A CRM — Shell, Dashboard & Leads
PHASE_19B CRM — Work Hub (Conversations, Tasks, Sales Team)
PHASE_19C CRM — Reports, Integrations & Settings (palette deletion)
PHASE_20  Final Validation (a11y, EN/AR, responsive matrix, regression)
```

### Dependency order

| # | Phase | Apps/packages touched | Depends on |
|---|---|---|---|
| 00 | Visual Design Validation | new `apps/design_prototype` only | — |
| 01 | Design System Foundation | shared_core + 4 app wiring | 00 sign-off |
| 02 | Localization & RTL Foundation | shared_core, shared_auth, 4 apps | 01 |
| 03A | Shared Primitives | shared_core | 01, 02 |
| 03B | Shared Data Display & Charts | shared_core | 03A |
| 04 | Responsive Shell & Navigation | shared_core + app shells | 01–03B |
| 05 | Authentication & Onboarding | shared_auth + supervisor login | 01–04 |
| 06 | Staff: Advisor Home & Jobs | staff_app | 01–05 |
| 07A | Staff: Advisor Intake & Check-in | staff_app | 06 |
| 07B | Staff: Advisor Inspection | staff_app | 07A |
| 08 | Staff: Advisor Estimate/Delivery/Assignment | staff_app | 07B |
| 09 | Staff: Supervisor Workspace | staff_app | 08 |
| 10 | Staff: Technician Workspace | staff_app | 09 |
| 11 | Staff: Common Surfaces | staff_app | 10 |
| 12 | Owner: Dashboard | owner_app | 01–05 |
| 13A | Owner: Job Lifecycle | owner_app | 12 |
| 13B | Owner: Resource Surfaces | owner_app | 12 (parallel with 13A) |
| 14 | Owner: Finance/Compliance/Subscription | owner_app | 13A + 13B |
| 15A | Customer: Shell, Home & Profile | customer_app | 01–05 |
| 15B | Customer: Bookings, Garage & Form | customer_app | 15A |
| 16 | Customer: Booking Flow | customer_app | 15B |
| 17 | Customer: Status/Approvals/Invoices | customer_app | 16 |
| 18 | Customer: Notifications/Roadside/Feedback | customer_app | 17 |
| 19A | CRM: Shell, Dashboard & Leads | crm_app | 01–05 |
| 19B | CRM: Work Hub | crm_app | 19A |
| 19C | CRM: Reports/Integrations/Settings | crm_app | 19A + 19B |
| 20 | Final Validation | all | 00–19 |

Full graph + split rationale: `00_PHASE_DEPENDENCY_MAP.md`.

---

## 5. How to execute a phase with Codex

1. Open the workspace root (`orientmobileapplication/`).
2. Read `00_DESIGN_SYSTEM_SPEC.md`, `00_VISUAL_DIRECTION.md` and the target
   `PHASE_XX_*.md` end to end.
3. Run `melos bootstrap` if dependencies changed (only when a phase explicitly
   adds a package, e.g. Phase 02's `flutter_localizations`).
4. Implement exactly the phase scope — no opportunistic changes to later phases.
5. Run the phase's verification commands and its **visual quality gates (J2)**
   — rendered review, screenshot/golden evidence, EN/AR, three form factors.
6. Produce the phase Deliverable Report (section L) and attach the evidence
   pack under `phases/reports/PHASE_XX/`.
7. **Stop.** Do not start the next phase until explicitly instructed.

Commands reference (`melos.yaml`):

```
melos run analyze          # dart analyze across all packages/apps
melos run analyze:staff    # per app: staff | owner | customer | crm
melos run test             # all tests
melos run test:core        # shared_core tests (test:auth for shared_auth)
melos run test:staff       # per app: staff | owner | customer | crm
melos run format           # dart format .
```

---

## 6. How to validate phase completion

A phase is complete only when **all** of these hold:

- Every screen listed in the phase's section D is implemented.
- `melos run analyze` passes with zero new warnings/errors.
- The phase's test command passes (existing tests included — regressions are failures).
- The phase's acceptance criteria (section K) are individually verifiable.
- **Visual quality gates (J2) evidence exists**: rendered review, mobile /
  tablet / desktop, EN + AR, state matrix, no overflow, screenshot/golden pack
  attached. Passing analyze + widget tests alone is never sufficient.
- No previously working functional behavior changed (section I).

---

## 7. How to track progress

```
Phase 00 [x] | 01 [ ] | 02 [ ] | 03A [ ] | 03B [ ] | 04 [ ] | 05 [ ]
06 [ ] | 07A [ ] | 07B [ ] | 08 [ ] | 09 [ ] | 10 [ ] | 11 [ ]
12 [ ] | 13A [ ] | 13B [ ] | 14 [ ] | 15A [ ] | 15B [ ] | 16 [ ] | 17 [ ] | 18 [ ]
19A [ ] | 19B [ ] | 19C [ ] | 20 [ ]
```

Phase 00 status: **done — VISUALLY APPROVED by the product owner (2026-10-13)**.
Prototype app + 104-render pack + `audit/` captures delivered; audit found zero
blockers; refinements assigned to implementation phases. Frozen values, sign-off
and handoff prerequisites: `00_VISUAL_DIRECTION.md` (§1–§7);
execution record: `PHASE_00_VISUAL_DESIGN_VALIDATION.md` §N.

Statuses: `not started → in progress → in review → done`. A phase is done only
after its Deliverable Report + evidence pack exist.

---

## 8. Shared design changes

- All token/component changes live in `packages/shared_core` (and `shared_auth`
  for auth surfaces). Feature apps **consume**, they do not fork.
- Missing primitive discovered in a feature phase:
  1. add it to the shared library (its own small change),
  2. note it in the phase report,
  3. document it in `00_DESIGN_SYSTEM_SPEC.md` §7.
- Never hard-code a color, radius, spacing, duration or font size that has a token.

---

## 9. Preventing regressions

- Never change route paths, `extra` contracts, provider names, API/DTO shapes or
  permission checks as part of UI work. If a phase must touch any of them, it
  must document why and require explicit review (section I) — the default is no.
- Existing tests are the regression baseline; update them **only** where the
  design intentionally changes a user-visible contract (document every case).
- Goldens regenerate only in the phase that redesigns the screen.
- `TextScaler.linear(0.85)` removal (Phase 01) is followed by an in-phase
  regression fix protocol — application-breaking layout fallout is fixed in
  Phase 01, never deferred.

---

## 10. Files in this folder

```
phases/
├── README.md                                  ← you are here
├── 00_PROJECT_ANALYSIS.md                     ← real architecture + screen inventory
├── 00_REDESIGN_VISION.md                      ← 2026 design direction + UX principles
├── 00_VISUAL_DIRECTION.md                     ← review brief + sign-off record (Phase 00 output)
├── 00_DESIGN_SYSTEM_SPEC.md                   ← design authority: tokens + components
├── 00_RESPONSIVE_STRATEGY.md                  ← breakpoints, adaptive behavior rules
├── 00_LOCALIZATION_RTL_STRATEGY.md            ← EN/AR architecture + ownership + tests
├── 00_SCREEN_COVERAGE_MATRIX.md               ← every screen → phase mapping
├── 00_PHASE_DEPENDENCY_MAP.md                 ← execution order + prerequisites
├── PHASE_00_VISUAL_DESIGN_VALIDATION.md
├── PHASE_01_DESIGN_SYSTEM_FOUNDATION.md
├── PHASE_02_LOCALIZATION_RTL_FOUNDATION.md
├── PHASE_03A_SHARED_PRIMITIVES_ACTIONS_INPUTS_SURFACES.md
├── PHASE_03B_SHARED_DATA_DISPLAY_FEEDBACK_CHART_LANGUAGE.md
├── PHASE_04_RESPONSIVE_SHELL_AND_NAVIGATION.md
├── PHASE_05_AUTHENTICATION_AND_ONBOARDING.md
├── PHASE_06_STAFF_ADVISOR_HOME_AND_JOBS.md
├── PHASE_07A_STAFF_ADVISOR_INTAKE_AND_CHECKIN.md
├── PHASE_07B_STAFF_ADVISOR_INSPECTION.md
├── PHASE_08_STAFF_ADVISOR_ESTIMATE_DELIVERY_ASSIGNMENT.md
├── PHASE_09_STAFF_SUPERVISOR_WORKSPACE.md
├── PHASE_10_STAFF_TECHNICIAN_WORKSPACE.md
├── PHASE_11_STAFF_COMMON_SURFACES.md
├── PHASE_12_OWNER_DASHBOARD.md
├── PHASE_13A_OWNER_JOB_LIFECYCLE.md
├── PHASE_13B_OWNER_RESOURCE_SURFACES.md
├── PHASE_14_OWNER_FINANCE_COMPLIANCE_SUBSCRIPTION.md
├── PHASE_15A_CUSTOMER_WORKSPACE_AND_HOME.md
├── PHASE_15B_CUSTOMER_BOOKINGS_GARAGE_VEHICLE_FORM.md
├── PHASE_16_CUSTOMER_BOOKING_FLOW.md
├── PHASE_17_CUSTOMER_STATUS_APPROVALS_INVOICES.md
├── PHASE_18_CUSTOMER_NOTIFICATIONS_ROADSIDE_FEEDBACK.md
├── PHASE_19A_CRM_SHELL_DASHBOARD_LEADS.md
├── PHASE_19B_CRM_WORK_HUB.md
├── PHASE_19C_CRM_REPORTS_INTEGRATIONS_SETTINGS.md
└── PHASE_20_FINAL_VALIDATION.md
```

**Recommended first phase: `PHASE_00_VISUAL_DESIGN_VALIDATION.md`** — build the
prototype, review the screenshots, sign `00_VISUAL_DIRECTION.md`, then start
`PHASE_01_DESIGN_SYSTEM_FOUNDATION.md`.

Do not implement any phase until explicitly instructed.
