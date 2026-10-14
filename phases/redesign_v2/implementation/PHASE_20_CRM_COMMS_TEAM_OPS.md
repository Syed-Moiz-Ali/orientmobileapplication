# PHASE 20 — CRM Application: Omnichannel Messaging, Sales Team & Admin Settings

**Document ID:** `phases/redesign_v2/implementation/PHASE_20_CRM_COMMS_TEAM_OPS.md`  
**Prerequisites:** Phase 19 Completed (`REPORT_PHASE_19.md`)  
**Target Package:** `apps/crm_app/lib/features/crm_dashboard/presentation/`  
**Status:** READY FOR IMPLEMENTATION (Gate 20)  

---

## 1. Primary User & Engineering Objective
Complete redesign of the CRM application's omnichannel conversations console, sales team performance leaderboard, conversion analytics reports, 3rd-party integrations, and administrative settings using **Archetype 10: Live Comms & Dispatch Console**, **Archetype 8: Executive Cockpit & Financial Desk**, and **Archetype 11: System Configuration & User Settings**.

---

## 2. Real Repository File Paths
- `apps/crm_app/lib/features/crm_dashboard/presentation/widgets/crm_conversations_page.dart` (R6)
- `apps/crm_app/lib/features/crm_dashboard/presentation/widgets/crm_sales_team_page.dart` (R7)
- `apps/crm_app/lib/features/crm_dashboard/presentation/widgets/crm_reports_page.dart` (R8)
- `apps/crm_app/lib/features/crm_dashboard/presentation/widgets/crm_integrations_page.dart` (R9)
- `apps/crm_app/lib/features/crm_dashboard/presentation/widgets/crm_settings_page.dart` (R10)
- `apps/crm_app/lib/features/crm_dashboard/presentation/widgets/connect_integration_sheet.dart` (R11)
- `apps/crm_app/lib/features/crm_dashboard/presentation/widgets/crm_channel_widgets.dart`
- `apps/crm_app/test/features/crm/crm_comms_admin_test.dart`

---

## 3. Screen Redesign Requirements
1. **`CrmConversationsPage` (R6) & `crm_channel_widgets.dart`:**
   - Unified multi-channel inbox: WhatsApp Business, SMS, Web Chat, and In-App messages in a clean split-pane console.
   - Master conversation list with unread badges, channel iconography, and timestamp.
   - Detail chat view with template canned responses, quote insertion shortcut, and customer profile sidebar.
2. **`CrmSalesTeamPage` (R7):**
   - Agent leaderboard ranking: Deals Won, Revenue Generated (AED), Response Time (Mins), and Lead Conversion Ratio.
3. **`CrmReportsPage` (R8):**
   - Analytical reporting suite: Monthly lead volume bar charts, channel acquisition pie/donut chart, and lost deal reason analysis.
4. **`CrmIntegrationsPage` (R9), `CrmSettingsPage` (R10) & `ConnectIntegrationSheet` (R11):**
   - Connected apps hub (Meta Ads, WhatsApp Cloud API, Google Business Profile) with real-time sync status badges.
   - Lead routing configuration rules (Round Robin, Bay Specialist, Shift Active).

---

## 4. Visual Acceptance Criteria
- Desktop & Tablet: Sophisticated 3-pane comms layout (Channel List -> Active Thread -> Customer Dossier).
- Mobile: Fluid sliding drilldown between inbox list and conversation thread.
- Golden tests generated with real fonts loaded across Mobile (390px EN/AR), Tablet (834px), and Desktop (1280px).

---

## 5. Dual Gate Verification
### Gate 1: Engineering Validation
- `dart analyze apps/crm_app` returns 0 errors and 0 warnings.
- `crm_comms_admin_test.dart` passes 100% across all viewports.

### Gate 2: Visual Aesthetic Validation
- Golden screenshots captured across Mobile (390px EN/AR), Tablet (834px), and Desktop (1280px) with real fonts.
- Generates `phases/redesign_v2/reports/REPORT_PHASE_20.md`.


