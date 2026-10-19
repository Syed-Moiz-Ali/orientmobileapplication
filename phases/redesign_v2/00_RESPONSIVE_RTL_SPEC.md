# 00 — Responsive Breakpoint & Bilingual RTL Specification

**Document ID:** `phases/redesign_v2/00_RESPONSIVE_RTL_SPEC.md`  
**Target Coverage:** Mobile (320–599px), Tablet (600–1023px), Desktop/Web (≥1024px)  
**Localization:** 100% English (LTR) & Arabic (RTL) Parity  
**Status:** FROZEN RESPONSIVE & RTL STANDARD  

---

## 1. Responsive Viewport Breakpoint Hierarchy

Every newly designed screen must render intentionally across three core breakpoint categories without layout breaking or stretched phone syndrome:

```
┌────────────────────────────────────────────────────────────────────────┐
│                     RESPONSIVE BREAKPOINT TAXONOMY                     │
├────────────────────┬───────────────┬───────────────────────────────────┤
│ Breakpoint Class   │ Width Range   │ Structural Composition Strategy   │
├────────────────────┼───────────────┼───────────────────────────────────┤
│ Compact Mobile     │ 320 – 599 px  │ Single-column vertical stream,    │
│                    │ (390px prime) │ touch-optimized bottom docks,     │
│                    │               │ modal bottom sheets, full cards   │
├────────────────────┼───────────────┼───────────────────────────────────┤
│ Adaptive Tablet    │ 600 – 1023 px │ 2-column balanced split layouts,  │
│                    │ (768px prime) │ master-detail panes, contextual   │
│                    │               │ side drawers, expanded grids      │
├────────────────────┼───────────────┼───────────────────────────────────┤
│ Desktop Workspace  │ ≥ 1024 px     │ Multi-pane command centers,       │
│                    │ (1280px prime)│ fixed left navigation rail, dense │
│                    │               │ sortable data tables, dialogs     │
└────────────────────┴───────────────┴───────────────────────────────────┘
```

### 1.1 Mobile Layout Rules (320 – 599 px)
- **Viewport Constraints:** Max content width bounded to `480px` when viewed on wider mobile viewports.
- **Horizontal Rows:** All text inside horizontal `Row` widgets must be wrapped in `Expanded` or `Flexible` with `TextOverflow.ellipsis` to prevent `RenderFlex overflow` on narrow 320px–360px devices.
- **Actions:** Primary contextual actions anchored to a bottom `AppActionBar` floating above the operating system safe area.
- **Sheets:** Complex options, filters, and pickers rendered as draggable modal bottom sheets.

### 1.2 Tablet Layout Rules (600 – 1023 px)
- **Master-Detail Splitting:** Lists and details presented as a side-by-side 40/60 split pane (e.g. Job Cards on left, Job Inspection details on right).
- **Metric Grids:** 2-column or 3-column metric grids instead of horizontal carousels.
- **Dialogs:** Modal sheets automatically transform into centered floating dialog cards with max width `540px`.

### 1.3 Desktop Workspace Rules (≥ 1024 px)
- **Navigation:** Persistent left navigation rail (collapsible between 72px icon rail and 240px expanded sidebar).
- **Data Presentation:** Mobile card streams transform into high-density, sortable, paginated data tables with sticky column headers and row hover highlights.
- **Max Canvas Width:** Main workspace canvas constrained to `1440px` with centered alignment on ultra-wide monitors.
- **Keyboard Shortcuts:** Support for `Cmd/Ctrl+K` (global search), `Esc` (dismiss modal), and `Enter` (form submission).

---

## 2. Bilingual English (LTR) & Arabic (RTL) Implementation Rules

The application must support complete visual parity between English and Arabic from day one.

### 2.1 Text Alignment & Mirroring
- **Layout Mirroring:** In RTL mode, all start/end paddings, leading/trailing icons, and column alignments automatically invert. Use `EdgeInsetsDirectional` rather than `EdgeInsets.only(left/right)`.
- **Directional Chevrons:** Navigation chevrons (`chevron_right` in English) must mirror (`chevron_left` in Arabic) using `DirectionalIcon`.
- **Typography Switching:**
  - English active: Apply **Plus Jakarta Sans** font family.
  - Arabic active: Apply **IBM Plex Sans Arabic** font family. Arabic line-heights use a single frozen **`×1.05` multiplier** (`AppTypography.arabicLineHeightScale`) applied to each Latin role height — e.g. Heading 1 `1.25 → 1.3125`, Body `1.4 → 1.47`. This is the authoritative rule; the earlier `1.3`–`1.5` figures were pre-multiplier absolute role heights, not a second multiplier.

### 2.2 Critical Non-Mirroring Exceptions (Strict Requirements)
The following elements **MUST NOT BE MIRRORED** in Arabic RTL mode:
1. **Vehicle Spatial Damage Maps:** The physical geometry of the vehicle (Front, Rear, Left, Right) must reflect the physical car, not the reading direction. The driver side of the car remains the driver side.
2. **License Plates:** UAE and regional vehicle plates maintain their standardized format (e.g. `DXB • M 84920`).
3. **Vehicle Identification Numbers (VIN):** 17-character VIN strings are always rendered LTR in monospace font.
4. **Phone Numbers & International Country Codes:** Phone numbers (e.g. `+971 50 847 2910`) must always be formatted LTR.
5. **Technical Metric Units:** Tabular numbers and units (`AED 48,250.00`, `7.2 mm`, `60,000 KM`) retain mathematical and currency ordering.
6. **Progress Timelines:** Numeric step sequences (`1 -> 2 -> 3 -> 4`) follow chronological progression.
