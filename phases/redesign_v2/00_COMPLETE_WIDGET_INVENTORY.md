# 00 — Verified Widget Inventory & Migration Plan (Redesign v2)

**Document ID:** `phases/redesign_v2/00_COMPLETE_WIDGET_INVENTORY.md`  
**Target Package:** `packages/shared_core/lib/src/widgets/`  
**Actual Reconciled Count:** Exactly **42 Shared Core Widget Files**  
**Action Classifications:**
- **A: Reuse functionality, redesign visually** (Preserve contract, replace Concept A rendering)
- **B: Replace with new composition** (Retire old layout, build modern archetype component)
- **C: Consolidate into a new component** (Merge fragmented primitives)
- **D: Keep unchanged with documented justification** (Strict non-visual / architectural helper)
- **E: Retire after migration** (Remove obsolete or redundant component)

---

## 1. Complete Reconciled Shared Core Widget Matrix

| # | Widget File Name | Current Role | Migration Action | Concept A Production Redesign Plan | Phase |
| :--- | :--- | :--- | :--- | :--- | :---: |
| 1 | `app_action_bar.dart` | Pinned bottom action bar | **A: Reuse, Redesign** | Translucent frosted glass (`sigma: 10`), safe-area avoidance, primary/secondary button slotting. | Phase 02 |
| 2 | `app_bottom_sheet.dart` | Standard modal bottom sheet | **A: Reuse, Redesign** | 16px top corner radius, drag handle pill, responsive tablet/desktop modal transformation. | Phase 02 |
| 3 | `app_breadcrumbs.dart` | Navigation breadcrumbs | **D: Keep Unchanged** | Contracts and rendering already meet desktop requirements; retain intact. | Phase 04 |
| 4 | `app_card.dart` | Generic container card | **A: Reuse, Redesign** | Clean 12px chamfer, hairline border (`#E2E8F0`/`#262C3D`), subtle 4px elevation. | Phase 02 |
| 5 | `app_confirmation_dialog.dart`| Confirmation dialog modal | **A: Reuse, Redesign** | 16px radius, high-impact status icon, destructive crimson styling for delete, Enter/Escape keys. | Phase 02 |
| 6 | `app_dropdown_button.dart` | Standard dropdown input | **A: Reuse, Redesign** | Smooth modal bottom sheet selector on mobile (<600px), docked precision menu on desktop. | Phase 02 |
| 7 | `app_form_primitives.dart` | Fragmented form primitives | **C: Consolidate** | Unify into cohesive `AppFormSection` with section headers, dividers, and status indicators. | Phase 02 |
| 8 | `app_info_panel.dart` | Tinted alert container | **A: Reuse, Redesign** | Refine with subtle 10% alpha tint, 1px border, status icon, no heavy saturated blocks. | Phase 02 |
| 9 | `app_kpi_card.dart` | Rectangular metric card | **B: Replace** | Replaced by specialized `TelemetryMetricPod`, `SparklineChart`, and `CompactTickerPod`. | Phase 03 |
| 10 | `app_list_surface.dart` | Grouped list container | **A: Reuse, Redesign** | Subtle hairline border, alternating row hover highlights, inner dividers. | Phase 02 |
| 11 | `app_master_detail_scaffold.dart`| Two-pane split scaffold | **A: Reuse, Redesign** | Modernize divider styling, add smooth pane resize animations, fluid mobile fallback. | Phase 04 |
| 12 | `app_page_frame.dart` | Page wrapper with padding | **A: Reuse, Redesign** | Concept A canvas (`#FBFBFD`/`#090B10`), adaptive max-width gutters (480px, 1024px, 1440px). | Phase 02 |
| 13 | `app_page_header.dart` | Static title and subtitle | **B: Replace** | Rebuilt into dynamic banner with uppercase cobalt telemetry overline and action clustering. | Phase 02 |
| 14 | `app_progress.dart` | Linear/step progress bars | **A: Reuse, Redesign** | 4px pill progress indicator with animated progress value, high-contrast colors. | Phase 02 |
| 15 | `app_quantity_stepper.dart` | Number incrementer (- 1 +) | **A: Reuse, Redesign** | Tactile increment/decrement buttons with haptic click, monospace count display. | Phase 02 |
| 16 | `app_record_row.dart` | Standard list tile | **B: Replace** | Modular data row: Left icon/avatar slot, title/subtitle column, trailing status pill & amount. | Phase 02 |
| 17 | `app_search_field.dart` | Search input with icon | **A: Reuse, Redesign** | 8px radius, subtle border, keyboard shortcut badge (`⌘K`), instant clear icon. | Phase 02 |
| 18 | `app_selection_sheet.dart` | Multi-option picker sheet | **A: Reuse, Redesign** | Searchable selection list with radio pills and smooth modal presentation. | Phase 02 |
| 19 | `app_skeleton.dart` | Shimmer loading box | **A: Reuse, Redesign** | Refined micro-shimmer frequency matching 2026 aesthetics; content-aware shapes. | Phase 02 |
| 20 | `app_snackbar.dart` | Toast / snackbar notifications| **A: Reuse, Redesign** | Floating pill toast with status color left border and dismiss swipe. | Phase 02 |
| 21 | `app_table.dart` | Responsive desktop table | **A: Reuse, Redesign** | Sticky header row, sortable columns with arrows, alternating row hover, mobile cards. | Phase 03 |
| 22 | `app_text_field.dart` | Form text input | **A: Reuse, Redesign** | 8px radius, 1.0px hairline border, focused cobalt ring, prefix slot for plate/country code. | Phase 02 |
| 23 | `app_top_bar.dart` | Material AppBar wrapper | **A: Reuse, Redesign** | Modernize with border bottom (`#E2E8F0`), high-contrast icons, offline status badge. | Phase 04 |
| 24 | `dashboard_shell.dart` | Adaptive app shell | **A: Reuse, Redesign** | Clean workspace frame coordinating navigation rail, top bar, and content canvas. | Phase 04 |
| 25 | `directional_icon.dart` | RTL icon flipper | **D: Keep Unchanged** | Essential localization infrastructure that correctly mirrors chevrons in RTL. | Phase 02 |
| 26 | `empty_state.dart` | Generic empty illustration | **B: Replace** | Archetype-specific empty states with purposeful automotive iconography & single CTA. | Phase 02 |
| 27 | `error_view.dart` | Generic error view | **A: Reuse, Redesign** | Diagnostic error view with actionable retry button and error code badge. | Phase 02 |
| 28 | `exit_confirmation_dialog.dart`| Back-button double tap guard| **D: Keep Unchanged** | Crucial operational guard to prevent form data loss; preserve intact. | Phase 02 |
| 29 | `gradient_banner.dart` | Gradient header banner | **E: Retire** | Completely retired; replaced by Concept A clean typography and subtle telemetry pods. | Phase 02 |
| 30 | `loading_indicator.dart` | Spinner wrapper | **A: Reuse, Redesign** | Circular progress with Hyper Cobalt stroke and smooth indeterminate animation. | Phase 02 |
| 31 | `logout_dialog.dart` | Sign-out confirmation modal | **A: Reuse, Redesign** | Apply Concept A dialog tokens, crimson confirm button, clear session summary. | Phase 05 |
| 32 | `markdown_text.dart` | Markdown renderer | **D: Keep Unchanged** | Retain for terms, conditions, and formatted service notes. | Phase 02 |
| 33 | `notification_bell.dart` | AppBar bell icon | **A: Reuse, Redesign** | Pulse indicator for unread operational alerts and haptic badge pop. | Phase 04 |
| 34 | `offline_banner.dart` | Full-width orange strip | **B: Replace** | Replaced by sleek floating offline telemetry pill with auto-sync countdown. | Phase 02 |
| 35 | `pending_sync_chip.dart` | Offline sync indicator | **A: Reuse, Redesign** | Modernized spinning sync glyph with tap-to-inspect pending queue sheet. | Phase 02 |
| 36 | `primary_button.dart` | Filled cobalt button | **A: Reuse, Redesign** | 8px radius, w700 typography, haptic click, embedded spinning loader. | Phase 02 |
| 37 | `profile_sheet.dart` | User profile bottom sheet | **A: Reuse, Redesign** | Identity header with shift metrics, branch status pill, language switch. | Phase 06 |
| 38 | `resume_refresh_scope.dart` | App lifecycle refresh helper | **D: Keep Unchanged** | Crucial lifecycle helper to refresh state on app resume; preserve intact. | Phase 02 |
| 39 | `section_header.dart` | Section title & action row | **A: Reuse, Redesign** | Bold 14sp title, optional item count badge, clean secondary action link. | Phase 02 |
| 40 | `status_pill.dart` | Status badge capsule | **A: Reuse, Redesign** | 4px radius chamfer, 10% semantic tint background, 1px border, uppercase w800 10sp text. | Phase 02 |
| 41 | `user_avatar.dart` | Circle avatar | **A: Reuse, Redesign** | Online status dot, role-based border ring, smooth image fallback initials. | Phase 02 |
| 42 | `workspace_app_bar.dart` | Desktop workspace header | **A: Reuse, Redesign** | Frosted glass backdrop, breadcrumbs, search shortcut, and notification bell. | Phase 04 |

---

## 2. New Dedicated Concept A Shared Components

1. **`TelemetryMetricPod`** (`telemetry_metric_pod.dart`): Replaces generic KPI cards with overline uppercase label, large currency/numeric value, delta pill (`+18.4% vs Target`), and status indicator.
2. **`SpatialDamageHud`** (`spatial_damage_hud.dart`): 8-perspective vehicle blueprint with interactive tap-to-pin damage hotspots (Dent/Scratch/Crack) and photo thumbnail preview.
3. **`LiveServiceTelemetryRibbon`** (`live_service_telemetry_ribbon.dart`): Multi-stage progressive workshop stage ribbon (Intake -> Inspection -> Parts -> Labor -> QC -> Ready).
4. **`DealRadarCard`** (`deal_radar_card.dart`): CRM card displaying customer name, vehicle interest, deal amount in AED, and probability percentage.
5. **`CommandSearchBar`** (`command_search_bar.dart`): Spotlight command palette (`Cmd+K`) for rapid plate, VIN, and customer search.
