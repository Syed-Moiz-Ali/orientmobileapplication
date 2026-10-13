# 00 — Project Analysis (Actual Repository Findings)

This document records what the repository actually contains. It is the shared
context for every phase prompt. All paths are relative to the workspace root
`orientmobileapplication/`.

---

## 1. Framework, tooling and architecture

| Item | Value |
|---|---|
| Framework | Flutter (stable channel), Dart SDK `^3.9.2` |
| Workspace | Melos 8 (`melos.yaml`), packages globs `packages/*`, `apps/*` |
| State management | Riverpod `flutter_riverpod ^2.6.1` (StateNotifier/Provider families) |
| Routing | `go_router ^17.1.0`, one `appRouterProvider` per app with auth redirects |
| Local persistence | Hive (`hive`, `hive_flutter`) + `flutter_secure_storage` for tokens |
| Networking | Dio (`dio ^5.7/5.9`) + interceptors (`envelope_interceptor`, `retry_interceptor`, `auth_interceptor`) |
| Notifications | Firebase Core/Messaging 4.x/16.x + `flutter_local_notifications` |
| Charts | `fl_chart` (staff advisor reports, CRM reports); custom `CustomPainter`s (owner dashboard, CRM reports) |
| Media/device | `mobile_scanner`, `image_picker`, `video_player`, `audioplayers`, `permission_handler`, `path_provider`, `share_plus`, `url_launcher` |
| Auth UX | `pinput` OTP fields |
| Backend | Spring Boot monorepo in `orient-workshop-backend/` (out of scope for UI redesign; API contracts must be preserved) |
| CI | `.github/workflows/ci.yml` — gitleaks, `melos run analyze`, `melos run test`, backend Maven tests, seamless-flow E2E harness, 4 APK builds |

Apps and packages:

```
apps/staff_app       Advisor + Supervisor + Technician role workspace (largest app)
apps/owner_app       Workshop owner dashboard + operations + finance
apps/customer_app    Customer portal (bookings, tracking, approvals, garage)
apps/crm_app         CRM workspace (leads, pipeline, tasks, conversations)
packages/shared_core  Design system, widgets, responsive layer, network, sync, models
packages/shared_auth  Login / OTP / registration / password recovery surfaces
packages/shared_models Role + job-card-status enums
```

---

## 2. Existing design system (what exists today)

### 2.1 Tokens — `packages/shared_core/lib/src/theme/`

| File | Contents |
|---|---|
| `app_colors.dart` | Semantic palette: canvas `#F5F7FB`, surface white, navy `#14213D`, primary cobalt `#3157D5`, success/warning/danger/info sets, borders, legacy aliases |
| `app_dimensions.dart` | 4-pt spacing scale (`s4…s64`), semantic radii (`radiusXs 4 … radiusSheet 22, radiusPill 999`), gutters, shadows (`shadowSurface/Card/Modal/Navy`), icon sizes, `touchTarget 48`, content widths (560/1180/1320) |
| `app_text_styles.dart` | `AppFontFamilies.app = 'packages/shared_core/Plus Jakarta Sans'`; roles: displayLarge/Medium/Small, pageTitle, sectionTitle, cardTitle, bodyStrong/body/bodySmall, label, eyebrow, metadata, caption, tableHeader, metric (tabular), button, mono* (aliases) |
| `app_motion.dart` | Durations 100/160/220/280 ms + enter/exit/standard curves |
| `app_theme.dart` | `AppTheme.light(brand)` and `AppTheme.dark(brand)` — Material 3 `ColorScheme.fromSeed`, full component themes (buttons, inputs, cards, dialogs, sheets, nav bar/rail, chips, snackbars, checkboxes, switches, tooltips) |
| `brand_config.dart` | `BrandConfig {appName, tagline, icon, iconColor, accentColor, buttonColor}`; `BrandConfig.orient`; `brandConfigProvider` + `overrideBrandConfigProvider` (white-label hook, currently unused) |

### 2.2 Responsive layer — `packages/shared_core/lib/src/layout/`

