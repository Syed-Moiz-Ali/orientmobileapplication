# PHASE 02 — Localization & RTL Foundation: Completion Report

- **Date:** 2026-10-13
- **Phase:** 02 — Localization & RTL Foundation (`phases/PHASE_02_LOCALIZATION_RTL_FOUNDATION.md`)
- **Status:** **IMPLEMENTATION COMPLETE — awaiting product-owner review**
- **Toolchain:** Flutter 3.35.7 stable · Dart 3.9.2 · Windows dev machine
- **Authorities:** `00_LOCALIZATION_RTL_STRATEGY.md` (binding), `PHASE_02_LOCALIZATION_RTL_FOUNDATION.md`,
  `00_DESIGN_SYSTEM_SPEC.md` §9, `00_VISUAL_DIRECTION.md` (frozen V4/V5/V11), Phase 00 prototype
  `apps/design_prototype/lib/l10n/provisional_strings.dart` (copy authority; **untouched, 299/299**)

---

## 1. Localization architecture implemented

Six **independent** l10n units, each with its own `l10n.yaml`, ARB pair and generated class +
directory (no `AppLocalizations` collision), generated with `flutter gen-l10n` and committed:

| Unit | Generator config | Generated class / import |
|---|---|---|
| `packages/shared_core` | `l10n.yaml` → `lib/l10n/gen/` | `SharedCoreLocalizations` · `package:shared_core/l10n/gen/shared_core_localizations.dart` |
| `packages/shared_auth` | `l10n.yaml` → `lib/l10n/gen/` | `SharedAuthLocalizations` · `package:shared_auth/l10n/gen/shared_auth_localizations.dart` |
| `apps/staff_app` | `l10n.yaml` → `lib/l10n/gen/` | `StaffLocalizations` · `package:staff_app/l10n/gen/staff_localizations.dart` |
| `apps/owner_app` | `l10n.yaml` → `lib/l10n/gen/` | `OwnerLocalizations` · `package:owner_app/l10n/gen/owner_localizations.dart` |
| `apps/customer_app` | `l10n.yaml` → `lib/l10n/gen/` | `CustomerLocalizations` · `package:customer_app/l10n/gen/customer_localizations.dart` |
| `apps/crm_app` | `l10n.yaml` → `lib/l10n/gen/` | `CrmLocalizations` · `package:crm_app/l10n/gen/crm_localizations.dart` |

All units use `untranslated-messages-file: l10n_untranslated.json`; every generated
`l10n_untranslated.json` is `{}` (verified by the per-unit parity tests).

**Single locale contract (shared_core).**

- `AppLocales.supported = const [Locale('en'), Locale('ar')]`, `AppLocales.fallback = Locale('en')`,
  `AppLocales.resolve({persisted, system})` implementing the priority **persisted → system → English**.
- `localeProvider` (`StateNotifierProvider<LocaleController, Locale?>`) is the single source of truth.
  `LocaleController.readPersisted()` hydrates from the Hive `settings` box; `setLocale` writes back
  (`delete` when null). `HiveRegistry.initHive()` now opens the `settings` box **before `runApp`**, so
  the first frame renders in the persisted locale (no English flash).
- All four `main.dart` register **all** delegates, `supportedLocales: AppLocales.supported`,
  `locale: effectiveLocale` and `onGenerateTitle`. Effective locale is resolved in each app with
  `AppLocales.resolve(persisted: ref.watch(localeProvider), system: platformDispatcher.locale)` and is
  also passed to `AppTheme.light/dark(brand, locale:)` so **typography follows the active language**
  from the very first frame.

**Graceful-testing accessors.** `SharedCoreL10n.of(context)` / `SharedAuthL10n.of(context)` read the
registered delegate and fall back to the English bundle (via the generated
`lookup…(Locale('en'))`) when no delegate is present. This keeps the large existing
delegate-less widget-test corpus rendering canonical English (zero churn) while apps always get the
active locale. `SharedAuthL10n.forLocale(Locale)` serves Riverpod notifiers (login validation) that
run outside the widget tree.

**No competing providers, no new packages.** Only the SDK `flutter_localizations` was added (six
units); `intl` was already a dependency. No route/provider/API/persistence change was made beyond the
narrowly-scoped `settings` box key.

## 2. Translation resource ownership

Ownership table from `00_LOCALIZATION_RTL_STRATEGY.md` §2.1 is honored:

