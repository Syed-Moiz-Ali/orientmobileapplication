# Progress tracker

> How to resume: Read `DESIGN_SPEC.md`, `PROGRESS.md` and the "Next session starts here" note, then open the next unchecked phase file, summarize in 5 lines, show a short plan, and wait for my go.

## Next session starts here

- **Phase:** phase-0b-tokens (Parts 0a + 0a-2 safety net are DONE and committed)
- **Before starting:** read DESIGN_SPEC.md, this file and phases/phase-0-foundation.md; confirm the 5 baselines in `docs/ui-redesign/baseline/` are on disk
- **Files in scope:** `packages/shared_core/src/theme/` (+ `src/localization/formatters` if touched) — additive only, no renames/deletes, zero component-theme geometry edits; `docs/ui-redesign/DESIGN_SYSTEM.md` (new)
- **Must do at the end:**
  1. Add a token swatch capture (tagged baseline, light + dark) rendering every new token: accent, accentPressed, accentSoft, lighter dark accent, info family (chip, banner, soft, border, ink), semantic success/warning/error next to info, plus text-on-accent and text-on-soft samples with measured AA ratios printed in the image. View the images and judge: info must not be confusable with success or accent.
  2. The 5 login baselines must still match; list any difference.
  3. Verify with `tool/analyze_all.sh`.
- **Token decisions (locked):** accent `#215FE6` family + accentPressed/accentSoft + lighter dark accent; `info` moves to teal-cyan from `#0E7490` (derive soft/border/ink + lighter dark variant); AA ratios reported for text-on-accent, accent-on-surface, every soft tint (adjust until pass); dark tokens defined but NOT wired for staff/owner/CRM.
- **Open questions:** none blocking (tnum verified present; tabular fallback OK)

## Working rules (follow every session)

1. **One phase per session.** Do exactly one phase file (or one part/module of a split phase), then stop. Never start the next phase. Per-module phases (11, 14) are one module per session.
2. **Session start:** read DESIGN_SPEC.md, PROGRESS.md and the phase file, summarize in 5 lines, show a short plan, wait for my "go".
3. **Commit after each phase/part.** When QA passes, stop and give me the commit message (`ui(phase-N): <module> - <summary>`) plus `git diff --stat`. Do not commit yourself. Do not start new work on a dirty tree; tell me first. Suggest tags after phases 0, 1 and each finished module (e.g. `ui-phase-1-done`).
4. **Split big phases.** Any phase touching more than ~8 screens or ~40 files is split into parts (3a, 3b, ...) grouped by screen/flow. If a phase turns out too big mid-session, stop at a clean boundary, update this file and tell me to continue in a new session.
5. **Monorepo safety (4 apps + 3 packages).** After every part run `tool/analyze_all.sh` (per-package `flutter analyze --no-pub` with pass/fail summary; non-zero on failure) and report per package. Use `tool/test_all.sh` for the test suite (`flutter test --exclude-tags baseline`). Do NOT use melos until it is fixed separately (broken in this env: no scripts in root pubspec / 0 packages discovered). List which apps each change affects. Changes in `shared_core` / `shared_auth` affect all 4 apps: smoke-check each affected app and list what was verified.
6. **customer_app dark mode must not regress.** Re-check against `docs/ui-redesign/baseline/` whenever shared theme or shared widgets change.
7. **Context hygiene.** Update this file after every part (ticks, decisions, session log, next step). Before ending a session, rewrite the "Next session starts here" note with the exact phase/part, files in scope and open questions.
8. **Ask, don't guess.** If unclear, ask me, then record my answer in the Decisions log.
9. **No dependency changes** beyond the approved list in the Decisions log. Ask first.
10. **Presentation layer only.** Never change business logic, Riverpod providers/state, models, repositories, services, API/Firebase code or go_router behavior.
11. **Goldens are blessed only after visual evaluation.** Never run `--update-goldens` just to make tests pass.
12. **End-of-session report (always):** what changed (file count, main files), QA checklist results, analyzer results per app, apps affected, risks/skipped items, commit message, and the exact prompt to start the next session.

## Phase checklist

