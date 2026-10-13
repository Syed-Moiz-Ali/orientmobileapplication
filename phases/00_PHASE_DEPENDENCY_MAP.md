# 00 — Phase Dependency Map

Execution order, prerequisites, split rationale, and what each phase guarantees
to its dependents. **Do not start a phase before its dependencies are complete
and reviewed.**

---

## 1. Dependency graph (text form)

```
PHASE_00 Visual Design Validation  ──(sign-off gate)──►
PHASE_01 Design System Foundation
   └─► PHASE_02 Localization & RTL Foundation
          └─► PHASE_03A Shared Primitives
                 └─► PHASE_03B Shared Data Display & Chart Language
                        └─► PHASE_04 Responsive Shell & Navigation
                               └─► PHASE_05 Authentication & Onboarding
                                      │
        ┌─────────────────┬───────────┴────────────┬────────────────────┐
        ▼                 ▼                        ▼                    ▼
  PHASE_06           PHASE_12                 PHASE_15A            PHASE_19A
  Advisor Home       Owner Dashboard          Customer Shell/Home  CRM Shell/Dashboard/Leads
   └─► 07A            ├─► 13A ─┐                └─► 15B              ├─► 19B ─┐
        └─► 07B      └─► 13B ─┴─► 14                 └─► 16          └────────┴─► 19C
             └─► 08                                     └─► 17
                  └─► 09                                     └─► 18
                       └─► 10
                            └─► 11
                                      ALL ──► PHASE_20 Final Validation
```

Linear safe order: **00 → 01 → 02 → 03A → 03B → 04 → 05 → 06 → 07A → 07B → 08
→ 09 → 10 → 11 → 12 → 13A → 13B → 14 → 15A → 15B → 16 → 17 → 18 → 19A → 19B →
19C → 20.**

Branch independence after Phase 05:

- Staff (06–11), Owner (12–14), Customer (15A–18), CRM (19A–19C) are mutually
  independent and may be re-prioritized.
