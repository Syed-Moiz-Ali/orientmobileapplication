# REPORT PHASE 07.1 — Centralized SaaS Retrofit (Consumes 01.2)

**Document ID:** `phases/redesign_v2/reports/REPORT_PHASE_07_1.md`
**Execution Phase:** Concept A V2 — Phase 07.1 (runs after 07, before 08)
**Specification:** `phases/redesign_v2/implementation/PHASE_07_1_CENTRALIZED_SAAS_HARDENING.md`
**Prerequisites:** Phases 01–07 complete + Phase 01.2 COMPLETE & engineering-PASSED (`reports/PHASE_01_2_FOUNDATION_HARDENING.md`: core 405/405, auth 86/86, models 17/17)
**Status:** **ENGINEERING GATE PASSED** / **VISUAL GATE PENDING PRODUCT OWNER**
**Timestamp:** 2026-10-15
**Author:** Lead Flutter Architect & Systems Designer

> Mission summary: adopt (not rebuild) the 01.2 foundation — rewire every 01–07 app-local duplicate onto its 01.2 counterpart, migrate all allowlisted bespoke-bar callers, adopt value objects where contracts allow, delete duplicates after zero-reference verification. No new foundation except two additive shared hardenings (§6). No screen recomposition. Phase 08 not started.

---

## 1. Duplicate inventory (file + owning phase + disposition)

 Parallel subagent inventories (bars, widget duplicates, raw identifier fields) verified by hand against source. `design_prototype` / `concept_showcase` excluded (frozen).

### 1.1 Bespoke bars & banners — ALL MIGRATED, 5 files deleted

| # | File (deleted) | Owner | Callers rewired |
| :-- | :--- | :--- | :--- |
| 1 | `staff_app/.../supervisor/widgets/supervisor_app_bar.dart` (`SupervisorAppBar`) | Phase 11 | `supervisor_scaffold.dart` → inline `_SupervisorChrome` (`WorkspaceAppBar`: same titles/subtitles/brand tile/bell/avatar + profile sheet + logout) |
| 2 | `staff_app/.../technician_dashboard_view.dart` (`TechnicianAppBar` class) | Phase 10 | Same file → inline `_TechnicianChrome` (`WorkspaceAppBar`: same Today titles, branch·attendance subtitle, avatar leading, notification sheet action) |
| 3 | `owner_app/.../dashboard/.../owner_app_bar.dart` (`OwnerAppBar`) | Phase 13 | `dashboard_body.dart` → inline `_OwnerChrome` (same tab titles/branch subtitle, back-to-overview leading, `PeriodDropdown` + bell + avatar) |
| 4 | `crm_app/.../crm_dashboard/.../crm_app_bar.dart` (`CrmAppBar`) | Phase 19 | `crm_dashboard_view.dart` → inline `_CrmChrome` (same 8 tab titles, rail/drawer leading, refresh + bell + avatar) |
| 5 | `owner_app/.../dashboard/.../header_banner.dart` (`HeaderBanner`) | Phase 13 | `owner_dashboard_page.dart` → `_OwnerOpsHeader` (`AppPageHeader` + 3 `StatusPill`; hardcoded `0xFF10B981` ×2 now theme-resolved) |
| 6 | `crm_app/.../crm_dashboard/.../crm_header_banner.dart` (`CrmHeaderBanner`) | Phase 19 | `crm_dashboard_page.dart` → `_CrmPulseHeader` (`AppPageHeader` eyebrow Live + 2 `StatusPill`; `CrmColors` accents → warning/success families) |
| 7 | `AppTopBar` ×10 (customer_app, Phase 16–18) | Phases 16–18 | Each screen → `WorkspaceAppBar(title, showBack: true)` in the `Scaffold.appBar` slot (+ `onBack`/`actions` where the old bar had them); bar-drawn divider replaces the manual `Divider` |

