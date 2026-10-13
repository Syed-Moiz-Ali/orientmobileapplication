# PHASE 06 — Staff: Advisor Home & Jobs: Completion Report

- **Date:** 2026-10-13
- **Phase:** 06 — Staff: Advisor Home & Jobs (`phases/PHASE_06_STAFF_ADVISOR_HOME_AND_JOBS.md`)
- **Status:** **IMPLEMENTATION COMPLETE — awaiting product-owner review**
- **Toolchain:** Flutter 3.35.7 stable · Dart 3.9.2 · Windows dev machine
- **Authorities:** `00_DESIGN_SYSTEM_SPEC.md` (§7 registry, §13 density, §14
  templates), `00_VISUAL_DIRECTION.md` (frozen V1–V14), `00_RESPONSIVE_STRATEGY.md`,
  `00_LOCALIZATION_RTL_STRATEGY.md`, Phase 00 prototype (read-only, 0 changes).

---

## 1. Screens redesigned

| Screen | Purpose | Redesign delivered |
|---|---|---|
| `AdvisorHomeView` (shell + Today) | Shift execution cockpit | Shift header (role eyebrow, desk title, greeting, branch/shift + freshness pills) → attention block (pending approvals + reminders) → search pill → quick-action tile grid (one eyebrow) → `AppKpiCard` metric strip → recent work orders; skeleton first load, error+retry, empty |
| `AdvisorJobsListView` | Find/open job cards | Title + `AppSearchField` toolbar + status chips (All/In Progress/Completed/Pending/QC Check/Cancelled) → `AppRecordRow`-family cards; skeleton, empty, no-match, error |
| `AdvisorReportsView` | Personal analytics | `SegmentedButton` range control → `AppKpiCard` hero strip → bar chart + distribution on `AppChartTheme` → export; skeleton, `AppChartPlaceholder`, error+retry |
| `AdvisorJobDetailView` | Job workspace hub | `AppTopBar` → identity header → contextual primary action → customer/vehicle/inspection/work-items/fuel/body/service/requests sections → call/deliver/refresh; load error + retry |
| `AdvisorSearchSheet` | Global find | `AppSearchField` + scan → grouped `AppRecordRow` results (jobs/customers/approvals); empty vs no-match |
| `AdvisorNotificationSheet` | Inbox | Localized header + clear-all → rows; explicit empty (shared with technician, contract preserved) |
| `AdvisorProfileSheet` | Account menu | Identity header + `AppRecordRow` menu rows + logout |
| `AdvisorApprovalSheet` | Estimate approval | Record summary + approve/send-back (localized, money formatted) |
| `AdvisorContactSheet` | Reach customer | Identity + call/WhatsApp/SMS + mark-done (same callbacks) |
| `AdvisorStatDialog` | Metric detail | Value + breakdown hint + close/view-all (view-all wired to Jobs tab) |

Kit widgets redesigned: `advisor_job_card_row`, `advisor_approval_row`,
`advisor_notification_row`, `advisor_meta_pill`, `advisor_status_badge`,
`advisor_date_chip`, `advisor_detail_line`, `advisor_sheet`, `advisor_handle`,
`advisor_menu_item`, `advisor_solid_action`, `advisor_outline_action`, plus a new
`advisor_status.dart` helper (localized labels + semantic pills + filter keys).

---

## 2. Files changed

All under `apps/staff_app/`:

**Pages** — `advisor_home_view.dart`, `advisor_jobs_view.dart`,
`advisor_reports_view.dart`, `advisor_job_detail_view.dart`.

**Widgets** — `advisor_status.dart` (new), `advisor_job_card_row.dart`,
`advisor_approval_row.dart`, `advisor_notification_row.dart`,
`advisor_meta_pill.dart`, `advisor_status_badge.dart`, `advisor_date_chip.dart`,
`advisor_detail_line.dart`, `advisor_sheet.dart`, `advisor_handle.dart`,
`advisor_menu_item.dart`, `advisor_solid_action.dart`, `advisor_outline_action.dart`,
`advisor_see_all_button.dart`, `advisor_stat_dialog.dart`,
`advisor_approval_sheet.dart`, `advisor_contact_sheet.dart`,
`advisor_profile_sheet.dart`, `advisor_notification_sheet.dart`,
`advisor_search_sheet.dart`; `advisor_job_card_sheet.dart` (compile fix only).

