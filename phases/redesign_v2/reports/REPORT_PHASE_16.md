# REPORT PHASE 16 — Customer Garage at Airbnb Bar

**Document ID:** `phases/redesign_v2/reports/REPORT_PHASE_16.md`
**Execution Phase:** Concept A V2 — Phase 16 (Archetypes 2 + 11, Airbnb addendum binding)
**Specification:** `phases/redesign_v2/implementation/PHASE_16_CUSTOMER_GARAGE_HOME.md`
**Status:** **ENGINEERING GATE PASSED** / **VISUAL GATE PENDING PRODUCT OWNER**
**Timestamp:** 2026-10-19
**Author:** Lead Flutter Architect & Systems Designer

> Mission summary: screen-level redesign of the consumer garage — shell,
> home feed, bookings, vehicles, stepped add-vehicle, profile,
> notifications — as a warm Airbnb-grade product (imagery-first, airy,
> one CTA, warm copy), never a recolored enterprise form. Enterprise rails,
> breadcrumbs, tables and ⌘K are absent by mandate. Every claim derives
> from frozen provider data; anything without a contract (health scores,
> favorites, photos, promos, insurance, payroll-style extras, reply
> composer, swap-like actions) is omitted honestly rather than faked.
> Providers/API/models/math/validation/Hive/routes are byte-identical, and
> the staff and owner trees were never touched.

---

## 0. Baseline the dirty tree (§0 directive — done FIRST, no code)

Phases 13–15 were LANDED; the tree was clean. No floating diffs, no
mystery: nothing was built on unknown state.

| Path | Disposition | Evidence |
| :--- | :--- | :--- |
| Owner 13–15 (landed) | Reference siblings only | Phase 16 goldens reviewed against cockpit/register grammar spirit |
| `apps/staff_app/**`, `apps/owner_app/**`, `packages/**` (pre-existing) | READ-ONLY except two justified shared additions | Final status: no staff/owner paths; shared adds are new files + exports |
| Customer tree (prototype + 07.1 skeletons/scaffolds) | REBUILT per scope | 07.1 deleted names verified absent; skeletons/scaffolds kept |
| Customer analyzer 0; functional suites 443 green | KEPT green | Verified before rebuild |
| 80 golden failures at baseline | PRE-EXISTING ENVIRONMENTAL | 100% golden pixel drift (up to 94% diff: this environment renders fallback fonts); zero functional failures. Owned goldens re-rendered; out-of-scope drift inherited as-is |
| Mid-session incident: an external `git add -A` captured in-progress work as `31ebfa1e` (plus `test/failures/` debris) | RECORDED, worked around | No other author's work was clobbered (verified: the commit diffs equal this session's own early work). Debris removed from the tree; true baseline for this report is `95b75c8b`. One real regression it exposed (see §7) was fixed |

---

## 1. Owned inventory (from source, nothing omitted)

| Ref | Surface | File | Entry | States owned & covered |
| :-- | :--- | :--- | :--- | :--- |
| Shell | `CustomerScaffold` (consumer bar + bottom nav) | `widgets/customer_scaffold.dart` | all tabs | brand bar, bell + badge, avatar, offline pill (banner off), 4 tabs always |
| C1 | `CustomerHomeTab` (garage feed) | `widgets/customer_home_tab.dart` | tab 0 | greeting, carousel/grid, journey, tiles, garage rows, recent; loading/empty/error |
| C1a | `CustomerGarageCarousel` (hero) | `widgets/customer_garage_carousel.dart` | home | swipe pages (compact) / grid (tablet+), dots, per-vehicle booking |
| C2 | `CustomerBookingsTab` | `widgets/customer_bookings_tab.dart` | tab 1 | groups, failed-queue retry/remove, empty/error/loading |
| C3 | `CustomerVehiclesTab` + `CustomerVehicleRecord` | `widgets/customer_vehicles_tab.dart`, `.../customer_vehicle_record.dart` | tab 2 | art-band rows, VIN/specs, sync/delete recovery, grid positions |
| C4 | `CustomerProfileTab` | `widgets/customer_profile_tab.dart` | tab 3 | identity, contact, account/about rows, session; loading/error |
| C5 | `AddVehicleView` (3-step) | `add_vehicle_view.dart` | `/add-vehicle` | plate → vehicle → details, per-step validation, save + honesty note |
| C6 | `CustomerNotificationsView` (inbox) | `customer_notifications_view.dart` | `/notifications` | 4 groups, mark-all-read, row destinations; loading/empty/error |
| — | `CustomerHomeHeader` (greeting only) | `widgets/customer_home_header.dart` | home | bell removed to the shell (single chrome) |
| — | `CustomerHomeQuickActions` (4 tiles) | `widgets/customer_home_quick_actions.dart` | home | book/SOS/invoices/history, one emphasis |

