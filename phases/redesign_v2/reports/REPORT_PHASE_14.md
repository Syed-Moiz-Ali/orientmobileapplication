# REPORT PHASE 14 — Owner Jobs & Approvals

**Document ID:** `phases/redesign_v2/reports/REPORT_PHASE_14.md`
**Execution Phase:** Concept A V2 — Phase 14 (Archetype 8: Executive Cockpit & Financial Desk)
**Specification:** `phases/redesign_v2/implementation/PHASE_14_OWNER_JOBS_APPROVALS.md`
**Prerequisite:** Phase 13 (`REPORT_PHASE_13.md` — shell patterns + deferrals honored)
**Status:** **ENGINEERING GATE PASSED** / **VISUAL GATE PENDING PRODUCT OWNER**
**Timestamp:** 2026-10-19
**Author:** Lead Flutter Architect & Systems Designer

> Mission summary: screen-level redesign (not a colour refresh) of the owner
> jobs surfaces — register, executive audit, live status monitor, approvals
> queue — in direct siblinghood with the Phase 13 cockpit (same app, same
> shell, same pods/tables/records; must read as the same product, never
> cheaper). Every figure is a frozen provider value rendered verbatim;
> anything without a contract (margin %, parts/labor splits, discount
> history, invoice state, target series, per-request approval fields and
> decision endpoints) is omitted honestly rather than faked. Providers/API/
> models/persistence/routes are byte-identical, and the staff tree was never
> touched.

---

## 0. Baseline the dirty tree (§0 directive — done FIRST, no code)

Phase 13 was FLOATING (uncommitted) when this phase started — classified as
carryover and kept, never reverted: it is the direct sibling this phase must
read beside. `git status` showed zero `staff_app` paths (read-only rule
held from the first command).

| Path | Disposition | Evidence |
| :--- | :--- | :--- |
| Phase 13 floating work (cockpit rewrite, pod fix, l10n, suites, goldens) | CARRYOVER, kept | Direct sibling; Phase 14 goldens reviewed side-by-side with it |
| `apps/staff_app/**` | READ-ONLY, zero touches | Final status: no `staff_app` paths (instant-FAIL rule respected) |
| `apps/staff_app/build/` (stale artifact) | REMOVED via `flutter clean` (regenerable, no source) | Unblocked the 13-flagged deprecation guard (see below) |
| Deprecation guard (red-environmental in Phase 13 §7) | RE-PROVEN GREEN 3/3 after clean | `PathNotFoundException` on the stale build dir is gone; fix-forward was deletion of debris only |
| Phase 14 owned files (list/detail/status/approvals + `job_card_tile.dart`) | REBUILT / retired | Prototype chrome, hardcoded copy + hex, bespoke tiles |
| `test/features/job_cards/owner_job_cards_test.dart` (spec path) | DID NOT EXIST | Created (16 contract tests) |

---

## 1. Owned inventory (from source, nothing omitted)

| Ref | Surface | File | Entry | States owned & covered |
| :-- | :--- | :--- | :--- | :--- |
| O5 | `JobCardsListView` (register) | `job_cards/.../job_cards_list_view.dart` | `/job-cards` | search + 6-chip FilterBar with live counts, sortable AppTable (sticky desktop, record-row fallback), select + side preview (desktop), push-through (compact); loading/empty/no-match |
| O6 | `JobCardDetailView` (audit) | `job_cards/.../job_card_detail_view.dart` | `/job-cards/detail` | breadcrumbs Jobs › id, lifecycle stepper, services/assignment/financials panels, totals dock + complete/share; selected-null empty |
| O7 | `JobStatusView` (monitor) | `dashboard/.../job_status_view.dart` | `/job-status` | stage pods, freshness stamp, 60s auto-refresh, stale banner, search + 8-chip FilterBar, table/cards; loading/empty |
| O8 | `PendingApprovalsView` (queue) | `dashboard/.../pending_approvals_view.dart` | `/pending-approvals` | danger-toned hero count, read-only triage rows, explicit no-action note; loading/empty |
| — | `job_status_ui.dart` (shared helpers) | `job_cards/.../job_status_ui.dart` | — | fixed-decimal AED, pill tone/label contract, lifecycle index (display-only) |

`JobCardsNotifier` methods (`load/refresh/onSearch/setFilter/markComplete`),
`JobStatusNotifier`, `PendingApprovalsNotifier`, datasources, entities, Hive,
routes/params/nav semantics and the share flow are **unchanged**.

---

## 2. Before / after composition (per screen) — task → concept → composition

