# 00 — Concept A Production Design System Specification

**Document ID:** `phases/redesign_v2/00_CONCEPT_A_DESIGN_SYSTEM.md`  
**Visual Authority:** **Concept A — Premium Minimal Automotive**  
**Target Package:** `packages/shared_core/lib/src/theme/`  
**Status:** FROZEN DESIGN SYSTEM SPECIFICATION  

---

## 1. Design Token Architecture & Exact Color Values

All color tokens are derived directly from the approved Concept A showcase (`apps/concept_showcase/lib/concepts/concept_tokens.dart`) and elevated for high-density production use.

### 1.1 Color Palettes

#### Canvas, Surfaces & Borders
```dart
// Light Theme Tokens
static const canvasLight       = Color(0xFFFBFBFD); // Ultra-clean off-white background
static const surfaceLight      = Color(0xFFFFFFFF); // Elevated cards, modals, sheets
static const cardBgLight       = Color(0xFFF4F6F9); // Secondary surface / input field fill
static const borderLight       = Color(0xFFE2E8F0); // Subtle 1px structural hairline
static const borderSubtleLight = Color(0xFFEDF2F7); // Inner dividers / row separators
static const textPrimaryLight  = Color(0xFF0F172A); // High-contrast deep slate navy
static const textSecondaryLight= Color(0xFF64748B); // Technical metadata & secondary labels
static const textMutedLight    = Color(0xFF94A3B8); // Captions, timestamps, disabled hints

// Dark Theme Tokens
static const canvasDark        = Color(0xFF090B10); // Deep obsidian background
static const surfaceDark       = Color(0xFF11141D); // Elevated cards & modals
static const cardBgDark        = Color(0xFF181C28); // Secondary surface / input fill
static const borderDark        = Color(0xFF262C3D); // Hairline structural border
static const borderSubtleDark  = Color(0xFF1A202E); // Inner dividers
static const textPrimaryDark   = Color(0xFFF8FAFC); // Crisp white typography
static const textSecondaryDark = Color(0xFF94A3B8); // Secondary technical slate
static const textMutedDark     = Color(0xFF64748B); // Captions & subtle hints
```

#### Brand & Semantic Status Accents
```dart
// Hyper Cobalt (Primary Brand & Action Anchor)
// WCAG AA Design Amendment: Concept A raw token #2563EB produced 4.49:1 under hover/press overlays;
// tuned to #215FE6 (5.46:1 rest, 4.73:1 hover, 4.56:1 press) for strict compliance across all states.
static const hyperCobalt       = Color(0xFF215FE6); // Primary CTA buttons, active tabs, selected states (authorized accessible value)
static const hyperCobaltRaw    = Color(0xFF2563EB); // Prototype baseline (historical reference)
static const hyperCobaltHover  = Color(0xFF1D4ED8); // Button hover / press state
static const hyperCobaltMuted  = Color(0xFFDBEAFE); // 10% tint for badges & active list item fills

// Precision Emerald (Success, Passed, Profit, Active)
static const precisionEmerald  = Color(0xFF10B981); // Checkpoints passed, positive revenue, verified
static const emeraldMuted      = Color(0xFFD1FAE5); // Emerald badge background

// Electric Amber (Caution, Warning, Pending, Estimates)
static const electricAmber     = Color(0xFFF59E0B); // Caution checkpoints, awaiting approval, follow-ups
static const amberMuted        = Color(0xFFFEF3C7); // Amber badge background

// Brembo Crimson (Critical Failure, Urgent Hazard, Overdue)
static const bremboCrimson     = Color(0xFFEF4444); // Inspection failed, safety hazard, overdue lead
static const crimsonMuted      = Color(0xFFFEE2E2); // Crimson badge background

// Ice Blue / Cyan (Telemetry, Stage, Informational)
static const iceBlue           = Color(0xFF0284C7); // Stage indicators, telemetry chips, VIN markers
static const iceBlueMuted      = Color(0xFFE0F2FE); // Ice blue badge background
```

---

## 2. Typography & Font Stacks

### 2.1 Latin Typography: Plus Jakarta Sans
Plus Jakarta Sans is the primary typeface for English LTR, delivering a modern geometric aesthetic with exceptional optical legibility at small sizes.

