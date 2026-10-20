# Phase 3 — Staff advisor core (home, jobs, check-in, assign, reports)

## 1. Title + Goal
Migrate the highest-traffic workshop flow to calm, single-focus screens with hero status, quick actions, and proper loading/empty/error states.

## 2. Pre-step
Read `docs/ui-redesign/DESIGN_SPEC.md`, `PROGRESS.md`, `MODULES.md` and any previous phase notes. Summarize in 5 lines. Do not touch business logic.

## 3. Scope
In scope: `apps/staff_app/lib/features/advisor/presentation/pages/{advisor_home_view,advisor_jobs_view,advisor_job_detail_view,advisor_vehicle_checkin_view,advisor_assign_tasks_view,advisor_reports_view,scan_vehicle_view,vehicle_customer_view,vehicle_delivery_view}.dart` + section widgets split into `presentation/widgets/` (<150 lines each).
Do NOT touch: `inspection_pages/*`, `repair_order*`, `real_damage_canvas.dart`, `vehicle_map/*`, datasources/providers logic, `data/models/*`, routing guards.

## 4. Design principles
C9 dashboard/list/detail/form anatomies; C8 AppScaffold/AppBar/Card/Section/ListTile/StatusChip/StatTile/Banner/Skeleton/Empty/Error/SnackBar; C10 every data screen; C11 status pattern (dot + human label + why-sentence).

## 5. Step-by-step tasks
1. Home → greeting/status header + ONE hero summary card (numberLarge + delta + plain sentence) + 3–4 quick-action tiles + sections (activity, alerts) with See-all.
2. Jobs list → AppSearchBar + pill filters + count/sort + cards (12 gap) + skeletons/empty/error/no-results + pull-to-refresh + infinite loader.
3. Job detail → hero + title block + 2-col StatTiles + grouped DataRow cards + related + sticky primary action; danger actions to overflow/bottom danger-zone card.
4. Check-in/assign/delivery forms → single column, grouped sections, label-above/helper-below, inline validation, sticky bottom CTA + loading/disabled.
5. Replace `Colors./EdgeInsets/BorderRadius` literals with tokens; surface sync states via PendingSyncChip/OfflineBanner ("Updated Xm ago").

## 6. Screen-by-screen plan
| Screen | Problems | New layout + swaps | States |
|---|---|---|---|
| advisor_home_view | 5+ competing sections, no hero | hero card + quick actions + max 5 sections | skeleton/empty/error/offline |
| advisor_jobs_view | dense rows, no filter feedback | search + pills + count + cards | skeleton/empty/error/no-results |
| advisor_job_detail_view | technical dump, CTA crowding | hero + stats + grouped cards + sticky action | loading/error/partial banner |
| check-in/assign/delivery/scan/vehicle-customer | jargon, cramped, silent save | form anatomy + snackbar confirm | validating/disabled/loading/success |
| advisor_reports_view | chart clutter | AppChartCard + timeframe pills + muted grid | loading/empty/error |

## 7. UX writing rules
Plain labels; technical codes behind InfoTooltip/Details; verb-first buttons; errors what+next-step; numbers via formatters (tabular, separators, +/-).

## 8. Responsive + accessibility checklist
Compact single-col + bottom nav; medium 2-col dashboards; expanded max-width 1200 + rail; tables→cards on phones; 48dp; semantics; 1.3x + 320px clean; AA contrast.

## 9. QA checklist
- [ ] Zero forbidden patterns in scope (grep); zero new hardcoded strings (use ARB/tokens)
- [ ] Light+dark; all C10 states; 1.3x + small phone; ≥48dp; UI-only diff; `flutter analyze` clean; app runs

## 10. Definition of done
Update PROGRESS.md (M3), session log, commit message (e.g. `ui(staff-advisor): redesign home/jobs/detail/checkin flows`).

## 11. Ask me first
Job-status vocabulary mapping (raw codes → human labels), which fields are truly required, assign-flow confirmation wording.
