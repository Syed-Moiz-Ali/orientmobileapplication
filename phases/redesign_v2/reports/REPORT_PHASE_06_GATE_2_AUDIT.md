# Phase 06 — Gate 2 Visual Acceptance Audit (Evidence-Only)

**Document ID:** `phases/redesign_v2/reports/REPORT_PHASE_06_GATE_2_AUDIT.md`
**Audit Type:** Read-only Product-Owner visual acceptance review — **no production source, tests, goldens, localization, config, or Git state modified**
**Scope audited:** Phase 06 Staff Advisor Hub redesign (`apps/staff_app/lib/features/advisor/`)
**Basis:** `00_CONCEPT_A_DESIGN_SYSTEM.md`, `00_CONCEPT_A_APPROVAL.md`, `00_RESPONSIVE_RTL_SPEC.md`, `00_VISUAL_ACCEPTANCE_RULES.md`, `implementation/PHASE_06_STAFF_ADVISOR_HUB.md`, `reports/REPORT_PHASE_06.md`, `reports/REPORT_PHASE_04_1_INTEGRATION_PLAN.md`, `reports/REPORT_PHASE_05.md`, `00_COVERAGE_MATRIX.md`, `README.md`, and the actual renders in `reports/PHASE_06/screens/`
**Timestamp:** 2026-10-14

> **Path discrepancies found (resolved, not assumed):** the brief lists `phases/redesign_v2/PHASE_06_STAFF_ADVISOR_HUB.md` and `phases/README.md`. Neither exists. The real paths are `phases/redesign_v2/implementation/PHASE_06_STAFF_ADVISOR_HUB.md` and the master hub `phases/redesign_v2/README.md` (both inspected). The Concept A reference assets are `apps/concept_showcase/test/goldens/concept_a_staff_*.png` (inspected).

---

## A. Executive decision

### `CONDITIONAL — ACTIONS REQUIRED`

**Rationale.** The available headless evidence is strong and internally consistent:

- Every Phase 06 surface (S1–S11) exists, is composed as a distinct, task-appropriate layout, and renders Concept-A-aligned (navy/cobalt identity, hairline borders, restrained elevation, semantic status accents) across the 14 captured renders (mobile 390 / tablet 768 / desktop 1280 × EN/AR, light).
- The mandatory Phase 04.1 shell integration (`WorkspaceAppBar` + `frosted`, `OfflineStatusPill`, `DashboardShell(showOfflineBanner:false)`, `WorkspaceSearchShortcuts` ⌘K/Ctrl+K → `AdvisorSearchSheet`, breadcrumbs, `AppMasterDetailScaffold` + `AppTable`) is present, wired, and covered by 10 passing widget tests + source inspection.
- Theme/localization architecture is clean (24-file Phase 06 set has **0** `AppColors.*`/`AppDarkColors`/`Color(0x`/`Brightness.` references; guard + ARB parity + empty untranslated pass).
- The 62 `staff_app` failures are **conclusively attributable to other phases' stale goldens**, not to Phase 06.

It is **not** `RECOMMEND APPROVAL` because Gate 2 is a *human visual + live* gate (`00_VISUAL_ACCEPTANCE_RULES.md` §3) and this audit can only verify static/headless evidence. It is **not** `NOT READY FOR APPROVAL` because there are no blockers in the delivered design or engineering evidence. The conditions are: (1) Product Owner review of the supplied renders, (2) a live device/browser pass (not performed here), and (3) capture of the currently un-goldened states (dark theme, offline/queued, loading/error/empty, search + modal sheets, jobs desktop matrix).

---

## B. Screen-by-screen visual matrix

Only the following evidence exists (all headless golden PNGs, **light theme only**, real fonts loaded). Every entry below was inspected at native resolution.

