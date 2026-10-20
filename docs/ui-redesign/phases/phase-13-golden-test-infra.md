# Phase 13 — Golden test infrastructure (harness + one worked example)

## 1. Title + Goal
Build the deterministic C14 golden harness (fonts, fakes, device matrix, wrappers, naming, comparator, contact sheets) plus ONE fully worked example screen with evaluation report. Then stop for review.

## 2. Pre-step
Read `docs/ui-redesign/DESIGN_SPEC.md`, `PROGRESS.md`, `MODULES.md` and any previous phase notes. Summarize in 5 lines. Do not touch business logic.

## 3. Scope
In scope: `test/goldens/helpers/golden_harness.dart` (theme+delegates+MediaQuery/Directionality/nav-shell wrappers, FontLoader-bundled fonts — NOT Ahem — `debugDisableShadows=false`, fixed clock, fakes at provider/bloc boundary, stubbed network images, frozen shimmer, no randoms), device-matrix runner, `test/goldens/<module>/<screen>/<state>/<device>_<theme>_<locale>_ts<scale>.png` naming, tolerant comparator doc (≤0.5% if mixed OS), contact-sheet script → `docs/ui-redesign/evaluation/contact-sheets/`; ONE example screen full matrix + `evaluation/<module>.md` row. Ask before adding alchemist.
Do NOT touch: app logic; blessing baselines beyond the example.

## 4. Design principles
C14 determinism + matrix (CORE phone-compact/standard/tablet-portrait/tablet-landscape/desktop × light/dark × loaded/loading/empty/error × 1.0; STRESS phone-small/large + 1.3x/2.0; LOCALE compact+tablet-portrait × every language incl. RTL) + automated checks (`takeException()==null`, tap-target + contrast guidelines).

## 5. Step-by-step tasks
1. Build harness + wrappers (real AppTheme, localizations, safe-area/notch MediaQuery, Directionality, nav shell).
2. Encode matrix + naming + platform doc (ONE consistent platform) + comparator if needed.
3. Write golden tests for ONE screen (suggest shared_auth login_view — small, high-value); generate to STAGING (not baselines); build contact sheets (PIL/Dart).
4. VIEW the PNGs against C14 checklist; write `evaluation/<module>.md` example rows; fix UI; regenerate; bless ONLY the example; `flutter test` green. STOP for review.

## 6. Screen-by-screen plan
Example: login_view × (compact/standard/tablet/desktop + small/large stress) × (light/dark) × (loaded/loading/error) × (1.0/1.3) × (en + ar). List skipped combos with reasons.

## 7. UX writing rules
N/A (infrastructure) — example screen copy already per C11.

## 8. Responsive + accessibility checklist
Automated: RenderFlex overflow fail, android/iOS/labeled tap-target + text-contrast guidelines on key screens.

## 9. QA checklist
- [ ] Deterministic reruns byte-identical; matrix runner covers CORE/STRESS/LOCALE naming; contact sheets built; example evaluated + blessed; `flutter test` passes after bless; analyzer clean

## 10. Definition of done
Update PROGRESS.md, session log, commit message (e.g. `test(goldens): harness + matrix + login example evaluated`). STOP — wait for review before phase-14.

## 11. Ask me first
alchemist approval; golden platform choice; tolerance %; which screen is the example (default: login_view).
