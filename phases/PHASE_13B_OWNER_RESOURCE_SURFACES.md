# PHASE 13B — Owner: Resource Surfaces

## A. Phase identity

- **Phase number:** 13B (part 2 of 2; split from the former Phase 13)
- **Title:** Owner Resource Surfaces — inventory (parts/suppliers/POs), attendance, team directory
- **Objective:** Redesign the owner's people-and-stock surfaces onto the unified listing/table/form grammar with consistent toolbars, validation, and complete states — replacing all ad-hoc search fields and hand-rolled containers in these pages.
- **Priority:** High
- **Dependencies:** Phase 12 (drill-ins); Phase 03A/03B (primitives + tables)
- **Estimated scope:** Medium-Large

## B. Repository context

Files (relative to `apps/owner_app/`):

- `lib/features/dashboard/presentation/pages/inventory_view.dart`:
  `_ItemsTab` (parts/stock, low-stock highlight, +/- adjust), `_SuppliersTab`,
  `_PurchaseOrdersTab`; `_showAddItemSheet`; skeleton; error + retry when empty;
  snackbar; 6 hand-rolled containers + 11 hard-coded hex.
- `pages/attendance_view.dart`: shift-register totals + per-staff cards; date
  picker; role filter; `ErrorView` + retry; `EmptyState`; `RefreshIndicator`.
- `pages/team_view.dart`: staff directory with summary, search, role filter,
  enable/disable staff, FAB Add Member → `_showAddStaffSheet` →
  `_showLoginCreatedDialog`; skeleton/error/empty; 9 hard-coded hex.
- Providers: inventory/attendance/team providers under
  `features/dashboard/presentation/providers/` — preserve APIs.
- Navigation in: dashboard quick actions (Inventory, Attendance, Team & Roles).
- Tests: `test/logic_test.dart` (`OwnerAttendanceRecord.fromJson`) — untouched;
  no page widget tests yet.

## C. Design objectives

1. **One listing grammar** across all three pages (header → toolbar → content →
   states → pull-to-refresh), as in 13A.
2. **Inventory:** three tabs (Parts & Stock / Suppliers / Purchase Orders) with
   consistent toolbars; low-stock rows highlighted via semantic tokens + inline
   "Low stock" pill; adjust-stock stepper with confirmation; Add Part sheet
   gains local validation for required fields (name/SKU/price/qty/reorder);
   suppliers searchable if data allows; POs with status pills; per-tab empty,
   no-match and error states.
3. **Attendance:** summary strip (present/absent/late if data exists) → date
   control (picker + prev/next day steppers) → staff cards with check-in/out
   times (tabular); role filter preserved; complete states.
4. **Team:** summary → search + role filter → member cards (avatar, role,
   contact, active state) → enable/disable with confirmation → FAB Add Member
   sheet (inline validation, busy submit) → credentials dialog (copyable
   credentials; share action unchanged).
5. **Cleanliness:** zero hard-coded hex/radii in touched files; `AppSearchField`
   everywhere.

## D. Screens and workflows

| Screen | New hierarchy | Key interactions | States |
|---|---|---|---|
| `InventoryView` (3 tabs) | tabs → toolbar → lists/tables | search, adjust stock (confirm), add part (validated), refresh | per-tab skeleton/empty/no-match/error |
| `AttendanceView` | summary → date control → staff cards | date pick, prev/next day, role filter, refresh | skeleton, empty, error+retry |
| `TeamView` | summary → toolbar → members | search, filter, enable/disable (confirm), add member, credentials dialog | skeleton, empty-filter, error+retry, busy |
| Add Part sheet | form grammar | validate, submit | validation, busy, error |
| Add Staff sheet + credentials dialog | form → result | validate, submit, copy/share credentials | validation, busy, error |

Route contracts unchanged (`/inventory`, `/attendance`, `/team`).

## E. Responsive specifications

- **Compact:** record rows; toolbars stack; sheets for forms; FAB clears nav.
- **Medium:** rail; items rows show column values; team/attendance 2-up grids.
- **Expanded/large:** true tables (items, POs, team) with hover, kebab menus,
  tabular money; content caps; attendance timeline beside summary.
