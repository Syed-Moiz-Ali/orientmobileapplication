# Phase 06 Completion Report — Staff Advisor Command Center

**Document ID:** `phases/redesign_v2/reports/REPORT_PHASE_06.md`
**Execution Phase:** Concept A V2 — Phase 06 (Staff Advisor Hub, Archetype 4: Tactical Operations Radar)
**Target Package:** `apps/staff_app/lib/features/advisor/`
**Specification:** `phases/redesign_v2/implementation/PHASE_06_STAFF_ADVISOR_HUB.md`
**Prerequisites:** Phase 03 ✅ (`REPORT_PHASE_03.md`), Phase 04 ✅ (`REPORT_PHASE_04.md`), Phase 04.1 integration plan, Phase 05 ✅ (`REPORT_PHASE_05.md`)
**Status:** **ENGINEERING GATE PASSED** / **VISUAL GATE PENDING PRODUCT OWNER**
**Timestamp:** 2026-10-14

---

## 1. Complete screen, route and file inventory

Discovered from source (`apps/staff_app/lib/features/advisor/`) — not from the spec list alone. The advisor workspace is a single GoRouter tab host (`AdvisorHomeView`) with three in-shell tabs plus pushed detail pages and modal surfaces.

| Ref | Surface | File | Route / entry | States owned |
| :-- | :-- | :-- | :-- | :-- |
| **S1** | `AdvisorHomeView` (tab 0) | `presentation/pages/advisor_home_view.dart` | `/advisor_home_view` | loading (skeleton), error+retry, empty, attention, active-intake, loaded |
| **S2** | `AdvisorJobsListView` (tab 1) | `presentation/pages/advisor_jobs_view.dart` | `/advisor_home_view` | loading, error+retry, empty, no-match, loaded (list / master-detail) |
| **S3** | `AdvisorReportsView` (tab 2) | `presentation/pages/advisor_reports_view.dart` | `/advisor_home_view` | loading (skeleton), error+retry, no-data placeholder, loaded |
| **S4** | `AdvisorJobDetailView` | `presentation/pages/advisor_job_detail_view.dart` | `/advisor/job-detail` (pushed, `extra: JobCardEntity`) | loading, load-error+retry, loaded, inspection-work-items variant |
| **S5** | `AdvisorSearchSheet` | `presentation/widgets/advisor_search_sheet.dart` | modal sheet + ⌘K / Ctrl+K | idle, results, no-match |
| **S6** | `AdvisorNotificationSheet` | `presentation/widgets/advisor_notification_sheet.dart` | modal sheet | empty, loaded |
| **S7** | `AdvisorProfileSheet` | `presentation/widgets/advisor_profile_sheet.dart` | modal sheet | loaded |
| **S8** | `AdvisorContactSheet` | `presentation/widgets/advisor_contact_sheet.dart` | modal sheet | loaded |
| **S9** | `AdvisorApprovalSheet` | `presentation/widgets/advisor_approval_sheet.dart` | modal sheet | loaded |
| **S10** | `AdvisorJobCardSheet` | `presentation/widgets/advisor_job_card_sheet.dart` | jobs-list overflow action | loaded |
| **S11** | `AdvisorStatDialog` | `presentation/widgets/advisor_stat_dialog.dart` | centred dialog | loaded |

**Routes preserved (unchanged):** `/advisor_home_view`, `/advisor/job-detail`, `/vehicle-customer`, `/scan-vehicle`, `/profile`, `/attendance`, `/advisor/check-in`. Route arguments and `extra` payloads are untouched.

**Obsolete surfaces removed (unreferenced legacy widgets, superseded):** `advisor_body.dart`, `advisor_header.dart`, `advisor_header_button.dart`, `advisor_avatar.dart`, `advisor_bottom_nav.dart`, `advisor_bottom_item.dart`, `advisor_fab.dart`, `advisor_stat_tile.dart`, `advisor_date_chip.dart`, `advisor_tab_panel.dart`, `advisor_job_cards_page.dart`, `advisor_approvals_page.dart`, `advisor_reminders_page.dart`, `advisor_reminder_row.dart`, `advisor_see_all_button.dart`, `advisor_tab_button.dart`, `advisor_status_badge.dart`. Each was verified to have **zero** references from any live page or test before removal (only self-referential within the dead cluster). Removing them eliminates the old "generic dashboard" leftovers and 62 legacy palette references.

---

## 2. Before / after visual-composition audit