- **shared_core (56 keys):** shared widget copy — retry/cancel/close/back, error/empty titles, offline
  banner, logout/exit/un-synced dialogs, profile sheet "Sign out", search field hint + clear tooltip,
  top-bar back tooltip, notifications tooltip, sheet close tooltip, date-selector hint, media-upload
  defaults, **17 status labels**, relative-time formatter copy, language-switcher copy.
- **shared_auth (81 keys):** all login/code/registration/recovery copy, auth identity panel, security
  badge, legacy phone/OTP widgets, and provider validation + friendly transport errors.
- **Each app (4 keys):** `appTitle` (OS title), `loginAppName`, `loginAppPurpose`,
  `loginIntendedUsers` — app identity strings passed into `shared_auth` views as localized values
  (per §2.5 rule).

No app-specific key was added to a shared unit; no shared concept is re-defined per app.

## 3. Files changed

**shared_core (production):** `pubspec.yaml` (+`flutter_localizations`, +`generate`, +IBM Plex
Sans Arabic family), new `l10n.yaml`, `lib/l10n/app_en.arb` + `app_ar.arb` (+ `gen/`), new
`lib/src/localization/{app_locales, locale_provider, app_formatters, language_switcher,
shared_core_l10n}.dart`, new `lib/src/widgets/directional_icon.dart`, `lib/shared_core.dart`
(exports), `lib/src/theme/app_theme.dart` (locale-aware, `arabic:` threaded through all component
text styles), `lib/src/theme/app_text_styles.dart` (`AppTypography.tracking`), `status_labels.dart`
(locale-aware `AppStatusLabels.of` + legacy shims), `local/hive/hive_registry.dart` (`settings` box),
`errors/app_error_handler.dart` (forced-LTR removed), and 13 shared widgets
(`empty_state`, `error_view`, `offline_banner`, `logout_dialog`, `exit_confirmation_dialog`,
`app_confirmation_dialog`, `app_search_field`, `app_text_field` [+identifier variant], `app_top_bar`,
`profile_sheet`, `notification_bell`, `app_form_primitives`, `app_bottom_sheet`,
`app_kpi_card`/`app_page_header`/`app_record_row`/`status_pill` Arabic-tracking + dark-safe icons).

**shared_auth (production):** `pubspec.yaml`, new `l10n.yaml` + ARBs, new
`lib/src/localization/shared_auth_l10n.dart`, `shared_auth.dart` (exports), and
`login_view`, `forgot_password_view`, `login_provider`, `auth_surface`, `auth_field`,
`auth_button`, `auth_loading_view`, `security_badge`, `otp_input_field`, `phone_input_field`.

**Apps (production):** `pubspec.yaml`, `l10n.yaml` + ARBs, `lib/main.dart` (delegates + locale-aware
theme) ×4; `app_router.dart` (localized `LoginView`/`ForgotPasswordView` identity) ×4;
`staff_app/.../simple_pages.dart` + `crm_app/.../crm_settings_page.dart` +
`customer_app/.../customer_profile_tab.dart` & `customer_profile_rows.dart` (minimal language entry
points + RTL chevron).

**Tests added:** `shared_core/test/{localization_test.dart, localized_shared_widgets_test.dart,
arb_parity_test.dart}`; `shared_auth/test/{localized_auth_test.dart, arb_parity_test.dart}`;
`apps/*/test/{localization_cross_boundary_test.dart, arb_parity_test.dart}` (×4).

**Evidence:** `phases/reports/PHASE_02/{baseline/, screens/, capture/, final_*.txt, analyze_*.txt}`.

*Not touched:* `apps/design_prototype/**` (git-verified 0 changes), route paths/`extra` contracts,
provider names, API/DTO shapes, permissions, sync, the Phase 00 prototype and its goldens.

## 4. Arabic font integration

- IBM Plex Sans Arabic (SIL OFL; weights 400/500/600/700) bundled under
  `packages/shared_core/assets/fonts/ibm_plex_sans_arabic/` and registered in
  `shared_core/pubspec.yaml` as family `IBM Plex Sans Arabic` → resolved at runtime as
  `packages/shared_core/IBM Plex Sans Arabic` (`AppFontFamilies.arabic`).
