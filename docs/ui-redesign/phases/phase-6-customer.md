# Phase 6 — Customer app (dashboard, booking, tracking, vehicles, profile)

## 1. Title + Goal
Redesign the highest-visibility external app into a calm reassuring flow: book → track → approve → pay, with honest live status.

## 2. Pre-step
Read `docs/ui-redesign/DESIGN_SPEC.md`, `PROGRESS.md`, `MODULES.md` and any previous phase notes. Summarize in 5 lines. Do not touch business logic.

## 3. Scope
In scope: `apps/customer_app/lib/features/customer/presentation/{customer_dashboard_view,customer_book_service_view,customer_booking_detail_view,customer_booking_success_view,customer_approvals_page,customer_service_status_page,customer_breakdown_help_view,customer_breakdown_result_view,customer_invoice_detail_view,customer_feedback_view,customer_notifications_view,add_vehicle_view}.dart` + `widgets/{customer_home_tab,customer_bookings_tab,customer_service_status_tab,customer_vehicles_tab,customer_profile_tab,customer_scaffold*}.dart` (28 files) — split into section widgets.
Do NOT touch: `data/*`, `domain/*`, `support/*` logic (`booking_relations/push_routing/sync`), `core/router/app_router.dart` behavior + legacy redirects, providers in `support/` boundary.

## 4. Design principles
C9 dashboard/list/detail/form + data-heavy screens (switcher pills + big live value + status chip + why + chart + stat grid + explainers + accordion); C10 incl. "Updated Xs ago" + AppBanner when delayed/offline; C11 STATUS pattern everywhere ("Watching…/On the lift…").

## 5. Step-by-step tasks
1. Dashboard → greeting + ONE hero (vehicle/service status, numberLarge + delta + sentence) + 3–4 quick actions + sections w/ See-all; preserve tab deep-links (`?tab=`, legacy `/customer_service_status_view` redirect).
2. Book service + add/edit vehicle → form anatomy (single col, grouped, sticky CTA, success snackbar → booking-success screen).
3. Service status/tracking → data-heavy anatomy w/ live ribbon (`live_service_telemetry_ribbon` restyled via tokens) + timeline + explainers.
4. Approvals/invoices → detail anatomy w/ sticky approve/pay + danger separation; breakdown help/result → guided flow; notifications/feedback → list anatomy. Do NOT regress dark mode (only app with dark wired).

## 6. Screen-by-screen plan
Each screen: current problems (jargon/cramped/no-states/table-scroll) → new C9 layout → App* swaps (SearchBar/pills/cards/sheets/dialogs) → required states incl. offline/stale + pull-to-refresh.

## 7. UX writing rules
Reassuring calm copy; technical telemetry behind Details; relative time + currency via formatters; never raw exceptions.

## 8. Responsive + accessibility checklist
Compact bottom nav; medium 2-col; expanded rail + 1200 max; tables→cards; 48dp; labeled targets; contrast incl. dark; 1.3x/320px.

## 9. QA checklist
- [ ] Grep clean; light+dark (no regression); all states; 1.3x/320px; ≥48dp; deep-links preserved; UI-only diff; `flutter analyze` clean

## 10. Definition of done
Update PROGRESS.md (M6), session log, commit message (e.g. `ui(customer): redesign dashboard/booking/tracking flows`).

## 11. Ask me first
Approval/payment confirmation wording, breakdown safety copy, notification categories to keep.