| # | Screen / state | Viewport | Theme | Locale | Evidence path | Primary task | Visual findings | Verification gap |
| :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- |
| 1 | Advisor home (command board, loaded) | 390×844 | light | EN | `screens/advisor_today_390_en.png` | Triage today's work | Shell header (`Service Desk` + `Synced` pill + search + bell + avatar); `SERVICE ADVISOR` overline; greeting; branch/shift + freshness pills; **amber-bordered Attention panel above passive metrics**; quick-action dock with cobalt `Scan Vehicle` primary; Work Summary KPIs; bottom nav. No overflow/clipping. Strong hierarchy. | Dark; loading/error/empty; offline/queued |
| 2 | Advisor home (loaded) | 390×844 | light | AR | `screens/advisor_today_390_ar.png` | Same, RTL | Fully mirrored (title right; search/pill/notifications/avatar left; Scan Vehicle cobalt at start/right; bottom nav mirrored); identifiers/money non-mirrored. Correct. | Dark |
| 3 | Advisor home (loaded) | 768×1024 | light | EN | `screens/advisor_today_768_en.png` | Same, tablet | Rail nav appears; header retains search + pill; 2-up quick actions; 3-up KPI. Balanced. | Dark; rail-expanded (≥1440) |
| 4 | Advisor home (loaded) | 768×1024 | light | AR | `screens/advisor_today_768_ar.png` | Same, RTL tablet | Rail on the right; mirrored; no overflow. | Dark |
| 5 | Advisor home (loaded) | 1280×800 | light | EN | `screens/advisor_today_1280_en.png` | Same, desktop | Rail; wide header; 4-up quick actions; KPI strip. Concept-A command center. | Dark; frosted-over-scrolled-content |
| 6 | Advisor home (loaded) | 1280×800 | light | AR | `screens/advisor_today_1280_ar.png` | Same, RTL desktop | Rail on right; mirrored quick actions (cobalt at start); KPI grid mirrored. Correct. | Dark |
| 7 | Jobs / work-order list | 390×844 | light | EN | `screens/advisor_jobs_390_en.png` | Find and open a job | Title + live count pill; search; filter rail; scannable cards (job id, customer, vehicle, time, status) with contextual `•••` overflow. Work-management feel, not dashboard cards. | Empty/no-match/loading/error renders; dark |
| 8 | Jobs / work-order list | 390×844 | light | AR | `screens/advisor_jobs_390_ar.png` | Same, RTL | Mirrored; kebab on left; status/time mirrored; identifiers LTR. Correct. | as above |
| 9 | Reports & analytics | 390×844 | light | EN | `screens/advisor_reports_390_en.png` | Review performance | Report identity header (icon anchor + title); segmented range (`This Week` selected); 2-up KPI grid; bar chart with day labels; status-allocation pie + legend. Readable labels. | No-data/error renders; dark |
| 10 | Reports & analytics | 390×844 | light | AR | `screens/advisor_reports_390_ar.png` | Same, RTL | Mirrored header/segments/KPIs; charts keep numeric ordering. Correct. | as above |
| 11 | Job detail | 390×844 | light | EN | `screens/advisor_job_detail_390_en.png` | Act on the selected job | `WorkspaceAppBar` (back, `Synced`); breadcrumbs `Jobs › JC-2026-1042`; page header (customer/vehicle/status); identity card; Next Step cobalt action; secondary actions; sectioned record. Clear identity + primary action. | Load-error render; dark |
| 12 | Job detail | 390×844 | light | AR | `screens/advisor_job_detail_390_ar.png` | Same, RTL | Back chevron right; breadcrumbs mirrored; status pill left; fuel gauge mirrored; rows label-right/value-left. Correct. | as above |
| 13 | Job detail (master-detail rail) | 1280×800 | light | EN | `screens/advisor_job_detail_1280_en.png` | Same, desktop | 3/1 split: sections left, action rail right; gauge readable. | Dark; frosted |
| 14 | Job detail (master-detail rail) | 1280×800 | light | AR | `screens/advisor_job_detail_1280_ar.png` | Same, RTL desktop | Rail mirrored to left; header right-aligned; gauge fills from right. Correct. | Dark |

**States with no captured evidence (cannot be visually judged):** loading skeletons, error/retry, empty, no-match, offline banner, `OfflineStatusPill` queued/offline (all captures show online `Synced`), dark theme, `AdvisorSearchSheet` + results, `AdvisorNotificationSheet`, `AdvisorProfileSheet`, `AdvisorContactSheet`, `AdvisorApprovalSheet`, `AdvisorJobCardSheet`, `AdvisorStatDialog`, and the **desktop Jobs master-detail matrix**.

