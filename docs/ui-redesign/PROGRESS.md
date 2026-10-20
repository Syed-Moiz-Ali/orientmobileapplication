# Progress tracker

> How to resume: Read `DESIGN_SPEC.md`, `PROGRESS.md` and the "Next session starts here" note, then open the next unchecked phase file, summarize in 5 lines, show a short plan, and wait for my go.

## Next session starts here

- **Phase:** phase-0-foundation (not started)
- **Before starting:** capture "before" screenshots/goldens of customer_app (light + dark) into `docs/ui-redesign/baseline/` as the regression baseline
- **Files in scope:** `packages/shared_core/src/theme/` (tokens, theme, extensions, formatters)
- **Open questions:** Jakarta Sans tabular-figure support (verify in phase 0; if missing, propose a fallback and ask me)

## Working rules (follow every session)

1. **One phase per session.** Do exactly one phase file (or one part/module of a split phase), then stop. Never start the next phase. Per-module phases (11, 14) are one module per session.
2. **Session start:** read DESIGN_SPEC.md, PROGRESS.md and the phase file, summarize in 5 lines, show a short plan, wait for my "go".
3. **Commit after each phase/part.** When QA passes, stop and give me the commit message (`ui(phase-N): <module> - <summary>`) plus `git diff --stat`. Do not commit yourself. Do not start new work on a dirty tree; tell me first. Suggest tags after phases 0, 1 and each finished module (e.g. `ui-phase-1-done`).
4. **Split big phases.** Any phase touching more than ~8 screens or ~40 files is split into parts (3a, 3b, ...) grouped by screen/flow. If a phase turns out too big mid-session, stop at a clean boundary, update this file and tell me to continue in a new session.
5. **Monorepo safety (Melos, 4 apps).** After every part run the analyzer for all packages/apps (`melos run analyze` or `melos exec -- flutter analyze`) and report per app. List which apps each change affects. Changes in `shared_core` / `shared_auth` affect all 4 apps: smoke-check each affected app and list what was verified.
6. **customer_app dark mode must not regress.** Re-check against `docs/ui-redesign/baseline/` whenever shared theme or shared widgets change.
7. **Context hygiene.** Update this file after every part (ticks, decisions, session log, next step). Before ending a session, rewrite the "Next session starts here" note with the exact phase/part, files in scope and open questions.
8. **Ask, don't guess.** If unclear, ask me, then record my answer in the Decisions log.
9. **No dependency changes** beyond the approved list in the Decisions log. Ask first.
10. **Presentation layer only.** Never change business logic, Riverpod providers/state, models, repositories, services, API/Firebase code or go_router behavior.
11. **Goldens are blessed only after visual evaluation.** Never run `--update-goldens` just to make tests pass.
12. **End-of-session report (always):** what changed (file count, main files), QA checklist results, analyzer results per app, apps affected, risks/skipped items, commit message, and the exact prompt to start the next session.

## Phase checklist

- [ ] `phases/phase-0-foundation.md` (includes customer_app before-baseline in `docs/ui-redesign/baseline/`)
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
| 2026-10-20 | decisions | Resolved accent, font, dark scope, l10n merge approach, package approvals. Added working rules and phase 3 split. No .dart touched. | See Risks                                                                     | Start phase-0 (baseline screenshots first) |
