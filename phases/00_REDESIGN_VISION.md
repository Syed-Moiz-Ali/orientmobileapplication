# 00 — Redesign Vision (2026 Design Direction)

> This document is the spiritual brief every phase implements. The concrete
> token/component authority lives in `00_DESIGN_SYSTEM_SPEC.md`.
>
> **This direction is validated before rollout:** Phase 00
> (`PHASE_00_VISUAL_DESIGN_VALIDATION.md`) renders six representative production
> screens (owner dashboard, job-cards listing, technician job detail, vehicle
> form, auth, advisor inspection) in a runnable prototype with EN/AR variants,
> produces a screenshot review pack, and freezes the approved values in
> `00_VISUAL_DIRECTION.md`. Phase 01 must not start until that sign-off exists.

---

## 1. Positioning

**Orient Workshop OS — "Precision, Clarity, Calm."**

Four apps (Staff, Owner, Customer, CRM) must read as one product family built by
one design team: same canvas, same card grammar, same navigation vocabulary, same
bilingual behavior. A workshop runs on this all day — the design must be
effortless at 8:00 and at 18:00, on a 5-inch phone in one hand, on a tablet at the
service desk, and in a browser window in the back office.

The redesign is **not** "make it prettier". It is a re-architecture of the visual
and interaction language around the real workflows discovered in
`00_PROJECT_ANALYSIS.md`: intake → inspection → estimate → repair → QC →
delivery → invoice for staff; monitoring → approvals → inventory → people for the
owner; booking → tracking → approvals → payment for customers; lead → pipeline →
conversion for CRM.

---

## 2. The five design principles

### P1 — One canvas, one grammar
A single surface system: cool slate canvas, white content surfaces, hairline
borders, restrained elevation, radius discipline. A card in the CRM looks like a
card in the technician workspace. No module invents its own card, its own search
field, or its own navy palette.

### P2 — Hierarchy before decoration
Every screen answers three questions in order: **where am I** (page header with
eyebrow), **what matters now** (one primary focus region), **what can I do**
(contextual actions). Decoration never competes with data. Navy high-emphasis
surfaces are reserved for telemetry and hero metrics — not sprinkled as accents.

### P3 — Task-driven navigation
Navigation mirrors how work happens: role workspaces with ≤5 destinations,
deliberate overflow, contextual pushed pages for deep tasks, sheets for quick
decisions, and state-preserving back behavior. Desktop gets the same
destinations as rail/sidebar with more context visible at once — never a
stretched phone layout.

### P4 — Truthful feedback
Every mutation has a visible lifecycle: optimistic where the sync engine already
supports it, queued/offline where writes are deferred, pending, done, failed with
recovery. Loading = skeletons matching the final layout (no spinners where a
shape is predictable). Empty ≠ error ≠ offline. Errors are actionable, never raw.

### P5 — Bilingual by construction
Arabic is a first-class layout, not a translation file: RTL mirrors navigation,
icons, timelines and tables; typography is chosen for Arabic; numbers, dates,
currency and phone input are locale-aware; components are sized for the longer of
the two languages. A screen that only looks right in English is **not done**.

---

## 3. Visual direction

### 3.1 Personality
Calm, precise, editorial. Think "instrument panel", not "marketing dashboard".
Confident cobalt for action, deep navy for emphasis, quiet neutrals for everything
else, semantic color only when it carries meaning.

### 3.2 Surface system (light theme canonical)
- **Canvas**: cool slate `#F5F7FB` — never pure white page background.
- **Content surface**: pure white cards/panels with 1 px `#E5EAF1` hairline border
  and `radiusCard 12`; elevation is a whisper, not a shadow show.
- **Grouped list surfaces**: a single card containing divider-separated rows —
  not one card per row, not floating rows.
- **Navy command surface** `#14213D`: hero KPIs, live telemetry, dark banners,
  auth identity panels. Text on navy is white/`#AAB5C8` secondary.
- **Tinted semantic surfaces**: `subtle` background + `border` color + dark text
  (success/warning/danger/info), used for status blocks and notices.
- **Selection tint**: cobalt at 8–12 % alpha for selected rows/chips/nav states,
  always paired with an icon or weight change (color is never the only cue).

### 3.3 Typography
- **Latin**: Plus Jakarta Sans (already bundled) — keep, but with a disciplined
  role scale (see spec §3): no more ad-hoc font sizes or weights.
- **Arabic**: IBM Plex Sans Arabic (new asset, Phase 02) with numeric fallback to
  tabular figures; line-height increased ~5 % for Arabic.
- **Numbers are data**: tabular figures for metrics, money, odometers, plates,
  phone numbers, VINs (monospace-alias roles today; keep that convention).
- Max two weights per region (regular/medium vs semibold/bold). Uppercase
  eyebrows only for Latin; in Arabic use letter-spacing 0 and no case transform.

### 3.4 Motion
`AppMotion` tokens only (100/160/220/280 ms). Motion communicates state change:
nav selection, sheet rise, list item insertion, progress transitions. Respect
`MediaQuery.disableAnimations` (reduce-motion) by collapsing to ≤100 ms/instant.
No ambient/looping animation except honest loading shimmer.

### 3.5 Iconography
Material rounded icons only (`Icons.*_rounded`), one optical size per context
(12/16/20/24/32 tokens). Directional icons must flip in RTL (arrows, chevrons,
back, next, timeline progress). No mixed icon families, no emoji.

