# PHASE 20 — Final Validation

## A. Phase identity

- **Phase number:** 20
- **Title:** Final Validation (accessibility, EN/AR + RTL audit, responsive matrix, regression, visual consistency, performance, documentation)
- **Objective:** Independently audit the completed family-wide redesign against the design specification and quality standards, fix only audit findings within a bounded scope, and produce the final compliance report. This phase audits; it does not redesign.
- **Priority:** Critical (release gate)
- **Dependencies:** Phases 00–19 (all, including split units: 03A/03B, 07A/07B,
  13A/13B, 15A/15B, 19A/19B/19C)
- **Estimated scope:** Large (audit + bounded fixes)

## B. Repository context

- All four apps + `shared_core` + `shared_auth` as redesigned by Phases 00–19
  (Phase 00's prototype lives in `apps/design_prototype/` and owns no
  production screen; its approved direction is frozen in
  `00_VISUAL_DIRECTION.md`).
- Design authority: `00_DESIGN_SYSTEM_SPEC.md` (§8 accessibility, §9 l10n/RTL,
  §13 density, §15 consistency, §16 anti-patterns, §17 DoD) +
  `00_VISUAL_DIRECTION.md` (frozen visual values).
- Responsive strategy: `00_RESPONSIVE_STRATEGY.md` §4b + §5 verification matrix.
- Localization strategy: `00_LOCALIZATION_RTL_STRATEGY.md` §2–§9 (incl. §8.3
  cross-boundary tests).
- CI: `.github/workflows/ci.yml` (analyze, tests, backend, E2E, APK builds).
- Phase reports from 00–19 (each phase's section L output) list intentional
  changes, goldens, known limitations, and J2 evidence packs at
  `phases/reports/PHASE_XX/` — the audit starts from those lists and verifies
  every phase's evidence pack exists and is named per convention.

## C. Design objectives

Run a disciplined audit with concrete evidence, fix findings, and prove:

1. **Consistency:** no hand-rolled duplicates remain in redesigned files
   (hex colors, magic radii, ad-hoc search fields, custom shells, dead
   affordances); deprecation lists from Phases 03A/03B fully executed; every
   phase's J2 evidence pack present.
2. **Accessibility:** spec §8 verified app-wide: no text-scale locks; contrast;
   semantics labels localized; focus rings; 48 px targets; reduce-motion;
   dialog dismissibility; screen-reader copy.
3. **Bilingual completeness:** EN + AR full coverage per app; RTL mirroring
   app-wide (nav, tables, timelines, charts, sheets, calendars); number/date/
   currency formatting; identifier policy.
4. **Responsive matrix:** each app's key flows verified at 320/390/430/600/768/
   1024/1280/1440 widths (per strategy §5) with no overflow, no stretched
   forms, no tiny desktop controls on touch.
5. **Regression safety:** full test suite + goldens + CI-equivalent local runs
   green; route/provider/API/permission audit proves contracts untouched.
6. **Performance sanity:** no new jank sources (unbounded rebuilds in shells,
   oversized blur/shadows, unnecessary full-page reprojections); app startup
   unaffected; list performance at realistic sizes; chart render cost bounded.
7. **Documentation:** README/analysis docs updated with final status; residual
   issues logged.

## D. Screens and workflows

All screens from `00_SCREEN_COVERAGE_MATRIX.md` are audited. Audit method per
app:

1. Static sweep (rg): hex colors, `Colors.white|black`, `EdgeInsets.only(left:
   right:)`, `Directionality(`, `TextScaler(`, `MaterialPageRoute(` in
   redesigned files, hard-coded English in redesigned files (excluding
   documented identifier exceptions), `showModalBottomSheet(` outside
   `shared_core`.
2. Test sweep: run every suite in EN and AR (locale override harness).
3. Visual sweep: representative screens per app at the matrix widths, EN/AR,
   1.0/1.3× scale; dark mode smoke (one pass per app with `ThemeMode.dark`
   enabled via test harness only).
4. Workflow walkthrough (widget/integration tests where feasible): one critical
   end-to-end per app:
   - Staff: intake → inspection → estimate (fixtures) — states only, no network.
   - Owner: dashboard → job card detail, inventory adjust, attendance.
   - Customer: booking wizard → success → detail; approvals decision.
   - CRM: lead create → status change → task toggle.

## E. Responsive specifications

Execute `00_RESPONSIVE_STRATEGY.md` §5 matrix per app. Required evidence per app:
a table of screens × widths with pass/fail, overflow findings, and fixes
applied. Fix scope is bounded to responsive defects (padding, wrapping, layout),
not redesign.

## F. Localization and RTL

- EN/AR strings sweep per app (rg for the app's hard-coded English in
  `lib/features/**`, excluding documented identifiers).
- RTL mirroring audit checklist per app: rail side, bottom bar order, back/
  chevron icons, tables, timelines, charts, sheets, calendars, progress.
- Formatting audit: dates, times, numbers, money, plurals.
- Fix scope bounded to localization defects (missing keys, un-mirrored
  icons/insets, formatting bugs).

## G. Design system integration

- Confirm every deprecated kit is gone or explicitly retained with a documented
  reason (Phases 03A/03B deprecation appendix vs actual).
- Confirm no file outside `shared_core`/`shared_auth` defines its own color or
  type tokens.
- Update `00_DESIGN_SYSTEM_SPEC.md` §7 registry if any component was added or
  changed in 01–19 (keep the spec authoritative post-redesign).

## H. Technical implementation

- Fixes only within audit findings; each fix gets a one-line rationale and a
  test where behavior changed.
- No route/provider/API/permission changes — re-verify with:
  - route inventory diff per app (`app_router.dart` paths, extras),
  - provider name/API diff (grep class names in the phase reports vs current),
  - `shared_models`/`shared_core` model field diff,
  - permission checks diff (`_isRouteAllowedForRole`, role gates).
- Verify CI-equivalents locally: `melos run analyze`, `melos run test`, and
  each app's release build still applies (smoke `flutter build apk --debug` per
  app is sufficient if release signing is unavailable; document).

