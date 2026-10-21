# Phase 7 — Owner Home / Executive Cockpit — Fresh Re-Review ROUND 2 (post-fix, PASS 16/16)

**Role:** FRESH RE-REVIEWER (round 2), not builder/fixer. READ-ONLY except this file. No code/tests/PNGs edited. No branch/commit/push.
**Branch:** `ui/dashboards-2`.
**Read first:** Brief `docs/ui-redesign/briefs/phase-7-owner-home.md` (authoritative); prior FAIL `phase-7-owner-home-evaluation.md` round 1 (8/16, 3 gating owner-file issues); REDESIGN MANDATE + C16 (caps 10/16) + U0–U14 C17 (caps 8/16). Pass ≥ 12/16 with caps. Frequent tasks single-screen; taps: glance 0, drill 1, triage 1+scroll.
**Fixer claims re-checked:** (1) search same-row end-side all breakpoints (no AppPageHeader stacking); (2) 2-col pods @360, hero+pod-row+banner above fold; (3) register-empty copy `ownerRegisterEmptyHint`.
**Images viewed (12/12 via Read, full resolution, no sampling):**
- AFTER (9): `docs/ui-redesign/baseline/after-owner-home/` — `home_1.0_en_360x800`, `home_1.0_ar_360x800`, `home_empty_en_360x800`, `home_error_en_360x800`, `home_search_open_en_360x800`, `home_1.3_en_360x800`, `home_1.0_en_320x568`, `home_1.0_en_768x1024`, `home_1.0_en_1280x800`.
- Contact sheets (3): `docs/ui-redesign/baseline/phase-7-owner-light.png` (BEFORE en 360 vs AFTER en 360), `phase-7-owner-ar.png` (BEFORE ar 360 vs AFTER ar 360), `phase-7-owner-tablet.png` (BEFORE 360 + AFTER 768 + AFTER 1280).
- Code read-only (attribution only): `apps/owner_app/lib/features/dashboard/presentation/widgets/owner_dashboard_page.dart` (`_HomeHeader` ~199–283, `_MicroPods` ~340–392, `_ApprovalsBlocker`, `_JobRegister` ~584–678), `dashboard_body.dart`, `owner_search.dart`, `l10n/app_en.arb` + `app_ar.arb`.

---

## 1. DESCRIBE — region by region, WITHOUT judging

### Reference frame: AFTER idle light 360 — `after-owner-home/home_1.0_en_360x800.png`

- **Shell app-bar region (top, shared):** left-to-right: rounded search glyph box, green `Synced` pill with cloud-check, light-blue `This week` pill with calendar + chevron, bell, pale-blue circle avatar `O`. Thin divider below.
- **Owner header region:** bold headline `Executive Operations Control` left; magnifier glyph at top-right on the SAME row as the headline (end-side); muted two-line subtitle `Real-time overview of branch performance, revenue, and active repair pipelines.` below the headline; three pills below: light-blue `● Live operations`, pale-teal `● 12 active` on one row, pale-green `● 5 today` on next row.
- **Hero region:** one white rounded card full-width: left small pale-teal square with briefcase glyph, grey overline `REVENUE`, large bold `AED 84K`, green `↑ +2.1% Ahead` on the same row to the right of the figure.
- **Micro-pod region:** two white rounded cards side-by-side in one row: left `MARGIN` (grey overline, pale-green `⊕` badge top-right, large `18.4%`, green `↑ +1.2% vs last we…` with trailing ellipsis), right `BAY OCCU…` (grey overline truncated, pale-red `⊗` badge top-right, large `12/16`, green `↑ 4 bays free`). Below: one white card left-column `PENDING A…` (grey overline truncated, document badge, large `3`, green `↑ 2 need decisions`).
- **Blocker banner region (bottom of crop, above nav):** yellow rounded notice peeking: brown text `3 waiting for owner review` on one line, warning triangle glyph below-left, blue `View all` centered below.
- **Nav region:** bottom bar four items: filled light-blue `Dashboard` (selected), `Top sales`, `Messages`, `Activity`.

### BEFORE vs AFTER en 360 — `phase-7-owner-light.png`

