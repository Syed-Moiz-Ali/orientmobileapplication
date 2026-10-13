# 00 — Design System Specification (Design Authority)

Every phase **must** implement this specification. Where a phase needs something
this document does not define, the primitive is added to `packages/shared_core`
first and this document is updated in the same phase (see README §8).

Canonical source of truth in code:
`packages/shared_core/lib/src/theme/*` and `packages/shared_core/lib/src/widgets/*`.

**Related authority documents:**

- `00_VISUAL_DIRECTION.md` — the Phase 00 review brief and signed decision log.
  Its frozen values are the required inputs for Phases 01 and 03A/03B; where it
  amended a value in this spec, the frozen value wins.
- Every implementation phase carries a **J2 Visual Quality Gates** section:
  rendered review, three form factors, EN/AR, state matrix, no overflow,
  screenshot/golden evidence. Passing static analysis and widget tests alone is
  never proof of design quality.

---

## 1. Product design vision (one paragraph)

Orient Workshop OS is a calm, precise, information-first workshop operating
system. Cobalt is action, navy is emphasis, neutrals are the stage, semantic
colors carry meaning only. One card grammar, one navigation language, one
bilingual behavior across Staff, Owner, Customer and CRM apps. Phones feel
comfortable, tablets feel organized, desktop feels like a professional back
office — and every screen is equally correct in English and Arabic.

---

## 2. Color system

### 2.1 Canonical tokens (extend, do not replace)

All existing tokens in `app_colors.dart` remain valid. Phase 01 adds the
following missing roles and fixes the one weakness (no true dark parity map):

| Role | Token | Value (light) | Usage |
|---|---|---|---|
| Canvas | `canvas` | `#F5F7FB` | App/page background |
| Surface | `surface` | `#FFFFFF` | Cards, sheets, dialogs, bars |
| Surface subtle | `surfaceSubtle` | `#F8FAFC` | Nested rows, quiet zones |
| Surface sunken | `surfaceSunken` | `#F0F3F8` | Input wells, inactive slots |
| Surface strong | `surfaceStrong` / `navy` | `#14213D` | Hero/telemetry panels |
| Navy raised | `navySurfaceRaised` | `#1C2C50` | Cards on navy |
| Text primary | `textPrimary` | `#111827` | Titles, values |
| Text secondary | `textSecondary` | `#394150` | Body |
| Text muted | `textMuted` | `#677182` | Metadata, captions |
| Text disabled | `textDisabled` | `#9AA4B2` | Disabled/placeholder |
| Text inverse | `textInverse` | `#FFFFFF` | On navy/cobalt |
| Border subtle | `borderSubtle` | `#F0F3F8` | Internal dividers |
| Border default | `borderDefault` | `#E5EAF1` | Cards, inputs, bars |
| Border strong | `borderStrong` | `#CCD6E2` | Focused/active emphasis |
| Primary | `primary` | `#3157D5` | Actions, selection |
| Primary hover | `primaryHover` | `#2848B8` | Desktop hover |
| Primary pressed | `primaryPressed` | `#203B9E` | Pressed |
| Primary subtle | `primarySubtle` | `#EEF3FF` | Tint backgrounds |
| Primary border | `primaryBorder` | `#C8D6FF` | Tint borders |
| Selected | `selected` | `#E8EEFF` | Selected rows/chips |
| Hover | `hover` | `#F0F4FF` | Desktop hover rows |
| Success | `success/subtle/border` | `#0F8B5F` / `#E9F7F1` / `#B9E5D0` | Completed, paid, verified |
| Warning | `warning/subtle/border` | `#E09A1F` / `#FFF8E8` / `#F3D18B` | Waiting, attention |
| Danger | `danger/subtle/border` | `#D92D43` / `#FFF1F3` / `#F8C7CE` | Destructive, failed, overdue |
| Info | `info/subtle/border` | `#6D5DF6` / `#F1F0FF` / `#D9D5FF` | Notices, scheduled |
| Focus ring | `focus` | `primary` | 2 px focus indicator (offset 2) |

