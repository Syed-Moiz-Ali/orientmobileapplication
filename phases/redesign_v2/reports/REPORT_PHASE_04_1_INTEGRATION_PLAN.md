# Phase 04.1 — Application Integration Planning & Ownership

**Document ID:** `phases/redesign_v2/reports/REPORT_PHASE_04_1_INTEGRATION_PLAN.md`
**Type:** Planning / ownership report — **no application code or golden files are changed by this phase**
**Basis:** `REPORT_PHASE_04.md`, `REPORT_PHASE_04_VISUAL_ACCEPTANCE.md`, the Phase 05–20 implementation specs, and the actual repository source (symbols cited by path)
**Timestamp:** 2026-10-14

---

## 1. Executive decision

The Phase 04 **shared layer is complete and green** (`shared_core` 324/0). The gap is **application-shell adoption**: none of the four apps uses `WorkspaceAppBar`, `OfflineStatusPill`, `WorkspaceSearchShortcuts`, breadcrumbs, or master-detail.

**Decision:** the gap is closed **inside each app's owning role-hub phase**, not by Phase 04.1 and not by a new phase. Concretely:

| Integration item | Owning phase(s) |
| :-- | :-- |
| App-shell header → `WorkspaceAppBar` | Phase **06** (staff advisor), **10** (technician), **11** (supervisor), **13** (owner), **16** (customer), **19** (CRM) |
| ⌘K / Ctrl+K global search trigger | Phase **06** (explicit in spec); others where a global search exists |
| Offline pill + `DashboardShell(showOfflineBanner:false)` coordination | Phase **07/12** (staff offline), **16/17/18** (customer offline), **13** (owner), **19** (crm) |
| Breadcrumbs | Phase **13/14** (owner), **19** (crm); **not** consumer customer screens |
| Master-detail / three-pane | Phase **14** (owner job cards), **16/17** (customer bookings), **19** (CRM leads) |

**No application source, tests, or goldens were modified.** This report is source-backed planning only.

The single most important finding: **the Phase 04 spec defines the shared header, but no downstream phase spec explicitly lists "adopt `WorkspaceAppBar` (and its Phase-04.1 refinements) in the app shell" as an acceptance criterion.** §5 proposes the smallest amendment to close that gap without moving work into Phase 04.

---

## 2. Source-backed findings (file paths + symbols)

### 2.1 Shared infrastructure delivered by Phase 04 (verified present)

- `shared_core/lib/src/widgets/dashboard_shell.dart` — `DashboardShell` (authenticated frame; `showOfflineBanner` coordination flag).
- `shared_core/lib/src/layout/app_adaptive_navigation.dart` — `AppAdaptiveNavigationFrame`, `AppNavigationRail`, `AppBottomNavigation`, `AppNavDrawer`, `OrientBrandMark`, `AppNavItem`.
- `shared_core/lib/src/widgets/workspace_app_bar.dart` — `WorkspaceAppBar(frosted, showOfflineStatus, offlinePendingCount, onSearch, searchShortcutLabel)` + `WorkspaceSearchShortcuts`.
- `shared_core/lib/src/widgets/offline_status_pill.dart` — `OfflineStatusPill` (reads `connectivityStatusProvider`).
- `shared_core/lib/src/widgets/app_master_detail_scaffold.dart` — `AppMasterDetailScaffold`, `AppThreePaneScaffold`.
- `shared_core/lib/src/widgets/app_breadcrumbs.dart`, `app_page_header.dart` — `AppBreadcrumbs`, `AppPageHeader(breadcrumbs:)`.

### 2.2 What the applications actually use (verified)

