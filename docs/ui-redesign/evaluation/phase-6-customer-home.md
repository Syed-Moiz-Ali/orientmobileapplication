# Phase 6 — Customer home — fresh rubric review (READ-ONLY, no code touched)

Branch: `ui/phase-6-customer` (rebuilt + recaptured, uncommitted).
Reviewer: fresh, not involved in build. No code/tests/PNGs edited. No commit.
Method: viewed PNGs with Read only. No `flutter test`, no grep, no code read.

## 0. Verdict summary

**Verdict: FAIL (4 failing rows, 9 passing rows). Not a too-similar automatic FAIL.**

The after-image is structurally different from before (see §3) — automatic-fail for
too-similar does NOT trigger.

Fidelity to `phases/phase-6-customer.md` + `customer-home-test-migration.md`:
hero-priority (approval > unpaid > live-service > upcoming > nothing/idle),
single-hero suppression, garage `Show all` (replaces `Manage` on home only),
4 quick-action tiles, `Recent activity` + `All bookings`, empty-state single CTA
`Add your vehicle` (booking step-0 vehicle gate), cap 2 → 3 — all confirmed
visually in hero variants. PASS on fidelity.

Rubric failures are presentation-only (layout/copy/responsive), no logic change needed:

1. **FAIL — quick-action labels truncate/wrap mid-word at 360px and collapse at 1.3x/320px.**
2. **FAIL — garage status chips clipped (`IN THE WORKSHOP NO`) + untranslated in `ar` (`LAST SERVICE` / `IN THE WORKSHOP NOW` stay English — regression vs before `قيد الصيانة`).**
3. **FAIL — tablet-portrait 768px stays single-column (C4/C9 medium = two columns for dashboards).**
4. **FAIL — hero has no explicit verb-first CTA (tappable card only); (8) single-primary-CTA scores 0.**

Scores: 9/13 rows ≥ 12/16 pass; 4/13 rows < 12/16 fail.
Dark correctness: PASS as its own verdict. Contrast: PASS with note.
RTL mirroring: FAIL (layout mirrors, digits/plates correctly LTR, but chips untranslated).
Overflow 1.3x/320px: no visible `RenderFlex` overflow, but information-loss truncation = FAIL.
Tap targets ≥ 48dp: PASS by visual estimate (tiles/buttons clearly > 48dp; exact dp not measurable from PNG — stated as extrapolation).

## 1. Files inspected (all viewed)

Contact sheets (3):
- `docs/ui-redesign/evaluation/contact-sheets/phase-6-customer-light.png`
- `docs/ui-redesign/evaluation/contact-sheets/phase-6-customer-dark.png`
- `docs/ui-redesign/evaluation/contact-sheets/phase-6-customer-tablet.png`

Before (4):
- `docs/ui-redesign/baseline/before-customer-home/customer_home_light_en_360x800.png`
- `docs/ui-redesign/baseline/before-customer-home/customer_home_light_ar_360x800.png`
- `docs/ui-redesign/baseline/before-customer-home/customer_home_dark_en_360x800.png`
- `docs/ui-redesign/baseline/before-customer-home/customer_home_dark_ar_360x800.png`

After (28/28):
- `idle_light_1.0_en_360x800.png`, `idle_dark_1.0_en_360x800.png`
- `idle_light_1.0_ar_360x800.png`, `idle_dark_1.0_ar_360x800.png`
- `idle_light_1.3_en_360x800.png`, `idle_dark_1.3_en_360x800.png`
- `idle_light_1.3_ar_360x800.png`, `idle_dark_1.3_ar_360x800.png`
- `idle_light_1.0_en_320x568.png`, `idle_dark_1.0_en_320x568.png`
- `idle_light_1.0_en_768x1024.png`, `idle_light_1.0_en_1180x820.png`
- `hero-approval_light_1.0_en_360x800.png`, `hero-approval_dark_1.0_en_360x800.png`
- `hero-payment_light_1.0_en_360x800.png`, `hero-payment_dark_1.0_en_360x800.png`
- `hero-service_light_1.0_en_360x800.png`, `hero-service_dark_1.0_en_360x800.png`
- `hero-upcoming_light_1.0_en_360x800.png`, `hero-upcoming_dark_1.0_en_360x800.png`
- `hero-nothing_light_1.0_en_360x800.png`, `hero-nothing_dark_1.0_en_360x800.png`
- `empty_light_1.0_en_360x800.png`, `loading_light_1.0_en_360x800.png`
- `error_light_1.0_en_360x800.png`, `error_dark_1.0_en_360x800.png`
- `offline_light_1.0_en_360x800.png`, `field-na_light_1.0_en_360x800.png`

