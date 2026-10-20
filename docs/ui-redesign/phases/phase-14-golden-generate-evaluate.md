# Phase 14 — Golden generate + evaluate (per-module checklist)

## 1. Title + Goal
Generate, LOOK AT, and fix every screen until zero C14 failures, then bless baselines. One module per session.

## 2. Pre-step
Read `docs/ui-redesign/DESIGN_SPEC.md`, `PROGRESS.md`, `MODULES.md` and any previous phase notes. Summarize in 5 lines. Do not touch business logic.

## 3. Scope
Per module in MODULES.md order (M2→M8): golden tests for every screen × every state; staging generation; contact sheets; `evaluation/<module>.md` (Screen|Device|Theme|Locale|Scale|pass-fail|Issues|Fix|Re-verified); UI fixes (presentation only); regenerate until zero fails; bless + commit. Never `flutter test --update-goldens` to force green — bless only after visual evaluation.
Do NOT touch: business logic; translations (phase-12 frozen); harness design (phase-13 frozen except bugfixes).

## 4. Design principles
Full C14: layout/hierarchy/spacing/grid/typography/components/color/responsiveness/states/scale/locale-RTL checklist per image; harsh reviewer ("report what's wrong, name the files").

## 5. Step-by-step tasks (repeat per module)
1. Write tests for module screens/states; generate to staging; build contact sheets.
2. VIEW every PNG/contact sheet; fill `evaluation/<module>.md`.
3. Fix UI issues; regenerate; re-evaluate until zero fails.
4. Bless baselines; `flutter test` green; CI shows diffs as review artifacts; tick PROGRESS.md goldens columns; commit per module.

## 6. Screen-by-screen plan
Checklist mirrors MODULES.md: auth → advisor-core → inspection → sup/tech/common → customer → owner → crm. Each lists matrix variants + skipped combos.

## 7. UX writing rules
Fix only overflow/truncation copy issues; no new strings without ARB path.

## 8. Responsive + accessibility checklist
Per-image C14: compact single-col+nav; medium 2-col/sheets; expanded rail+max-width; tables→cards; 1.3x/2.0x; RTL mirror; AA.

## 9. QA checklist (per module)
- [ ] Staging evaluated (contact sheets inspected, report written); zero fails; baselines blessed; `flutter test` passes; analyzer clean; UI-only diff outside `test/goldens/`

## 10. Definition of done
Update PROGRESS.md per module, session log, commit per module (e.g. `test(goldens): bless customer matrix (evaluated)`).

## 11. Ask me first
Any image you want to bless despite a minor issue (list it); platform drift if CI differs.
