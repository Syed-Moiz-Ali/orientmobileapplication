# 00 — Visual Direction (Review Brief & Sign-Off Record)

This document is the bridge between `00_REDESIGN_VISION.md` (intent) and
`00_DESIGN_SYSTEM_SPEC.md` (authority). It is **filled and signed during
Phase 00** after the prototype review. Until signed, Phase 01 must not start.

Status: **`APPROVED — 2026-10-13`** (product owner, after prototype review).
Frozen artifacts: 104-render pack + 6 audit captures at
`phases/reports/PHASE_00/`; runnable prototype at `apps/design_prototype/`;
audit at `reports/PHASE_00/VISUAL_QUALITY_AUDIT.md`. Execution record:
`PHASE_00_VISUAL_DESIGN_VALIDATION.md` §N. **Phase 01 may now start**; the
handoff prerequisites are listed in §6.

---

## 1. Frozen direction statements (approved)

All fourteen statements below were reviewed against the rendered prototype and
**approved as proposed, without amendment**. The decision log (§3) records the
operational clarifications made during execution (palette, sizes, behaviors);
those clarifications are part of the freeze.

| # | Decision | Proposed value | Status |
|---|---|---|---|
| V1 | Canvas & surface model | Cool slate canvas `#F5F7FB`; white cards with 1 px `#E5EAF1` hairline border; whisper elevation only (`shadowSurface/Card/Modal`) | ✓ Approved |
| V2 | High-emphasis surface | One navy `#14213D` region per screen maximum (hero strip, auth identity panel, KPI hero tile) | ✓ Approved |
| V3 | Action color | Cobalt `#3157D5` for all actions/selection; tint at 8–12 % alpha never used alone | ✓ Approved |
| V4 | Typography | Plus Jakarta Sans (Latin) + IBM Plex Sans Arabic; role scale from spec §3.2; no ad-hoc sizes | ✓ Approved |
| V5 | Numerals | Latin digits everywhere incl. Arabic; tabular figures for all money/quantity/time data | ✓ Approved |
| V6 | Row grammar | One record-row grammar for every list; tables on ≥ expanded, cards on compact; tablet density = 2-column cards (600–1023), table ≥1024 | ✓ Approved |
| V7 | Radius discipline | Semantic radii only (`radiusControl 8 / Input 10 / Card 12 / Panel 16 / Sheet 22 / Pill 999`) | ✓ Approved |
| V8 | Charts | Shared chart palette + token typography; max 2 series per chart; empty-data renders as a state, never a blank | ✓ Approved |
| V9 | Motion | `AppMotion` only (100/160/220/280 ms); no ambient motion; reduce-motion collapses to instant | ✓ Approved |
| V10 | Icons | Material rounded only; directional icons flip in RTL; damage-map vehicle outline never mirrors | ✓ Approved |
| V11 | Arabic typography | No letter-spacing/case transforms; line-height ×1.05 vs Latin | ✓ Approved |
| V12 | Auth identity panel | Navy panel with brand mark + app purpose + security note; single form column capped at `formMaxWidth` | ✓ Approved |
| V13 | Quick-action tiles | Icon + short label, uniform hit area ≥48 px, max 6 per row on desktop; on compact grids labels wrap (2 lines) and chevrons are omitted | ✓ Approved |
| V14 | Status language | `StatusPill` + localized labels; state encoded by icon/text + color (never color alone) | ✓ Approved |

---

## 2. Per-screen direction (Phase 00 prototype targets)

| Prototype screen | Direction statement | Reviewer verdict |
|---|---|---|
| Owner Dashboard | Executive calm: navy period hero → 4 KPI tiles (2×2 at tablet) → register table → 2 charts → 12-tile action grid; no duplicate metrics; everything drills | ✓ **Approved** — 2026-10-13 |
| Job Cards List | One dominant identity column (vehicle+customer), tabular money, status pills, filter chips; cards → 2-up → true table (≥1024) | ✓ **Approved** — 2026-10-13 |
| Technician Job Detail | Next action above the fold; ≥56 px task targets; state morph includes the locked-completed state; persistent part/escalate/complete actions; offline chip honesty | ✓ **Approved** — 2026-10-13 |
| Add Vehicle Form | Three quiet sections; label-above; inline errors; sticky bar with busy + save-error states; LTR identifiers inside RTL layouts | ✓ **Approved** — 2026-10-13 |
| Login / Auth | Split identity + form ≥900 px; segmented method control; OTP at 320 px; calm notices | ✓ **Approved** — 2026-10-13 |
| Advisor Inspection | Section rail + three-state checkpoints + tappable damage map + sticky footer (stacked on phones); three-pane at desktop; RTL mirrors everything except the car outline | ✓ **Approved** — 2026-10-13 |

