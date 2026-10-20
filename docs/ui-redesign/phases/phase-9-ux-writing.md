# Phase 9 — UX writing (centralize + plain language)

## 1. Title + Goal
Centralize every user-facing string and rewrite jargon into calm plain language with tooltips for technical terms.

## 2. Pre-step
Read `docs/ui-redesign/DESIGN_SPEC.md`, `PROGRESS.md`, `MODULES.md` and any previous phase notes. Summarize in 5 lines. Do not touch business logic.

## 3. Scope
In scope: all strings touched in phases 2–8; `lib/core/strings/app_strings.dart` (or existing ARB if team prefers — but NO parallel systems; decide once) + per-module call sites; `docs/ui-redesign/COPY_QUESTIONS.md`.
Do NOT touch: logic, ARB translation values yet (phase-12), routing.

## 4. Design principles
C11 (sentence case, active voice, verb-first buttons, what+next errors, STATUS pattern, formatters for numbers/dates/currency/relative time); C8 InfoTooltip/Details expanders.

## 5. Step-by-step tasks
1. Grep `Text('`, `Text("`, `title: '` etc. per module (MODULES.md order); move into `app_strings.dart` (or ARB — confirm) with `<module>_<screen>_<element>` keys.
2. Rewrite per C11: hero sentences, status chip labels + why-sentences, empty/error states, button verbs, validation messages; unify number/date formats via `formatters.dart`.
3. Add InfoTooltips for VIN/sync/QC/AR/pipeline technical terms; keep term available, never default.
4. Write `COPY_QUESTIONS.md` for ambiguous strings; stop and ask before guessing business meaning.

## 6. Screen-by-screen plan
Per module (phase 2–8 order): list of jargon found → replacement + tooltip decision → states copy (loading/empty/error/offline/success) → formatter applied.

## 7. UX writing rules
This phase IS C11. Max 2 lines for empty/error; no ALL CAPS; no "Submit/OK"; no raw exceptions; thousands separators; explicit +/- deltas.

## 8. Responsive + accessibility checklist
Long rewritten strings must wrap at 320px + 1.3x; no fixed-height text containers; semantics unchanged.

## 9. QA checklist
- [ ] Hardcoded-string grep zero outside design_system/gallery/tests; `flutter analyze` clean; UI-only diff; all screens boot light+dark

## 10. Definition of done
Update PROGRESS.md (strings-centralized column), session log, commit message (e.g. `copy: centralize strings + plain-language pass`).

## 11. Ask me first
Any string whose business meaning is unclear (list in COPY_QUESTIONS.md); brand/ticker terms that must NOT change.
