# 08 — Responsive Architecture & Arabic RTL Localization Strategy

**Document ID:** `phases/redesign_v2/discovery/08_RESPONSIVE_AND_RTL_STRATEGY.md`  
**Status:** DRAFT / PENDING PRODUCT OWNER REVIEW (Stage A Discovery)  
**Author:** Principal Product Designer, Systems Architect & Lead Flutter Engineer  

---

## 1. Responsive Architecture: Purpose-Built Form Factors

A professional 2026 application **does not merely stretch or shrink the same screen composition**. Mobile phones, tablets, and desktop workstations represent fundamentally different operational contexts, input modalities, and cognitive loads.

The table below outlines the structural transformations required across each breakpoint tier:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        RESPONSIVE BREAKPOINT TIERS                     │
├─────────────────────────┬──────────────────────┬───────────────────────┤
│ MOBILE (320px – 599px)  │ TABLET (600px–1023px)│ DESKTOP (≥ 1024px)    │
├─────────────────────────┼──────────────────────┼───────────────────────┤
│ • Single-column thumb   │ • Dual-pane split    │ • Multi-column dock   │
│   focus zone            │ • Adaptive navigation│ • Persistent rail     │
│ • Floating action dock  │   rail (78px)        │   (224px extended)    │
│ • Bottom modal sheets   │ • Master-detail list │ • High-density tables │
│ • Touch target ≥48-64px │ • 2-column cards     │ • Sticky sidebars     │
└─────────────────────────┴──────────────────────┴───────────────────────┘
```

---

### 1.1 Mobile Form Factor (320px – 599px)
- **Primary Input**: Single-hand thumb interaction, touch gestures, mobile camera, GPS.
- **Navigation Paradigm**: Compact bottom navigation bar with maximum 4–5 core destinations; secondary actions housed in a contextual floating action island or bottom sheet.
- **Surface Composition**: Single-column vertical flow; sticky bottom action bar with safe-area padding; modal bottom sheets for complex inputs (filter dialogs, date pickers, forms).
- **Extreme Small-Screen Defense (320px–360px)**:
  - Form fields that sit side-by-side on larger screens automatically stack vertically.
  - KPI cards compress into a swipeable carousel or 2x2 grid with auto-shrinking tabular figures to prevent horizontal overflows.
  - Tab titles truncate with graceful ellipsis or convert to iconography.

### 1.2 Tablet Form Factor (600px – 1023px)
- **Primary Input**: Two-handed touch, stylus (Apple Pencil / S-Pen for vehicle damage markup), detachable keyboard.
- **Navigation Paradigm**: Pinned left navigation rail (78px collapsed) with icon + label tooltips.
- **Surface Composition**:
  - **Portrait (600px–800px)**: 2-column adaptive card grids; split form layouts (Vehicle info on left, Customer info on right).
  - **Landscape (801px–1023px)**: Master-detail split view (e.g. Job Cards list on left 35%, selected Job Card workspace on right 65%). Modals transition from bottom sheets into centered, elevated dialogs.
- **Ergonomics**: Touch targets remain generous (≥48px); stylus-friendly canvas for digital signatures and vehicle damage drawings.

### 1.3 Desktop / Web Form Factor (1024px and Above)
- **Primary Input**: Mouse precision pointer, full keyboard shortcuts (`⌘K`, `Enter`, `Escape`, arrow key navigation).
- **Navigation Paradigm**: Expanded left navigation drawer (224px) with brand mark, user profile, role switcher, and quick-collapse button.
- **Surface Composition**:
  - **3-Pane Operational Command Center**: (1) Left navigation rail, (2) Central operational work area (tables, kanban boards, vehicle canvases), (3) Right-hand context inspector (customer profile, financial breakdown, activity audit log).
  - **High-Density Data Tables**: True sortable data tables with frozen identity columns (Vehicle Plate, Job Card #), sticky headers, and inline action buttons.
  - **Maximum Content Caps**: Fluid layouts with explicit max-content caps (e.g., forms capped at 760px; analytical dashboards fluid up to 1600px) to prevent unnatural stretching on ultra-wide monitors.

---

## 2. English & Arabic (RTL) Localization Strategy

Localization in Orient Redesign v2 is **treated as a first-class architectural requirement from Day One**, building upon the solid engineering foundations established in Phase 02.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        BIDIRECTIONAL UI RULES                          │
├──────────────────────────────────┬─────────────────────────────────────┤
│ WHAT MIRRORS AUTOMATICALLY       │ WHAT MUST NEVER MIRROR (EXCEPTIONS) │
├──────────────────────────────────┼─────────────────────────────────────┤
│ ✓ Text alignment & reading flow  │ ✗ Vehicle damage map & diagrams    │
│ ✓ Navigation bars & rails        │ ✗ License plate numbers & codes     │
│ ✓ Action buttons & back chevrons │ ✗ VIN (Vehicle Identification No.)  │
│ ✓ Progress bars & timeline steps │ ✗ Phone numbers (+971 50 ...)       │
│ ✓ Modal sheet slide-in direction │ ✗ Tabular financial numbers         │
└──────────────────────────────────┴─────────────────────────────────────┘
```