- BEFORE en 360: same shell row; same headline + subtitle; below subtitle a small pale-grey square with blue bar-chart glyph, then single pill `● Live operations` only; hero card with blue briefcase glyph + blue `REVENUE` overline, large `AED 84K`, green badge `↑ +2.1% Ahead` BELOW the figure; margin card blue `⊕` + blue `MARGIN`, `18.4%`, green badge below; tall single-column squares with large empty space.
- AFTER en 360: ADDED `12 active` + `5 today` pills; search glyph moved from lone row below subtitle to top-right same-row as headline; hero/pod internals restyled to horizontal figure+delta with grey overlines and corner badges; pods now 2-col (`MARGIN` + `BAY OCCU…` side-by-side); no figure changed (`AED 84K`, `18.4%`, `12/16`, `3`, deltas verbatim).

### Arabic — `after-owner-home/home_1.0_ar_360x800.png` + `phase-7-owner-ar.png`

- Shell mirrored (right-to-left: `O`, bell, `هذا الأسبوع`, `متزامن`, search). Headline right-aligned `التحكم التنفيذي في العمليات`, subtitle right-aligned. Magnifier at top-LEFT on the same row as the headline (end-side in RTL, mirrored vs en). Pills row right-aligned: `عمليات مباشرة`, `12 نشطةة`, `5 اليوم`.
- Hero `REVENUE` + `AED 84K` + `↑ +2.1% Ahead` same-row. Pods mirrored order: right `BAY OCCUP…` + `12/16` + `4 bays free`, left `MARGIN` + `18.4%` + `+1.2% vs last …`; `PENDING A…` + `3` + `2 need decisions` second row. Figures/deltas/codes stay LTR (`AED 84K`, `18.4%`). Yellow banner fully in-crop: `بانتظار مراجعة المالك 3` + `عرض الكل` centered + warning triangle. Bottom nav mirrored (`النشاط`, `الرسائل`, `الأعلى مبيعًا`, `اللوحة` right-to-left, `اللوحة` selected).

### 1.3x — `after-owner-home/home_1.3_en_360x800.png`

- Shell row shows yellow-black striped overflow marker at the right edge covering the avatar. Header `Executive Operations Control` wraps to two lines, search magnifier top-right same-row, subtitle, pills (`Live operations`, `12 active`, `5 today` wrapped). Hero `REVENUE AED 84K +2.1% Ahead` same-row. Two pods side-by-side (`MARGIN 18.4% +1.2% vs las…`, `BAY OC… 12/16 4 bays free`), third pod (`PENDIN… 3`) partially at capture bottom. Bottom nav first label truncated `Dashboa…` with ellipsis.

### 320px — `after-owner-home/home_1.0_en_320x568.png`

- Shell row striped overflow marker at right edge (avatar covered). Header headline wraps two lines, search magnifier top-right same-row, subtitle, pills (`Live operations`, `12 active`, `5 today` wrapped). Hero full-width `REVENUE AED 84K +2.1% Ahead`. One pod full-width in-crop (`MARGIN 18.4% +1.2% vs last week` fully legible, no ellipsis at this width — single-column stacking). Bottom nav full `Dashboard` label (no ellipsis at 1.0x).

### Tablets — `after-owner-home/home_1.0_en_768x1024.png` / `home_1.0_en_1280x800.png` (+ `phase-7-owner-tablet.png`)

- 768 medium: shell becomes left rail + top bar (`Owner dashboard / Head Office`, `Search CtrlK`, `Synced`, `This week`, bell, avatar). Owner header row `Executive Operations Control` + subtitle left, small magnifier top-right same-row. Pills single row. Hero full-width. Three pods in one row (`MARGIN 18.4%`, `BAY OCCUPANCY 12/16`, `PENDING APPROV… 3` — third overline truncated with ellipsis at this width). Yellow banner below pods (text line, icon line, `View all` centered). Two chart cards side-by-side (`Sales & profit` with `● Sales ● Profit` legend, Jan→Mar curves; `Profit & expenses` with `● Profit ● Expenses`). `Job register / View all` header + `Category / Open / Total` table header at capture bottom.
- 1280 expanded: same pattern wider. Header search still top-right. Hero full-width. Three pods wider (third overline now full `PENDING APPROVALS`, no ellipsis). Same yellow banner stacking. `Quick actions` title peeks at bottom.

### Empty — `after-owner-home/home_empty_en_360x800.png`

