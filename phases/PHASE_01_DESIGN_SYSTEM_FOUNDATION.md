# PHASE 01 — Design System Foundation

## A. Phase identity

- **Phase number:** 01
- **Title:** Design System Foundation (tokens, typography roles, themes, motion, elevation, dark parity, safe text-scale removal)
- **Objective:** Codify the **Phase 00-approved** visual direction into `packages/shared_core` as the single design authority, wire the themes in all four apps, and remove the global text-scale restriction **without leaving any application-breaking layout regression behind** — creating the base every later phase builds on.
- **Priority:** Critical (blocks everything; requires Phase 00 sign-off in `phases/00_VISUAL_DIRECTION.md`)
- **Dependencies:** Phase 00 (visual direction approved — hard gate)
- **Estimated scope:** Medium-Large

**Approved Phase 00 inputs (binding — do not re-derive from the prototype):**

- `phases/00_VISUAL_DIRECTION.md` — **APPROVED 2026-10-13**; V1–V14 frozen
  values + §3 decision log (dark palette map, KPI tile sizing, pill ellipsis,
  tablet density, workflow steps, required fields, field stacking, identifier
  policy) + §5 refinement assignments + §6 handoff prerequisites.
- `phases/reports/PHASE_00/VISUAL_QUALITY_AUDIT.md` — the rendered evidence the
  approval is based on; its §5 items are assigned to phases (03A/03B/07B/10/12/16).
- `apps/design_prototype/` — **read-only** rendered reference for this phase
  (its tokens mirror what must now be codified in `shared_core`; its 299-test
  suite and `test/goldens/` baselines are frozen). Do not edit the prototype.
- Carried-into-this-phase specifics: dark parity map exactly as the approved
  prototype palette (`ProtoPalette.dark` values); `AppKpiCard` sizing must be
  scale-aware (≥156 px at 1.0×, grows with text scale); status pills must
  ellipsize inside flex; `AppTypography.forLocale` must reproduce the
  prototype's Arabic line-height ×1.05 / zero letter-spacing behavior; shared
  primitives are verified to **1.6×** text scale in this phase per spec §3.3.

## B. Repository context

- Tokens today:
  - `packages/shared_core/lib/src/theme/app_colors.dart` (semantic palette + legacy aliases)
  - `packages/shared_core/lib/src/theme/app_dimensions.dart` (4-pt scale, radii, shadows, icon sizes, content widths)
  - `packages/shared_core/lib/src/theme/app_text_styles.dart` (`AppFontFamilies`, `AppTextStyles`, `AppTypography`)
  - `packages/shared_core/lib/src/theme/app_motion.dart`
  - `packages/shared_core/lib/src/theme/app_theme.dart` (`AppTheme.light(brand)`, `AppTheme.dark(brand)`)
  - `packages/shared_core/lib/src/branding/brand_config.dart` (`BrandConfig.orient`, provider + override hook)
- Theme wiring: `apps/{staff_app,owner_app,customer_app,crm_app}/lib/main.dart` — all call `AppTheme.light(brand)`; `customer_app` also defines `darkTheme` but forces `ThemeMode.light`. All four force `MediaQuery(textScaler: TextScaler.linear(0.85))` in the builder.
- Fonts: `packages/shared_core/pubspec.yaml` registers "Plus Jakarta Sans" (300–800). Arabic family is Phase 02; this phase prepares the wiring only.
- Consumers whose public APIs must not break (audited list): every theme reference across ~120 UI files plus shared widgets in `packages/shared_core/lib/src/widgets/`, navigation in `lib/src/layout/`, and every test in `packages/shared_core/test/` (`app_theme_test.dart`, `app_theme_visual_test.dart`, `app_responsive_test.dart`, `shell_unification_test.dart`, `app_adaptive_navigation_test.dart`, `shared_components_visual_test.dart`).
- Spec: `phases/00_DESIGN_SYSTEM_SPEC.md` §2–§4 + `phases/00_VISUAL_DIRECTION.md` (frozen values).

## C. Design objectives

1. **One authoritative token set.** All apps and shared packages read colors/spacing/radii/typography/motion exclusively from `shared_core` tokens. Raw hex, magic radii, ad-hoc durations become review-rejected. Values are the **Phase 00-frozen** values (from `00_VISUAL_DIRECTION.md`), not guesses.
2. **Complete color roles incl. states.** Add to `AppColors`: `overlayScrim`, `onNavySecondary`, `focusRing`, `ratingStar`, and the 6-value chart palette (light + dark variants). Keep every existing token name resolving (additive only).
3. **Completed light AND dark token mapping.** `AppTheme.dark` must cover every component theme `AppTheme.light` covers with correct contrast — proven by a **parity test** that walks both themes and asserts matching resolved roles. Dark stays opt-in (`ThemeMode.light` default) but is fully usable.
4. **Locale-aware typography foundations.** Structure `AppFontFamilies` for a second (Arabic) family and add `AppTypography.forLocale(Locale? locale)` (or equivalent) that switches family stack + line-height multipliers per locale, testable with a stub family now; Phase 02 plugs in the real Arabic font. Zero call-site changes required later.
5. **Motion respects users.** `AppMotion` gains a reduced-motion resolver; all shared widgets that animate use it.
6. **Safe text-scale removal (this is a gate, not a note).** Remove `TextScaler.linear(0.85)` from all four apps and **fix every application-breaking layout regression it exposes inside this phase** (protocol in §H). Non-breaking polish items are listed for the owning feature phase; nothing that makes a current screen unusable may be deferred.
7. **Elevation language.** `shadowSurface/Card/Modal/Navy` documented + applied as levels 0–3 consistently in component themes.

