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
| `customer_app` | 511 / 6 | 509 / 8 | 2 (pre-existing, date-dependent) | The "2 additional" are **one golden** — `customer_book_service_dark_mobile.png` — failing in the file's **two duplicate** `Booking flow visual references` groups. Root cause: the flow renders **"tomorrow"** from `DateTime.now()`; the golden embeds `Wed, 14 Oct 2026` (captured 2026-10-13) and today renders `Thu, 15 Oct 2026`. Diff = 0.49 % / 1621 px, **isolated to the date string**. Same class as the pre-existing schedule/review/tablet failures. **Not Phase 06-caused** (customer_app and shared_core/shared_auth untouched; fonts/viewport/DPR/theme unchanged). See §13. |
| `crm_app` | 14 / 0 | 14 / 0 | 0 | untouched |

**Static analysis:** `dart analyze` → **0 issues** on all six production units.
Advisor goldens regenerated only for the screens intentionally redesigned here and
visually reviewed before re-baselining.

---

## 11. Remaining issues and ownership

| Item | Owner |
|---|---|
| `AdvisorStatDialog` "View all" opens the Jobs tab (no per-metric provider filter exists) — display-only drill-down documented, not faked | 06 (accepted) |
| `customer_book_service_test.dart` booking-flow goldens are **date-relative** (`_pickFirstDate` selects "tomorrow" from the real clock) → they fail as the wall clock advances. 4 unique goldens (schedule/review/tablet/dark) ×2 duplicate groups = 8 failures. Fix by injecting a fixed clock / deterministic date into the flow, or capturing a date-independent golden | customer booking phase (16) / 20 |
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

---

## 13. Final regression verification — customer_app golden failures

Investigated after the Phase 06 implementation, per the final verification brief.

### 13.1 Exact failing cases

`apps/customer_app/test/customer_book_service_test.dart` defines the group
`Booking flow visual references` **twice** (lines 494 and 697), so every test in
it runs twice. The reported "two additional failures" are therefore **one golden**
compared in two groups:

| Golden | Group occurrence | Phase 05 baseline | Phase 06 final |
|---|---|---|---|
| `customer_book_service_schedule_mobile.png` | ×2 | FAIL | FAIL |
| `customer_book_service_review_mobile.png` | ×2 | FAIL | FAIL |
| `customer_book_service_tablet.png` | ×2 | FAIL | FAIL |
| **`customer_book_service_dark_mobile.png`** | ×2 | **PASS** | **FAIL** |

Baseline (Phase 05 final): 6 failures (3 goldens ×2). Final: 8 failures
(4 goldens ×2). The delta is exactly `customer_book_service_dark_mobile.png`.

### 13.2 Root cause (reproducible evidence)

The booking flow renders the appointment date as **"tomorrow" relative to the real
clock** — `_pickFirstDate` taps the second date entry (comment: *"Tomorrow, not
today"*; `customer_book_service_test.dart:1014`), and the app formats it via
`DateTime.now()`.

- The golden `customer_book_service_dark_mobile.png` embeds **`Wed, 14 Oct 2026`**
  (its `LastWriteTime` is 2026-10-13 17:25, i.e. captured when "tomorrow" = 14 Oct).
- The current render (run on **2026-10-14**) shows **`Thu, 15 Oct 2026`**.
- The `isolatedDiff` is **only the date string**; every other pixel is identical.
- Pixel diff: **0.49 % / 1621 px**, reproduced identically across two clean
  isolated runs (`--plain-name "dark mode mobile"`): `+0 -2`, same 0.49 % both times.
- The same date-only diff pattern appears in the pre-existing schedule / review /
  tablet failures (their `isolatedDiff`s show the date row and the
  `Wed 14 Oct → Thu 15 Oct` text only).

This is a **deterministic, date-relative golden** (test-design), **not**
nondeterministic rendering: it fails for every wall-clock day after the golden's
capture date.

### 13.3 Environment comparison (ruled out)

| Factor | Value | Changed by Phase 06? |
|---|---|---|
| Viewport | `Size(390, 844)`, `devicePixelRatio = 1` | No |
| Golden dimensions | 390×844 | No |
| Theme | `AppTheme.dark(BrandConfig.orient)` | No |
| Fonts | `setUpAll(_loadFonts)` loads Plus Jakarta from `shared_core` assets | No (assets unchanged) |
| Dependencies | `customer_app/pubspec.lock` untouched | No |
| Flutter/Dart | 3.35.7 / 3.9.2 (unchanged) | No |

Phase 06 changed only `apps/staff_app/**` (advisor presentation + staff ARB/tests);
`customer_app` does not import `staff_app`, and neither `shared_core` nor
`shared_auth` was modified in Phase 06. Fonts render identically (the diff is a
single date substring), so this is **not** a shared-component, font, or
environment regression.

### 13.4 Disposition

- **Not a Phase 06 regression** — no Phase 06 code change required or made.
- **Golden not regenerated** (per the "do not regenerate to make tests pass" rule);
  the correct fix is a deterministic clock in the test flow, owned by the customer
  booking phase (16) / Phase 20.
- Reproducible evidence captured at
  `phases/reports/PHASE_06/customer_darkmode_isolated.txt` and the failure
  diff images under `apps/customer_app/test/failures/`.

### 13.5 Final status after verification

| Unit | Result |
|---|---|
| `staff_app` | **312 / 7** (7 = identical pre-existing set) |
| `shared_auth` | 73 / 0 |
| `shared_core` | 245 / 1 (1 = `app_theme_visual_test`, 01) |
| `owner_app` | 21 / 0 |
| `crm_app` | 14 / 0 |
| `customer_app` | 509 / 8 — 8 = 4 **date-relative** booking-flow goldens ×2 duplicate groups (3 pre-existing + `dark_mobile`); not Phase 06-caused |
| `dart analyze` | 0 issues on all six units |
| Phase 00 prototype | 0 changes |

**Phase 06 acceptance criteria are satisfied** (all section-D screens redesigned on
the shared system, EN/AR + RTL + 320 px clean, actions/routes unchanged, analyze +
`test:staff` green with no new failures, J2 evidence attached). The residual
`customer_app` failures are pre-existing date-relative goldens outside Phase 06
scope and are **recorded, not suppressed or regenerated**. Phase 06 is marked
**complete**.