---

## 3. Decision log (filled during Phase 00 review)

| Date | Decision | Value before → after | Owner | Notes |
|---|---|---|---|---|
| 2026-10-13 | Prototype rendered; pack delivered | none → 104 renders `phases/reports/PHASE_00/` | Implementing agent | Light + dark, EN + AR, 320→1440, state variants. **Awaiting product review.** |
| 2026-10-13 | Dark palette proposal added (spec §2.1 deferred parity to Phase 01) | undefined → `ProtoPalette.dark` (canvas `#0C1120`, surface `#151C2E`, primary `#6E8BFF`, semantic sets) | Implementing agent | Needs product confirmation; light stays the default theme |
| 2026-10-13 | Compact KPI tile height | flexible → 156 px compact / 158 px wide | Implementing agent | Arabic line-height ×1.05 headroom at 320 px; carry into Phase 03A `AppKpiCard` |
| 2026-10-13 | Status pill text handling | fixed text → Flexible + ellipsis | Implementing agent | Long Arabic statuses must not overflow dense ≥1024 table columns |
| 2026-10-13 | Tablet listing density (open question) | default 2-col cards → **2-column cards 600–1023, true table ≥1024** | Implementing agent | Prototype default; product verdict still required |
| 2026-10-13 | Damage-map RTL exception proven | unverified → vehicle outline never mirrors; all chrome mirrors | Implementing agent | Verified in `inspection_*_ar_*` renders; Arabic on-screen note included |
| 2026-10-13 | Inspection workflow indicator | doc "Step 1 of 4" → production-faithful 5 steps (Job Card → Inspect → Estimate → Repair → Deliver), current = Inspect ("Step 2 of 5") | Implementing agent | Production `AdvisorWorkflowIndicator` is the source of truth; product to confirm |
| 2026-10-13 | Add-vehicle required fields (§D4) | production make+plate → plate + make + model | Implementing agent | Follows the phase brief §D4; product to confirm |
| 2026-10-13 | Phone-width form field pairs | side-by-side → stacked below 600 px | Implementing agent | Fixes 320 px hint truncation; form cap 760 px |
| 2026-10-13 | Identifier input policy demonstrated | — → plate/VIN/phone force LTR Latin content inside RTL forms | Implementing agent | Mixed-input proof shipped (Arabic owner name beside Latin plate) |
| 2026-10-13 | **Visual quality audit** | 110 renders reviewed → 15 in-prototype fixes (KPI density, AR tile truncation, completed-state data, wrapping/duplication/footer ergonomics, AR localization leaks, save-error/spinner, scale-aware KPI tiles) | Implementing agent | Full report: `reports/PHASE_00/VISUAL_QUALITY_AUDIT.md`; no Rework-level defects remained |
| 2026-10-13 | **APPROVED by product owner** | AWAITING USER APPROVAL → **APPROVED** | Product owner | Approval conveyed after reviewing the prototype and audit; all V1–V14 frozen as proposed; clarifications above included |
| 2026-10-13 | Dark palette approved for foundation | proposal → approved as the Phase 01 dark parity map | Product owner (via direction approval) | Dark remains foundation-only; `ThemeMode.light` stays the shipped default (V-exposure question in §4) |
| 2026-10-13 | KPI tile sizing approved | scale-aware minimum 156 px (grows with system text scale) | Product owner (via direction approval) | Carry into Phase 03A `AppKpiCard`; verified 1.15×/1.3× clean |
| 2026-10-13 | **Phase 01.1 accessibility amendment — dark control ink** | white `onPrimary`/`onError` on `#6E8BFF` / `#F1707F` (≈3.1:1 / ≈2.9:1) → dark ink `#0C1120` (**≈6.1:1 / ≈6.6:1** at rest; ≥5.1:1 under Material hover/pressed/focus overlays) | Product owner (Phase 01 sign-off) | WCAG AA correction for normal-sized button labels. Dark map amended; light map unchanged. Applied centrally via `AppDarkColors.onPrimary`/`onError` → `AppTheme.dark` → shared buttons. Exact values: `phases/reports/PHASE_01/PHASE_01_COMPLETION.md` §7.2 |

Amendments made during review are edited first in
`apps/design_prototype/lib/design/provisional_tokens.dart`, re-captured in the
screenshot pack, and recorded here. Phase 01 codifies only **frozen** values.
The 2026-10-13 Phase 01.1 accessibility amendment is a **production-map**
amendment (post-prototype): the phase-00 prototype render remains the approved
visual reference; the amendment changes only the dark ink on bright fills and
is verified by `app_button_accessibility_test.dart` + the re-baselined dark
goldens.

---

## 4. Resolved questions and open items

