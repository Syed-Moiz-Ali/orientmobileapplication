# PHASE 03 — Complex Data Presentation & Telemetry Components

**Document ID:** `phases/redesign_v2/implementation/PHASE_03_COMPLEX_DATA_COMPONENTS.md`  
**Prerequisites:** Phase 02 Completed (`REPORT_PHASE_02.md`)  
**Target Package:** `packages/shared_core/lib/src/widgets/data/`  
**Status:** READY FOR IMPLEMENTATION (Gate 3)  

---

## 1. Primary User & Engineering Objective
Build high-density operational data components required across Staff, Owner, Customer, and CRM applications. Eliminate repetitive card syndrome by providing specialized data presentation widgets: sortable data tables, telemetry metric pods, revenue sparklines, and the spatial damage HUD.

---

## 2. Real Repository File Paths
- `packages/shared_core/lib/src/widgets/app_table.dart` (Sortable responsive table)
- `packages/shared_core/lib/src/widgets/data/telemetry_metric_pod.dart` (Concept A metric pod)
- `packages/shared_core/lib/src/widgets/data/sparkline_chart.dart` (Revenue & occupancy curve)
- `packages/shared_core/lib/src/widgets/data/spatial_damage_hud.dart` (Interactive vehicle damage map)
- `packages/shared_core/lib/src/widgets/data/live_service_telemetry_ribbon.dart` (Workshop stage ribbon)
- `packages/shared_core/test/widgets/data_components_test.dart`

---

## 3. New Screen & Component Composition
1. **`AppTable`:**
   - Desktop & tablet responsive data grid with sticky header row.
   - Sortable column headers with directional arrows.
   - Alternating row hover highlights with subtle cobalt indicator line on selection.
   - Fluid mobile fallback mode: transforms wide table columns into stacked telemetry cards.
2. **`TelemetryMetricPod`:**
   - High-contrast numeric display with overline label (uppercase 11sp Hyper Cobalt).
   - Prominent numerical value (`AED 48,250.00`).
   - Delta percentage badge (`+18.4% vs Target`) with Precision Emerald or Brembo Crimson pill.
   - Real-time indicator dot for live data streams.
3. **`SparklineChart`:**
   - Lightweight custom-painted curve for revenue velocity and bay occupancy without heavy third-party chart bloat.
4. **`SpatialDamageHud`:**
   - Detailed 8-perspective vehicle blueprint wireframe with interactive tap-to-pin damage hotspots.
   - Hotspot severity coloring: Amber (Scratch/Scuff), Crimson (Dent/Deformation), Blue (Glass/Lamp).
   - Strict LTR vehicle physical orientation in Arabic RTL mode.
5. **`LiveServiceTelemetryRibbon`:**
   - 6-stage progressive workshop journey ribbon (Intake -> Inspection -> Parts -> Labor -> QC -> Ready) wired to live `JobCardStatus` enums.

---

## 4. Visual Acceptance Criteria
- Clean, high-density data display without clunky Material 3 card borders.
- Vehicle wireframe must be a sharp, professional vector, not a blurry placeholder.
- Multi-column tables collapse gracefully on mobile screens without horizontal clipping.

---

## 5. Dual Gate Verification
### Gate 1: Engineering Validation
- `dart analyze packages/shared_core` returns 0 errors and 0 warnings.
- `data_components_test.dart` passes 100% across Mobile, Tablet, and Desktop viewports.

### Gate 2: Visual Aesthetic Validation
- Golden screenshot captures of `AppTable`, `TelemetryMetricPod`, `SpatialDamageHud`, and `SparklineChart` approved for Concept A fidelity.
- Generates `phases/redesign_v2/reports/REPORT_PHASE_03.md`.