**Phase 01 additions:** `overlayScrim` (`#0B1526` at 42 %), `shadow*` remain
from dimensions; `onNavySecondary` (`#AAB5C8`); chart series palette (6 values
derived from primary/navy/success/warning/info/accent, documented in the theme
file) for `fl_chart` + custom painters so owner/advisor/CRM charts share
encoding.

### 2.2 Usage rules

1. Semantic colors are never decorative; a green card means success state.
2. Navy `surfaceStrong` is the only high-emphasis surface; the max per screen is
   one hero region.
3. States are always encoded by ≥2 signals (icon/text + color) — never color alone.
4. Gradients are limited to `GradientBanner` (contextual headers) and the auth
   identity panel, both subtle (two brand-family stops max).
5. Dark theme tokens are defined in `AppTheme.dark` (parity map added in Phase
   01). Apps continue to ship `ThemeMode.light` by default; dark must compile,
   pass widget tests, and render correctly when enabled.

---

## 3. Typography

### 3.1 Families

| Role | Family | Notes |
|---|---|---|
| Latin (canonical) | Plus Jakarta Sans (bundled in `shared_core/assets/fonts/plus_jakarta_sans/`) | All existing roles |
| Arabic | **IBM Plex Sans Arabic** (added Phase 02 under `shared_core/assets/fonts/`) | Weights 400/500/600/700; registered as a font family and applied via `TextStyle.fontFamilyFallback` when locale is Arabic, or an explicit locale-aware typography setter |
| Numeric/data | tabular figures of the active family (`FontFeature.tabularFigures()`) via `metric`/`mono*` roles | Never proportional digits in tables |

### 3.2 Role scale (existing `AppTextStyles`, binding)

| Role | Size/Weight | Usage |
|---|---|---|
| `displayLarge` 34/800 | Auth identity, hero numbers |
| `displayMedium` 28/700 | Big KPI numbers (single instance) |
| `displaySmall` 22/700 | Rare |
| `pageTitle` 22/700 | Page/app-bar titles |
| `sectionTitle` 18/700 | Section headers, sheet titles |
| `cardTitle` 15/600 | Entity titles in rows/cards |
| `bodyStrong` 14/600 | Emphasized values |
| `body` 14/400 | Default copy |
| `bodySmall` 13/400 | Supporting copy |
| `label` 13/600 | Form labels, controls |
| `eyebrow` 11/700 +0.8 | Section kickers (Latin only; Arabic: no tracking, no case) |
| `metadata` 12/500 | Timestamps, IDs, VIN |
| `caption` 12/400 | Helper text |
| `tableHeader` 12/700 | Column headers |
| `metric` 26/800 tabular | KPI values |
| `button` 14/600 | All buttons |
| `mono*` 13 tabular | Plates, money, odometers, codes |

### 3.3 Rules

- No new font sizes: pick the nearest role; a new role requires a spec update.
- Arabic line-height multiplier ≈ 1.05× of the Latin value; Arabic never gets
  letter-spacing or `toUpperCase()`.
- Latin/English technical identifiers (VIN, SKU, email, plate numbers) stay in
  the Latin family with the mono/tabular treatment in both locales.
- Text must survive 1.0–1.3× system scale gracefully (0.85 lock removed Phase
  01; layouts verified to at least 1.3× in Phase 20, 1.6× in shared components).

---

## 4. Spacing, radii, elevation

- **Spacing**: 4-pt grid — `s4 s6 s8 s10 s12 s14 s16 s18 s20 s24 s28 s32 s40 s48 s64`.
  Semantic helpers: `screenGutterCompact 16 / Medium 24 / Expanded 32`,
  `sectionGap 24`, `cardGap 16`, `cardPaddingCompact/Regular/Spacious`.
