# PHASE 00 — Visual Design Validation

## A. Phase identity

- **Phase number:** 00
- **Title:** Visual Design Validation (runnable design prototype + screenshot review before design system rollout)
- **Objective:** Prove the 2026 visual direction on **real screens from this repository** before any production code or token rollout: build an isolated, runnable prototype of six representative production screens with real entity data, capture EN-LTR and AR-RTL screenshot packs at mobile/tablet/desktop widths, and obtain an explicit visual sign-off recorded in `00_VISUAL_DIRECTION.md`. A rejection here changes a prototype, not the product.
- **Priority:** Critical gate (Phase 01 must not start before sign-off; the prototype is required to answer "does the new direction actually look and behave premium?" with evidence instead of prose)
- **Dependencies:** None. Reads the current repository as-is; does not modify any application code.
- **Estimated scope:** Large (six screens + shell + fixtures + visual pack + review loop)

> **What this phase explicitly is not:** a redesign of the production apps, a
> token change in `shared_core`, or a dependency change anywhere. Only a new
> isolated prototype app (`apps/design_prototype/`) and planning documents are
> created. `git status` at the end must show zero changes under
> `apps/staff_app|owner_app|customer_app|crm_app|packages/`.

---

## B. Repository context — the six representative screens (real paths, real content)

Screens are chosen to span the product's structural archetypes. Each prototype
screen mirrors the real composition of the referenced production screen (same
sections, same fields, same actions) rendered in the new visual language.

| # | Archetype | Production source (read-only reference) | Why this one |
|---|---|---|---|
| 1 | **Dashboard** | `apps/owner_app/lib/features/dashboard/presentation/dashboard_view.dart` + `widgets/owner_dashboard_page.dart`, `header_banner.dart`, `kpi_grid.dart`, `kpi_card.dart`, `job_card_register_card.dart`, `sales_trend_card.dart`, `sales_vs_expenses_card.dart`, `quick_actions_row.dart` | The flagship executive surface: hero banner, KPI strip, register table, charts, 12 quick actions |
| 2 | **Data-listing workspace** | `apps/owner_app/lib/features/job_cards/presentation/pages/job_cards_list_view.dart` (+ `widgets/job_card_tile.dart`, `filter_chip_bar.dart`) | Real search, status filter chips, row grammar, desktop table transformation; representative of 10+ listing screens |
| 3 | **Detailed operational screen** | `apps/staff_app/lib/features/technician/presentation/widgets/job_detail_sheet.dart` (TechnicianJobDetailView) | Task checklist execution, state morphing, parts/escalation actions — the densest daily-use screen |
| 4 | **Create/edit form** | `apps/customer_app/lib/features/customer/presentation/add_vehicle_view.dart` | Three-section form + validation + sticky save bar; mirrors `LeadFormSheet` and `_showAddStaffSheet` patterns |
| 5 | **Authentication screen** | `packages/shared_auth/lib/src/presentation/pages/login_view.dart` (+ `auth_surface.dart` `AuthShell`, `auth_field.dart`, `auth_button.dart`) | Entry point of every app; validates identity panel, method segment, OTP density |
| 6 | **Complex workflow interaction** | `apps/staff_app/lib/features/advisor/presentation/pages/inspection_sheet_view.dart` + `.../inspection_pages/presentation/vehicle_map/vehicle_body_condition_panel.dart` + `vehicle_inspection_map.dart` | Multi-panel interaction: checkpoint list + section rail + vehicle damage map + media/audio; the hardest layout problem in the product |

Backup candidate if review wants more scope: customer 4-step booking wizard
(`apps/customer_app/lib/features/customer/presentation/customer_book_service_view.dart`
+ `widgets/customer_booking_steps.dart`) — prepared as an optional 7th
prototype screen, same methods.

**Real data shapes for fixtures** (prototype fixtures must mirror these field
sets — no invented dummy copy):

- Job cards: `apps/owner_app/lib/features/job_cards/domain/entities/job_card.dart`,
  `packages/shared_core/lib/src/models/owner_models.dart` (`OwnerJobCard*`).
- Technician jobs/tasks: `apps/staff_app/lib/features/technician/domain/entities/technician_entities.dart`
  (+ `work_task_entity.dart`).
- Vehicles: `apps/customer_app/lib/features/customer/domain/entities/customer_entities.dart`
  (vehicle fields: plate, make, model, year, mileage).