---

## C2. Public API preservation contract (binding)

The following exported symbols must keep their exact names, signatures and
semantics (additive changes only; deprecations annotated):

| API | Constraint |
|---|---|
| `AppColors.*` (all fields incl. legacy aliases) | Keep names; may only add new fields |
| `AppDimensions.*` (spacing/radii/shadows/icons/touchTarget/content*) | Keep names and values unless Phase 00 froze a change (then update all usages in this phase; no silent drift) |
| `AppTextStyles.*` role functions | Keep names + call signatures; internal values may align to frozen spec |
| `AppTypography.textTheme` | Keep returning a `TextTheme`; add `forLocale` as new API |
| `AppTheme.light(BrandConfig)` / `AppTheme.dark(BrandConfig)` | Keep signatures |
| `BrandConfig` fields + `brandConfigProvider` / `overrideBrandConfigProvider` | Keep |
| `AppResponsive`/`AppAdaptiveSpec` public members | Keep (Phase 04 owns refinement) |
| `shared_core.dart` export list | Only additive exports |

Any unavoidable signature change requires: (a) updating **every** usage in the
same commit, (b) an entry in the phase report's "API changes" table, (c) all
package tests updated — never deferred.

---

## D. Screens and workflows

No screen is redesigned here. The phase changes how **every** screen renders
globally. Seams the later phases depend on:

- Finalized `ThemeData` for both brightnesses (component themes complete).
- `metric`/`mono*` remain the only data-value typography roles.
- Shared widgets keep working with zero call-site edits (or all call sites are
  updated in this phase if a signature changed — see §I).
- App-level `MediaQuery` wrapper removed; screens now obey the system text
  scale (features verify 1.3× in their own phases; **this phase fixes only
  breakage**, §H).

## E. Responsive specifications

- Token layer stays responsive-neutral: `AppResponsive` specs keep deriving
  from the same dimension tokens; no breakpoint changes.
- The only responsiveness-relevant change is text-scale removal; validation at
  1.0× default across all suites + the overflow regression sweep in §H.
- Run `shared_core/test/app_responsive_test.dart` untouched (regression guard).

## F. Localization and RTL

- No strings localized here (Phase 02 owns ARB infrastructure).
- `AppTypography.forLocale` is direction-agnostic; it must work before Arabic
  font assets exist (fallback list may reference an unregistered family).
- No `Directionality` overrides; no LTR assumptions introduced.

## G. Design system integration

- Edit only theme/token files (+ `shared_core.dart` exports if additive).
- Values come from `00_VISUAL_DIRECTION.md` §1 (frozen table). If the prototype
  review amended a value, the amendment is the requirement — do not "restore"
  older values.
- Update token doc comments to state role + usage rule (spec §2–§4 mirroring).

## H. Technical implementation

### H1. Files to modify
- `app_colors.dart` — add roles (§C2 additive); document chart palette (light+dark).
- `app_text_styles.dart` — add `AppFontFamilies.arabic` + fallback stack const;
  add `AppTypography.forLocale`; no role-size changes beyond frozen spec.
- `app_motion.dart` — reduced-motion resolver.
- `app_theme.dart` — complete dark component themes; shadow levels; ensure both
  brightnesses set every `ColorScheme` surface/outline/error role.
- `apps/*/lib/main.dart` ×4 — remove the text-scale override (see H2).

### H2. Text-scale removal protocol (safe, per app)
1. Remove the override in **one app**, run `flutter test` for that app plus a
   new **layout smoke test** (H3) at default scale.
2. If a screen overflows/throws because of scaling, fix it **in this phase**
   when the fix is bounded UI-only (ellipsis/maxLines, `Flexible`/`Expanded`,
   wrapping the content in a scrollable, replacing fixed heights with intrinsic
   sizing). These are bug fixes, not redesigns — keep visual output at 1.0×
   effectively identical.
3. If a screen's fix would require redesign (structure change), **keep that
   screen functional at 1.0×** (no crash, no overflow at default scale) and add
   it to a tracked list `phases/reports/PHASE_01/scale_polish_list.md` for its
   owning feature phase to complete at 1.3×. Application-breaking cases are
   **not** allowed on this list — they must be fixed here.
4. Repeat for the remaining three apps; finish with all four apps unlocked.
5. Evidence: per-app test run after removal + smoke test list; before/after note
   in the report for every in-phase fix.

