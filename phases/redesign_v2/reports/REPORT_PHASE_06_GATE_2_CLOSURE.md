# Phase 06 — Gate 2 Closure (Live/State/Sync Reactivity)

**Document ID:** `phases/redesign_v2/reports/REPORT_PHASE_06_GATE_2_CLOSURE.md`
**Type:** Closure & validation pass (not a redesign). Preserves Concept A and the existing Phase 06 implementation.
**Basis:** `REPORT_PHASE_06.md`, `REPORT_PHASE_06_GATE_2_AUDIT.md`, `implementation/PHASE_06_STAFF_ADVISOR_HUB.md`, `00_VISUAL_ACCEPTANCE_RULES.md`, `00_RESPONSIVE_RTL_SPEC.md`, `00_COVERAGE_MATRIX.md`
**Timestamp:** 2026-10-14

---

## 1. Baseline & scope

`git status --short` was recorded at the start of the pass (84 entries — the Phase 06 working tree plus unrelated lockfile/Phase 05 changes; all preserved). During the pass the working tree's `HEAD` advanced to commit `ed2dc678` (a checkpoint commit that captured most of the in-progress closure work); the remaining uncommitted deltas at the end of this pass are only the three files in §2 plus the new report/evidence. No commit, revert, or history operation was performed by this pass.

**Files touched by this closure pass:**

| File | Change | Rationale |
| :-- | :-- | :-- |
| `apps/staff_app/lib/features/advisor/presentation/providers/advisor_providers.dart` | `advisorPendingSyncCountProvider` → `StreamProvider<int>` + new `advisorPendingSyncCountStream(box)` | Task 2 — reactive pending-sync count |
| `apps/staff_app/lib/features/advisor/presentation/pages/advisor_home_view.dart` | read `...value ?? 0`; `.value` → `.valueOrNull` (3 reads) | Task 2 wiring + Task 3 error-state defect fix |
| `apps/staff_app/lib/features/advisor/presentation/pages/advisor_jobs_view.dart` | `.value` → `.valueOrNull` (2 reads) | Task 3 error-state defect fix |
| `apps/staff_app/test/advisor_sync_reactivity_test.dart` | New — 3 tests | Task 2 test evidence |
| `apps/staff_app/test/advisor_phase06_states_test.dart` | New — 15 golden states | Task 3 visual evidence |
| `apps/staff_app/test/goldens/advisor_states_*.png` | 15 new Phase 06 goldens | Task 3 visual evidence |
| `phases/redesign_v2/00_COVERAGE_MATRIX.md` | appended closure-status note | Task 7 |

No other production file, test, localization file, shared package, or golden was modified. The Phase 06 report and Gate 2 audit report were **not** overwritten.

---

## 2. Task 2 — Pending-sync reactivity: root cause & fix

**Root cause.** `SyncQueue` wraps a Hive `Box<SyncOperation>` but exposes no change stream, and `syncQueueProvider` is a plain `Provider<SyncQueue>`. The old `advisorPendingSyncCountProvider` read `queue.length` once at build; Hive mutates the box on enqueue/remove/clear without notifying Riverpod, so the `OfflineStatusPill` queued count never updated until an unrelated rebuild.

**Fix (smallest architecture-consistent).** Hive boxes already expose a supported change stream (`Box.watch()`), which is the existing source of truth (`syncQueueProvider` wraps the same box). The provider is now a `StreamProvider<int>` fed by a named helper:

```dart
Stream<int> advisorPendingSyncCountStream(Box<SyncOperation> box) {
  late StreamController<int> controller;
  StreamSubscription<BoxEvent>? subscription;
  controller = StreamController<int>(
    onListen: () {
      controller.add(box.length);                       // seed current value
      subscription = box.watch().listen((_) => controller.add(box.length));
    },
    onCancel: () async { await subscription?.cancel(); subscription = null; },
  );
  return controller.stream.distinct();                  // no redundant rebuilds
}
```

