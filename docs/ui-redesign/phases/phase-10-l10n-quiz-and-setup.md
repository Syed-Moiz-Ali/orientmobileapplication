# Phase 10 — l10n quiz + setup (infrastructure only)

## 1. Title + Goal
Decide languages with the user, then build the ONE official Flutter localization setup (no parallel string systems). Stop after 3 sample screens.

## 2. Pre-step
Read `docs/ui-redesign/DESIGN_SPEC.md`, `PROGRESS.md`, `MODULES.md` and any previous phase notes. Summarize in 5 lines. Do not touch business logic.

## 3. Scope
In scope: C15 quiz → `docs/ui-redesign/l10n/DECISIONS.md`; dependency proposal (flutter_localizations/intl/script fonts) for approval; `l10n.yaml`, `lib/l10n/app_<locale>.arb` template + `AppLocalizations` (`context.l10n`), `LocaleController` (existing state mgmt + storage, System default, fallback), locale-aware `formatters.dart`, font fallbacks (Noto per chosen scripts), platform configs, pseudo-locale, ARB consistency check, `GLOSSARY.md` skeleton; migrate `app_strings.dart` → ARB (delete Dart constants at zero usages); 3 sample screens as proof. NOTE: en+ar ARBs already exist in all 4 apps + core/auth — MERGE, don't greenfield.
Do NOT touch: remaining screens' strings (phase-11), translations (phase-12), logic.

## 4. Design principles
C15 architecture only; C11 tone preserved in source strings; C4/C12 (RTL mirroring prep: Directional widgets, start/end, bidi isolates for numbers/IDs).

## 5. Step-by-step tasks
1. FIRST run the C15 quiz via AskUserQuestion (3–4 Qs/round): launch languages + phase-2 laters; default/fallback; device vs in-app switcher + persist; RTL set; translation source + glossary terms; regional formats/numerals/week-start/12v24h; backend-sourced text policy; platforms; font approval. Summarize + confirm; write DECISIONS.md + PROGRESS.md.
2. Propose dependency list; WAIT for approval; then implement `l10n.yaml`/ARB/`gen-l10n`/`context.l10n`/`LocaleController`/formatters/fontFallback/platform locale config/pseudo-locale/consistency script.
3. Migrate 3 sample screens end-to-end; `flutter gen-l10n` clean; untranslated-messages reviewed.

## 6. Screen-by-screen plan
3 proof screens (e.g. shared_auth login_view + customer dashboard + staff advisor home): keys `<module>_<screen>_<element>` + `@key` descriptions, typed placeholders, ICU plural/select, no concatenation, no HTML.

## 7. UX writing rules
Source-language strings per C11; placeholders typed; glossary terms untranslated (product/tickers/codes).

## 8. Responsive + accessibility checklist
RTL mirroring from day one (chevrons/back flip, numbers LTR-isolated); +40% growth room; tall-script line-heights; no fixed-height text.

## 9. QA checklist
- [ ] Quiz answered + DECISIONS.md; deps approved; `flutter gen-l10n` clean; consistency check passes; 3 screens proof in light+dark; `flutter analyze` clean

## 10. Definition of done
Update PROGRESS.md (languages/RTL/fallback/source decisions), session log, commit message (e.g. `l10n: quiz decisions + gen-l10n infrastructure (3-screen proof)`). Then STOP.

## 11. Ask me first
Everything in the C15 quiz — ask before any code.