- Shell same. Header + top-right search + single `Live operations` pill. Centered empty block: pale-blue circle with cash glyph, title `No figures yet.`, sentence `Pull to refresh when you are back online.` Below: `Sales & profit` card with `● Sales ● Profit` legend + chart placeholder (bar glyph, `No data yet`, `No trend data yet.`). `Profit & expenses` header peeks. No register section in this crop (register empty copy verified from code, §2 U6).

### Search sheet — `after-owner-home/home_search_open_en_360x800.png`

- Dimmed home behind (header/pills/hero greyed). Full-width bottom sheet with drag handle, rounded input `Search destinations…` with left magnifier and focused caret, list rows with blue icons: `Dashboard / Owner dashboard`, `Top sales / Performance breakdown by category`, `Messages / Internal messaging`, `Activity / Workshop activity feed`. No inline field in content, no `×` close in this crop (handle + swipe affordance).

### Error — `after-owner-home/home_error_en_360x800.png`

- Shell same. Top: pale-red circle `!`, title `Could not load the latest figures`, sentence `Dashboard data could not be loaded. Pull to retry.`, full-width filled blue `Retry` button. Below: owner header + top-right search + `Live operations` pill + `No figures yet.` empty block + `Sales & profit` placeholder header. Error sits above content (content kept mounted below).

---

## 2. U0–U14 walk (each with image + region evidence; shared/shell = non-gating per governance)