- Within a branch the order is fixed by data/navigation reuse (e.g. 13A/13B both
  need Phase 12's drill-ins; 16 depends on 15B's vehicle form; 19B/19C depend on
  19A's shell + token migration).
- 13A and 13B may run in parallel; both must be complete before 14.
- Phase 20 runs last, after every branch.

---

## 2. Split rationale (audit of the original 20-phase plan)

Phases were split where a single execution attempted too many independent
workflows or screens (splits keep exactly one owning phase per screen):

| Original | Split into | Trigger | Result |
|---|---|---|---|
| 03 Shared Component Library | 03A + 03B | Two consumer groups: interactive primitives vs data-display/feedback/charts; two independently testable catalogs | 03A ships first and unblocks forms/actions; 03B unblocks listing-heavy phases |
| 07 Advisor Intake & Inspection | 07A + 07B | Two 3 000-line workflows (capture vs inspection+damage map) | Each independently verifiable; failure in one does not block the other's review |
| 13 Owner Operations Pages | 13A + 13B | Six pages across two domains: job lifecycle vs resources | Parallelizable; each with its own widget suite |
| 15 Customer Workspace | 15A + 15B | Shell/landing vs records-management + form | 15A proves navigation early; 15B carries the offline-recovery surface |
| 19 CRM Workspace | 19A + 19B + 19C | Eight tabs + three sheets across three domains: conversion core / daily work / analytics+admin | Palette deletion becomes a verifiable final gate in 19C |

Phases reviewed and **kept whole** (coherent single context, no split trigger):

- 08 (estimate → delivery → assignment): one advisor completion pipeline sharing
  the workflow indicator and job-detail entry; splitting would duplicate context.
- 09 (supervisor): seven surfaces but one operations context sharing a single
  provider and shell — reviewed, kept with its own visual gates.
- 10 (technician): one "execute my work" workflow.
- 12 (owner dashboard): one dashboard with secondary tabs.
- 16/17/18 (customer): one booking journey; one decision/monitoring bundle; one
  assist bundle — each internally cohesive.

---

## 3. Phase contracts (what each phase guarantees)

| Phase | Guarantees to dependents |
|---|---|
| 00 | Approved visual direction (`00_VISUAL_DIRECTION.md`), screenshot pack, frozen token/component inputs; zero production changes |
| 01 | Final token set (colors incl. dark parity + chart palette + ratingStar, typography roles incl. locale hook, dimensions, motion, elevation); themes wired in 4 apps; text-scale lock removed with **no application-breaking regressions**; public APIs preserved |
| 02 | Six l10n units with distinct classes/imports; localeProvider + persistence + switcher; Arabic font + fallback; shared copy localized; cross-boundary tests |
| 03A | Interactive primitive catalog complete (buttons/inputs/stepper/selection/cards/rows/KPI/progress/dialogs/forms) |
| 03B | Skeletons, empty/error, table primitives, chart theme, list-surface recipes |
| 04 | Final shell/navigation behavior + app-bar/page-frame/breadcrumb/master–detail templates |
| 05 | Localized, branded, responsive auth for all four apps |
| 06 | Advisor shell + Today/Jobs/Reports + job detail + advisor sheets |
| 07A | Intake/scan/check-in incl. media/signature + offline queue honesty |
| 07B | Inspection incl. damage map (math untouched, RTL exception documented) |
| 08 | Estimate builder + preview/signature + delivery + assignment; dead advisor kits removed |
| 09 | Supervisor workspace parity incl. QC + notifications |
| 10 | Technician workspace parity incl. parts/escalation |
| 11 | Common surfaces (profile with language switcher, attendance, shift, settings) |
| 12 | Owner shell + dashboard + charts (chart theme adopted) + Top Sales/Messages/Activity |
| 13A | Job cards list/detail + job status + approvals (dead affordance resolved) |
| 13B | Inventory + attendance + team (+ sheets) |
| 14 | Owner AR/compliance/moderation/subscription; owner dead code removed |
| 15A | Customer shell + Home + Profile + router fallbacks |
| 15B | Bookings + garage + vehicle form (identity/failed-* contracts unmodified) |
| 16 | Booking wizard + success + booking detail |
| 17 | Service status + approvals + invoices |
| 18 | Notifications + roadside + feedback (+ `/feedback` entry point) |
| 19A | CRM shell + dashboard + leads/kanban + lead sheets on tokens |
| 19B | CRM conversations/tasks/team; conversations affordance resolved |
| 19C | CRM reports/integrations/settings; `crm_constants.dart` deleted; dark toggle honest; language switcher |
| 20 | Cross-app audit: a11y, EN/AR, responsive matrix, regression, visual consistency, phase-evidence completeness |

---

## 4. Cross-phase rules

1. **No forward dependencies.** A phase may not assume a primitive, localized
   string or visual decision introduced later. Missing pieces are added to the
   shared library inside the current phase (README §8).
2. **No phase changes routes, providers, API contracts, permissions or
   persistence.** Documented UX-completion wiring that calls existing repository
   methods only (e.g. `/feedback` entry in 18, approvals drill-down in 13A,
   conversations affordance in 19B) is always listed in the phase's section I.
3. **Golden tests** regenerate only for screens intentionally redesigned in the
   current phase, re-verified at compact + expanded width and EN + AR.
4. **Visual quality gates (J2)** apply to every implementation phase; a phase
   without its evidence pack is incomplete regardless of test results.
5. **Shared changes ripple.** A component API change is updated across all
   current consumers in the same phase and recorded in the report.
6. **Stop at the gate.** Each phase ends with its Deliverable Report; do not
   proceed automatically.

---

## 5. Suggested execution batches

| Batch | Phases | Outcome |
|---|---|---|
| Visual gate | 00 | Approved direction backed by screenshots before any rollout |
| Foundation | 01–05 | Whole family on the new system; auth redesigned |
| Staff | 06–11 | Largest app fully redesigned (proving ground) |
| Owner | 12–14 | Operations + finance redesigned |
| Customer | 15A–18 | Customer portal redesigned |
| CRM | 19A–19C | CRM redesigned, token-only |
| Audit | 20 | Family-wide validation + residual issue log |
