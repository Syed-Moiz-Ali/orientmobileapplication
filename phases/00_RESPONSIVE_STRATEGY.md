# 00 — Responsive Strategy (Mobile · Tablet · Web/Desktop)

The foundation already exists in `packages/shared_core/lib/src/layout/`
(`app_responsive.dart`, `app_adaptive_navigation.dart`). This document makes the
strategy binding for every phase: what each form factor is, how screens adapt,
and how adaptation is verified. Nothing in the strategy requires a new
breakpoint engine — Phase 04 refines and completes it.

---

## 1. Breakpoint model (binding)

Two orthogonal classifications, both derived from **available layout width**
(never device names):

**Window classes** (layout decisions — `AppWindowClass`):

| Class | Width | Navigation | Content columns | Density |
|---|---|---|---|---|
| `compact` | ≤ 599 | Bottom bar (≤5 destinations, overflow sheet) | 1 | comfortable, 48 px controls |
| `medium` | 600–1023 | Rail 76 px (icon) | 1–2 | 2 columns for card grids |
| `expanded` | 1024–1439 | Rail 92 px | up to 3 | tables allowed, side panels |
| `large` | ≥ 1440 | Extended rail 224 px | up to 4 / split-pane | dense tables, 3-pane builders |

**Device classes** (fine-tuning — `AppDeviceClass`): `smallMobile <360 ·
mobile <430 · largeMobile <600 · tablet <1024 · desktop <1600 · largeDesktop
≥1600`. Used for gutter/typography/density nuance, never for structural rewrites.

Rules:
1. Structural decisions come from `AppWindowClass` via `context.adaptive`.
2. New code must use `context.adaptive`/`AppResponsivePage` — not raw
   `MediaQuery.width > X` checks.
3. Breakpoints are stable; no phase may invent new ones.
4. Short viewports: `isShort` (<680 px height) + `keyboardOpen` flip focused
   flows to top-aligned (`focusedFlowAlignment`).
5. Orientation: phones remain single column in landscape (content scrolls);
   tablets/desktop reflow using width, which naturally covers landscape.

---

## 2. Per-form-factor experience

### 2.1 Small & large phones (compact)
- One-column everything; no horizontal scrolling tables (record cards instead).
- Bottom navigation; overflow beyond 5 destinations via the existing "More" sheet.
- Forms: single column, sticky action bar clears keyboard; long forms scroll.
- Detail screens: identity header collapses on scroll; actions in sticky bar or
  overflow menu, not floating clusters.
- Sheets for filters/quick actions; full pages for multi-step tasks.
- Long-content lists: `ListView` with skeletons; pull-to-refresh.
- No element <48 px tall; safe areas respected; text at 1.0–1.3× never overflows
  (ellipsis with tooltip on non-essential overflow only).

### 2.2 Tablets (medium)
- Rail navigation; two-column layouts where the workflow allows:
  - list + detail (master–detail) for job cards, bookings, leads, inventory;
  - form + live summary for intake, estimate builder, booking wizard.
- Card grids 2-up; KPI grids 4-up.
- Landscape and portrait both supported; master–detail degrades to stacked
  navigation below 600 px.
- Sheets become centered bounded dialogs (≥600 px, max 560–600 px wide) — the
  existing `showAppModalSheet` behavior.

### 2.3 Web / desktop (expanded & large)
- Sidebar / extended rail with brand header and account footer (exists).
- Content is capped: `contentStandard 1180` default, `contentWide 1320` for
  dashboards; forms capped at `formMaxWidth` (420–460 px) — never full-width.
- Real data tables (36–44 px rows, sortable header, hover, kebab menus, bulk
  selection only where providers already support it).
- Three-pane builders where justified: catalog/options | editor | summary
  (estimate builder, intake on large screens).
- Breadcrumbs on depth ≥2 pages (owner sub-pages, CRM sections) via
  `AppPageHeader`.
- Keyboard: tab traversal, Enter primary, Esc close, visible focus ring,
  `/` focuses search where a list owns the page.
- Hover states from `hover` token; cursor changes on all interactive elements.
- Widescreen space is used for **context**, not stretching: side panels, preview,
  activity, related records.

### 2.4 Adaptive behavior rules (centralized)
- `AppResponsivePage` handles padding + max-width; `AppAdaptiveGrid` handles
  KPI/card grids; `AppSplitView` handles master–detail stacking; prefer these
  over bespoke `LayoutBuilder`.
- Components that change structure must be tested at 320/390/600/768/1024/1280/1440.
- Bottom padding always clears: bottom nav (compact), FAB, sticky action bars,
  keyboard insets, safe area.
- Overflow prevention: text uses ellipsis/maxLines deliberately; rows flex
  (no fixed widths on translated text); charts get bounded heights per class.
- `navigationRailWidth` and `extendNavigationRail` come from `AppAdaptiveSpec`;
  do not hard-code rail widths.

---

## 3. What must NOT change (compatibility)

- Route paths/contracts, provider shapes, sync behavior, permission gating —
  responsive work is presentation-only.
- Existing golden tests: only regenerated in the phase that intentionally
  redesigns the screen (then re-verified at compact + expanded widths).
- `DashboardShell` responsibilities (offline banner, system bar, exit confirm)
  stay centralized.

---

## 4. Phase expectations (binding checklist)

Every phase file's section E repeats this checklist in context. Universal rules:

1. **Mobile (compact)** — exact layout described; overflow tested at 320 px.
2. **Tablet (medium)** — column structure, rail behavior, any master–detail.
3. **Web/desktop (expanded+)** — max widths, tables vs cards, hover/keyboard.
4. **Orientation + short viewport** — keyboard behavior for forms.
5. **Text scale** — 1.0 and 1.3× verified (1.6× for shared primitives).
6. **RTL parity** — every layout statement holds in mirrored direction.

---

## 4b. Rendered verification (binding)

Width tests in widget tests are necessary but not sufficient. Every phase must:

- **render the real app** (or the Phase 00 prototype for pre-production
  screens) at the form factors its screens are assigned,
- capture EN-LTR and AR-RTL renders,
- visually review the state matrix (loading/empty/populated/error/disabled),
- attach the evidence pack under `phases/reports/PHASE_XX/` (see each phase's
  J2 Visual Quality Gates section).

A phase whose layouts are only proven by `tester.view.physicalSize` assertions is
incomplete.

## 5. Verification matrix (used by Phase 20 and per-phase reports)

| Width | Target | What is checked |
|---|---|---|
| 320×640 | small phone | no horizontal overflow, tap targets, truncated copy |
| 390×844 | phone | primary flow usability, bottom nav, sheets |
| 430×932 | large phone | bottom nav overflow behavior, long labels |
| 600×960 | small tablet portrait | rail appears, 2-col grid, dialog sheets |
| 768×1024 | tablet | master–detail, landscape parity |
| 1024×768 | small laptop | tables, hover, no stretched forms |
| 1280×800 | desktop | content caps, extended rail, 3-pane builders |
| 1440×900+ | large desktop | breadcrumbs, density, max content width |

Representative testing (widget tests with `MediaQuery`/`LayoutBuilder` sizing or
`tester.view.physicalSize`) is required per phase for each redesigned screen at
minimum: 320, 390, 768, 1280 (+ native form factors of the app).