| Law | Evidence (image + region) | Pass / Fail + attribution |
|---|---|---|
| U0 — fewer steps, never hunt/tap more than necessary | `home_1.0_en_360x800.png` hero + pills regions: revenue figure + delta + `Live/12 active/5 today` visible at launch, zero scroll; `home_search_open` focuses input and lists real destinations with zero typing | PASS |
| U1 — search ICON top-right → full-screen search, never inline | **Re-check @360:** `home_1.0_en_360x800.png` header region — magnifier at top-right SAME row as headline (end-side), no lone row below subtitle; `phase-7-owner-light.png` AFTER confirms same. **@320:** `home_1.0_en_320x568.png` header — magnifier top-right same-row despite wrapping headline. **@1.3x:** `home_1.3_en_360x800.png` header — magnifier top-right same-row. **@ar:** `home_1.0_ar_360x800.png` header — magnifier top-LEFT same-row as right-aligned headline (correct RTL end-side mirror; `phase-7-owner-ar.png` confirms). **Tablets:** 768/1280 headers — same-row end-side. Sheet half (`home_search_open`): full sheet + handle + autofocused field, no inline field, result = same palette contract per `owner_search.dart` (no new routes). Code: `_HomeHeader` (`owner_dashboard_page.dart:199–258`) now plain `Row` (Expanded title + `AppIconButton(search)`) with comment noting AppPageHeader compact stacking avoided; Row mirrors in RTL. Prior lone-row + phone/tablet split GONE. | **PASS — owner-file fixed** |
| U2 — first actionable item above the fold at 360x800 idle | **Re-check @360:** `home_1.0_en_360x800.png` — hero full + pod ROW (`MARGIN` + `BAY OCCU…` side-by-side, 2-col) + `PENDING A…` + yellow banner top (`3 waiting for owner review` / `View all`) peeking just above nav. Brief cap (hero + first pod row + banner when blockers exist) met; `phase-7-owner-light.png` AFTER confirms vs BEFORE single-column. ar 360 even shows banner fully. Code: `_MicroPods` (`owner_dashboard_page.dart:346–370`) compact `columns: pods.length==1?1:2`, `minChildWidth 142`, scale-aware `compactAspect (isSmallMobile 2.15 : 1.1)/textScale` — short 2-col tiles, single-column only below 360px (`isSmallMobile`), matching `home_1.0_en_320x568.png` single-col `MARGIN`. | **PASS — owner-file fixed** |
| U3 — tap counts (brief BEFORE vs AFTER; details in §3) | Migration-doc pins verified from code: glance 0→0, register row 1→1, approvals tile 1+scroll → 1+scroll, palette search 2→2; `owner_search.dart` destinations unchanged, `_JobRegister` row/`View all` → `AppRoutes.jobCards`, `_ApprovalsBlocker` → `pendingApprovals` | PASS |
| U4 — frequent action reachable without scrolling, lower half or sticky | `home_1.0_en_360x800.png`: glance (hero + pills) at launch 0 scroll; drill/triage below fold need scroll — same as BEFORE compact (brief allows scroll past stacked curves) | PASS |
| U5 — no truncation of primary text; rows fit or scroll with clean peek | `home_1.3_en_360x800.png` nav region: `Dashboa…` ellipsis truncates primary nav label at 1.3x. Pod regions: `BAY OCCU…` / `PENDING A…` (360), `BAY OC…` / `PENDIN…` (1.3x), `PENDING APPROV…` (768 medium) truncate overlines with ellipsis; full `PENDING APPROVALS` only at 1280. BEFORE frames show identical `Dashboa…`. Attribution: nav ellipsis = shell `AppBottomNavigation` (shared); pod overline ellipsis = shared `AppKpiCard` + narrow 2-col column (shared grammar). Values/deltas (`AED 84K`, `18.4%`, `12/16`, `3`) never truncated. | **FAIL surface — shell/shared, non-gating** (noted for owning phase; does not gate this owner-file verdict) |
| U6 — calm empty: no filled CTA to nothing | `home_empty_en_360x800.png`: `No figures yet.` + hint, no CTA; `home_error_en_360x800.png`: single filled `Retry` to real `refresh`. No approve/reject anywhere. **Register-empty copy re-check:** `_JobRegister` compact empty now `title: t.ownerRegisterEmpty` (`No register rows.`) + `message: t.ownerRegisterEmptyHint` (`New jobs will appear here when they are booked.`) (`owner_dashboard_page.dart:624–625`), expanded `emptyMessage: t.ownerRegisterEmpty` (:678); `app_en.arb:103–106` + `app_ar.arb:50–51` (`لا صفوف في السجل.` / `ستظهر المهام الجديدة هنا عند حجزها.`). Prior `ownerHeroEmptyHint`-for-register bug GONE (hero empty still correctly `ownerHeroEmpty/Hint` at :302–303). Register section not in empty 360 crop, so code is the evidence. | **PASS — owner-file fixed** |
| U7 — one path per task; See-all only when more exists than shown | 1280 + code: `_QuickActions` top-4 tiles + `Show-all` preview expanding inline to remaining 8; `_JobRegister` compact caps at 5 rows + `Show-all` only when `hasMore`, `View all` trailing (`ownerRegisterAll` → same `jobCards` route). No duplicate filled CTAs. Search palette single contract shared by shell + header | PASS |
| U8 — relevance: completed/history never under Assigned/To-do | N/A here by construction — say so: this surface has NO Assigned/To-do list (executive cockpit: hero + pods + banner + curves + register + actions). Approvals stay read-only triage (no decision buttons), banner drills to triage only. Statuses honest per `_findKpi` verbatim | PASS (N/A, stated) |
| U9 — consistency: same element, same place across screens/apps | Header/pills/hero/pod order identical en/ar and 360/tablet; search now consistently same-row end-side on EVERY breakpoint (phone/tablet split from round 1 gone) | PASS |
| U10 — feedback/forgiveness; errors say what to do next | `home_error_en_360x800.png` (what + next: `Could not load the latest figures` / `Dashboard data could not be loaded. Pull to retry.` + `Retry`); `home_empty` offers `Pull to refresh`; banner + pills keep stale data visible; destructive-confirm stays dialog per brief. Haptic timing not provable from stills | PASS (stills-limited) |
| U11 — readable numbers: zero is 0, stats labelled/visible/decision-helping | `home_1.0_en_360x800.png` + ar + tablets: `AED 84K` + `+2.1% Ahead`, `18.4%` + `+1.2% vs last week`, `12/16`, `3` all verbatim with LTR lock (`Directionality(ltr)` in `_RevenueHero`/`_MicroPods`); `pending<=0` hides banner, unparseable stays visible; zero shown as `0` per code, never `–` | PASS |
| U12 — one background colour, no stray bands | All 9 after frames: single page background; hero/pod/chart whites are cards, not bands; yellow banner is an allowed warning notice; offline pill owns connectivity (no duplicated full-width banner) | PASS |
| U13 — new-employee test: plain words in 3 seconds | `Executive Operations Control`, `Real-time overview…`, `Live operations`, `REVENUE AED 84K`, `Sales & profit`, `Job register`, `View all`, `Search destinations…`, `No figures yet. Pull to refresh…` Sentence-case, verb-first `View all`. Residual Latin deltas kept verbatim per verbatim-value rule | PASS |
| U14 — a11y: ≥48dp targets, AA, Semantics, 1.3x + 320px without clipping | `home_1.3_en_360x800.png` + `home_1.0_en_320x568.png` shell regions: yellow-black striped RenderFlex-overflow markers persist at the app-bar right edge (avatar covered) — the documented 17px@1.3x / 29px@320 overflows from BEFORE are NOT fixed AFTER. Owner cards themselves wrap without clipping (2-col at 1.3x with wrapped pills/headline, single-column at 320 with full `+1.2% vs last week` legible, legend wraps). Attribution: app-bar overflow = shell `WorkspaceAppBar` (shared), bottom-nav ellipsis at 1.3x = shell `AppBottomNavigation` (shared). | **FAIL surface — shell/shared, non-gating** (same BEFORE quirk, tolerated by capture harness; owning shell phase must fix) |

