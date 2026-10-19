# REPORT PHASE 12 — Staff Common Profile, Attendance & Settings

**Document ID:** `phases/redesign_v2/reports/REPORT_PHASE_12.md`
**Execution Phase:** Concept A V2 — Phase 12 (Archetype 11: Structured Workspace Settings)
**Specification:** `phases/redesign_v2/implementation/PHASE_12_STAFF_COMMON_PROFILE.md`
**Status:** **ENGINEERING GATE PASSED** / **VISUAL GATE PENDING PRODUCT OWNER**
**Timestamp:** 2026-10-16
**Author:** Lead Flutter Architect & Systems Designer

> Mission summary: screen-level redesign (not a colour refresh) of the shared
> staff identity surfaces — profile dossier, attendance punch clock, shift
> details, settings/sync diagnostics — on the centralized theme + shared-widget
> architecture, in home-grammar siblinghood with the advisor hub. Every
> clock/sync/auth write goes through the frozen providers; anything without a
> contract (history dots, late verdicts, geo, swap CTA, last-sync persistence,
> device model, cache byte-size, theme/notif toggles) is omitted honestly
> rather than faked. Providers/API/models/persistence/routes are byte-identical.

---

## 0. Baseline the dirty tree (§0 directive — done FIRST, no code)

The working tree carried uncommitted changes of mixed origin when this phase
started. Every hunk was classified before any code was written; nothing was
built on a mystery diff.

| Path | Disposition | Evidence |
| :--- | :--- | :--- |
| `common/presentation/profile_screen.dart` (716 → 1023 lines in tree) | KEEP (Phase 12 carryover WIP) | Dossier-mini recomposition: 64 avatar + role badge + branch·shift + live attendance dot, `LanguageSwitcher`, change-password sheet over OTP flow, storage nav, unsynced-aware sign-out; full `staffProfile*` l10n |
| `common/presentation/staff_attendance_screen.dart` (558 → 1085 lines in tree) | KEEP + FIX (Phase 12 carryover WIP, one compile break) | Punch card (56px CTA, timestamp microcopy, 8h-basis meter), month calendar with today-only dot + day sheet, `staffAtt*` l10n; **broken**: `_SyncPill` used non-existent `SyncQueue.pendingCount` (test compilation failed) |
| `common/presentation/simple_pages.dart` (575 lines, clean vs HEAD) | REBUILD REQUIRED (untouched by WIP) | Hardcoded EN copy, raw `constraints.maxWidth >= 640`, direct `AppColors.warning`, bool-only sync status, no Force Sync / cache clear / breaks / supervisor / bay / empty state |
| `l10n/app_{en,ar}.arb` + `gen/*` | KEEP (Phase 12 carryover WIP) | `staffProfile*` + `staffAtt*` + `staffShift*` + `staffSettings*` keys with exact EN/AR parity (`arb_parity` green); this session changed one glyph only (straight → curly apostrophe in `staffAttDoneLine` to match the frozen test contract) |
| `advisor/presentation/pages/repair_order_view.dart` + `test/goldens/repair_*` + `reports/PHASE_09/screens/repair_*` + `README.md` Phase 09 row + untracked `advisor_phase09_studio_test.dart` + untracked `reports/REPORT_PHASE_09.md` | STRAY (Phase 09 session, out of scope) | Left untouched; excluded from Phase 12 proof; no revert without owner confirm |
| `test/failures/` or runner debris | NONE COMMITTED | No runner artifacts in the tree |

---

## 1. Owned inventory (from source, nothing omitted)

| Ref | Surface | File | Entry | States owned & covered |
| :-- | :--- | :--- | :--- | :--- |
| M1 | `StaffProfileScreen` | `common/presentation/profile_screen.dart` | `/profile` | identity dossier (avatar 64 + name + role badge + branch·shift + live dot + emp-id chip), prefs (language / change-password sheet / storage nav), work + contact groups (hide when empty), account (OTP reset + licences), danger zone (unsynced-aware sign-out confirm) |
| M2 | `StaffAttendanceScreen` | `common/presentation/staff_attendance_screen.dart` | `/attendance` | punch card (56px toggle CTA, status tone, timestamp microcopy, elapsed meter), today-record grid, month calendar (today ring + today-only dot + history note + day sheet), loading skeleton (AppSkeleton), error + retry, queued pill (no banner) |
| M3 | `ShiftDetailsPage` | `common/presentation/simple_pages.dart` | `/shift-details` | schedule card (eyebrow + shift + start/end + breaks) + assignment card (member/id/branch/supervisor/bay), empty state, wide two-pane vs compact stream |
| M4 | `SettingsPage` | `common/presentation/simple_pages.dart` | `/settings` | sync diagnostics (real pending count, session last-attempt, real Force Sync + toast), language, app version (when pushed), cache count (real Hive lengths) + guarded real clear + toast, pill-owned offline (no banner) |

Routes (`/profile`, `/attendance`, `/shift-details`, `/settings`), role
semantics, `StaffAttendanceNotifier` methods, `SyncEngine`/`SyncQueue`/`HiveCleaner`
contracts, Hive boxes and the OTP recovery flow are **unchanged**.

