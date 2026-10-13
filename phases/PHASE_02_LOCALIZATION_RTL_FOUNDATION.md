# PHASE 02 — Localization & RTL Foundation

## A. Phase identity

- **Phase number:** 02
- **Title:** Localization & RTL Foundation (six l10n units, locale state, Arabic typography, RTL correctness, cross-boundary tests)
- **Objective:** Establish the complete English + Arabic infrastructure defined in `00_LOCALIZATION_RTL_STRATEGY.md` — distinct generated localization classes per package/app, one locale provider with persistence, the Arabic typeface, RTL-correct shared components, formatting utilities, and end-to-end tests that prove app + shared_core + shared_auth localized copy render together.
- **Priority:** Critical (blocks all feature phases)
- **Dependencies:** Phase 01 (locale-aware typography hook must exist)
- **Estimated scope:** Large

## B. Repository context

- **No localization exists today** (verified: no `.arb`, no generated classes, no
  `flutter_localizations`, no `Locale` handling; `shared_core/lib/src/errors/app_error_handler.dart` forces LTR for its own error surface — fix here).
- Shared user-visible copy lives in:
  - `packages/shared_core/lib/src/widgets/*` (32 files: empty/error, offline
    banner, dialogs, nav semantics, page headers)
  - `packages/shared_core/lib/src/constants/status_labels.dart` (English status
    strings used app-wide)
  - `packages/shared_auth/lib/src/presentation/**` (~60+ strings incl.
    `security_badge.dart` workshop wording that leaks into CRM)
- App strings: hard-coded across ~120 feature files; each feature phase
  localizes its own — **this phase handles shared copy + plumbing only**.
- Hive is initialized in every app (`HiveRegistry.initHive()`); reuse its
  settings box for locale persistence (no new storage dependency).
- Fonts: `shared_core/pubspec.yaml` registers Plus Jakarta Sans; assets under
  `packages/shared_core/assets/fonts/`.
- `main.dart` ×4 constructs `MaterialApp.router` (Phase 01 output) with
  `title: brand.appName`.
- Phase 00 deliverable to consume: `00_VISUAL_DIRECTION.md` + prototype
  `provisional_strings.dart` — the approved EN/AR copy for the six prototype
  screens is copied verbatim into the correct units here.
- Strategy authority: `00_LOCALIZATION_RTL_STRATEGY.md` (§2 architecture, §3
  typography, §4 formatting, §5 RTL, §6 mixed input, §8 tests).

## C. Design objectives

1. **Six units, six identity-importable classes** (§2.1–2.2 of the strategy):
   `SharedCoreLocalizations`, `SharedAuthLocalizations`, `StaffLocalizations`,
   `OwnerLocalizations`, `CustomerLocalizations`, `CrmLocalizations` — each in
   its own `l10n.yaml`/ARB pair with `synthetic-package: false`,
   `output-class` set, generated files committed.
2. **One locale contract:** `AppLocales.supported` + `localeProvider`
   (persisted in the Hive settings box, hydrated before first frame), registered
   with all delegates in all four apps (§2.3–2.4).
3. **Shared copy localized:** every string owned by `shared_core` widgets and
   `shared_auth` surfaces moves to its unit's ARB (EN+AR); `status_labels.dart`
   becomes locale-aware via `AppStatusLabels.of(context)`.
4. **Arabic typography live:** IBM Plex Sans Arabic bundled + applied through
   Phase 01's `AppTypography.forLocale`, with the specified fallback chain and
   Arabic metrics (no tracking, ×1.05 line height).
5. **Formatting utilities:** `AppFormatters` (dates, time, money AED, quantity,
   percent, compact count, relative time) — locale-aware, display-only.
6. **RTL-correct shared components:** direction-safe insets/alignment, icon
   flipping helper, mirrored navigation chrome; `app_error_handler.dart`
   LTR-forcing removed; documented exceptions (damage map later) reserved.
7. **Verification machinery:** per-unit ARB parity tests +
   `untranslated-messages-file` empty checks + cross-boundary widget tests (§8.3)
   + locale-switch live test.
8. **Language switcher available:** a shared `LanguageSwitcher` component
   (`shared_core`) + minimal reachable placement per app (staff `/settings`,
   owner profile sheet, customer profile, CRM settings tab) to prove the
   pipeline end-to-end now; final styling/placement refined in feature phases.