- Reuses the existing Hive change stream; no polling; no second source of truth; queue semantics/error handling unchanged.
- `distinct()` avoids rebuilds when the count is unchanged (e.g. retry-count writes).
- `onCancel` releases the box subscription → no leak when the provider is disposed.
- Falls back to `Stream.value(0)` when the box is unavailable (headless widget tests).
- The home now reads `.value ?? 0`.

> Note: an initial `async*`/`await for` implementation hung the test isolate against Hive's stream in this environment; the explicit `StreamController` mirrors the proven direct-`listen` pattern and is unit-tested.

**Tests (`advisor_sync_reactivity_test.dart`, 3/0):** initial seed → enqueue → remove → clear emission order `[0,1,2,1,0]`; provider reflects the queue reactively; subscription cancels cleanly.

---

## 3. Task 3 — Missing visual states (new evidence)

New `advisor_phase06_states_test.dart` (15/0) captures the states the Gate 2 audit flagged as missing, using deterministic fixtures and real fonts. Every render was inspected at native resolution.

| Screenshot (golden) | Viewport | Theme | Locale | State | Evidence path |
| :-- | :-- | :-- | :-- | :-- | :-- |
| `advisor_states_dark_home_390_en` | 390×844 | dark | EN | home loaded | `test/goldens/` + `reports/PHASE_06/screens/` |
| `advisor_states_dark_home_390_ar` | 390×844 | dark | AR | home loaded (RTL) | same |
| `advisor_states_dark_detail_1280_en` | 1280×800 | dark | EN | job detail | same |
| `advisor_states_offline_390_en` | 390×844 | light | EN | offline pill | same |
| `advisor_states_queued_390_en` | 390×844 | light | EN | pending-sync "3 queued" pill | same |
| `advisor_states_loading_390_en` | 390×844 | light | EN | loading skeleton | same |
| `advisor_states_error_390_en` | 390×844 | light | EN | error + retry | same |
| `advisor_states_jobs_empty_390_en` | 390×844 | light | EN | empty | same |
| `advisor_states_jobs_nomatch_390_en` | 390×844 | light | EN | no-match | same |
| `advisor_states_jobs_matrix_1280_en` | 1280×800 | light | EN | desktop master-detail | same |
| `advisor_states_search_390_en` | 390×844 | light | EN | search + results | same |
| `advisor_states_sheet_notification_390_en` | 390×844 | light | EN | notification sheet | same |
| `advisor_states_sheet_profile_390_en` | 390×844 | light | EN | profile sheet | same |
| `advisor_states_sheet_contact_390_en` | 390×844 | light | EN | contact sheet | same |
| `advisor_states_sheet_approval_390_en` | 390×844 | light | EN | approval sheet | same |

**Inspection observations:** dark theme renders Concept A obsidian/slate correctly with cobalt primary and semantic accents; the offline pill shows amber "Offline" and the queued pill shows "3 queued" with no duplicate `OfflineBanner`; loading shows skeleton rows; the error panel renders crimson with a working retry; empty/no-match states are correct; the desktop jobs matrix shows the `AppTable` master plus the preview placeholder; the search sheet shows grouped results; all four sheets render correctly (approval shows money hero + emerald Approve / crimson Send Back).

**Latent defect surfaced & fixed (Task 3 side-effect).** Capturing the error state exposed that `_AdvisorDashboardContent.build` dereferenced `AsyncValue.value`, which **throws** when a provider is in `AsyncError`. Because `advisorAssignedBookingsProvider` returns a raw future (no internal catch), a booking-load failure would crash the home instead of showing the declared error panel. Fixed by reading `.valueOrNull` (home; jobs likewise). Success-state renders are unchanged (verified: the pre-existing 14 goldens still pass).

**Low visual nit observed:** in the 1280 desktop jobs matrix the five columns truncate aggressively within the 520 px master pane ("Toyota Land Crui…", "JC-2026-1…"). Functional; flagged as Low.