- **Radii**: semantic only — `radiusXs 4` (badges) · `radiusSm 6` (tags/chips) ·
  `radiusControl 8` (segmented/controls) · `radiusInput 10` · `radiusButton 10` ·
  `radiusCard 12` · `radiusPanel 16` (hero/bento) · `radiusDialog 18` ·
  `radiusSheet 22` · `radiusPill 999`. Raw numeric aliases exist for
  compatibility but new code uses semantic names.
- **Elevation** (subtle, no colored glow):
  - Level 0 — flat: cards on canvas, borders do the work (`borderDefault`).
  - Level 1 — `shadowSurface` (bars, sticky footers).
  - Level 2 — `shadowCard` (popovers, raised cards, FAB).
  - Level 3 — `shadowModal` (dialogs, sheets).
  - Navy surfaces use `shadowNavy`.
- **Touch targets**: ≥48 px everywhere (`touchTarget`). Interactive rows ≥48 px
  even when visually dense.

---

## 5. Breakpoints and layout (binding summary)

Full detail in `00_RESPONSIVE_STRATEGY.md`. Binding rules:

- Window classes: **compact ≤599 · medium 600–1023 · expanded 1024–1439 · large ≥1440**.
- Phone = 1 content column; padding per `AppResponsive.pagePadding`.
- Tablet = rail navigation + up to 2 content columns; master-detail preferred for
  list→detail workflows.
- Desktop = extended rail/sidebar (224 px) + content capped at
  `contentStandard 1180` / `contentWide 1320`; three-pane layouts for
  builder flows (catalog | editor | summary).
- No screen may horizontally overflow at 320 px width.
- Forms cap at 420–460 px (`formMaxWidth`); dialogs 520–600 px; sheets become
  centered dialogs ≥600 px (`showAppModalSheet` behavior).

---

## 6. Navigation patterns

1. **Workspace shell** — `DashboardShell` + `AppAdaptiveNavigationFrame`:
   - compact → `AppBottomNavigation` (≤5 destinations; overflow sheet beyond);
   - medium/expanded/large → `AppNavigationRail` (76/92/92 px, extended 224 px at
     `large`) with brand mark header and profile/account footer.
2. **Pushed task pages** — `AppTopBar` (back + title + trailing actions) inside
   the same canvas; no nested shells.
3. **Sheets** — quick context: profile menu, notifications, contact actions,
   filters (mobile), confirmations → `showAppModalSheet`/dialogs.
4. **Selection language** — cobalt 12 % tint + filled selected icon + heavier
   label + optional badge; identical in bar, rail, drawer, and any segmented
   control.
5. **Breadcrumbs (desktop only)** — for the owner sub-pages and CRM where depth
   ≥2 (`Dashboard / Inventory / PO #123`), rendered via `AppPageHeader`.
6. **Back behavior** — predictable pop; system back before exit with
   `ExitConfirmationWrapper` only at workspace root.
7. Deep links and route contracts remain exactly as today (README §9).

---

## 7. Component registry (specification)

The full component library lives in `shared_core/lib/src/widgets/` and is
consolidated in Phases 03A/03B. Each component defines: variants, sizes, states
(default/hover/pressed/focus/disabled/loading/error where applicable), RTL
behavior, accessibility semantics, and responsive behavior.