- `app_responsive.dart`:
  - `AppWindowClass {compact ≤599, medium ≤1023, expanded ≤1439, large >1439}`
  - `AppDeviceClass {smallMobile <360, mobile <430, largeMobile <600, tablet <1024, desktop <1600, largeDesktop ≥1600}`
  - `AppAdaptiveSpec` (page padding, content/form/dialog max widths, gutter, section/item spacing, control height, radius, grid columns 1–4, `useNavigationRail`, `extendNavigationRail`, rail width, keyboard state)
  - `AppResponsivePage`, `AppAdaptiveGrid`, `AppSplitView`, `AppAdaptiveBuilder`, `context.adaptive` extension
- `app_adaptive_navigation.dart`:
  - `AppNavItem`, `OrientBrandMark`, `AppBottomNavigation` (with "More" overflow beyond `maxDestinations=5`), `AppNavigationRail` (compact 78 px / extended 224 px), `AppAdaptiveNavigationFrame`, `AppNavDrawer`
  - Shared selection language: cobalt tint 12 %, filled icon, heavier label, haptics, semantics labels ("Label, N new")
- `widgets/dashboard_shell.dart`: authenticated frame — app bar slot, `OfflineBanner`, system-bar `AnnotatedRegion`, `ExitConfirmationWrapper`, `FocusTraversalGroup`, body SafeArea handling.

### 2.3 Shared widgets — `packages/shared_core/lib/src/widgets/` (32 files)

Key primitives: `AppCard`, `AppPageFrame`, `AppPageHeader`, `AppTopBar`, `AppSearchField`, `AppTextField`, `AppDropdownButton`, `AppRecordRow`, `AppKpiCard`, `AppInfoPanel`, `AppActionBar`, `PrimaryButton/SecondaryButton/AppButton`, `AppBottomSheet` (`showAppModalSheet`), `AppConfirmationDialog`, `AppFormField/AppFormSection/AppFormPanel/AppDateSelectorShell/AppMediaUploadShell`, `AppLinearProgress/AppStepProgress`, `AppSkeleton`, `EmptyState`, `ErrorView`, `StatusPill`, `SectionHeader`, `UserAvatar`, `NotificationBell`, `GradientBanner`, `MarkdownText`, `LoadingIndicator/ShimmerLoading`, `LogoutDialog`, `ProfileSheet`, `OfflineBanner`, `ResumeRefreshScope`, `ExitConfirmationDialog`.

### 2.4 The consistency gap (why a coordinated redesign is needed)

- A previous partial pass modernized some surfaces; **substantial portions remain hand-rolled**:
  - staff_app: ~58 of ~86 widget-bearing files do not use shared primitives; the advisor legacy kit, technician support sheets, `job_detail_sheet.dart`, `vehicle_customer_view.dart` (~3 200 lines) and `repair_order_view.dart` (~2 900 lines) hand-roll containers/colors.
  - owner_app: 11 standalone pages hand-roll `Scaffold`+`AppBar`; ~85 hard-coded hex colors in 11 files; 6+ duplicated ad-hoc search fields.
  - customer_app: ~15 files / ~21 call sites hand-roll grouped surfaces; `AppPageHeader`, `ErrorView`, `AppSkeleton` unused; dead `customer_empty_fallbacks.dart`.
  - crm_app: a parallel navy/cyan palette in `crm_constants.dart` and hand-rolled cards coexist with theme tokens.
- Loading UX is inconsistent (shimmer in some places, `CircularProgressIndicator` in others, silent catches elsewhere).
- `TextScaler.linear(0.85)` is forced in all four `main.dart` files — this is an accessibility defect to fix in Phase 01.

---

## 3. Per-app architecture and workflows

### 3.1 staff_app — roles and flows

Entry: `lib/main.dart` → `ProviderScope` (logger + Dio with `AuthInterceptor`) → `MaterialApp.router` (`AppTheme.light`) with `ResumeRefreshScope` + `AuthenticatedPushNotificationScope`. Startup recovery `recoverUnsyncedAdvisorIntakes()` and connectivity-triggered sync flush.

