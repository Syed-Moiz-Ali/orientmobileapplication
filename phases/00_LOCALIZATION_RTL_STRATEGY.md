# 00 — Localization & RTL Strategy (English + Arabic)

Current state (verified): **there is no localization infrastructure anywhere** —
no `flutter_localizations`, no `.arb` files, no `AppLocalizations`, no locale
provider, no RTL handling. Every string is hard-coded English and every layout is
LTR. This document defines the architecture Phase 02 establishes, the ownership
rules every later phase follows, and the verification that proves it works.

---

## 1. Target behavior

1. The app runs in **English (LTR)** or **Arabic (RTL)**.
2. Language follows, in priority order: persisted user selection → system
   locale → English fallback.
3. Users switch language in-app (Profile/Settings in every app); switching
   applies immediately (no restart), persists, and survives process death.
4. Arabic is a complete translation, not partial: every screen, validation,
   empty/error state, tooltip and semantics label.
5. A screen that only renders correctly in English is **not complete**
   (binding in every phase's DoD).

---

## 2. Architecture

### 2.1 Localization units and ARB ownership

Six independent l10n units, one per package/app. Own your strings; consume the
rest:

| Unit | Owns (ARB keys) | Never owns |
|---|---|---|
| `packages/shared_core` | Shared widget copy: empty/error/retry, offline banner, exit/logout dialogs, sheet titles/actions of shared components, nav semantics labels, status labels (`status_labels.dart` copy), form primitives hints, chart tooltip defaults, pending-sync chip copy | Feature/app-specific copy; auth copy |
| `packages/shared_auth` | All login/recovery/registration/OTP copy, security badge, auth notices | App identity copy (passed in as localized values from each app's ARB) |
| `apps/staff_app` | Advisor/supervisor/technician/common feature copy (incl. the localized `ProfileData` labels, tab labels, workflow copy) | Shared widget copy (consume `shared_core`) |
| `apps/owner_app` | Dashboard/operations/finance copy | Shared widget copy |
| `apps/customer_app` | Home/bookings/vehicles/profile/booking/status/roadside/feedback copy | Shared widget copy |
| `apps/crm_app` | CRM feature copy | Shared widget copy |

Rules:
- If a string renders inside a widget that lives in `shared_core`, the key
  belongs to `shared_core` — even if only one app shows it today.
- App identity strings (app name, purpose, intended users) belong to each
  **app's** ARB and are passed into `shared_auth` views as localized values.
- Feature phases may only add keys to their app's unit (or `shared_core` via
  README §8 when a shared widget needs new copy).

### 2.2 Generated class naming and imports

Default `gen-l10n` names every class `AppLocalizations`, which collides across
packages. Each unit therefore generates a **distinct class in a distinct
directory** (`synthetic-package: false`):

| Unit | `output-class` | Generated file / import |
|---|---|---|
| shared_core | `SharedCoreLocalizations` | `package:shared_core/l10n/shared_core_localizations.dart` |
| shared_auth | `SharedAuthLocalizations` | `package:shared_auth/l10n/shared_auth_localizations.dart` |
| staff_app | `StaffLocalizations` | `package:staff_app/l10n/staff_localizations.dart` |
| owner_app | `OwnerLocalizations` | `package:owner_app/l10n/owner_localizations.dart` |
| customer_app | `CustomerLocalizations` | `package:customer_app/l10n/customer_localizations.dart` |
| crm_app | `CrmLocalizations` | `package:crm_app/l10n/crm_localizations.dart` |

Each unit's `l10n.yaml` (example, shared_core):

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: shared_core_localizations.dart
output-class: SharedCoreLocalizations
synthetic-package: false
output-dir: lib/l10n/gen
untranslated-messages-file: l10n_untranslated.json
```

Generated files are committed (repo convention: no codegen at analyze time),
and `flutter gen-l10n` is run as part of the phase that edits ARBs.

### 2.3 Delegate registration (all four applications)

Every `MaterialApp.router` registers **all** delegates (a shared helper in
`shared_core` keeps them consistent):

```dart
localizationsDelegates: const [
  StaffLocalizations.delegate,          // app unit
  SharedCoreLocalizations.delegate,     // shared widgets
  SharedAuthLocalizations.delegate,     // auth screens
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
supportedLocales: AppLocales.supported, // const [Locale('en'), Locale('ar')] from shared_core
locale: ref.watch(localeProvider),      // null = follow system
onGenerateTitle: (context) => StaffLocalizations.of(context).appTitle,
```

`AppLocales.supported` is defined once in `shared_core` so no app can drift.
Lookup convention: `SharedCoreLocalizations.of(context)`, etc. — never a bare
`AppLocalizations.of(context)`.

### 2.4 Locale state, persistence, synchronization

- `shared_core` owns `localeProvider` (`StateNotifier<Locale?>`), persisted in
  the existing Hive settings box (`HiveRegistry` gains the settings box to its
  initialization; **no new storage package**).
- Hydration happens in `HiveRegistry.initHive()`/bootstrap before `runApp` so
  the first frame already renders in the persisted locale (no EN flash for AR
  users).
- All writes go through the provider (Profile/Settings switchers in every app);
  the provider updates Hive + `state`; `MaterialApp.router` rebuilds.
- "Synchronization" scope: single process, single isolate — the provider is the
  single source of truth; tests override it via `ProviderScope(overrides:)`.
  No cross-app sync exists (separate installs), so none is invented.
- Locale choice is independent of auth state (available pre-login: auth screens
  localize too).

### 2.5 Shared component translation ownership (implementation rule)

- Shared widgets read copy internally: `final t = SharedCoreLocalizations.of(context);`
  — call sites pass **data**, not labels (e.g. `EmptyState(title: t.emptyJobsTitle)`).
- Components whose copy is contextual (a dialog title provided by a feature)
  keep taking the string as a parameter; the feature supplies the localized
  value from its own unit.
- `status_labels.dart` becomes `AppStatusLabels.of(context)` (or an equivalent
  locale-aware accessor) returning localized labels; its current static English
  constants are removed. Migration of app call sites happens per feature phase
  (list them in the phase report); shared-internal call sites migrate in Phase
  02.
- Tests for shared widgets must pump delegates (test helper
  `pumpLocalizedApp(...)` added to `shared_core` test utilities).

### 2.6 Duplicate-key avoidance

- Keys are namespaced per feature: `advisorIntakeVehicleSectionTitle`,
  `ownerArAging0to30`, `crmLeadStatusQualified` — never generic (`title`,
  `save`).
- Across units, values may legitimately repeat ("Save" exists in several
  units); **keys must not collide within a unit**, and shared concepts
  (statuses, empty/error, offline copy) must reference the `shared_core` unit
  instead of being re-defined per app.
- A per-unit **ARB parity test** (`<unit>_arb_parity_test.dart`) parses
  `app_en.arb` and `app_ar.arb` and fails when the key sets differ or a required
  `@description` is missing — this is the anti-drift mechanism.
- `flutter gen-l10n` runs with `untranslated-messages-file`; CI/local check
  fails when the file is non-empty for either locale.

---

## 3. Arabic typography

- **Family:** IBM Plex Sans Arabic (SIL OFL; weights 400/500/600/700), bundled
  under `packages/shared_core/assets/fonts/ibm_plex_sans_arabic/`, registered in
  `shared_core/pubspec.yaml` as family `packages/shared_core/IBM Plex Sans Arabic`.
- **Fallback chain:** `IBM Plex Sans Arabic → Noto Sans Arabic → system Arabic
  font` (declared in `AppFontFamilies.arabicFallback`, exercised even before the
  asset exists so Phase 01 wiring is test-safe).
- **Application:** `AppTypography.forLocale(locale)` (from Phase 01) selects the
  family stack; Arabic roles get line-height ×1.05, letter-spacing 0, no case
  transforms. Latin identifiers inside Arabic screens stay on Plus Jakarta Sans
  via run-level `fontFamily` on identifier styles (`mono*` roles).
- **Numerals:** Latin digits in both locales (product decision, see
  `00_VISUAL_DIRECTION.md`); all numeric roles keep tabular figures. Eastern
  Arabic numerals explicitly out of scope.
- **Weights:** map Arabic weight usage to 400/500/600/700; never bold-only
  hierarchy (Arabic bold can look heavy) — hierarchy also uses size + color.

---

## 4. Formatting

- `AppFormatters` in `shared_core` (wraps `intl`):
  `date`, `dateShort`, `dateTime`, `time`, `moneyAED`, `quantity`, `percent`,
  `compactCount`, `relativeTime` — all locale-aware.
- API payloads stay **ISO-8601/raw enums** exactly as today; formatting is
  display-only (no serialization change, no DTO change).
- Currency: AED default; `12,450.00` style with locale grouping/symbol per
  locale (EN: `AED 12,450`; AR: `12,450 د.إ`).
- Identifiers (VIN, plate, phone, SKU, invoice/job refs) keep Latin digits and
  `mono*` styling in both locales; they are excluded from "translate
  everything" sweeps.

---

## 5. RTL layout rules (binding)

1. `EdgeInsetsDirectional`, `AlignmentDirectional`, `start/end`,
   `BorderDirectional` everywhere in new/modified code. Existing raw
   `left/right` layout insets are converted in the owning screen's phase.
2. Directional icons flip via a shared helper (`DirectionalIcon` or documented
   convention): back/forward, chevrons, arrows, undo, timeline progression,
   drawer edges. Non-directional icons (clock, person, document) never flip.
3. Navigation chrome mirrors automatically via `Directionality`: rail side,
   drawer edge, bottom-bar order, "More" sheet rows, brand-mark lockups.
4. Sheets/action bars/sticky footers mirror alignment; drag handles stay
   centered.
5. Progress (`AppLinearProgress`, `AppStepProgress`): determinate mirrors the
   start edge; indeterminate stays direction-neutral.
6. Tables mirror column order; numeric columns keep tabular figures with
   locale-consistent alignment (spec §13).
7. Charts (fl_chart + painters): axis order mirrors; axis labels localized;
   series legends order mirrors.
8. **Explicit exceptions (must be documented in the owning phase):**
   - Vehicle damage map / car outline: physical left/right must NOT mirror
     (canonical case, Phase 07B). Surrounding UI mirrors; the map does not.
   - Media/images, signatures, and plate/identifier strings keep natural
     direction.

---

## 6. Mixed English/Arabic input and technical identifiers

- Text fields accept bidi input by default; Flutter handles per-character bidi.
- Identifier fields (VIN, plate, phone, email, SKU) enforce
  `textDirection: TextDirection.ltr` + Latin keyboard hints regardless of
  locale; labels/hints around them localize.
- `TextField` hints align with the locale; user-entered mixed content is never
  force-aligned.
- A dedicated prototype proof exists: Phase 00 screen D4 (Arabic owner name
  beside Latin plate) — the pattern is copied into `AppTextField`'s identifier
  variant so every app gets it once.

---

## 7. Migration rules for feature phases

1. A phase localizes only the screens it owns; no cross-app key renames.
2. When touching a screen: replace hard-coded strings with keys in the owning
   unit (EN+AR in the same change), run `flutter gen-l10n`, update the parity
   test expectations (automatic from ARB), and delete the literals.
3. Shared widget copy arrives via `shared_core` keys (created in Phase 02 or
   added following README §8 if new).
4. Semantics labels, tooltips, SnackBar copy and dialog copy are strings too —
   same rules.
5. Phase reports must state "N new keys, EN+AR complete, parity test passes".

---

## 8. Testing requirements (end-to-end across boundaries)

### 8.1 Unit
- Locale resolution (persisted → system → en); Hive persistence round-trip;
  `AppFormatters` for en/ar (dates, money, quantity, percent, relative time);
  identifier digit policy; Arabic typography mapping.

### 8.2 Per-unit
- ARB parity test per unit (key sets + descriptions).
- `untranslated-messages-file` empty check.

### 8.3 Cross-boundary widget tests (mandatory)
Pump real compositions containing strings from **all three layers** and assert
each layer renders its own localized copy under `Locale('ar')`:
- staff: `AdvisorHomeView` (app copy) + `OfflineBanner` (shared_core) +
  `LoginView` (shared_auth) in one harness (or two harnesses in one test file).
- owner: `DashboardBody` + shared dialogs + login copy.
- customer: `CustomerScaffold` + shared notices + login copy (registration).
- crm: `CrmDashboardView` + shared widgets + login copy — this is also the proof
  that the old workshop-specific `SecurityBadge` leak is gone in Arabic.
- Locale switch test: flip `localeProvider` at runtime → assertion that app,
  shared_core and shared_auth copy all change without restart.
- RTL assertions on the same harnesses: `Directionality.of == rtl`, mirrored
  rail border, flipped directional icons.

### 8.4 Overflow/scale
- Every cross-boundary harness at 320 px and 1.3× scale in both locales with
  zero overflow exceptions.

---

## 9. Acceptance criteria (Phase 02 + repeated per feature phase)

- App launches in English and Arabic; switcher works, applies immediately, and
  persists across restarts.
- No user-visible hard-coded English remains in strings owned by the phase
  (search-verifiable, excluding documented identifier exceptions).
- Distinct generated classes/imports per unit; all delegates registered in all
  four apps; no bare `AppLocalizations` collisions.
- ARB parity + untranslated checks pass for every unit touched.
- Cross-boundary tests prove app + shared_core + shared_auth localized copy
  render together in AR, and locale switch affects all layers live.
- Arabic typography applied with correct metrics and fallback documented.
- Numbers/dates/money localized; identifiers stay Latin; API payloads
  unchanged.
- RTL mirroring verified incl. the documented exceptions; no clipped layouts in
  AR at 320 px.