| App | Shell root | `DashboardShell(appBar:)` | Nav |
| :-- | :-- | :-- | :-- |
| staff_app | `apps/staff_app/lib/features/advisor/presentation/pages/advisor_home_view.dart:262` | **none** (no `appBar`) | `AppAdaptiveNavigationFrame` + `AppBottomNavigation` |
| staff_app | `.../supervisor/presentation/widgets/supervisor_scaffold.dart:64` | `SupervisorAppBar` (bespoke) | same |
| staff_app | `.../technician/presentation/technician_dashboard_view.dart:41` | inline `AppBar` (bespoke) | same |
| owner_app | `apps/owner_app/lib/features/dashboard/presentation/widgets/dashboard_body.dart:50` | `OwnerAppBar` (bespoke) | same |
| customer_app | `apps/customer_app/lib/features/customer/presentation/widgets/customer_scaffold.dart:75` | **none** (no `appBar`) | same |
| crm_app | `apps/crm_app/lib/features/crm_dashboard/presentation/crm_dashboard_view.dart:81` | `CrmAppBar` (bespoke) | `AppAdaptiveNavigationFrame` + `AppNavDrawer` |

Bespoke bars: `apps/owner_app/.../widgets/owner_app_bar.dart`, `apps/crm_app/.../widgets/crm_app_bar.dart`, `apps/staff_app/.../widgets/supervisor_app_bar.dart`. They are theme-compliant (`colors.surface/onSurfaceVariant/outline`) and their only `Brightness` use is `SystemUiOverlayStyle` (justified OS chrome).

### 2.3 Adoption evidence (zero references in apps)

```powershell
Get-ChildItem apps\*\lib, packages\shared_auth\lib -Recurse -Filter *.dart |
  Select-String 'WorkspaceAppBar|OfflineStatusPill|WorkspaceSearchShortcuts|showOfflineBanner'
# => (no matches)
```

### 2.4 Why the owning phases are the role-hub phases

Each role-hub phase spec lists its app's **shell/dashboard** file as a target, therefore owns its header:

- Phase 06 §2 — `advisor_home_view.dart` (S1) + `advisor_search_sheet.dart` (S5, "Instant Spotlight command palette (`Cmd+K`)").
- Phase 10 §2 — `technician_dashboard_view.dart` (T1).
- Phase 11 §2 — `supervisor_dashboard_view.dart` (V2).
- Phase 13 §2 — `dashboard_view.dart` **& `widgets/dashboard_body.dart`** (labelled **"Shell"**).
- Phase 16 §2 — `customer_dashboard_view.dart` (**"Dashboard Shell"**).
- Phase 19 §2 — `crm_dashboard_view.dart` (**"Shell"**).

Cross-cutting acceptance source: `00_RESPONSIVE_RTL_SPEC.md` §1.3 — Desktop Workspace requires a persistent left rail (72/240), max canvas 1440px, and **`Cmd/Ctrl+K` (global search)**, `Esc`, `Enter`. §1.2 — tablet 40/60 master-detail. §2.2 — RTL non-mirroring exceptions.

---

## 3. Four-app integration ownership matrix

Legend: **Y** = applicable · **N** = not applicable (justified) · phase number = owning phase.