- Fallback chain preserved: `AppFontFamilies.arabicFallback = [Noto Sans Arabic, sans-serif]`.
- **Application:** `AppTypography.forLocale(locale)` selects the family stack and Arabic metrics
  (line-height ×1.05, zero letter-spacing, no case transforms). `AppTheme.light/dark(brand, locale:)`
  now build `textTheme` from `forLocale(locale)` **and** thread `arabic:` through every component
  text style (app bar, buttons, dialogs, inputs, nav, chips, snackbar) so Material chrome uses IBM
  Plex in Arabic. Latin output is byte-identical when `locale` is null/English (all Phase 01 goldens
  untouched).
- **Latin numerals for identifiers:** `AppFormatters` forces Latin digits in both locales;
  mono/tabular roles stay Latin-only. The identifier `AppTextField` variant forces
  `textDirection: TextDirection.ltr` (verified in test even under `Locale('ar')`).
- Rendered proof: `screens/auth_login_390_ar.png` (correct Arabic shaping + mirrored layout),
  `screens/shared_chrome_390_ar.png`.

## 5. Locale switching and persistence behavior

- In-app switching through the shared `LanguageSwitcher` row → `localeProvider.setLocale` → immediate
  rebuild (no restart) → persisted to Hive (`settings` box, key `app_locale`).
- Restart: `HiveRegistry.initHive()` opens the box before `runApp`; `LocaleController` hydrates from it,
  so frame 1 is already in the persisted locale.
- Locale choice is available **pre-login** (auth screens localize). Locale is independent of auth.
- Tests: `localization_test.dart` (resolution + Hive round-trip incl. unsupported-value rejection);
  `localized_shared_widgets_test.dart` and `localized_auth_test.dart` (live flip of `localeProvider`
  changes shared_core and shared_auth copy without restart).

## 6. RTL handling

- **Direction follows locale** automatically via `GlobalWidgetsLocalizations` (`Directionality.rtl` for
  Arabic) — verified in every AR widget test.
- **Directional icons mirror** through the new `DirectionalIcon` (`Transform.flip`), used for the
  top-bar back arrow, profile/logout icon, all chevrons (`AppRecordRow`, `ProfileSheet`,
  customer profile rows), and the language picker. Non-directional icons are untouched.
- **Leading/trailing padding:** the one LTR-specific alignment found in scope
  (`customer_profile`/login "forgot password" link `Alignment.centerRight`) was converted to
  `AlignmentDirectional.centerEnd`; `PhoneInputField`'s start-corner radius made direction-safe.
- **Notification badge** is anchored to the top-**end** corner.
- **Arabic tracking removed** where shared components hard-coded Latin letter-spacing (KPI label, page
  header eyebrow + uppercase, record-row identifier, status pill, auth brand mark) via
  `AppTypography.tracking(context, latin)`.
- **Forced LTR removed** from `app_error_handler.dart`; the crash surface now follows ambient
  direction (the sole audited English exception — `ErrorWidget.builder` has no `BuildContext`).
- **Documented exception:** the vehicle damage map / car outline keeps its canonical physical
  orientation in Arabic — reserved for **Phase 07B** (unchanged in this phase).

## 7. Responsive validation

- Cross-boundary harnesses and shared-chrome tests run at **320, 390, 768, 1280** (and 320 at 1.3×);
  Arabic long-string sweep of shared widgets at 320 px / 1.3× shows **zero overflow exceptions**
  (`localized_shared_widgets_test.dart`).
- The shared `LanguageSwitcher` uses `showAppModalSheet` → bottom sheet on compact, bounded dialog on
  ≥600 px.
- Render pack includes mobile (320/390), tablet-split (1024) and phone scale-1.3× in Arabic.
- Feature-screen localization-induced overflow is deferred to the owning feature phases (feature
  screens keep their current English layout untouched).

## 8. Translation coverage

- **shared_core: 56 keys**, EN+AR complete (parity test passes, untranslated file empty).
- **shared_auth: 81 keys**, EN+AR complete.
- **Each app: 4 keys**, EN+AR complete.
- Arabic terminology reviewed for automotive/workshop workflows (e.g. statuses `قيد الخدمة`,
  `بانتظار القطع`, `فحص الجودة`; auth `رمز لمرة واحدة`, `التقديرات`).
- **Not claimed complete:** feature-screen copy owned by later phases (advisor/supervisor/technician,
  owner dashboards, customer flows, CRM) remains English **by design** — this is visible and expected
  in `screens/customer_profile_390_ar.png` (only the shared "Language" row is Arabic). These are
  tracked per phase in §12/§13.