| Question | Resolution in force | Resolved by |
|---|---|---|
| Arabic font availability/licensing for bundling | **Resolved for the prototype**: IBM Plex Sans Arabic (SIL OFL) bundled and verified; Phase 02 relocates the assets into `shared_core` and keeps the Noto fallback | Phase 00 (approved); asset move in Phase 02 |
| Dark mode user exposure | Foundation only; `ThemeMode.light` remains the shipped default; dark must compile, render and pass tests | Approved 2026-10-13; product exposure reconsidered in Phase 20 |
| Eastern Arabic numerals | Out of scope; Latin digits everywhere | Approved 2026-10-13 (revisit only on product request) |
| Density on tablet listings | 2-column cards 600–1023; true table ≥1024 | **Resolved by Phase 00 verdict (V6)** |
| Inspection workflow steps | Production-faithful 5 steps; Inspect = "Step 2 of 5" | Approved 2026-10-13; Phase 07B adopts with real transitions |

---

## 5. Nonblocking refinements carried into implementation phases

The final audit (`reports/PHASE_00/VISUAL_QUALITY_AUDIT.md` §5) classified the
remaining findings as **nonblocking refinements** — none is a defect in the
approved direction. Assignments:

| Refinement | Owner phase | Note |
|---|---|---|
| Live motion-quality pass (nav selection, sheet rise, task morph) | Product owner — recommended before/with Phase 01 review | Interactive-only; tokens already frozen (V9) |
| Chart y-axis value labels / tooltips | Phase 12 (owner) with 03B chart theme | Palette frozen (V8); labels are additive |
| Technician tablet context-rail width (4/10 at 768) | Phase 10 | Revisit if tablet review is common for technicians |
| Identifier values scale down (~10.5 px floor) in extremely narrow columns | Phase 03B (component spec note) | Current renders readable; keep scale-down over wrapping |
| Dark-mode vehicle map stays a light schematic panel | Phase 07B (optional) | Deliberate contrast choice; recoloring the production illustration is out of Phase 00 scope |
| Shared primitives at 1.6× text scale | Phase 03A acceptance | Screens verified to 1.3× in Phase 00 |
| Form autosave / offline queue visual states | Phases 07A and 16 | Prototype scope excluded persistence flows |

---

## 6. Preserved baselines and Prerequisites for Phase 01

**Baselines frozen at approval** (must not be regenerated without a recorded
amendment in this document):

- `phases/reports/PHASE_00/` — 104-render review pack
  (`screen_width_locale_state[_dark].png`) + `audit/` (6 full-page / 1440
  captures).
- `apps/design_prototype/test/goldens/` — the deterministic source baselines;
  `flutter test test/visual_pack_test.dart` verifies them unchanged (run from
  `apps/design_prototype`). The prototype test suite (299 tests) is preserved
  as-is and remains the visual reference; the prototype is read-only from
  Phase 01 onward.

**Prerequisites before starting Phase 01:**

1. **Melos scripts don't execute in this workspace** — the repo pins Melos 8
   but keeps scripts in the legacy `melos.yaml` block (Melos 7+ reads scripts
   from `pubspec.yaml`). Phase 01's acceptance runs `melos run analyze` /
   `melos run test`; either migrate the scripts (small, non-UI change) or run
   the per-package equivalents and record the substitution in the Phase 01
   report.
2. **Pre-existing suite failures** (present before Phase 00, zero relation to
   the redesign): `apps/staff_app` 7 failures (6 hand-rolled `VehicleCustomerView`
   intake layout overflows + 1 advisor-workflow golden), `apps/customer_app` 8
   golden-baseline failures, `packages/shared_core` 9 and `packages/shared_auth`
   11 missing-golden failures. Phase 01's regression rule ("existing tests are
   the baseline") needs these triaged first — regenerate/restore the missing
   baselines or record them as the accepted baseline — otherwise Phase 01
   cannot prove "no regressions".
3. **Arabic font relocation** — Phase 02 moves the bundled IBM Plex Sans Arabic
   files from `apps/design_prototype/assets/` into `shared_core/assets/fonts/`;
   Phase 01 only prepares the `AppTypography.forLocale` hook (no asset move).

---

## 7. Sign-off

| Role | Name | Verdict | Date |
|---|---|---|---|
| Product owner / requester | — | **✅ APPROVED** | 2026-10-13 |
| Design authority (implementing agent) | Codex (Phase 00 execution) | Prototype + 104-render pack + audit delivered; approved by the product owner | 2026-10-13 |

**Phase 01 gate: SATISFIED** — all V-statements approved, per-screen verdicts
approved, screenshot pack present at `phases/reports/PHASE_00/`, no outstanding
"Rework" verdicts. Phase 01 may begin on the product owner's instruction;
Phase 00 remains closed (no further prototype changes except recorded
amendments).