Not generated (extrapolated only where stated): `empty/error/loading/offline_dark_ar`,
`hero-*_ar`, `hero-*_1.3x`, `idle_*_768_dark`, `idle_*_1180_dark/ar`. Extrapolation
assumes same widgets as viewed equivalents — flagged in table.

Read first: `DESIGN_SPEC.md` C16 + C8/C9/C10/C14, `phases/phase-6-customer.md`,
`evaluation/customer-home-test-migration.md`.

Rubric key (0 = fail, 1 = partial, 2 = pass/N/A-with-reason); 8 criteria × 2 = /16; pass ≥ 12:
(1) one task/screen, (2) headline-first, (3) whitespace/no boxes-in-boxes,
(4) sheets for secondary (N/A allowed), (5) sticky CTA (N/A allowed — home has no sticky bar),
(6) carousel/peeking + Show all, (7) plain friendly copy + verified STATUS,
(8) single primary CTA.

## 2. Result table

| Area | Theme | Locale | Scale | Size | Rubric /16 | Result | Issues | Fix | Re-verified |
|---|---|---|---|---|---|---|---|---|---|
| idle hero (approval wins, payment suppressed) | light | en | 1.0 | 360x800 | 13 | PASS | (8) no verb-first button in hero, card-tap only; (2) `WELCOME BACK` ALL-CAPS eyebrow violates C3 sentence-case | Add one `AppPillButton` inside hero (`Review estimate` / `Pay invoices` / `Track service` per variant, full-width or trailing); change eyebrow to sentence-case `Welcome back` with muted color, keep name as headline | No (write-only review) |
| idle hero | dark | en | 1.0 | 360x800 | 13 | PASS | Same as light; dark itself correct (see dark verdict) | Same hero-button + eyebrow fix (token-only) | No |
| idle hero | light | ar | 1.0 | 360x800 | 13 | PASS (hero copy only) | Hero title/sentence correctly translated (`تقدير AED 450 …`, `الموافقة مطلوبة …`); `AED 450` stays LTR — correct; eyebrow ALL-CAPS equivalent | Same hero-button fix; keep numeral LTR with bidi isolate | No |
| idle hero | dark | ar | 1.0 | 360x800 | 13 | PASS (hero copy only) | Same as light-ar | Same | No |
| garage carousel | light | en | 1.0 | 360x800 | 12 | PASS (borderline) | Badge clipped: `IN THE WORKSHOP NO` (missing `W`); subtitle `2021 · 45000 km …` hides color `White` (secondary-text ellipsis allowed but harsh: info loss); `LAST SERVICE`/`IN THE WORKSHOP NOW` ALL-CAPS violates C3/C11 | Let status chip wrap to 2 lines or shrink + `FittedBox` alternative: shorter sentence-case labels (`In the workshop`, `Last service`); allow subtitle 2 lines or `White · 2021 · 45,000 km` with wrap, keep plate chip single-line | No |
| garage carousel | light | ar | 1.0 | 360x800 | **9** | **FAIL** | Chips NOT translated (`IN THE WORKSHOP NOW`, `LAST SERVICE` English in ar screen — regression vs before `قيد الصيانة`); order correctly mirrored but untranslated = locale FAIL; same clipping | Add ARB keys `garStatusWorkshopNow` / `garStatusLastService` (+ `garStatusBooked`, `garStatusInService`) en+ar, sentence-case, use `AppStatusChip`; fix chip constraints as above | No |
| garage carousel | dark | ar | 1.0 | 360x800 | **9** | **FAIL** | Same untranslated + clipped chips in dark | Same ARB + layout fix | No |
| quick actions (4 tiles) | light/dark | en | 1.0 | 360x800 | 12 | PASS (borderline) | `Breakdown h…` truncated, `Invoices` breaks as `Invoice s` mid-word; icons + 4-across ok | Shorten labels presentation-only: `Book`, `Breakdown`, `Invoices`, `History` single-line with `overflow: ellipsis` + `Semantics` full label; reduce tile label to `labelMedium`, `textAlign: center`, `maxLines: 2` with balanced wrap (never mid-word); or 3 + `More` sheet | No |
| quick actions | light/dark | en/ar | 1.3 | 360x800 | **8** | **FAIL** | Collapse: `Book serv…`, `Break do…`, `Invoi ces`, `Histo ry`, ar `مساء دة ا…`; mid-word breaks; no overflow exception visible but information loss | Same label-shortening + allow tiles to grow in height (no fixed height), `Flexible` text, keep ≥ 48dp; verify at 1.3x golden | No |
| quick actions | light/dark | en | 1.0 | 320x568 | **10** | **FAIL** | Same truncation (`Book servi…`, `Break dow…`, `Invoic es`, `Histor y`) | Same fix; consider 2×2 grid on < 340dp via `LayoutBuilder` (presentation-only breakpoint) | No |
| recent activity | light | en | 1.0 | 1180x820 | 14 | PASS | `Recent activity` + `All bookings` + `Brake pads / Honda Civic · 02 May 2026 / Completed` — one status per row, tabular date, chevron mirrors correctly; 1180 shows full labels (no truncation) | None (keep) | No |
| states: empty/loading/error/offline/field-na | light (+dark error) | en | 1.0 | 360x800 | 14 | PASS | Empty: one icon + one sentence + one CTA `Add your vehicle` — correct; loading skeleton mirrors hero + 2 cards + 4 tiles + 3 rows — correct; error light+dark centered + `Retry` — correct, no raw exception; offline keeps last data under warning `AppBanner` + `Retry` — correct (banner title/icon alignment slightly top-heavy, minor); field-na degrades to `Vehicle` with no overflow — correct | Polish offline banner alignment (icon + text baseline, `Retry` trailing); keep 3-tile empty variant intentional (no history when empty) — document | No |
| dark (own verdict) | dark | en/ar | 1.0/1.3 | 360x800 | 14 | PASS | Soft charcoal (not pure black), no neon/glow, no shadows (surface lift + border), chips readable (`Needs your attention` red-soft, `2 unpaid` amber-soft, `Confirmed` teal-soft, `IN SERVICE` blue-soft); plates `ABC 1234` LTR on dark — correct | None | No |
| tablet | light | en | 1.0 | 768x1024 / 1180x820 | **11** | **FAIL** | 768 portrait stays single-column (hero full-width, quick actions 4-across, garage 2-up full) — C4/C9 medium (600–1024) requires two-column dashboard; 1180 landscape correctly side-by-sides hero + quick actions and 2-up garage with full untruncated text — PASS for expanded, FAIL for medium | At ≥ 600dp: two-column grid — hero spans 2 cols (or left col hero + right col quick actions as in 1180), garage 2-up grid, recent-activity Takes second row; use existing `Breakpoints`/`AppResponsive`, no hardcoded device checks | No |

