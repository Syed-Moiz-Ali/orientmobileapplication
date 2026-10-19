# REPORT PHASE 15 — Owner Financials & Compliance

**Document ID:** `phases/redesign_v2/reports/REPORT_PHASE_15.md`
**Execution Phase:** Concept A V2 — Phase 15 (Archetype 8: Executive Cockpit & Financial Desk)
**Specification:** `phases/redesign_v2/implementation/PHASE_15_OWNER_FINANCIALS_COMPLIANCE.md`
**Prerequisites:** Phases 13–14 (patterns + deferrals honored)
**Status:** **ENGINEERING GATE PASSED** / **VISUAL GATE PENDING PRODUCT OWNER**
**Timestamp:** 2026-10-19
**Author:** Lead Flutter Architect & Systems Designer

> Mission summary: screen-level redesign (not a colour refresh) of the owner
> financial surfaces — receivables, inventory, team, attendance, expiry,
> feedback, subscription — in direct siblinghood with the Phase 13 cockpit
> and Phase 14 register (same shell/tables/pods/records; must read as the
> same product, never cheaper). Every figure is a frozen provider value
> rendered verbatim; anything without a contract (collection actions,
> supplier linkage, payroll figures, renew routes, reply composer) is
> omitted honestly rather than faked. Providers/API/models/math/persistence/
> routes are byte-identical, and the staff tree was never touched.

---

## 0. Baseline the dirty tree (§0 directive — done FIRST, no code)

Phase 13 was LANDED (`f1bfec6d`); Phase 14 was FLOATING — classified as
carryover and kept, never reverted: both are the direct siblings this phase
reads beside. `git status` showed zero `staff_app` paths before and after
(read-only rule held from the first command to the last).

| Path | Disposition | Evidence |
| :--- | :--- | :--- |
| Phase 13 (landed) + Phase 14 (floating) work | CARRYOVER, kept | Sibling goldens reviewed side-by-side with every new surface |
| `apps/staff_app/**` | READ-ONLY, zero touches | Final status: no `staff_app` paths (instant-FAIL rule respected) |
| Phase 15 owned files (7 views) | REBUILT | Prototype chrome, hardcoded copy + hex, bespoke inputs/buttons |
| `test/features/dashboard/owner_analytics_test.dart` (spec path) | DID NOT EXIST | Created (19 contract tests) |

---

## 1. Owned inventory (from source, nothing omitted)

| Ref | Surface | File | Entry | States owned & covered |
| :-- | :--- | :--- | :--- | :--- |
| O9 | `AccountsReceivableView` | `dashboard/.../accounts_receivable_view.dart` | `/accounts-receivable` | bucket strip, search + bucket filter, sortable ledger + contact sheet; loading/empty/no-match |
| O10 | `InventoryView` | `dashboard/.../inventory_view.dart` | `/inventory` | valuation hero, alert strip, tabs, search + filter sheet, stock/add sheets, suppliers/orders; loading/error/empty/no-match |
| O11 | `TeamView` | `dashboard/.../team_view.dart` | `/team` | directory header + counts, search + role filter, roster with clock pills, add sheet + created dialog, enable switch; loading/error/empty |
| O12 | `AttendanceView` | `dashboard/.../attendance_view.dart` | `/attendance` | date header, summary strip, role filter, clock cards; loading/error/empty |
| O13 | `DocumentExpiryView` | `dashboard/.../document_expiry_view.dart` | `/document-expiry` | urgency bands, search, countdown rows, alert pill; loading/empty |
| O14 | `FeedbackModerationView` | `dashboard/.../feedback_moderation_view.dart` | `/feedback-moderation` | star rows, real approve/reject + toasts, read-only note; loading/error/empty |
| O15 | `SubscriptionView` | `dashboard/.../subscription_view.dart` | `/subscription` | tier hero, plan catalog + real switch + toasts; loading |

`ARNotifier`/`InventoryNotifier`/`TeamNotifier`/`OwnerAttendanceNotifier`/
`DocumentExpiryNotifier`/`ModerationNotifier`/`SubscriptionNotifier`
methods, all math, entities, Hive, routes and the share flow are
**unchanged**.

---

## 2. Before / after composition (per screen) — task → concept → composition

