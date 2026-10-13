# PHASE 13A — Owner: Job Lifecycle Surfaces

## A. Phase identity

- **Phase number:** 13A (part 1 of 2; split from the former Phase 13)
- **Title:** Owner Job Lifecycle — job cards list, job card detail, live job status pipeline, pending approvals
- **Objective:** Redesign the owner's job-workflow surfaces onto the unified listing/table/detail grammar with real desktop tables, consistent search/filter chrome, complete state coverage, and resolution of the dead pending-approvals affordance.
- **Priority:** High
- **Dependencies:** Phase 12 (dashboard drill-ins land here); Phase 03B (tables/rows/skeletons)
- **Estimated scope:** Large

## B. Repository context

Files (relative to `apps/owner_app/`):

- `lib/features/job_cards/presentation/pages/job_cards_list_view.dart`
  (search, `FilterChipBar`, `JobCardTile`, `EmptyState`, `CircularProgressIndicator`),
  `pages/job_card_detail_view.dart` (services/meta/estimate; complete/print/share;
  "No job card selected" fallback; 16 hard-coded hex colors),
  widgets `job_card_tile.dart`, `filter_chip_bar.dart`.
- `features/dashboard/presentation/pages/job_status_view.dart` (pipeline with
  9-stage filter, per-job `LinearProgressIndicator`, skeleton, per-filter empty;
  no error state; 11 hard-coded hex).
- `pages/pending_approvals_view.dart` (count + categories; **rows show a chevron
  but have no `onTap`** — resolve this phase; no error/empty states).
- Providers: `features/job_cards/presentation/providers/job_card_providers.dart`
  (`jobCardsProvider.load()`), dashboard providers for job status/approvals.
- Navigation in: dashboard register ("View All"), job-status/approvals quick
  actions; job detail via list rows.
- Tests: `test/logic_test.dart` (job card entity mapping) — untouched; no page
  widget tests yet.

## C. Design objectives

1. **One listing grammar:** `AppPageHeader` → toolbar (search + filters +
   primary action if one exists) → content (table ≥ expanded / record rows
   compact) → states (skeleton, empty, no-match, error+retry) → pull-to-refresh.
2. **Job cards list (T2):** `AppSearchField`, status filter chips with counts
   where data allows, rows: job ref + customer/vehicle identity + status pill +
   promised/completed time + amount (tabular); detail navigation unchanged.
   Desktop table with sortable columns only if client-side sorting from loaded
   data is possible (no new fetch logic).
3. **Job card detail (T3):** identity header (ref, customer, vehicle, status,
   priority) → services line-items table (tabular money) → meta (dates, branch,
   team) → estimate summary → actions (complete, print, share PDF, share) in a
   sticky action bar (compact) / header overflow (desktop). "No job card
   selected" becomes an `EmptyState` with a return action.
4. **Job status pipeline:** stage filter as horizontally scrollable chips
   (compact) / segment list (desktop); progress rows with localized stage
   labels; grouping by stage where data supports it; standardized per-filter
   empty; add error+retry.
5. **Pending approvals:** decision-first list (category → count → rows).
   **Product decision required in this phase:** if a repository method already
   exposes the drill-down destination, wire the chevron; otherwise remove the
   affordance and render rows static. No dead chevrons survive this phase.
6. **Cleanliness:** zero hard-coded hex/radii in touched files; ad-hoc search
   fields replaced by `AppSearchField`.

## D. Screens and workflows

| Screen | New hierarchy | Key interactions | States |
|---|---|---|---|
| `JobCardsListView` | header → toolbar → list/table | search, filter, open detail, refresh | skeleton, empty, no-match, error+retry |
| `JobCardDetailView` | identity → items → meta → estimate → actions | complete (confirm), print, share PDF, share | no-selection empty, busy, error |
| `JobStatusView` | header → stage filter → grouped rows | filter, open job (if wired today) | skeleton, per-filter empty, error+retry |
| `PendingApprovalsView` | categories with counts → rows | row action per documented decision | skeleton, empty, error+retry |

Route contracts unchanged (`/job-cards`, `/job-cards/detail`, `/job-status`,
`/pending-approvals`).

## E. Responsive specifications

- **Compact:** record rows (no tables); filter chips scroll; toolbar stacks
  (search full width, filters below); bottom padding clears nav.