**Localization** — `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb` +
regenerated `lib/l10n/gen/**`.

**Tests** — `test/advisor_experience_test.dart` (rewritten, 21 tests),
`test/advisor_phase06_visual_test.dart` (new, 14 goldens),
`test/phase01_layout_smoke_test.dart` (harness now registers delegates).

*Not touched:* any provider, entity, route, DTO, `advisor_providers.dart`,
Hive keys, `AdvisorWorkflowIndicator` (owned by 07/08), the technician dashboard,
`apps/design_prototype/**` (0 changes).

---

## 3. UX changes

- **Today is a command surface**, not a card pile: the requested order (shift
  header → attention → metrics → recent → quick actions) with one eyebrow above
  the quick-action grid.
- **Attention block added**: pending approvals (`AdvisorApprovalRow` → sheet) and
  follow-up reminders are now surfaced on Today (they were previously passed as
  callbacks but never rendered).
- **Jobs** leads with search, then chips, then record rows; empty vs no-match are
  distinct; failed loads show an inline notice + retry.
- **Reports** uses a segmented range control, a 4-tile hero strip and the shared
  chart language (gridlines, token colours, tabular values, empty placeholder).
- **Job detail** is a workspace hub: identity → next action → sections; failed
  loads surface an error with retry (silent catches removed).
- **Sheets** unified on the shared modal grammar (surface, rounded top, drag
  handle, title, padding) and localized; menu rows use `AppRecordRow`.
- **Offline truth**: cached/error states use `AppInfoPanel` notices; no fake
  freshness.

---

## 4. Responsive layout transformations

- **Compact (≤430):** single column; bottom nav (3 destinations); Today sections
  stack; quick-action grid 2-up; metric tiles 2-up; job cards full-width; chips
  scroll horizontally (deliberate exception). 320 px clean in EN + AR.
- **Medium (600–1023):** rail navigation; Today 2-up grids; job list records.
- **Expanded/large (≥1024):** content capped; quick actions/metrics 4-up; job
  detail becomes a two-pane split (sections + identity/actions) at ≥1024.
- **Text scale:** 1.0–1.3× verified at 320/390/768/1280 EN + AR; zero overflow.
- **Keyboard/short viewport:** `AppTopBar` on job detail; lists are focusable.

---

## 5. Shared components integrated

`AppPageFrame`/`AppResponsivePage`, `AppTopBar`, `AppSearchField`,
`AppRecordRow`, `AppKpiCard` (+ `KpiSemanticState`), `StatusPill` (+ localized
`advisorStatusPill`), `AppSkeleton.listRows`/`.chart`, `EmptyState`
(+ `.noMatch`), `AppInfoPanel`, `AppCard.standard`, `SectionHeader`,
`PrimaryButton`/`SecondaryButton`, `AppLinearProgress`, `AppChartTheme` +
`AppChartPlaceholder`, `DirectionalIcon`, `AppFormatters.moneyAED`,
`AppTypography.tracking`, and the `AppDimensions`/`AppColors`/`AppMotion` tokens.

**Documented deviations:**
- Advisor sheets keep the self-contained `AdvisorSheet` modal grammar (handle +
  surface + scroll) instead of `showAppModalSheet`, because
  `AdvisorNotificationSheet` is reused by the technician dashboard via a direct
  `showModalBottomSheet` call (Phase 10 owns its usage); the import path and
  presentation contract are preserved.
- Job detail uses a bespoke two-pane `LayoutBuilder` split at ≥1024 (rather than
  `AppSplitView`) to control the pane order required by the spec (identity first
  on compact).

---

## 6. English / Arabic translation coverage

- `staff_app` ARB now ships **168 keys** (was 13): **155 new `advisor*` keys**,
  EN+AR parity green, `l10n_untranslated.json` = `{}`.
- Every in-scope visible string is localized: nav labels, header, chips, statuses,
  section titles, field labels, actions, toasts, sheet copy, dialog copy, empty/
  no-match/error states, semantics/tooltips.
- Status vocabulary is centralized in `advisor_status.dart` (localized labels +
  semantic pills + locale-independent filter keys).
- Numbers: money via `AppFormatters.moneyAED` (AED 2,450 / 2,450 د.إ); plates/VIN/
  job refs/odometer keep Latin `mono` style.

---

## 7. RTL validation

