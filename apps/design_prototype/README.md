# Design Prototype — Phase 00 Visual Design Validation

> **NOT SHIPPED.** This app is an isolated visual-validation prototype for the
> 2026 UI/UX redesign. It imports **no** production package, no production app
> imports it, and CI's four APK builds never reference it (they build
> `staff_app`, `owner_app`, `customer_app`, `crm_app` explicitly). It can be
> deleted at any time without residue.

> **PHASE 00 APPROVED (2026-10-13) — this prototype is now READ-ONLY.**
> The product owner approved the visual direction recorded in
> `phases/00_VISUAL_DIRECTION.md`. The `test/goldens/` baselines and the
> 299-test suite are **frozen**: do not regenerate goldens or change these
> screens without a recorded amendment in `00_VISUAL_DIRECTION.md` §3.
> Implementation continues in the production apps (Phases 01+); this
> prototype remains the rendered reference (re-run `flutter test` any time to
> verify the baselines).

## Purpose

Prove the "Precision Workshop OS" direction from `phases/00_REDESIGN_VISION.md`
and `phases/00_DESIGN_SYSTEM_SPEC.md` on six representative production screens
before any token rollout:

| # | Screen | Mirrors (read-only reference) |
|---|---|---|
| D1 | Owner Dashboard | `apps/owner_app/.../dashboard/*` (HeaderBanner, KpiGrid, JobCardRegisterCard, SalesTrend/SalesVsExpenses, QuickActions, adaptive nav) |
| D2 | Job Cards listing | `apps/owner_app/.../job_cards/*` (list + tile + filter chips) |
| D3 | Technician Job Detail | `apps/staff_app/.../technician/.../job_detail_sheet.dart` |
| D4 | Add Vehicle form | `apps/customer_app/.../add_vehicle_view.dart` + intake/lead form patterns |
| D5 | Login / Auth | `packages/shared_auth/.../login_view.dart` + `auth_surface.dart` |
| D6 | Advisor Inspection | `apps/staff_app/.../inspection_sheet_view.dart` + vehicle body-condition panel (real damage-map asset) |

## Run the interactive prototype (Flutter Web)

```powershell
# from the repository root
cd apps/design_prototype
flutter pub get
flutter run -d chrome --web-port 8090
```

Then open `http://localhost:8090`. The review console at the top switches:

- **screen** — the six prototype screens,
- **EN | ع** — token-switch language (LTR ⇄ RTL) with runtime re-layout,
- **Light | Dark** — theme variant,
- **width** — 360 / 390 / 430 / 600 / 768 / 1024 / 1280 / 1440 presets (Fit),
- **state** — per-screen state variants (loading / empty / error / invalid / delayed / complete / finding-sheet …),
- **Reset** — restore the screen's initial interaction state.

Native shells also work for motion review: `flutter run -d windows` /
`-d android`.

## Capture the visual pack (goldens)

```powershell
cd apps/design_prototype
flutter test test/visual_pack_test.dart --update-goldens   # first run / after changes
flutter test test/visual_pack_test.dart                    # verify
..\..\tools\capture_visual_pack.ps1                        # copy into phases/reports/PHASE_00/
```

The pack (`test/goldens/`) uses the naming scheme
`screen_width_locale_state[_dark].png` and covers 6 screens × 4 widths × EN/AR
plus every state variant at 390 px in both locales and dark-theme spot checks.

## Verification commands

```powershell
dart analyze                                # zero issues
flutter test                                # 244 tests: goldens (104), responsive/overflow (109), locale/RTL (10), interactions (21)
```

## Provisional design assets

- `lib/design/provisional_tokens.dart` — **PROVISIONAL — do not ship;**
  mirrors `00_DESIGN_SYSTEM_SPEC.md` §2–§4 (colors + dark parity map, type
  scale, spacing, radii, shadows, motion, chart palette). Review amendments are
  edited here first and recorded in `phases/00_VISUAL_DIRECTION.md`.
- `lib/l10n/provisional_strings.dart` — EN + AR copy authority for these six
  screens; Phase 02 copies the values into the real ARB files.
- Fonts: Plus Jakarta Sans (workspace asset copy) + IBM Plex Sans Arabic
  400/500/600/700 (SIL OFL) with the fallback stack
  `IBM Plex Sans Arabic → Noto Sans Arabic → system` documented in
  `prototype_theme.dart`.
