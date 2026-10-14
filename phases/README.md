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
Phase 00 [x] | 01 [x] | 02 [x] | 03A [x] | 03B [x] | 04 [x] | 05 [x]
06 [x] | 07A [x] | 07B [ ] | 08 [ ] | 09 [ ] | 10 [ ] | 11 [ ]
12 [ ] | 13A [ ] | 13B [ ] | 14 [ ] | 15A [ ] | 15B [ ] | 16 [ ] | 17 [ ] | 18 [ ]
19A [ ] | 19B [ ] | 19C [ ] | 20 [ ]
```

Phase 00 status: **done — VISUALLY APPROVED by the product owner (2026-10-13)**.
Prototype app + 104-render pack + `audit/` captures delivered; audit found zero
blockers; refinements assigned to implementation phases. Frozen values, sign-off
and handoff prerequisites: `00_VISUAL_DIRECTION.md` (§1–§7);
execution record: `PHASE_00_VISUAL_DESIGN_VALIDATION.md` §N.

Phase 01 status: **COMPLETE — accepted by the product owner (2026-10-13)**
after the final Phase 01.1 accessibility correction (WCAG AA dark control
inks: `onPrimary`/`onError` = `#0C1120`, ≈6.1:1/≈6.6:1 at rest and ≥5.1:1 in
all enabled states; amended in `00_VISUAL_DIRECTION.md` §3). Deliverable
Report + evidence pack: `phases/reports/PHASE_01/PHASE_01_COMPLETION.md`
(33-render pack in `PHASE_01/screens/`, baseline/final logs,
`scale_polish_list.md`). Zero new test failures vs. baseline across the six
suites (pre-existing sets recorded separately); prototype untouched
(299/299); `dart analyze` 0 issues on all six units.

Phase 02 status: **IMPLEMENTATION COMPLETE — in review (awaiting product-owner
acceptance, 2026-10-13)**. Six l10n units (shared_core/shared_auth + four apps)
with distinct generated classes; `AppLocales` + Hive-persisted `localeProvider`
hydrated before the first frame; IBM Plex Sans Arabic bundled and applied through
locale-aware `AppTypography.forLocale`/`AppTheme`; shared copy + auth copy
localized EN+AR; `AppFormatters`, `LanguageSwitcher`, `DirectionalIcon` and the
identifier `AppTextField` variant shipped; forced LTR removed; RTL mirrors shared
chrome (damage-map exception reserved for 07B). Deliverable Report + evidence
pack: `phases/reports/PHASE_02/PHASE_02_COMPLETION.md` (11 EN/AR renders in
`PHASE_02/screens/`, baseline/final logs, capture harnesses). **Zero new test
failures** vs. baseline across the six suites + prototype (prototype untouched,
299/299); `dart analyze` 0 issues on all six units + prototype; 7 customer-profile
goldens intentionally re-baselined after review (additive language row).
**Phase 03A is ready to start — not started; awaiting explicit authorization.**

Phase 03A status: **IMPLEMENTATION COMPLETE — in review (awaiting product-owner
acceptance, 2026-10-13)**. The shared interactive primitive catalog is finalized
in `packages/shared_core` — buttons/actions, inputs/search/select, quantity
stepper, cards/panels, record rows, KPI tiles, status pills, progress, action
bar, dialogs/sheets and form primitives — plus the five proven gaps
(`AppQuantityStepper`, `AppSelectionSheet`/`showAppSelectionSheet`,
`showAppSnackBar`, `PendingSyncChip`, identifier `AppTextField`). The Phase 01.1
light-danger pressed-state contrast deviation (≈4.21:1) is fixed centrally
through the new `AppInteractionStates` (all enabled button states now ≥4.5:1).
14 new EN+AR ARB keys; EN/AR + RTL + 1.6× verified; 8 new component goldens
(390/834/1400 × EN/AR + dark) in `phases/reports/PHASE_03A/screens/`. Deliverable
Report + evidence pack: `phases/reports/PHASE_03A/PHASE_03A_COMPLETION.md`.
**Zero new test failures** across the six suites + prototype (prototype
untouched, 299/299); `shared_core` 189/6 (3 component goldens resolved vs. the
155/9 baseline; the 6 remaining are non-component, owned by 04/01);
`dart analyze` 0 issues on all seven units. Public APIs additive-only.
**Phase 03B is ready to start — not started; awaiting explicit authorization.**

