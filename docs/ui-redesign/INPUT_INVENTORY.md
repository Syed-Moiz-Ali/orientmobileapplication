# Input inventory (phase-1b; read-only — do NOT touch these files)

Counts are constructor/call-site hits. Module phases migrate each screen to
`AppInputField` / `AppSearchBar` / `AppDropdown` / selection tiles.

## staff_app (`apps/staff_app/lib`) — densest, migrate first (3a–3c, 5)

| File | Hits | What lives there (spot-checked) |
|---|---|---|
| `features/advisor/presentation/pages/vehicle_customer_view.dart` | 18 | vehicle intake form (plate/VIN/owner/phone fields) |
| `features/advisor/presentation/pages/repair_order_view.dart` | 11 | estimate line items, notes, price inputs |
| `features/advisor/presentation/pages/advisor_vehicle_checkin_view.dart` | 6 | check-in form (odometer, fuel, notes) |
| `features/advisor/presentation/widgets/parts_request_sheet.dart` | 6 | parts quantity/search |
| `features/advisor/presentation/pages/inspection_sheet_view.dart` | 5 | inspection checkpoints, notes |
| `features/advisor/presentation/pages/advisor_assign_tasks_view.dart` | 4 | assign search + notes |
| `features/advisor/presentation/widgets/supervisor_assign_sheet.dart` | 4 | assign search + notes |
| `features/advisor/presentation/pages/supervisor_login_view.dart` | 4 | login identifier + password |
| `features/advisor/inspection_pages/presentation/vehicle_map/vehicle_body_condition_panel.dart` | 4 | damage notes |
| `features/advisor/presentation/pages/advisor_home_view.dart` | 3 | home search |
| `features/advisor/presentation/pages/advisor_jobs_view.dart` | 3 | jobs search + filters |
| `features/advisor/presentation/pages/advisor_job_detail_view.dart` | 2 | detail notes/actions |
| `features/advisor/presentation/pages/scan_vehicle_view.dart` | 2 | manual plate/VIN fallback |
| `features/advisor/presentation/pages/damage_detail_sheet.dart` | 2 | damage notes |
| `features/advisor/presentation/widgets/advisor_search_sheet.dart` | 2 | search sheet |
| `features/advisor/presentation/widgets/qc_checklist_sheet.dart` | 2 | QC notes |
| `features/advisor/presentation/widgets/escalation_sheet.dart` | 2 | escalation reason |
| `features/advisor/presentation/pages/vehicle_delivery_view.dart` | 4 | delivery checklist/notes |
| `features/advisor/presentation/pages/technician...` (supervisor/tech/common) | ~10 | queue search, staff search, job search, login |
| `features/technician/.../technician_providers.dart` | 1 | controller owned by provider |

Totals: raw `TextField(` 28 · shared `AppTextField(` 14 · `AppSearchField(` 10 · `AppDropdownButton(`/`AppSelectField(` 11 · `TextEditingController` 38 · `obscureText` 1 · phone keyboard 1 · number keyboards 3.

## owner_app (`apps/owner_app/lib`)

| File | Hits |
|---|---|
| `features/dashboard/presentation/pages/team_view.dart` | 22 (member search + invite/edit form) |
| `features/dashboard/presentation/pages/inventory_view.dart` | 12 (part search, stock counts) |
| `features/dashboard/presentation/widgets/owner_dashboard_page.dart` → `messages_page.dart` | 5 (message composer) |
| `features/dashboard/presentation/pages/accounts_receivable_view.dart` | 2 |
| `features/dashboard/presentation/pages/document_expiry_view.dart` | 2 |
| `features/dashboard/presentation/pages/job_status_view.dart` | 2 |
| `features/job_cards/presentation/pages/job_cards_list_view.dart` | 2 (list search) |

Totals: raw `TextField(` 15 · `AppTextField(` 15 · `AppSearchField(` 6 · dropdowns 3 · controllers 23 · obscure 2 · phone 1 · number 3.

## customer_app (`apps/customer_app/lib`)

| File | Hits |
|---|---|
| `features/customer/presentation/add_vehicle_view.dart` | 21 (plate/VIN/year/odometer form — biggest customer form) |
| `features/customer/presentation/support/customer_booking_steps.dart` | 4 |
| `features/customer/presentation/customer_breakdown_help_view.dart` | 4 (location/phone/description) |
| `features/customer/presentation/customer_feedback_view.dart` | 3 (rating + comment) |
| `features/customer/presentation/customer_book_service_view.dart` | 2 |

Totals: raw `TextField(` 12 · `AppTextField(` 7 · controllers 22 · number keyboards 1. No `AppSearchField`/`AppDropdownButton` — search lives in tab bars (custom), vehicle pickers are custom sheets.

## crm_app (`apps/crm_app/lib`)

| File | Hits |
|---|---|
| `features/crm_dashboard/presentation/widgets/lead_form_sheet.dart` | 20 (lead create/edit — biggest CRM form) |
| `features/crm_dashboard/presentation/widgets/crm_tasks_page.dart` | 8 (task title/notes) |
| `features/crm_dashboard/presentation/widgets/connect_integration_sheet.dart` | 7 (API keys/URLs) |
| `features/crm_dashboard/presentation/widgets/crm_leads_page.dart` | 1 (leads search) |

Totals: raw `TextField(` 4 · `AppSearchField(` 1 · controllers 31 · obscure 1.

## shared_auth (login/OTP for all apps)

- `presentation/widgets/auth_field.dart` — shared identifier/password field + **`Pinput`** OTP (6-digit one-time code, `pinput` package). Module phase-2 migrates to `AppInputField`; OTP stays `Pinput` styled via tokens.
- `presentation/widgets/phone_country.dart` — dial-code selector data + UI (`phoneCountries`, `phoneCountryFor`). Customer login (`allowRegistration`) and staff login both use phone identifiers → `AppInputField(forceLtr: true)` + country row in phase-2/6.
- `presentation/widgets/auth_password_strength.dart` — password meter (keep logic, restyle in phase-2).

## Variant → AppInputField mapping (for module phases)

- Plain text / email / name → `AppInputField`, `forceLtr: true` for email/identifier/URL.
- Phone / OTP / number / plate / VIN → `forceLtr: true` + matching `keyboardType` + `inputFormatters` (digits-only where applicable). Western digits stay (policy).
- Password → `obscureText: true, passwordToggle: true`.
- Search rows/sheets → `AppSearchBar` (with clear button).
- Dropdowns/selects (`AppDropdownButton` ×14 + crm channel maps) → `AppDropdown` (+ `searchable: true` for long lists).
- Multiline notes/descriptions/comments → `maxLines: 3+` + `showCounter` where a limit exists.
- Checkbox/switch/radio rows → `AppCheckTile` / `AppSwitchTile` / `AppRadioTile`.
