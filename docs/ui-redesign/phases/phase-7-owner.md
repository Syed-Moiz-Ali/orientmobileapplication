# Phase 7 — Owner app (dashboard + job cards)

## 1. Title + Goal
Turn the owner console into a 5-second-glance dashboard (ONE hero number + deltas) with card-based lists on mobile.

## 2. Pre-step
Read `docs/ui-redesign/DESIGN_SPEC.md`, `PROGRESS.md`, `MODULES.md` and any previous phase notes. Summarize in 5 lines. Do not touch business logic.

## 3. Scope
In scope: `apps/owner_app/lib/features/dashboard/presentation/{dashboard_view,pages/{team,subscription,pending_approvals,job_status,inventory,feedback_moderation,document_expiry,attendance,accounts_receivable}_view,widgets/{dashboard_body,kpi_grid,owner_dashboard_page,owner_activity_feed_tab,messages_page,period_dropdown,top_sales_page}}.dart`; `features/job_cards/presentation/{pages/{job_cards_list_view,job_card_detail_view},providers/job_card_providers,widgets/job_status_ui}.dart`.
Do NOT touch: `data/{datasources/adapters,repositories}`, `domain/*`, providers logic, router guards.

## 4. Design principles
C9 dashboard/list/detail; C8 KPI grids (AppStatTile 2-col, 12 gap), AppChartCard w/ timeframe pills, AppTable→cards on compact, AppDataRow lists, sticky action bars.

## 5. Step-by-step tasks
1. Dashboard → hero KPI + period pills + stat grid + activity feed w/ See-all (cap 5 sections above fold).
2. AR aging/inventory/job-status tables → desktop sticky-header tables, mobile stacked AppCards; add count/sort + filter pills + skeletons/empty/error.
3. Pending approvals → detail + sticky approve + danger separation + named confirmations + snackbar.
4. Team/subscription/attendance/moderation/expiry → settings/list anatomies w/ grouped tiles.

## 6. Screen-by-screen plan
Per screen: problems (table-scroll, competing KPIs, jargon buckets) → new anatomy → swaps → C10 states + offline banner + refresh.

## 7. UX writing rules
AR buckets/pipeline jargon → human + tooltip; deltas signed + color+icon (never color alone); currency/percent via formatters.

## 8. Responsive + accessibility checklist
Medium 2-col + side sheets; expanded rail + max-width; charts get text summaries; 48dp; 1.3x; AA both themes (new dark coverage — owner currently light-only).

## 9. QA checklist
- [ ] Grep clean; light+dark; all states; tables→cards verified at 360px; 1.3x; ≥48dp; UI-only diff; `flutter analyze` clean

## 10. Definition of done
Update PROGRESS.md (M7), session log, commit message (e.g. `ui(owner): redesign dashboard + job-cards`).

## 11. Ask me first
Hero KPI choice (revenue vs jobs vs AR?), AR bucket labels, approval authority wording.
