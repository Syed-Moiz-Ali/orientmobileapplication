# Phase 12 — l10n translations, RTL, fonts, language picker

## 1. Title + Goal
Ship every agreed language with natural UI translations, full RTL mirroring, script fonts, and an in-app language picker. Flag uncertain translations for native review.

## 2. Pre-step
Read `docs/ui-redesign/DESIGN_SPEC.md`, `PROGRESS.md`, `MODULES.md` and any previous phase notes. Summarize in 5 lines. Do not touch business logic.

## 3. Scope
In scope: source ARB → each agreed language (respect DECISIONS.md + existing en/ar ARBs); `REVIEW_NEEDED.md`; language picker (Settings row → AppBottomSheet list, native names + English secondary, current ✓, System default first); RTL mirroring pass (`EdgeInsetsDirectional/AlignmentDirectional/start/end`, chevron flip, bidi isolates); script fonts + line-height tuning; platform configs (CFBundleLocalizations, resourceConfigurations, web lang/dir); plural/format unit tests + locale-switch widget test; manual smoke list per language.
Do NOT touch: business logic, golden baselines (phase-14).

## 4. Design principles
C15 (natural — not literal — translations, C11 tone, short strings, glossary-consistent, brand terms untranslated); C3 script fallbacks; C4/C12 (+40% growth, tall scripts, no truncation of primary content).

## 5. Step-by-step tasks
1. Produce translations per DECISIONS.md; write REVIEW_NEEDED.md with context per uncertain key; never claim verified.
2. Build picker UI from design-system widgets only; wire LocaleController persist + localeResolutionCallback fallback.
3. RTL pass over phases 2–8 files; font fallback bundles (only chosen scripts) + glyph check (no tofu); plural/format tests green.
4. Manual smoke per language (checklist in file).

## 6. Screen-by-screen plan
Per language: auth → advisor → customer → owner → crm spot-pass (mirroring, numerals/dates, long-string wrap, direction-flip icons, charts LTR unless agreed otherwise).

## 7. UX writing rules
Claude-drafted translations flagged; glossary in `l10n/GLOSSARY.md` enforced; REVIEW_NEEDED.md context for natives.

## 8. Responsive + accessibility checklist
Every RTL language on phone-compact + tablet-portrait; 1.3x + longest-string language; focus order mirrored; semantics localized.

## 9. QA checklist
- [ ] All ARBs complete w/ identical placeholders; `gen-l10n` clean; tests pass; picker works + persists; RTL verified; fonts render; `flutter analyze` clean

## 10. Definition of done
Update PROGRESS.md (languages shipped), session log, commit message (e.g. `l10n: add ar+… translations, RTL pass, language picker`).

## 11. Ask me first
Any translation tradeoff (length vs fidelity); numeral system per locale; chart-axis direction in RTL.