**Redesign verdict (per screen):** genuinely redesigned, not cosmetic. Home adopts a new shell header and an attention-first command composition; Jobs moved from a universal card feed to a work surface with a desktop table + master-detail; Job detail gained shell header + breadcrumbs; Reports gained an identity header. No screen retains the old layout with only a palette change.

---

## C. Concept A comparison

Compared directly against `concept_a_staff_390_en.png`, `concept_a_staff_768_en.png`, `concept_a_staff_390_ar.png`.

**Similarities (high fidelity):**
- Off-white canvas with pure-white surfaces and 1 px hairline borders; restrained elevation (matches the reference's flat cards).
- Hyper Cobalt as the single primary action anchor (`Scan Vehicle` tile, `Add Inspection` CTA), 8 px button radius.
- Uppercase overline labels (`SERVICE ADVISOR`, `QUICK ACTIONS`, `Assigned Work Orders`) mirroring the reference's `RAPID CHECKPOINTS (3/18 RECORDED)` treatment.
- Semantic status accents (emerald/amber/crimson) on pills and the attention panel; amber "BAY 04 · 18M"-style telemetry echoed by the amber bordered attention region.
- Typographic hierarchy (deep navy headings + muted slate metadata) and a plate/identifier chip language consistent with `DXB • M 84920` (job detail shows uppercase plate / mono job id / mono odometer).
- Bilingual mirroring with non-mirrored identifiers, plate, VIN, and money.

**Deviations / observations:**
- The reference is an inspection-HUD screen; the advisor hub is a different archetype (operations board) by design, so the compositions intentionally differ. Tokens/grammar match; the layout does not need to.
- Desktop KPI tiles carry noticeable vertical emptiness (fixed `kpiTileMinHeight` = 156 with the value near the top) — consistent with Concept A tiles, cosmetically sparse at 1280. Low impact.
- All reference and Phase 06 captures are light-mode only; no dark-side-by-side exists.

No gradient/glass-card/rounded-pill card overuse, no random accents, no decorative chart without data (charts show real mock report figures and a no-data placeholder path in source).

---

## D. Shell integration audit

| Required component | Source evidence | Test evidence | Outcome | Live gap |
| :-- | :-- | :-- | :-- | :-- |
| `WorkspaceAppBar` as shell header | `advisor_home_view.dart:264`; `advisor_job_detail_view.dart:246` | `advisor_phase06_shell_test` ("adopts WorkspaceAppBar"); `advisor_experience_test` still green | ✅ wired | Translucency over scrolled content not shown |
| `frosted: true` on desktop | `advisor_home_view.dart:267`, `advisor_job_detail_view.dart:250` (`!context.isCompact`) | Rendered at 1280 (header top) | ✅ present; fallback handled inside shared component via `MediaQuery.disableAnimations` | Readability over scrolled content = **NOT VERIFIED** |
| `DashboardShell(showOfflineBanner:false)` | `advisor_home_view.dart:263` | Shell test passes; single `OfflineStatusPill` asserted | ✅ no duplicate banner in the home shell | Real offline toggle = **NOT VERIFIED** |
| `OfflineStatusPill` | `advisor_home_view.dart:268` (`showOfflineStatus: true`) | `find.byType(OfflineStatusPill)` findsOneWidget | ✅ wired to `connectivityStatusProvider` | Offline/queued visual state not captured |
| `advisorPendingSyncCountProvider` → `SyncQueue` | `advisor_providers.dart:22-28` (`ref.watch(syncQueueProvider).length`, try/catch → 0) | Fed as `offlinePendingCount` | ⚠️ functional but **not reactive** (see G-2) | Queued-count update on enqueue = **NOT VERIFIED / likely stale until rebuild** |
| `WorkspaceSearchShortcuts` (⌘K / Ctrl+K) | `advisor_home_view.dart:359` (`onSearch: _showSearch`) | `advisor_phase06_shell_test` "Ctrl+K opens the advisor search sheet" + "app-bar trigger also opens" | ✅ both shortcuts bound (meta+K and control+K) by the shared component | Physical ⌘/Ctrl key, focus traversal = **NOT VERIFIED** |
| Existing `AdvisorSearchSheet` reuse | `_showSearch` (same handler for trigger + shortcut) | opens `AdvisorSearchSheet` | ✅ reuses existing workflow; no new endpoint | Results rendering, Hive-backed customer search = source-only |
| Breadcrumbs on job detail | `advisor_job_detail_view.dart:298-305` (`AppPageHeader(breadcrumbs: [Jobs › id])`) | `advisor_experience_test` (job detail) green | ✅ present | — |
| `AppMasterDetailScaffold` + `AppTable` (Jobs) | `advisor_jobs_view.dart:223` + `:260`, `onRowTap:272` | `advisor_phase06_shell_test` desktop matrix present, mobile degrades | ✅ correct width behaviour | Selection→preview→"Open Job Card" push = source-verified, not captured |

**Duplicate/conflicting indicators:** only one offline affordance per shell (home = pill; job detail = pill, no banner). No duplication found in source or tests.

**Navigation:** compact rows push `advisorJobDetail` (unchanged); the wide master-detail only selects a preview and routes the push through the same `onJobCard` callback — no double navigation.

---

## E. Theme and localization audit

Checks executed (non-mutating) and results:

| Check | Command / method | Result |
| :-- | :-- | :-- |
| Phase 06 palette/hex/brightness scan | `Select-String` over the 24-file Phase 06 set for `AppColors.`/`AppDarkColors`/`Color(0x`/`Brightness.` | **0 references — PASS** |
| Theme architecture guard | `flutter test test/advisor_theme_architecture_test.dart` | **1/0 PASS** |
| ARB parity + untranslated | `flutter test test/arb_parity_test.dart` | **PASS** |
| Cross-boundary Arabic render | `flutter test test/localization_cross_boundary_test.dart` | **PASS (2/2)** |
| Untranslated artifact | `apps/staff_app/l10n_untranslated.json` | `{}` (empty) — authoritative artifact |
| `shared_core` guard (untouched) | prior run | **324/0** |
| Directional APIs | source inspection (`EdgeInsetsDirectional`, `AlignmentDirectional`, `DirectionalIcon`, `PositionedDirectional`) | Present; RTL goldens corroborate |
| RTL identifiers | EN/AR goldens (`JC-2026-1042`, `EST-5521`, plate, `14200 km`, `د.إ 2,450`) | Correctly LTR/non-mirrored |

**Static vs rendered separation:** the guard proves *no static palette selection exists in source* for the Phase 06 set; the light-mode goldens corroborate the *rendered* result for EN/AR. **Dark-theme rendered correctness is asserted by widget tests but not visually captured**, so it is verified for "no exception/architecture clean" and **NOT VERIFIED** for aesthetic acceptance.

**Hygiene note (low):** a stray untracked `l10n_untranslated.json` (content `{}`) exists at the repository root in addition to the package-level one. Not modified by this audit; flagged for tidy-up.

---

## F. Test-failure attribution

**Reported claim verified:** full `staff_app` observed result is **291 passed / 62 failed**, reproduced identically in two independent headless runs (logs inspected; no re-run performed during this audit to avoid golden failure-artifact writes).

**All 62 failures are golden comparisons; zero non-golden/functional failures.** They are byte-identical in two runs and fall into 8 files owned by other phases:

| Test file | Failing tests | Owning phase | Screen/state | Classification |
| :-- | ---: | :-- | :-- | :-- |
| `advisor_phase07a_visual_test.dart` | 13 | Phase 07 (intake/scan) | intake 390/768/1280 (+invalid), checkin 390 (+damage), scan 390 — EN/AR | Pre-existing stale golden |
| `supervisor_login_phase05_test.dart` | 2 | Phase 05/11 (supervisor login) | compact EN/AR | Pre-existing stale golden |
| `technician_job_detail_test.dart` | 9 | Phase 10 | completed/dark/delayed/desktop/in-progress/large-text/pending/qc/tablet mobile | Pre-existing stale golden |
| `technician_jobs_test.dart` | 8 | Phase 10 | dark/desktop/empty/filtered-empty/large-text/mixed/search/tablet | Pre-existing stale golden |
| `technician_productivity_test.dart` | 6 | Phase 10 | dark/desktop/empty/large-text/mobile/tablet | Pre-existing stale golden |
| `technician_profile_test.dart` | 9 | Phase 10 | advisor ref/dark/desktop/large-text/minimal/mobile/sign-out/supervisor ref/tablet | Pre-existing stale golden |
| `technician_support_flows_test.dart` | 8 | Phase 10 | escalation (dark/error/large-text/mobile), parts request (dark/error/large-text/mobile) | Pre-existing stale golden |
| `technician_today_test.dart` | 7 | Phase 10 | active/dark/desktop/empty/large-text/no-active/tablet | Pre-existing stale golden |

**Evidence that these predate Phase 06 (conclusive):**
1. **Environment golden drift is proven by the Phase 06 baseline itself** — `advisor_phase06_visual_test` was **0/14 failing** before any Phase 06 code change (recorded in `REPORT_PHASE_06.md` §9). The same rendering environment therefore invalidates the committed golden baseline across `staff_app`.
2. **The failing goldens are tracked and unmodified** — `git status --short` shows no changes to any `technician_*`, `intake_*`, `scan_*`, `checkin_*`, `supervisor_login_*`, or `staff_profile_*` PNG; only the 14 `advisor_*` goldens are modified (by Phase 06).
3. **The tested source was not touched** by Phase 06 (technician/supervisor/intake feature code is unchanged).
4. **No shared dependency is broken** — the only cross-feature import is `technician_dashboard_view.dart` → `advisor_notification_sheet.dart` (source-noted reuse). No technician/supervisor test imports an advisor widget; the notification sheet is a modal not rendered by the failing default-state goldens.
5. **Baseline report corroboration** — `REPORT_PHASE_04_1` §9 records `staff_app` baseline **267 passed / 76 failed**; 76 = 62 (other phases, still failing) + 14 (Phase 06 goldens, now passing). This supports the reported failure-count reduction of **exactly 14**.

**Reconciliation nuance (not a blocker):** baseline total tests (343) + the 11 new Phase 06 tests (1 guard + 10 shell) should equal 354, but the observed total is 353 — a **1-test accounting delta**. It does not affect failure composition or ownership-phase attribution, but the exact baseline total is not perfectly reconciled by the available reports. Flagged as unresolved evidence detail.

**Failure that cannot be conclusively classified:** none. Every one of the 62 is a golden mismatch in an untouched, other-phase test file, and all become explicable by environment golden drift + unmodified assets. The 14 Phase 06 goldens now pass.

**No non-golden failure is hidden in the count.**

---

## G. Risk register

| ID | Finding | Affected | Evidence | Impact | Rank | Smallest next action |
| :-- | :-- | :-- | :-- | :-- | :-- | :-- |
| G-1 | Live device/browser acceptance never performed | All Phase 06 screens | `REPORT_PHASE_06.md` §11; this audit (headless only) | Gate 2 is a live/human gate; keyboard, focus, real connectivity, resize, transitions unproven | **Blocker (to full Gate 2 closure)** | PO provides a device/emulator/browser for a live pass; keep status *NOT VERIFIED* until then |
| G-2 | `advisorPendingSyncCountProvider` is not reactive to `SyncQueue` mutations | Home/shell offline pill queued state | `advisor_providers.dart:22-28` | Queued count may lag until an unrelated rebuild; offline detection itself is live via `connectivityStatusProvider` | **Medium** | Recompute queued count when the queue signals a change (e.g., watch a queue `StateProvider`/revision) — out of audit scope |
| G-3 | Missing visual evidence for key states | Home/Jobs/Reports/Job detail | Absence of goldens: dark, offline/queued, loading/error/empty/no-match, search + 4 modal sheets, jobs desktop matrix | States are asserted by tests but cannot be visually accepted | **Medium** | Capture additional Phase 06 goldens (dark + state + sheets + jobs desktop) in a follow-up |
| G-4 | Desktop KPI tiles look vertically sparse | Home (1280) | `advisor_today_1280_en.png` | Minor aesthetic; consistent with Concept A tile spec | **Low** | Optional density tweak if PO objects |
| G-5 | Froster/translucency readability over scrolled content not demonstrated | Shell headers | Header captured at scroll-top only | Frosted readability unproven in isolation | **Low** | Live scroll capture |
| G-6 | Stray root `l10n_untranslated.json` (untracked) | Repo hygiene | `git status` | None functional; two untranslated artifacts | **Low** | Tidy in a maintenance pass |
| G-7 | Jobs desktop `AppTable` rendered inside a non-lazy `ListView` | Jobs (wide) | `advisor_jobs_view.dart` master builder | Potential cost for very large job lists | **Low** | Pass `maxHeight`/virtualise if needed |

No Blocker/High finding exists in the *delivered code or design*; G-1 is a process/evidence gap, not a product defect.

---

## H. Gate 2 acceptance checklist

**Verified PASS**
- All Phase 06 surfaces S1–S11 present and compositionally distinct (source + 14 renders).
- Concept A identity consistent across captures (canvas/surfaces/hairline/cobalt/status grammar).
- Responsive composition at 390 / 768 / 1280 in EN and AR (renders) with no visible overflow/clipping.
- EN/AR RTL mirroring correct; identifiers/plate/VIN/money non-mirrored (renders).
- Phase 06 theme architecture clean (0 palette/hex/brightness refs across 24 files); guard passes.
- ARB parity clean; `l10n_untranslated.json` empty; generated localizations updated.
- Required shell integration present and wired: `WorkspaceAppBar`, `OfflineStatusPill`, `DashboardShell(showOfflineBanner:false)`, `WorkspaceSearchShortcuts`, `AdvisorSearchSheet`, breadcrumbs, `AppMasterDetailScaffold` + `AppTable`.
- `advisor_experience` 21/0, `advisor_phase06_visual` 14/0, shell 10/0, guard 1/0; `shared_core` 324/0; `shared_auth` 74/0.
- The 62 `staff_app` failures are other-phase stale goldens (verified; assets unmodified).

**Verified FAIL**
- None identified in the delivered Phase 06 scope.

**NOT VERIFIED**
- Live device/emulator/browser acceptance of any screen (not performed).
- Keyboard shortcut activation on a physical keyboard; focus traversal order; Enter/Esc behaviour.
- Real connectivity transitions and offline/queued pill rendering.
- Live pending-sync count updates after enqueue.
- Real API-backed loading/retry/error and dynamic refresh.
- Window resize across every breakpoint (320/360/430/600/834/1024/1440) and navigation transitions.
- Dark-theme aesthetic acceptance and the un-captured states listed in §B (search, 4 modal sheets, jobs desktop matrix, loading/error/empty).
- Froster header readability against scrolled content.

---

## I. Final recommendation

The Phase 06 design and engineering evidence **meets the headless bar and is compatible with Concept A**, and no Phase 06 defect or regression was found. However, the available evidence **does not yet support a full Gate 2 closure** because:

1. Gate 2 explicitly requires human visual acceptance and live validation (`00_VISUAL_ACCEPTANCE_RULES.md`), and no live device/browser pass exists.
2. Several states/themes lack captured evidence (dark, offline/queued, loading/error/empty, search + modal sheets, jobs desktop matrix).

**Recommended path:** request Product Owner review of `reports/PHASE_06/screens/` now (design direction appears approvable), and schedule (a) a live device/browser pass and (b) capture of the missing states before final sign-off. Optionally address G-2 (reactive sync count) in a small follow-up.

This audit makes **no claim of Product Owner approval** and recommends **no implementation changes** in the audit itself.

---

## Appendix — Audit integrity statement

- `git status --short` recorded before and after: **84 entries, unchanged**; no files added, modified, deleted, or reformatted by this audit.
- No golden was regenerated/overwritten/deleted; no `--update-goldens` was executed; the `test/failures/` scratch directory was confirmed absent (not created by this audit).
- No production source, test, specification, localization, lockfile, or configuration file was modified.
- Test evidence was read from previously captured, out-of-repo logs (`%TEMP%/opencode/staff_full_test*.txt`) plus non-golden, read-only test runs (`advisor_theme_architecture_test`, `arb_parity_test`, `localization_cross_boundary_test`).
- Phase 07A/07B were not started.
- The phase ledger approval state was left untouched.
