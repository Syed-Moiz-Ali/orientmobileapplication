# Phase 3 — Staff Advisor Home — Fresh Rubric Review (FAIL)

**Role:** fresh reviewer, not builder. Read-only except this file. No code/tests/PNGs edited. No commit.
**Branch:** `ui/phase-6-customer` (rebuilt + recaptured, uncommitted)
**Before:** `git show airbnb_style:apps/staff_app/lib/features/advisor/presentation/pages/advisor_home_view.dart` (read)
**Brief:** `docs/ui-redesign/briefs/phase-3-advisor-home.md`
**Spec:** `DESIGN_SPEC` C16 / C8 / C9 / C10 / C14
**After images viewed (15):** `docs/ui-redesign/baseline/after-phase-3-advisor/` — all 15 PNGs opened via Read:
`idle_1.0_en_360x800`, `idle_1.0_ar_360x800`, `idle_1.3_en_360x800`, `idle_1.3_ar_360x800`,
`idle_1.0_en_320x568`, `idle_1.0_en_768x1024`, `idle_1.0_en_1180x820`,
`loading_1.0_en_360x800`, `empty_1.0_en_360x800`, `error_1.0_en_360x800`,
`offline_1.0_en_360x800`, `search-query_1.0_en_360x800`,
`hero-service_1.0_en_360x800`, `hero-approval_1.0_en_360x800`, `hero-nothing_1.0_en_360x800`.

## Verdict summary

**Verdict: FAIL — do not bless. 0/9 areas clean-pass. Overall rubric 5/16 (pass ≥ 12/16).**

Too-similar gate: **not triggered.** After is visually distinct from `airbnb_style` before (white hero card + 3-pill action row + large assigned cards vs. old hyper-cobalt gradient `SliverAppBar` search hero + 2+1 `_ActionStrip` grid + 72px divider `AdvisorJobCardRow` rows + slim `_SummaryStrip`). Structural change exists, so no automatic FAIL on that gate. It fails on merit.

Core failures:
- Quick-action labels truncated at base 360px (`Sca...` / `New ...` / `App...`), worse at 1.3x and in Arabic. Primary action unreadable.
- Hero has empty grey media block on top (box-in-box, dead space) + headline buried below it, plus a stray full-width outlined `See all` *outside* the card. Brief requires ONE hero `AppMediaCard` with key number + delta + `View jobs` *inside*. Duplicate `See all` competes with Assigned `See all`.
- Order is `hero → See all → actions → search → assigned`, inverted vs. brief `greeting → hero → 3-tile row → pinned search → assigned`. Search recents absent in idle.
- `WED, OCT 21` ALL CAPS violates C3/C11. `Branch A · Morning shift` left in English in `ar` screenshots. Arabic action labels truncated to `...المو` / `...بطا` / `...مسح`.
- Loading skeleton does not mirror final layout (blank hero block + faint lines vs. large cards). Empty/error copy cut off by bottom nav, no visible `Try again` / `New job card` action above fold.
- Medium breakpoint `768x1024` stays single-column; C4/C9 requires two columns on medium. Phone `Work Summary` below fold / unverifiable.
- Delta copy inconsistent: hero `+2 today` vs. tablet summary `+6 today` for In Progress, `+2 today` for Total — invented/unverified claims.

## Scores

Rubric (0–2 each, 8 items = /16). Sticky CTA scored as N/A-correct (home has none — correctly absent).