| Component | Variants/spec | Usage rules |
|---|---|---|
| `AppButton` (primary/secondary/tertiary/danger/quietIcon/compactInline) + `PrimaryButton`/`SecondaryButton` | min 48 px height; loading spinner replaces label; icons 20 px; RTL icon flip | One primary action per view region; destructive uses danger + confirmation |
| `AppTextField` / `AuthTextField` | label above; helper/error below; icon slots; 52 px control (48 compact) | Labels above inputs, never floating-only |
| `AppSearchField` | leading search icon, clear button, debounce hook | One per list; replaces all ad-hoc search fields |
| `AppDropdownButton` + selection sheets | 52 px control; searchable list sheet on mobile; menu on desktop | Selection sheets get title + search when >8 options |
| Segmented control (`SegmentedButton` styled via theme) | 2–5 options | Use for period/mode switches, not navigation |
| `AppCard` | variants: default, subtle, strong(navy), tinted (semantic) | One level of nesting max; no decorative containers |
| `AppRecordRow` | leading avatar/icon, title, 1–2 metadata lines, trailing (value/chevron/badge) | The single row grammar for every list |
| `AppKpiCard` | compact/standard/wide; trend up/down/flat; semantic states | Tappable → its source list; never decorative |
| `StatusPill` | neutral/info/success/warning/danger + dot variant; text from `AppStatusLabels` (localized in Phase 02) | Status text localized; pill never the only status cue |
| `AppInfoPanel` | neutral/primary/success/warning/danger/navy | Notices, offline/queued explanations |
| `AppStepProgress` (`AppProgressStep`) | horizontal steps with current/complete; RTL mirrors | Multi-step flows (booking, intake, estimate, feedback) |
| `AppSkeleton` | text/card/list/chart shapes with pulse; reduced-motion → static | First load only; mirrors final layout |
| `EmptyState` | icon, title, body, optional primary action | Every list needs one; distinguish empty vs no-match vs error |
| `ErrorView` / `EmptyState.error` | message + retry | Retry must actually re-run the fetch |
| `AppBottomSheet` (`showAppModalSheet`) | drag handle; bounded 560 px on ≥600 px; centered dialog ≥600 | Forms shorter than a screen; destructive confirmations use dialogs |
| `AppConfirmationDialog` | title, body, confirm/cancel; destructive variant | Required for: cancel booking, remove vehicle, delete lead, logout with pending sync, QC reject |
| `AppPageHeader` | eyebrow/title/subtitle/leading/actions; breadcrumb slot | Standard page heading in every pushed page |
| `AppTopBar` | back + title + trailing; `CustomerTopBar` variant | Min 60 px; no custom app bars |
| `AppPageFrame` | responsive gutters + max width (contentStandard/Wide) | Every pushed page body |
| `AppActionBar` | sticky bottom primary/secondary; stacks on compact | One per screen maximum |
| `AppFormSection`/`AppFormField`/`AppFormPanel`/`AppDateSelectorShell`/`AppMediaUploadShell` | section header + grouped fields; date shell opens real picker; upload shell shows local preview/pending state | All forms use these; no bespoke form scaffolding |
| `AppLinearProgress` | determinate/indeterminate, semantic colors | Step completion, sync progress |
| `GradientBanner` | contextual header with optional pills | Max one per page; owner/CRM dashboard headers |
| `NotificationBell` | count/dot badge; opens inbox sheet | Staff + owner + CRM |
| `UserAvatar` | initials, sizes 28–72, optional border/status dot | Identity blocks |
| `OfflineBanner` | connectivity-driven; honest queue copy | Provided by `DashboardShell`; never duplicated |
| `MarkdownText` | **bold**, *italic*, bullets | Descriptions/notes only |
| Charts | `fl_chart` styled from the chart palette + owner/CRM painters refactored to the same palette/typography | Axis labels localized; values use tabular figures |

Deprecated after Phases 03A/03B (must not be used in new code): legacy advisor kit
(`inspection_widgets.dart` etc.), `customer_surface_panel.dart` ad-hoc grouping,
`crm_constants.dart` palette, `owner_shimmer_skeletons.dart` custom shimmer
(replaced by `AppSkeleton` patterns), ad-hoc `MaterialPageRoute` pushes
(use go_router).

---

## 8. Accessibility requirements (binding)

1. No forced text-scale overrides; remove `TextScaler.linear(0.85)` from all
   `main.dart` files (Phase 01) and verify layouts at 1.0–1.3×.
2. Contrast: body text ≥ 4.5:1, large text ≥ 3:1 against its surface — verify for
   text-on-navy, text-muted-on-canvas, and semantic pills.