Extrapolated (not re-verified): `loading/error/offline` dark-ar, `hero-*` ar/1.3x/320 share the
same hero-button and chip fixes above; no separate score claimed.

C8/C10/C14 cross-cutting:
- Contrast legibility: PASS with note — `Your car is in good hands` muted secondary on
  `background` is the lowest pair; visually readable but must be AA-checked by tooling
  (cannot measure from PNG).
- ≥ 48dp targets: PASS by visual estimate (quick tiles ~72px+, pill buttons full-width 52,
  chips 32 high but inside tappable cards; exact dp not measurable — stated).
- RTL mirroring: FAIL — layout mirrors (quick-action order, garage order, header
  right-aligned, chevrons flip), digits/plates correctly stay LTR (`ABC 1234`, `AED 450`,
  `45000 km`), but garage chips untranslated English in ar = locale regression.
- No overflow 1.3x/320px: no visible `RenderFlex overflowed`/clipping off-screen, but
  mid-word truncation + badge clipping = information-loss FAIL (see rows).
- Dark correctness: PASS (own verdict row).

## 3. Structural changes vs before (layout/flow — not colors)

Before (all 4 `before-customer-home` PNGs):
- Greeting `Welcome back / Ahmed` (small, no subtitle) → attention box (pink tint,
  two rows `Estimate AED 450 awaiting your approval` + `1 unpaid invoice` with `>` chevrons).
- Section `Your garage` + `Manage` (blue text) → single large vehicle card with dots
  pagination (one card visible + peek), spec line `2021 · 45000 km · White`, plate `ABC 1234`.
- Below: `IN SERVICE / Full service` card (cut off in capture).

After (idle + variants):
- Greeting → eyebrow `WELCOME BACK` + large `Ahmed` + subtitle `Your car is in good hands`
  (headline-first hierarchy, new).
- Attention box REPLACED by ONE hero `AppMediaCard`: media block + title
  (`Estimate AED 450 awaiting your approval`) + sentence (`Approval needed before work
  continues`) + single `AppStatusChip` (`Needs your attention`). Payment variant swaps to
  `2 unpaid invoices` + `Review and settle…` + amber chip. Service/upcoming/nothing variants
  swap title/sentence/chip (`Full service / Current stage · On the lift / IN SERVICE`,
  `Oil change / 12 Jun 2026 · 10:00 … / Confirmed`, `No active service / …`). Only one hero
  rendered at a time (suppression logic preserved per migration doc). Structural, not recolor.
