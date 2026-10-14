# PHASE 08 â€” Staff Application: Spatial Inspection HUD & Evidence Workspace

**Document ID:** `phases/redesign_v2/implementation/PHASE_08_STAFF_INSPECTION_HUD.md`  
**Prerequisites:** Phase 07 Completed (`REPORT_PHASE_07.md`)  
**Target Package:** `apps/staff_app/lib/features/advisor/`  
**Status:** READY FOR IMPLEMENTATION (Gate 8)  

---

## 1. Primary User & Engineering Objective
Complete visual and interaction redesign of the vehicle inspection workflow using **Archetype 6: Spatial Inspection HUD**. Replace generic checkpoint lists with an interactive 8-perspective vehicle damage map, tactile Pass/Caution/Fail toggle rings, voice note recordings, and digital vehicle health summary reports.

---

## 2. Real Repository File Paths
- `apps/staff_app/lib/features/advisor/presentation/pages/choose_inspection_view.dart` (S17)
- `apps/staff_app/lib/features/advisor/presentation/pages/inspection_sheet_view.dart` (S18)
- `apps/staff_app/lib/features/advisor/presentation/pages/inspection_preview_view.dart` (S19)
- `apps/staff_app/test/features/advisor/inspection_views_test.dart`

---

## 3. Screen Redesign Requirements
1. **`ChooseInspectionView` (S17):**
   - Tiered inspection packages: Quick 20-Point Check, Comprehensive 60-Point Check, Safety & Roadworthiness Audit.
   - Package cards display checkpoint breakdown, estimated duration chip, and primary focus areas (Brakes, Engine, Suspension).
2. **`InspectionSheetView` (S18 - Spatial Inspection HUD):**
   - **Vehicle Damage Canvas:** Interactive vehicle blueprint diagram. Tapping any exterior zone drops a colored damage pin:
     - Amber pin: Minor Scratch / Scuff
     - Crimson pin: Deep Dent / Structural Deformation
     - Blue pin: Cracked Glass / Lamp Assembly
   - **Tactile Checkpoint Rings:** High-contrast toggle rings for Pass (Emerald), Caution (Amber), and Fail (Crimson). No small radio buttons.
   - **Voice & Media Dock:** One-tap audio note recording and instant camera photo attachments per checkpoint.
   - **RTL Non-Mirroring Rule:** The vehicle physical diagram must remain strictly un-mirrored in Arabic RTL.
3. **`InspectionPreviewView` (S19 - Digital Vehicle Health Report):**
   - High-impact vehicle score card (e.g. `82% Overall Health Index`).
   - Categorized findings list: Mandatory Safety Items (Red), Recommended Maintenance (Amber), Good Condition (Green).
   - One-tap button to convert flagged items directly into a Repair Estimate.

---

## 4. Visual Acceptance Criteria
- Vehicle wireframe rendered as a crisp, production-grade vector diagram.
- Clear, tactile distinction between Pass, Caution, and Fail checkpoint states.
- Golden tests generated with real fonts loaded across Mobile and Tablet.

---

## 5. Dual Gate Verification
### Gate 1: Engineering Validation
- `dart analyze apps/staff_app` returns 0 errors and 0 warnings.
- `inspection_views_test.dart` passes 100% with damage pin addition and grading logic tested.

### Gate 2: Visual Aesthetic Validation
- Golden screenshots captured across Mobile (390px EN/AR) and Tablet (768px) with real fonts.
- Generates `phases/redesign_v2/reports/REPORT_PHASE_08.md`.


---

## Styling Authority (Phase 01.1 — Mandatory)
All styling in this phase MUST resolve through the single centralized theme system. Do not select light/dark colors by hand.

- Standard Material roles -> `context.colors` (`ColorScheme`).
- Custom automotive/workshop roles -> `context.semanticColors` (`AppSemanticColors` ThemeExtension).
- **Forbidden:** `dark ? AppDarkColors.x : AppColors.x` ternaries; direct `AppColors.*` / `AppDarkColors.*` palette selection in feature widgets; hardcoded semantic hex; duplicate local theme systems or competing theme providers; hardcoded font styles, spacing, or radii where a theme or `AppDimensions` token exists.
- **Justified exceptions** (brand assets, theme construction, color previews, brightness-dependent behavior) must carry a one-line documented reason.
- Full rules: `00_CONCEPT_A_DESIGN_SYSTEM.md` Sec.6 and `reports/PHASE_01_1_THEME_ARCHITECTURE.md`.