---

### 2.1 Typographic Scale & Font Pairing
- **Dual-Font System**:
  - **English (LTR)**: **Plus Jakarta Sans** / **Inter** — modern, geometric, crisp legibility.
  - **Arabic (RTL)**: **IBM Plex Sans Arabic** — renowned for authentic calligraphic proportion, high legibility on digital screens, and clean technical balance.
- **Arabic Line-Height Adjustment**:
  - Arabic glyphs possess taller ascenders and deeper descenders than Latin characters. A single frozen multiplier of **`×1.05`** (`AppTypography.arabicLineHeightScale`) is applied to every Arabic text role so diacritics and dots never clip.
  - Letter-spacing (`letterSpacing`) is strictly set to `0.0` for Arabic text (letter-spacing breaks cursive character ligation in Arabic script).

### 2.2 Directional Layout & Interaction Mirroring
1. **Navigation Mirroring**: In Arabic, the navigation rail or drawer shifts to the right side of the screen; content flows from right to left; back chevrons point to the right (`Icons.chevron_right`).
2. **Timeline & Steppers**: Multi-step booking wizards and service tracking timelines progress from right to left in Arabic mode, matching the natural reading eye-scan.
3. **Modal Sheets & Drawers**: Slide-over panels (such as lead details or parts requisition drawers) emerge from the left edge in Arabic, maintaining natural spatial physics.

### 2.3 Strict Non-Mirroring Exceptions (Physical & Technical Data)
Certain automotive and technical entities **must never be mirrored**, even in full Arabic RTL mode:
1. **Interactive Vehicle Damage Map**:
   The physical car does not flip because the user speaks Arabic. The driver side, passenger side, front bumper, and rear trunk must remain physically accurate to the actual vehicle sitting in the workshop bay.
2. **License Plate Numbers & Alphanumeric Codes**:
   Plate codes (e.g. `DXB A 12345` or `AUH 12 98765`) and VIN codes (`1HGCR2F83HA...`) represent legal LTR alphanumeric strings and must always render LTR with monospace tabular typography.
3. **Phone Numbers & Country Dial Codes**:
   Telephone numbers (e.g., `+971 50 123 4567`) are universally formatted LTR.
4. **Financial Numerals & Currency Formats**:
   Currencies are localized as `AED 1,250.00` in English and `١٬٢٥٠٫٠٠ د.إ` or `1,250.00 AED` depending on system preference, but numeral digits remain tabular to guarantee clean decimal column alignment.

---

## 3. Localization Verification Protocol

Every screen developed in the new design system must pass a **Dual-Locale Verification Gate** before visual sign-off:
1. **RTL Overflow Check**: Ensure that longer Arabic phrasing (which is on average 15%–20% longer than English equivalents) does not cause `RenderFlex` overflow errors in buttons, table cells, or status pills.
2. **Mixed Content Rendering**: Validate that screens containing mixed Arabic customer names and Latin VIN/plate codes display without punctuation jumping or bi-directional text corruption.
3. **Directional Asset Check**: Verify that directional icons flip correctly using the shared `DirectionalIcon` widget while brand logos and vehicle schematics stay locked.