---

## 4. Task 4 — Live acceptance

**Tooling discovered:** `flutter devices` reports **Windows (desktop)**, **Chrome**, **Edge**, and 2 Android emulators (`Pixel_9_Pro`, `flutter_emulator`); `flutter doctor` shows Flutter 3.35.7 with Chrome/Windows/Android SDK present. So live tooling **is** available.

**Why live interaction was not performed:**
1. `apps/staff_app/lib/core/router/app_router.dart` (redirect, §:105) forces unauthenticated users to `/login`; reaching `/advisor_home_view` requires a successful authenticated staff login against the backend. No dev auth bypass exists.
2. The environment is non-interactive (no GUI driver), so physical keyboard, focus traversal, window resizing, and real connectivity toggling cannot be exercised.
3. A `flutter run -d chrome` launch attempt was started and then **aborted at the operator's direction** ("dont run the app"); the process tree was stopped. (The first attempt also failed with `Target file lib\main.dart not found` because the working directory was not set; the corrected attempt was aborted before producing output.)

**Result: live acceptance is `NOT PERFORMED`.** No live check is claimed as passed. Specifically **NOT VERIFIED**: physical ⌘K/Ctrl+K, focus order/dismissal/restoration, real offline toggle + pending-sync updates on device, live resize across breakpoints, navigation transitions, real API loading/retry/error, live EN/AR and light/dark on device.

---

## 5. Task 5 — Baseline reconciliation delta

**Claim under test:** `REPORT_PHASE_04_1` §9 records `staff_app` baseline **267 passed / 76 failed** (= 343). The Gate 2 audit reconstructed a pre-Phase-06 total of **342** (353 observed − 11 Phase 06 tests), a **1-test delta**.

**Findings:**
- **Current, authoritative counts (this pass):** full `staff_app` = **309 passed / 62 failed** (= 371). Removing this pass's 18 new tests (`advisor_sync_reactivity` 3 + `advisor_phase06_states` 15) → 353; removing the earlier Phase 06 tests (`advisor_theme_architecture` 1 + `advisor_phase06_shell` 10) → **342**.
- **Only historical test deletion found:** `git log --diff-filter=D` shows commit `fcec6fb7` (2026-08-05) deleted `apps/staff_app/test/widget_test.dart` — the stock Flutter "Counter increments smoke test" (exactly 1 test).
- **But that deletion predates the baseline report** (2026-10-14), so the stock test was already gone when the 267/76 baseline was recorded. It therefore **does not** explain the delta.

**Conclusion:** the **1-test delta remains unresolved** from available artifacts. Historical values are preserved verbatim (`267/76`). Most likely cause is minor inventory/counting drift in the historical hand-recorded figure (a test added/removed or a parameterized count difference not captured per-file at baseline time). This has **no effect** on failure attribution: all 62 failures are other-phase stale goldens in files untouched by Phase 06.

---

## 6. Task 6 — Regression results

| Suite | Result | Notes |
| :-- | :-- | :-- |
| `flutter analyze lib test` (staff_app) | **0 issues** | clean |
| `advisor_sync_reactivity_test.dart` | **3 / 0** | new |
| `advisor_phase06_states_test.dart` | **15 / 0** | new |
| `advisor_phase06_shell_test.dart` | **10 / 0** | unchanged |
| `advisor_experience_test.dart` | **21 / 0** | unchanged |
| `advisor_phase06_visual_test.dart` | **14 / 0** | unchanged (no visual regression from the fix) |
| `advisor_theme_architecture_test.dart` | **1 / 0** | guard passes |
| `arb_parity_test.dart` | **1 / 0** | localization parity clean |
| `localization_cross_boundary_test.dart` | **2 / 0** | EN/AR render |
| `apps/staff_app` (full) | **309 passed / 62 failed** | see below |
| `packages/shared_core` | **324 / 0** | unchanged (not modified) |

