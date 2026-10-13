# PHASE 11 — Staff: Common Surfaces

## A. Phase identity

- **Phase number:** 11
- **Title:** Staff Common Surfaces (profile, attendance, shift details, settings, shared skeletons; language switcher)
- **Objective:** Redesign the surfaces every staff role shares — profile (also supervisor/technician tab), attendance punch, shift details, settings — and finalize the staff app's language switcher placement and skeleton system. This phase closes the staff branch.
- **Priority:** High
- **Dependencies:** Phases 01–10
- **Estimated scope:** Medium

## B. Repository context

Files (relative to `apps/staff_app/`):

- `lib/features/common/presentation/profile_screen.dart` (`StaffProfileScreen`):
  route `/profile` + embedded as supervisor tab 5 and technician tab 4;
  `AppPageHeader` + `AppPageFrame`, 2-col at ≥640 px; `_IdentityCard`,
  `_FieldGroupSection`, `_AccountPanel`; actions: reset password
  (→ `/forgot-password`), open licences (if wired), sign out via
  `showLogoutDialog` (warns on pending sync); hides empty fields; no skeleton
  (session data); takes optional `ProfileData` (built in router from auth
  profile + route extra).
- `.../presentation/staff_attendance_screen.dart`: route `/attendance`; punch
  in/out both confirmed; `StaffAttendanceSkeleton`, `ErrorView` + retry,
  `_StatusCard`, `_TimeSummaryWorkspace`, `_ActionSection`; saving progress;
  provider `providers/staff_attendance_provider.dart` (also invalidated on
  logout in `main.dart`).
- `.../presentation/simple_pages.dart`: `ShiftDetailsPage` (`/shift-details`,
  extra map shift/start/end/name/id/branch; graceful empty fields;
  `_ScheduleCard`, `_StaffContextCard`) and `SettingsPage` (`/settings`, extra
  map version; `SectionHeader`; truthful "no version" when absent).
- `.../presentation/staff_shimmer_skeletons.dart`: `ShimmerBox`,
  `SupervisorQueueSkeleton` (used in 09), `StaffAttendanceSkeleton` (used here),
  `AdvisorDashboardSkeleton` + `TechnicianHUDSkeleton` (unused after 06/10 —
  confirm and delete).
- Router: `lib/core/router/app_router.dart` — `/profile`, `/shift-details`,
  `/settings`, `/attendance` are common routes allowed for all staff roles;
  `ProfileData` model in `lib/core/models/profile_data.dart`.
- Language switcher: wired minimally in Phase 02 (staff `/settings`). This phase
  finalizes placement: Settings page row + Profile account panel entry; uses
  `shared_core` `LanguageSwitcher`.
- Tests: `test/staff_common_test.dart` (Profile, Attendance, Shift Details,
  Settings), `test/staff_experience_test.dart` (cross-role usability), goldens
  for staff profile advisor/supervisor (+ technician profile).

## C. Design objectives

1. **Profile = identity + account, calm and complete.** Identity card
   (avatar initials, name, designation, branch/shift chips) → contact/work
   fields grouped (only non-empty rendered) → account actions (reset password,
   language, licences if wired, sign out). Session-based: no network skeleton;
   show a lightweight placeholder only while auth profile is pending.
   Embedded tab mode (supervisor/technician) renders identically minus back
   navigation.
2. **Attendance = punch with proof.** Status card states clearly: not punched /
   punched in (elapsed timer) / on break / punched out today. Punch actions with
   confirmation, busy state inside button, success/failure panels; time summary
   (first in, last out, total hours) tabular; timeline list of events (compact
   rows). Pull-to-refresh.
3. **Shift details = schedule clarity.** Schedule card (shift name, start/end,
   date context) + staff context (name/id/branch) with graceful omission; no
   invented live data.
4. **Settings = preferences + truth.** Sections: Preferences (language +
   any existing toggles — none today, so language only), About (app version —
   only when provided), Sync status (local queue counts if the sync engine
   exposes them via existing providers; otherwise omit — do not invent).
5. **Language switcher finalized:** visible, labeled, immediate effect, persisted
   (Phase 02 infra), RTL-correct, footer note that it changes the entire app.
6. **Skeletons standardized:** `ShimmerBox`/custom skeletons replaced by
   `AppSkeleton` compositions; delete unused skeleton widgets; keep
   `SupervisorQueueSkeleton` only if Phase 09 did not migrate it (then migrate).
7. **Sign-out honesty kept:** pending-sync warning preserved; the dialog
   restyled to `AppConfirmationDialog` grammar.

## D. Screens and workflows

| Screen | New hierarchy | Key interactions | States |
|---|---|---|---|
| `StaffProfileScreen` | identity card → field groups → account panel | reset password, language switch, licences (if wired), sign out (confirm) | auth-pending placeholder; pending-sync warning |
| `StaffAttendanceScreen` | status card → punch actions → time summary → event timeline | punch in/out (confirm), refresh | skeleton, error+retry, saving, punched states |
| `ShiftDetailsPage` | schedule card → staff context | pull-to-refresh (if wired today), back | graceful empty fields |
| `SettingsPage` | preferences → about → sync | language switch, back | truthful version absence |
| Skeletons | AppSkeleton compositions | — | — |

