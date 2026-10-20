# Phase 11 — l10n migrate strings (per-module checklist)

## 1. Title + Goal
Move every remaining user-facing string into ARB with metadata/placeholders/plurals, one module per session, in MODULES.md order.

## 2. Pre-step
Read `docs/ui-redesign/DESIGN_SPEC.md`, `PROGRESS.md`, `MODULES.md` and any previous phase notes. Summarize in 5 lines. Do not touch business logic.

## 3. Scope
Per module (M2→M8 order): all `Text(`/hardcoded titles/labels/errors/validation/empty states in that module's files → `context.l10n` + ARB keys (`<module>_<screen>_<element>`, shared `common_*`); `Left/Right→Start/End`; hardcoded formats → locale-aware formatters.
Do NOT touch: translations (phase-12), logic/providers, already-migrated phase-10 proof screens except fixes.

## 4. Design principles
C15 ARB rules (descriptions, typed placeholders, plural/select, no concatenation/HTML, rich text via spans); C11 tone; RTL-safe layout primitives.

## 5. Step-by-step tasks
For EACH module: grep strings → add ARB keys + metadata → replace usages → fix alignment/format calls → run analyzer + boot app + string-grep → tick PROGRESS.md module row. One module per session; stop between modules if large (staff advisor split across sessions).

## 6. Screen-by-screen plan
Checklist (MODULES.md order): shared-auth → staff-advisor-core → inspection → sup/tech/common → customer → owner → crm, each with file list from MODULES.md + key inventory.

## 7. UX writing rules
Keep C11 copy; flag unclear meanings in COPY_QUESTIONS.md rather than guessing; glossary-consistent.

## 8. Responsive + accessibility checklist
Directional widgets only; icons flip check; numbers/IDs LTR isolates; no fixed-height text; 1.3x spot-check per module.

## 9. QA checklist (per module)
- [ ] No hardcoded strings in module (grep); `flutter gen-l10n` clean; consistency script passes; analyzer clean; app boots light+dark; UI-only diff

## 10. Definition of done
Tick PROGRESS.md localized-column per module, session log per session, commit per module (e.g. `l10n(customer): migrate strings to ARB`).

## 11. Ask me first
Ambiguous strings (COPY_QUESTIONS.md); any key-naming conflicts with existing en/ar ARBs.
