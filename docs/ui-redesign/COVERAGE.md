# UI Redesign — Screen Coverage Matrix (branch `ui/integration-2`)

Every screen file named in `docs/ui-redesign/MODULES.md`, plus sub-pages / sheets /
row variants reached from already-redesigned screens (enumerated from the app `lib`
trees). Each row ends in exactly one terminal bucket:

- `redesigned` — rebuilt under full gates, with the tag or commit as evidence.
- `pending` — not yet rebuilt; `planned phase` (owner session) is filled.
- `filed leftover` — enumerated + filed in `evaluation/crm-modules-sweep.md`
  (out-of-scope for the filing builder); `planned phase` is STILL filled —
  "filed" is not a final state.

Sources read: `MODULES.md`; `evaluation/crm-modules-sweep.md`; all LIST briefs
(`briefs/*.md`); evaluation + adversarial reviews for DONE screens; the `lib`
trees of `staff_app`, `customer_app`, `owner_app`, `crm_app`, `shared_auth`.
`references/` EMPTY is irrelevant here (no pattern mapping is claimed).
Non-screen files (providers, models, entities, datasources, repositories,
usecases, router, l10n gen, firebase_options) are out of scope for this matrix
and not listed. Commit `71983229` was not touched (see Notes).

Status words used below: `R` = redesigned, `P` = pending, `F` = filed leftover.

## M2 — Auth, shared (`packages/shared_auth/lib/src/presentation/`) — app: shared (all 4)

| screen file | family | status | evidence / planned phase |
|---|---|---|---|
| `pages/login_view.dart` | form | R | tag `ui-phase-2-login-onescreen-done` |
| `pages/forgot_password_view.dart` | form | R | tag `ui-phase-2-login-onescreen-done` |
| `widgets/auth_button.dart` | form | R | tag `ui-phase-2-login-onescreen-done` |
| `widgets/auth_field.dart` | form | R | tag `ui-phase-2-login-onescreen-done` |
| `widgets/auth_guard.dart` | special | R | tag `ui-phase-2-login-onescreen-done` |
| `widgets/auth_error_mapper.dart` | special | R | tag `ui-phase-2-login-onescreen-done` |
| `widgets/auth_notice.dart` | special | R | tag `ui-phase-2-login-onescreen-done` |
| `widgets/auth_password_strength.dart` | form | R | tag `ui-phase-2-login-onescreen-done` |
| `widgets/phone_country.dart` | form | R | tag `ui-phase-2-login-onescreen-done` |
| `widgets/security_badge.dart` | special | R | tag `ui-phase-2-login-onescreen-done` |
| `widgets/auth_loading_view.dart` | special | R | tag `ui-phase-2-login-onescreen-done` |
| `widgets/auth_surface.dart` | special | R | tag `ui-phase-2-login-onescreen-done` |
| `widgets/authenticated_push_notification_scope.dart` | special | R | tag `ui-phase-2-login-onescreen-done` |
| `widgets/auth_step_brand.dart` (step-flow, new) | special | R | tag `ui-phase-2-login-onescreen-done` |
| `widgets/auth_step_resend.dart` (step-flow, new) | special | R | tag `ui-phase-2-login-onescreen-done` |
| `widgets/auth_otp_field.dart` (step-flow, new) | form | R | tag `ui-phase-2-login-onescreen-done` |

## M3 — Staff advisor core (`apps/staff_app/lib/features/advisor/`) — app: staff

Pages:

| screen file | family | status | evidence / planned phase |
|---|---|---|---|
| `presentation/pages/advisor_home_view.dart` | dashboard | R | tag `ui-phase-3-advisor-home-done` |
| `presentation/pages/advisor_jobs_view.dart` | list | R | commit `29891fe5` (merge `60fcf67e`), review 15/16 + adversarial 13/16 PASS |
| `presentation/pages/advisor_job_detail_view.dart` | detail | R | `ui/detail-advisor e1f88b79`, adversarial 16/16 PASS |
| `presentation/pages/advisor_vehicle_checkin_view.dart` | form | P | phase-3 |
| `presentation/pages/advisor_assign_tasks_view.dart` | form | P | phase-3 |
| `presentation/pages/advisor_reports_view.dart` | dashboard | F | phase-3 (filed in sweep: legacy `AppSkeleton.chart`) |
| `presentation/pages/scan_vehicle_view.dart` | special | P | phase-3 |
| `presentation/pages/vehicle_customer_view.dart` | form | P | phase-3 |
| `presentation/pages/vehicle_delivery_view.dart` | detail | R | `ui/detail-group3 87d9126e`, adversarial 14-16 PASS |