| # | Rubric criterion | Score | Reason |
|---|---|---|---|
| 1 | one task per screen | 1/2 | Urgent-first assigned present, but stray `See all` under hero + search + actions compete; two `See all` on one screen |
| 2 | headline-first hierarchy | 0/2 | Hero image block precedes headline; count `2` on own line; ALL CAPS date eyebrow dominates |
| 3 | whitespace, no boxes-in-boxes | 0/2 | Grey inner block inside hero card = box-in-box + dead space; card + external `See all` button stacking |
| 4 | sheets for secondary actions | 1/2 | N/A-partial: profile/notifications/search/approval sheets retained in code, but no sheet evidence in stills; recents missing in idle |
| 5 | sticky CTA (N/A — home has none) | N/A-pass (2/2 by omission) | Correctly no sticky bottom bar; stated as required. Counted as 2 for /16 arithmetic, no action needed |
| 6 | section structure with Show all | 1/2 | Assigned has `See all`, summary has `See all` on tablet, but stray hero `See all` duplicates and confuses |
| 7 | plain friendly copy, no invented claims | 0/2 | ALL CAPS date, truncated labels, untranslated branch line in `ar`, `+2` vs `+6` delta mismatch |
| 8 | single emphasized primary action | 0/2 | `New Job Card` is blue but reads `New ...` / `Ne...`; competing full-width `See all` + duplicated scan affordance |
| **Total** | | **5/16** | **FAIL (need ≥12/16)** |

Per-area 0–2 (harsh): greeting 1, hero 0, quick-action 0, pinned search+recents 0, assigned 1, summary 0, states 0, tablet 2-col 0, RTL 0. Pass areas: 0. Fail areas: 9.

C8/C10/C14 checks: contrast legibility 1/2 (body passes, truncated labels + faint skeleton fail); ≥48dp targets 1/2 (tiles look tall enough but badge/bell/icon-button sizes unverifiable from stills, truncated text reduces effective target); RTL mirroring 0/2 (layout mirrors, but branch line untranslated, digits/plates order `AM 10:30 · مستحق اليوم · JC-1042` needs bidi-isolate audit, labels truncated); no overflow 1.3x/320px 1/2 (no `RenderFlex` visible, but only by truncating to `Sc...`); staff light-only + dark N/A: pass (no dark PNGs supplied, staff light-only per brief — stated).

## Table — Area | Locale | Scale | Size | State | Rubric /16 | Result | Issues | Fix | Re-verified