- KPIs/owner dashboard: `owner_models.dart` dashboard entities; sales categories
  from `sales_category_card.dart` usage.
- Auth: login methods/`PasswordIdentifier` from
  `packages/shared_auth/lib/src/presentation/providers/login_provider.dart`.
- Inspection: `apps/staff_app/lib/features/advisor/inspection_pages/data/models/inspection_model.dart`
  + `vehicle_damage_map_model.dart` + the real vehicle mapping asset
  `apps/staff_app/assets/vehicle_maps/advisor_car_top_mapped.svg`.

Fixture rule: 2–3 realistic records per screen (a mix of states: one urgent,
one normal, one completed/empty-adjacent) using credible Gulf-workshop data
(AED amounts, UAE plates like `A 12345`, plausible Arabic customer names in the
AR pass — **not** "Lorem ipsum", "John Doe", "Item 1").

---

## C. Design objectives

The prototype exists to answer six review questions with rendered evidence:

1. **Does the visual language feel premium and calm at a glance** (surfaces,
   color restraint, typography hierarchy) on a data-dense dashboard?
2. **Does the row/table grammar survive real data** (long Arabic names, amounts,
   statuses) in listing contexts, and does it transform correctly from cards
   (mobile) to table (desktop)?
3. **Is the operational detail screen scannable under pressure** (next action
   obvious, state changes legible, ≥48 px targets)?
4. **Do forms feel guided, not interrogated** (section rhythm, label placement,
   validation, sticky action honesty)?
5. **Does auth feel trustworthy and branded per app** while staying calm?
6. **Can the hardest interaction (damage map + checkpoints) be read instantly**
   (panel states, legend, RTL behavior, media affordances)?

Each prototype screen must demonstrate the six cross-cutting pillars:

- **Hierarchy:** eyebrow → title → value → metadata; one focus region per view.
- **Surfaces:** cool-slate canvas, white cards with hairline borders, one navy
  high-emphasis region max, semantic tints only for status.
- **Navigation language:** same selected-state vocabulary as production
  (`AppAdaptiveNavigationFrame` behavior: cobalt tint, filled icon, heavier
  label) shown in the prototype shell at rail + bottom-bar variants.
- **Typography:** the spec role scale (Plus Jakarta Sans + Arabic family) with
  tabular numerals on all money/quantity data.
- **Motion:** `AppMotion` timings only (nav selection, sheet rise, state morph)
  — demonstrated in interactive review, not GIFs.
- **Responsive transformation:** the same screen meaningfully rearranged at
  mobile / tablet / desktop — never stretched or shrunk.

---

## D. Prototype screens and required compositions

### D1. Owner Dashboard (archetype 1)

- **Regions (order):** prototype top bar (brand mark + period control + bell +
  avatar) → identity/period hero strip (navy surface; workshop name, date/period
  chips, Live pill) → KPI strip (4 tiles: Revenue, Cars in Service, Pending
  Approvals, Completed Today; one navy hero tile allowed) → Job Card Register
  (categories table: Open / In Progress / Waiting Parts / QC / Completed, count
  + amount columns) → Analytics row (sales trend line + sales-vs-expenses bars,
  side-by-side ≥ tablet) → Quick Actions grid (12 tiles, real labels from
  `quick_actions_row.dart`).
- **Hierarchy proof:** period context is readable before numbers; register rows
  drill visually (hover on desktop, chevron affordance); no duplicate metric
  between hero strip and KPI tiles.
- **States to render:** populated (fixtures), loading (skeleton matching final
  layout), empty register, error banner with retry.
- **EN/AR:** period chips, category names, KPI labels, money formatting
  (`AED 12,450` EN / `12,450 د.إ` AR), chart axis labels.
- **Decisions this screen validates:** navy hero usage, KPI density (4-up max),
  chart styling from the chart palette, quick-action tile grammar.

### D2. Job Cards List (archetype 2)

- **Regions:** prototype top bar (back + "Job Cards" + count) → toolbar (search
  field + 5 filter chips: All / In Progress / Waiting Parts / QC / Completed) →
  content: mobile = record cards (job ref, plate chip, customer, service line,
  status pill, promised time, amount); ≥ expanded = true table (columns: Ref,
  Vehicle, Customer, Service, Status, Promised, Amount, kebab menu) with hover
  and selected row states.