## 9. Tests executed and exact results

Baseline captured **before** implementation (this session), final after. Per-package
`flutter test` (Melos scripts are still unusable in this workspace — see §14).

| Unit | Baseline (pass/fail) | Final (pass/fail) | New failures | Notes |
|---|---|---|---|---|
| `shared_core` | 130 / 9 | **155 / 9** | **0** | +25 new tests; same 9 missing-golden baseline |
| `shared_auth` | 30 / 11 | **35 / 11** | **0** | +5 new tests; same 11 missing-golden baseline |
| `staff_app` | 274 / 7 | **277 / 7** | **0** | +3 new; same 6 intake overflow + 1 advisor-workflow |
| `owner_app` | 19 / 0 | **21 / 0** | **0** | +2 new |
| `customer_app` | 509 / 6 | **511 / 6** | **0** | +2 new; **7 customer-profile goldens intentionally regenerated** (additive language row, reviewed) — booking-flow 3 remain the pre-existing baseline |
| `crm_app` | 12 / 0 | **14 / 0** | **0** | +2 new |
| `design_prototype` | 299 / 0 | **299 / 0** | 0 | read-only; git-verified zero changes |

**Static analysis:** `dart analyze` → **0 issues** on all six production units **and**
`apps/design_prototype` (`analyze_*.txt`).

**New tests (all passing):**
- `shared_core/localization_test.dart` (14): locale resolution, Hive persistence round-trip,
  `AppFormatters` en/ar (money `AED 12,450` / `12,450 د.إ`, quantity, percent, compact count, dates,
  latinize), Arabic typography mapping ×1.05 + mono Latin-only, **IBM Plex Sans Arabic assets bundled**.
- `shared_core/localized_shared_widgets_test.dart` (10): Arabic shared chrome (EmptyState.error,
  ErrorView, AppTopBar tooltip, search field, confirmation dialog) + RTL direction; `DirectionalIcon`
  mirroring (flip in RTL, none in LTR); identifier `AppTextField` forces LTR content in Arabic while a
  normal field inherits RTL; bottom-nav order mirrors in RTL; 320 px / 1.3× no-overflow; **locale-switch
  live**.
- `shared_auth/localized_auth_test.dart` (4): LoginView AR copy + RTL, registration AR copy,
  ForgotPasswordView AR copy, **auth copy live locale switch**.
- `shared_core`/`shared_auth`/4-app `arb_parity_test.dart` (1 each): EN/AR key-set equality +
  `@description` coverage + empty untranslated file.
- `apps/*/localization_cross_boundary_test.dart`: **app + shared_core + shared_auth copy render
  together under `Locale('ar')`** with `Directionality.rtl` (staff also proves English-by-default).

## 10. Pre-existing versus newly introduced failures

- **Pre-existing (unchanged, recorded baseline):** shared_core 9 missing-golden files; shared_auth 11
  missing-golden files; staff 6 `VehicleCustomerView` intake overflows + 1 advisor-workflow finder;
  customer 3 booking-flow goldens (schedule/review/tablet). None is caused or touched by Phase 02.
- **Newly introduced:** **none.** The only golden churn is the 7 customer-profile goldens, regenerated
  because the phase intentionally adds one language row; each was reviewed (sample:
  `screens/customer_profile_390_ar.png` and the regenerated EN mobile golden) before re-baselining.
- Golden baselines were **not** regenerated blind; the Phase 00 prototype and its goldens were not
  touched.

## 11. Screenshots / render evidence

`phases/reports/PHASE_02/screens/` (11 renders; AR uses IBM Plex Sans Arabic, verified applied):

| File | What it proves |
|---|---|
| `auth_login_390_en.png` / `auth_login_390_ar.png` | EN-LTR vs AR-RTL login incl. mirrored form, Latin identifiers in RTL |
| `auth_login_320_ar.png` | Arabic at 320 px, no clipping |
| `auth_login_390_ar_scale13.png` | Arabic at 1.3× |
| `auth_login_1024_ar.png` | Arabic tablet split (identity panel + form) |
| `auth_forgot_390_ar.png` | Arabic recovery |
| `shared_chrome_390_en.png` / `shared_chrome_390_ar.png` | Top bar back-arrow mirror, EmptyState.error + ErrorView Arabic |
| `shared_chrome_320_ar_scale13.png` | Shared chrome 320 px / 1.3× |
| `shared_dialog_390_ar.png` | Localized confirmation dialog (RTL, mirrored actions) |
| `shared_language_sheet_390_ar.png` | Language picker sheet in RTL |
| `customer_profile_390_ar.png` | Real customer Profile screen in RTL: identity/rows mirrored, chevrons flipped, shared "Language" row Arabic; feature copy still English (expected) |