- **Display 1 (Hero Numbers / Currencies):** `32sp` / Weight: `w900` / Letter-spacing: `-0.8px`
- **Heading 1 (Page Titles):** `24sp` / Weight: `w800` / Letter-spacing: `-0.5px`
- **Heading 2 (Card & Modal Titles):** `18sp` / Weight: `w700` / Letter-spacing: `-0.3px`
- **Heading 3 (Section Labels):** `14sp` / Weight: `w700` / Letter-spacing: `-0.2px`
- **Body Large:** `15sp` / Weight: `w500` / Line-height: `1.4`
- **Body Regular:** `13sp` / Weight: `w400` / Line-height: `1.4`
- **Technical Telemetry / Overline:** `11sp` / Weight: `w800` / Letter-spacing: `+0.8px` / UPPERCASE
- **Micro Caption / Timestamps:** `10sp` / Weight: `w600` / Letter-spacing: `+0.4px`

### 2.2 Arabic Typography: IBM Plex Sans Arabic
IBM Plex Sans Arabic is the primary typeface for Arabic RTL, harmonizing perfectly with Latin geometric proportions without exaggerated calligraphic loops.

- **Heading 1:** `24sp` / Weight: `w800` / Height: `1.3`
- **Heading 2:** `18sp` / Weight: `w700` / Height: `1.3`
- **Heading 3:** `14sp` / Weight: `w700` / Height: `1.3`
- **Body Regular:** `13sp` / Weight: `w400` / Height: `1.5`
- **Technical Telemetry:** `11sp` / Weight: `w800` / Height: `1.2`

---

## 3. Geometry, Elevation & Radii

Concept A completely rejects bulbous, exaggerated rounded corners in favor of crisp, engineered chamfers:

```dart
static const radiusXs = 4.0;  // Micro-badges, status dots, inner progress bars
static const radiusSm = 8.0;  // Buttons, text inputs, dropdowns, filter chips
static const radiusMd = 12.0; // Standard cards, table containers, dialogs
static const radiusLg = 16.0; // Bottom sheets, hero vehicle cards, workspace panels
static const radiusXl = 24.0; // Floating modal dialogs, large preview overlays
```

### 3.1 Shadows and Elevation
- **Card Default:** No heavy drop shadows. Border: `Border.all(color: border, width: 1.0)`.
- **Card Hover / Active:** Elevation: `0 4px 12px rgba(15, 23, 42, 0.04)`.
- **Modal / Bottom Sheet:** Elevation: `0 12px 32px rgba(15, 23, 42, 0.12)`.

---

## 4. Spacing Scale

Based on an 8-point spatial grid with 4-point micro-adjustments:
- `xxs`: `4px` (Icon to badge gap, indicator dot spacing)
- `xs`: `8px` (Label to input gap, chip spacing)
- `sm`: `12px` (Internal padding of compact rows, list item spacing)
- `md`: `16px` (Default card padding on mobile, form field vertical gap)
- `lg`: `20px` (Card padding on tablet, page gutter on mobile)
- `xl`: `24px` (Workspace panel padding, section gap)
- `xxl`: `32px` (Dashboard group separation)

---

## 5. Visual Anti-Patterns (Permanently Prohibited in v2)

1. **No Repetitive 4-Card Dashboard Templates:** No screen may blindly repeat the "4 identical metric boxes at top + generic list at bottom" pattern.
2. **No Pure Saturated Card Backgrounds:** Do not make entire cards bright green or bright red. Use clean neutral surfaces with targeted status badges and hairline accent borders.
3. **No Heavy Skeuomorphism or Uncontrolled Glassmorphism:** Subtle translucent frosted glass (`BackdropFilter(sigma: 10)`) is permitted only on sticky navigation headers and floating action docks.
4. **No Untranslated Strings in Arabic Views:** Every label must use genuine, approved automotive terms from the localization dictionaries.
5. **No Text Overflow or Truncation on 390px Mobile:** Every horizontal row containing dynamic text must be wrapped in `Expanded` or `Flexible` with explicit ellipsis handling.