---

## 2. Before / after composition (per screen) — task → concept → composition

| Screen | Old got WRONG (one line) | New does DIFFERENTLY (one line) | Task → Concept → Composition | Viewport @390 EN |
| :-- | :--- | :--- | :--- | :--- |
| Profile (M1) | Generic account list with hardcoded EN copy and no attendance awareness. | Identity dossier owns the top (avatar + badge + context + live dot); prefs / facts / danger follow as grouped divider-rows. | prove who I am, then act → dossier-mini (job-detail grammar) → card + grouped rows, identity-left/prefs-right on wide | identity ≈55% |
| Attendance (M2) | Static punch buttons with hardcoded copy and no month context. | The punch verb owns the top (tone + timestamp + meter + 56px CTA); today-record grid then month calendar follow. | punch the clock, see today → verb-first workspace → punch card + record grid + calendar | punch card ≈50% |
| Shift (M3) | Two hardcoded cards with a raw 640 breakpoint and staff-only fields. | Schedule dossier + assignment dossier with breaks/supervisor/bay rows, empty state, all l10n, spec.pick wide. | know my shift → structured settings dossier → schedule card + assignment card | schedule ≈50% |
| Settings (M4) | Bool-only sync label with hardcoded copy and no actions. | Diagnostics card (count + session stamp + real Force Sync), language, version, cache count + guarded clear. | trust the device → diagnostics card → status + CTA + storage | sync card ≈50% |

No screen repeats the header + KPI + grid + list template. Profile is a
dossier stream; attendance is a verb-first clock; shift is a dual dossier;
settings is a diagnostics card — one language, four layouts.

Side-by-side vs HOME bar: same spacing rhythm (`AppDimensions`), same
divider-row grammar, same pill/toast/haptic patterns, same
`AppPageFrame`/`SectionHeader`/`StatusPill`/`AppSkeleton` family. Reviewer
reads a sibling, never a different app and never the old UI.

---

## 3. Include / remove / enhance (SaaS rework)

**Included (added, all real):** `staffShift*`/`staffSettings*` l10n with
parity; breaks / supervisor-on-duty / assigned-bay rows (render only when
pushed); shift empty state; pending **count** (`queue.length + failed.length`);
session last-attempt stamp (locale-aware); Force Sync Now (frozen
`syncEngine.syncAll` + success/fail toast, same pattern as the advisor hub);
cache item-count (real Hive lengths) + guarded `HiveCleaner.clearAll` +
confirm + toast; state-toned status pills; honest 3-line punch hint;
`staff_phase12_visual_test.dart` (16 goldens).

**Removed:** hardcoded EN copy in shift/settings; raw `>= 640` breakpoint;
direct `AppColors.warning`; bool-only sync label; `PrimaryButton(isLoading)`
busy treatment that hid its own label (replaced with the label-preserving
honest-busy pattern); dead `sync_providers`/`foundation` imports; unused
locals; `pendingCount` compile break.

**Enhanced:** punch CTA keeps its 56px height with a visible
"Punching in/out…" busy label + disabled control; punch pill resolves by
state tone (success/warning/neutral); back buttons use localized tooltips;
times/ids stay LTR-locked mono tabular; desktop is two-pane (never stretched
phone); AR mirrors with zero hardcode.

**Honest omissions (no fake actions — FAIL rule):** Emerald/Amber/Crimson
history dots + late/absent verdicts (no history endpoint, no scheduled-start
contract — only today's record marks, note explains); geo microcopy (provider
carries no geo); swap-request CTA (no swap endpoint — read-only everywhere);
persisted last-sync time (no contract — session stamp only); device model
(no contract — omitted); cache byte-size (no contract — item count only);
theme Light/Dark/System + notification prefs (no contracts — asserted absent
by tests); duplicate banners (pill owns offline, exactly once).

---

## 4. Reference conformance (house bar)

Sibling-checked against `advisor_home_view.dart` (greeting header, tiles,
divider-rows, skeleton-mirrors-geometry, toasts, haptics) and
`advisor_job_detail_view.dart` (dossier, breadcrumbs-equivalent header,
lifecycle tone, action dock):

- Spacing rhythm, card grammar, pill/toast/haptic shapes match; task-specific
  compositions differ (no clone).
- Skeleton mirrors geometry (`AppSkeleton.card/text/grid`) on the async
  surface; sync surfaces use honest busy states instead of fake skeletons.
- Motion restraint: no bespoke animations; shared widgets resolve
  `AppMotion` (reduced-motion safe).
- 48dp targets on every CTA/row; semantics headers + live regions; focus
  tooltips localized.

---

## 5. Contracts proof (UI-only, zero logic changes)

Frozen and byte-identical (no diff outside the listed presentation/test/l10n
scope): `StaffAttendanceNotifier.load/punchIn/punchOut`, `SyncEngine`,
`SyncQueue`, `HiveCleaner`, auth notifier, API endpoints/models/repos,
Hive boxes/queues, routes/params/extras/nav semantics, validation, deep
links, DTOs. Allowed diffs only: `common/presentation/*` composition,
`*.arb` strings, test harnesses/goldens.

