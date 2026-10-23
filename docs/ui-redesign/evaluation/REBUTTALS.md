# Rebuttals log — reviewer findings rejected or deferred, with evidence and rule

Every entry below was raised by a reviewer and NOT fixed, with the reason.
"Rebutted" never means ignored: each cites file+line evidence and the
governance rule that decides it. Fixed items live in the migration docs,
not here. References (`references/`, `AIRBNB_PATTERNS.md`) are EMPTY —
recorded UNMET in every brief; precedent patterns cited instead.

## Standing rebuttals (apply everywhere)

- **R1. Fixture-English is not a UI defect.** Capture/test fixtures carry
  EN literals (`Task N`, `LD-1000`, tied revenues pre-diversification,
  6-char VIN stub). The UI renders them verbatim, LTR-locked. Inventing
  Arabic data or realistic variety beyond representative fixtures would
  violate the no-invention rule. Where fixtures misled (tied team
  revenues, 1-per-group notifications, identical tasks), fixtures were
  DIVERSIFIED (test-only) instead. Evidence: per-screen migration docs.
  Rule: REDESIGN MANDATE (no data invention).
- **R2. Feed-owned server strings stay verbatim.** Backend codes and
  stored copy (tech statuses pre-formatter-fix, notification
  titles/bodies/times, stage/priority/role codes) render as received.
  Translating or re-casing them in presentation would invent copy.
  Logged: LOGIC entries 2, 9, 11, 16. Rule: no-invention + U8 (log,
  never silently filter).
- **R3. No state signal → no state UI.** Skeleton/error/offline branches
  without a provider signal would be dead code masquerading as states
  (CRM `isLoading`, swallowed refresh failures, team sync cache).
  Logged: LOGIC entries 10, 14, 15. Rule: honesty over decoration.
- **R4. One path per task beats sticky duplicates.** A second Add/FAB
  alongside the header/empty-state action would violate C16/U7
  (duplicate entry points). The XOR contract (header when non-empty,
  empty-state CTA when empty) is the lawful resolution. Rule: C16/U7.
- **R5. Shared atoms change in owning phases, not screens.** Tones,
  canonical vocab, skeleton atoms, banner grammar, chevron tokens,
  progress-bar auto-tones stay byte-identical on list surfaces; fixes
  land in the shared/owning phase with all-call-site verification.
  Rule: monorepo safety (PROGRESS rule 5).
- **R6. Search-as-transport is not a duplicate entry.** A find sheet
  reaching the same destinations as rows/tiles is transport, not a
  second entry point (consistent with every prior PASS). Rule: U7
  (one path per task — the task here is *finding*, not browsing).
- **R7. Capture framing is not UI.** Tab-alone harnesses crop the shell
  AppBar; claims about "missing" titles/icons that live in the shell
  above the crop are rebutted against the full tree (scaffold + view).
  Rule: evidence must be full-screen (U9 consistency lives in the shell).
- **R8. Sanctioned deviations hold unless the law is genuinely harmed.**
  Brief deviations with written U-reasons (filter rails inline for
  top-3 triage taps, wide AppTable master-detail, calm action-less
  empties) stand; where the law genuinely wins (art-band size is fine;
  ID-first was overridden by ruling (d)), the brief is amended.

## Deferred to owning phases (filed, not dropped)

- **D1. Shared ALL-CAPS/tones/vocab** (approval red, Title-Case pills,
  overline casing beyond fixed surfaces) — shared-grammar phase.
- **D2. Golden platform/threshold + stopwatch clock** — phase 13
  (tolerant comparator ≤ 0.5%; injectable clock, LOGIC entry 6).
- **D3. Gallery canonical drift** — phase-1 owner decision (untouched
  by list work; reported, not blessed).
- **D4. Status-machine / handler-contract / endpoint gaps** — LOGIC
  entries 3, 4, 5, 10, 14, 15 (backend/product/state owners).
- **D5. Native-copy glossary** (ar status/role/stage glossary, dual
  forms) — phase 9 with native review (LOGIC entries 2, 9, 11, 16).

## The 4 open design rulings and their outcome

- **(a) Search icon position** (strict top-right, shell-AppBar locus):
  IMPLEMENTED — relocation wave across customer/staff/CRM/owner
  (shell-icon contextual per tab, page icons removed, same sheets and
  tap budgets); shared locus guard extended (21/21); adversarial
  confirms PASS (staff 15/16, customer 14/16, CRM 14/16, owner PASS).
- **(b) Vehicles art band**: VERIFIED-COMPLIANT, no change — measured
  96px; first card + entire second card + 63px margin above the fold
  at 360x800 (holds at 1.3x/320/ar/dark).
- **(c) Edit/remove menu +1**: ACCEPTED as scored (15/16 stands).
- **(d) sv-review vehicle/customer first**: IMPLEMENTED (row reorder +
  brief hierarchy updated; revertible in one commit if countermanded).

## Prior adjudications (kept)

- Supervisor 7-tab → 4+More (LOGIC entry 8 CLOSED as presentation
  decision; user CONFIRMED).
- Technician inline-search removal; supervisor Jobs dual-search scope
  unification (old STOP superseded — single AppBar path per scope).
- Duplicate shell/page magnifiers → single path per screen (now
  relocated per ruling (a), not merely hidden).
- Tech row-internal truncation → shared-component owning phase
  (workaround intact: 1-tap dossier with exact times).
- sv-review ID-first binding → OVERRIDDEN by ruling (d).
- Owner-cards 7 adversarial gates → all fixed, confirm PASS 15/16.
- `71983229` never in any working history; never touched.
