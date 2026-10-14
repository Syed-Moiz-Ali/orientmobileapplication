# PHASE 12 â€” Staff Application: Common Profile, Attendance & Settings

**Document ID:** `phases/redesign_v2/implementation/PHASE_12_STAFF_COMMON_PROFILE.md`  
**Prerequisites:** Phase 11 Completed (`REPORT_PHASE_11.md`)  
**Target Package:** `apps/staff_app/lib/features/common/`  
**Status:** READY FOR IMPLEMENTATION (Gate 12)  

---

## 1. Primary User & Engineering Objective
Redesign the common staff profile, attendance punch-clock, shift details, and local synchronization settings screens using **Archetype 11: Structured Workspace Settings**. Provide clean, professional identity cards, attendance history, shift schedules, and offline sync diagnostics.

---

## 2. Real Repository File Paths
- `apps/staff_app/lib/features/common/presentation/profile_screen.dart` (M1)
- `apps/staff_app/lib/features/common/presentation/staff_attendance_screen.dart` (M2)
- `apps/staff_app/lib/features/common/presentation/simple_pages.dart` (`ShiftDetailsPage` M3, `SettingsPage` M4)
- `apps/staff_app/test/features/common/staff_common_views_test.dart`

---

## 3. Screen Redesign Requirements
1. **`ProfileScreen` (M1):**
   - Refined staff identity card with active shift metrics, branch status pill, role badge, and profile photo avatar.
   - Quick settings toggles: Language (English / Arabic), Theme (Dark / Light / System), Security & Password Change.
2. **`StaffAttendanceScreen` (M2):**
   - Shift Punch Clock: Large, tactile "Clock In" / "Clock Out" action with geolocation and timestamp logging.
   - Monthly Attendance Calendar: Visual attendance status dots (Present = Emerald, Late = Amber, Absent = Crimson).
3. **`ShiftDetailsPage` (M3):**
   - Scheduled work hours, break allocations, supervisor on duty, and assigned workshop bay.
4. **`SettingsPage` (M4):**
   - Local Sync Status: Clear diagnostic indicator showing pending Hive offline operations and manual "Force Sync Now" trigger.
   - App version, device telemetry, and cache cleaning actions.

---

## 4. Visual Acceptance Criteria
- Clean, structured card layout with refined navy typography.
- Zero horizontal layout overflows on narrow mobile screens.
- Golden tests generated with real fonts loaded across Mobile and Tablet.

---

## 5. Dual Gate Verification
### Gate 1: Engineering Validation
- `dart analyze apps/staff_app` returns 0 errors and 0 warnings.
- `staff_common_views_test.dart` passes 100%.

### Gate 2: Visual Aesthetic Validation
- Golden screenshots captured across Mobile (390px EN/AR) and Tablet (768px) with real fonts.
- Generates `phases/redesign_v2/reports/REPORT_PHASE_12.md`.


---

## Styling Authority (Phase 01.1 — Mandatory)
All styling in this phase MUST resolve through the single centralized theme system. Do not select light/dark colors by hand.

- Standard Material roles -> `context.colors` (`ColorScheme`).
- Custom automotive/workshop roles -> `context.semanticColors` (`AppSemanticColors` ThemeExtension).
- **Forbidden:** `dark ? AppDarkColors.x : AppColors.x` ternaries; direct `AppColors.*` / `AppDarkColors.*` palette selection in feature widgets; hardcoded semantic hex; duplicate local theme systems or competing theme providers; hardcoded font styles, spacing, or radii where a theme or `AppDimensions` token exists.
- **Justified exceptions** (brand assets, theme construction, color previews, brightness-dependent behavior) must carry a one-line documented reason.
- Full rules: `00_CONCEPT_A_DESIGN_SYSTEM.md` Sec.6 and `reports/PHASE_01_1_THEME_ARCHITECTURE.md`.