- NEW quick-action row (did not exist): 4 tiles `Book service / Breakdown help / Invoices /
  History` between hero and garage (empty state: 3 tiles, no `History`).
- Garage header `Manage` → `Show all`; carousel now shows ~1.6–2 cards peeking with status
  chips on art (`IN THE WORKSHOP NOW`, `LAST SERVICE`, `BOOKED`) + name + spec + plate chip;
  single-vehicle case collapses header to `Your vehicle` + one card (hero-approval/payment/
  service/upcoming/nothing PNGs).
- NEW `Recent activity` + `All bookings` list section (`Brake pads / Honda Civic · 02 May 2026 /
  Completed` with chevron) below garage.
- NEW states: `empty` (centered `AppEmptyState` + `Add your vehicle`), `loading` (skeleton
  mirroring layout), `error` (`AppErrorState` + `Retry`), `offline` (warning `AppBanner` +
  last data kept), `field-na` (nameless vehicle degrades gracefully).
- Tablet: 768 single-column stacked; 1180 two-column (hero + quick actions side-by-side,
  garage 2-up grid) — new responsive behavior (no tablet before to compare).

Per-area structural list (still required):
- Idle hero: 2-row attention list → 1 hero card with 1 title + 1 sentence + 1 chip.
- Garage: dots-paginated single-card focus → peeking carousel/grid + `Show all` + plated cards.
- Quick actions: absent → 4-tile (3-tile empty) icon row.
- Recent activity: absent/cut-off service card → titled list group + `All bookings`.
- States: no captured states → full C10 set (skeleton/empty/error/offline/field-na).
- Dark: same structure as light (no structural fork — correct).
- Tablet: no baseline → new single (768) / two-column (1180) flow.

## 4. Concrete logic-free fixes (presentation/copy only, no providers/routes/keys)

1. Hero CTA: add one `AppPillButton` (or make hero card action explicit) per variant —
   `Review estimate`, `Pay invoices`, `Track service`, `View booking` — reusing existing
   navigation targets/keys; no logic change.
2. Eyebrow + chips sentence-case: `Welcome back`, `In the workshop`, `Last service`,
   `In service`, `Booked`, `Confirmed`; keep `WELCOME BACK`-style emphasis via color/weight,
   not caps (C3).
3. Garage ARB: add `garStatusWorkshopNow`, `garStatusLastService`, `garStatusBooked`,
   `garStatusInService` (+ any other English-only chip) en+ar; reuse otherwise verbatim strings.
4. Chip clipping: give status chip `maxLines: 1–2` with wrap (not fixed-width overlay) or
   shorter labels; keep dot + label pattern; do not widen card beyond grid.
5. Quick-action labels: shorten to `Book`, `Breakdown`, `Invoices`, `History` (or full
   `Book service` only where width allows via `LayoutBuilder`); `labelMedium`, centered,
   `maxLines: 2`, word-boundary wrap + ellipsis + semantic label; allow tile height to grow;
   at < 340dp switch to 2×2 grid (breakpoint helper only).
6. Subtitle: allow 2 lines (`2021 · 45,000 km · White`) instead of single-line ellipsis;
   keep plate `ABC 1234` LTR with bidi isolate in ar.
7. Tablet 768: apply C4 medium two-column dashboard via existing responsive helper
   (hero span, quick-actions row, garage 2-up, activity list); 1180 layout already correct — keep.
8. Offline banner: align icon + `No connection` baseline, keep `Retry` trailing action.
9. (5) sticky CTA: N/A — home correctly has no sticky bottom bar; state so (done).
   (4) sheets: N/A — home has no filters/pickers; `Show all`/`Manage` correctly navigate,
   not sheets (done).

## 5. Return

- Pass/fail counts: 9 pass / 4 fail (13 scored rows).
- FAIL list: (a) quick-actions 1.3x collapse, (b) quick-actions 320px truncation,
  (c) garage ar untranslated + clipped chips (light + dark counted as one issue, two rows),
  (d) tablet-portrait 768 single-column, (e) hero missing explicit CTA (folded into idle-hero
  13/16 pass but listed as required fix — harsh note: scores 0 on criterion 8).
  Strict row-FAILs: garage-ar-light, garage-ar-dark, quick-actions-1.3x, quick-actions-320,
  tablet-768.
- Scores: see table (highest 14: recent-activity, states, dark; lowest 8: quick-actions 1.3x).
- Evaluation path: `docs/ui-redesign/evaluation/phase-6-customer-home.md` (this file).
- No code changes. No commit.