| Aspect | staff_app | owner_app | customer_app | crm_app |
| :-- | :-- | :-- | :-- | :-- |
| **Current root shell** | `advisor_home_view.dart:262`, `supervisor_scaffold.dart:64`, `technician_dashboard_view.dart:41` | `dashboard_body.dart:50` | `customer_scaffold.dart:75` | `crm_dashboard_view.dart:81` |
| **Current header** | bespoke `SupervisorAppBar` / inline technician `AppBar` / advisor **none** | bespoke `OwnerAppBar` | **none** | bespoke `CrmAppBar` |
| **`WorkspaceAppBar` integration point** | `DashboardShell(appBar: …)` in each of the 3 role shells | `DashboardShell(appBar: …)` (replace `OwnerAppBar`, reuse `PeriodDropdown` in `contextSelector`) | `DashboardShell(appBar: …)` (add a lightweight bar: brand/title + notifications/profile) | `DashboardShell(appBar: …)` (replace `CrmAppBar`) |
| **Breadcrumbs** | Y — advisor job detail / intake pushed pages (06/07) | Y — job card audit (13/14) | N — consumer; no deep hierarchy in main shell | Y — lead detail (19) |
| **Master-detail / three-pane** | Y (tablet) — advisor jobs matrix (06) | Y — job cards (14), job status (14) | Y (tablet) — bookings list/detail (16/17) | Y — leads list/detail, tasks (19) |
| **Offline pill + `showOfflineBanner` coordination** | Y — intake/offline queue (07), sync settings (12) | Y — offline approvals/ops (13/14) | Y — offline bookings (16/17/18) | Y — offline lead updates (19/20) |
| **⌘K / Ctrl+K search** | Y — advisor spotlight (06, explicit); technician/supervisor optional | Y — register/leads search (13/14) | N — consumer app has no global search (justified) | Y — leads/conversation search (19) |
| **Responsive (mobile/tablet/desktop)** | Y | Y | Y | Y |
| **EN/AR RTL implications** | Y — non-mirroring plates/VIN/phone; `DirectionalIcon` chevrons | Y — money/plates non-mirrored | Y — plate/VIN/money non-mirrored (16 §2.2) | Y — numbers LTR |
| **Light/dark** | Y | Y | Y | Y |
| **Golden tests potentially affected** | `advisor_phase06_visual_test`, `advisor_phase07a_visual_test`, `technician_*`, `supervisor_login_phase05` (31 golden assertions) | **none currently** (owner_app has no goldens — recommend adding) | 60 golden assertions across `customer_*` tests | **none currently** (recommend adding) |
| **Owning phase** | 06 (advisor), 10 (tech), 11 (supervisor), 07/12 (offline) | 13 (shell/cockpit), 14 (jobs/approvals) | 16 (shell/garage), 17 (booking), 18 (status) | 19 (shell/pipeline), 20 (comms/settings) |
| **Dependencies** | Phase 04 ✔, Phase 03 ✔ | Phase 04 ✔, Phase 03 ✔ | Phase 04 ✔, Phase 15 (prereq per 16) | Phase 04 ✔, Phase 18 (prereq per 19) |
| **Acceptance evidence** | in-phase widget tests + goldens (mobile/tablet/desktop, EN/AR) | in-phase tests + **new** goldens | in-phase tests + existing goldens re-rendered | in-phase tests + **new** goldens |
| **Blockers** | app palette debt (328 refs) migrated in-phase; live visual gate needs device | same | same; consumer-pattern discipline (do not force rail/⌘K) | same |

### 3.1 Customer-app caveat (anti-over-engineering)

Phase 16 targets **Archetype 2: Digital Garage & Service Hub** — a consumer surface with exactly four permanent destinations (`CustomerDestination.navItems`) and contextual pushed pages. Enterprise workspace patterns must **not** be forced here:

- **No breadcrumb trail** and **no global ⌘K search** in the consumer shell (justified as N above). The `00_RESPONSIVE_RTL_SPEC §1.3` desktop rules apply to **workspace** screens; consumer screens use the mobile-first "Digital Garage" composition on all widths.
- A `WorkspaceAppBar` adoption for customer should be the **brand/title + notifications + profile** composition only (optionally `showOfflineStatus`), not the enterprise rail/breadcrumb/search chrome.

---

## 4. Phase-by-phase dependency mapping (Phases 05–20)

Resolved from `README.md` (execution ledger + dependency mermaid) and each spec's `Prerequisites` line:

| Phase | Scope (from spec) | Shell-integration relevance | Depends on |
| :-- | :-- | :-- | :-- |
| 05 | `shared_auth` login/OTP/recovery/logout (`auth_loading_view`, `login_view`, `forgot_password_view`, `logout_dialog`) | **None** — no app shell header (auth surfaces only) | 02, 04 |
| 06 | staff advisor hub (`advisor_home_view`, jobs, reports, sheets) | **Owns** advisor `WorkspaceAppBar` + ⌘K spotlight (`AdvisorSearchSheet`) | 03, 04 |
| 07 | staff vehicle intake (`.../advisor/.../*` intake) | Offline pill (`DashboardShell(showOfflineBanner:false)`), breadcrumb on pushed page | 06 |
| 08 | staff inspection HUD | Offline pill; HUD is full-bleed (may hide header) | 07 |
| 09 | staff repair estimates | Breadcrumbs on estimate pushed pages | 08 |
| 10 | technician console (`technician_dashboard_view`) | **Owns** technician header; offline pill | 09 |
| 11 | supervisor bay (`supervisor_dashboard_view`) | **Owns** supervisor header; offline pill | 10 |
| 12 | staff profile/attendance/settings | Offline **sync diagnostics** (M4) — interplay with pill | 11 |
| 13 | owner cockpit (`dashboard_view.dart` & `dashboard_body.dart` = **Shell**) | **Owns** owner `WorkspaceAppBar` | 03, 04 |
| 14 | owner jobs/approvals | Breadcrumbs, master-detail, `AppTable` register | 13 |
| 15 | owner financials/compliance | — (pushed pages) | 14 |
| 16 | customer garage/home/profile (`customer_dashboard_view.dart` = **Shell**) | **Owns** customer header (consumer composition) | 15, 04 |
| 17 | customer booking wizard | Breadcrumb **stepper**; master-detail on tablet | 16 |
| 18 | customer status/approvals | Offline pill (live status) | 17 |
| 19 | CRM deal radar/pipeline (`crm_dashboard_view.dart` = **Shell**) | **Owns** CRM `WorkspaceAppBar`; master-detail; ⌘K search | 18 |
| 20 | CRM comms/team/settings | Offline pill; breadcrumbs in settings | 19 |
| 21 | final monorepo audit | Verifies all integrations + no palette debt | 05,10,11,12,15,18,20 |