## I. Functional preservation

- Run every existing test unmodified-or-intentionally-updated per phase reports;
  no phase may have left an "update later" test failing.
- Golden inventory: every golden regenerated in 01–19 is accounted for; no
  stale baselines (run with `--update-goldens` disabled and confirm zero
  unexpected diffs).
- Offline/sync workflows spot-verified by tests (customer breakdown queue,
  staff intake queue, failed-booking recovery) — no silent regressions.

## J. Testing requirements

- `melos run analyze` (all), `melos run test` (all six suites),
  plus per-app EN/AR matrix tests added in 01–19 all passing.
- Dark-mode smoke per app (widget test with `ThemeMode.dark`).
- Accessibility checks: automated semantics assertions where built; manual
  checklist documented in the report (contrast pairs sampled, focus order,
  reduce-motion).
- Performance spot-checks: list scroll frame sanity via existing tooling/manual
  profiling notes; startup timing comparison vs pre-redesign note (qualitative).
- CI config check: confirm `.github/workflows/ci.yml` still passes conceptually
  (analyze + test). Document any CI updates needed (e.g. if l10n codegen must
  run before analyze — add `flutter gen-l10n` step if required by Phase 02's
  setup; include the change here if it was missed).

## J2. Visual quality gates (mandatory)

This phase *is* the family-wide visual gate. It additionally requires that every
redesign phase 00–19 has attached its own J2 evidence; missing evidence for any
phase is itself an audit finding (fix: run that phase's capture matrix before
sign-off — never accept code-reading as proof).

Evidence required here:

1. **Rendered review** — final pass over every screen in all four apps in EN and
   AR, mobile/tablet/desktop (the §D audit walks).
2. **Matrix completeness** — every phase's `phases/reports/PHASE_XX/` pack
   exists and is named per convention.
3. **Consistency sweep** — side-by-side review proves one visual language; no
   orphaned component variants, no drifting card/row/status styles.
4. **State and interaction** — spot-checked across apps per the audit method.
5. **Accessibility** — programmatic + manual checks per spec §8.
6. **Honest content** — screenshots show realistic entity content, not dummy
   placeholders; any placeholder found is an audit finding.
7. **Overflow** — 320 px EN/AR sweep across every app (automated where possible).
8. **Report** — results recorded in the final compliance report with pass/fail
   and fixes.

## K. Acceptance criteria

1. Audit report with pass/fail per app against spec §8/§9/§13/§15/§17 and the
   responsive matrix; all failures either fixed (with test) or explicitly
   accepted with rationale (never silently).
2. Zero new hard-coded tokens/strings in redesigned files (evidence: rg output).
3. Every phase's known-limitation list reviewed; nothing unresolved without an
   entry.
4. All suites + goldens green; CI-equivalent checks pass.
5. Documentation final: README status table updated (phases done), spec registry
   updated.
6. No route/provider/API/permission diffs.

## L. Deliverables

- Final compliance report (`phases/PHASE_20_AUDIT_REPORT.md` is acceptable as
  the deliverable artifact, or an inline report if preferred by the operator),
  containing:
  - app × matrix results (responsive, EN/AR, a11y),
  - fixes applied (files + reasons),
  - regression evidence (commands/results),
  - contract-preservation diff results,
  - residual issues + recommendations,
  - phase-report reconciliation table (limitations closed/open).

## M. Completion gate

This is the final phase. After reporting, stop. Any further work must come from
explicit new instructions based on the residual-issue list.