3. Every icon-only control has a `tooltip`/`semanticsLabel`; every interactive
   row is a semantic button with a meaningful label; selected states use
   `Semantics(selected: true)`.
4. Focus: visible 2 px focus ring (`focusColor` from theme); logical focus
   traversal in forms and dialogs (`FocusTraversalGroup` exists in shell).
5. Touch targets ≥ 48 px; spacing between adjacent targets ≥ 8 px.
6. Motion respects `MediaQuery.disableAnimations`.
7. Dialogs/sheets are dismissible with back/Escape; confirmations put the safest
   choice under the thumb.
8. Screen-reader copy is localized (Phase 02 covers semantics strings).

---

## 9. Localization & RTL rules (binding summary)

Full detail: `00_LOCALIZATION_RTL_STRATEGY.md`. Binding per-screen rules:

1. Zero hard-coded user-visible strings in new/modified code — all strings from
   ARB (`lib/l10n/app_en.arb`, `app_ar.arb` in the owning package/app) or
   `shared_core` localization (for shared widgets).
2. Use `EdgeInsetsDirectional`, `AlignmentDirectional`, `start/end` semantics —
   never raw left/right padding for layout direction.
3. Directional icons flip in RTL: back/forward, chevrons, arrows, undo, timeline
   direction; non-directional icons never flip (clock, person, document).
4. Numbers/dates/currency via `intl` with the active locale; currency AED by
   default; keep Latin digits for identifiers (VIN, plate) but localize
   thousands separators per locale rules where the value is a quantity.
5. Components must not clip on the longer language; test both locales at compact
   width before marking a screen done.
6. Layout direction mirrors the workspace chrome: rail swaps sides, bottom nav
   order mirrors, sheets' handles and action bars mirror, timelines flow
   start→end.

---

## 10. Interaction patterns

- **Optimistic + truthful**: UI updates immediately where sync engine supports
  retry; queued items show "Not sent yet" until confirmed (never fake success).
- **Confirmations**: destructive actions + actions losing entered data.
- **Hover (desktop)**: rows and buttons get `hover` tint + pointer; kebab menus
  for secondary row actions.
- **Keyboard (desktop/web)**: tab order logical; Enter activates primary; Escape
  closes modal; search fields focusable with `/` where already supported.
- **Pull-to-refresh** on every scrollable list surface with remote data.
- **Long-press**: only for destructive/contextual mobile menus already supported.
- **Toasts (SnackBars)**: single-line outcome + optional action (Undo/Retry);
  never used for errors requiring decisions (use panels/dialogs).
- **Refresh cadence**: badges/timers refresh in place; no full-screen flash.

---

## 11. Motion guidelines

Use only `AppMotion`: `instant 100` (state snaps), `fast 160` (hover, chip,
badge), `standard 220` (sheets, page transitions, list insert), `emphasized 280`
(hero/step transitions). Curves: `enter (easeOutCubic)`, `exit (easeInCubic)`,
`standardCurve (easeInOutCubic)`. Nothing animates longer than 280 ms. Loading
shimmer is exempt but must pause under reduced-motion.

---

## 12. Form UX guidelines

1. Sections with plain-language titles; one topic per section.
2. Label above field; required fields marked with a single consistent marker;
   optional fields labeled "Optional" rather than asterisks-everywhere.
3. Validate on blur + on submit; inline error text replaces helper text; error
   borders use `danger`.
4. Multi-step flows: `AppStepProgress` visible, back preserves data, final step
   summaries what will be submitted.
5. Sticky primary action (`AppActionBar`); disabled while invalid or submitting;
   loading state inside the button.
6. Discard protection: if a form has unsaved changes, back triggers a
   confirmation dialog.
7. Long forms (intake, estimate, booking) persist drafts via existing Hive
   storage where the repository already supports it — never introduce new
   backend behavior.

---