- `assets/vehicle_map/advisor_car_top_mapped.svg` — byte copy of the real
  staff_app asset: the embedded base illustration is decoded at runtime and the
  25 interactive outlines are parsed from the byte copy of
  `advisor_car_top_mapping.json` (no SVG/path dependencies added).

## Component checklist (input for Phases 03A/03B)

Every prototype-only widget maps to a spec §7 component; ad-hoc patterns used
by the screens are justified here.

| Prototype widget | Spec component | Notes / findings |
|---|---|---|
| `ProtoCard` | `AppCard` (default/navy/tinted) | one radius (12) + hairline border; interactive variant adds hover |
| `ProtoSectionHeader` | `AppPageHeader` section role | eyebrow+title+trailing; eyebrow case-transforms in Latin only |
| `ProtoStatusPill` | `StatusPill` | dot+text+color; text ellipsizes inside flex — required for AR |
| `ProtoPlateChip` | new primitive (03B) | **add to catalog**: mono plate chip (used by D2/D3/D4) |
| `ProtoKpiTile` | `AppKpiCard` (compact/standard) | one navy hero variant; value uses metric role + FittedBox |
| `ProtoEmptyState` | `EmptyState` | title/body/action; distinct no-match copy lives in the calling screen |
| `ProtoErrorBanner` | `ErrorView` (inline variant) | **add "banner" variant** to 03B (list/board level, page level = `ErrorView`) |
| `ProtoInfoPanel` | `AppInfoPanel` | semantic tones incl. navy; used for offline/queued/notices |
| `ProtoSkeleton` | `AppSkeleton` | pulse; pauses under `MediaQuery.disableAnimations` |
| `ProtoSearchField` | `AppSearchField` | 48 px control, clear affordance |
| `ProtoFilterChip` | theme Chip / filter bar | selected = cobalt fill + check; never color-only |
| `ProtoActionTile` | new primitive (03A) | **add to catalog**: quick-action tile (D1's 12-tile grid) |
| `ProtoKeyValueRow` | `AppRecordRow` meta role | label/value pairs in summaries |
| `ProtoProgress` | `AppLinearProgress` | determinate; label below |
| `ProtoKebabMenu` | new primitive (03B) | **add to catalog**: kebab trailing menu for desktop tables |
| `ProtoNotificationBell` | `NotificationBell` | count badge; semantics label |
| `ProtoAvatar` | `UserAvatar` | initials; sizes 28–72 |
| `ProtoTopBar` | `AppTopBar` | back + title + subtitle + trailing; 60 px |
| `ProtoField` | `AppTextField` | label-above; Required/Optional marker; inline error; `ltrContent` flag = identifier policy for Phase 02's `AppTextField` |
| `ProtoDirIcon` | RTL helper | **adopt in shared_core** (03A): directional-icon flip helper |
| `ProtoWorkspaceNav` | `AppAdaptiveNavigationFrame` | bottom bar (compact) / rail (medium+) / extended (large); same selection vocabulary |
| `ProtoVehicleMap(+Loader)` | Phase 07B | prototype-local; production keeps `flutter_svg` + `path_drawing`. Loader caches decoded values + returns `SynchronousFuture` on cache hit |
| `showProtoSheet` | `showAppModalSheet` | bottom sheet < 600 px, centered 560 px dialog ≥ 600 px |
| Charts (`proto_charts.dart`) | 03B chart theme | mirrored x-axis in RTL, max 2 series, localized labels |

## Findings recorded for later phases

- Arabic line-heights (×1.05) need the slightly taller compact KPI tile (156 px)
  and must be re-verified for any fixed-height tile primitive in Phase 03A.
- Status pills must ellipsize (flex) or long Arabic statuses overflow dense
  table columns at 1024 px.
- Compact forms must stack field pairs; side-by-side pairs only ≥ 600 px.
- The vehicle outline (D6) is the canonical RTL exception: surrounding chrome
  mirrors, the car does not — implemented via an inner `Directionality(ltr)`
  and documented on-screen in Arabic.
- `flutter_localizations` (SDK-provided, not a pub.dev package) is the only
  dependency addition, needed for correct RTL + Material locale behavior.