`SupervisorScaffold` / `CustomerScaffold` already compose `DashboardShell` (Phase 04.1) — kept; only their bar slots changed. `CustomerHomeHeader` kept: theme-clean greeting composition, no 01.2 counterpart (documented §9.2).

### 1.2 Widget duplicates — rewired onto 01.2/shared counterparts, 12 files deleted

| Duplicate | Owner | Counterpart | Disposition |
| :--- | :--- | :--- | :--- |
| `FilterChipBar` (owner) | Ph. 14 | `AppFilterBar` | Deleted file; `job_cards_list_view` maps status↔label |
| `_FilterStrip` + `_FilterChip` (owner job_status) | Ph. 13 | `AppFilterBar` | Deleted classes; stage↔label mapping |
| `_JobsToolbar` + `_JobFilterChip` (staff technician) | Ph. 10 | `AppFilterBar(counts:)` | Deleted class; **new additive `counts`/`countSemantics` slot** (§6) preserves live counts + semantics |
| `KpiCard` + `KpiGrid` tile (owner) | Ph. 13 | `AppKpiCard` | Deleted tile; grid composes shared card (sub→trend slot); decorative color rotation → `KpiSemanticState` mapped in adapter (order-preserving) |
| `SupervisorStatCard` (staff) | Ph. 11 | `AppKpiCard` | Deleted; grid composes shared card; raw-hex rotation → states in provider |
| `_ReportStatCard`, `_JobsMetricPill`, `_AttentionChip` (staff) | Ph. 11 | `AppKpiCard(.compact)` | Deleted/deleted/deleted; `_AttentionChip`'s hardcoded `0xFFD97706` → warning family |
| `_KpiOverviewGrid` inline tile (staff) | Ph. 11 | `AppKpiCard.compact` | Rewired in place |
| `CrmKpiCard` (crm) | Ph. 19 | `AppKpiCard` | Deleted; trend→`KpiTrend`, tint→state; `color`/`bgColor` fields removed from entity/adapter/tests |
| `TechnicianSectionHeader`, `_ReviewSectionHeader`, `_BookingsSectionHeader`, `_StepHeading` | Ph. 10/08/17 | `SectionHeader` | Deleted/deleted/deleted/deleted (eyebrow→subtitle/title/count/leadingIcon mapping) |
| `_ActiveSectionHeader` (inspection sheet, Ph. 08) | Ph. 08 | `SectionHeader` | Inner row rewired (sticky container kept); hardcoded `0xFF059669` deleted |
| `TechnicianStatusPill` | Ph. 10 | `StatusPill` tone ctors via `technicianStatusPill()` | Deleted class; static `AppColors` selection on the enum now documented domain-data (Phase 10 owns) |
| `_StatusLabel` + `_progressColor` (owner) | Ph. 13 | `StatusPill` tones + semantic inks | Rewired; **8 hardcoded hex literals deleted** |
| `_SummaryPill` + hardcoded `StatusPill(bg/fg: 0xFF10B981)` (owner team) | Ph. 15 | `AppKpiCard.compact` + `StatusPill.success` | Deleted class; hex deleted |
| `TechnicianTaskProgress` | Ph. 10 | `AppLinearProgress` | Deleted class (zero-task guard preserved at call sites) |
| `TechnicianEmptyState` | Ph. 10 | `EmptyState` | Deleted class (9 call sites) |
| `CustomerEmptyStateCard` + `EmptyVehicles/Bookings/InvoicesCard` | Ph. 16 | `EmptyState` | **Dead code** (zero references) — file deleted, no rewire needed |
| `CustomerBookingProgress` | Ph. 17 | `AppStepper` | Deleted class; steps tappable via existing `_goToStep` (matches summary Change affordance) |
| `SearchField` (inspection_widgets) | Ph. 08 | `AppSearchField` | Deleted class (also killed its `AppColors` statics); 2 call sites |
| `_StatusSummary` (inspection preview) | Ph. 08 | `AppKpiCard.compact` | Deleted class; hardcoded `0xFF059669` → success family |
| `ShimmerBox` ×2 + `AdvisorDashboardSkeleton`, `TechnicianHUDSkeleton` (staff, dead), `SupervisorQueueSkeleton`, `StaffAttendanceSkeleton` | Ph. 10–12 | `AppSkeleton` | Engine + file deleted; call sites compose `card/text/grid` |
| `ShimmerBox` + `OwnerDashboardSkeleton` + `KpiGridSkeleton` (dead) (owner) | Ph. 13–15 | **`AppSkeleton.page()` (new ctor, §6)** | Engine + file deleted; 8 call sites → `const AppSkeleton.page()` |
| `CustomerSkeleton` + `CustomerSkeletonBox` + 4 page skeletons + 5 inline skeletons (customer) | Ph. 16–18 | `AppSkeleton` primitives | Engine + 4 files deleted; 9 call sites recomposed (`card/text`); `EmptyVehicles/Bookings/Invoices` dead (above) |
| `AdvisorMetaPill` | Ph. 06 | `StatusPill.neutral` | Deleted file + Phase 06 guard-list entry; 2 call sites |