**U-walk fails: 2 surface — both shell/shared non-gating (U5 nav/pod ellipsis, U14 app-bar overflow persisting). Zero owner-file fails.** Capture-agent flags reassessed: (1) shell avatar overflow persists (stripes, shared); (2) single-column squares GONE — now 2-col @360 (fixed); (3) search bottom-left + phone/tablet split GONE — now same-row end-side everywhere including ar mirror + 320 + 1.3x (fixed); (4) nav ellipsis + banner icon stacking on expanded persist (shared `AppBottomNavigation` / `AppBanner` responsive, non-gating); empty-register copy FIXED to `ownerRegisterEmpty/Hint` (code :624–625, :678).

---

## 3. Top-3 tap walk BEFORE→AFTER + Show-all / search-U1 check

BEFORE counts (verbatim from brief §Top-3, verified from code per migration doc): (1) glance hero + pods = **0 taps** (above fold at launch); (2) register row (or section View-all) → `AppRoutes.jobCards` = **1 tap** (+scroll compact past swipeable charts); (3) approvals tile → `pendingApprovals` = **1 tap + scroll** to 12-row actions on compact; command-palette search path = **2 taps** (search icon → destination).

AFTER walk on these pixels + code:

1. **Glance today's business status (hero + micro-pods + live pills)** — `home_1.0_en_360x800.png`: hero `AED 84K` + pod ROW (`MARGIN` + `BAY OCCU…`) + banner peeking visible at launch (**0 taps**). Meets budget 0 AND now meets fold cap (was 1 pod + no banner in round 1). No logic change.
2. **Drill into job register (category rows → job-cards list)** — `_JobRegister`: compact row tap → `context.push(AppRoutes.jobCards)` (**1 tap**); section `View all` (`ownerRegisterAll` → same route) **1 tap**; expanded `AppTable` `onRowTap` same. `home_1.0_en_768x1024.png` register region shows `Job register / View all` + table header mounted. Compact needs scroll past stacked (non-swipeable) curves — same scroll as before (swipeable `PageView` removed, curves stack). Show-all (`items.take(5)` + inline `ownerRegisterAll` row when `hasMore`) pushes same `jobCards` route — no extra tap vs before.
3. **Triage pending approvals (read-only queue)** — `_QuickActions`: approvals tile (top-4) → `pendingApprovals` (**1 tap + scroll** on compact: tiles sit below register, same as before's 12-row scroll); `_ApprovalsBlocker` banner `View all` → same triage (**1 tap**, now visible/peeking on phone 360 due to U2 fix — strictly better). Header/shell palette search → approvals in **2 taps** (`openOwnerSearch` same 9 destinations, `route-approvals` → `push(pendingApprovals)`). No approve/reject buttons anywhere (STOP-1 honored). Show-all expansion for overflow actions is expand + destination = 2 taps (structural, brief-mandated, same 12 routes/tabs).

| Task | Before | After | Verdict |
|---|---|---|---|
| Glance status (hero + pods) | 0 taps (hero + first pods above fold) | 0 taps (hero + first pod ROW + banner peeking/fully above fold) | same taps ✓ (fold now met) |
| Open job register → job cards | 1 tap (+scroll compact) | 1 tap (row or View-all → same `jobCards`; same scroll past stacked curves) | same ✓ |
| Triage pending approvals | 1 tap + scroll (tile) / 2 taps (search) | 1 tap + scroll (tile) / 2 taps (header or shell search → same palette) / banner View 1 tap (now visible on phone) | same-or-better ✓ |

**Tap-count comparison result: PASS — no frequent task takes more taps than before; most frequent (glance 0, drill 1) stays ≤ 2. Show-all check PASS (register cap-5 + actions top-4 + inline expand, same routes). Search-U1 check PASS (sheet contract same palette, real destinations, no new routes; placement now same-row end-side on all breakpoints including ar/320/1.3x).**

---

## 4. Airbnb rubric + score (0–2 each, pass ≥ 12/16) — ONLY after (1)–(3)

| # | Criterion | Score | Reason |
|---|---|---|---|
| 1 | One task per screen | 2/2 | Executive glance → one hero number + delta → pods → banner → curves → register → actions; single primary read, no feed |
| 2 | Headline-first hierarchy | 2/2 | `Executive Operations Control` → subtitle → pills → `REVENUE AED 84K` → delta; calm empty/error keep headline order |
| 3 | Whitespace, no boxes-in-boxes | 2/2 | 2-col short pod tiles (no tall single-column squares, no dead half-empty cards); hero + pod row + banner above fold on phone 360 (was 0/2 in round 1) |
| 4 | Sheets for secondary actions | 2/2 | Search is a full sheet with handle + autofocused field over real destinations (`home_search_open`); destructive confirmations stay dialogs; no inline field |
| 5 | Sticky CTA (N/A — home has none) | 2/2 | Correctly absent; counted by omission (Retry is an error-state action, not a home CTA) |
| 6 | Section structure with Show-all | 2/2 | Register cap-5 + `View all` + inline `Show-all`; actions top-4 + inline `Show-all` preview; See-all only when more exists |
| 7 | Plain friendly copy, no invented claims | 2/2 | Sentence-case, verb-first `View all`, honest empties, en+ar regenerated, LTR-locked figures; register empty now correct family (`No register rows.` / `New jobs will appear here when they are booked.`, was 1/2 in round 1) |
| 8 | Single emphasized primary action | 2/2 | Exactly one filled action per frame (`Retry` only on error); banner `View all` is text, no twin filled CTAs; no fake approve/reject |
| **Merit total** | | **16/16** | Pass on merit (≥12) |
| **C16 hard-reject cap** | borderless-light-cards / ONE-read / no-duplicate-filled / above-fold / no-orphan-tiles / search-sheet / card-hierarchy / no-ALL-CAPS / zero-as-0 | **No cap** | ALL PASS: above-fold (hero + first pod ROW + banner above fold on 360 en+ar) ✓; no-orphan-tiles (2-col pod grid, single-col only below 360px/320) ✓; search-sheet ✓; one-read ✓; one-filled ✓; hierarchy (`figure → delta → drill`) ✓; no added ALL-CAPS (`REVENUE`/`MARGIN` kept from legacy per migration doc) ✓; zero-as-0 ✓ |
| **C17 U-cap** | ANY owner-file U-law violated caps at 8/16 | **No cap** | Zero owner-file U fails (U1 + U2 + register copy all fixed with pixel+code evidence). U5/U14 surface fails are shell/shared per governance — noted, not counted toward gate |
| **Final** | | **16/16** | PASS, no caps applied |

**Verdict: PASS — bless as U-clean for owner-file scope. 16/16 (pass ≥ 12/16).**

Remaining violations (all shared/shell, non-gating — do NOT block this owner-file PASS, for owning phases):
- App-bar avatar overflow stripes persist @1.3x/320 (shell `WorkspaceAppBar`).
- Bottom-nav `Dashboa…` ellipsis @1.3x (shell `AppBottomNavigation`).
- Banner icon/text/`View all` stacking on expanded + pod overline ellipsis on narrow/medium columns (shared `AppBanner` / `AppKpiCard` responsive grammar).

---

## The two answers

- **Would a first-time user know what to do in 3 seconds?** Yes. `home_1.0_en_360x800.png`: `Executive Operations Control / Real-time overview…` names the place, `REVENUE AED 84K +2.1% Ahead` gives the business today, pills say `Live / 12 active / 5 today`, banner peeks `3 waiting for owner review View all`. Search is now findable (top-right end-side, mirrored top-left in ar). Next step is glanceable.
- **What would an Airbnb product designer reject here?** Nothing gating in owner-file scope after this fix round. Residual nits for the shared-system owners: truncated pod overlines (`BAY OCCU…`/`PENDING A…`) on narrow 360 columns and the stacked yellow banner on expanded widths — both shared-component grammar, not this surface's call to fork.

(End of file — round 2 overwrite, 2026-10-21)