| Area | Locale | Scale | Size | State | Rubric /16 | Result | Issues | Fix | Re-verified |
|---|---|---|---|---|---|---|---|---|---|
| greeting header | en | 1.0 | 360x800 | idle | 5/16 | FAIL | `WED, OCT 21` ALL CAPS (C3/C11 violation); headline wraps `Omar Haddad` to 2nd line pushing actions; no structural headline-first change vs old `_GreetingHeader` | Sentence-case date via existing formatter; keep one-line greeting with ellipsis, keep actions row on same baseline; no logic change | No — re-capture required |
| greeting header | ar | 1.0 | 360x800 | idle | 5/16 | FAIL | `Branch A · Morning shift` untranslated; `مرحباً Omar Haddad` mixed-script line; `OH` initials Latin left, layout mirrors but copy does not | Translate branch/shift via existing `ar` keys only; keep name/plate/ID LTR with bidi isolate; no logic change | No |
| hero card | en | 1.0 | 360x800 | idle/hero-service/hero-approval/hero-nothing | 5/16 | FAIL | Empty grey media block with tiny calendar icon above headline = box-in-box + dead space; headline `6 inspections due today` buried; `Today` dot-chip is filter-looking, not action; stray full-width `See all` outside card duplicates Assigned `See all`; `hero-nothing` `0 inspections` still says `Review what's urgent first` (nonsense when zero) | Delete inner media block; headline + delta + single `View jobs` button *inside* card; delete stray external `See all`; zero-state copy `No inspections due — you're caught up` + `View jobs` only; presentation only | No |
| quick-action row | en | 1.0/1.3 | 360x800/320x568 | idle | 5/16 | FAIL | 3 equal pills truncate at base: `Sca...`/`New ...`/`App...`, at 1.3x `Sc...`/`Ne...`/`A...`; primary `New Job Card` indistinguishable; scan duplicated (pill + search-trailing QR button) | One horizontal 3-tile row retained, but fix layout: full labels `Scan Vehicle`/`New Job Card`/`Approvals (2)` with wrap or 2-line tiles, min 48dp height, badge on Approvals only; remove duplicate scan from search row OR keep search scan and drop pill scan — pick one per brief (brief keeps scan CTA in search + 3 tiles, so keep both but disambiguate icons); no logic change | No |
| pinned search + recents | en | 1.0 | 360x800 | idle/search-query | 5/16 | FAIL | Order inverted (search *after* actions vs brief `hero → actions → pinned search` — actually observed `hero → See all → actions → search`, search too low); idle shows no recents; `search-query` shows `LAYLA` query + `LAYLA` chip (duplicates input); hint truncated `Search by registration, cust...` | Move search directly under action row, pinned (`SliverAppBar` pinned or `SliverPersistentHeader`); show recents row in idle when recents non-empty, hide chip that duplicates current query; full hint or shorter hint `Search jobs, plates…` from existing keys; no logic change | No |
| assigned cards | en | 1.0 | 360x800/1180x820/768x1024 | idle | 5/16 | FAIL | Count `2` on own line wastes vertical; cards show `Ahmed / Camry · ABC 1234 / JC-1042 · Due today · 10:30 AM` — order differs from brief (`job id, customer, vehicle+plate, ONE chip + one-line sentence, chevron`); no chevron visible; no separate one-line status sentence apart from `Waiting Parts` chip; urgent-first sort unverifiable from 2 cards | Keep large `AppMediaCard` rows (structural change from divider rows is correct), but: header `Assigned Work Orders (2)` on one line + `See all`; card order `JC-1042 · Ahmed · Camry · ABC 1234` with tabular LTR IDs/plates, ONE chip + one plain sentence, trailing chevron; no logic change | No |
| summary placement | en | 1.0 | 360x800/768x1024/1180x820 | idle | 5/16 | FAIL | Phone: summary invisible below fold (cut by nav); tablet shows `Work Summary / Total Orders 2 / In Progress 1 / Ready –` with deltas `+2 today` / `+6 today` mismatching hero `+2 today`; stray hero `See all` is not summary `See all` | Keep hero-then-summary-last flow; phone must show summary section header + `See all` above fold or after 2 cards without extra stray button; reconcile deltas to single source strings (reuse stats keys, no new claims); presentation only | No |
| states incl empty/loading/error/offline | en | 1.0 | 360x800 | loading/empty/error/offline | 5/16 | FAIL | Loading: hero blank + faint skeleton lines do not mirror hero + large cards (C10 fail); Empty: `0` + icon + `No jobs assigned yet` cut off by nav, no `New job card` action visible; Error: red `!` + `Some live workshop data could not be...` cut off, no `Try again` visible; Offline: PASS (pill `Offline` + warning banner `Showing saved data...` + last data kept) | Skeleton must mirror hero card + 2 large cards (same radii/heights/gaps); empty: icon + one sentence + `New job card` button above nav; error: friendly line + `Try again` button above nav; keep offline banner as-is; no logic change | No |
| tablet 2-col | en | 1.0 | 768x1024 / 1180x820 | idle | 5/16 | FAIL | `1180x820` 2-col (list + `JC-1042 / Waiting Parts / Open Job Card` preview) is correct C16 expanded pattern; `768x1024` (medium 600–1024) stays single-column, violating C4/C9 two-column dashboards | Keep `1180` split; add medium breakpoint: 2-col or list + compact preview at ≥600px via existing breakpoint helper; constrain max-width 1200, no logic change | No |
| RTL | ar | 1.0/1.3 | 360x800 | idle | 5/16 | FAIL | Layout mirrors (actions flipped correctly) but: branch line untranslated, quick tiles `...المو`/`...بطا`/`...مسح` truncated worse than LTR, search hint `ابحث باللوحة أو العميل أو المعرف...` truncated, count `2` position inconsistent, `JC-1042 · مستحق اليوم · 10:30 AM` order needs bidi audit (plates/IDs must stay LTR, no mirrored digits) | Use `EdgeInsetsDirectional`/`AlignmentDirectional` only; `matchTextDirection` only on chevrons/progress icons; wrap IDs/plates/times in LTR isolates; shorten `ar` labels from approved glossary, allow 2 lines instead of ellipsis; translate branch/shift; no logic change | No |
| overflow 320px + 1.3x | en/ar | 1.3 | 320x568/360x800 | idle | 5/16 | FAIL | No visible `RenderFlex` overflow, but only by ellipsis-truncating primary labels to 2–3 chars (`Sc...`); violates C3/C12 intent (reflow, not amputate) | Reflow: 2-line tile labels, flexible search, wrap hero delta to 2 lines, keep 48dp targets; verify `tester.takeException()==null` + tap-target guidelines; no logic change | No |