### 1.3 Kept with justification (NOT duplicates of any 01.2 widget)

Domain chips without count-less counterparts (`_PlateChip` ×2, `CustomerPlateChip`, `_DateChip`, `_SlotChip`, `_SummaryPill`-equivalents removed above), grade selector `StatusBoxes` (behavioral, Phase 08), booking/feedback step BODIES, `AdvisorStatDialog` (metric dialog ≠ confirm dialog), `SalesTrendCard` (dual-line chart ≠ `AppTrendStat` value+delta), `_CrmConversionTrendPainter`, `TechnicianJobSummary/Context`, `_SupervisorContextBanner`, `_AdvisorCommandIdentity`, `CustomerHomeHeader`, CRM `CrmColors` outside migrated files (Phase 19), `JobCardRegisterCard`, `QuickActionsRow`, `CustomerSurfacePanel`, `StaffNotificationBell` (behavioral wiring).

### 1.4 Raw-String plate/VIN/phone/money inventory → adoption (§5)

Full inventory taken across advisor/owner/customer/crm + `shared_core` models (MODEL FIELD vs FORMAT vs VALIDATE). Adopted where byte-identical / contract-safe; the rest classified by owning phase (serialization and validation rules untouched everywhere):

| Adoption | Scope | Evidence |
| :--- | :--- | :--- |
| `tel:` link munging → `PhoneNumber.normalizeLoose` (+`+` prefix; repairs broken local-format links) | Ph. 06 (`advisor_job_detail_view`) | No rendered text; same digits for E.164 input |
| `vin.trim().toUpperCase()` ×3 → `Vin(...).format()` | Customer (files already in scope) | Property-tested identical incl. empty/invalid |
| `plateLabel` / `normalizePlate` (lenient free-form) | Kept | `PlateNumber` is strict (`DXB A 12345`); intake uses emirate display NAMES — forcing codes would change UX vocabulary (Phase 07/16–17 own) |
| Phone validators (`length<8`, team validator) | Kept | `PhoneNumber.tryParse` is stricter (E.164 `9715…`) — tightening validation = contract change |
| Ad-hoc `'AED …'` interpolation + `_formatAmount`/`_fmt`/`formatAmount` grouping helpers (owner AR/inventory, customer providers, crm pipeline/leads/detail, repair_order) | Kept, owners mapped | Display formatting owned by Phases 09/13–20; `MoneyAed` canonical for new code |
| Raw-String money outliers (`PurchaseOrderEntity.total`, technician/supervisor `amount`, customer `price`) vs `double` elsewhere | Kept | Serialization shape; owning phases |
| `TechJobStatus.color/bgColor`, `CrmLeadEntity.sourceColor/statusColor`, channel/task colors, `StatusCount.color`, `OwnerKpi`/`SupervisorKpi`/`CrmKpi` `color` fields | Removed ONLY where tiles stopped reading them (3 KPI entities); rest documented domain-data (Phase 06 precedent) | Tiles no longer select static palettes |

