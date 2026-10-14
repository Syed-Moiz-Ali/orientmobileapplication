# 00 — Product Owner Concept A Approval & Redesign v2 Authority

**Document ID:** `phases/redesign_v2/00_CONCEPT_A_APPROVAL.md`  
**Status:** **APPROVED & FROZEN AS SOLE DESIGN AUTHORITY**  
**Effective Date:** October 14, 2026  
**Sign-off:** Product Owner, Executive Leadership & Principal Design Architect  

---

## 1. Formal Approval Record

Following the review of the three divergent Stage A design prototypes (Concept A, Concept B, Concept C) and the inspection of rendered golden screenshots in `apps/concept_showcase/test/goldens/`, the Product Owner made the formal decision:

> **"CONCEPT A IS SELECTED as the new visual design direction for the entire Orient Flutter monorepo. Concept B and Concept C are rejected. The previous Phase 00 visual direction is superseded for visual design purposes."**

This document establishes **Concept A — Premium Minimal Automotive** as the binding, exclusive visual standard for all future development across `staff_app`, `owner_app`, `customer_app`, `crm_app`, and shared core packages.

---

## 2. Superseded Specifications & Historical Context

The visual grammar established in the historical Phase 00–07A documentation (including `phases/phase_00_foundations/`, `phases/phase_01_shared_core/`, etc.) is now **SUPERSEDED** for all visual design, layout, styling, and aesthetic purposes.

Specifically:
- **Repetitive Card Syndrome** is permanently prohibited.
- **Generic Material 3 Out-of-the-Box Aesthetics** are permanently prohibited.
- **Single-Template Dashboards** (Header + 4 metric boxes + list view) are permanently prohibited.
- **Cosmetic Color-Swapping** without compositional restructuring is permanently rejected.

*Note: Historical documents in `phases/phase_00_foundations/` through `phases/phase_07_staff_workflow_screens/` remain preserved strictly for backend API schemas, offline Hive storage contracts, and domain business logic references.*

---

## 3. Approved Concept A Core Characteristics

Concept A represents an elite, telemetry-driven, vehicle-first aesthetic tailored to luxury automotive service:

### 3.1 Visual Language
- **Canvas & Surfaces**: Ultra-clean chalk/off-white light mode (`#FBFBFD`) with pure white elevated surfaces (`#FFFFFF`); deep obsidian/space-gray dark mode (`#090B10`) with slate cards (`#11141D`).
- **Brand Accent**: Hyper Cobalt. Prototype baseline `#2563EB`; **authorized accessible value `#215FE6`** (WCAG AA across rest/hover/pressed — see `00_CONCEPT_A_DESIGN_SYSTEM.md` §1.1) is the singular high-conviction primary action and brand telemetry color.
- **Typography**: Deep navy-slate headings (`#0F172A`) paired with muted technical slate subtitles (`#64748B`), leveraging **Plus Jakarta Sans** for Latin and **IBM Plex Sans Arabic** for Arabic RTL.
- **Status Telemetry**: Purposeful, high-legibility semantic accents:
  - Precision Emerald (`#10B981`): Verified, passed, active, profitable.
  - Electric Amber (`#F59E0B`): Caution, pending estimate, follow-up required.
  - Brembo Crimson. Prototype baseline `#EF4444`; **authorized accessible value `#DC2626`** (WCAG AA with white ink): Critical failure, urgent safety hazard, overdue.
  - Ice Blue (`#0284C7`): Informational, scheduled, stage indicator.
- **Geometry**: Precision-milled chamfers (`8.0px` small, `12.0px` standard cards, `16.0px` hero sheets). No exaggerated pill shapes for cards.
- **Borders & Dividers**: Crisp, hairline 1.0px borders (`#E2E8F0` light, `#262C3D` dark) replacing heavy drop shadows.

---

## 4. Production Quality Mandate: Addressing Concept Prototype Weaknesses

As explicitly mandated by the Product Owner, **approving the style does NOT mean approving prototype defects**. The prototype provided the visual soul; production implementation must fix all prototype limitations:

1. **Owner Dashboard Charts**: In the prototype, charts were simplified mock bars. In production (Phase 11 & 12), Owner screens must feature multi-axis interactive telemetry, real-time revenue velocity curves, floor occupancy heatmaps, and margin sparklines.
2. **CRM Space Utilization**: In the prototype, CRM screens exhibited excessive unused white space. In production (Phase 15), CRM will utilize dense multi-column Deal Radars, interactive Kanban swimlanes, and split-pane conversation consoles.
3. **Vehicle Diagrams & HUD**: In the prototype, vehicle graphics were basic silhouettes. In production (Phase 07 & 08), vehicle inspection will feature authentic spatial damage maps with 8-angle vehicle profiles, tap-to-pin damage hotspots, and severity badges.
4. **Metric & Value Truncation**: No label or currency value (`AED 48,250.00`) may truncate on standard 390px mobile screens or Arabic RTL layouts.
5. **Arabic Translation Parity**: Mixed-language placeholders in the prototype must be completely replaced with natural, professional Arabic automotive terminology (e.g. `فحص واستلام المركبة`, `رادار الصفقات النشطة`).
6. **Authentication Flow**: The prototype auth card was basic. Production (Phase 05) requires biometric fast-pass, role detection, OTP countdown visualizers, and security telemetry indicators.

---

## 5. Architectural Non-Negotiables

The redesign is strictly a **visual and interaction overhaul**. The following foundations remain 100% frozen and protected:
- **Riverpod State Management**: All existing state notifiers, providers, and stream providers must remain intact.
- **Offline Persistence**: Hive boxes (`advisor_intakes`, `customer_bookings`, `offline_checkins`) must not be broken.
- **Routing & Deep Links**: Canonical `AppRoutes` paths and query parameters must be preserved.
- **Dio HTTP Interceptors**: Network layers and backend DTO schemas must not be altered.
- **100% Bilingual LTR/RTL**: Full parity between English and Arabic layouts across all screens.