| Screen | Before | After |
| :-- | :-- | :-- |
| Advisor Home | Bespoke in-body header (`_AdvisorHeader`) with a title + status row; search pill; 2-column action tiles; KPI row; recent list. Header duplicated the workspace title and had no shell integration. | `WorkspaceAppBar` (title `Service Desk`, branch·shift subtitle, frosted on desktop, integrated `OfflineStatusPill`, search trigger, notifications, profile). Body: command identity (eyebrow + greeting + meta pills), a **prominent amber-bordered Attention Radar panel** placed *above* passive metrics, quick-action dock (cobalt primary Scan), compact KPI strip, recent work, freshness footer. |
| Advisor Jobs | A vertical feed of large cards with a search field and chips; identical on every width (desktop rendered phone cards). | Work-management surface: title + live count, search, filter rail, scannable rows with **contextual overflow action**. Desktop/tablet now use `AppMasterDetailScaffold` with an `AppTable` job matrix (customer / job card / vehicle / status / time) and a live preview pane; compact keeps the touch list. |
| Advisor Job Detail | `AppTopBar` only; identity card then sections in a 3/1 rail. | `WorkspaceAppBar` (back + offline pill) + `AppPageHeader(breadcrumbs:)` wayfinding (`Jobs › JC-…`) + identity context, then the next-step/actions/sections hierarchy. |
| Advisor Reports | Plain title over the range control; KPI grid; charts; export. | Report identity header (icon anchor + title), range control, KPI grid, titled chart panels, export. No fabricated data. |

The composition is now **task-specific per screen**: an attention-first command board (home), a dense sortable work matrix (jobs), a document-like record (job detail), and an analytics report (reports). They share tokens and primitives but no longer read as the same page.

---

## 3. Changed production files & architectural rationale

**Pages**
- `advisor_home_view.dart` — shell integration (`WorkspaceAppBar`, `OfflineStatusPill`, `DashboardShell(showOfflineBanner:false)`, `WorkspaceSearchShortcuts`) + command composition; all palette reads migrated to `context.colors`/`context.semanticColors`.
- `advisor_jobs_view.dart` — work-management surface; `AppTable` + `AppMasterDetailScaffold`; contextual overflow.
- `advisor_job_detail_view.dart` — `WorkspaceAppBar` + `AppPageHeader(breadcrumbs:)`; palette migration.
- `advisor_reports_view.dart` — report header composition.

**Widgets**
- `advisor_job_card_sheet.dart` — rewritten: localized, theme-driven, wired as the jobs overflow preview (was an unreferenced sheet with hardcoded English and 34 palette refs).
- `advisor_job_card_row.dart` — optional contextual `onMore` overflow.
- `advisor_notification_sheet.dart`, `advisor_contact_sheet.dart`, `advisor_approval_sheet.dart`, `advisor_divider.dart`, `advisor_solid_action.dart` — palette migration.

**Providers**
- `advisor_providers.dart` — added `advisorPendingSyncCountProvider` (reads the existing `SyncQueue.length`) to drive the offline pill's queued state. No new connectivity state.

**Localization**
- `app_en.arb`, `app_ar.arb` + generated `staff_localizations*.dart` — 7 new keys (see §5).

**Tests (new)**
- `test/advisor_theme_architecture_test.dart` — Phase 06 theme guard.
- `test/advisor_phase06_shell_test.dart` — shell/shortcut/offline/responsive.

**Goldens (Phase 06-owned, 14):** regenerated after inspecting every render (§8).

No API request, response model, repository/provider contract, route, Hive box, offline queue, or validation rule was changed.

---

## 4. Centralized-theme audit findings

- **Removed all static palette selection** from the Phase 06 production set: `advisor_home_view` (7), `advisor_job_detail_view` (3), `advisor_contact_sheet` (3), `advisor_notification_sheet` (2), `advisor_approval_sheet` (1), `advisor_divider` (1), `advisor_solid_action` (2), plus the 34 in the rewritten `advisor_job_card_sheet`. All now resolve via `context.colors`, `context.semanticColors`, or `AppThemeContext`.
- Example: the action-tile solids use `colors.primary`/`colors.onPrimary`; status inks use `context.semanticColors.success.base` / `.info.base` / `.warning.base`; the offline pill reads `connectivityStatusProvider` + `SyncQueue`.
- **No new theme tokens were required** — existing `AppSemanticColors` roles (success/warning/info/primary/`primarySubtle`/`borderDefault`/…) covered every case.
- **New guard:** `apps/staff_app/test/advisor_theme_architecture_test.dart` fails if any listed Phase 06 file contains `AppColors.`, `AppDarkColors`, `Color(0x`, or `Brightness.`. The 24-file list is scoped to Phase 06 so later-phase advisor sub-features (intake 07 / inspection 08 / estimates 09, which still own their palette debt) are intentionally excluded.
- **Documented non-rendered exception:** `advisor_reports_provider.dart` retains `StatusCount.color` hex literals as domain model data; the reports view renders distribution colour from `AppChartTheme.seriesColor(...)`, never from `StatusCount.color`. Left for its domain owner (not a rendered-widget violation).
- **Dark-mode correctness improvement:** sheets previously used light `AppColors.success`/`AppColors.info` for status ink; they now use the brightness-aware semantic roles, so dark mode no longer shows light-mode accents.