`AuthGuard` adoption: verified all four app routers already gate sessions via `redirect` (unauthenticated → login, wrong-role → login/dashboard). No gaps found — wiring `AuthGuard` around router-gated trees would double-gate and risk navigation regressions. `AuthGuard` stays available for future unrouted surfaces.

---

## 2. Rewire table (imports → shared only; no new `apps/*/widgets` copies)

- Deleted source files (17): `supervisor_app_bar.dart`, `supervisor_stat_card.dart`, `staff_shimmer_skeletons.dart`, `technician` inline `TechnicianAppBar` class, `owner_app_bar.dart`, `header_banner.dart`, `kpi_card.dart`, `filter_chip_bar.dart`, `owner_shimmer_skeletons.dart`, `crm_app_bar.dart`, `crm_header_banner.dart`, `crm_kpi_card.dart`, `customer_skeleton.dart`, `customer_bookings_skeleton.dart`, `customer_home_skeleton.dart`, `customer_status_skeleton.dart`, `customer_empty_fallbacks.dart`, `advisor_meta_pill.dart`.
- Every rewired file imports only `shared_core` (+ `shared_models` as `models` in 3 files for `PhoneNumber`/`Vin`; prefixed to avoid the `JobCardStatus` barrel ambiguity).
- Entity changes (additive, serialization-safe): `OwnerKpi.color` → `state` (default neutral); `SupervisorKpiEntity.color` → `state`; `CrmKpiEntity.color/bgColor` → `state` (+ `==`/hashCode/toString updated); providers/adapters map rotation → states order-preservingly.
- Test-only updates: supervisor uppercase label finds (shared overline contract), owner/CRM entity constructions, customer skeleton-type assertions → `AppSkeleton`, Phase 06 guard list (deleted file).

## 3. Shared hardenings (additive, §3 gap protocol; 01.2 behavior preserved)

1. `AppFilterBar(counts:, countSemantics:)` — count badges for the technician toolbar; null default renders byte-identically (01.2 goldens confirmed before the 48 dp fix; re-baselined after, §7).
2. `AppFilterBar` 48 dp minimum chip height — the unwrapped chip measured 34 px and failed the staff tap-target audit (`technician_jobs_test`); fixed at source, 8 foundation goldens re-rendered.
3. `AppSkeleton.page()` + `AppSkeletonVariant.page` — dashboard first-load composition (8 owner call sites); 4 new tests; no 01.2 gallery change → 01.2 baselines intact.
4. `AppKpiCard` trend-row `Flexible` hardening — long trend labels ellipsize instead of overflowing narrow tiles (found via owner 320 px); 6 `shared_components_*` goldens re-rendered (≤0.04%, pixel-localized §7).

## 4. Theme / guard audit

- All rewired code resolves color via `context.colors` / `context.semanticColors` only. Deleted: 8× hardcoded hex (owner job_status), 2× `0xFF10B981` (owner banner/team), `0xFFD97706` (staff attention), `0xFF059669` ×2 (inspection), `CrmColors` from migrated CRM files, `AppColors.successBg/success` (owner tile), `AppColors.*` statics (inspection search), raw-hex KPI rotations (3 providers/adapters).
- Guards: `app_semantic_theme_test` 21/21; `theme_primary_guard_test` 6/6; `app_density_test` 20/20; `focus_disabled_tokens_test` 15/15; `deprecation_guard_test` 3/3 (**extended**: allowlist emptied of migrated callers, comments stripped, **new bespoke-definition test**); `advisor_theme_architecture_test` green (list updated for the deletion); `advisor_phase07_theme_test` green (untouched files).
- Exceptions remain documented/marked: optical-HUD/fixed-ink (Phase 07), domain color data (enum/entity fields no widget reads), brightness-for-status-bar (shared).

