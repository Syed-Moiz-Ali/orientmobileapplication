# UX Brief — staff inspection / repair-order lists (list family, GROUP-B `ui/list-staff-jobs`)

## Scope
Investigation brief: which inspection / repair-order LIST surfaces exist in
`apps/staff_app`, and what the list-production scope therefore is.
Candidate files inspected: `features/advisor/presentation/pages/choose_inspection_view.dart`
(package picker), `inspection_sheet_view.dart` (checklist detail),
`inspection_preview_view.dart` (preview), `repair_order_view.dart` (Repair Order Studio
detail), `advisor_job_detail_view.dart` (job dossier detail), `advisor_reports_view.dart`
(reports tab — out of list scope, owned elsewhere), plus the router
(`core/router/app_router.dart`) and a repo grep for list widgets in advisor scope.

## Finding (verified from code — single unified surface)
**No separate inspection list and no separate repair-order list exist in staff.**
Evidence:
- Router (`app_router.dart:56-60`): `choose-inspection`, `inspection-sheet`,
  `inspection-preview`, `repair-order`, `repair-order-preview` are all pushed
  detail/flow routes reached per job card — none is a register, none takes a list
  query, none appears in any nav rail/tab.
- The only advisor work register is `AdvisorJobsListView`
  (`advisor_jobs_view.dart:18`) — server page 1/size 50 + local-first intake cards —
  and it is the surface backing the advisor home Assigned list (`take(6)` window).
- `ChooseInspectionView` is a 3-tier package DECISION picker (Concept A entry), not a
  work list: fixed `_packages` (Express / Comprehensive / Brake-&-Suspension), sort
  pills, one Continue CTA. `InspectionSheetView` is a per-job checkpoint checklist.
  `RepairOrderView` is the per-job estimate Studio (Parts → Labor → Review stepper).
  All three are downstream of a selected job card (`jobCardId` / `jobCardRef`).
- `AdvisorReportsView` is the Reports tab (analytics), not an inspection or
  repair-order work list — out of this builder's list scope.
- Supervisor `SupervisorJobsTab` / `SupervisorQueueTab` and technician
  `TechnicianJobsView` are other roles' surfaces (other builders; technician Jobs is
  already header-icon-only — do not touch).
- `ListView`/`AppTable`/`AppMasterDetailScaffold` hits in advisor scope resolve to:
  the jobs register, job dossier detail rows, checkin/choose flows, inspection
  checklist rows, studio rows, delivery — i.e. exactly one register.

**Conclusion: inspection and repair orders are ONE surface — the advisor jobs
register.** This brief therefore collapses into `advisor-jobs-list.md` (screen 1):
one brief governs the single list surface; there is no second list to rebuild, no
second header/search/filter pattern to invent, and no divergent list grammar to
reconcile. Entry into the inspection and repair-order flows stays exactly as today:
job card → dossier → Choose inspection → Inspection sheet → Repair Order Studio
(existing pushes: `chooseInspection` → `inspectionSheet` → `inspectionPreview` /
`repairOrder` → `repairOrderPreview`; byte-identical).

## User goal
Same as screen 1 (the register IS the inspection/repair-order work list): find the
job → open it → continue into inspection / estimate work. No separate list goal exists.

## Single primary action
Same as screen 1: open the job card workspace. (Downstream flow entry points —
Start inspection, Open repair order — live inside the dossier detail, out of list
scope; their taps are unchanged and recorded below for the no-regression record.)

## Top tasks with tap counts (BEFORE = current UI, AFTER must be ≤)
Same register tasks as screen 1 (identical surface, identical budgets):
1. Open a job card workspace — before **2 taps** (+scroll) → after **≤ 2 taps**.
2. Find a specific job (search) — before **3 taps** + typing → after **≤ 3 taps** + typing.
3. Triage by status (filter) — before **2 taps** → after **≤ 2 taps** (rail inline).
Flow-entry tasks (dossier and downstream, NOT rebuilt — recorded so taps are pinned):
4. Reach the inspection picker from the list — before: tab (1) + card (1) + dossier
   inspection entry (1) = **3 taps** → after: **≤ 3 taps** (dossier untouched).