Router (`lib/core/router/app_router.dart`): `/` splash, `/login`, `/forgot-password`, `/supervisor-login`; role dashboards `/advisor_home_view`, `/supervisor_dashboard_view`, `/technician-dashboard`; advisor flow routes `/scan-vehicle`, `/vehicle-customer`, `/advisor/check-in`, `/advisor/job-detail`, `/choose-inspection`, `/inspection-sheet`, `/inspection-preview`, `/repair-order`, `/repair-order-preview`; supervisor sub-pages `/supervisor/{assign,jobs,queue,review,staff,schedule,reports}`; technician `/technician/job-detail`; common `/profile`, `/shift-details`, `/settings`, `/attendance`. Redirect logic enforces role allow-lists (`_isRouteAllowedForRole`).

Role workspaces:

- **Advisor** (`features/advisor/`): `AdvisorHomeView` = `DashboardShell` + adaptive nav with 3 tabs (Today / Jobs / Reports) + notification/profile sheets. Core flow: scan VIN/QR or open a booking → `VehicleCustomerView` intake (customer, vehicle, docs, media, signatures, job description) → `AdvisorVehicleCheckinView` (odometer/fuel/damage) → `ChooseInspectionView` → `InspectionSheetView` (checkpoints + interactive vehicle damage map + media/audio) → `InspectionPreviewView` → `RepairOrderView` estimate builder (services/parts line items, media, tags) → `RepairOrderPreviewView` (signature + approval method) → `VehicleDeliveryView` (handover checks + finalize). `AdvisorJobDetailView` is the workspace hub; `AdvisorAssignTasksView` assigns work items to technicians. Heavy offline behavior: intake payloads persisted to Hive and replayed by the sync engine.
- **Supervisor** (`features/supervisor/`): `SupervisorScaffold` = `DashboardShell` + adaptive nav, 5 tabs (Today / Assign / Queue / Review / Profile) + queue badge + "Save and assign" FAB on Assign. Today surfaces attention queues + a 4-tile navigation matrix to sub-pages; `QcChecklistSheet` performs QC sign-off (reject requires notes); `StaffNotificationBell` polls with badge.
- **Technician** (`features/technician/`): `TechnicianDashboardView` = 4 tabs (Today / Jobs / Productivity / Profile). Today = punch in/break/out shift controls + active job + quick actions; job execution in `job_detail_sheet.dart` (start/hold/complete tasks, complete repair, request parts, escalate); `PartsRequestSheet`, `EscalationSheet`.
- **Common**: `StaffProfileScreen` (`/profile`, also embedded as a tab), `StaffAttendanceScreen` (`/attendance`), `ShiftDetailsPage`, `SettingsPage` (`lib/features/common/presentation/simple_pages.dart`), `SupervisorSubPageWrapper` (router).

Tests: `test/advisor_experience_test.dart`, `technician_experience_test.dart` (+ per-screen tests), `supervisor_experience_test.dart`, `staff_experience_test.dart`, `staff_common_test.dart`, `logic_test.dart`, golden PNGs under `test/goldens/`.

### 3.2 owner_app — operations workflows

Entry/theme identical pattern. Router: `/owner-dashboard`, `/accounts-receivable`, `/document-expiry`, `/job-status`, `/pending-approvals`, `/job-cards`, `/job-cards/detail`, `/inventory`, `/feedback-moderation`, `/subscription`, `/attendance`, `/team` + shared auth routes. Owner-only role gate.

Dashboard shell: `DashboardView → DashboardBody` = `DashboardShell` + adaptive nav + 4 tabs (Dashboard / Top Sales / Messages / Activity). Tab 0 sections: `HeaderBanner` → KPI grid → Job Card Register → Analytics (`SalesTrendCard` + `SalesVsExpensesCard`, custom painters) → 12 Quick Actions (9 push routes + 2 tab switches + subscription). Data: `dashboardUiProvider`, `jobCardsProvider`, team/subscription/moderation/inventory/AR/attendance providers; resume + pull-to-refresh reload. Message broadcast (`MessagesPage`) posts to active staff.

Tests: `chart_painters_test.dart`, `logic_test.dart`, `responsive_dashboard_widgets_test.dart` (320/390/800/1440 px overflow checks).

### 3.3 customer_app — customer workflows

Router: `/customer_dashboard_view?tab=` (Home / Bookings / Vehicles / Profile via `CustomerDestination`), contextual pushed pages `/customer_service_status` (+ legacy redirect), `/customer_approvals?estimateId=`, `/customer_book_service_view?vehicleId=`, `/customer_breakdown_help_view` → `/customer_breakdown_result`, `/customer_booking_detail`, `/booking-success`, `/invoice-detail`, `/add-vehicle` + `/edit-vehicle/:id`, `/notifications`, `/feedback`; `_RouteErrorPage` fallbacks for unusable deep links.

