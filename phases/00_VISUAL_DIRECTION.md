# 00 — Visual Direction (Review Brief & Sign-Off Record)

This document is the bridge between `00_REDESIGN_VISION.md` (intent) and
`00_DESIGN_SYSTEM_SPEC.md` (authority). It is **filled and signed during
Phase 00** after the prototype review. Until signed, Phase 01 must not start.

Status: `UNAPPROVED — awaiting Phase 00 prototype review`

---

## 1. Frozen direction statements (to approve or amend)

| # | Decision | Proposed value |
|---|---|---|
| V1 | Canvas & surface model | Cool slate canvas `#F5F7FB`; white cards with 1 px `#E5EAF1` hairline border; whisper elevation only (`shadowSurface/Card/Modal`) |
| V2 | High-emphasis surface | One navy `#14213D` region per screen maximum (hero strip, auth identity panel, KPI hero tile) |
| V3 | Action color | Cobalt `#3157D5` for all actions/selection; tint at 8–12 % alpha never used alone |
| V4 | Typography | Plus Jakarta Sans (Latin) + IBM Plex Sans Arabic; role scale from spec §3.2; no ad-hoc sizes |
| V5 | Numerals | Latin digits everywhere incl. Arabic; tabular figures for all money/quantity/time data |
| V6 | Row grammar | One record-row grammar for every list; tables on ≥ expanded, cards on compact |
| V7 | Radius discipline | Semantic radii only (`radiusControl 8 / Input 10 / Card 12 / Panel 16 / Sheet 22 / Pill 999`) |
| V8 | Charts | Shared chart palette + token typography; max 2 series per chart; empty-data renders as a state, never a blank |
| V9 | Motion | `AppMotion` only (100/160/220/280 ms); no ambient motion; reduce-motion collapses to instant |
| V10 | Icons | Material rounded only; directional icons flip in RTL; damage-map vehicle outline never mirrors |
| V11 | Arabic typography | No letter-spacing/case transforms; line-height ×1.05 vs Latin |
| V12 | Auth identity panel | Navy panel with brand mark + app purpose + security note; single form column capped at `formMaxWidth` |
| V13 | Quick-action tiles | Icon + short label, uniform hit area ≥48 px, max 6 per row on desktop |
| V14 | Status language | `StatusPill` + localized labels; state encoded by icon/text + color (never color alone) |

---

## 2. Per-screen direction (Phase 00 prototype targets)

| Prototype screen | Direction statement | Reviewer verdict |
|---|---|---|
| Owner Dashboard | Executive calm: navy period hero → 4 KPI tiles → register table → 2 charts → 12-tile action grid; no duplicate metrics; everything drills | ☐ approve ☐ amend |
| Job Cards List | One dominant identity column (vehicle+customer), tabular money, status pills, filter chips; cards ⇄ table at the medium breakpoint | ☐ approve ☐ amend |
| Technician Job Detail | Next action above the fold; ≥56 px task targets; state morph demo; persistent part/escalate/complete actions; offline chip honesty | ☐ approve ☐ amend |
| Add Vehicle Form | Three quiet sections; label-above; inline errors; sticky bar with busy state; LTR identifiers inside RTL layouts | ☐ approve ☐ amend |
| Login / Auth | Split identity + form ≥900 px; segmented method control; OTP at 320 px; calm notices | ☐ approve ☐ amend |
| Advisor Inspection | Section rail + three-state checkpoints + tappable damage map + sticky footer; three-pane at desktop; RTL mirrors everything except the car outline | ☐ approve ☐ amend |

---

## 3. Decision log (filled during Phase 00 review)

| Date | Decision | Value before → after | Owner | Notes |
|---|---|---|---|---|
| — | — | — | — | *(empty until review)* |

Amendments made during review are edited first in
`apps/design_prototype/lib/design/provisional_tokens.dart`, re-captured in the
screenshot pack, and recorded here. Phase 01 codifies only **frozen** values.

---

## 4. Open questions carried into later phases

| Question | Default in force | Resolved by |
|---|---|---|
| Arabic font availability/licensing for bundling | IBM Plex Sans Arabic (SIL OFL) with Noto fallback | Phase 02 |
| Dark mode user exposure | Foundation only; `ThemeMode.light` default | Phase 20 audit / product |
| Eastern Arabic numerals | Out of scope; Latin digits | Product request only |
| Density on tablet listings | 2-column cards; table at ≥ expanded | Phase 00 verdict |

---

## 5. Sign-off

| Role | Name | Verdict | Date |
|---|---|---|---|
| Product owner / requester | — | — | — |
| Design authority (implementing agent) | — | — | — |

**Phase 01 gate:** all rows above signed; screenshot pack present at
`phases/reports/PHASE_00/`; no outstanding "Rework" verdicts.