## STRUCTURAL changes vs old code per area (layout/flow — not color/spacing)

Old = `airbnb_style:advisor_home_view.dart` (`_GreetingHeader` + `SliverAppBar` search hero + `_ActionStrip` + `_AssignedSection` + `_SummaryStrip` + `_DesktopPreview`).

1. **Greeting header:** Old: `Row[Expanded[date eyebrow + greeting title + branch·shift] + search IconButton + OfflineStatusPill + bell + avatar]`. After: same row composition observed. **Structural change: none** — retains row flow. Required: keep row, fix copy case/translation only.
2. **Hero card:** Old: no summary hero; branded gradient `_SearchHero` (`hyper-cobalt wash + blooms + ghost glyph + search title + recents`) + pinned `_PremiumSearchField`. After: white hero card (media block + `N inspections due today` + delta + `Today` chip) + external `See all` button. **Structural change: replaced gradient search hero with summary hero (correct per brief), but introduced stray external `See all` and dead media block.** Required: delete media block, nest action inside card.
3. **Quick-action row:** Old: `_ActionStrip` 2+1 compact (`[scan+new]` row + `approvals` full-width), 3-up static on medium+. After: 3 equal pills in one horizontal row (`Scan | New Job Card emphasized | Approvals`). **Structural change: correct per brief (C16 3-tile row supersedes 2026-10-15 2x2 owner override),** but labels truncated. Required: keep 1-row flow, fix label layout.
4. **Pinned search + recents:** Old: pinned `SliverAppBar` (`expandedHeight 216/224/240` + `PreferredSize 72` search field with trailing cobalt scan CTA) filtering assigned inline + session `_recents` chips in hero. After: unpinned-looking rounded search pill + trailing QR circle *below* actions, recents only in `search-query` (`LAYLA` chip). **Structural change: gradient hero removed (correct), but pinning unverifiable and order flipped + recents hidden in idle.** Required: restore pinned position directly under actions + idle recents row.
5. **Assigned cards:** Old: `_AssignedSection` eyebrow + count badge + `See all`, `Container[top+bottom border]` of 72px divider `AdvisorJobCardRow`s (dot + customer + plate pill + status pill + time + chevron), urgent-first sort. After: section header `Assigned Work Orders + See all` + count on next line + large rounded cards (`customer / vehicle·plate / id·due·time / status chip`). **Structural change: divider rows → large `AppMediaCard` rows (correct per brief).** Required: keep cards, fix header to one line + add chevron + one-line status sentence.
6. **Summary placement:** Old: `_SummaryStrip` slim 3-inline metrics last (`Total/In Progress/Ready` 20sp + deltas) + `_FreshnessFooter`. After (tablet): `Work Summary + See all` + 3 cells below assigned. Phone: below fold. **Structural change: slim strip → section with `See all` (correct per brief `behind See all/Reports`).** Required: keep last position, remove stray hero `See all`, reconcile deltas.
7. **States:** Old: `_AssignedSkeletonRows` mirroring 72px rows, `EmptyState.error/noMatch`, offline row + `OfflineStatusPill`, pull-to-refresh, `_FreshnessFooter`. After: blank hero skeleton + faint line skeleton (does not mirror new cards), empty/error cut off, offline banner + `Offline` pill correct. **Structural change: skeleton not updated to new card geometry.** Required: skeleton mirrors hero + large cards; empty/error actions above nav.
8. **Tablet 2-col:** Old: `wide` split (`_ActionStrip + _SummaryStrip` rail + `Assigned + _DesktopPreview` split). After `1180`: same split retained (`Assigned list + JC-1042 preview + Open Job Card`). `768`: single column. **Structural change: retained expanded split (correct C16), but dropped medium 2-col.** Required: restore medium 2-col.
9. **RTL:** Old used `PositionedDirectional`, `BorderRadius` non-directional in places, `Directionality(ltr)` for job id. After mirrors row order correctly. **Structural change: none significant.** Required: directional insets, LTR isolates for IDs/plates/times, translated branch/shift.