### 3.6 Density
- Phones: comfortable — 16 px gutters, 48 px controls, max 2 emphasis levels per
  viewport.
- Tablets: two-column where workflows allow (list + detail, form + preview).
- Desktop: content capped (`contentStandard 1180`, `contentWide 1320`), data
  tables get real density (32–40 px rows), bulk actions and hover/focus states
  become first-class, keyboard navigation works.

---

## 4. Experience architecture per surface type

### 4.1 Dashboards (owner, supervisor today, technician, CRM)
Order: identity/greeting + period context → 3–4 KPI tiles (one navy hero allowed)
→ "needs attention" queue with concrete actions → trends → secondary modules.
Every KPI is tappable to its source list. No KPI without a destination, no
dashboard without an explicit refresh affordance and freshness indicator.

### 4.2 Data listings (job cards, inventory, leads, invoices, attendance...)
One list template everywhere: title + count, search, filter chips, sort menu
(desktop), rows/cards that share the record-row grammar, explicit empty states
with the primary action, pull-to-refresh, skeleton on first load, inline error
with retry, bulk selection on desktop where the backend already supports it.
Phones never get horizontal-scrolling tables: they get record cards; tablets
choose; desktop gets the table.

### 4.3 Forms (intake, estimate builder, booking, add staff, lead form...)
Grouped sections with one question per row, labels above inputs, inline
validation on blur, errors that say how to fix, a single sticky primary action,
an explicit way to discard with confirmation when data would be lost, autosave
for long flows where local persistence already exists (intake, estimate drafts).
Multi-step flows show progress, allow back, and preserve entered data.

### 4.4 Detail screens (job card, booking, lead, invoice, vehicle)
Header block (identity + status + primary action) → structured sections
(overview, work items, financials, activity/history) → contextual actions.
Kill the "cheap chevron with no tap target" pattern — if a row is tappable it
navigates; otherwise it is static.

### 4.5 Real-time & offline surfaces (technician, customer, staff offline)
Offline is a designed state, not an error: persistent honest banner, queued items
visually distinct ("Not sent yet"), per-item retry/remove, sync status in
profile/settings, no data loss on retry. Live states (service tracking, queue
badges, attendance timers) refresh politely (badge/timeline morph, not full-page
flashes).

### 4.6 Auth & onboarding
One branded shell: identity panel (product + purpose + security), focused form,
big touch-friendly controls, OTP with clear resend/cooldown, locale-aware phone
input, and a calm recovery flow. Per-app brand context via `BrandConfig` so staff
/ owner / customer / CRM feel distinct yet related.

---

## 5. How the redesign improves the discovered workflows (examples)

| Workflow | Today | 2026 experience |
|---|---|---|
| Advisor intake (`VehicleCustomerView`, 3 200 lines, hand-rolled) | Scroll-heavy form, inconsistent sections, risk of lost data offline | Sectioned progress flow with autosave (Hive already exists), damage map as a first-class panel, sticky save with queue status, tablet split-view (form + vehicle summary) |
| Estimate builder (`RepairOrderView`) | Dense kit of legacy widgets, mixed typography | Line-item table with tabular money columns, inline qty/price editing with validation, live total in a sticky footer, desktop two-pane (catalog picker + estimate), signature/approval captured in a focused sheet |
| Technician job execution | Hand-rolled `job_detail_sheet` full-screen view | One job workspace: identity, live task checklist with clear state morphing, parts/escalation as bottom sheets with validation, offline-aware completion with confirm |
| Supervisor QC | Functional but visually ad-hoc | Review queue with per-job evidence summary, QC checklist sheet with sign-off/reject requiring notes, queue badges and empty states everywhere |
| Owner daily ops | 11 hand-rolled pages, 85 hard-coded colors, ad-hoc search fields | One operations shell: consistent page frame, KPI → list drill-ins, real data tables on desktop, unified date/filter chrome, skeleton/empty/error states everywhere |
| Customer booking | 4-step wizard exists (good bones) | Same steps with refined step chrome, availability clarity, summary that mirrors the receipt, honest offline result screens, RTL-correct slots/date picker |
| Customer approvals | Estimate detail is good; overview ad-hoc | Decision-first overview (what needs me now) with financial breakdown, confidence copy, and a single primary decision bar |
| CRM lead flow | Works, but a separate navy/cyan visual world | Unified design system: pipeline kanban with drag affordances (desktop hover, mobile long-press), lead sheet with timeline, consistent task/report surfaces |
| Auth (all apps) | English-only shared package, workshop wording in CRM | Localized branded auth with per-app identity copy, Arabic typography, phone input, and recovery that explains itself |

---

## 6. What we deliberately avoid

- Generic Material defaults without our token layer; stock `BottomNavigationBar`
  look-alikes; default ripple-only feedback.
- Card-ception (cards inside cards inside sheets) and decorative container noise.
- Heavy gradients, glassmorphism, neon glows, oversized drop shadows.
- Oversaturated semantic colors used decoratively; color-only state encoding.
- Stretched desktop layouts (full-width forms, endless line lengths) and shrunken
  mobile layouts (tiny desktop controls on phones).
- Animations that delay work; looping ambient motion; celebratory confetti.
- New backend features invented to decorate a screen. UI may only surface what
  the repositories already expose.