Advisor widgets / sheets (reached from done screens vs pending flows):

| screen file | family | status | evidence / planned phase |
|---|---|---|---|
| `presentation/widgets/advisor_search_sheet.dart` | special | R | commit `29891fe5` (existing sheet reused by jobs search) |
| `presentation/widgets/advisor_job_card_row.dart` | list | R | commit `29891fe5` (jobs brief scope) |
| `presentation/widgets/advisor_job_card_sheet.dart` | special | R | commit `29891fe5` (jobs brief scope, chrome only) |
| `presentation/widgets/advisor_notification_sheet.dart` | special | P | phase-3 |
| `presentation/widgets/advisor_notification_row.dart` | special | P | phase-3 |
| `presentation/widgets/advisor_notification_data.dart` | special | P | phase-3 |
| `presentation/widgets/advisor_profile_sheet.dart` | special | P | phase-3 |
| `presentation/widgets/advisor_approval_sheet.dart` | special | P | phase-3 |
| `presentation/widgets/advisor_approval_row.dart` | special | P | phase-3 |
| `presentation/widgets/advisor_contact_sheet.dart` | special | P | phase-3 |
| `presentation/widgets/advisor_contact_option.dart` | special | P | phase-3 |
| `presentation/widgets/advisor_sheet.dart` | special | P | phase-3 |
| `presentation/widgets/advisor_stat_dialog.dart` | special | P | phase-3 |
| `presentation/widgets/advisor_menu_item.dart` | special | P | phase-3 |
| `presentation/widgets/advisor_handle.dart` | special | P | phase-3 |
| `presentation/widgets/advisor_divider.dart` | special | P | phase-3 |
| `presentation/widgets/advisor_detail_line.dart` | special | P | phase-3 |
| `presentation/widgets/advisor_status.dart` | special | P | phase-3 |
| `presentation/widgets/advisor_solid_action.dart` | special | P | phase-3 |
| `presentation/widgets/advisor_outline_action.dart` | special | P | phase-3 |
| `presentation/widgets/advisor_workflow_indicator.dart` | special | P | phase-3 |
| `presentation/widgets/advisor_signature_pad.dart` | special | P | phase-3 |
| `presentation/widgets/job_card_pdf.dart` | special | P | phase-3 |
| `presentation/widgets/job_card_share_sheet.dart` | special | P | phase-3 |
| `presentation/widgets/repair_estimate_math.dart` | special | P | phase-3 |
| `presentation/widgets/repair_estimate_share_sheet.dart` | special | P | phase-3 |
| `presentation/widgets/repair_price_breakdown_dock.dart` | special | P | phase-3 |
| `presentation/widgets/select_brand_sheet.dart` | special | P | phase-3 |

## M4 — Staff advisor inspection & repair — app: staff

| screen file | family | status | evidence / planned phase |
|---|---|---|---|
| `presentation/pages/choose_inspection_view.dart` | form | P | phase-4 |
| `presentation/pages/inspection_sheet_view.dart` | form | P | phase-4 |
| `presentation/pages/inspection_preview_view.dart` | detail | R | `ui/detail-group3 87d9126e`, adversarial 14-16 PASS |
| `presentation/pages/damage_detail_sheet.dart` | special | P | phase-4 |
| `presentation/pages/repair_order_view.dart` (incl. `RepairOrderPreviewView`, same file) | detail | R | `ui/detail-group3 87d9126e`, adversarial 14-16 PASS |
| `presentation/pages/real_damage_canvas.dart` | special | P | phase-4 (fragile canvas; deterministic-stub plan lives in phase-14 notes — NOT a redesign blocker) |
| `inspection_pages/presentation/vehicle_map/hud_pin_bridge.dart` | special | P | phase-4 |
| `inspection_pages/presentation/vehicle_map/vehicle_body_condition_panel.dart` | special | P | phase-4 |
| `inspection_pages/presentation/vehicle_map/vehicle_inspection_map.dart` | special | P | phase-4 |
| `inspection_pages/presentation/vehicle_map/vehicle_map_transform.dart` | special | P | phase-4 |
| `inspection_pages/presentation/widgets/inspection_widgets.dart` | special | P | phase-4 |