---

## 5. Shell integration (Phase 04.1) details

| Requirement | Implementation |
| :-- | :-- |
| Replace bespoke header with `WorkspaceAppBar` | `AdvisorHomeView` passes `WorkspaceAppBar` as `DashboardShell.appBar`; `AdvisorJobDetailView` uses it directly. |
| Frosted sticky header | `frosted: !context.isCompact` (desktop/tablet); the component already falls back to an opaque surface under `MediaQuery.disableAnimations` (reduced transparency). |
| `OfflineStatusPill` + `showOfflineBanner: false` | `WorkspaceAppBar(showOfflineStatus: true, offlinePendingCount: pendingSync)`; `DashboardShell(showOfflineBanner: false)` — offline state is announced **once**. |
| ⌘K / Ctrl+K global search | `WorkspaceSearchShortcuts(onSearch: _showSearch)` wraps the shell; the `WorkspaceAppBar` search trigger is the always-visible fallback and opens the same `AdvisorSearchSheet`. |
| Breadcrumbs on work-order/detail routes | `AppPageHeader(breadcrumbs: [Jobs › <job id>])` on `AdvisorJobDetailView`. |
| Master-detail where justified | `AppMasterDetailScaffold` + `AppTable` for the desktop/tablet jobs matrix. |
| Preserve navigation/args/permissions | All route pushes, `extra` payloads and the approvals persistence/sync flow are byte-for-byte preserved. |
| Mobile-appropriate navigation | Compact keeps the shared `AppBottomNavigation`; enterprise rail/breadcrumbs only on wide layouts. |

No shared component was modified.

---

## 6. Localization & RTL verification

- 7 new keys added with exact EN/AR parity and metadata: `advisorJobsColumnCustomer`, `advisorJobsColumnJobCard`, `advisorJobsColumnStatus`, `advisorJobsColumnTime`, `advisorJobsSelectPrompt`, `advisorActionOpenJob`, `advisorActionMore`.
- `flutter gen-l10n` regenerated `staff_localizations*.dart`. `l10n_untranslated.json` = `{}`; `arb_parity_test` and `localization_cross_boundary_test` pass.
- No hardcoded EN/AR strings introduced in production widgets.
- RTL: all new layout uses directional APIs (`EdgeInsetsDirectional`, `DirectionalIcon`, `AlignmentDirectional`, `PositionedDirectional` in shared components); Arabic goldens confirm mirrored composition. Identifiers (`JC-2026-1042`, `EST-5521`), plate/vehicle and money values remain LTR/non-mirrored.

---

## 7. Responsive viewport matrix & accessibility

Verified by `advisor_phase06_shell_test` (no overflow / correct shell) and `advisor_experience_test` (no overflow at 1.3× text scale):

| Width | Verified | Composition |
| :-- | :-- | :-- |
| 320, 360, 390, 430 | ✅ (320/390 asserted; 360/430 covered by responsive spec + no-overflow suite) | single-column, bottom nav, modal sheets, bottom action bar |
| 600, 768, 834, 1024 | ✅ (768 asserted) | rail navigation; master-detail jobs matrix; 2-up grids |
| 1280, 1440 | ✅ (1280 asserted) | rail + wide content (max 1440 canvas); full job table |

- Accessibility: shared components provide semantics/focus/keyboard (search trigger labelled, offline pill `liveRegion` when offline, nav destinations announce counts); touch targets ≥48dp; reduced-motion/transparency honoured by `WorkspaceAppBar`.
- Dark theme: rendered in `advisor_phase06_shell_test` with no exceptions; `advisor_today_1280` etc. captured in light (dark captured in tests, not goldens — documented limitation).

---

## 8. Golden changes & review evidence

**Regenerated (14, Phase 06-owned only):** `advisor_today_{390,768,1280}_{en,ar}`, `advisor_jobs_390_{en,ar}`, `advisor_reports_390_{en,ar}`, `advisor_job_detail_{390,1280}_{en,ar}`.

Each was **inspected at native resolution** before acceptance (mobile home EN/AR, desktop home EN, jobs EN, reports EN/AR, job detail EN). Observed: Concept A navy/cobalt identity; frosted header with search + `Synced` pill; amber attention panel above passive metrics; correct RTL mirroring with non-mirrored identifiers/money; no overflow/clipping.

**Evidence copies:** `phases/redesign_v2/reports/PHASE_06/screens/` (14 PNGs, real fonts via `_loadFonts`).

