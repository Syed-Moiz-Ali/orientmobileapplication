# Adversarial Review — CRM Sales Team List (ui/list-crm)

**Role:** adversarial reviewer. Assume NOT Airbnb-level. Hunt defects.
**Worktree:** `wt-crm` (branch `ui/list-crm`). No checkout/commit/push performed. No touch of `71983229`.
**Screen brief:** `docs/ui-redesign/briefs/crm-sales-team-list.md` (list family; AppPageHeader + ranked rows, view-only, no search per reasoned U1 exception, borderless cards + AppAvatar + AppStatusChip stat pills + AppProgressBar, calm action-less empty).
**References:** EMPTY — `docs/ui-redesign/references/` does not exist; `AIRBNB_PATTERNS.md` missing repo-wide (brief §References confirms dependency UNMET, proceeded on precedent). No reference-based claims made.
**Governance:** REDESIGN MANDATE + C16 hard-reject (caps 10/16) + U0–U14 per C17 (`DESIGN_SPEC.md` C16–C17; brief §§U-laws is authoritative application). Any U-law fail caps at 8/16. Pass bar ≥12/16.
**Images inspected (Read, 9 files):**
- `docs/ui-redesign/baseline/after-crm-sales-team/team_idle_light_1.0_en_360x800.png`
- `docs/ui-redesign/baseline/after-crm-sales-team/team_compare-4_light_1.0_en_360x800.png`
- `docs/ui-redesign/baseline/after-crm-sales-team/team_scrolled_light_1.0_en_360x800.png`
- `docs/ui-redesign/baseline/after-crm-sales-team/team_empty_light_1.0_en_360x800.png`
- `docs/ui-redesign/baseline/after-crm-sales-team/team_idle_light_1.0_ar_360x800.png`
- `docs/ui-redesign/baseline/after-crm-sales-team/team_idle_light_1.0_en_320x568.png`
- `docs/ui-redesign/baseline/after-crm-sales-team/team_idle_light_1.3_en_360x800.png`
- `docs/ui-redesign/baseline/after-crm-sales-team/team_idle_light_1.0_en_768x1024.png`
- `docs/ui-redesign/baseline/phase-crm-sales-team-light.png` (BEFORE/AFTER comparator)
**Siblings checked for U9:** `phase-crm-leads-light.png`, `phase-crm-tasks-light.png`, `phase-6-vehicles-light.png`.

---
## Ranked defects (most severe first)

### 1. Ranked-by-revenue with identical revenue on all six rows — ranking meaningless — U8 + U11
**Evidence:**
- `team_idle_...`: `Sara #1 AED 12000`, `John #2 AED 12000`, `Mia #3 AED 12000` (same green ink, same value).
- `team_compare-4_...`: adds `Omar #4 AED 12000` (same). `team_scrolled_...`: `Mia #3`, `Omar #4`, `Lina #5 AED 12000`, `Kris #6 AED 12000` — all six `AED 12000`. Header in every frame: `Ranked by revenue won this period.`
**Law/criterion:** U8: RELEVANCE — actionable/ordered items first; order must mean something. U11: "stats are shown only if they help a decision." Brief §U8: feed order untouched — but pixels prove feed order cannot be revenue order if all revenues tie.
**What fails:** Core promise broken: user asked "who leads" gets six-way tie with forced `#1`–`#6` badges. Either fake data hides real ordering (then goldens prove layout, not decision-helping) or real feed ties and rank is arbitrary — both need `LOGIC_FOLLOWUPS.md` note + tie-break display per brief U8, not silent badges. A manager comparing Sara vs Lina sees same revenue but different ranks with no explanation.
**GATES (strict): YES — U8 (and U11 decision-helping), caps at 8/16.**

### 2. Numbers unreadable/unlabeled: glued currency, no separators, revenue has no label — U11 + C11
**Evidence:** Every card in every content frame: `AED 12000` (no comma, no `12,000` grouping, currency glued with space only). No `Revenue`/`Value` label next to it — only `#n` pill + green figure. `team_idle_ar_...`: same `AED 12000` LTR. Tablet `team_idle_768...`: same. BEFORE side in `phase-crm-sales-team-light.png` also shows `AED 12000` — migration did not fix formatting.
**Law/criterion:** U11: "READABLE NUMBERS: stats have labels, are fully visible." C11: "Numbers: thousands separators, consistent decimals, explicit +/- on deltas, currency symbols, relative time via central formatters only."
**What fails:** `12000` vs `13000` comparison gets ungrouped 5-digit string with no `12,000` grouping and no `Revenue` label — user must infer from subtitle that green figure is revenue. Stat blocks below DO have labels (`Leads`/`Won`/`Win Rate`) — revenue does not. Search-less triage therefore leans on an unlabeled, unformatted number.
**GATES (strict): YES — U11, caps at 8/16.**