- **Hierarchy proof:** one primary column pattern (vehicle + customer) dominates;
  money column tabular and aligned; statuses never color-only.
- **States:** populated (8 fixtures incl. long Arabic names), empty, no-match
  ("no cards match this filter" distinct from empty), loading skeleton, error.
- **RTL proof:** column order mirrors; chevrons flip; kebab on the end side.
- **Decisions validated:** row grammar adoption, filter chrome, table density
  (36–44 px rows), card-to-table transformation breakpoint.

### D3. Technician Job Detail (archetype 3)

- **Regions:** top bar (job identity: plate + service ref) → status/context row
  (stage pill, promised time, workshop bay) → execution column (task checklist
  rows with tap targets ≥56 px, progress bar, state morph demo: todo → in
  progress → done → held) → context column (vehicle info, customer contact
  actions, work description) → persistent actions (Request part, Escalate,
  Complete repair — gated like production).
- **States:** active job (populated), delayed/QC/completed variants (badges),
  empty task list, loading, error.
- **Responsive:** mobile single column with sticky bottom action bar; ≥ medium
  two columns; ≥ expanded context becomes a right panel.
- **Decisions validated:** checklist interaction model, state colors +
  labels, action bar placement, offline notice placement (prototype shows the
  "saved, will sync" chip variant).

### D4. Add Vehicle Form (archetype 4)

- **Regions:** top bar (title + discard affordance) → 3 sections (Vehicle
  details: plate, make, model, year, colour, mileage; Ownership: owner name,
  phone; Notes) → sticky action bar (Cancel / Save vehicle with busy state).
- **Validation demonstration:** required fields (plate, make, model), inline
  error copy EN/AR, error border tokens, helper text under identifier fields.
- **Identifier policy on screen:** plate and VIN inputs force LTR text direction
  with Latin content (mixed-input proof: Arabic owner name beside Latin plate).
- **Responsive:** single column mobile; two-column (fields | vehicle summary)
  ≥ medium; capped ~720 px ≥ expanded.
- **States:** pristine, focused, invalid, saving, save-error.
- **Decisions validated:** form section rhythm, label-above pattern, sticky bar
  honesty, mixed-direction input handling.

### D5. Login / Auth (archetype 5)

- **Regions (≥900 px split):** navy identity panel (brand mark, app name
  "Orient Staff/Customer/Owner/CRM" switchable, purpose line, security badge) |
  form card (identifier field, method segmented control password / one-time
  code, password field with visibility toggle, primary CTA, forgot-password
  link).
- **States:** default, focused field, invalid credentials notice (error tone),
  loading CTA, OTP entry variant (6 boxes) with resend countdown.
- **EN/AR:** identity copy both languages; OTP boxes in RTL; countdown text.
- **Responsive:** compact single column; tablet boxed card; desktop split.
- **Decisions validated:** identity panel direction, segmented control density,
  OTP sizing at 320 px.

### D6. Advisor Inspection (archetype 6 — hardest interaction)

- **Regions:** workflow indicator (Step 1 of 4) → section rail (engine /
  exterior / interior / electrical / notes — horizontally scrollable on mobile,
  vertical ≥ medium) → checkpoint list (Good/Fair/Poor three-state cards with
  media affordances) → damage map card (real `advisor_car_top_mapped.svg`
  rendering test; panels tap-highlight to severity color; legend; finding
  summary count) → sticky footer (Save draft / Preview).
- **Interaction proof:** tap a checkpoint → state cycles with haptic-style
  selection feedback; tap the map → finding sheet mock (severity + note);
  media square opens a source sheet.
- **States:** no ratings yet (progress 0 %), partial (e.g. 9/15 rated),
  complete, finding sheet open, exit-guard dialog.
- **RTL proof:** rail/chips/footer mirror; **vehicle outline itself does not
  mirror** (physical left/right preserved) — the surrounding UI mirrors only.
  This is the canonical RTL-exception test case for the whole program.
- **Responsive:** three-pane at ≥ expanded (rail | checkpoints | map+summary);
  two-pane at medium; stacked at compact.
- **Decisions validated:** damage-map legibility and color coding, three-state
  rating control, checkpoint density, workflow indicator style.

---

## E. Responsive specifications (prototype review matrix)

Every prototype screen is rendered and captured at:

