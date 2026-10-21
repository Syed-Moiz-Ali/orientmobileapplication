# Phase 3 — Advisor Home — Fresh U-Laws Review (FAIL on U8 feed item)

**Role:** FRESH REVIEWER, not builder. Read-only except this file. No code/tests/PNGs edited. No commit.
**Branch:** `ui/phase-6-customer` (rebuild landed, uncommitted)
**Read first:** DESIGN_SPEC C16 + C17 + hard-reject; brief `docs/ui-redesign/briefs/phase-3-advisor-home.md`;
tap-count BEFORE numbers from `docs/ui-redesign/evaluation/advisor-home-test-migration.md` (tap-count table).
**After images viewed (16, all via Read):** `docs/ui-redesign/baseline/after-phase-3-advisor/`
`idle_1.0_en_360x800`, `idle_1.0_ar_360x800`, `idle_1.3_en_360x800`, `idle_1.3_ar_360x800`,
`idle_1.0_en_320x568`, `idle_1.0_en_768x1024`, `idle_1.0_en_1180x820`,
`loading_1.0_en_360x800`, `empty_1.0_en_360x800`, `error_1.0_en_360x800`,
`offline_1.0_en_360x800`, `search-query_1.0_en_360x800`, `search-recents_1.0_en_360x800`,
`hero-service_1.0_en_360x800`, `hero-approval_1.0_en_360x800`, `hero-nothing_1.0_en_360x800`.
Dark: n/a — no dark PNGs supplied; staff app is light-only per brief.

---

## (a) DESCRIBE — what is visible, region by region, at full resolution (no judging)

### Light 360 — `idle_1.0_en_360x800.png` (reference frame)
- **Header region (top):** left-aligned muted date line `Wed, Oct 21`. Right-aligned row of three
  elements: magnifier search icon, bell icon with red count badge `3` offset above-right of the glyph,
  circular avatar with initials `OH`. Below, bold headline `Good to see you, Omar Haddad` on one line,
  muted sub-line `Branch A · Morning shift` beneath it.
- **Hero region:** one large rounded white card. Inside, bold title `6 inspections due today`,
  muted sentence `+2 today. Review what's urgent first.`, one full-width filled blue pill button
  `View jobs` at the card bottom.