- **Medium:** rail; rows show column values; job detail two-column
  (items | meta/estimate) where width allows.
- **Expanded/large:** true tables with hover, kebab menus, aligned tabular
  money; job detail two-column with sticky action header; content caps.
- 320 px: no overflow; chips scroll intentionally.
- 1.3× scale: toolbars wrap cleanly.
- RTL: table column order mirrors; money alignment per locale rules; chevrons
  flip.

## F. Localization and RTL

- All strings localized (`ownerJobs*`, `ownerApprovals*` namespaces) EN+AR;
  statuses via localized `AppStatusLabels`.
- Money/dates via `AppFormatters`; refs Latin.
- Tests: page widget tests EN+AR; RTL table/row assertions; 320 px clean.

## G. Design system integration

- Use: `AppPageHeader`, `AppTopBar` (pushed pages), `AppSearchField`, filter
  chips (theme), table primitives + `AppRecordRow` (03B), `StatusPill`,
  `AppButton`, `AppActionBar`, `AppConfirmationDialog` (complete), `AppSkeleton`,
  `EmptyState` (+no-match), `ErrorView`, `AppInfoPanel`.
- No new tokens expected.

## H. Technical implementation

- Modify: the four page files + job-card widgets; owner ARB; add owner page
  widget tests.
- Preserve: provider APIs (`jobCardsProvider.load()`, dashboard providers),
  navigation contracts, print/PDF/share behaviors.
- Pending-approvals decision documented (wire vs static) with rationale; if
  wiring, call only existing methods — no new backend calls.
- No route/provider/API changes; no new packages.

## I. Functional preservation

- Complete/print/share on job detail unchanged.
- Job status data mapping and displayed fields unchanged.
- Approvals counts/categories unchanged; only the affordance decision changes.
- `logic_test.dart` untouched and green.
- Dashboard drill-ins from Phase 12 land on the redesigned pages unchanged.

## J. Testing requirements

- `melos run analyze:owner`; `melos run test:owner`.
- New widget tests: list/search/filter/empty/no-match; detail actions
  callbacks + no-selection empty; status filter + per-filter empty + error;
  approvals decision behavior; EN+AR; RTL; 320/390/768/1280; 1.3×.
- Goldens: job cards list (EN compact + expanded) + job detail; AR golden for
  the list.

## J2. Visual quality gates (mandatory)

Static analysis and widget tests alone are **not** proof of design quality. This
phase is not complete until all of the following evidence exists:

1. **Rendered review** — run the owner app and visually review the list, detail,
   status and approvals pages; no screen may be signed off from code-reading
   alone.
2. **Form factors** — renders captured at mobile (≤430 px), tablet (600–1023 px)
   and desktop (≥1280 px).
3. **Locales** — EN-LTR and AR-RTL renders; table mirroring and money alignment
   reviewed in AR.
4. **State matrix** — skeleton/empty/no-match/error for the list; detail
   populated + no-selection; per-filter empty for status; approvals empty.
   Populated fixtures use realistic job cards (UAE plates, AED amounts).
5. **Interaction verification** — search/filter, row navigation, complete
   confirm, print/share, stage filtering; approvals rows behave per the
   documented decision (no dead affordance remains).
6. **Accessibility** — 1.0–1.3× scale clean; ≥48 px rows; semantics on rows and
   pills; contrast sampled.
7. **No visual overflow** at 320 px in either locale.
8. **Evidence attached** — goldens or a screenshot pack at
   `phases/reports/PHASE_13A/` named `screen_width_locale_state.png`. Section K
   is unmet without this evidence.

## K. Acceptance criteria

1. Four pages redesigned on shared grammar; zero hard-coded hex in touched
   files; ad-hoc search fields removed.
2. Provider/navigation/print behaviors unchanged (tests).
3. Approvals dead affordance resolved with a documented product decision.
4. EN/AR complete; RTL correct; responsive per E.
5. `melos run analyze:owner` + `test:owner` green; J2 evidence attached.

## L. Deliverables

- File changes; ARB counts; approvals decision note; test evidence; goldens;
  known limitations.

## M. Completion gate

Stop after this phase. Phase 13B (owner resources) follows; it may run in
parallel with 13A after Phase 12, but both must complete before Phase 14. Do not
begin until explicitly instructed.
