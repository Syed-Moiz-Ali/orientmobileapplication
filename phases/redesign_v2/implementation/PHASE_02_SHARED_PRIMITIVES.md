# PHASE 02 — Shared UI Primitives & Input System

**Document ID:** `phases/redesign_v2/implementation/PHASE_02_SHARED_PRIMITIVES.md`  
**Prerequisites:** Phase 01 Completed (`REPORT_PHASE_01.md`)  
**Target Package:** `packages/shared_core/lib/src/widgets/`  
**Status:** READY FOR IMPLEMENTATION (Gate 2)  

---

## 1. Primary User & Engineering Objective
Redesign all foundational shared components in `packages/shared_core` to embody Concept A geometry, tactile haptics, and elevation. Provide the building blocks for all subsequent application screens: buttons, inputs, form sections, status pills, dialogs, sheets, and loading skeletons.

---

## 2. Real Repository File Paths
- `packages/shared_core/lib/src/widgets/primary_button.dart`
- `packages/shared_core/lib/src/widgets/app_text_field.dart` & `app_search_field.dart`
- `packages/shared_core/lib/src/widgets/app_dropdown_button.dart` & `app_selection_sheet.dart`
- `packages/shared_core/lib/src/widgets/app_form_primitives.dart`
- `packages/shared_core/lib/src/widgets/status_pill.dart`
- `packages/shared_core/lib/src/widgets/app_bottom_sheet.dart` & `app_confirmation_dialog.dart`
- `packages/shared_core/lib/src/widgets/app_skeleton.dart` & `app_progress.dart`
- `packages/shared_core/lib/src/widgets/empty_state.dart` & `error_view.dart`
- `packages/shared_core/test/widgets/shared_primitives_test.dart`

---

## 3. New Screen & Component Composition
1. **`PrimaryButton`:**
   - 8px chamfered corners, Hyper Cobalt (`#2563EB`) background, white w700 typography.
   - Micro-haptic tactile feedback on tap (`HapticFeedback.lightImpact()`).
   - Integrated progress spinner on loading state that maintains exact button dimensions without layout jump.
2. **`AppTextField`:**
   - 8px radius, 1.0px hairline border (`#E2E8F0` / `#262C3D`), focused cobalt ring.
   - Prefix slot for UAE license plate code / country dial code.
   - Inline error badges with micro-shake animation.
3. **`StatusPill`:**
   - 4px radius, 10% semantic tint background, 1px border, uppercase w800 10sp text.
   - Supports directional icon orientation for Arabic RTL.
4. **`AppFormSection` (Consolidated):**
   - Clean grouping of form fields with subtle title, description, and divider lines.
5. **`EmptyState`:**
   - Automotive-themed vector illustration, bold title, concise guidance, and single prominent CTA.

---

## 4. Visual Acceptance Criteria
- Components render with crisp 8px/12px chamfers without excessive rounded bubbles.
- Buttons and inputs have tactile, visible focus and active states.
- Golden tests generated with real fonts loaded (`PlusJakartaSans` & `IBMPlexSansArabic`).

---

## 5. Dual Gate Verification
### Gate 1: Engineering Validation
- `dart analyze packages/shared_core` returns 0 errors and 0 warnings.
- `shared_primitives_test.dart` passes 100%.

### Gate 2: Visual Aesthetic Validation
- Rendered component catalog golden PNG approved for Concept A fidelity.
- Generates `phases/redesign_v2/reports/REPORT_PHASE_02.md`.
