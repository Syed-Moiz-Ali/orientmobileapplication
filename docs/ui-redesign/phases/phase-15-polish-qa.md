# Phase 15 — Polish + QA (consistency sweep, real-device pass, final report)

## 1. Title + Goal
Consistency sweep, micro-interactions, accessibility + performance pass, dead-code removal, and a manual real-device checklist — ending in `FINAL_REPORT.md`.

## 2. Pre-step
Read `docs/ui-redesign/DESIGN_SPEC.md`, `PROGRESS.md`, `MODULES.md` and any previous phase notes. Summarize in 5 lines. Do not touch business logic.

## 3. Scope
Whole workspace presentation layer: forbidden-pattern sweep (zero `Color(0x`/`Colors.`/raw TextStyle/insets/radii/durations/hardcoded strings outside design_system/gallery/tests), dead/duplicate widget removal (old wrappers at zero usages only), unused-dependency check, motion (C7) + const/rebuild/image-cache/list-virtualization perf pass.
Do NOT touch: business logic/services/routing behavior; no new features.

## 4. Design principles
C1–C12 final conformance; C7 press states/page transitions (250ms fade/shared-axis), skeleton 1200ms, count transitions 300ms, reduced-motion; C12 full a11y.

## 5. Step-by-step tasks
1. Grep sweeps (whole app must be zero); remove dead widgets/deps.
2. Micro-interactions + a11y pass (focus order, semantics, contrast both themes, 1.3x/2.0x, notch/safe-area, rotation, keyboard, offline).
3. Perf pass (const, rebuilds, image caching, list virtualization).
4. Fill MANUAL checklist below and hand to user for the real-device pass (≥1 Android phone, 1 iPhone, 1 tablet/web window): small screen 320px, RTL language, longest-string language, large text, dark mode, keyboard, notch/safe areas, rotation, offline.
5. Write `docs/ui-redesign/FINAL_REPORT.md` (before/after, remaining debt, known issues, golden coverage, languages shipped).

## 6. Screen-by-screen plan
Spot-check top screens per module (advisor home/detail, inspection sheet, supervisor dashboard, customer dashboard/tracking, owner dashboard, crm kanban, login) against C14 visual checklist one last time.

## 7. UX writing rules
Final C11 read-through; glossary-consistent; REVIEW_NEEDED.md either cleared by native or explicitly carried as known issue.

## 8. Responsive + accessibility checklist
Real-device matrix in FINAL_REPORT.md; limits honestly stated (goldens ≠ perf/gesture/keyboard/notch proof).

## 9. QA checklist
- [ ] Forbidden greps zero; string grep zero; `flutter analyze` clean; all 4 apps build+run light+dark; goldens green; FINAL_REPORT.md written

## 10. Definition of done
Tick PROGRESS.md all-QA-passed, final session log, commit message (e.g. `ui: final polish + QA (final report)`).

## 11. Ask me first
Anything you want exempted from the zero-grep rule; known issues to carry vs fix.