Phase 03B status: **IMPLEMENTATION COMPLETE — in review (awaiting product-owner
acceptance, 2026-10-13)**. The data-display half of the catalog is finalized in
`packages/shared_core` — `AppSkeleton` variants (text/list/card/grid/chart/table,
one controller per composite, reduced-motion static, dark `skeleton*` tokens),
`EmptyState` empty/no-match/error + `ErrorView` details, the `AppTable*` desktop
primitives with a proven `<600 px` `AppRecordRow` fallback, `AppChartTheme` +
`AppChartPlaceholder` (palette/typography/tooltip/gridlines/RTL order/empty — no
`fl_chart` dependency), the documented `AppListSurface` list-surface recipe, and
the `ShimmerLoading` deprecation. 2 new EN+AR ARB keys; RTL table/chart order,
1.6× and 320 px verified; 6 new data-display goldens
(`phases/reports/PHASE_03B/screens/`). Deliverable Report + evidence pack:
`phases/reports/PHASE_03B/PHASE_03B_COMPLETION.md`. **Zero new test failures**
across the six suites + prototype (prototype untouched, 299/299); `shared_core`
216/6 (the 6 remaining are non-component, owned by 04/01); `dart analyze` 0
issues on all seven units. Public APIs additive-only. **Phase 04 is ready to
start — not started; awaiting explicit authorization.**

Phase 04 status: **IMPLEMENTATION COMPLETE — in review (awaiting product-owner
acceptance, 2026-10-13)**. The family-wide shell and navigation are finalized in
`packages/shared_core` — one shell contract (`DashboardShell`, keyboard/FAB
clearance), RTL-mirrored rail/drawer/bottom-bar (mirrored rail
`BorderDirectional`, direction-aware badges, localized "More" + destination
semantics), the single `WorkspaceAppBar` header composition, `AppBreadcrumbs` +
`AppPageHeader` breadcrumb slot, and the `AppMasterDetailScaffold` /
`AppThreePaneScaffold` templates. 3 new EN+AR ARB keys; RTL rail/bottom-bar/
drawer mirroring, master–detail degradation, breadcrumbs, Escape-closes-modal
and 1.6× nav rendering all test-proven. Deliverable Report + evidence pack:
`phases/reports/PHASE_04/PHASE_04_COMPLETION.md` (15 renders in
`PHASE_04/screens/`). **Zero new test failures** across the six suites +
prototype (prototype untouched, 299/299); `shared_core` 245/1 (**5
`shell_family` goldens resolved**; the 1 remaining is non-shell, owned by 01);
`dart analyze` 0 issues on all seven units. Public APIs additive; no
route/provider/feature changes. **Phase 05 is ready to start — not started;
awaiting explicit authorization.**

Phase 05 status: **IMPLEMENTATION COMPLETE — in review (awaiting product-owner
acceptance, 2026-10-13)**. The authentication experience is redesigned on the
approved system — navy `AuthShell` identity panel, segmented password/one-time-code
control, `AppStepProgress` recovery stages, branded navy splash, `AppInfoPanel`-tone
notices and app-aware `SecurityBadge` — for `LoginView`, `ForgotPasswordView`,
`AuthLoadingView` and the rebuilt staff `SupervisorLoginView`. `shared_auth` ships
74 EN keys (EN+AR parity green; ICU plural countdown); each app adds a localized
`authSecurityNotice`. Legacy `AuthHeader`/`AuthBackground`/`OtpInputField`/
`PhoneInputField` removed (dial-code data retained as `phoneCountries`).
Deliverable Report + evidence pack: `phases/reports/PHASE_05/PHASE_05_COMPLETION.md`
(24 renders in `PHASE_05/screens/`). **Zero new test failures** across the six
suites + prototype (prototype untouched, 0 changes); `shared_auth` **73/0** (11
missing auth goldens resolved + 27 new tests); staff **282/7** (baseline set
unchanged); `dart analyze` 0 issues on all six units. **Phase 06 is ready to start
— not started; awaiting explicit authorization.**