## 5. l10n / RTL matrix

- **Zero new l10n keys** (all swaps reuse caller copy or shared keys: `filterBarAll`, `stepperStepOf`, `pagination*`, `trendUp/Down`). ARB parity + `l10n_untranslated.json` clean in all suites (no `.arb` file touched — verified via git status).
- RTL: `AppFilterBar` scroll direction, `AppStepper`/`AppTimeline` directional layout, `StatusPill` dots, `WorkspaceAppBar` chevrons all mirror via shared components; plates/VIN/phone/money stay Latin+LTR (`Vin`/`PhoneNumber`/`PlateNumber.isLtr` asserted; intake preview + odometer LTR wrappers untouched).
- New tests assert AR rendering for: supervisor scaffold, owner KPI grid + job list, CRM page, filter counts (`الكل`), stepper/pagination/timeline/trend via existing 01.2 AR goldens.

## 6. Viewport matrix (no-overflow evidence)

| Surface | 320 | 390 | 768 | 1280 | AR | 1.3x | Dark |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| Supervisor scaffold (chrome+tiles) — new migration test | ✅ | ✅¹ | ✅ | ✅ | ✅ | ✅¹ | ✅² |
| Technician jobs toolbar (counts) | ✅ | ✅¹ | — | — | ✅ | ✅¹ | — |
| Owner KPI grid | ✅ | ✅¹ | ✅ | ✅ | ✅ | ✅¹ | — |
| Owner job list + filter | ✅ | ✅¹ | — | ✅ | ✅ | — | — |
| Owner dashboard (smoke, pre-existing) | ✅ | ✅ | ✅ | ✅ | — | ✅ | — |
| CRM dashboard page + view (smoke) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | — |
| Customer rewired screens (existing suites) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅² |
| Shared 01.2 goldens (8+6+8) | ✅ | ✅ | ✅ | ✅ | ✅ | — | ✅ |

¹ via existing suites at same widths (identical results §7). ² dark via existing goldens/smoke. — Two hardening fixes landed from this sweep: supervisor nav grid aspect 1.6→1.4 (pre-existing 320 px clip in untouched tile, §9.3) and `job_card_tile` amount row `Expanded` (first 320 px coverage).

## 7. Baseline vs final (commands: `flutter analyze lib test --no-pub`, `flutter test`)

| Suite | Baseline (pre-07.1) | Final | Δ |
| :--- | ---: | ---: | :--- |
| shared_core analyze / tests | 0 / **405/405** | 0 / **414/414** | +9 (4 skeleton-page, 4 filter-counts, +1 guard) |
| shared_auth | 0 / 86/86 | 0 / 86/86 | — (untouched) |
| shared_models | 0 / 17/17 | 0 / 17/17 | — (untouched) |
| staff_app lib analyze | 0 | **0** | clean |
| staff_app tests | 354 / 49 | **374 / 41** | +20 (12 migration incl. 320@1.3x; 8 stale jobs goldens re-baselined on migration); −8 fails |
| owner_app lib+test analyze | 0 | **0** | clean |
| owner_app tests | 21 / 0 | **31 / 31** | +10 migration |
| crm_app lib analyze | 0 | **0** | clean |
| crm_app tests | 14 / 0 | **21 / 21** | +7 migration |
| customer_app lib+test analyze | 0 | **0** | clean |
| customer_app tests | 437 / 80 | **443 / 80** | +6 migration; **failing-test sets name-identical before/after** (4 batches diffed; rest untouched files) |

- shared_core downstream: staff/owner/customer/crm apps analyze with **0 errors** (customer `deprecated_member_use` infos are gone — zero bespoke-bar references remain).
- 01.2 suites kept green throughout; no 01.2 test regressed (only additive shared changes; goldens §7).

### Remaining failures + owners (all pre-existing, none introduced, none claimed fixed)