---

## Styling Authority (Phase 01.1 � Mandatory)
All styling in this phase MUST resolve through the single centralized theme system. Do not select light/dark colors by hand.

- Standard Material roles -> `context.colors` (`ColorScheme`).
- Custom automotive/workshop roles -> `context.semanticColors` (`AppSemanticColors` ThemeExtension).
- **Forbidden:** `dark ? AppDarkColors.x : AppColors.x` ternaries; direct `AppColors.*` / `AppDarkColors.*` palette selection in feature widgets; hardcoded semantic hex; duplicate local theme systems or competing theme providers; hardcoded font styles, spacing, or radii where a theme or `AppDimensions` token exists.
- **Justified exceptions** (brand assets, theme construction, color previews, brightness-dependent behavior) must carry a one-line documented reason.
- Full rules: `00_CONCEPT_A_DESIGN_SYSTEM.md` Sec.6 and `reports/PHASE_01_1_THEME_ARCHITECTURE.md`.

---

## Centralized Widgets (Phase 01.2 — Mandatory)
All UI in this phase MUST reuse `packages/shared_core` centralized widgets. Never build a per-app duplicate when a shared widget exists.

- Use existing: `WorkspaceAppBar`, `DashboardShell`, `OfflineStatusPill`, `AppBreadcrumbs`, `AppPageHeader`, `AppMasterDetailScaffold`, `AppTable`, `AppCard`, `AppKpiCard`, `AppListSurface`, `AppRecordRow`, `AppSearchField`, `AppTextField`, `AppDropdownButton`, `AppFilterBar` / `AppDateRangeField` / `AppPaginationFooter` (01.2), `AppCommandPalette` + `WorkspaceSearchShortcuts` (01.2), `AppStepper` / `AppTimeline` / `AppTrendStat` (01.2), `AppBottomSheet`, `AppConfirmationDialog`, `AppSelectionSheet`, `EmptyState`, `ErrorView`, `AppSkeleton`, `LoadingIndicator`, `StatusPill`, `SectionHeader`, `AppActionBar`, `PrimaryButton`.
- If a needed widget does NOT exist in `shared_core`: create it in `packages/shared_core/lib/src/widgets/` (theme-driven via `context.colors` / `context.semanticColors`, EN/AR, responsive, a11y), export from `shared_core.dart`, add widget tests + goldens, THEN use it in this phase. Do not create `apps/*/lib/.../widgets/` copies.
- Forbidden: app-local copies of shared primitives, hardcoded spacing/radii/fonts, hardcoded colors, bespoke app bars/shells.
- Acceptance: grep shows zero new app-local duplicates; new shared widgets have tests + docs.


---

## Full 100% Redesign Mandate (Binding)
This phase is a SCREEN-LEVEL REDESIGN, not a color refresh, spacing tweak, or bug-fix pass. Minimal-change execution FAILS this phase.

- Rebuild every owned screen composition from its archetype (see 00_SCREEN_ARCHETYPES.md): new visual hierarchy, layout, spacing rhythm, section order, interaction patterns, responsive behavior. The finished screen must look visibly different from the old one side-by-side.
- FORBIDDEN as the whole change: only swapping colors/fonts/padding, only wrapping old layout in new cards, keeping obsolete headers/lists/forms because they exist. If the diff is palette + spacing only, reject and rework.
- Each screen gets a task-specific composition (never the same header + KPI cards + grid + list template on every screen). Attention/action content outranks passive metrics. Remove dead sections, kill obsolete widgets (verify zero references first, like REPORT_PHASE_06 S-section did with 17 legacy files).
- Must use Concept A tokens + centralized shared_core widgets (01.2 block); no per-app duplicates.
- Proof required in report: before/after composition table per screen + deleted-obsolete-files list + side-by-side screenshots. Reviewer compares old vs new at 390 + 1280 EN/AR. If it still resembles the old UI, Gate 2 FAILS.