## M5 — Staff supervisor + technician + common — app: staff

Supervisor:

| screen file | family | status | evidence / planned phase |
|---|---|---|---|
| `supervisor/presentation/supervisor_dashboard_view.dart` | dashboard | R | tag `ui-phase-5-supervisor-done` (floor) |
| `supervisor/presentation/supervisor_login_view.dart` | form | R | tag `ui-phase-2c-done` (supervisor auth slice) |
| `supervisor/presentation/widgets/supervisor_dashboard_tab.dart` | dashboard | F | phase-5 (filed in sweep) |
| `supervisor/presentation/widgets/supervisor_jobs_tab.dart` | list | R | commit `80ad4613` (merge `06a8fd59`), adversarial re-review 13/16 PASS |
| `supervisor/presentation/widgets/supervisor_queue_tab.dart` | list | R | commit `80ad4613`, adversarial re-review 12/16 PASS |
| `supervisor/presentation/widgets/supervisor_review_tab.dart` | list | R | commit `80ad4613`, adversarial re-review 12/16 PASS |
| `supervisor/presentation/widgets/supervisor_staff_tab.dart` | list | F | phase-5 (filed in sweep) |
| `supervisor/presentation/widgets/supervisor_schedule_tab.dart` | dashboard | F | phase-5 (filed in sweep) |
| `supervisor/presentation/widgets/supervisor_reports_tab.dart` | dashboard | F | phase-5 (filed in sweep) |
| `supervisor/presentation/widgets/supervisor_assign_sheet.dart` | form | F | phase-5 (DETAIL-family session; per-job surface, no detail route) |
| `supervisor/presentation/widgets/supervisor_scaffold.dart` | special | R | tag `ui-phase-5-supervisor-done` (floor + compact nav, integration-1) |
| `supervisor/presentation/widgets/supervisor_components.dart` | special | P | phase-5 |
| `supervisor/presentation/widgets/qc_checklist_sheet.dart` | special | P | phase-5 (entry preserved; internals out of review-tab scope) |
| `supervisor/presentation/widgets/staff_notification_bell.dart` | special | P | phase-5 |
| `supervisor/presentation/widgets/supervisor_floor_search.dart` | special | R | tag `ui-phase-5-supervisor-done` |

Technician:

| screen file | family | status | evidence / planned phase |
|---|---|---|---|
| `technician/presentation/technician_dashboard_view.dart` | dashboard | R | tag `ui-phase-5-technician-done` (shell) |
| `technician/presentation/widgets/technician_today_view.dart` | dashboard | R | tag `ui-phase-5-technician-done` |
| `technician/presentation/widgets/technician_today_search.dart` | special | R | tag `ui-phase-5-technician-done` |
| `technician/presentation/widgets/technician_jobs_view.dart` | list | R | commit `80ad4613`, adversarial re-review 13/16 PASS |
| `technician/presentation/widgets/technician_productivity_view.dart` | dashboard | F | phase-5 (filed in sweep) |
| `technician/presentation/widgets/technician_components.dart` | special | P | phase-5 (`TechnicianJobSummary` STOP boundary per tech-jobs brief) |
| `technician/presentation/widgets/job_detail_sheet.dart` | detail | R | commit `a36d9482`, review 15/16 PASS (2nd-confirmed) |
| `technician/presentation/widgets/parts_request_sheet.dart` | form | P | phase-5 |
| `technician/presentation/widgets/escalation_sheet.dart` | form | P | phase-5 |

Common:

| screen file | family | status | evidence / planned phase |
|---|---|---|---|
| `common/presentation/profile_screen.dart` | settings | R | pre-integration (sweep-verified as done) |
| `common/presentation/simple_pages.dart` | settings | P | phase-5 |
| `common/presentation/staff_attendance_screen.dart` | settings | P | phase-5 |

## M6 — Customer (`apps/customer_app/lib/features/customer/`) — app: customer

Pages:

| screen file | family | status | evidence / planned phase |
|---|---|---|---|
| `presentation/customer_dashboard_view.dart` | dashboard | R | tag `ui-phase-6-customer-home-done` |
| `presentation/customer_book_service_view.dart` | form | P | phase-6 |
| `presentation/customer_booking_detail_view.dart` | detail | R | `ui/detail-group2 6db3ff6c`, adversarial 14-16 PASS |
| `presentation/customer_booking_success_view.dart` | special | P | phase-6 |
| `presentation/customer_approvals_page.dart` | detail | R | `ui/detail-group4 d4a19724`, adversarial 15/16 PASS (overview; base `ui/detail-group2 6db3ff6c`) |
| `presentation/customer_service_status_page.dart` | detail | R | `ui/detail-group2 6db3ff6c`, adversarial 14-16 PASS |
| `presentation/customer_breakdown_help_view.dart` | form | P | phase-6 |
| `presentation/customer_breakdown_result_view.dart` | special | P | phase-6 |
| `presentation/customer_invoice_detail_view.dart` | detail | R | `ui/detail-group2 6db3ff6c`, adversarial 14-16 PASS |
| `presentation/customer_feedback_view.dart` | form | P | phase-6 |
| `presentation/customer_notifications_view.dart` | list | R | commit `b8de9d6d` (merge `3316f86d`), review 16/16 PASS |
| `presentation/add_vehicle_view.dart` | form | P | phase-6 |

Widgets (tabs, rows, sheets, shell):

| screen file | family | status | evidence / planned phase |
|---|---|---|---|
| `presentation/widgets/customer_home_tab.dart` | dashboard | R | tag `ui-phase-6-customer-home-done` |
| `presentation/widgets/customer_home_search_sheet.dart` | special | R | tag `ui-phase-6-customer-home-done` |
| `presentation/widgets/customer_home_hero.dart` | dashboard | R | tag `ui-phase-6-customer-home-done` |
| `presentation/widgets/customer_home_header.dart` | dashboard | R | tag `ui-phase-6-customer-home-done` |
| `presentation/widgets/customer_home_garage.dart` | dashboard | R | tag `ui-phase-6-customer-home-done` |
| `presentation/widgets/customer_home_quick_actions.dart` | dashboard | R | tag `ui-phase-6-customer-home-done` |
| `presentation/widgets/customer_vehicles_tab.dart` | list | R | tag `ui-integration-1-vehicles-done` |
| `presentation/widgets/customer_vehicle_record.dart` | list | R | tag `ui-integration-1-vehicles-done` |
| `presentation/widgets/customer_vehicles_search_sheet.dart` | special | R | tag `ui-integration-1-vehicles-done` |
| `presentation/widgets/customer_vehicles_filter_sheet.dart` | special | R | tag `ui-integration-1-vehicles-done` |
| `presentation/widgets/customer_bookings_tab.dart` | list | R | commit `b8de9d6d`, review 16/16 PASS |
| `presentation/widgets/customer_booking_item.dart` | list | R | commit `b8de9d6d` |
| `presentation/widgets/customer_failed_booking_item.dart` | list | R | commit `b8de9d6d` |
| `presentation/widgets/customer_bookings_search_sheet.dart` | special | R | commit `b8de9d6d` (new) |
| `presentation/widgets/customer_bookings_filter_sheet.dart` | special | R | commit `b8de9d6d` (new) |
| `presentation/widgets/customer_service_status_tab.dart` | detail | R | `ui/detail-group2 6db3ff6c` (tracking experience, same build as status page) |
| `presentation/widgets/customer_status_service_panel.dart` | detail | R | `ui/detail-group2 6db3ff6c` (sub-widget in scope, same build) |
| `presentation/widgets/customer_status_notices.dart` | detail | R | `ui/detail-group2 6db3ff6c` (sub-widget in scope, same build) |
| `presentation/widgets/customer_status_details.dart` | detail | R | `ui/detail-group2 6db3ff6c` (sub-widget in scope, same build) |
| `presentation/widgets/customer_service_journey.dart` | detail | R | `ui/detail-group2 6db3ff6c` (sub-widget in scope, same build) |
| `presentation/widgets/customer_profile_tab.dart` | settings | P | phase-6 |
| `presentation/widgets/customer_profile_rows.dart` | settings | P | phase-6 |
| `presentation/widgets/customer_scaffold.dart` | special | R | tag `ui-phase-6-customer-home-done` (shell; no-rail consumer contract kept) |
| `presentation/widgets/customer_surface_panel.dart` | special | R | commit `b8de9d6d` (states rebuilt on shared atoms) |
| `presentation/widgets/customer_plate_chip.dart` | special | R | tag `ui-integration-1-vehicles-done` |
| `presentation/widgets/customer_notice_panel.dart` | special | R | commit `b8de9d6d` (stale/failure → `AppBanner`) |
| `presentation/widgets/customer_approval_detail_view.dart` | detail | R | `ui/detail-group2 6db3ff6c`, adversarial 14-16 PASS |
| `presentation/widgets/customer_booking_steps.dart` | form | P | phase-6 |
| `presentation/widgets/customer_booking_flow_progress.dart` | form | P | phase-6 |
| `presentation/widgets/customer_booking_detail_vehicle.dart` | detail | R | `ui/detail-group2 6db3ff6c` (sub-widget in scope, same build) |
| `presentation/widgets/customer_booking_detail_summary.dart` | detail | R | `ui/detail-group2 6db3ff6c` (sub-widget in scope, same build) |
| `presentation/widgets/customer_booking_detail_service.dart` | detail | R | `ui/detail-group2 6db3ff6c` (sub-widget in scope, same build) |