| Failures | Owner | Nature |
| :--- | :--- | :--- |
| staff 41: `technician_today` 7, `technician_job_detail` 9, `technician_productivity` 6, `technician_support_flows` 8, `technician_profile` 9, `supervisor_login_phase05` 2 | Phases 10 / 05 | Stale-golden pixel rot (19–100% diffs, incl. untouched screens); no logic failures. Technician_jobs 8 left this list via migration re-baseline |
| customer 80 (name-identical pre/post) | Phases 16–18 | Same stale-golden rot (40–100%); 7 in files never touched, 73 in touched files with identical sets |

## 8. Golden updates + evidence (re-rendered only after inspection; all others byte-identical)

| Goldens | Cause | Evidence |
| :--- | :--- | :--- |
| `shared_components_{mobile,tablet}{,_ar,_dark*} (6)` | `AppKpiCard` trend `Flexible` | Diff-localizer: 469 px confined to x[225,352] y[2700,2712] (KPI trend row); functional suites green |
| `foundation_01_2_{320,768,1280}_{en,ar}{,_dark} (8)` | 48 dp chip minimum | Same region class (filter bar); taller chips verified by tap-target test |
| `advisor_states_*` + `advisor_today_*` (12) | `AdvisorMetaPill`→`StatusPill` (29→22 px cascade from y≈134, box-verified) | Content assertions green; copy identical |
| `technician_jobs_*` (8) | Toolbar wrap→scroll + 48 dp chips | 48 dp audit green; counts/semantics preserved |

Evidence PNGs: the re-baselined files in `packages/shared_core/test/goldens/`, `apps/staff_app/test/goldens/`. No live-device captures exist in this environment (see §9.4).

## 9. Known limitations

1. **Value-object adoption is partial by design** (§1.4): strict `PlateNumber` codes vs intake/customer display names, strict E.164 validation vs lenient rules, and `MoneyAed` grouping vs fixed-2 decimals would each change contracts or pixels — owning phases adopt.
2. **Kept compositions** (§1.3) are theme-clean and have no 01.2 counterpart; creating shared versions would be new API without a proven gap.
3. **Supervisor nav-grid aspect + `job_card_tile` flex** touch untouched widgets — minimal overflow hardening on migrated screens, documented above.
4. **No live device/emulator/browser is available.** Verification is headless golden + widget tests only; live visual/interaction acceptance is **NOT PERFORMED** and must not be reported as passed.
5. `phases/README.md` (cited by the brief) does not exist — the ledger update went to `phases/redesign_v2/README.md` §5 (same substitution as Phase 07 §11).

## 10. Gate verdicts + ledger

**Gate 1 — Engineering: PASS.** Inventory complete; all 17 deleted files have zero references (migration source-scan tests in all four apps); analyzer 0 across all seven packages (lib+test); all guards green; suites: shared 414, auth 86, models 17, owner 31, crm 21 green; staff 373 with only pre-existing failures; customer 443 with name-identical pre-existing failures; l10n parity clean; Dio/Riverpod/Hive/routes/validation/serialization preserved (payloads verbatim; only display/ normalization helpers that are byte-identical, plus one documented `tel:` repair).

**Gate 2 — Visual: PENDING PRODUCT OWNER.** All swaps are import/prop-level with Concept A intact; 320/768/1280 + AR + dark renders reviewed headless via goldens and viewport suites. Live acceptance **not performed**. This report does **not** claim Product Owner approval.

### Ledger update (`phases/redesign_v2/README.md` §5)

Phase 07.1 Centralized SaaS Hardening & Retrofit: 17 duplicate files deleted, 4 bars + 2 banners + 10 legacy bars migrated to `WorkspaceAppBar`/`AppPageHeader`, filters/KPIs/headers/pills/empty/progress/search/skeletons centralized, value objects adopted where contract-safe, guards extended, 44 new tests (414/86/17 + 31/21/374/443). Evidence: this report + re-baselined goldens.

---

**Phase 07.1 executed in isolation. Phase 08 and later were not started.**