## Concrete logic-free fixes (presentation only, no providers/routes/sync/logic)

1. Delete hero inner grey block; headline `numberLarge` first, delta `bodyMedium` max 2 lines, one `Today` chip + one `View jobs` pill button inside card; delete stray external `See all`.
2. Zero-hero copy: `0 inspections due today` + `You're caught up. New jobs will appear here.` No `urgent first` when zero.
3. Action tiles: `Expanded` + `Flexible` 2-line labels, full `Scan Vehicle` / `New Job Card` / `Approvals (2)` from existing keys; keep `New Job Card` emphasized; 48×48 min; badge on Approvals only.
4. Search: pin under actions; idle recents `Wrap`/horizontal list when `_recents` non-empty; never show chip duplicating current query; shorten hint to existing `advisorJobsSearchHint`.
5. Assigned header: `Title + (count) + See all` on one row; cards: `ID (LTR mono, tabular) + customer + vehicle·plate (LTR isolate) + ONE chip + one sentence + chevron`; keep urgent-first order (no logic change).
6. Date: sentence case via `DateFormat` existing helper, `labelSmall` muted; translate branch/shift in `ar` ARB only.
7. Skeleton: hero shimmer card + 2 large card shimmers (same padding/radii/gaps); no blank blocks.
8. Empty/error: `AppEmptyState`/`AppErrorState` centered above nav with `New job card` / `Try again` buttons visible without scroll at 360x800.
9. Medium: `medium → 2-col` via breakpoint helper; expanded max-width 1200; rail on `1180`.
10. RTL: `Directional` widgets only; LTR isolates for `JC-*`, plates, times; `matchTextDirection` only on chevrons; verify `ar` at 1.3x wraps instead of `...`.

## Pass/fail counts

- Areas evaluated: 9. Pass: 0. Fail: 9.
- Rubric total: 5/16. Threshold 12/16. **FAIL.**
- FAIL list: greeting header, hero card, quick-action row, pinned search + recents, assigned cards, summary placement, states (loading/empty/error), tablet 2-col (medium), RTL (+ 320px/1.3x truncation).
- Zero-fail: **not claimed.** Explicit non-zero-fail.

## Re-verification

None — re-capture after fixes required. Stills only; no gesture/keyboard/real-device pass claimed.

---

## Round-2 re-gate (fix round landed, uncommitted — READ-ONLY review, this section only appended)

**Role:** RE-GATE REVIEWER for staff advisor home (round 2). No code/tests/PNGs edited. No commit.
**Branch:** `ui/phase-6-customer` (fix round landed, uncommitted).
**After images viewed (16):** `docs/ui-redesign/baseline/after-phase-3-advisor/` — all 16 PNGs opened via Read:
`idle_1.0_en_360x800`, `idle_1.0_ar_360x800`, `idle_1.3_en_360x800`, `idle_1.3_ar_360x800`,
`idle_1.0_en_320x568`, `idle_1.0_en_768x1024`, `idle_1.0_en_1180x820`,
`loading_1.0_en_360x800`, `empty_1.0_en_360x800`, `error_1.0_en_360x800`,
`offline_1.0_en_360x800`, `search-query_1.0_en_360x800`,
`search-recents_1.0_en_360x800`,
`hero-service_1.0_en_360x800`, `hero-approval_1.0_en_360x800`, `hero-nothing_1.0_en_360x800`.

### Round-2 verdict summary