Support (14 files):

| screen file | family | status | evidence / planned phase |
|---|---|---|---|
| `presentation/support/customer_vehicle_presentation.dart` | special | R | tag `ui-integration-1-vehicles-done` (truth rules kept verbatim) |
| `presentation/support/customer_bookings_presentation.dart` | special | R | commit `b8de9d6d` (`groupOf`/sort/labels unchanged) |
| `presentation/support/customer_booking_draft.dart` | special | R | commit `b8de9d6d` |
| `presentation/support/customer_booking_relations.dart` | special | R | commit `b8de9d6d` |
| `presentation/support/failed_booking_sync.dart` | special | R | commit `b8de9d6d` (retry/remove kept) |
| `presentation/support/customer_notification_presentation.dart` | special | R | commit `b8de9d6d` (icon/tone/destination rules) |
| `presentation/support/customer_destination.dart` | special | R | commit `b8de9d6d` (deep-link destinations) |
| `presentation/support/vehicle_booking_decision.dart` | special | P | phase-6 |
| `presentation/support/failed_vehicle_delete.dart` | special | P | phase-6 |
| `presentation/support/failed_breakdown_sync.dart` | special | P | phase-6 |
| `presentation/support/customer_service_tracking.dart` | special | P | phase-6 |
| `presentation/support/customer_push_routing.dart` | special | P | phase-6 |
| `presentation/support/customer_l10n.dart` | special | P | phase-6 (key migration itself is phase-11) |
| `presentation/support/customer_approval_presentation.dart` | special | P | phase-6 |

## M7 — Owner (`apps/owner_app/lib/features/`) — app: owner

Dashboard + 9 sub-pages + widgets:

| screen file | family | status | evidence / planned phase |
|---|---|---|---|
| `dashboard/presentation/dashboard_view.dart` | dashboard | R | tag `ui-phase-7-owner-done` |
| `dashboard/presentation/widgets/dashboard_body.dart` | dashboard | R | tag `ui-phase-7-owner-done` |
| `dashboard/presentation/widgets/owner_dashboard_page.dart` | dashboard | R | tag `ui-phase-7-owner-done` |
| `dashboard/presentation/pages/team_view.dart` | settings | F | phase-7 — PROCESS GATE: parallel commit `71983229` owns `team_view`+providers; do not touch until reviewed |
| `dashboard/presentation/pages/subscription_view.dart` | settings | P | phase-7 |
| `dashboard/presentation/pages/pending_approvals_view.dart` | detail | R | `ui/detail-group2 6db3ff6c`, adversarial 14-16 PASS |
| `dashboard/presentation/pages/job_status_view.dart` | dashboard | P | phase-7 |
| `dashboard/presentation/pages/inventory_view.dart` | list | P | phase-7 (AR/inventory tables break on mobile) |
| `dashboard/presentation/pages/feedback_moderation_view.dart` | list | P | phase-7 |
| `dashboard/presentation/pages/document_expiry_view.dart` | detail | R | `ui/detail-group3 87d9126e`, adversarial 14-16 PASS |
| `dashboard/presentation/pages/attendance_view.dart` | settings | P | phase-7 |
| `dashboard/presentation/pages/accounts_receivable_view.dart` | detail | R | `ui/detail-group3 87d9126e`, adversarial 14-16 PASS |
| `dashboard/presentation/widgets/kpi_grid.dart` | dashboard | F | phase-7 (filed in sweep: verify + complete) |
| `dashboard/presentation/widgets/owner_activity_feed_tab.dart` | special | F | phase-7 (filed in sweep) |
| `dashboard/presentation/widgets/messages_page.dart` | special | F | phase-7 (filed in sweep) |
| `dashboard/presentation/widgets/top_sales_page.dart` | dashboard | F | phase-7 (filed in sweep) |
| `dashboard/presentation/widgets/period_dropdown.dart` | special | P | phase-7 |
| `dashboard/presentation/widgets/owner_search.dart` | special | P | phase-7 |