- [ ] `phases/phase-0-foundation.md`
  - [x] Part 0a safety net (baselines + guard test + font check, no theme changes)
  - [x] Part 0a-2 (real icons in harness via SDK MaterialIcons FontLoader, tool/*.sh scripts)
  - [ ] Part 0b tokens (additive only, DESIGN_SYSTEM.md, swatch capture + baseline re-diff)
- [ ] `phases/phase-1-shared-widgets.md`
- [ ] `phases/phase-2-shared-auth.md`
- [ ] `phases/phase-3-staff-advisor-core.md` (split, confirm the real grouping from actual screens before starting)
  - [ ] 3a: home + jobs list
  - [ ] 3b: job detail + check-in + assign
  - [ ] 3c: reports + scan + vehicle/customer + delivery
- [ ] `phases/phase-4-staff-advisor-inspection.md` (split if it exceeds ~8 screens / ~40 files; canvas + vehicle SVG map are highest risk)
- [ ] `phases/phase-5-staff-supervisor-technician-common.md` (split suggested: supervisor tabs / technician / common)
- [ ] `phases/phase-6-customer.md` (split if needed; dark mode must not regress)
- [ ] `phases/phase-7-owner.md`
- [ ] `phases/phase-8-crm.md`
- [ ] `phases/phase-9-ux-writing.md`
- [ ] `phases/phase-10-l10n-quiz-and-setup.md` (merge existing en/ar ARBs; 3-screen proof, then stop)
- [ ] `phases/phase-11-l10n-migrate-strings.md` (one module per session)
  - [ ] shared_auth
  - [ ] staff advisor core
  - [ ] staff inspection & repair
  - [ ] staff supervisor / technician / common
  - [ ] customer
  - [ ] owner
  - [ ] CRM
- [ ] `phases/phase-12-l10n-translations-rtl-picker.md`
- [ ] `phases/phase-13-golden-test-infra.md` (harness + matrix + 1 worked example, then stop)
- [ ] `phases/phase-14-golden-generate-evaluate.md` (one module per session)
  - [ ] shared_auth
  - [ ] staff advisor core
  - [ ] staff inspection & repair (needs deterministic stubbing for canvas + SVG map)
  - [ ] staff supervisor / technician / common
  - [ ] customer (light + dark)
  - [ ] owner
  - [ ] CRM
- [ ] `phases/phase-15-polish-qa.md` (sweeps, real-device checklist, FINAL_REPORT.md)

## Module table

| Module                     | Phase file         | Apps affected | Redesigned | States added | Strings centralized | Localized | Goldens generated | Evaluated & fixed | QA passed |
| -------------------------- | ------------------ | ------------- | ---------- | ------------ | ------------------- | --------- | ----------------- | ----------------- | --------- |
| Foundation (M0)            | phase-0            | all 4         |            |              |                     |           |                   |                   |           |
| Shared widgets (M1)        | phase-1            | all 4         |            |              |                     |           |                   |                   |           |
| Auth (M2)                  | phase-2            | all 4         |            |              |                     |           |                   |                   |           |
| Staff advisor core (M3)    | phase-3 (3a/3b/3c) | staff         |            |              |                     |           |                   |                   |           |
| Staff inspection (M4)      | phase-4            | staff         |            |              |                     |           |                   |                   |           |
| Staff sup/tech/common (M5) | phase-5            | staff         |            |              |                     |           |                   |                   |           |
| Customer (M6)              | phase-6            | customer      |            |              |                     |           |                   |                   |           |
| Owner (M7)                 | phase-7            | owner         |            |              |                     |           |                   |                   |           |
| CRM (M8)                   | phase-8            | CRM           |            |              |                     |           |                   |                   |           |

## Decisions log

- **Accent color:** keep existing brand `#215FE6` (guard test stays untouched and passing). Derive `accentPressed` / `accentSoft` and a lighter dark variant, verify AA contrast. Move the `info` token off blue (slate/teal) so it does not clash with accent. (Spec default #FF385C is NOT used.)
- **Font:** keep Plus Jakarta Sans Variable + IBM Plex Sans Arabic. Verify tabular-figure support in phase 0; if missing, propose a fallback and ask me.
- **Theme default:** light-first. Dark stays off for staff / owner / CRM until each module passes its dark golden evaluation. customer_app dark must not regress (baseline in `docs/ui-redesign/baseline/`).
- **Skipped modules:** none (CRM last but not skipped).
- **Localization:** merge into existing en + ar ARBs (per app + core/auth). Do NOT rename existing keys (up to 2510 in staff). New keys use `<module>_<screen>_<element>`. Keep per-app gen-l10n with shared core/auth ARBs as the common base (no single giant ARB). Quiz skips en/ar and asks only about additional languages, fallback, switcher behavior, regional formats, backend text, platforms and fonts. RTL goldens are mandatory.
- **Packages:** approved: `shimmer`. Not approved: `alchemist` (use our own golden harness), `lucide_icons` (stay with the current icon set). `cached_network_image`: ask before adding. Script fonts (Noto Devanagari etc.) only if the l10n quiz requires them. Reuse existing fl_chart / svg.
- **Golden platform + threshold:** pending phase-13 (use one consistent platform; tolerant comparator <= 0.5% if needed).
- **Phase-0a findings (2026-10-20):** referenced `theme_primary_guard_test.dart` never existed (comments only) — added `packages/shared_core/test/theme_primary_guard_test.dart`, green. `tnum` IS in Jakarta Variable GSUB (fontTools) and runtime widths are equal (15.3px all digits); Plex Arabic fallback resolves. Hive file I/O hangs under the testWidgets FakeAsync clock (proven by probe) → all async backend/font setup lives in `setUpAll`, auth-restore pumps run inside `tester.runAsync` + real 1s delay + transition pumps. Icons render as tofu in harness (MaterialIcons not FontLoader-loaded — deterministic on this machine; phase-15 real-device pass covers true icons). connectivity_plus uses method `check` (v7 platform interface) as well as `checkConnectivity` — both mocked offline. `melos run analyze` / `melos exec` are broken in this env (no scripts in root pubspec / 0 packages discovered — pre-existing); 0a used per-package `flutter analyze --no-pub`, all 7 green.
- **Golden risk subjects:** inspection canvas (`real_damage_canvas.dart`) and vehicle SVG map need fixed fake data and deterministic rendering.
- **Languages / RTL / fallback / translation source:** pending l10n quiz (phase-10). Existing: en + ar in all 4 apps and core/auth.

## Risks

- Shared theme/widget changes affect all 4 apps at once: verify each affected app after every shared change.
- Dark-mode breakage expected in staff/owner/CRM (`Colors.white/black` everywhere), which is why dark stays off there for now.
- ARB merge complexity (large existing key sets, 688 hardcoded Texts in staff advisor).
- Canvas + SVG map goldens are the hardest to make deterministic.

## Session log

| Date       | Phase     | What changed                                                                                                                        | Risks                                                                         | Next step                                  |
| ---------- | --------- | ----------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- | ------------------------------------------ |
| 2026-10-20 | init      | Analyzed 439 lib files; wrote DESIGN_SPEC/AUDIT/MODULES/PROGRESS + 16 phase files. No .dart touched.                                | Token conflict (#215FE6 vs #FF385C); ARB merge complexity; dark-only-customer | Record decisions, then start phase-0       |
| 2026-10-20 | decisions | Resolved accent, font, dark scope, l10n merge approach, package approvals. Added working rules and phase 3 split. No .dart touched. | See Risks | Start phase-0 (baseline screenshots first) |
| 2026-10-20 | phase-0a | Safety net done: 5 baselines (`customer_light/dark`, `staff/owner/crm_light`, real fonts+shadows, login screens verified by eye), primary guard test (3/3 green), font tnum check (GSUB + runtime, green). melos.yaml test scripts now `--exclude-tags baseline`. No app/theme code changed. | Tofu icons in harness (documented); melos scripts broken in env (used per-package analyze) | Commit 0a, then start phase-0b (tokens) |
| 2026-10-20 | phase-0a2 | Icons fixed: MaterialIcons FontLoader from SDK path in all 4 harnesses (all pubspecs have `uses-material-design`; zero Cupertino/custom fonts in captured screens); all 5 baselines re-captured, viewed (real icons), compare re-runs byte-identical. Added `tool/analyze_all.sh` + `tool/test_all.sh` (Git Bash runnable); rules now mandate the scripts over melos. No app/theme code changed. | Baseline PNGs replaced with icon versions (expected diff vs 0a: icons only) | Commit 0a-2, then start phase-0b (tokens + swatch capture) |