| Screen | Old got WRONG (one line) | New does DIFFERENTLY (one line) | Task → Concept → Composition | Viewport @390 EN |
| :-- | :--- | :--- | :--- | :--- |
| Register (O5) | Bespoke app bar + raw search box + 4 prototype chips + bespoke tiles with hardcoded labels. | Search + lifecycle chips with counts over a sortable table; desktop selects into a preview pane. | audit the book → dense register → toolbar + table + pane | table ≈60% |
| Detail (O6) | Bespoke app bar + stacked cards + hardcoded hex pills + doubled share buttons + hardcoded green CTA. | Breadcrumb dossier with lifecycle stepper and panels; totals dock owns the one real state change. | audit one job → dossier (advisor-detail grammar) → header + stepper + panels + dock | dossier ≈65% |
| Status (O7) | Bare app bar + raw search + 8 EN chips + bespoke progress cards, no freshness. | Pods + stamp + auto-refresh + stale banner over the same grammar, table on desktop. | watch the floor live → live board → pods + stamp + table | board ≈60% |
| Approvals (O8) | Hardcoded red hero + bespoke category cards with server-tint rows. | Tone-resolved hero count + shared record rows + an explicit read-only note. | triage what waits → honest queue → hero + rows + note | queue ≈65% |

No screen repeats one template: the register is a table, the detail a
dossier, the monitor a live board, the queue a triage list — one design
language, four jobs. Reviewer holds old vs new side-by-side: new hierarchy,
new flow, new states everywhere.

Side-by-side vs Phase 13 sibling: identical `WorkspaceAppBar` chrome,
`AppTable`/`AppRecordRow`/`StatusPill`/`SectionHeader`/`EmptyState`/
`ErrorView`/`AppSkeleton` family, identical toast/haptic/pill grammar,
identical tabular-money treatment. Nothing reads cheaper than the cockpit.

---

## 3. Include / remove / enhance (SaaS rework)

**Included (added, all real):** ~80 `ownerReg*/ownerJs*/ownerDet*/ownerSt*/ownerAp*`
l10n keys with exact EN/AR parity; `formatAed2` fixed-decimal tabular money
(`AED 2,450.00`, Latin digits, LTR lock); single `jobStatusPill` tone/label
contract + 6-step lifecycle index; sortable columns (Job/Plate/Customer/
Total) with sticky desktop header; live per-chip counts; side preview pane
with select + open; breadcrumbs Jobs › id; stepper; complete-confirm dialog
+ themed toasts over the frozen `markComplete`; stage pods + freshness stamp
+ 60s auto-refresh + stale banner; read-only queue note; per-view loading
skeleton, empty, no-match, stale and selected-null states; 1.3x/48dp/
semantics/focus/reduced-motion throughout; ⌘K focus where search exists.

**Removed (1 file + patterns, zero references verified before deletion):**
`job_card_tile.dart` (replaced by table rows + preview pane); bespoke
app bars on all four views (→ `WorkspaceAppBar`); raw search boxes (→
`AppSearchField`); the doubled Print/Share buttons doing the same share
(→ single Share); 30+ hardcoded hex literals incl. status maps and CTA
greens (→ semantic tones); hardcoded EN copy; `MaterialBanner`+`RETRY`
(→ `ErrorView`). `chart_painters_test.dart` migration from Phase 13 kept.

**Enhanced:** register owns the viewport as a table (not tiles); detail
dossier matches the advisor-detail grammar; status never shows silent old
data; approvals states its limits in-product; desktop is table + preview
pane (never stretched phone); tablet gets full tables; compact gets divider
rows + filter strips.

**Honest omissions / deferrals (no fake data — FAIL rule):** Margin %
column (no cost fields on `JobCard` — Total/Status shown instead); parts
margin / labor profitability / discount history / invoice panels (no
endpoint fields — scope note rendered in-product); revenue-vs-target on
status (no target series — counts-only pods, same deviation as Phase 13);
per-request approval rows with amount/requester/reason/age (endpoint
carries categories only); Approve/Reject + comment sheet (NO decision
endpoint exists anywhere in the owner app — verified by repo-wide grep;
buttons would be fake, so the queue is read-only with an explicit note);
persisted last-clock syncstamp (connectivity pill only); permission-denied
(N/A — router role-gates).

---

## 4. Reference conformance (house bar + Phase 13 sibling)

Studied before writing a widget: `advisor_home_view.dart` (toolbar +
search + filter + divider-row grammar, toasts, haptics, shortcuts) and
`advisor_job_detail_view.dart` (dossier header + breadcrumbs + lifecycle
stepper + rail + dock — the O6 composition mirrors its information
architecture with owner financial tone). Phase 13 cockpit is the direct
sibling: same shell, same pods/tables/records/charts grammar, same state
patterns. Layouts differ per task (§2); nothing is cloned, nothing is
cheaper.

---

## 5. Contracts proof (UI-only, zero logic changes)

