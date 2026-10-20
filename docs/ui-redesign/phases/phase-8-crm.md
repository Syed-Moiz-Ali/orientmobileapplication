# Phase 8 — CRM app (pipeline, leads, tasks, reports)

## 1. Title + Goal
Simplify the internal CRM into a focused pipeline console; last module by design (lowest traffic, most tolerant).

## 2. Pre-step
Read `docs/ui-redesign/DESIGN_SPEC.md`, `PROGRESS.md`, `MODULES.md` and any previous phase notes. Summarize in 5 lines. Do not touch business logic.

## 3. Scope
In scope: `apps/crm_app/lib/features/crm_dashboard/presentation/{crm_dashboard_view,crm_constants,providers/*,support/{crm_l10n,crm_board_filter},widgets/{crm_dashboard_page,crm_leads_page,crm_kanban_view,crm_pipeline_widget,crm_conversations_page,crm_channel_widgets,crm_tasks_page,crm_reports_page,crm_sales_team_page,crm_integrations_page,crm_settings_page,crm_followups_widget,crm_activity_feed_widget,crm_recent_leads,crm_drawer,lead_form/detail_sheet,connect_integration_sheet}}.dart`.
Do NOT touch: `data/*`, `domain/*`, kanban drag logic/ordering, router (4 routes stay).

## 4. Design principles
C9 dashboard/list/detail + bottom-sheet flows for lead form/detail; C8 kanban restyled via tokens (neutral columns, accent only active); C10 per board (skeleton board, empty pipeline, error + retry, offline banner).

## 5. Step-by-step tasks
1. Eliminate 22 `Color(0x` in `crm_constants.dart` + widgets → tokens; unify channel/pipeline pills → AppStatusChip.
2. Dashboard → hero (open pipeline value) + pills filter + kanban + follow-ups/activity sections; tasks/reports/team/integrations/settings → list/settings anatomies.
3. Lead form/detail sheets → form/detail sheets w/ sticky CTA + validation + snackbar; drawer → NavigationRail on expanded.
4. Desktop: max-width + side sheets; mobile: kanban columns become swipeable cards list (no forced horizontal table scroll).

## 6. Screen-by-screen plan
Kanban/leads/conversations/tasks/reports/team/integrations/settings: problems (raw colors, dense, no states) → new anatomy → swaps → states.

## 7. UX writing rules
Pipeline stages → short human + why-sentence; confirmations name the lead; relative times via formatters.

## 8. Responsive + accessibility checklist
Tablet landscape rail; desktop max-width; 48dp; semantics on drag handles (announce); 1.3x; AA.

## 9. QA checklist
- [ ] Zero `Color(0x`; other greps clean; light+dark; all states; 1.3x/320px; ≥48dp; UI-only diff; `flutter analyze` clean

## 10. Definition of done
Update PROGRESS.md (M8 — all modules redesigned), session log, commit message (e.g. `ui(crm): redesign pipeline console on design system`).

## 11. Ask me first
Stage names mapping, fields required on lead form, integrations copy that must stay technical.
