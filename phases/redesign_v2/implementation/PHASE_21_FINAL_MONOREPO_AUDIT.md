# PHASE 21 — Monorepo Master Integration & Final Visual Quality Gate

**Document ID:** `phases/redesign_v2/implementation/PHASE_21_FINAL_MONOREPO_AUDIT.md`  
**Prerequisites:** All Phases 01 through 20 Completed (`REPORT_PHASE_01.md` through `REPORT_PHASE_20.md`)  
**Target Package:** Entire Monorepo (`apps/` & `packages/`)  
**Status:** READY FOR IMPLEMENTATION (Gate 21)  

---

## 1. Primary User & Engineering Objective
Execute the final comprehensive quality assurance audit across all 4 production applications (Staff, Owner, Customer, CRM) and shared packages (`shared_core`, `shared_auth`, `app_router`). Verify total visual fidelity against Concept A, enforce 0 Dart analyzer issues, confirm 100% test pass rates, execute cross-app golden regression testing with real fonts, and validate Arabic RTL integrity.

---

## 2. Real Repository File Paths
- Entire workspace: `apps/staff_app`, `apps/owner_app`, `apps/customer_app`, `apps/crm_app`
- Shared packages: `packages/shared_core`, `packages/shared_auth`, `packages/app_router`
- Test suites across all 4 applications.

---

## 3. Monorepo Quality Gate Verification Checklist
1. **Static Analysis & Code Quality:**
   - Run `dart analyze` across root monorepo. Expected result: `No issues found!`.
   - Verify zero deprecated widget references (e.g. no leftover raw Material 3 styling, old cards, or deprecated tokens).
2. **Unified Test Suite Execution:**
   - Run unit and widget test suites for all 4 applications and shared packages.
   - All tests must pass with 100% green status.
3. **Master Golden Test Catalog:**
   - Comprehensive golden regression pass across all 86 reconciled UI surfaces.
   - Verified across Mobile (390x844), Tablet (834x1194), and Desktop (1280x800) in both English (LTR) and Arabic (RTL).
   - Real typography verification: Plus Jakarta Sans (Latin) and IBM Plex Sans Arabic (Arabic) properly loaded in golden environments without wireframe glyphs or boxes.
4. **Accessibility (a11y) & RTL Verification:**
   - Contrast ratio ≥ 4.5:1 on all text elements and primary UI buttons.
   - Touch targets ≥ 48x48dp for all interactive buttons and chips.
   - Non-mirroring rules enforced for LTR-locked elements in Arabic mode (VIN numbers, plate badges, phone dialers, price currencies).

---

## 4. Final Deliverables
- Final Monorepo Audit Report: `phases/redesign_v2/reports/FINAL_REDESIGN_V2_AUDIT_REPORT.md`.
- Updated Monorepo Catalog & Golden Screenshot Index.
- Official product sign-off recommendation.


---

## Styling Authority (Phase 01.1 � Mandatory)
All styling in this phase MUST resolve through the single centralized theme system. Do not select light/dark colors by hand.

- Standard Material roles -> `context.colors` (`ColorScheme`).
- Custom automotive/workshop roles -> `context.semanticColors` (`AppSemanticColors` ThemeExtension).
- **Forbidden:** `dark ? AppDarkColors.x : AppColors.x` ternaries; direct `AppColors.*` / `AppDarkColors.*` palette selection in feature widgets; hardcoded semantic hex; duplicate local theme systems or competing theme providers; hardcoded font styles, spacing, or radii where a theme or `AppDimensions` token exists.
- **Justified exceptions** (brand assets, theme construction, color previews, brightness-dependent behavior) must carry a one-line documented reason.
- Full rules: `00_CONCEPT_A_DESIGN_SYSTEM.md` Sec.6 and `reports/PHASE_01_1_THEME_ARCHITECTURE.md`.