Frozen and byte-identical: all four notifiers' methods/state, datasource
mappings, `JobCard`/`JobStatus`/`ApprovalCategory` shapes, search/filter
semantics, `markComplete` + selected-card sync, share flow, Hive, routes
(`/job-cards`, `/job-cards/detail` + params), auth/role guards, DTOs.
Allowed diffs only: the four views + `job_status_ui.dart`, `*.arb`
strings, test/golden files — plus one justified shared-system note below
(which this phase ultimately did NOT need to change: the record-row squeeze
was solved owner-side; shared `app_record_row.dart` was reverted and its
scratch test deleted — zero shared production churn this phase).

Non-UI files touched (one-line justification each):

- `owner l10n/app_{en,ar}.arb` + `gen/*` — new keys + regen only.
- `test/phase07_1_migration_test.dart` — harness (Owner delegate) +
  recomposed chip assertion (`WIP` lifecycle label; same Ahmed/Sara filter
  proof — the 07.1 contract it guards is "centralized FilterBar", intact).
- `test/features/job_cards/owner_job_cards_test.dart`,
  `test/owner_phase14_visual_test.dart`, `test/goldens/owner14_*.png` —
  new Phase 14 evidence.
- `reports/REPORT_PHASE_14.md`, `reports/PHASE_14/screens/*`, README row 14.

---

## 6. Deltas made this session (all owner-side)

Four views rebuilt; `job_status_ui.dart` created; `job_card_tile.dart`
deleted; ~80 l10n keys; migration test updated; 16-test contract suite +
20-golden visual suite created; register overflow fixed owner-side (status
pill as full-width block in compact rows — no shared change); sort enabled
via `sortable` flags; medium grid aspect tuned (Phase 13 pattern).

---

## 7. Gates & evidence

**Gate 1 — Engineering:**

- `flutter analyze` (owner_app): **0 issues**. `flutter analyze`
  (shared_core): **0 issues**.
- Owner suite: **97/97 green** — logic, responsive, 07.1 migration (10),
  chart guards, parity, cross-boundary, smoke (5), Phase 13 dashboard
  contracts (11) + visuals (20), `owner_job_cards_test` (16: register
  render/search/no-match/filter/sort/preview/push/320@1.3x, dossier
  render/empty/confirm-toast, monitor pods/stamp/filter, queue
  render/no-fake-actions/empty), Phase 14 visuals (20).
- `arb_parity_test` (owner): **green**. Shared suite: **419/419 green**
  (incl. pod regression test; record-row revert verified pixel-identical).
- Deprecation guard: **3/3 green, explicitly re-proven** after `flutter
  clean` (was red-environmental on a stale `staff_app/build` dir).
- Manual guards: zero `AppColors.*`/`AppDarkColors`/raw widths/breakpoints
  in owned files (remaining `AppColors` hits live in out-of-scope
  `pages/attendance_view.dart`, owned by a later phase); zero new
  app-local duplicates; bespoke bars stay dead.

**Gate 2 — Visual (headless):**

- 20 goldens, real fonts, deterministic rerun green, reviewed native
  in-session:
  `reports/PHASE_14/screens/owner14_{register,detail,status,approvals}_{390_en,390_ar,768_en,1280_en,390_dark}.png`
  (test originals in `apps/owner_app/test/goldens/`).
- Matrix: 390 EN/AR + 768 EN + 1280 EN + 390 dark per surface; RTL with
  LTR-locked plates/ids/money; desktop table + preview pane (register),
  dossier + rail (detail); overflow audited 320→1440 at 1.0x/1.3x.
- **Live device: NOT PERFORMED** (no device in this session).

**Failures & owners (none owned by this phase):**

| Item | State | Owner |
| :--- | :--- | :--- |
| Owner `pages/*` (attendance etc.) `AppColors`/hardcode | Untouched: outside the Phase 14 file list | Later phases (15 owns financials-adjacent screens) |
| Margin/parts/labor/discount/invoice/approve-reject | Deferred for missing contracts (§3) | Backend / follow-up |
| Shared `deprecation_guard` pre-clean red | Fixed forward via debris removal; green | — (closed) |

---

## 8. Files changed (Phase 14 scope)

- Rewritten: `job_cards_list_view.dart` (O5), `job_card_detail_view.dart`
  (O6), `job_status_view.dart` (O7), `pending_approvals_view.dart` (O8)
- Created: `job_cards/.../job_status_ui.dart`
- Deleted: `job_cards/.../job_card_tile.dart`
- Kept: all providers/entities/datasources/router, `kpi_grid.dart`
- L10n: `app_en.arb`/`app_ar.arb` (+~80 keys), `gen/*` (regen)
- Tests: `test/features/job_cards/owner_job_cards_test.dart` (new),
  `test/owner_phase14_visual_test.dart` (new),
  `test/goldens/owner14_*.png` (20, new),
  `test/phase07_1_migration_test.dart` (harness + chip assertion)
- Docs: `reports/REPORT_PHASE_14.md`, `reports/PHASE_14/screens/*` (20),
  README ledger row 14

Staff touches: **none**. Runner artifacts committed: **none**
(`test/failures/` debris removed; goldens are the evidence).