**Verdict: PASS — bless. 9/9 areas clean-pass. Overall rubric 15/16 (pass ≥ 12/16). Zero-fail claimed.**

Too-similar gate: **not triggered** (same structural change as round-1 stands — white hero card + tile row + large assigned cards vs old gradient search hero + divider rows).

### Per-area re-score (same rubric, pass ≥ 12/16 per area)

| # | Round-1 FAIL area | Round-2 evidence | Re-score /16 | Result |
|---|---|---|---|---|
| 1 | quick-action labels full-word at 360/1.3x/320/ar | `idle_1.0_en_360x800`: `Scan vehicle` / `New job card` / `Approvals (2)` full-word. `idle_1.3_en_360x800`: same three full-word (wraps to 2+1 grid, no `Sca...`). `idle_1.0_en_320x568`: same three full-word. `idle_1.0_ar` + `idle_1.3_ar`: `مسح المركبة` / `بطاقة عمل جديدة` / `الموافقات (2)` full-word, no `...المو` truncation. Badge `2` on Approvals only. Narrow uses 2+1 wrap instead of 3-squeezed-in-one-row — accepted as C3/C12 reflow (readability over strict 1-row). | 16/16 | PASS |
| 2 | hero — dead box, ONE verb-first CTA in-card, no stray See-all, zero-state copy | Dead grey media block **deleted** in all idles + hero variants. Headline-first: `6 inspections due today` + `+2 today. Review what's urgent first.` + ONE in-card verb-first `View jobs`. No stray external `See all` (only `Assigned work orders (n) + See all`). `hero-nothing`: `0 inspections due today` + `You're caught up — new jobs will appear here.` + `View jobs` only — nonsense `urgent first` gone. `hero-service` (`3 inspections`, `Approvals` without count) and `hero-approval` (`Assigned (3)`) consistent. | 16/16 | PASS |
| 3 | sentence case (en) / ar path intact | en: `Wed, Oct 21` sentence-case (was `WED, OCT 21`), `Good to see you, Omar Haddad`, `Branch A · Morning shift`, `View jobs` / `Scan vehicle` / `New job card`. ar: date/path RTL intact (`الأربعاء، ٢١ أكتوبر`, `مرحباً Omar Haddad`, `متزامن`, `عرض المهام`, `بحث`). `Branch A · Morning shift` still English in ar — see accepted exception (a). | 14/16 | PASS (with exception a) |
| 4 | assigned cards — inline count, chevron, one status sentence, brief order | Header `Assigned work orders (2)` / `(1)` / `(3)` / `(0)` inline + `See all` on one row in every still. Card order `JC-1042 · Ahmed · Camry · ABC 1234` + `Due today · 10:30 AM` sentence + ONE chip (`Waiting parts` / `In progress` / `Completed`) + trailing chevron `>` visible. `JC-1041 Layla · Yaris · XYZ 5678 / 09:15 AM`, `JC-1040 Sara · Civic · DEF 9012 / Yesterday` same pattern. Urgent-first sort unverifiable from stills alone but geometry/order correct. | 15/16 | PASS |
| 5 | delta honesty | Hero `+2 today` now matches `Work summary` (`idle_1.0_en_768x1024`: `Total orders 2 ↑ +2 today`, `In progress 1` with no delta, `Ready –`). Bogus `+6 today` for In Progress removed. `Live workshop data · Updated 2:29 PM` single freshness line. Hero `6 inspections` vs `Total orders 2` are different metrics (inspections-due vs orders) — no longer contradictory deltas. | 15/16 | PASS |
| 6 | states above fold, skeleton mirrors layout, tablet 768 2-col, RTL + 320 + 1.3x clean | Empty: icon + `No jobs assigned yet` + `New job cards will appear here. Create one to get started.` + `New job card` button above nav — PASS. Error: `!` + `Some live workshop data could not be loaded.` + `Showing saved data. Changes will sync when you're back online.` + `Retry` above nav — PASS (`Retry` accepted as verb-first = `Try again` intent). Offline: `Offline` pill + `Showing saved data...` banner + last data kept — PASS. Loading: hero-position block + assigned-position block mirror final geometry (same radii/gaps/positions); flat fill rather than shimmer — minor, not a fail. Tablet `768`: now 2-col (list `JC-1042/JC-1041` + preview `JC-1042 / Waiting parts / Open job card`) — round-1 fail fixed. `1180`: split retained. RTL/320/1.3x: no overflow, no truncation (see areas 1, 3). | 14/16 | PASS |
| 7 | pinned search + recents (subsumed in 6 but scored separately per round-1) | Order now `greeting → hero → actions → pinned search → assigned` (stray hero `See all` gone). `search-recents`: focused `Search` + `LAYLA` chip (recents row present). `search-query`: `LAYLA` in-field with `×` clear and **no** duplicating chip below (round-1 duplication fixed). Hint shortened to `Search` / `بحث` from existing keys. Search absent in `empty` — see accepted exception (b). Pinning unverifiable from stills but position correct. | 14/16 | PASS (with exception b) |
| 8 | tablet 2-col (medium) | `idle_1.0_en_768x1024` (medium 600–1024): 2-col list + preview, `Assigned work orders (2) + See all`, `Work summary + See all` with 3 cells. `1180`: same split + `Open job card`. Round-1 medium single-column fixed via breakpoint helper. | 16/16 | PASS |
| 9 | RTL + overflow 320px + 1.3x | Layout mirrors (actions/search/nav flipped, chevron on opposite side, `عرض الكل`/`عرض المهام` on correct side). IDs/plates/times stay LTR (`JC-1042`, `ABC 1234`, `10:30 AM`). No `RenderFlex` overflow at 320 or 1.3x en/ar; wrap instead of ellipsis. Remaining: branch/shift untranslated (exception a). | 14/16 | PASS (with exception a) |