Out of scope and untouched: booking wizard/detail/success (P17),
breakdown, service status, approvals, invoice, feedback (P18) files.

---

## 2. Before / after composition (per screen) — task → concept → composition

| Screen | Old got WRONG (one line) | New does DIFFERENTLY (one line) | Task → Concept → Composition | Viewport @390 EN |
| :-- | :--- | :--- | :--- | :--- |
| Shell | Rail frame on wide screens + hardcoded labels + duplicated bell. | Brand bar (bell + avatar + pill) with bottom nav on every width. | come home → consumer chrome → bar + tabs | chrome ≈112px |
| Home (C1) | Split-view summary/rows with hardcoded copy and no showcase. | Greeting → swipeable imagery carousel → journey → 4 large tiles → rows. | which car needs me → explore feed → hero + journey + tiles | carousel ≈45% |
| Bookings (C2) | Same rows, hardcoded headers. | Same honest rows under localized warm groups (composition kept, chrome lifted). | what happened → history feed → groups + rows | list ≈70% |
| Vehicles (C3) | Icon-tile rows, hardcoded actions. | Art-band listing rows with plate, VIN, specs and the same real actions. | manage my cars → listings → art rows + grid | rows ≈70% |
| Add (C5) | One long form with hardcoded sections. | Three gated steps (plate → vehicle → details) with the same rules. | register my car → stepped flow → stepper + step + dock | step ≈55% |
| Profile (C4) | Same honest content, hardcoded copy. | Same contracts in warm localized rows (kept composition). | who am I → account → identity + rows | identity ≈40% |
| Notifications (C6) | Flat list, hardcoded labels. | Four triage groups with the same destinations and read markers. | what changed → inbox → groups + rows | feed ≈75% |

No two screens share a template: feed, history, listings, stepped flow,
account, inbox — one warm language, six jobs. Nothing resembles the old
enterprise-density layouts; nothing reads as staff/owner chrome.

---

## 3. Include / remove / enhance (SaaS rework + addendum)

**Included (added, all real):** shared `AirbnbImageCard` (16:10 art slot,
badge, conditional heart, title/meta/footer) + `TrustPill`
(verified/top-rated, theme tones) with shared tests + goldens; ~120 warm
`gar*/bk*/vh*/av*/pf*/nt*/js*` keys with exact EN/AR parity; hero
carousel (silhouette art + real booking-derived context badges + dots,
grid on tablet+); 4-tile action grid (book/SOS/invoices/history over real
routes); journey kept with all live strings; stepped add-vehicle with
gated validation + save dock; grouped inbox (service/approvals/invoices/
general); VIN rows; per-tab loading (`AppSkeleton`), empty art, no-match,
error+retry, offline pill, failed-queue recovery; 320–1440 + 1.3x + 48dp +
semantics/focus/reduced-motion throughout.

**Removed:** rail frame on consumer widths (bottom nav always); home bell
(single chrome in the bar, exact a11y contract preserved); hardcoded EN
copy across owned files; hardcoded hex/status maps (→ semantic tones +
one pill contract each); bespoke search boxes (→ shared fields); the
snackbar bell behavior stays honest; dead intro-card draft (duplicated
CTA); `customer_home_garage_summary.dart` (showcase consolidated into the
carousel; zero references after); unused l10n keys.

**Enhanced:** airy 28/20/20 rhythm, 16px cards, single primary CTA per
screen, warm microcopy; tablet shows 2-up grids, desktop centered
max-width compositions (never a rail, never a table); RTL mirrors with
LTR-locked plates/VIN/money/phones; dark resolves every tone.

