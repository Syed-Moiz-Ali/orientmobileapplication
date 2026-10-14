# PHASE 13 — Owner Application: Executive Cockpit & Dashboard Operations

**Document ID:** `phases/redesign_v2/implementation/PHASE_13_OWNER_COCKPIT_OPERATIONS.md`  
**Prerequisites:** Phase 03 & Phase 04 Completed (`REPORT_PHASE_03.md`, `REPORT_PHASE_04.md`)  
**Target Package:** `apps/owner_app/lib/features/dashboard/`  
**Status:** READY FOR IMPLEMENTATION (Gate 13)  

---

## 1. Primary User & Engineering Objective
Complete redesign of the Owner executive dashboard using **Archetype 8: Executive Cockpit & Financial Desk**. Upgrade the simplified prototype dashboard into an enterprise command center featuring live revenue velocity tickers, top sales leaderboards, activity feeds, and workshop communications.

---

## 2. Real Repository File Paths
- `apps/owner_app/lib/features/dashboard/presentation/dashboard_view.dart` & `widgets/dashboard_body.dart`
- `apps/owner_app/lib/features/dashboard/presentation/widgets/owner_dashboard_page.dart` (O1)
- `apps/owner_app/lib/features/dashboard/presentation/widgets/top_sales_page.dart` (O2)
- `apps/owner_app/lib/features/dashboard/presentation/widgets/messages_page.dart` (O3)
- `apps/owner_app/lib/features/dashboard/presentation/widgets/owner_activity_feed_tab.dart` (O4)
- `apps/owner_app/test/features/dashboard/owner_dashboard_test.dart`

---

## 3. Screen Redesign Requirements
1. **`OwnerDashboardPage` (O1 - Executive Cockpit):**
   - **Live Revenue Ticker:** Hero metric display (`AED 48,250.00`) with dynamic delta pill (`+18.4% vs Target`).
   - **Interactive Telemetry Curve:** Lightweight custom-painted curve comparing actual revenue against daily targets.
   - **Operational Micro-Pods:** Gross Margin (`44.2% • +2.1% Ahead`), Floor Occupancy (`88.5% • 14/16 Active Bays`), Approvals WIP (`AED 18.4K • 6 Due`).
   - **Responsive Adaptation:** Mobile renders stacked telemetry cards with swipeable charts; Desktop renders a 3-column panoramic command console.
2. **`TopSalesPage` (O2):**
   - Service advisor revenue leaderboards, average invoice size, and conversion rate rankings.
3. **`MessagesPage` & `OwnerActivityFeedTab` (O3 & O4):**
   - Pinned workshop communications thread and real-time operational activity log (e.g. "Job #9281 approved by customer", "Bay 4 QC passed").

---

## 4. Visual Acceptance Criteria
- Clean, financial-grade aesthetic with deep navy typography and cobalt accents.
- Zero horizontal layout overflows on narrow mobile screens.
- Golden tests generated with real fonts loaded across Mobile, Tablet, and Desktop.
- **Shell Integration (Phase 04.1).** Replace the bespoke `OwnerAppBar` with the shared `WorkspaceAppBar` (desktop uses `frosted: true` with the reduced-transparency fallback), preserving the period control through `contextSelector` and the notification/avatar actions. Provide `onSearch` + `WorkspaceSearchShortcuts` (⌘K / Ctrl+K) and `OfflineStatusPill` with `DashboardShell(showOfflineBanner: false)` where the pill is shown. Acceptance: header/search/offline widget tests + new mobile/desktop EN/AR goldens.

---

## 5. Dual Gate Verification
### Gate 1: Engineering Validation
- `dart analyze apps/owner_app` returns 0 errors and 0 warnings.
- `owner_dashboard_test.dart` passes 100% across all viewports.

### Gate 2: Visual Aesthetic Validation
- Golden screenshots captured across Mobile (390px EN/AR) and Desktop (1280px) with real fonts.
- Generates `phases/redesign_v2/reports/REPORT_PHASE_13.md`.


---

## Styling Authority (Phase 01.1 � Mandatory)
All styling in this phase MUST resolve through the single centralized theme system. Do not select light/dark colors by hand.

- Standard Material roles -> `context.colors` (`ColorScheme`).
- Custom automotive/workshop roles -> `context.semanticColors` (`AppSemanticColors` ThemeExtension).
- **Forbidden:** `dark ? AppDarkColors.x : AppColors.x` ternaries; direct `AppColors.*` / `AppDarkColors.*` palette selection in feature widgets; hardcoded semantic hex; duplicate local theme systems or competing theme providers; hardcoded font styles, spacing, or radii where a theme or `AppDimensions` token exists.
- **Justified exceptions** (brand assets, theme construction, color previews, brightness-dependent behavior) must carry a one-line documented reason.
- Full rules: `00_CONCEPT_A_DESIGN_SYSTEM.md` Sec.6 and `reports/PHASE_01_1_THEME_ARCHITECTURE.md`.