Capture harness sources are archived under `phases/reports/PHASE_02/capture/` (copy into the owning
package's `test/` and run `flutter test --update-goldens` to regenerate; **not** part of the normal
suite).

## 12. Remaining issues assigned to future phases

| Item | Owner phase |
|---|---|
| Feature-screen copy localization (all hard-coded feature strings) | 06–19C (owning phases) |
| Migrate `AppStatusLabels.booking/breakdown/invoice/normalizeJob` static call sites → `AppStatusLabels.of(context)` (**6 sites, all `customer_app`**: `customer_booking_success_view.dart:149`, `customer_approvals_page.dart:529`, `customer_service_tracking.dart:113`, `customer_entities.dart:169`, `customer_invoice_detail_view.dart:83`, plus doc ref) | 15A–18 |
| Customer Profile contact rows: phone `+971 50 123 4567` renders reversed under RTL (all-neutral bidi) — needs the identifier `textDirection: ltr` treatment in `_InfoRow` | 15A |
| Feature screens use raw `left/right` insets — convert per owning screen | owning phases |
| Hard-coded feature `toUpperCase()`/tracking on Arabic | owning phases |
| Vehicle damage-map canonical-orientation exception (documented, not implemented) | 07B |
| Auth identity-panel role-token parsing assumes English `for … and …` | 05 |
| Remove the legacy `AppStatusLabels` static shims once migrated | 20 |
| Melos 8 workspace migration decision | tooling (unscheduled) |

## 13. Readiness assessment for Phase 03A

**Ready.** The Phase 02 contract for dependents is satisfied:

- all six l10n units generate distinct classes with the specified imports; all delegates are
  registered in all four apps; no class collisions; every ARB has EN+AR parity and zero untranslated
  messages;
- `AppLocales`, `localeProvider`, `LanguageSwitcher`, `AppFormatters`, `AppStatusLabels.of`,
  `DirectionalIcon`, and the identifier `AppTextField` variant are exported from `shared_core` for
  downstream consumption;
- shared surfaces are fully localized EN+AR with no remaining hard-coded user-visible English except
  the one documented, context-less crash surface;
- Arabic typography is applied with the approved family, fallback chain and metrics, proven by render;
- RTL mirrors shared chrome; the damage-map exception is documented for 07B;
- app + shared_core + shared_auth render together in Arabic (cross-boundary tests) and locale switch is
  live;
- `dart analyze` is clean on all seven units and no golden was regenerated except the reviewed
  customer-profile set; the prototype is untouched.

**Phase 02 completion checklist**

- [x] Six l10n units, distinct classes/imports, delegates registered in all apps
- [x] `AppLocales` + `localeProvider` + Hive persistence + pre-first-frame hydration
- [x] IBM Plex Sans Arabic bundled + applied through `AppTypography.forLocale`
- [x] Locale-aware theme; Latin typography byte-identical
- [x] Shared copy localized; `AppStatusLabels` locale-aware (+ documented shim)
- [x] Auth copy localized; provider validation localized
- [x] `AppFormatters`, `LanguageSwitcher`, `DirectionalIcon`, identifier `AppTextField`
- [x] Forced LTR removed; RTL mirrors shared chrome; damage-map exception documented
- [x] Parity + untranslated + cross-boundary + locale-switch + RTL + overflow + font tests pass
- [x] Six suites + prototype at baseline (0 new failures); analyze 0 issues on 7 units
- [x] 11-render EN/AR evidence pack + reviewed golden updates
- [x] Per-app feature-migration list delivered (§12)

## 14. Melos note (unchanged from Phase 01)

`melos run analyze/test*` still cannot execute (legacy `melos.yaml` scripts vs. Melos 8 pub-workspace
discovery). All Melos equivalents were run per package — exactly as documented in
`PHASE_01_COMPLETION.md` §9 — and recorded here.