| Screen | Old got WRONG (one line) | New does DIFFERENTLY (one line) | Task → Concept → Composition | Viewport @390 EN |
| :-- | :--- | :--- | :--- | :--- |
| Receivables (O9) | Bespoke app bar + raw search + 4 hardcoded-hex bucket cards + hand-rolled ledger rows. | Bucket strip over honest sums + sortable ledger table + billing-contact sheet. | collect what's owed → ledger → buckets + table + sheet | ledger ≈60% |
| Inventory (O10) | Bespoke app bar + tabs + raw inputs + hex pills + inline steppers + bespoke add sheet. | Valuation hero → alert strip → tabs → table + filter sheet; adjust/add live in sheets. | know what's on the shelf → stock console → hero + strip + table + sheets | table ≈50% |
| Team (O11) | Bespoke app bar + directory card + raw search + material chips + hex role colors + bespoke add form. | Header with counts + shared search/filter + tonal roster with clock pills + shared-input add sheet. | run the crew → directory → header + rows + sheet | roster ≈60% |
| Attendance (O12) | Bespoke app bar + hero card + raw chips + bespoke summary boxes with `AppColors` + hardcoded EN states. | Locale date header + metric strip + shared filter + tonal clock cards. | see who showed up → day register → date + strip + cards | register ≈65% |
| Expiry (O13) | Bespoke app bar with snackbar bell + hex summary cards + divider rows. | Bands + search + countdown rows with alert pill (bell deleted with its placeholder snackbar). | stay legal → countdown ledger → bands + rows | ledger ≈65% |
| Feedback (O14) | Bespoke app bar + hex star badge + doubled CTA row, no outcome feedback. | Star rows with real approve/reject + state-derived toasts + read-only note. | protect the reputation → inbox → rows + dock | inbox ≈70% |
| Subscription (O15) | Bespoke app bar + hardcoded tier/plans/CTA copy with hex pill. | Tier hero + plan catalog over the real switch + themed toasts. | own the plan → tier desk → hero + catalog | catalog ≈60% |

No screen repeats one template: ledger, console, directory, register,
countdown, inbox, desk — one design language, seven jobs.

Side-by-side vs 13/14 siblings: identical `WorkspaceAppBar` chrome,
`AppTable`/`AppRecordRow`/`StatusPill`/`SectionHeader`/`EmptyState`/
`ErrorView`/`AppSkeleton` family, identical toast/haptic/pill/sheet
grammar, identical fixed-decimal tabular money. Nothing reads cheaper.

---

## 3. Include / remove / enhance (SaaS rework)

**Included (added, all real):** ~110 `ownerAr*/ownerIn*/ownerTm*/ownerAt*/ownerEx*/ownerFb*/ownerSb*`
+ shared `ownerReq*` validator keys with exact EN/AR parity; Critical as
the honest 60+ sum; billing-contact sheet (contact + phone verbatim);
valuation hero at cost (Σ qty×cost, documented basis); red/amber alert
strip over items' own `reorderLevel`s; category + availability filter sheet
(supplier control omitted — no item linkage, documented); stock sheet with
± over frozen `adjustStock` + error toasts; rebuilt add-part sheet on
shared inputs; roster clock pills joined by staff id (absent when unmatched,
never claimed); toggle + add-member + created dialog over frozen flows;
locale full-date header; countdown pills from real `daysLeft` (overdue
included); state-derived moderation toasts; plan switch toasts; per-view
loading skeleton, empty, no-match, error+retry; 1.3x/48dp/semantics/focus/
reduced-motion throughout; ⌘K focus where search exists.

**Removed:** bespoke app bars on all seven views (→ `WorkspaceAppBar`
with pill/refresh); raw search boxes (→ `AppSearchField`); material
`FilterChip` rows (→ `AppFilterBar` with live counts); 40+ hardcoded hex
literals (status/urgency/role/CTA maps → semantic tones + one shared pill
contract each); hardcoded EN copy; the snackbar bell; bespoke add/member
forms (→ shared inputs + manual `errorText` — the shared field has no
validator slot); `MaterialBanner`/`ElevatedButton`-Retry fallbacks (→
`ErrorView`).

**Enhanced:** ledgers own the viewport as tables; money is fixed-decimal
everywhere (`AED 2,450.00`); dates/phones/plates/SKUs stay LTR mono;
desktop is tables + side-by-side compositions (never stretched phone);
tablet is two-pane grids; compact stacks with sheets; copy is
financial-grade owner tone.

**Honest omissions / deferrals (no fake data — FAIL rule):** collection
actions (remind/write-off — no endpoints); supplier filter (no item
linkage); stock movements beyond ±/add (no endpoints); payroll —
overtime/commission (no fields anywhere); renew CTAs (no route);
reply composer (no endpoint — note rendered, guarded by test);
external manage route (the in-app switch IS the action); persisted
sync stamp (connectivity pill only); permission-denied (N/A — router
role-gates).

---

## 4. Reference conformance (house bar + siblings)