## D. Screens and workflows

No screen redesign. Infrastructure + shared-surface localization:

| Surface | What changes | Behavior preserved |
|---|---|---|
| All app shells (`DashboardShell`, nav, offline banner) | Copy + RTL | identical structure/behavior |
| Shared dialogs (`LogoutDialog`, `ExitConfirmationDialog`, `AppConfirmationDialog`) | Copy + RTL | same callbacks |
| `EmptyState`/`ErrorView`/`AppSkeleton` copy | from `shared_core` ARB | same states |
| `StatusPill` + status labels | localized `AppStatusLabels` | same statuses |
| Auth screens (`LoginView`, `ForgotPasswordView`, `AuthLoadingView`) | copy localized (layout redesign is Phase 05) | same flows |
| Language switcher entry points (minimal) | new row/sheet | additive |

Workflow: switch to Arabic → immediate RTL rebuild across shell + shared
widgets + auth → restart → persisted → switch back. Status labels render
Arabic everywhere they already render today.

## E. Responsive specifications

- `LanguageSwitcher` uses `AppBottomSheet` grammar (sheet on phones, inline row
  on ≥ tablet where placed).
- Arabic long-string check at 320 px across shared components; fix shared
  overflow here (feature screens fixed in their phases; note findings).
- All cross-boundary harnesses run at 320/390/768/1280 in both locales (§8.4).

## F. Localization and RTL

This phase **is** the localization work; implement `00_LOCALIZATION_RTL_STRATEGY.md`
§2–§6 exactly:

- ARB ownership table honored; nothing app-specific added to shared units.
- Distinct classes/imports; delegate registration from §2.3 in all four apps.
- Locale persistence via Hive settings box; hydrated pre-first-frame; single
  source of truth (no duplicate locale state anywhere).
- Shared component copy read internally via `SharedCoreLocalizations.of(context)`
  (data-in / copy-out rule); contextual strings stay parameters.
- Duplicate-key avoidance: namespaced keys; per-unit parity tests; status/empty/
  error copy referenced from `shared_core` only.
- Arabic font bundling + fallback chain + application via `forLocale`.
- Mixed input: `AppTextField` identifier variant (LTR content) — implemented in
  `shared_core` so all apps inherit it.
- RTL rules incl. icon flip helper and the vehicle-map exception documented for
  Phase 07B.
- No hard-coded user-visible English may remain in `shared_core`/`shared_auth`
  (excluding the audited identifier list); `app_error_handler.dart` loses its
  forced LTR.

## G. Design system integration

- New shared APIs: `AppLocales`, `localeProvider`, `LanguageSwitcher`,
  `AppFormatters`, `AppStatusLabels`, `DirectionalIcon` (or documented
  convention), identifier `AppTextField` variant, localized shared widgets.
- Fonts: add `packages/shared_core/assets/fonts/ibm_plex_sans_arabic/*` +
  pubspec registration; extend `AppFontFamilies` (`arabic`, `arabicFallback`).
- Zero visual redesign: copy/direction only; any visual delta is a bug.

## H. Technical implementation

Files to add/modify (expected):

- `packages/shared_core/pubspec.yaml` — `flutter_localizations` (SDK), font assets.
- `packages/shared_core/l10n.yaml` + `lib/l10n/app_en.arb` + `app_ar.arb` (+ gen output).
- `packages/shared_core/lib/src/localization/locale_provider.dart` (+ `HiveRegistry` settings-box hydration), `app_formatters.dart`, `language_switcher.dart`; export via `shared_core.dart` (additive).
- `packages/shared_core/lib/src/theme/app_text_styles.dart` — Arabic family + fallback wired to Phase 01 `forLocale`.
- `packages/shared_core/lib/src/constants/status_labels.dart` — locale-aware accessor (shared-internal call sites migrate now; app call sites migrate per feature phase — list them in the report).
- `packages/shared_core/lib/src/widgets/*` — string + direction fixes (incl. identifier variant).
- `packages/shared_core/lib/src/errors/app_error_handler.dart` — remove forced LTR.
- `packages/shared_auth/…` — pubspec, `l10n.yaml`, ARBs, wire all presentation strings.
- `apps/*/pubspec.yaml` + `l10n.yaml` + ARBs (minimal keys: `appTitle`, switcher + identity copy for auth).
- `apps/*/lib/main.dart` ×4 — delegates + `locale` + `onGenerateTitle`.
- Tests: per-unit parity tests, formatter tests, locale tests, cross-boundary harnesses, locale-switch test, 320 px/1.3× overflow harnesses.