| Width | Device class label | What the reviewer checks |
|---|---|---|
| 320×640 | small phone | no overflow, 48 px targets, Arabic strings un-clipped |
| 390×844 | phone | primary flow readability, bottom nav, sheets |
| 430×932 | large phone | long labels, chip wrapping |
| 600×960 | tablet portrait | rail appears, 2-col transforms |
| 768×1024 | tablet | master–detail / two-pane behavior |
| 1024×768 | laptop | table transforms, hover states, caps |
| 1280×800 | desktop | extended rail, 3-pane, dense rows |
| 1440×900 | large desktop | breadcrumb-free content caps, negative space balance |

For each screen × width: EN-LTR and AR-RTL. Minimum capture set: 6 screens ×
4 widths (320 / 390 / 768 / 1280) × 2 locales = **48 renders**, plus state
variants for the state matrix screens (dashboard loading/error, listing
empty/no-match, form invalid, workflow finding-sheet).

---

## F. Localization and RTL (prototype scope)

- The prototype does **not** consume the (not-yet-built) Phase 02 infrastructure.
  It ships a small provisional string map `lib/l10n/provisional_strings.dart`
  (EN + AR) typed as `Map<String, String>` per locale with the **approved copy**
  that Phase 02 later copies verbatim into the real ARB files (the prototype is
  the copy-authority for its six screens).
- Locale toggle in the prototype shell (`EN | العربية`) switches the whole
  prototype including direction; every screen must be reviewed in both.
- Arabic font: bundle `IBM Plex Sans Arabic` (400/500/600/700) in the prototype
  app under `apps/design_prototype/assets/fonts/`; fallback stack
  `IBM Plex Sans Arabic → Noto Sans Arabic → system` documented in code. If font
  files cannot be added in the executing environment, the fallback stack is
  still specified and the Arabic pass uses the platform Arabic font, with the
  font pairing decision marked "provisional — verify in Phase 02".
- Numerals: Latin digits for identifiers (plate, refs); Latin digits with
  locale grouping for money/quantities in **both** locales (decision recorded
  now to avoid churn; Eastern-Arabic numerals explicitly out of scope until a
  product request).
- Mixed input: D4 proves the identifier-field policy (LTR content in AR layout).
- The prototype's Arabic review is the first real RTL proof of the direction —
  findings feed `00_LOCALIZATION_RTL_STRATEGY.md` §2.5 and Phase 02.

---

## G. Design system integration (prototype-local, provisional)

- The prototype carries `lib/design/provisional_tokens.dart` — a single file
  mirroring `00_DESIGN_SYSTEM_SPEC.md` §2–§4 values (colors incl. dark set,
  type scale, spacing, radii, shadows, motion durations, chart palette).
  Header comment: **PROVISIONAL — do not ship; codified into `shared_core` in
  Phase 01.** The spec remains the authority; this file only makes the spec
  renderable.
- On review, changed values are edited **here first** and then recorded in
  `00_VISUAL_DIRECTION.md` (decision log). Phase 01 codifies the frozen values.
- The prototype must not import `shared_core` (it targets the new direction,
  not the current implementation) and must not be imported by any production
  app.
- Component inventory implied by the six screens (buttons, inputs, chips,
  cards, rows, table, skeletons, sheets, action bar, KPI tile, status pill,
  timeline pieces, damage map) is tracked in a checklist in the prototype
  README; it becomes the acceptance input for Phases 03A/03B — any ad-hoc
  pattern used by a prototype screen must be justified in the checklist.

---

## H. Technical implementation

Create a new, isolated Flutter app:

```
apps/design_prototype/
├── pubspec.yaml                (flutter only + existing font/image assets; NO new pub deps)
├── README.md                   (purpose, run instructions, "not shipped" warning, component checklist)
├── assets/fonts/ibm_plex_sans_arabic/…   (if obtainable; fallback documented)
├── assets/vehicle_map/advisor_car_top_mapped.svg   (copy of the real asset)
└── lib/
    ├── main.dart               (MaterialApp.router-less; home = prototype shell)
    ├── design/provisional_tokens.dart
    ├── l10n/provisional_strings.dart
    ├── fixtures/               (owner_dashboard_fixtures.dart, job_cards_fixtures.dart,
    │                            technician_job_fixtures.dart, vehicle_form_fixtures.dart,
    │                            auth_fixtures.dart, inspection_fixtures.dart)
    ├── shell/prototype_shell.dart   (screen switcher, locale toggle, width preset selector, dark toggle)
    └── screens/                (dashboards/owner_dashboard_prototype.dart, listings/job_cards_prototype.dart,
                                 detail/technician_job_detail_prototype.dart, forms/add_vehicle_prototype.dart,
                                 auth/login_prototype.dart, workflows/inspection_prototype.dart)
```