Job cards:

| screen file | family | status | evidence / planned phase |
|---|---|---|---|
| `job_cards/presentation/pages/job_cards_list_view.dart` | list | R | commit `80ad4613` (merge `06a8fd59`), review 16/16 + adversarial 15/16 PASS |
| `job_cards/presentation/pages/job_cards_search_sheet.dart` | special | R | commit `80ad4613` (new) |
| `job_cards/presentation/pages/job_card_detail_view.dart` | detail | R | pre-integration (sweep-verified as done) |
| `job_cards/presentation/widgets/job_status_ui.dart` | special | R | commit `80ad4613` (read-only helpers, shared with detail) |

## M8 — CRM (`apps/crm_app/lib/features/crm_dashboard/`) — app: crm

| screen file | family | status | evidence / planned phase |
|---|---|---|---|
| `presentation/crm_dashboard_view.dart` | dashboard | P | phase-8 (shell; hosts tab pages below) |
| `presentation/widgets/crm_dashboard_page.dart` | dashboard | F | phase-8 (filed in sweep: partial header, legacy pills/containers) |
| `presentation/widgets/crm_leads_page.dart` | list | R | commit `7b305f9e` (merge `a8718a82`), review 16/16 PASS |
| `presentation/widgets/crm_tasks_page.dart` | list | R | commit `7b305f9e`, review 16/16 PASS |
| `presentation/widgets/crm_sales_team_page.dart` | list | R | commit `7b305f9e`, review 16/16 PASS |
| `presentation/widgets/crm_leads_search_sheet.dart` | special | R | commit `7b305f9e` (new) |
| `presentation/widgets/crm_leads_filter_sheet.dart` | special | R | commit `7b305f9e` (new) |
| `presentation/widgets/crm_tasks_search_sheet.dart` | special | R | commit `7b305f9e` (new) |
| `presentation/widgets/crm_sales_team_search_sheet.dart` | special | R | commit `7b305f9e` + wave-2 `83b07d29` (new) |
| `presentation/support/lead_contact_actions.dart` | special | R | commit `7b305f9e` (new) |
| `presentation/widgets/crm_kanban_view.dart` | special | F | phase-8 (filed: kept verbatim per leads brief, next slice) |
| `presentation/widgets/crm_conversations_page.dart` | list | F | phase-8 (filed in sweep: master-detail rebuild) |
| `presentation/widgets/crm_reports_page.dart` | dashboard | F | phase-8 (filed in sweep: chart-card rebuild) |
| `presentation/widgets/crm_integrations_page.dart` | settings | F | phase-8 (filed in sweep: sheet/state rebuild) |
| `presentation/widgets/crm_settings_page.dart` | settings | F | phase-8 (filed in sweep: verify rows/states) |
| `presentation/widgets/lead_form_sheet.dart` | form | F | phase-8 (filed: migrates with its owning flow) |
| `presentation/widgets/lead_detail_sheet.dart` | detail | R | `ui/detail-group3 87d9126e`, adversarial 14-16 PASS |
| `presentation/widgets/connect_integration_sheet.dart` | form | F | phase-8 (filed: migrates with its owning flow) |
| `presentation/widgets/crm_pipeline_widget.dart` | dashboard | F | phase-8 (filed in sweep: rebuilds with dashboard surface) |
| `presentation/widgets/crm_followups_widget.dart` | list | F | phase-8 (filed in sweep) |
| `presentation/widgets/crm_activity_feed_widget.dart` | dashboard | F | phase-8 (filed in sweep) |
| `presentation/widgets/crm_recent_leads.dart` | list | F | phase-8 (filed in sweep) |
| `presentation/widgets/crm_channel_widgets.dart` | special | F | phase-8 (filed in sweep) |
| `presentation/widgets/crm_drawer.dart` | special | F | phase-8 (filed in sweep) |