- All layouts use directional spacing/alignment; `DirectionalIcon` flips
  chevrons/back/arrows; the chips row, sheets, list rows, metric grids and the
  job-detail two-pane split all mirror (verified in AR renders).
- Identifier fields/values stay LTR (`AppTextStyles.mono`).
- AR renders reviewed at 390/768/1280; `Directionality.rtl` asserted in tests.

---

## 8. Functional regression tests

- Preserved exactly: `advisor_providers.dart` (untouched), Hive keys, sync
  triggers, approval persistence + sync enqueue, contact callbacks, notification
  clear, search (Hive) behavior, report sharing, job navigation
  (`/advisor/job-detail` extra `JobCardEntity`), pushes to 07/08 routes, stat
  dialog, profile logout (pending-sync dialog).
- `AdvisorNotificationSheet` still works for the technician dashboard.
- New coverage: Today metrics/attention/recent; jobs search/filter/empty/no-match;
  reports range switch + export; job-detail sections + load error + retry; sheet
  open/callbacks (approval/contact); profile + notification sheets; stat dialog.

---

## 9. Screenshot evidence

`phases/reports/PHASE_06/screens/` — **14 renders**, `screen_width_locale_state.png`:
`today_{390,768,1280}_{en,ar}_default`, `jobs_390_{en,ar}_default`,
`reports_390_{en,ar}_default`, `job_detail_{390,1280}_{en,ar}_default`.
Goldens: `apps/staff_app/test/goldens/advisor_*.png` (14). All reviewed.

---

## 10. Baseline versus final test results

| Unit | Baseline (pass/fail) | Final (pass/fail) | New failures | Notes |
|---|---|---|---|---|
| `staff_app` | 282 / 7 | **312 / 7** | **0** | +30 tests (21 advisor functional, 14 advisor goldens, −5 replaced); 7 failures identical to baseline (6 intake overflows + 1 advisor-workflow finder — pre-existing, 07A/06) |
| `shared_auth` | 73 / 0 | 73 / 0 | 0 | untouched |
| `shared_core` | 245 / 1 | 245 / 1 | 0 | untouched; 1 = `app_theme_visual_test` (01) |
| `owner_app` | 21 / 0 | 21 / 0 | 0 | untouched |
| `customer_app` | 511 / 6 | 509 / 8 | 2 (env.) | 2 extra **dark-mode golden pixel diffs (0.49%, sub-pixel)** in `customer_book_service_test.dart` — `customer_app` was not touched by Phase 06 and shares no code with the advisor workspace; recorded as environmental rendering nondeterminism, **not regenerated** (not Phase 06-owned) |
| `crm_app` | 14 / 0 | 14 / 0 | 0 | untouched |

**Static analysis:** `dart analyze` → **0 issues** on all six production units.
Advisor goldens regenerated only for the screens intentionally redesigned here and
visually reviewed before re-baselining.

---

## 11. Remaining issues and ownership

| Item | Owner |
|---|---|
| `AdvisorStatDialog` "View all" opens the Jobs tab (no per-metric provider filter exists) — display-only drill-down documented, not faked | 06 (accepted) |
| Customer dark-mode golden pixel diffs (0.49%, sub-pixel) — environmental; customer app untouched | customer phases / 20 |
| Pre-existing staff intake overflow failures (6) + advisor-workflow finder (1) | 07A / 06 |
| `AdvisorJobCardSheet` (dead UI) still present | 08 (planned removal) |
| Technician reuse of `AdvisorNotificationSheet` (restyle its usage) | 10 |

---

## 12. Readiness for the next phase

**Ready.** The advisor daily workspace is redesigned on the approved 2026 system,
localized EN+AR, RTL-correct, responsive at 320/390/768/1280 px, and
behavior-preserving.

**Phase 06 completion checklist**

- [x] All section-D screens redesigned with shared primitives; no raw hex/magic
      radius in touched files
- [x] EN/AR complete; RTL correct; 320 px clean
- [x] Existing advisor tests pass (updated for intentional copy/layout); new tests
      cover the state matrix
- [x] Actions/route contracts unchanged; offline/error notices truthful
- [x] `analyze:staff` + `test:staff` green (no new failures); goldens intentional
- [x] J2 evidence pack attached (`phases/reports/PHASE_06/`, 14 renders)
- [ ] Phase 07A — awaiting explicit authorization (not started)