**Honest omissions / deferrals (no fake data — FAIL rule):** health pill
(endpoints carry no provenance — constant 100; enforced absent by tests);
favorite heart (no persistence contract — slot exists, renders nothing);
vehicle photography (no image fields — labeled silhouette art); promos
(no endpoint); insurance countdown + next-service nudges (`nextDue` is an
unmaintained placeholder; tests forbid both); per-advisor/amount/checklist
on booking rows (no fields — estimate line only where approval needs it,
enforced absent otherwise); payments/emergency profile rows (no data or
routes); notification preferences (no contract); photo upload step (no
storage contract); reply composer (no endpoint — note rendered, guarded);
approve/reject-style actions anywhere (no endpoints); persisted sync stamp
(connectivity pill only).

---

## 4. Reference conformance (house bar + addendum)

Studied before writing a widget: `advisor_home_view.dart` (spacing
rhythm, row grammar, skeleton-mirrors-geometry, toasts, haptics) and
`advisor_job_detail_view.dart` (dossier/stepper/dock grammar, applied to
the add-vehicle stepped flow). The addendum wins every consumer decision:
imagery-first cards, 16:10 bands, 28/20/20 air, one CTA, warm EN/AR copy,
TrustPill accents only, 280ms sheet motion via `AppMotion.resolve`,
 tabular money unchanged. Side-by-side vs the old UI: unrecognizable;
 vs staff/owner: same quality bar, different species. Recolored
 enterprise form nowhere.

---

## 5. Contracts proof (UI-only, zero logic changes)

Frozen and byte-identical: dashboard/bookings/approvals notifiers,
`customerSaveVehicle`/remove/sync/retry payloads and flows, validation
rules (plate/make/year/messages), VIN normalization, mileage honesty,
`PlateNumber` usage, approval/invoice surfacing rules, notification
read-markers and destinations, deep links + legacy `?tab=` semantics,
auth/session contracts, Hive boxes, DTOs. Allowed diffs only:
`customer/presentation/{customer_dashboard_view untouched,} shell, tabs,
record, add-vehicle, notifications` composition, `support/customer_l10n`
helper, `*.arb` strings, test/golden files — plus two justified shared
additions below.

Non-UI files touched (one-line justification each):

- `packages/shared_core/.../airbnb_image_card.dart` + `trust_pill.dart` +
  exports — addendum-mandated components absent from shared (with
  `airbnb_components_test.dart` + 3 goldens).
- `packages/shared_core/test/goldens/airbnb_*.png` (3, new) — component
  baselines.
- `customer l10n/app_{en,ar}.arb` + `gen/*` — new keys + regen only
  (three pre-existing auth values restored byte-identical after a
  transcription slip, §7).
- Customer tests — recomposed assertions only (bell relocation with the
  exact a11y contract preserved; stepped-form interactions; per-step
  eyebrows); zero weakened behavior pins.
- `reports/REPORT_PHASE_16.md`, `reports/PHASE_16/screens/*` (30),
  README ledger row 16.

---

## 6. Deltas made this session (all customer-side)

Shell rebuilt (consumer bar + always bottom nav); carousel created; home
recomposed around it; bookings/vehicles/record/profile/notifications
lifted to warm localized chrome with identical contracts; add-vehicle
restructured into 3 gated steps with identical rules/payloads; ~120 l10n
keys; `customer_l10n.dart` null-safe accessor (router precedent: tests
without delegates resolve EN instead of crashing); `customer_garage_test`
(8) + `customer_garage_visual_test` (30) created; owned goldens
re-rendered (home/bookings/vehicles/profile/notifications/form +
failed-sync rows); one file deleted.

---

## 7. Gates & evidence

**Gate 1 — Engineering:**

- `flutter analyze` (customer_app): **0 issues**. `flutter analyze`
  (shared_core): **0 issues**.