## Counts per app

| app | screens | redesigned | pending / filed leftover |
|---|---|---|---|
| shared (all 4, M2 auth) | 16 | 16 | 0 |
| staff (M3+M4+M5) | 75 | 22 | 53 |
| customer (M6) | 58 | 41 | 17 |
| owner (M7) | 22 | 10 | 12 |
| crm (M8) | 24 | 9 | 15 |
| TOTAL | 195 | 98 | 97 |

## Counts per family

| family | screens | redesigned | pending / filed leftover |
|---|---|---|---|
| dashboard | 26 | 13 | 13 |
| list | 22 | 16 | 6 |
| detail | 23 | 23 | 0 |
| form | 24 | 8 | 16 |
| settings | 10 | 1 | 9 |
| special (sheets/rows/shells/support/empty-error variants) | 90 | 37 | 53 |
| TOTAL | 195 | 98 | 97 |

## Pending screens by planned phase (97)

- phase-3 (staff advisor core, 30): `advisor_vehicle_checkin_view`,
  `advisor_assign_tasks_view`, `advisor_reports_view`, `scan_vehicle_view`,
  `vehicle_customer_view` + 25 advisor widgets/sheets
  (all except search/job-card-row/job-card-sheet).
- phase-4 (inspection & repair, 9): `choose_inspection_view`, `inspection_sheet_view`,
  `damage_detail_sheet`, `real_damage_canvas`, `hud_pin_bridge`,
  `vehicle_body_condition_panel`, `vehicle_inspection_map`, `vehicle_map_transform`,
  `inspection_widgets`.
- phase-5 (supervisor/technician/common, 14):
  `supervisor_dashboard_tab`, `supervisor_staff_tab`, `supervisor_schedule_tab`,
  `supervisor_reports_tab`, `supervisor_assign_sheet`, `supervisor_components`,
  `qc_checklist_sheet`, `staff_notification_bell`, `technician_productivity_view`,
  `technician_components`,
  `parts_request_sheet`, `escalation_sheet`, `simple_pages`, `staff_attendance_screen`.
- phase-6 (customer, 17): `customer_book_service_view`,
  `customer_booking_success_view`,
  `customer_breakdown_help_view`, `customer_breakdown_result_view`,
  `customer_feedback_view`, `add_vehicle_view`,
  `customer_profile_tab`,
  `customer_profile_rows`, `customer_booking_steps`,
  `customer_booking_flow_progress` + 7 support files
  (`vehicle_booking_decision`, `failed_vehicle_delete`, `failed_breakdown_sync`,
  `customer_service_tracking`, `customer_push_routing`, `customer_l10n`,
  `customer_approval_presentation`).
- phase-7 (owner, 12): `team_view` (gated on `71983229` review), `subscription_view`,
  `job_status_view`, `inventory_view`, `feedback_moderation_view`,
  `attendance_view`, `kpi_grid`,
  `owner_activity_feed_tab`, `messages_page`, `top_sales_page`, `period_dropdown`,
  `owner_search`.
- phase-8 (CRM, 15): `crm_dashboard_view`, `crm_dashboard_page`, `crm_kanban_view`,
  `crm_conversations_page`, `crm_reports_page`, `crm_integrations_page`,
  `crm_settings_page`, `lead_form_sheet`, `connect_integration_sheet`,
  `crm_pipeline_widget`, `crm_followups_widget`, `crm_activity_feed_widget`,
  `crm_recent_leads`, `crm_channel_widgets`, `crm_drawer`.

## Notes

- Technical blockers: ZERO. No screen has a platform/third-party limitation that
  forces keeping a legacy widget; every non-redesigned screen has an owner phase
  above. (`real_damage_canvas` fragility is handled by deterministic stubbing in
  the golden phase, not by skipping the redesign.)
- `71983229` (parallel staff-management work: `team_view` + providers + Java
  backend) was not reviewed and was not touched; owner `team_view` stays pending
  phase-7 behind that review.
- DETAIL family: technician `job_detail_sheet` brief is written and awaiting user
  approval (no build yet); advisor detail + supervisor assign sheet follow the same
  pattern in their own builds (owner phases: phase-5 / phase-3).
- Auth supervisor slice is covered by tag `ui-phase-2c-done`; customer dark wiring
  was kept on every rebuilt customer surface (no regression claimed without captures).