Non-UI files touched (one-line justification each):

- `l10n/app_en.arb` — one glyph: curly apostrophe in `staffAttDoneLine` to
  match the frozen test contract (pre-existing WIP copy used straight).
- `l10n/gen/*` — regenerated by `flutter gen-l10n` for the above (no hand
  edits).
- `test/staff_common_test.dart` — harness only: l10n delegates +
  `supportedLocales` (WIP l10n broke the old harness; zero assertions
  changed).
- `test/technician_profile_test.dart`, `test/phase01_layout_smoke_test.dart`
  — harness only: same l10n-delegate fix (suites still carry pre-existing
  expectation drift, see §7).
- `test/staff_phase12_visual_test.dart` + `test/goldens/common_*` — new
  Phase 12 evidence (no production code).

---

## 6. Deltas made this session (on top of carryover WIP)

1. `_SyncPill`: `pendingCount` → `length` (compile fix; authoritative queue
   source, same as advisor pill).
2. `staff_common_test.dart` harness: l10n delegates + locales (18/18 green;
   was a compile failure at session start).
3. `simple_pages.dart` rebuilt (§§2–3; was untouched HEAD code).
4. Punch-in busy: label-preserving `ElevatedButton.icon` (test contract
   `find.text('Punching in…')` + disabled control; `PrimaryButton(isLoading)`
   hides its label).
5. Punch hint `maxLines: 2 → 3` (golden review showed mid-word cut at 390).
6. Punch pill → state tones (`success`/`warning`/`neutral`, never bare red).
7. Analyzer cleanups (unused imports/locals, null-promotion rewrite).
8. New visual suite + 16 goldens + report screens + README row.

---

## 7. Gates & evidence

**Gate 1 — Engineering:**

- `flutter analyze` (staff_app): **0 issues** (was 4 in carryover WIP).
- `staff_common_test.dart`: **18/18 green** (profile truthfulness, overflow,
  1.6x, all four punch states, skeleton, error+retry, saving-busy, shift
  accuracy/omission/responsive, settings truthfulness/no-fabrication).
- `arb_parity_test.dart`: **green** (exact EN/AR key parity + descriptions).
- `staff_phase12_visual_test.dart`: **16/16 green**, deterministic rerun
  (no `--update-goldens`) green.
- Manual guards (source scan): zero `AppColors.*`/`AppDarkColors`/
  `Brightness.*` and zero raw width comparisons in the three owned files.
- Frozen-contract suites: advisor/supervisor/technician provider suites
  untouched; no logic diffs to regress.

**Gate 2 — Visual (headless):**

- 16 goldens, real fonts (Plus Jakarta Sans + IBM Plex Sans Arabic +
  MaterialIcons), reviewed native in this session:
  `reports/PHASE_12/screens/common_{profile,attendance,shift,settings}_{390_en,390_ar,768_en,390_dark}.png`
  (test originals in `apps/staff_app/test/goldens/`).
- Matrix: 390 EN/AR light + 768 EN light + 390 EN dark spot per screen;
  punched-out seed (deterministic, no live-meter flake); RTL mirroring with
  LTR-locked plates/ids/times; tablet two-pane verified (identity
  left/prefs right; punch left/calendar right; schedule left/assignment
  right; sync left/app-cache right).
- **Live device: NOT PERFORMED** (no device in this session).

**Pre-existing failures (not caused by this session, owners noted):**

| Suite | Result | Cause | Owner |
| :--- | :--- | :--- | :--- |
| `technician_profile_test.dart` (~13) | red | Expectations written for the pre-redesign profile (forbids the honest "Preferences" header; expects single branch instance; expects untruncated emp-id/context; goldens `technician_profile_*` baseline the OLD composition) | Phase 10 / follow-up re-baseline to the Phase 12 dossier |
| `phase01_layout_smoke_test.dart` (2) | red (advisor cases only; profile cases pass) | Expects "Work Summary" copy the Phase 06 hub no longer renders | Phase 06 |
| Phase 09 stray diffs/goldens | untouched | Out-of-scope session work | Phase 09 |

---

## 8. Files changed (Phase 12 scope)

- Rebuilt: `common/presentation/simple_pages.dart`
- Fixed: `common/presentation/staff_attendance_screen.dart`
- Carried: `common/presentation/profile_screen.dart` (WIP, no session edits)
- L10n: `l10n/app_en.arb` (1 glyph), `l10n/gen/*` (regen)
- Tests: `test/staff_common_test.dart`, `test/technician_profile_test.dart`,
  `test/phase01_layout_smoke_test.dart` (harness only)
- New: `test/staff_phase12_visual_test.dart`,
  `test/goldens/common_*.png` (16), `reports/PHASE_12/screens/*` (16),
  `reports/REPORT_PHASE_12.md`, README ledger row.

No runner artifacts committed (`test/failures/` absent; goldens are the only
binaries, and they are the evidence).
