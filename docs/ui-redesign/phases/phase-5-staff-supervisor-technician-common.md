# Phase 5 — Staff supervisor + technician + common

## 1. Title + Goal
Unify the remaining staff_app shell: 7-tab supervisor console, technician today/jobs/productivity, and profile/attendance/settings.

## 2. Pre-step
Read `docs/ui-redesign/DESIGN_SPEC.md`, `PROGRESS.md`, `MODULES.md` and any previous phase notes. Summarize in 5 lines. Do not touch business logic.

## 3. Scope
In scope: `features/supervisor/presentation/{supervisor_dashboard_view,supervisor_login_view,widgets/{supervisor_dashboard_tab,supervisor_jobs_tab,supervisor_queue_tab,supervisor_review_tab,supervisor_staff_tab,supervisor_schedule_tab,supervisor_reports_tab,supervisor_assign_sheet,supervisor_scaffold,supervisor_components,qc_checklist_sheet,staff_notification_bell}}.dart`; `features/technician/presentation/{technician_dashboard_view,widgets/{technician_today_view,technician_jobs_view,technician_productivity_view,technician_components,job_detail_sheet,parts_request_sheet,escalation_sheet}}.dart`; `features/common/presentation/{profile_screen,simple_pages,staff_attendance_screen}.dart`.
Do NOT touch: providers/datasources/entities, sync logic, router guards.

## 4. Design principles
C9 dashboard (ONE hero + ≤5 sections + See-all) / list / detail + bottom-sheet flows (pickers ≤1 screen); C9 settings anatomy for profile/settings; C8 segmented/pill tabs, AppTable→cards on mobile.

## 5. Step-by-step tasks
1. Supervisor: collapse 7 tabs into AppPillTabs/scrollable pills + hero summary + AppChartCard + StatTile grid; assign/review/QC as BottomSheets; staff/schedule tables become cards on compact.
2. Technician: Today = hero job + next actions; jobs list + job_detail_sheet; productivity = chart card + stats; parts/escalation sheets with sticky CTAs + snackbars.
3. Common: settings anatomy (account header avatar+name+email → grouped AppSettingsTiles → separated logout/danger); split 958-line `profile_screen.dart` into section widgets.
4. Replace local bells/pills/scaffolds with core (`NotificationBell`, `StatusChip`, `WorkspaceAppBar` wrappers).

## 6. Screen-by-screen plan
Supervisor dashboard/tabs → dashboard anatomy each with single primary focus; technician views → today/list/detail; profile/attendance/settings → settings anatomy with empty/error/offline states everywhere.

## 7. UX writing rules
Queue/QC jargon → plain + tooltip; shift/attendance states as STATUS pattern; destructive logout/delete separated with named confirmations.

## 8. Responsive + accessibility checklist
Medium 2-col grids + side sheets; expanded rail + max-width; 48dp; semantics; 1.3x; AA.

## 9. QA checklist
- [ ] Grep clean in scope; light+dark; all C10 states; 1.3x/320px; ≥48dp; UI-only diff; `flutter analyze` clean

## 10. Definition of done
Update PROGRESS.md (M5), session log, commit message (e.g. `ui(staff): redesign supervisor + technician + profile flows`).

## 11. Ask me first
Which supervisor tabs can hide behind See-all; QC checklist must-stay-visible items; escalation copy.