Constraints:
- New packages: only `flutter_localizations` (SDK). `intl` already present.
- No route/provider/API changes; Hive additions are a settings box key only.
- Do not localize feature screens here beyond the minimal switcher entry.

## I. Functional preservation

- Login/logout/OTP/recovery behavior identical; only copy/direction change.
- Deep links, routes, provider names, sync behavior untouched.
- `status_labels.dart` API migration defined: shared-internal consumers updated
  in this phase; app-level consumers listed for their phases (report) and kept
  compiling via a temporary deprecated shim if needed (documented).
- Tests that asserted hard-coded shared English copy are updated as an
  intentional, documented contract change (never silently weakened).
- API payloads (dates, statuses, money) byte-identical — formatting is display-only.

## J. Testing requirements

- `melos run analyze`; all six suites.
- New: locale resolution + persistence; `AppFormatters` en/ar; typography
  mapping; per-unit ARB parity; untranslated-file empty check.
- Widget: shared chrome (shell/nav/banner/dialogs/empty/error/status) in `ar`
  with RTL assertions; Arabic 320 px overflow sweep of shared components.
- **Cross-boundary tests (mandatory, §8.3):**
  - staff harness: app copy + `OfflineBanner` + `LoginView` in `ar`;
  - owner harness: dashboard shell + shared dialog + login copy in `ar`;
  - customer harness: scaffold + notice + registration copy in `ar`;
  - CRM harness: shell + shared widgets + login copy in `ar` (SecurityBadge
    leak fixed);
  - locale-switch test flips provider live and asserts all three layers change.
- Goldens: replace missing/stale auth goldens intentionally; add one AR golden
  per app shell.

## J2. Visual quality gates (mandatory)

Static analysis and widget tests alone are **not** proof of design quality.
This phase is not complete until all of the following evidence exists:

1. **Rendered review** — run all four apps in AR and walk shell + auth +
   one feature screen per app; visually confirm mirroring and typography.
2. **Form factors** — AR renders at mobile (≤430 px), tablet (600–1023 px) and
   desktop (≥1280 px).
3. **Locales** — EN-LTR and AR-RTL renders of the reviewed surfaces; both
   reviewed for clipping (long Arabic), typography (font actually applied) and
   mirroring.
4. **State matrix** — loading/empty/error states of shared widgets captured in
   AR (skeleton/empty/error/offline).
5. **Interaction verification** — language switch applies live without restart;
   nav/rail/drawer mirror; dialogs behave; OTP boxes align in RTL.
6. **Accessibility** — AR at 1.3× scale clean on the reviewed surfaces;
   localized semantics labels present; contrast unchanged.
7. **No visual overflow** at 320 px in AR across the reviewed surfaces.
8. **Evidence attached** — screenshot pack `phases/reports/PHASE_02/` +
   updated AR/EN goldens.

## K. Acceptance criteria

1. Four apps switch EN↔AR live; choice persists across restart; first frame
   after restart is already in the persisted locale.
2. Six l10n units generate distinct classes with the specified imports; all
   delegates registered in all four apps; no class collisions.
3. Shared surfaces fully localized EN+AR; zero hard-coded user-visible English
   in `shared_core`/`shared_auth` beyond the audited identifier exceptions.
4. Arabic font applied with documented fallback; Arabic metrics correct.
5. RTL mirrors shared chrome; forced LTR removed; damage-map exception
   documented for Phase 07B.
6. Formatting localized; identifiers Latin; API payloads unchanged.
7. Parity + untranslated + cross-boundary + locale-switch tests pass.
8. `melos run analyze` + six suites green; visual gates J2 evidence attached.
9. Per-app list of feature-phase string migrations delivered.

## L. Deliverables

- Infrastructure summary: six units, key counts (EN/AR), class names/imports.
- Font assets + license note; fallback behavior.
- RTL audit results for shared widgets (fixed vs exceptions).
- Cross-boundary + locale-switch test evidence.
- `phases/reports/PHASE_02/` screenshot pack.
- Pending per-screen string/RTL migration list per app for feature phases.

## M. Completion gate

Stop after this phase. Do not begin Phase 03A until explicitly instructed.
