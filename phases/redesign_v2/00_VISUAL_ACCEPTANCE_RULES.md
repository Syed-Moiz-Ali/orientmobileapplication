# 00 — Visual & Engineering Acceptance Rules (Redesign v2)

**Document ID:** `phases/redesign_v2/00_VISUAL_ACCEPTANCE_RULES.md`  
**Standard:** ZERO PHANTOM APPROVALS  
**Authority:** Product Owner & Principal Systems Architect  
**Status:** ENFORCED BINDING QUALITY CRITERIA  

---

## 1. The Core Acceptance Principle

In earlier phases, development was mistakenly marked complete because static analysis succeeded, unit tests passed, and widgets were mechanically replaced. **This produced generic, visually monotonous screens that failed product owner review.**

In Redesign v2:
> **A phase is NOT complete until it satisfies BOTH the Engineering Verification Gate AND the Visual Aesthetic Acceptance Gate.**

No phase may be closed without human-verifiable visual evidence (real screenshot captures with loaded fonts).

---

## 2. Gate 1: Engineering Verification Criteria (Strict Pass Required)

For every phase:
1. **Dart Analysis:** `dart analyze lib test` must exit with `0 errors` and `0 warnings`.
2. **Automated Unit & Widget Tests:** `flutter test` must pass 100% across all unit and widget tests covering the affected module.
3. **No Breaking API Changes:** Existing Riverpod providers, Dio network interceptors, Hive offline boxes, and GoRouter route paths must function without regressions.
4. **Localization Coverage:** All user-facing strings must use localization keys (`context.l10n.*` or `AppLocalizations`). Zero hardcoded raw strings.

---

## 3. Gate 2: Visual Aesthetic Acceptance Criteria (Human Verification Required)

For every screen redesigned in a phase:
1. **Concept A Identity Fidelity:**
   - Backgrounds adhere to `#FBFBFD` (light) / `#090B10` (dark).
   - Surfaces adhere to `#FFFFFF` (light) / `#11141D` (dark) with crisp 1px borders (`#E2E8F0` / `#262C3D`).
   - Primary action buttons use Hyper Cobalt (`#215FE6`, the authorized accessible amendment to the `#2563EB` prototype baseline) with 8px chamfered corners.
   - Deep navy slate typography (`#0F172A`) for English headings; crisp white (`#F8FAFC`) in dark mode.
2. **Dedicated Archetype Adherence:**
   - Screen composition reflects its designated archetype (e.g. Tactical Radar, Inspection HUD, Digital Garage).
   - Prohibited: Generic "4 metric boxes + vertical list" template.
3. **Responsive Visual Integrity:**
   - Validated at **390px (Mobile)**, **768px (Tablet)**, and **1280px (Desktop)**.
   - Zero `RenderFlex overflow` errors.
   - Text wrapped with `Expanded`/`Flexible` and ellipsis handling.
   - Wide tables transform into responsive cards on mobile.
4. **Bilingual RTL Mirroring & Non-Mirroring Parity:**
   - Arabic layout renders naturally with **IBM Plex Sans Arabic**.
   - No untranslated English strings in Arabic screens.
   - Strict adherence to non-mirroring exceptions (vehicle damage maps, VINs, number plates, phone numbers, and currencies).
5. **No Wireframe / Box Placeholders:**
   - Automated golden tests must load real fonts via `showcase_font_loader.dart` or equivalent so golden PNGs render actual readable text.
   - Vehicle diagrams must be detailed, production-quality vectors, not simple gray silhouette boxes.

---

## 4. Phase Completion Sign-Off Protocol

At the conclusion of each phase:
1. Generate a Phase Completion Report in `phases/redesign_v2/reports/REPORT_PHASE_XX.md`.
2. Attach links to the updated golden screenshot captures in `test/goldens/`.
3. Verify that the previous phase report is referenced and all prerequisite gates were satisfied.
4. Stop execution and await explicit user review before commencing the subsequent phase.