- **Quick-action region:** one horizontal row of three equal white tiles: `Scan vehicle` (QR icon),
  `New job card` (blue `+` icon), `Approvals` (checklist icon, red count badge `2` offset outside the
  tile's top-right corner). Single-line labels.
- **Assigned-list region:** section header `Assigned work orders (2)` with no trailing button on this
  frame. Two large white cards. Card 1: title `Ahmed · Camry · ABC 1234`, red-tint pill `Waiting parts`
  with dot, muted lines `Due today · 10:30 AM` and `JC-1042`, right-aligned `>` chevron. Card 2:
  title `Layla · Yaris · XYZ 5678`, teal-tint pill `In progress` with dot, muted lines `09:15 AM` and
  `JC-1041`, `>` chevron. Freshness line below: green lightning glyph + `Live workshop data · Updated 4:19 PM`.
- **Nav region:** bottom bar with three items: `Today` (active blue, grid icon in soft-blue pill),
  `Jobs` (receipt icon), `Reports` (bar-chart icon).

### Dark — n/a (staff-only light)
No dark PNGs in the folder. All frames are light theme.

### Arabic — `idle_1.0_ar_360x800.png`
- **Header:** date at top-right `الأربعاء، ٢١ أكتوبر`; icons mirrored to top-left (avatar `OH`,
  bell + badge `3`, search). Headline right-aligned `مرحباً Omar Haddad`; sub-line in English
  `Branch A · Morning shift`.
- **Hero:** right-aligned title `6 عمليات فحص مستحقة اليوم`, sentence `+2 اليوم. راجع المهام العاجلة أولاً.`,
  filled button `عرض المهام`.
- **Quick actions:** mirrored row: `مسح المركبة` (QR), `بطاقة عمل جديدة` (`+`, two lines),
  `الموافقات` (checklist, badge `2` offset outside). Full-word labels, no ellipsis characters.
- **Assigned:** right-aligned header `أوامر العمل المسندة (2)`. Cards right-aligned:
  `Ahmed · Camry · ABC 1234` + red pill `بانتظار القطع`, `مستحق اليوم · AM 10:30`, `JC-1042`, chevron on
  the left side; second card `Layla · Yaris · XYZ 5678` + teal pill `قيد التنفيذ`, `AM 09:15`, `JC-1041`.
  IDs, plates and times render LTR (`JC-1042`, `ABC 1234`, `10:30 AM`).
- **Nav:** mirrored: `اليوم` active right, `المهام` center, `التقارير` left.

### 1.3x — `idle_1.3_en_360x800.png` / `idle_1.3_ar_360x800.png`
- Same regions and order. Greeting wraps to two lines (`Good to see you, Omar` / `Haddad`) with no
  ellipsis. Hero sentence wraps to two lines. Quick-action labels wrap to two lines (`Scan` / `vehicle`,
  `New job` / `card`; ar `مسح` / `المركبة`, `بطاقة عمل` / `جديدة`) with icons intact. First assigned
  card fully visible above the bottom nav; second card reaches the nav edge. No `RenderFlex` overflow
  text, no clipped glyphs.

### 320px — `idle_1.0_en_320x568.png`
- Same order: date + icons, greeting + branch line, hero card (`6 inspections due today` + sentence +
  `View jobs`), three tiles (`Scan vehicle` / `New job card` / `Approvals` + badge `2`), header
  `Assigned work orders (2)`, first card (`Ahmed · Camry · ABC 1234`, `Waiting parts`,
  `Due today · 10:30 AM`, `JC-1042`, chevron). Labels wrap to two lines where narrow. No overflow markers.

### 768 (medium) — `idle_1.0_en_768x1024.png`
- Left icon rail (blue square logo mark, grid, receipt, chart icons vertically; `OH` avatar at bottom).
  Content two-column: left column holds greeting, hero card, three tiles, `Assigned work orders (2)`
  list (Ahmed + Layla cards with chevrons); right column holds a detail preview card (`JC-1042`,
  `Waiting parts` pill, `Ahmed`, `Camry · ABC 1234`, filled `Open job card` button). Freshness line
  under the list.

### 1180 (expanded) — `idle_1.0_en_1180x820.png`
- Same left rail. Wider two-column split: list column (assigned cards) + preview column
  (`JC-1042` / `Waiting parts` / `Ahmed` / `Camry · ABC 1234` / `Open job card`). Hero spans the content
  width with `View jobs`. No bottom nav (rail replaces it).

### Empty-day — `empty_1.0_en_360x800.png`
- Header, hero (`6 inspections due today` + `View jobs`), three tiles, header `Assigned work orders (0)`.
  Centered empty block: light-blue circle with clipboard icon, title `No jobs assigned yet`, sentence
  `New job cards will appear here. Create one to get started.`, filled button `New job card`, all above
  the bottom nav. Freshness line present.

### Search screen/sheet — `search-recents_1.0_en_360x800.png`, `search-query_1.0_en_360x800.png`
- Full-screen sheet over dimmed home (home header dimmed behind). Grab handle at top, title `Search`,
  autofocused rounded input with blue focus border, search glyph left, `×` clear when text present,
  separate scan QR button to the right of the field.
- Recents frame: hint `Search customers, vehicles...`, helper `Lookup repair orders, estimates & history`,
  `Recent` label + `Clear` action, recent row `LAYLA` with history-clock icon and chevron.
- Query frame: input holds `LAYLA`, grouped results `Job Cards (1)` (row `Layla`, `Yaris · XYZ 5678 · JC-1041`,
  clipboard icon, chevron) and `Approvals (1)` (row `Layla`, `E2 · AED 120`, thumbs-up icon, chevron).
  No chip duplicating the typed query.

### Remaining states (light 360)
- `loading_1.0_en_360x800.png`: header + three tiles + `Assigned work orders (0)` header rendered; hero
  position and two card positions are flat light rounded blocks matching card geometry; freshness line present.
- `error_1.0_en_360x800.png`: header, hero, tiles as idle; error block with soft-red circle + `!` glyph,
  title `Some live workshop data could not be loaded.`, sentence `Showing saved data. Changes will sync
  when you're back online.`, filled `Retry` button above nav.
- `offline_1.0_en_360x800.png`: header and hero as idle; warning-tinted banner with triangle icon:
  `Showing saved data. Changes will sync when you're back online.` Tiles, `Assigned work orders (2)`,
  both cards, and bottom nav all present with last data.
- `hero-service_1.0_en_360x800.png`: hero `3 inspections due today` + `Review what's urgent first.` +
  `View jobs`; `Assigned work orders (1)` with the Layla `In progress` card.
- `hero-approval_1.0_en_360x800.png`: hero `6 inspections due today` + sentence + `View jobs`;
  `Assigned work orders (3)` with Ahmed, Layla, and a third card peeking at the nav edge.
- `hero-nothing_1.0_en_360x800.png`: compact calm row (no large hero): green check circle + sentence
  `You're caught up — new jobs will appear here.` No filled button in that row. Below: three tiles,
  header `Assigned work orders (1)`, one card `Sara · Civic · DEF 9012` with green-tint pill `Completed`,
  muted lines `Yesterday` and `JC-1040`, chevron. Freshness line present.

---

## (b) U0–U14 walk, one by one (evidence = image + region; ANY fail caps at 8/16)

| Law | Evidence (image + region) | Pass / Fail |
|---|---|---|
| U0 — fewer steps, never hunt/tap more than necessary | `idle_1.0_en_360x800` hero + assigned regions: next work (`View jobs`, first card) and create/scan/approvals all visible from launch with zero scroll; `search-query` sheet focuses input and groups results with scan beside the field | PASS |
| U1 — search ICON top-right, full-screen search, never inline | `idle_1.0_en_360x800` header: magnifier sits top-right next to bell + avatar; body has no text field. `search-recents` + `search-query`: tapping opens a full-screen sheet (handle, autofocused field, recents in normal case, scan button inside, grouped results). Same header placement as customer home | PASS |
| U2 — first actionable item above the fold at 360x800 idle | `idle_1.0_en_360x800` assigned region: first card (Ahmed · Waiting parts · JC-1042) fully visible above the bottom nav. Holds at `idle_1.3_en_360x800` (first card fully above nav) and `idle_1.0_en_320x568` (first card visible) | PASS |
| U3 — tap counts (brief BEFORE vs AFTER; details in §c) | Migration table: open job 1→1, new job 1→1, search 3→2. `idle` assigned region: first card tappable (chevron row); quick-action region: `New job card` tile without scrolling; header search icon → autofocused sheet | PASS |
| U4 — create/scan reachable without scrolling, lower half or sticky | `idle_1.0_en_360x800` quick-action region: `Scan vehicle` + `New job card` tiles visible at launch below the hero (in the screen's lower half), no scroll needed; also `empty` keeps a `New job card` CTA above the nav | PASS |
| U5 — no truncation of primary text; rows fit or scroll with clean peek | `idle_1.0_en_360x800`: greeting + all three tile labels full-word, single line. `idle_1.3_en_360x800`: greeting wraps to 2 lines with no `…`; tiles wrap (`Scan/vehicle`, `New job/card`) with icons intact, badge on Approvals only. `idle_1.0_ar` / `idle_1.3_ar`: full-word Arabic labels, 2-line wrap, no `...` fragments. 3 equal columns, nothing cut mid-word | PASS |
| U6 — calm empty: hero collapses to a status line, no filled CTA when nothing exists | `hero-nothing_1.0_en_360x800` hero region: compact row (green check + `You're caught up — new jobs will appear here.`), zero filled buttons, no `0 …` headline. (`empty_1.0_en_360x800` keeps the filled hero because 6 inspections are still due — attention exists, so the CTA is legitimate) | PASS |
| U7 — one path per task; See-all only when more exists than shown | `idle_1.0_en_360x800` assigned region: `Assigned work orders (2)` shows both cards and correctly shows NO See-all (nothing more to see). `hero-approval` shows 3 with list scroll (cap is 6, so no See-all owed). Hero `View jobs` is the one persistent list path; Jobs tab is global nav, not a second in-page entry | PASS |
| U8 — relevance: completed/history never under Assigned/To-do | `hero-nothing_1.0_en_360x800` assigned region: card `Sara · Civic · DEF 9012`, pill `Completed`, meta `Yesterday`, `JC-1040` sits under the header `Assigned work orders (1)`. A terminal-status, yesterday-dated item is presented as assigned to-do. Feed ownership is documented (`docs/ui-redesign/LOGIC_FOLLOWUPS.md` §1: status-agnostic feed admits terminal statuses; sort/fixture innocent; owner = backend/product; status open; no silent filter applied) — the *handling* clause is obeyed, but the *visible* law is violated on-screen | **FAIL** |
| U9 — consistency: same element, same place across screens/apps | Header search/bell/avatar top-right on every phone frame (mirrored top-left in ar), matching the customer-home placement; bottom nav Today/Jobs/Reports on compact, rail on 768/1180; primary CTA inside the hero card | PASS |
| U10 — feedback/forgiveness; errors say what to do next | `error_1.0_en_360x800`: what happened + what to do (`Showing saved data…` + `Retry`). `offline_1.0_en_360x800` banner region: `Showing saved data. Changes will sync when you're back online.` Destructive logout dialog is code-kept (not visible in stills). Haptics/toasts not provable from stills — stated limit | PASS (stills-limited) |
| U11 — readable numbers: zero is 0, stats labelled/visible/decision-helping | `empty_1.0_en_360x800`: `Assigned work orders (0)` — zero as `0`, never `–`. Hero `6 inspections due today` + `+2 today` labelled; bogus tablet deltas and zero-as-dash summary are gone (summary removed). No dash-for-zero anywhere in the 16 frames | PASS |
| U12 — one background colour, no stray bands | All idle/ar/scale/size frames: single page background; the old pinned-search surface band + divider are gone with the inline pill. The offline banner is a warning notice (allowed), not a band behind rows | PASS |
| U13 — new-employee test: plain words in 3 seconds | Tiles `Scan vehicle` / `New job card` / `Approvals`; hero `6 inspections due today. Review what's urgent first. View jobs`; statuses `Waiting parts` / `In progress` / `Completed`; empty `No jobs assigned yet. New job cards will appear here.` All plain verbs, no jargon | PASS |
| U14 — a11y: ≥48dp targets, AA, semantics, 1.3x + 320px without clipping | `idle_1.3_en/ar_360x800` + `idle_1.0_en_320x568`: no overflow, no clipping, wrap-not-truncate; badges offset outside glyphs (bell `3`, Approvals `2`); buttons/tiles read ≥48dp. Exact dp/contrast/semantics need instrumented tests — stated limit | PASS (stills-limited) |

**U-walk fails: 1 — U8** (completed `JC-1040 Sara · Civic · Yesterday` under `Assigned work orders`
in `hero-nothing_1.0_en_360x800.png`). Handling per the law's feed clause is correct and logged
(`LOGIC_FOLLOWUPS.md` §1, status open); the presentation layer did not silently filter. Zero-fail is
**not** claimed.

---

## (c) Top-3 advisor tasks — AFTER (each tap + scroll) vs BEFORE counts

BEFORE counts (verbatim from `advisor-home-test-migration.md` → Tap counts before → after):

- Open an assigned job: **1** (launch lands on Today with the first job visible; single tap opens detail)
- Create a job card: **1** (New-job tile, no scroll)
- Search to results: **3** (before: focus pill + type + submit-which-opens the sheet)

AFTER walk on these screens:

1. **Open first work order** — `idle_1.0_en_360x800` assigned region: first card
   (Ahmed · Camry · JC-1042, chevron row) is above the fold. **1 tap, 0 scroll → 1.**
   Before 1 → After 1. Most-frequent task ≤ 2 ✓. No increase.
2. **Create new job card** — `idle_1.0_en_360x800` quick-action region: `New job card` tile visible at
   launch. **1 tap, 0 scroll → 1.** Before 1 → After 1. No increase.
3. **Search + scan** — `idle_1.0_en_360x800` header: **tap 1** search icon → `search-recents` sheet
   (autofocused, recents `LAYLA`, scan button inside); **type** query → `search-query` grouped results.
   **2 taps/actions (tap icon + type), 0 scroll → 2.** Before 3 → After 2. Decreased.

| Task | Before | After | Verdict |
|---|---|---|---|
| Open first work order | 1 | 1 | same, ≤2 ✓ |
| Create new job card | 1 | 1 | same ✓ |
| Search + scan to results | 3 | 2 | fewer ✓ |

**Tap-count comparison result: PASS — no frequent task takes more taps than before; the most frequent
(open first work order, 1 tap) is ≤ 2.**

---

## (d) Airbnb rubric + score (0–2 each, pass ≥ 12/16) — ONLY after (a)–(c)

| # | Criterion | Score | Reason |
|---|---|---|---|
| 1 | One task per screen | 2/2 | Next-work focus: one hero, three tiles, urgent-first assigned list; no widget grid |
| 2 | Headline-first hierarchy | 2/2 | Greeting headline → hero key number first → sentence → single in-card CTA; calm zero-row has no competing headline |
| 3 | Whitespace, no boxes-in-boxes | 2/2 | Borderless light cards separated by space; dead media block gone; no card-in-card |
| 4 | Sheets for secondary actions | 2/2 | Search is a full sheet with recents + scan evidenced (`search-recents`, `search-query`); profile/notifications/approval sheets code-kept |
| 5 | Sticky CTA (N/A — home has none) | 2/2 | Correctly absent; counted by omission as in prior rounds |
| 6 | Section structure with Show-all | 2/2 | Inline `Assigned work orders (n)`; See-all correctly absent when all shown (U7); hero `View jobs` the one persistent path |
| 7 | Plain friendly copy, no invented claims | 1/2 | Sentence-case, verb-first buttons, honest errors; −1: backend branch/shift values still English in ar frames (feed-owned, logged pattern) and the hero↔list count relationship (`6 due` vs `2 assigned`) is unexplained on-screen |
| 8 | Single emphasized primary action | 2/2 | Exactly one filled CTA per section (hero `View jobs`; empty `New job card`; error `Retry`); tiles neutral; counts live on badges only |
| **Merit total** | | **15/16** | Pass on merit (≥12) |
| **U8 cap** | ANY violated law caps at 8/16 | **8/16** | U8 visible fail (completed JC-1040 under Assigned) caps the screen |

**Verdict: FAIL — do not bless as U-clean. Capped 8/16 (merit 15/16, pass ≥ 12/16).**
Single gating fail: U8. All other laws pass; tap counts pass; Airbnb merit passes.
Fix ownership is backend/product (filter terminal statuses from the assigned feed, or rename the section
to bless recently-completed inclusion) — logged in `docs/ui-redesign/LOGIC_FOLLOWUPS.md` §1 (open).
Frontend must not silently filter; no presentation change is asked for in this gate.

---

## The two answers

- **Would a first-time user know what to do in 3 seconds?** Yes. `idle_1.0_en_360x800`: greeting names
  them, hero says `6 inspections due today. Review what's urgent first. View jobs`, three plain tiles
  (`Scan vehicle`, `New job card`, `Approvals`) and the first urgent card with a chevron are all visible
  without scrolling. The next step is unambiguous: tap `View jobs` or the first card.
- **What would an Airbnb product designer reject here?** One thing: a `Completed · Yesterday` job card
  sitting under `Assigned work orders` (`hero-nothing` frame) — a done item in a to-do list breaks the
  "one status per card / actionable-first" contract and teaches the user the list can't be trusted.
  Secondary nits they'd flag but not gate on: the unexplained `6 due` vs `2 assigned` gap, and English
  backend values (`Branch A · Morning shift`) inside the Arabic frame.