### 3. No find-aid on a 6-row scrolling roster; U1 exception disproven by pixels — U1 + U2
**Evidence:**
- Zero search affordances in all 8 frames. `team_compare-4_...` shows 4 cards; `team_scrolled_...` shows list scrolled (top card `Mia #3` clipped at stat row, bottom `Kris #6` cut at stat blocks) — 6 rows do NOT fit 360×800 without scrolling.
- Brief §U1 claims "3–8 rows fit 360×800; fully visible without scrolling" — scrolled frame itself disproves it.
**Law/criterion:** U1 (search icon top-right opening full-screen search; same placement every list) + family >5 search-sheet rule applied on tasks/leads. U2: first actionable item above fold.
**What fails:** Once roster hits 6, user hunting "Omar → 0 Won" must scroll-hunt with no find path, while sibling lists (>5) DO get a search sheet. The reasoned exception (no destinations, fits one screen) collapses: rows may have no destinations but comparison IS the find task, and 6 does not fit. Either apply family >5 sheet or document why 6-user scroll beats 2-tap search — brief files it as "follow-up, not built" without pixel proof.
**GATES (strict): YES — U1 fail, caps at 8/16.**

### 4. Empty has no header — user loses place, no context — U0 + U6 + C9
**Evidence:** `team_empty_light_1.0_en_360x800.png`: centered pale circle with group glyph + `No salespeople yet` + `Team members appear here once added.` No `Leaderboard` title, no `Ranked by…` subtitle, no count, no actions anywhere in frame. All content frames DO have `Leaderboard` header.
**Law/criterion:** C9 screen skeleton (AppBar/large title + body); U0: user must know "what is this, what is happening, what can I do next" in 5 seconds; U6 calm empty still lives under header.
**What fails:** Empty removes the only orientation (`Leaderboard`) — deep-linked or tab-switched user sees a floating icon with no screen name, no back/title context. Calm action-less posture itself matches brief (no roster to create from here — correct), but header must persist. Compare tasks empty (`Tasks` title kept, subtitle hidden) — team drops even the title.
**GATES (strict): YES — U0, caps at 8/16.**

### 5. Missing states: no skeleton, no error, no offline/stale, no refresh proof — U10 + C10
**Evidence:** Folder inventory (8 PNGs): `idle`, `compare-4`, `scrolled`, `empty`, `ar`, `320`, `1.3x`, `tablet`. Zero files for `loading`, `error`, `offline/stale`. Brief §Matrix requires only empty/with-data/ar/1.3x/320px — loading/error required by §U6/C10 have no image. No `RefreshIndicator`/pull affordance visible (brief says none exists today — none added).
**Law/criterion:** C10 (every data screen implements loading/empty/error/offline/stale/refresh); U10: "errors say what to do next."
**What fails:** Cannot verify skeleton mirroring, `AppErrorState + Try again`, or `AppBanner` stale-keeping. View-only does not exempt data-fetch failure — failed `salesTeam` fetch would blank the list with no pixel-proven recovery. Tap retry therefore has zero evidence.
**GATES (strict): YES — U10, caps at 8/16.**

### 6. AR leaves role untranslated; revenue/name handling inconsistent — C15 + U13
**Evidence:** `team_idle_light_1.0_ar_360x800.png`, card rows: title right-aligned `لوحة الصدارة` + `مرتبة حسب الإيراد المحقق هذه الفترة.` translated, stat labels `العملاء`/`الرابح`/`معدل الفوز` translated, progress mirrored (fill grows from right — correct). But `Sara`/`John`/`Mia` + `Closer` + `#1`/`AED 12000` stay Latin. `Closer` is a role word, not a person name or currency code — same row translates `Leads`→`العملاء` but not `Closer`.
**Law/criterion:** U13 (plain words newcomer understands in 3s) + C15 (no untranslated user-visible strings; LTR-lock codes/names, translate roles/labels; `tm*` verbatim does not cover English role in Arabic UI).
**What fails:** Arabic reader sees English `Closer` three times with no Arabic equivalent. Names/`AED` LTR-lock is correct; role is not a code. Mirroring itself passes, copy does not — l10n sign-off blocked. Same server-label pattern as tasks `High` (Defect 5 there) — systemic.
**GATES (strict): YES — U13, caps at 8/16.** (If `Closer` pinned as server enum, still needs localized display per C11 glossary rule.)