## 13. Data-density guidelines

| Context | Compact | Medium | Expanded+ |
|---|---|---|---|
| Tables | record cards (no horizontal scroll) | card rows with columns | true table, 36–44 px rows, sortable headers |
| Lists | 1 column, 12 px gaps | 2 columns for card grids | 3–4 columns or list+detail |
| KPIs | 2 per row | 2–4 per row | 4 per row max |
| Charts | single column | 1–2 columns | 2 columns side-by-side, max 3 series |
| Money | tabular, right-aligned (mirrors LTR/RTL start=end rule per locale numerals) | | column right-aligned |

Bottom padding always clears bottom nav / FAB / action bar + safe area.

---

## 14. Screen templates

**T1 Workspace tab** — page header (title + context) → attention/highlight region
→ content list/grid → secondary modules. Refresh + skeleton + empty/error.

**T2 Pushed list page** — `AppTopBar` → search/filter row → list (record rows) →
empty/error/retry. Desktop: table + kebab actions.

**T3 Detail page** — `AppTopBar` → identity header (title, status pill, key
metadata, primary action) → sections → history → sticky action bar when actions
exist.

**T4 Form page** — `AppTopBar` (discard guard) → grouped `AppFormSection`s →
sticky `AppActionBar`. Desktop: two-pane with live summary/preview where the
workflow allows.

**T5 Wizard** — `AppTopBar` → `AppStepProgress` → step body → sticky back/next.
Desktop: step content left, live summary right.

**T6 Sheet form** — drag handle, title, scrollable body, sticky confirm; bounded
max width 560 on large screens.

**T7 Dashboard** — header banner (optional navy/gradient) → KPI row → attention
queue → analytics → quick actions.

**T8 Auth** — `AuthShell`: identity panel + focused form; responsive split at
≥900 px.

---

## 15. Consistency rules (non-negotiable)

1. No hard-coded colors/radii/font sizes/durations outside token files.
2. No new page-local containers when `AppCard`/`AppInfoPanel`/`AppSurfacePanel`
   equivalents exist.
3. Every list has: skeleton (first load), empty state, error+retry, pull-to-refresh.
4. Every money/quantity column uses tabular figures and a consistent alignment.
5. Every status uses `StatusPill` + localized status labels.
6. Every navigation destination has icon + label; badges share one component.
7. Both locales + 3 form factors verified before a screen is "done".

---

## 16. Anti-patterns (reject in review)

- Spinner-only full pages where skeletons are possible; silent failures.
- Chevrons/links that do not navigate; dead affordances.
- Mixed icon families or non-rounded icons in new work.
- One-card-per-field on desktop; full-width forms on widescreen.
- Bottom sheets on desktop where a dialog/menu is correct (and vice versa).
- Left-only `EdgeInsets`, `Container(color:)` used as page background, manual
  `Directionality` overrides.
- English pluralization built by string concatenation (`'$n jobs'`) — use ARB
  plurals.
- Any UI that requires reading a raw ID/JSON to understand state.

---

## 17. Definition of Done (applies to every screen in every phase)

1. Implemented with shared primitives; no new hand-rolled duplicates.
2. All strings localized (EN + AR) — none hard-coded.
3. RTL mirrored correctly including directional icons and alignment.
4. Responsive: correct at 320 px, 390–430 px, 600–1023 px, 1024–1439 px, ≥1440 px.
5. Loading (skeleton), empty, error+retry, and offline/queued states where
   applicable — no silent catch.
6. Accessibility: targets ≥48 px, semantics labels localized, focus visible,
   contrast verified, text scale 1.3× clean.
7. Motion from tokens only; reduced-motion respected.
8. Existing behavior preserved: routes, extras, providers, permissions, offline.
9. `melos run analyze` + the owning app's `melos run test:<app>` pass; goldens
   updated only for this screen's intentional change.
10. Phase Deliverable Report updated with files touched, tests run, and known
    limitations.