- Melos: the `apps/*` glob picks it up for `melos bootstrap`; it is **excluded
  from release/CI APK builds** (CI builds the four named apps explicitly — no
  CI change needed, verify and state this in the report).
- Charts (dashboard, inspection progress) use plain `CustomPaint` adapted from
  the existing painters (`apps/owner_app/.../dual_line_painter.dart`,
  `bar_chart_painter.dart`) — no chart dependency added.
- The damage map reuses the real asset + a simplified tap model sufficient for
  visual review (not production logic).
- Deterministic screenshot pipeline:
  `apps/design_prototype/test/visual_pack_test.dart` pumps each screen at the
  §E widths × EN/AR (and state variants) with `matchesGoldenFile`, producing
  PNGs under `test/goldens/`. A PowerShell helper `tools/capture_visual_pack.ps1`
  runs it and copies outputs to `phases/reports/PHASE_00/`. This satisfies
  "generate representative previews" with the repository's existing golden
  tooling. Manual `flutter run -d windows|chrome|android` is the interactive
  review path (motion + interaction).

Constraints:

- No new pub dependencies anywhere (prototype or workspace).
- No modification to `packages/*`, the four apps, `melos.yaml` scripts, or CI.
- No production routes/providers/imports.

---

## I. Functional preservation

- Zero production code changes (enforced by the `git status` acceptance check).
- No API/domain/auth/permission/persistence/offline/route/state-management
  surface is touched because nothing in the production dependency graph is
  touched at all.
- The prototype is deletable at any time without residue (when the program ends,
  Phase 20 may archive or remove it with a recorded decision).

---

## J. Testing and review requirements

1. `flutter analyze` clean inside `apps/design_prototype`.
2. `visual_pack_test.dart` generates the full capture matrix (48 base renders +
   state variants) deterministically (`flutter test --update-goldens` first run,
   then a verifying run).
3. Manual interactive review script (documented in the prototype README):
   walk each screen at each width, EN and AR, perform the §D interactions,
   toggle dark mode, capture any motion issues; log findings in
   `00_VISUAL_DIRECTION.md`.
4. Reviewers (requester = product owner) mark each screen: **Approved /
   Approved-with-changes / Rework**; changes are applied in-prototype and
   re-captured; the loop ends at full approval.
5. Regression guard: `melos run analyze` + the four app suites still pass
   unchanged (proves isolation).

## K. Acceptance criteria

1. Six prototype screens exist and visually mirror the production composition
   of their source screens (verified side-by-side against the referenced files).
2. Full capture matrix produced (≥48 base renders + state variants) under
   `phases/reports/PHASE_00/` with the naming scheme
   `screen_width_locale_state.png`.
3. Every screen reviewed in EN-LTR and AR-RTL at mobile, tablet and desktop;
   Arabic typography and RTL mirroring demonstrated (incl. the damage-map
   non-mirroring exception).
4. `00_VISUAL_DIRECTION.md` contains the signed decision log (approved values,
   amended values, rejected patterns, open questions with owners).
5. Component checklist complete; Phases 03A/03B inputs amended if the prototype
   proved the need for added/removed primitives.
6. `git status` proves only `apps/design_prototype/` and `phases/` changed.
7. `melos run analyze` + all four app test suites remain green (isolation
   proof).

## L. Deliverables

- `apps/design_prototype/` (runnable app + README + component checklist).
- Screenshot pack: `phases/reports/PHASE_00/` (golden PNGs, EN/AR, all widths,
  state variants).
- Updated `phases/00_VISUAL_DIRECTION.md` (signed decision log).
- Amended inputs (if any) for Phase 01 token values and Phases 03A/03B
  component catalog.
- Findings list for Phase 02 Arabic typography/RTL (font pairing confirmation,
  any mirroring surprises).

## M. Completion gate

Stop after the review sign-off. **Phase 01 must not begin until
`00_VISUAL_DIRECTION.md` shows full approval.** No production UI code may be
modified in this phase.