**Remaining failures — all 62 are other-phase stale goldens (no Phase 06 failures, no non-golden failures):**

| Test file | Count | Owning phase |
| :-- | ---: | :-- |
| `advisor_phase07a_visual_test.dart` | 13 | 07 |
| `supervisor_login_phase05_test.dart` | 2 | 05/11 |
| `technician_job_detail_test.dart` | 9 | 10 |
| `technician_jobs_test.dart` | 8 | 10 |
| `technician_productivity_test.dart` | 6 | 10 |
| `technician_profile_test.dart` | 9 | 10 |
| `technician_support_flows_test.dart` | 8 | 10 |
| `technician_today_test.dart` | 7 | 10 |

No Phase 06 test fails. The suite is **not** green and is reported as **309 / 62**.

---

## 7. Updated risk register

| ID | Finding | Affected | Evidence | Rank | Smallest next action |
| :-- | :-- | :-- | :-- | :-- | :-- |
| R-1 | Live device/browser acceptance not performed (auth-gated + non-interactive; aborted per operator) | All Phase 06 screens | §4; `app_router.dart:105` | **Blocker (to full Gate 2 closure)** | Operator/CI runs a live pass on Windows/Chrome/emulator with credentials |
| R-2 | Home crashed on provider `AsyncError` (`.value` threw) | Advisor home | §3; fixed with `.valueOrNull` | **Resolved** (was High) | — (regression-proofed by `advisor_states_error_390_en`) |
| R-3 | Pending-sync count not reactive | Shell offline pill | §2; fixed + tested | **Resolved** (was Medium) | — |
| R-4 | Missing state/theme evidence | Home/Jobs/Reports/Job detail | §3; 15 new goldens | **Resolved** (was Medium) | — (dark reports/details beyond captured set optional) |
| R-5 | Desktop jobs matrix truncates columns | Jobs (wide) | `advisor_states_jobs_matrix_1280_en` | **Low** | Widen master pane / adjust column flex in a future pass |
| R-6 | Baseline 1-test reconciliation unresolved | Test ledger | §5 | **Low** | None required; documented |
| R-7 | Untracked root `l10n_untranslated.json` artifact | Repo hygiene | `git status` | **Low** | Tidy in maintenance |

---

## 8. Gate 2 recommendation

### `CONDITIONAL — ACTIONS REQUIRED`

- **Closed this pass:** pending-sync reactivity (Task 2, root-caused + tested); missing-state visual evidence (Task 3, 15 goldens inspected); the home/jobs `AsyncError` crash (defect fix); theme/localization guards; all Phase 06 tests green; no new failures.
- **Still open:** **live device/browser acceptance** (Task 4) is `NOT PERFORMED` — it is blocked by the authentication gate and a non-interactive environment, and was explicitly not run at the operator's direction. `00_VISUAL_ACCEPTANCE_RULES.md` requires live/human verification for Gate 2.

Because the sole remaining gap is a live validation pass, this is **not** `NOT READY` (no code/design blocker remains) and **not** `RECOMMEND APPROVAL` (live acceptance is unverified). Product Owner approval is **not** claimed.

**To close Gate 2:** run one live pass (Windows/Chrome/emulator) covering Ctrl+K/Meta+K, focus, offline/queued, resize, navigation/master-detail, and EN/AR + light/dark, then record the results here.

---

## 9. Integrity & hard stop

- No production source, unrelated test, localisation, lockfile, or other-phase golden was modified; the Phase 06 implementation and Concept A are preserved.
- `REPORT_PHASE_06.md` and `REPORT_PHASE_06_GATE_2_AUDIT.md` were not overwritten.
- The `test/failures/` scratch directory produced by the full run was removed.
- This is a closure/validation pass — no redesign. Phase 07A/07B were not started. The coverage matrix was updated with evidence-backed status only; Product Owner approval state is untouched.