5. Reach the repair-order studio from the list — before: tab (1) + card (1) + dossier
   estimate entry (1) = **3 taps** → after: **≤ 3 taps** (dossier/studio untouched).

| Task | Before | After budget |
|---|---|---|
| Open job card (register) | 2 taps (+scroll) | ≤ 2 taps, ≤ same scroll |
| Find job via search | 3 taps + typing | ≤ 3 taps + typing |
| Filter by status | 2 taps | ≤ 2 taps |
| Reach inspection picker (via dossier) | 3 taps | ≤ 3 taps (dossier untouched) |
| Reach repair studio (via dossier) | 3 taps | ≤ 3 taps (studio untouched) |

## References (dependency: UNMET, proceeded on precedent)
Same as screen 1: `docs/ui-redesign/references/` does not exist;
`AIRBNB_PATTERNS.md` missing repo-wide; proceeding on the phase-6 vehicles-list
precedent via `advisor-jobs-list.md`. No second precedent mapping is needed because
no second list surface exists.

## U-laws application (U0–U14, C17)
All U-law obligations for the inspection / repair-order work list are discharged by
screen 1 (`advisor-jobs-list.md` — full U0–U14 walk, hard-reject checklist, wireframe,
states). No separate U-law walk is possible or needed: there is no second list chrome
to judge. U7 (one path per task) is specifically protected BY this finding: inventing
a parallel inspection/repair-order register would create a duplicate entry point to
the same work and violate U7. Downstream flow screens (picker / checklist / studio)
keep their existing chrome and tap counts (tasks 4–5 above); any future redesign of
those detail/flow surfaces is a different brief, not a list brief.

## What is REMOVED or moved
Nothing — no list surface exists to remove from, and none is created. The
`choose_inspection`, `inspection_sheet`, `inspection_preview`, `repair_order` and
`repair_order_preview` routes, providers (`inspectionProvider`), math
(`repair_estimate_math.dart`), Hive contracts and payloads are untouched (logic
untouchable; STOP + report if logic were ever needed — none is).

## Flow / sections
N/A (no surface). Register flow is screen 1's C16 list flow; downstream per-job flow
is unchanged: Jobs register → job dossier → Choose inspection → Inspection sheet →
Repair Order Studio.

## Hard-reject checklist
N/A as a separate surface — the single register's checklist lives in screen 1 and
covers the inspection/repair-order work list with it. No second header, no second
search icon, no second filter control is added anywhere (audit rule: exactly one
visible search icon per screen).

## U0-U14 checklist
Discharged via screen 1 (same surface, same walk). No independent list states exist.

## ASCII wireframe at 360x800
Same as screen 1 (one surface, one wireframe — see `advisor-jobs-list.md`). No second
fold to prove.

## States
Same as screen 1 (loading / empty / error / stale / no-match / ar / 1.3x / 320px /
tablets / light-only). Downstream flow states (studio skeleton/error, checklist
progress) are detail states, unchanged.

## Copy keys needed
None beyond screen 1's list (`advisorJobsCount` proposed there, en+ar, phase-9).
No inspection/repair list copy exists to add because no list surface exists.

## Acceptance
- Investigation evidence above (router lines, class candidates, grep resolution) is
  the acceptance artifact: exactly ONE advisor work register exists.
- U7 holds precisely because no parallel register is built.
- Gates: screen 1's characterization tests + before-images + migration table cover
  this scope (same surface); no separate test/capture/migration files are created
  for a surface that does not exist (creating them would assert against nothing).
- Airbnb rubric: judged once, on screen 1 (≥ 12/16 to pass).
- Verify from code: route table (`app_router.dart`), `AdvisorJobsListView` as the
  sole register, downstream flow entry points unchanged, no `71983229` touched.