## E. Responsive specifications

- **Compact:** single column; profile fields stack; attendance summary in 2×2
  metric tiles; settings rows full-width.
- **Medium:** profile keeps its 2-column ≥640 px behavior (identity left,
  fields right); attendance summary 4-up.
- **Expanded/large:** content capped; profile max width ~720 px; attendance
  timeline alongside summary (two columns).
- 320 px and 1.3×: identity card wraps; chips wrap; no clipping.

## F. Localization and RTL

- All strings localized (staff ARB): profile labels/actions, attendance states
  and confirmations, shift labels, settings sections, language selector copy.
- RTL: profile rows align end, chips order mirrors, attendance timeline mirrors,
  dialogs mirror; time/duration formatting localized (`AppFormatters`).
- Tests: `staff_common_test.dart` in EN+AR; RTL assertions; 320 px clean.

## G. Design system integration

- Use: `AppPageFrame`, `AppPageHeader`/workspace header, `AppCard`,
  `AppRecordRow`, `AppKpiCard` (attendance summary), `StatusPill` (punch state),
  `AppInfoPanel` (sync/pending notices), `AppButton`, `AppConfirmationDialog`,
  `showAppModalSheet` (language sheet if sheet variant), `LanguageSwitcher`
  (Phase 02), `SectionHeader`, `AppSkeleton`, `EmptyState`, `ErrorView`.
- Delete: unused skeleton widgets after reference check; `ShimmerBox` if fully
  replaced.

## H. Technical implementation

- Modify: profile/attendance/simple_pages/skeletons files; ARB; tests+goldens;
  `app_router.dart` **only** if profile/attendance constructor signatures need
  UI-only additions (prefer none).
- Preserve: `ProfileData` model + router-built data; `staffAttendanceProvider`
  APIs (punch methods, invalidation on logout in `main.dart`); attendance
  confirmation rules; settings extra map handling.
- Language switch uses Phase 02 `localeProvider` — no duplicate state.
- No new packages; no API changes.

## I. Functional preservation

- Punch flows, confirmations, and provider calls unchanged.
- Profile sign-out with pending-sync warning unchanged.
- Embedded profile tab behavior (supervisor/technician) unchanged.
- All staff common/experience tests pass (copy/layout updates only); goldens
  intentional.

## J. Testing requirements

- `melos run analyze:staff`; `melos run test:staff`.
- Update `staff_common_test.dart` + `staff_experience_test.dart`: EN+AR, RTL,
  320/390/768/1280, 1.3×; attendance status states; profile fields hiding;
  language switch changes locale and persists (provider test); sign-out warning
  path.
- Regenerate staff profile goldens (advisor/supervisor/technician); add AR
  goldens for profile + attendance.

## J2. Visual quality gates (mandatory)

Static analysis and widget tests alone are **not** proof of design quality. This
phase is not complete until all of the following evidence exists:

1. **Rendered review** — run the staff app and visually review Profile (standalone
   + embedded tab modes), Attendance, Shift Details and Settings; no screen may
   be signed off from code-reading alone.
2. **Form factors** — renders captured at mobile (≤430 px), tablet (600–1023 px)
   and desktop (≥1280 px); the profile 2-column transform reviewed at ≥640 px.
3. **Locales** — EN-LTR and AR-RTL renders incl. the language switcher row;
   profile rows and attendance timeline mirroring reviewed.
4. **State matrix** — attendance punch states (before/in/break/out), saving,
   error+retry, profile with missing fields hidden, pending-sync sign-out
   warning, skeleton states. Realistic staff fixtures.
5. **Interaction verification** — punch confirmations, reset-password
   navigation, language switch applies live, embedded-tab profile behaves,
   sign-out confirm.
6. **Accessibility** — 1.0–1.3× scale clean, tabular attendance summary,
   semantics on rows, contrast sampled.
7. **No visual overflow** at 320 px in either locale.
8. **Evidence attached** — goldens or a screenshot pack at
   `phases/reports/PHASE_11/` named `screen_width_locale_state.png`. Section K
   is unmet without this evidence.

## K. Acceptance criteria

1. Section D surfaces redesigned; skeleton system standardized; dead skeletons
   removed with proof.
2. Punch/profile/settings behaviors unchanged (tests).
3. Language switcher final in Settings + Profile; persisted; RTL-correct.
4. EN/AR complete; responsive per E; `melos run analyze:staff` + `test:staff`
   green.

## L. Deliverables

- File changes + deletions; ARB counts; golden diffs; test evidence; known
  limitations (e.g. licences action if unwired, sync-status section if omitted).

## M. Completion gate

Stop after this phase — this closes the Staff branch. Do not begin Phase 12
until explicitly instructed.