### H3. Real-context component verification (new tests)
Pump **real screens** (not isolated widgets) inside tests, at default scale and
1.3×, to prove the foundation renders actual app compositions:
- `staff_app`: `AdvisorHomeView`, `StaffProfileScreen` (existing test harnesses reuse).
- `owner_app`: `DashboardBody`/`OwnerDashboardPage` with fake providers.
- `customer_app`: `CustomerScaffold` + `CustomerHomeTab`.
- `crm_app`: `CrmDashboardView` shell.
- `shared_auth`: `LoginView` both locales-as-available (EN only this phase).
These tests assert: builds without exceptions, no overflow errors, token-driven
typography resolves, and text scale 1.3× produces no `RenderFlex overflowed`.

### H4. Constraints
- No new packages. No route/provider/API changes beyond the additive token API.
- No widget redesign (03A/03B own components). No localization infra (02).
- Dark remains non-default; no app-level theme-mode switch added here.

## I. Functional preservation

- **API preservation contract** (§C2) enforced; the audit list of load-bearing
  tests must pass untouched: `app_theme_test.dart`, `app_theme_visual_test.dart`,
  `app_responsive_test.dart`, `dashboard_shell_test.dart`,
  `app_adaptive_navigation_test.dart`, `shell_unification_test.dart`,
  `shared_components_test.dart`, `shared_primitives_test.dart`,
  `shared_components_visual_test.dart` + every app suite.
- Goldens shift only if a frozen value changed or scale-fix altered a pixel —
  regenerate per screen with documented diffs; never bulk-update.
- Text-scale removal must not alter 1.0× rendering semantics.
- No business behavior, persistence, sync, auth or navigation touched.

## J. Testing requirements

- `melos run analyze`; `melos run test:core`; `melos run test:auth`; the four
  app suites (`test:staff|owner|customer|crm`).
- New unit tests (`shared_core/test/`):
  - dark/light **parity test** walking component themes + resolved color roles;
  - token additions exist; legacy aliases resolve to the same colors;
  - reduced-motion resolver collapses durations under `disableAnimations: true`;
  - `AppTypography.forLocale` switches family stack + line height with a stub.
- New real-context layout smoke tests per H3 (four apps + auth).
- Contrast verification documented (sampled pairs, both brightnesses).

## J2. Visual quality gates (mandatory)

Static analysis and widget tests alone are **not** proof of design quality.
This phase is not complete until all of the following evidence exists:

1. **Rendered review** — run all four apps and visually review one
   representative screen per app (advisor home, owner dashboard, customer home,
   CRM shell) + `LoginView` after the token/theme change; no screen is signed
   off from code-reading alone.
2. **Form factors** — renders at mobile (≤430 px), tablet (600–1023 px) and
   desktop (≥1280 px) for each representative screen.
3. **Locales** — EN-LTR renders this phase (AR-RTL renders are impossible until
   Phase 02 and are explicitly deferred as a Phase 02 gate; the prototype's AR
   review from Phase 00 remains the visual reference).
4. **State matrix** — loading/empty/error states of the representative screens
   captured where they exist today; populated states use real fixture shapes.
5. **Interaction verification** — navigation, banners, dialogs still behave.
6. **Accessibility** — text scale 1.0 works end-to-end; 1.3× sampled on the
   representative screens (no overflow); focus visible; contrast sampled.
7. **No visual overflow** at 320 px on the representative screens.
8. **Evidence attached** — screenshot pack at `phases/reports/PHASE_01/`
   (`screen_width_state.png`) and/or regenerated goldens. Section K is unmet
   without this evidence.

## K. Acceptance criteria

1. `AppColors` exposes all §2.1 roles incl. additions with doc comments; zero
   removed names; legacy aliases resolve.
2. `AppTheme.light`/`dark` structural parity test passes; dark contrast sampled
   and documented.
3. `TextScaler.linear(0.85)` no longer exists in any `main.dart`
   (repo-search verifiable) and **no application-breaking layout regression
   remains**: every app's suite + H3 smoke tests pass at default scale; in-phase
   fixes documented; the residual list contains only non-breaking polish items.
4. `AppTypography.forLocale` tested with stub family; Arabic font wiring ready
   for Phase 02 with zero call-site work.
5. Reduced-motion resolver works and shared widgets use it.
6. `melos run analyze` + six suites green; goldens intentional and documented.
7. Public API preservation contract (§C2) holds: no signature changes outside
   the additive table; any change recorded.
8. Visual quality gates (J2) evidence attached.

## L. Deliverables

- Token/theme changes with before→after diff summary per frozen decision.
- Test evidence: analyze, six suites, parity/typography/motion tests, H3 smoke
  tests, per-app scale-removal evidence.
- `phases/reports/PHASE_01/scale_polish_list.md` (non-breaking residuals only).
- Screenshot pack `phases/reports/PHASE_01/`.
- Known limitations (dark not product-exposed; Arabic font asset pending 02;
  feature-phase 1.3× audits pending).
- Any token gaps discovered for 03A/03B/04.

## M. Completion gate

Stop after this phase. Do not begin Phase 02 until explicitly instructed.