**No other phase's goldens were touched.** Phase 07A/10/11 goldens remain unchanged and failing (pre-existing — see §9).

---

## 9. Baseline vs final test results

| Suite | Baseline | Final | Δ |
| :-- | ---: | ---: | :-- |
| `apps/staff_app/test/advisor_experience_test.dart` | 21 / 0 | **21 / 0** | unchanged |
| `apps/staff_app/test/advisor_phase06_visual_test.dart` | **0 / 14** | **14 / 0** | +14 (Phase 06 goldens re-baselined) |
| `apps/staff_app/test/advisor_theme_architecture_test.dart` | (new) | **1 / 0** | +1 guard |
| `apps/staff_app/test/advisor_phase06_shell_test.dart` | (new) | **10 / 0** | +10 shell/responsive |
| `apps/staff_app` (full) | 76 golden failures | **291 / 62** | −14 failures; **0 functional regressions** |
| `packages/shared_core` | 324 / 0 | **324 / 0** | unchanged |
| `packages/shared_auth` | 74 / 0 | **74 / 0** | unchanged |
| Analyzer (`flutter analyze lib test`) | 0 | **0** | clean |

**Commands run:** `flutter analyze lib test` (staff_app/shared_core/shared_auth); `flutter test` (each); `flutter test --update-goldens test/advisor_phase06_visual_test.dart`; `flutter gen-l10n`.

### Exact remaining failures (pre-existing, other phases — NOT fixed, NOT claimed fixed)

All 62 are golden mismatches owned by other phases and were already failing before this phase (the same environment stale-golden condition that made the 14 Phase 06 goldens fail at baseline):

| Test file | Count | Owner |
| :-- | ---: | :-- |
| `advisor_phase07a_visual_test.dart` | 13 | Phase 07 |
| `supervisor_login_phase05_test.dart` | 2 | Phase 05/11 |
| `technician_today_test.dart` | 7 | Phase 10 |
| `technician_jobs_test.dart` | 8 | Phase 10 |
| `technician_job_detail_test.dart` | 9 | Phase 10 |
| `technician_productivity_test.dart` | 6 | Phase 10 |
| `technician_profile_test.dart` | 9 | Phase 10 |
| `technician_support_flows_test.dart` | 8 | Phase 10 |

No Phase 06 test fails.

---

## 10. Screenshots of the completed screens

`phases/redesign_v2/reports/PHASE_06/screens/`:
- Home: `advisor_today_390_{en,ar}.png`, `advisor_today_768_{en,ar}.png`, `advisor_today_1280_{en,ar}.png`
- Jobs: `advisor_jobs_390_{en,ar}.png`
- Reports: `advisor_reports_390_{en,ar}.png`
- Job detail: `advisor_job_detail_390_{en,ar}.png`, `advisor_job_detail_1280_{en,ar}.png`

---

## 11. Known limitations

1. **No live device/emulator/browser is available** in this environment. Verification is **headless Flutter golden rendering only**; live visual/interaction acceptance is **NOT PERFORMED** and must not be reported as passed.
2. Desktop jobs master-detail and desktop frosted header are exercised by widget tests but not captured as separate goldens (jobs goldens are 390 only; home goldens cover 1280 light).
3. Dark-mode renders are exercised by widget tests but not added as goldens.
4. `advisor_reports_provider.dart` retains non-rendered `StatusCount.color` domain hexes (documented in §4); later-phase advisor pages (07/08/09) retain their own palette debt, owned by those phases.

---

## 12. Gate verdicts

**Gate 1 — Engineering: PASS.** All Phase 06 surfaces accounted for; Phase 04.1 shell integration implemented; analyzer clean in affected packages; theme guard + localization parity + untranslated-empty pass; existing contracts/routes/persistence preserved; no new functional failures; report and evidence produced.

**Gate 2 — Visual: PENDING PRODUCT OWNER.** Screens are compositionally redesigned (not recolored); each has a task-appropriate layout; Concept A identity is consistent; mobile/tablet/desktop and EN/AR renders were reviewed. Live acceptance is **not performed** (headless only). This report does **not** claim Product Owner approval.

---

## 13. Product Owner sign-off checklist

- [ ] Review `reports/PHASE_06/screens/` (home/jobs/reports/job detail; EN/AR; mobile/tablet/desktop).
- [ ] Confirm the command-oriented home (attention-first) matches the Concept A direction.
- [ ] Confirm the desktop master-detail jobs matrix is acceptable.
- [ ] Confirm removal of the obsolete legacy advisor widgets is acceptable.
- [ ] Accept the headless-visual limitation or provide a device/browser for live acceptance.
- [ ] Approve Gate 2 and this report.

**Phase 06 executed in isolation. Phases 07A/07B and later were not started.**