---

## 5. Proposed specification amendments (smallest justified)

**Problem:** the Phase 04 spec defines the shared header, but Phases 06–20 do not list header adoption as an acceptance criterion, so the shared layer can be "complete" while apps never adopt it (exactly the Phase 04.1 finding).

**Proposed amendment (minimal, additive, no redesign):** append an identical **"Shell Integration (Phase 04.1)"** acceptance clause to the six role-hub phase specs (06, 10, 11, 13, 16, 19), scoped per app:

> **Shell Integration (Phase 04.1).** The app's workspace shell must use the shared `WorkspaceAppBar` for its header, replacing any bespoke app bar. On desktop the header uses `WorkspaceAppBar(frosted: true)` (with the documented reduced-transparency fallback). Where the app has a global/spotlight search, provide `onSearch` and wrap the shell in `WorkspaceSearchShortcuts` (⌘K / Ctrl+K). Where the app surfaces offline state, show `OfflineStatusPill` and set `DashboardShell(showOfflineBanner: false)` to avoid duplicate announcements. Breadcrumbs (`AppPageHeader(breadcrumbs:)`) and master-detail (`AppMasterDetailScaffold`) apply only on the specific screens listed in §3. Acceptance: widget tests for header/search/offline + refreshed in-phase goldens (mobile/tablet/desktop, EN/AR).

**Also proposed:** add the same one-line cross-reference to `REPORT_PHASE_04.md` §10 and a "Shell Integration" note to the Phase 21 audit checklist.

**Not proposed:** creating a new phase, moving feature work into Phase 04, or changing any approved Concept A decision. **No spec file is edited by Phase 04.1** — the amendments above require Product Owner approval before application.

**Flagged product decision (do not decide unilaterally):** whether `frosted: true` is **default-on** for all workspace headers, or opt-in per app. This affects appearance across every app and must be a Product Owner decision.

---

## 6. Acceptance criteria & required verification evidence

Verification levels are strictly separated; a lower level passing is **never** reported as a higher level passing.

### Level 1 — Source & static analysis
- `flutter analyze lib test` = 0 issues for the touched app and `shared_core`.
- No `AppColors.*`/`AppDarkColors.*` selection, no `dark ? … : …` palette ternary, no hardcoded semantic hex in the modified shell/header files.
- `WorkspaceAppBar`/`OfflineStatusPill`/`WorkspaceSearchShortcuts` imported and used at the shell root.