- 320 px: no overflow; stepper and date control fit.
- 1.3× scale: toolbars wrap cleanly.
- RTL: tables mirror; steppers mirror; date control localized; chevrons flip.

## F. Localization and RTL

- All strings localized (`ownerInventory*`, `ownerAttendance*`, `ownerTeam*`)
  EN+AR; role/status labels localized.
- Money/dates via `AppFormatters`; SKUs stay Latin.
- Tests: page widget tests EN+AR; RTL assertions; 320 px clean.

## G. Design system integration

- Use: `AppPageHeader`, `AppTopBar`, `AppSearchField`, filter chips, table
  primitives + `AppRecordRow`, quantity stepper (03A), `StatusPill`,
  `AppButton`, `AppActionBar` (sheets), `AppConfirmationDialog` (adjust stock,
  disable staff), `showAppModalSheet` (forms), `AppTextField`/`AppDropdownButton`
  (validated forms), `AppSkeleton`, `EmptyState`, `ErrorView`, `AppInfoPanel`,
  `UserAvatar`, `AppKpiCard` (summaries).
- No new tokens expected.

## H. Technical implementation

- Modify: the three page files; owner ARB; add owner page widget tests.
- Preserve: inventory adjust/add methods, attendance load semantics, team
  enable/disable + add-staff login creation payload and result dialogs.
- Local validation additions are UI-only (no API changes).
- No route/provider/API changes; no new packages.

## I. Functional preservation

- Inventory adjustments and add-part submission unchanged.
- Attendance date/filter semantics unchanged; `OwnerAttendanceRecord` mapping
  untouched.
- Team enable/disable and staff-login creation unchanged (payload, dialogs,
  share).
- Dashboard quick actions still land on these pages.
- `logic_test.dart` untouched and green.

## J. Testing requirements

- `melos run analyze:owner`; `melos run test:owner`.
- New widget tests: inventory tab states + adjust + add validation; attendance
  date/filter + states; team enable/disable confirm + add-member validation +
  credentials dialog; EN+AR; RTL; 320/390/768/1280; 1.3×.
- Goldens: inventory items (EN compact + expanded), team, attendance; AR golden
  for inventory.

## J2. Visual quality gates (mandatory)

Static analysis and widget tests alone are **not** proof of design quality. This
phase is not complete until all of the following evidence exists:

1. **Rendered review** — run the owner app and visually review inventory (all
   three tabs + add sheet), attendance and team (incl. add-member and
   credentials dialog); no screen may be signed off from code-reading alone.
2. **Form factors** — renders captured at mobile (≤430 px), tablet (600–1023 px)
   and desktop (≥1280 px).
3. **Locales** — EN-LTR and AR-RTL renders; table mirroring, stepper mirroring
   and date control reviewed in AR.
4. **State matrix** — low-stock highlight, per-tab empty/no-match, add-part
   validation errors, attendance empty/error, team empty-filter/error,
   enable/disable confirm, credentials result. Realistic parts/staff fixtures.
5. **Interaction verification** — stock stepper + confirm, add forms submit,
   date picker + day stepping, role filters, enable/disable, credentials
   copy/share.
6. **Accessibility** — 1.0–1.3× scale clean; ≥48 px controls; semantics on
   steppers, rows and FAB; contrast sampled on low-stock pill.
7. **No visual overflow** at 320 px in either locale.
8. **Evidence attached** — goldens or a screenshot pack at
   `phases/reports/PHASE_13B/` named `screen_width_locale_state.png`. Section K
   is unmet without this evidence.

## K. Acceptance criteria

1. Three pages + sheets redesigned on shared grammar; zero hard-coded hex in
   touched files; ad-hoc search fields removed.
2. Provider interactions unchanged (tests).
3. EN/AR complete; RTL correct; responsive per E.
4. `melos run analyze:owner` + `test:owner` green; J2 evidence attached.

## L. Deliverables

- File changes; ARB counts; validation additions; test evidence; goldens; known
  limitations.

## M. Completion gate

Stop after this phase — 13A + 13B close the former Phase 13. Phase 14 follows
once both are signed off. Do not begin until explicitly instructed.