Phase 06 status: **IMPLEMENTATION COMPLETE — in review (awaiting product-owner
acceptance, 2026-10-13)**. The advisor daily workspace is redesigned on the
approved system — Today as a command surface (shift header → attention → metrics →
recent → quick actions), a search-first Jobs list on `AppRecordRow`, a
segmented-range Reports view on the shared chart language, and a job-detail
workspace hub with `AppTopBar` and error+retry; every advisor sheet/dialog and kit
widget is tokenized, localized and RTL-correct. 155 new `advisor*` ARB keys
(EN+AR parity green; 168 total). Deliverable Report + evidence pack:
`phases/reports/PHASE_06/PHASE_06_COMPLETION.md` (14 renders in
`PHASE_06/screens/`). **Zero new test failures** (staff **312/7** — the 7 are the
identical pre-existing intake/advisor-workflow set; `shared_auth` 73/0;
`shared_core` 245/1; owner 21/0; crm 14/0; customer 509/8 with the extra
`customer_book_service_dark_mobile` golden failing for the **same pre-existing
date-relative reason** as the schedule/review/tablet goldens — the flow renders
"tomorrow" from the real clock and the golden embeds a fixed date; verified not
Phase 06-caused, not regenerated); `dart analyze` 0 issues on all six units;
prototype untouched. **Phase 07A is ready to start — not started; awaiting explicit
authorization.**

Phase 07A status: **IMPLEMENTATION COMPLETE — in review (awaiting product-owner
acceptance, 2026-10-14)**. The advisor intake/check-in/scan capture flow is
redesigned on the approved 2026 system — a sectioned, collapsible intake
(`VehicleCustomerView`) with `AppStepProgress` intake rail, `AppTopBar` +
discard guard, shared `AppTextField` (identifier + new visible `prefix` slot),
`AppDropdownButton`, `AppMediaUploadShell`, `AppDateSelectorShell`,
`AppFormSection`/`AppFormField`/`AppFormPanel`, `AppActionBar`, `AppInfoPanel`,
`PendingSyncChip` (honest saving/queued/sent) and a live two-column summary at
≥600 px; a two-step `AppStepProgress` check-in wizard; and a restyled scan
surface with permission-denied + result-confirmation states. The legacy local
kit `vehicle_customer_shared_widgets.dart` is deleted (zero references). 205 new
`advisorIntake*`/`advisorScan*`/`advisorCheckIn*` ARB keys (EN+AR parity green;
373 total). Deliverable Report + evidence pack:
`phases/reports/PHASE_07A/PHASE_07A_COMPLETION.md` (13 renders in
`PHASE_07A/screens/`). **The six pre-existing `VehicleCustomerView` intake
overflow failures are resolved** (the rewritten `vehicle_customer_intake_layout_test.dart`
now proves 320/360/390/430/768/1280 px clean in EN+AR + 1.3×), plus the
pre-existing advisor-workflow finder is corrected. Staff **343/0** (baseline
312/7 → zero failures); `shared_core` 245/1 (the 1 is the pre-existing
`app_theme_visual_test`, owned by 01; the additive `AppTextField.prefix` slot
changed nothing); `shared_auth` 73/0; owner 21/0; crm 14/0; `dart analyze` 0
issues on `shared_core` + `staff_app`; prototype untouched. **Phase 07B is ready
to start — not started; awaiting explicit authorization.**

Statuses: `not started → in progress → in review → done`. A phase is done only
after its Deliverable Report + evidence pack exist and the product owner
accepts the review.

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