Studied before writing a widget: `advisor_home_view.dart` (toolbar +
search + filter + divider-row grammar, toasts, haptics, shortcuts),
`advisor_job_detail_view.dart` (dossier + dock grammar), and the Phase
13 cockpit + Phase 14 register as direct same-product siblings (shell,
pods, tables, records, sheets). Layouts differ per task (§2); grammar is
shared. Cheaper output nowhere.

---

## 5. Contracts proof (UI-only, zero logic changes)

Frozen and byte-identical: all seven notifiers' methods/state, every
mapping formula (`lowStock`, urgency parse, aging buckets, valuation basis
is display-only over frozen fields), entities, search/filter semantics,
`addItem`/`adjustStock`/`addMember`/`toggleActive`/`moderate`/`setPlan`
payloads, Hive, routes/params/nav semantics, auth/role guards, DTOs.
Allowed diffs only: the seven views, `*.arb` strings, test/golden files.
Zero shared production churn this phase (the one record-row squeeze found
in audit was solved owner-side with full-width status blocks).

Non-UI files touched (one-line justification each):

- `owner l10n/app_{en,ar}.arb` + `gen/*` — new keys + regen only.
- `test/features/dashboard/owner_analytics_test.dart`,
  `test/owner_phase15_visual_test.dart`, `test/goldens/owner15_*.png` —
  new Phase 15 evidence.

---

## 6. Deltas made this session (all owner-side)

Seven views rebuilt; ~110 l10n keys; 19-test contract suite (incl.
no-fake-action guards for collect/renew/reply) + 36-golden visual suite
(7 views + filter sheet); three audit-driven overflow fixes (bucket money
wrap, strip aspect, team filter pattern); one dead key removed
(`ownerTmAll` superseded by the shared All chip).

---

## 7. Gates & evidence

**Gate 1 — Engineering:**

- `flutter analyze` (owner_app): **0 issues**.
- Owner suite: **152/152 green** — all prior suites plus
  `owner_analytics_test` (19: bucket sums, contact sheet, no-match,
  no-collect-actions, at-cost valuation, strip separation, category
  filter, adjust call, tabs, directory/filter/toggle/clock, strip/rows/
  role filter, countdowns, no-renew, approve-toast, no-reply, plan
  switch) and `owner_phase15_visual_test` (36, takeException-guarded).
- `arb_parity_test` (owner): **green**. Shared suite untouched this
  phase (419/419 from Phase 14 stands; no shared diffs).
- Deprecation guard: **3/3 green** (re-proven; §0).
- Manual guards: zero `AppColors.*`/`AppDarkColors`/raw widths/breakpoints
  in owned files; zero new app-local duplicates; bespoke bars stay dead.

**Gate 2 — Visual (headless):**

- 36 goldens, real fonts, deterministic rerun green, reviewed native
  in-session:
  `reports/PHASE_15/screens/owner15_{receivables,inventory,team,attendance,expiry,feedback,subscription}_{390_en,390_ar,768_en,1280_en,390_dark}.png`
  plus `owner15_inventory_sheet_390_en.png`
  (test originals in `apps/owner_app/test/goldens/`).
- Matrix: 390 EN/AR + 768 EN + 1280 EN + 390 dark per surface (+ sheet);
  RTL with LTR-locked money/phones/plates/dates; desktop tables +
  side-by-side panes; overflow audited 320→1440 at 1.0x/1.3x.
- **Live device: NOT PERFORMED** (no device in this session).

**Failures & owners (none owned by this phase):**

| Item | State | Owner |
| :--- | :--- | :--- |
| Owner `pages/*` outside the 7 (job_cards untouched this phase) | Untouched | Phase 14 owns those files |
| Payroll/renew/reply/supplier-link/target endpoints | Deferred for missing contracts (§3) | Backend / follow-up |

---

## 8. Files changed (Phase 15 scope)

- Rewritten: `accounts_receivable_view.dart` (O9),
  `inventory_view.dart` (O10), `team_view.dart` (O11),
  `attendance_view.dart` (O12), `document_expiry_view.dart` (O13),
  `feedback_moderation_view.dart` (O14), `subscription_view.dart` (O15)
- Kept: all providers/entities/datasources/router
- L10n: `app_en.arb`/`app_ar.arb` (+~110 keys), `gen/*` (regen)
- Tests: `test/features/dashboard/owner_analytics_test.dart` (new),
  `test/owner_phase15_visual_test.dart` (new),
  `test/goldens/owner15_*.png` (36, new)
- Docs: `reports/REPORT_PHASE_15.md`, `reports/PHASE_15/screens/*` (36),
  README ledger row 15

Staff touches: **none**. Runner artifacts committed: **none**
(`test/failures/` debris removed; goldens are the evidence).