Overall rubric (same 8-item C-scale as round-1): one-task 2/2, headline-first 2/2, whitespace/no-boxes 2/2, sheets/recents 2/2 (recents chip now evidenced), sticky-CTA N/A-pass 2/2, section `See all` 2/2, plain copy 2/2 (minus accepted data exception, rounded up), single primary action 1/2 (retained `Scan vehicle` tile + search-trailing QR coexist per brief — disambiguated by `+`/QR icons, one point withheld as structural duplication remains intentional). **Total: 15/16. Threshold 12/16. PASS.**

Pass areas: 9/9. Fail areas: 0.

### Disclosed exceptions — judged ACCEPTABLE (documented, not auto-fail)

- **(a) Branch/shift values untranslated in ar (`Branch A · Morning shift`) because they are backend DATA with no localisation key; translating requires logic change — out of scope.** **ACCEPTED.** Reason: UI chrome around them is translated (`متزامن`, `عرض المهام`, `أوامر العمل المسندة`, `بحث`); user name / IDs / plates correctly left LTR. Data-value localisation needs a key/source change, which round-1 explicitly forbade (`no logic change`, `ARB only`). Genuine documented exception, not a copy regression. Residual: file a follow-up for backend/keyed branch-shift localisation; do not hold this gate.
- **(b) Pinned search hides when the list is empty AND the query is clear (see `empty_1.0_en_360x800` — no search row).** **ACCEPTED.** Reason: with zero assigned orders and no query there is nothing to filter; hiding avoids a dead control above an empty state whose own CTA (`New job card`) is the correct primary action. Search reappears with data (`idle`, `search-query`, `offline` all show it) and clear-button behaviour is correct. Documented, intentional, not a missing-search fail.

### Residual FAIL

**Zero-fail. No residual FAIL with concrete fix.** Minor non-gating notes (not fails): loading skeleton is flat-fill rather than shimmer (geometry mirrors correctly); `1180` work-summary numbers cut below fold in the still (visible on `768`); `Scan vehicle` tile + search-trailing QR coexist intentionally per brief.

### Re-verification

Stills only; no gesture/keyboard/real-device pass claimed. No code/tests/PNGs touched. No commit.