- Customer suite: **522 pass, 39 fail — all 39 are golden pixel tests in
  out-of-scope Phase 17/18 files** (book-service, booking-detail,
  breakdown, status-tab, approvals, booking-success). Zero functional
  failures anywhere: every contract suite (home, bookings, vehicles,
  profile, notifications, vehicle-form, navigation, smoke, logic,
  identity, failed-sync, moderation, push, cross-boundary, migration) is
  green, including the 8 new garage tests.
- `arb_parity_test` (customer): **green**. Shared
  `airbnb_components_test`: **8/8 green**.
- Manual guards: zero `AppColors.*`/`AppDarkColors`/raw widths/breakpoints
  in owned files (one justified height read in profile, pre-existing
  pattern); zero new app-local duplicates; bespoke bars/skeletons stay
  dead (07.1 scan green); no rail/breadcrumb/Cmd+K/palette/table in
  customer code (grep-verified); deprecation guard unaffected.

**Gate 2 — Visual (headless):**

- 30 NEW goldens, real fonts **including the Arabic face the old suites
  never loaded**, deterministic rerun green, reviewed native in-session:
  `reports/PHASE_16/screens/garage_{home,bookings,vehicles,profile,add,notifications}_{390_en,390_ar,834_en,1280_en,390_dark}.png`
  (test originals in `apps/customer_app/test/goldens/`).
- Matrix: 390 EN/AR + 834 EN + 1280 EN + 390 dark per surface; consumer
  compositions at every width (grids, never rails/tables); overflow
  audited 320→1440 at 1.0x/1.3x (three audit fixes: pager→grid beyond
  compact, 3-up grids, 384px cell floor).
- Pre-existing drift inherited: the 80 baseline golden failures were 100%
  environmental (fallback fonts); owned screens now carry fresh
  self-consistent baselines, out-of-scope ones are untouched.
- **Live device: NOT PERFORMED** (no device in this session).

**Failures, incidents & owners:**

| Item | State | Owner |
| :--- | :--- | :--- |
| Mid-session external commit `31ebfa1e` sweeping in-progress work + `test/failures/` debris | Recorded; debris removed from tree; true baseline `95b75c8b` used throughout | Reporter (local flow) |
| `loginAppName`/`appTitle`/`authSecurityNotice` AR transcription slip (singular vs baseline plural) | Fixed byte-identical; cross-boundary green | This phase (closed) |
| Phase 17/18 golden drift (39) | Pre-existing environmental; owned files untouched | Phases 17–18 |
| Health/favorite/photo/promo/insurance/payroll/reply endpoints | Deferred for missing contracts (§3) | Backend / follow-up |

---

## 8. Files changed (Phase 16 scope)

- Rewritten: `customer_scaffold.dart` (shell), `customer_home_tab.dart`,
  `customer_garage_carousel.dart` (new), `customer_home_header.dart`,
  `customer_home_quick_actions.dart`, `customer_bookings_tab.dart`,
  `customer_vehicles_tab.dart`, `customer_vehicle_record.dart`,
  `customer_profile_tab.dart`, `add_vehicle_view.dart`,
  `customer_notifications_view.dart`
- Recomposed internals (same contracts): `customer_home_service_summary.dart`
- Deleted: `customer_home_garage_summary.dart` (consolidated)
- Created: `support/customer_l10n.dart`
- Kept byte-identical: all providers/entities/datasources/router/sync,
  `customer_booking_item.dart`, `customer_failed_booking_item.dart`,
  status notices/surface/panels, `CustomerDestination`, out-of-scope views
- Shared (justified, §5): `airbnb_image_card.dart`, `trust_pill.dart`,
  exports, `airbnb_components_test.dart`, 3 goldens
- L10n: `app_en.arb`/`app_ar.arb` (+~120 keys), `gen/*` (regen)
- Tests: `test/features/customer/customer_garage_test.dart` (new),
  `test/customer_garage_visual_test.dart` (new),
  `test/goldens/garage_*.png` (30, new); recomposed assertions in
  home/notifications/vehicle-form suites; owned goldens re-rendered
- Docs: `reports/REPORT_PHASE_16.md`, `reports/PHASE_16/screens/*` (30),
  README ledger row 16

Staff touches: **none**. Owner touches: **none**. Runner artifacts
committed: **none** (`test/failures/` debris removed everywhere
touched; goldens are the evidence).