Flow highlights: 4-step booking wizard (vehicle → service → schedule with real slots → review) with offline queueing; live service tracking with a real stage timeline; estimate approval/rejection with financial breakdown; invoice detail; roadside breakdown request with offline "saved on device" recovery; vehicle garage with vehicle identity reconciliation (temp id ↔ server id) and failed-delete recovery; notification inbox with mark-all-read; 3-step feedback. Deliberate offline UX everywhere (`CustomerRefreshNotice`, `_FailedRequestRecovery`, "NOT SENT" booking rows).

Tests: 24 test files + ~70 golden baselines (workspace tabs, booking flow, approvals, breakdown offline, notifications, identity sync).

### 3.4 crm_app — CRM workflows

Single workspace route `/crm_dashboard_view`; all 8 sections are tabs inside `CrmDashboardView` (IndexedStack + `crmUiProvider.selectedIndex`): Dashboard, Leads (list ↔ kanban), Conversations, Sales Team, Tasks, Reports, Integrations, Settings. Drawer (`AppNavDrawer`) + adaptive rail; `CrmAppBar` per-tab titles + refresh + notification bell + profile sheet. Sheets: `LeadFormSheet` (create/edit), `LeadDetailSheet` (status, timeline, edit, delete), `ConnectIntegrationSheet` (Meta/Zoho credentials), task form sheet. Local `crm_constants.dart` navy/cyan palette duplicates tokens.

CI note: no widget tests for CRM pages currently.

### 3.5 shared_auth — auth workflows

`LoginView` (password / email-OTP / SMS-OTP / customer registration; identifier auto-detect; 6-digit `pinput` OTP; 30 s resend cooldown), `ForgotPasswordView` (identifier → code + new password → done; UAE +971 default), `AuthLoadingView` (session restore splash + semantics), `SupervisorLoginView` (staff app local alternate). `AuthShell` responsive scaffold (compact column / boxed card / ≥900 px split identity + form). All copy hard-coded English; workshop-specific wording leaks into CRM (`SecurityBadge`).

---

## 4. Functional behavior that must be preserved (cross-app)

1. Route paths, names and `extra` contracts (entities/maps) — including the customer legacy `?tab=` redirects and `/customer_service_status_view` compat route.
2. Role/permission gating (`_isRouteAllowedForRole`, owner-only/customer-only/staff-only redirects, permission-dependent actions such as supervisor QC reject-with-notes).
3. Riverpod provider names/shapes used by tests and cross-feature logic; Hive cache keys; sync engine operations & offline queue semantics; `recoverUnsyncedAdvisorIntakes` startup path.
4. API contracts (Dio clients, DTOs in `shared_core/lib/src/models`, `shared_models` enums, `ApiResponse` envelopes); Firebase push registration/token rotation; deep-link destinations (`customer_push_routing.dart`).
5. Existing test suites and golden baselines (updated only in the phase that intentionally redesigns the corresponding screen).
6. `EnvironmentConfig` `.env` requirements and fail-fast startup behavior (CI writes `BASE_URL`).

---

## 5. Coverage limitation statement

The screen inventory in `00_SCREEN_COVERAGE_MATRIX.md` covers every user-facing
widget class discovered under `lib/features/**` in the four apps plus the auth
package during this analysis. Two categories are marked for confirmation inside
the phases that consume them:

- **Dead/legacy UI** (e.g. advisor `AdvisorBody`/`AdvisorTabPanel` chain,
  `AdvisorJobCardSheet`, `CustomerTagSheet`, `customer_empty_fallbacks.dart`,
  `AuthBackground`, `AuthHeader`, `PhoneInputField`, `OtpInputField`): planned
  for removal in the phase owning that module, after confirming zero references.
- **Not-implemented affordances** (`PendingApprovalsView` chevron rows with no
  `onTap`; CRM conversation rows with no tap handler; `/feedback` with no
  in-app entry point): treated as *UX-completion* items inside their phase,
  wired only to existing repository methods — no invented backend features.