### 7. Card buries lead: 3 stat blocks + bar = 4 signals, bar misleads rank — U0 + C8
**Evidence:** `team_idle_...` Sara card: top row avatar + `Sara/Closer` + `#1` + `AED 12000`; middle 3 pale blocks `4 Leads`/`3 Won`/`75% Win Rate`; bottom full-width blue bar ~75%. `team_scrolled_...` Lina `#5` bar ~80% LONGER than Sara `#1` 75% — highest bar belongs to #5. Omar `#4` bar empty (invisible track only). No label row above bar (`AppProgressBar` spec wants label row "0% of 10%").
**Law/criterion:** U0: one card = one primary focus; C16: one status per card; C8 `AppStatTile`/`AppProgressBar` (label above value, label row above bar); C11 STATUS PATTERN (one dot + one sentence why).
**What fails:** Bars encode win-rate while rank encodes revenue (tied) — longest bar (#5 Lina 80%) outranks visual hierarchy of #1. User glancing at bars misreads standings. Three blocks + bar with no why-sentence ("why 33% vs 75%?") is decoration, not triage. Component also off-spec (no label row, no caption).
**GATES (strict): NO independent cap — design-smell / rubric deduction subsumed by U8/U11 caps above; cited for fix (label bars, tie-break sentence, or drop bar).**

### 8. Sibling consistency fails — U9 (supporting, non-independent cap)
**Evidence:** vs `phase-6-vehicles-light.png` AFTER (hero image + `Toyota Camry` title + plate badge + `Booked` pill + `View` + sticky bar); vs `phase-crm-tasks-light.png` AFTER (left radio + title + meta + pill + edit/delete top-right, header with refresh/Add + conditional search); vs `phase-crm-leads-light.png` AFTER (no avatar, `Call` + `···` bottom-left). Team: avatar + name/role + rank + revenue + 3-stat grid + bar, zero actions.
**Law/criterion:** U9: same element same place; C9 list + C8 shared atoms.
**What fails:** Identity visual left is consistent (avatar/radio/hero — good), but primary-action placement has no grammar (trailing-right vs bottom-left vs none vs bar). Header grammar diverges (team zero actions, tasks refresh/Add + conditional search, leads search/filter/kanban/Add). `AED 12000` green ink matches tasks/leads value color — consistent, good — but unformatted everywhere (Defect 2 systemic).
**GATES (strict): NO independent cap — subsumed by U1/U11 caps; cited for fix, not additional cap. Untranslated `Closer` alone would block l10n.**

---
## Tap walkthrough (brief budgets vs observed)

| Task | Budget | Observed path | Verdict |
|---|---|---|---|
| Open standings | ≤1 | nav Sales team tab (shell, not in crops; assumed kept) | PASS (unverified in images, no counter-evidence) |
| Compare members | 0 taps (scroll only) | `compare-4` 4 ranked rows glance-comparable; `scrolled` rows 3–6 with `#4/#5/#6` grey badges + bars/figures | PASS on count, FAIL on triage (Defects 1–2: tied revenue + unlabeled figure + misleading bars force extra cognitive taps) |
| Find member (implicit) | — (brief: no find-aid) | 6 rows require scroll (`scrolled` proves overflow); no search/filter/jump | FAIL (Defect 3 — family >5 rule not applied) |
| Retry on failure | — | no error/loading/offline PNG; no refresh affordance | FAIL (Defect 5 — no evidence) |

## C16 hard-reject checklist (each item)

- [x] Light cards borderless (soft shadow/flat): PASS — blue outline borders + gradient avatars + tinted washes in BEFORE gone in AFTER comparator.
- [x] No gradients: PASS — flat lavender `AppAvatar` replaces dark-green gradient.
- [ ] No orphan tiles / carousel peek: N/A (list, not tiles; no carousels).
- [ ] Exactly ONE filled accent per section: PASS (rows have zero filled accents; bars are progress, not CTA).
- [ ] No permanent status pills / badges covering icons: PASS (rank `#n` is content, not sync chrome; no badges).
- [ ] ALL CAPS / number duplication: PASS — sentence case (`Leaderboard`, `Win Rate`), no shouting.
- [x] FAIL (scope, not pattern) — Search = one top icon → sheet: pattern correctly absent per brief exception, but exception disproven by 6-row scroll (Defect 3). **U1 caps 8/16.**
- [ ] Above-the-fold rule (first row above bottom nav at 360×800 idle): PASS — header + Sara `#1` complete in idle/compare; 320 intact.
- [ ] Hierarchy (name → rank → figures): PASS on structure every card incl. AR mirror; FAIL on meaning (Defect 1 tied revenue makes rank arbitrary — U8 content fail, not C16 structural fail).

## Score

- Start 16. Defects 1 (U8/U11), 2 (U11), 3 (U1), 4 (U0), 5 (U10), 6 (U13) each independently cap at **8/16** per C17. Strictest governs.
- **Final: 5/16 — FAIL (bar ≥12/16).**
- Rationale for 5 rather than 8: cap is ceiling, not floor. Six independent U-law fails (meaningless rank order, unlabeled/unformatted numbers, missing find-aid on scrolling roster, headerless empty, missing error proof, untranslated role) + misleading bars (longest bar = #5) + no loading/error/offline goldens. An 8 would imply one slip in an otherwise Airbnb screen; this is a calm, clean leaderboard whose core answer ("who leads?") cannot be trusted (all `AED 12000`) and whose 6th member is unreachable without hunt.
- To pass (≥12): fix Defects 1–6 (real differentiated revenue or honest tie-break display + `LOGIC_FOLLOWUPS` note; `AED 12,000` grouping + `Revenue` label; family >5 search sheet or documented one-screen proof with real 8-row data; keep `AppPageHeader` on empty; skeleton + error + offline PNGs + refresh contract; translate `Closer`/roles + audit verbatim rule), re-shoot all 8 + new loading/error/offline PNGs.

*Adversarial stance kept: every defect tied to named image region + exact C16/U-law clause + explicit GATES marking. No reference claims (references EMPTY). No logic changes proposed; presentation-only fixes.

---

# ROUND-2 VERDICT (fresh eyes, did not fix) — 2026-10-22

Worktree: wt-crm branch ui/list-crm. No checkout/switch/commit/push/merge, no touch of 71983229, no writes outside this worktree.
Current PNGs verified (8/8 in after-crm-sales-team): idle_360, compare-4, scrolled, empty, idle_ar, idle_320, idle_1.3x, idle_768. Code: no AppFormatters usage on this surface (grep: only crm_leads_page.dart).

## Fixer claims verified
- Team empty header kept: FIXED. team_empty now shows Leaderboard + Ranked by revenue won this period. above icon/title/message. Round-1 U0 headerless-empty cap LIFTED.

## Remaining gating (strict)
1. U8/U11 rank vs revenue: all six rows AED 12000 (no comma, no Revenue label) with forced #1-#6 badges; header Ranked by revenue contradicted by six-way tie. compare-4 + scrolled prove it. Caps 8/16. Not fixed (no AppFormatters, no tie-break note).
2. U11 numbers: AED 12000 ungrouped everywhere incl AR/tablet; BEFORE had same, migration did not fix. Caps 8/16. Glossary rebuttal (AED must stay LTR) CORRECT for code but grouping still required.
3. U1 find-aid: zero search in 8 frames; 6 rows do NOT fit 360x800 without scroll (scrolled frame proves overflow: Mia #3 clipped, Kris #6 cut). Reasoned no-search exception disproven by pixels. Family >5 sheet applies. Caps 8/16.
4. U10 states: zero loading/error/offline PNGs; no refresh affordance. Caps 8/16. STOP rebuttal WRONG (presentation states, not logic).
5. U13 AR role: ar frame Sara/John/Mia + Closer + #n stay Latin; stat labels translated but Closer (role word) not. Mirroring correct, copy not. Caps 8/16. Rebuttal ar-verbatim-glossary WRONG for roles (names/currency LTR-lock correct; Closer/High/Active are user labels needing localization; tasks عالية proves pattern).
- Bars: longest bar = #5 Lina 80% vs #1 Sara 75% — visually misreads standings but per spec winRate.clamp; cited as design-smell, non-independent cap (subsumed by U8/U11). Rebuttal bars-per-spec CORRECT on implementation, defect remains as non-gating smell.

## Condensed regression
Open ≤1 PASS. Compare 0 taps PASS on count, FAIL on triage (tied revenue + unlabeled figure + misleading bars force extra cognition). Find implicit FAIL (scroll-hunt, no aid). Retry no evidence FAIL.

## Rubric
Merit 12/16 (calm clean leaderboard, borderless/flat-avatar wins) but core answer untrusted. C16 PASS (no hard-reject triggered). C17 U8/U11/U1/U10/U13 each cap 8/16.

Score: 6/16 — FAIL (bar 12/16). Verdict: NOT CLEAR. Remaining gating (round-2): U8, U11, U1, U10, U13.*

---

# ROUND-3 VERDICT (fresh eyes, did not fix) - 2026-10-22

Worktree: `wt-crm` branch `ui/list-crm`. No checkout/switch/commit/push/merge, no touch of 71983229, no writes outside this worktree.
Current PNGs verified (9/9 in after-crm-sales-team): idle_360, compare-4, scrolled, empty, idle_ar, idle_320, idle_1.3x, idle_768, search-open (NEW). Code read-only: crm_sales_team_page.dart moneyAED via AppFormatters (l.30) + `t.tmRevenue` (l.310) + `showFindAids = team.length > 5` (l.64) + `showSearch: showFindAids` (l.121) / empty `showSearch: false` (l.93); l10n gen tmRevenue en `Revenue` + ar `الإيراد`, tmSearchTitle `Search team`.

## Wave-2 fixes verified
- F7 team revenue: FIXED (formatting) on pixels. Every card (idle/compare-4/scrolled/tablet) shows `Revenue` label above green `AED 12,000` grouped; AR shows `الإيراد` + `12,000 د.إ` grouped (moneyAED LTR-correct). New tmRevenue key confirmed in code + pixels. U11 numbers sub-defect (label + grouping) LIFTED.
- F8 team search: FIXED (existence + condition) on pixels + code. NEW team_search-open sheet: `Search team` + `Search by name or role` + 6 avatar rows (Sara/John/Mia/Omar/Lina/Kris). idle_360 (3 rows) and compare-4 (4 rows) correctly show NO search; scrolled (6 rows) background dim shows search magnifier top-right; code `> 5` gates it; empty has no search. Same >5 family rule now holds. RTL mirror structurally correct (AR avatar right, revenue left, progress grows from right).
- F10 intact: team_empty keeps `Leaderboard + Ranked by...` header above calm action-less empty (U0 headerless cap stays lifted).
- F6 plain-Row (team): _TeamHeader is single Row title + search top-end when >5 (code ll.153-215); scrolled/search-open backgrounds show search top-right same row as title. No AR >5 PNG to prove search top-start in RTL - unproven, noted.

## Remaining gating (strict)
1. U8 rank vs revenue: all six rows `AED 12,000` with forced #1-#6 badges; header `Ranked by revenue won this period` contradicted by six-way tie (compare-4 + scrolled prove it). F7 fixed formatting, not ordering. No tie-break sentence, no LOGIC_FOLLOWUPS note in UI. Caps 8/16. Tie-math is real gating, not fixture excuse.
2. U1 placement: find-aid now EXISTS when >5 (progress), but icon sits in page header, not C17 shell header "next to notifications/avatar". Strict placement still FAILS. Caps 8/16. Family >5 sheet cures scroll-hunt; placement cap remains.
3. U10 states: zero loading/error/offline PNGs in 9-file set; no refresh affordance. Caps 8/16. STOP rebuttal stays WRONG (presentation states, not logic).
4. U13 AR role: ar frame Sara/John/Mia + `Closer` + #n stay Latin; stat labels + `الإيراد` translated but `Closer` (role word) not. Mirroring correct, copy not. Caps 8/16. Glossary rebuttal SPLIT: names/currency LTR-lock CORRECT; Closer/Active/High as user labels need localization (tasks-`عالية` proves pattern), so role part stays WRONG and gating.
- Bars: longest bar = #5 Lina 80% vs #1 Sara 75% still visually misreads standings, but per-spec winRate.clamp implementation - cited as non-independent design smell, subsumed by U8.

## Condensed regression
Open <=1 PASS. Compare 0 taps PASS on count, FAIL on triage (tied revenue forces extra cognition despite grouped figures). Find implicit now ASSISTED when >5 (sheet), placement FAIL strict. Retry no evidence FAIL.

## Rubric
Merit 13/16 (calm clean leaderboard, borderless/flat-avatar wins, Revenue label + grouping, search sheet added) but core answer untrusted. C16 PASS (no hard-reject triggered). C17 U8/U1/U10/U13 each cap 8/16 (U11 lifted by F7).

Score: 8/16 - FAIL (bar 12/16). Verdict: NOT CLEAR. Remaining gating: U8, U1, U10, U13.