### Level 2 — Automated widget tests & goldens
Per applicable app:
- **Header:** the shell renders `WorkspaceAppBar`; title/subtitle reflect the active tab; actions (notifications, profile, context selector) preserved.
- **Search:** where search exists, `onSearch` fires from both the app-bar trigger **and** ⌘K/Ctrl+K; discoverable fallback present on non-Command platforms.
- **Offline:** `OfflineStatusPill` reflects the existing `connectivityStatusProvider`; offline state announced **once** (`showOfflineBanner: false` where the pill is shown); queued-count path exercised.
- **Responsive:** mobile (390) / tablet (768–834) / desktop (≥1024) — rail vs bottom dock vs drawer, content max-width 1440, no `RenderFlex` overflow.
- **EN/AR RTL:** mirrored nav order/alignment; non-mirrored plates/VIN/phone/money (spec §2.2); Arabic labels via `SharedCoreLocalizations`.
- **Theme:** light + dark render with `context.colors`/`context.semanticColors` only.
- **Accessibility:** search trigger and nav items expose semantics; focus traversal works; reduced-transparency fallback disables the blur.
- **Goldens:** only the owning phase's goldens are refreshed, with before/after inspection; unrelated goldens untouched.

### Level 3 — Live visual & interaction acceptance
- Requires an emulator/device/browser: load the real app, exercise the header (translucency over scrolled content), ⌘K search, offline simulation (toggle connectivity), rail/bottom-bar/drawer transitions, EN/AR, light/dark. **Currently unavailable** in this environment — must be recorded as *not performed*, never as passed.

---

## 7. Risks, blockers, and explicit Product Owner decisions

| # | Item | Type | Severity | Resolution |
| :-- | :-- | :-- | :-- | :-- |
| R1 | No phase spec lists header adoption as acceptance | Process gap | High | §5 amendment (needs PO approval) |
| R2 | App golden churn (staff 31, customer 60 assertions) | Regression risk | Medium | Owning phase re-renders **only its own** goldens after visual inspection |
| R3 | owner_app / crm_app have **no** goldens | Evidence gap | Medium | Owning phases (13/19) add goldens |
| R4 | Live visual gate unavailable (no device/browser) | Tooling | High | Record as *not performed*; PO/CI provides environment |
| R5 | App palette debt (328 + 28 refs; 353 hex) | Compliance | High | Migrated within each owning phase; Phase 21 verifies |
| R6 | Forcing enterprise chrome onto the consumer app | Design risk | Medium | §3.1 — customer uses consumer composition only |
| R7 | Frolicking default (`frosted` on/off) | Product | Medium | **PO decision** — flagged, not decided |
| R8 | RTL non-mirroring regressions (plates/VIN/money/HUD) | Correctness | High | In-phase EN/AR goldens + the `00_RESPONSIVE_RTL_SPEC` §2.2 checks |

**Explicit Product Owner decisions required before application-level implementation:**
1. Approve the §5 "Shell Integration" acceptance amendment for Phases 06/10/11/13/16/19.
2. Decide `frosted` default-on vs opt-in.
3. Provide a device/emulator/browser environment for Level 3 acceptance.

---

## 8. Recommended next phase

**Proceed in roadmap order with Phase 05 (`PHASE_05_AUTHENTICATION_FLOWS.md`, target `packages/shared_auth/`).** Rationale (source-backed):

- The dependency graph has `P04 → P05` (README mermaid) and Phase 05's `Prerequisites` line reads *"Phase 02 & Phase 04 Completed"*. Phase 04 (shared layer) is now complete.
- Phase 05 does **not** touch application shell headers (it is the auth package), so it carries **no** integration risk for the §3 matrix.
- The **first** shell-integration-bearing phase is **Phase 06** (staff advisor), which explicitly owns the advisor header and the ⌘K `AdvisorSearchSheet` — the natural first adopter of the amended shell clause.

Therefore: **Phase 05 next**; shell integration is executed starting at **Phase 06**, per §3/§4.

---

## 9. Confirmation of no changes

- **No application source files** (`apps/*/lib`, `packages/shared_auth/lib`) were modified.
- **No golden files** were regenerated or deleted.
- **No test assertions or theme guards** were weakened; `pendingFuturePhase` remains empty.
- **No shared component** was modified (no defect was found).
- **No apps were launched or visually accepted.** Live visual acceptance remains **unverified** pending a device/browser environment.
- Baseline counts recorded (independently reproduced this session): `shared_core` **324/0**; shared_auth **51/22**; staff_app **267/76**; owner_app **21/0**; customer_app **437/80**; crm_app **14/0**.

**Stop.** Awaiting Product Owner approval before implementing application-shell integration or starting Phase 05.
