# Phase Shell-Fix Review — ui/integration-1 (fresh re-reviewer)

Scope: 12 PNGs in `docs/ui-redesign/baseline/after-shell-fix/` —
owner / tech / supervisor × en-1.0-360, ar-1.0-360, en-1.3-360, en-1.0-320.
Spec: `docs/ui-redesign/DESIGN_SPEC.md` C16 (~lines 495-510) + U0–U14 (~lines 513-542).
Gate: PASS ≥ 12/16. Any C16 violation caps at 10/16. Any U-law violation caps at 8/16.
No "non-gating" for U-law/hard-reject.

Reviewer stance: did not build or fix these shells. Static-PNG evidence only for
presentation; behaviour (tap targets, search routing) is inferred from affordances
and flagged where PNGs cannot confirm.

---

## 1. Region-by-region description (no judgement)

### 1A. Technician — Today (`tech_today_en_1.0_360x800.png`, `tech_today_ar_1.0_360x800.png`, `tech_today_en_1.3_360x800.png`, `tech_today_en_1.0_320x568.png`)

Top to bottom (en-1.0-360 reference):

1. AppBar row: left title "Today"; right cluster search magnifier, bell, circular avatar "OH". Thin hairline divider below.
2. Active-job card (bordered, rounded): left stack overline "Active job" (blue), title "Toyota Camry", plate chip "ABC 1234", status pill "● In Progress" (teal tint); right stack blue circular play button, "×" dismiss, chevron "›" below.
3. Content header block: large "Today", grey subtitle "Morning shift · Working", magnifier icon at far right of the title row.
4. Hero job card (elevated, rounded ~20): row 1 "Toyota Camry" left + "● In Progress" pill right; row 2 "JC-101" (grey, small) left + "ABC 1234" chip right; title "Replace brake pads"; grey "1 of 3 tasks completed" + blue progress bar; filled blue CTA "▶ Start next task"; outlined secondary "👁 Job details".
5. Quick-action row: three equal white tiles — "Tasks" (checklist icon), "Request part" (box icon), "Escalate" (red triangle icon).
6. Section header row: "Assigned queue" left, blue "View all" right.
7. First queue item (partially visible above bottom nav): highlighted row "Nissan Yaris" + red-tint pill "● 🕒 Delayed" + chevron, cut by the nav bar (top half visible at 1.0-360).
8. Bottom nav: four tabs — "Today" (active, blue), "Jobs", "Productivity", "Profile". Outlined icons.

Variants:

- ar-1.0-360: full RTL mirror. AppBar order mirrored (avatar/bell/search right-to-left, title "اليوم" at right). Active-job card mirrored (play left, texts right). Hero card mirrored. Strings: headings/buttons/nav translated ("بدء المهمة التالية", "تفاصيل المهمة", "المهام", "طلب قطعة", "تصعيد", "قائمة المهام المسندة", "عرض الكل"); entities stay English/LTR: "Toyota Camry", "Nissan Yaris", "In Progress", "Delayed", "ABC 1234", "JC-101", "Morning shift" mixed ("يعلمل · Morning shift"). Bottom nav Arabic labels, "اليوم" active.
- en-1.3-360: same regions; "Active job" block wraps to two lines (plate chip + pill stacked vertically); hero text larger; "Request part" tile label wraps to two lines ("Request" / "part"); bottom-nav "Productivity" label breaks across two lines as "Productivit" + "y"; queue section pushed below fold (not visible in capture).
- en-1.0-320 (568h): AppBar + active-job card + content header + hero card + start of quick-action row visible; bottom nav and queue below fold (not in capture). No horizontal overflow stripe visible; hero card fills width.

### 1B. Owner — Dashboard (`owner_home_en_1.0_360x800.png`, `owner_home_ar_1.0_360x800.png`, `owner_home_en_1.3_360x800.png`, `owner_home_en_1.0_320x568.png`)

Top to bottom (en-1.0-360 reference):

1. AppBar row: left title "Dashboard"; right cluster search magnifier, calendar icon (light-blue filled circle background, selected state), bell (filled black), avatar "O". Hairline divider.
2. Content header: title "Executive Operations Control" (single line at 1.0-360), grey subtitle "Real-time overview of branch performance, revenue, and active repair pipelines.", magnifier icon at far right of title row.
3. Status pills row (wrapping): "● Live operations" (blue tint), "● 12 active" (teal tint), "● 5 today" (green tint, second row).
4. Hero KPI card (full-width, bordered): left icon tile + overline "Revenue" + large "AED 84K"; right green delta "↑ +2.1% Ahead".
5. Two-column KPI grid: left "Margin" card (overline "Margin", icon tile top-right, large "18.4%", green "↑ +1.2% vs last week"); right "Bay occupancy" card (overline "Bay" / "occupancy" on two lines, icon tile top-right, large "12/16", green "↑ 4 bays free"). Below: left "Pending approvals" card (overline "Pending approvals" two lines, large "3", green "↑ 2 need decisions"); right column empty whitespace (no orphan tile — single card on second row, not a 2×2).
6. Conditional banner (peeking above bottom nav at 1.0-360): pale-yellow strip, brown text "3 waiting for owner review" (top edge only, cut by nav).
7. Bottom nav: four tabs — "Dashboard" (active, blue), "Top sales", "Messages", "Activity".

Variants:

- ar-1.0-360: RTL mirror. AppBar title "اللوحة" at right. Content header Arabic ("التحكم التنفيذي في العمليات" + subtitle), pills Arabic ("عمليات مباشرة", "12 نشطة", "5 اليوم"). Hero/grid overlines and deltas stay English: "Revenue", "AED 84K", "+2.1% Ahead", "Margin", "18.4%", "+1.2% vs last week", "Bay occupancy", "12/16", "4 bays free", "Pending approvals", "3", "2 need decisions". Banner fully visible: yellow card "بانتظار مراجعة المالك 3" + warning triangle + blue "عرض الكل". Bottom nav Arabic. Note grid order mirrored (Bay card left, Margin card right in RTL).
- en-1.3-360: title wraps to two lines ("Executive Operations" / "Control"); pills same; hero same; "Bay occupancy" overline renders as "Bay" / "occupan…" (truncated with ellipsis, mid-word); "Pending approvals" card pushed below fold; bottom-nav "Dashboard" label breaks as "Dashboar" + "d" across two lines.
- en-1.0-320 (568h): AppBar + header + pills + Revenue hero + Margin card (full-width stacked, Bay column off-screen/below) visible; bottom nav visible with four tabs intact. No red overflow stripe.

### 1C. Supervisor — Floor (`sv_floor_en_1.0_360x800.png`, `sv_floor_ar_1.0_360x800.png`, `sv_floor_en_1.3_360x800.png`, `sv_floor_en_1.0_320x568.png`)

Top to bottom (en-1.0-360 reference):

1. AppBar row: left title "Floor"; right cluster search magnifier, bell, avatar "S". Hairline divider.
2. Greeting block: grey overline "Thu, Oct 22"; large two-line title "Floor command, Supervisor"; green-tint pill "▦ 4/16 bays active".
3. Content header: large "Workshop floor", grey subtitle "4 active · 16 bays", magnifier icon at far right.
4. Instruction line: "Dispatch the next job into a free bay."
5. Single filled CTA: blue pill "🛠 Dispatch to technician" (icon + label, full-width).
6. Legend row: four dot+label items — green "Occupied", dark "Idle", orange "Parts delay", teal "QC".
7. Filter-chip row (horizontally scrollable): filled blue "All", outlined "Occupied", outlined "Parts delay", outlined "QC", plus a thin sliver of a fifth chip cut at the right viewport edge (clean peek).
8. Bay grid (2 columns): B-01 (pale blue, teal dot, "OH" avatar chip, "Yaris XYZ 5678", "JC-207  4/4"), B-02 (mint, green dot, "—" avatar, "Camry ABC 1234", "JC-101  2/5"), B-03 (pale yellow, orange dot, "Hilux XYZ 1111", "JC-900  1/4"), B-04 (mint, green dot, "Civic", "BK-301  10:00"), B-05/B-06 (grey idle, partial above nav).
9. Bottom nav: five tabs — "Floor" (active, blue), "Jobs", "Queue", "Review", "More" (three-dot icon).

Variants:

- ar-1.0-360: RTL mirror. AppBar title "الأرضية" at right. Greeting "الخميس، ٢٢ أكتوبر" + "قيادة الأرضية، Supervisor" (mixed Arabic + English "Supervisor"), pill "4/16 منصة قيد العمل". Content header "أرضية الورشة" + "4 قيد العمل · 16 منصة" + magnifier left. CTA "إسناد إلى فني". Legend/chips Arabic ("مشغولة", "شاغرة", "تأخّر قطع", "فحص الجودة", "الكل"). Bay cards mirrored; vehicle/plate/JC strings stay English/LTR ("Yaris XYZ 5678", "JC-207", "B-01", "OH", "10:00"). Bottom nav five Arabic tabs.
- en-1.3-360: same regions, larger text; title wraps to three lines ("Floor command," / "Supervisor"); chips and B-01/B-02 fully legible; bottom nav five tabs intact, labels complete.
- en-1.0-320 (568h): AppBar + greeting + header + CTA + legend + chips + top of B-01/B-02 visible above nav; no overflow stripe.

---

## 2. U0–U14 walk (with image + region evidence; residuals/STOP adjudicated)

Evidence key: [T]=tech, [O]=owner, [S]=supervisor.

- **U0 (never hunt/scroll/tap more than necessary).** [T] Primary job + CTA above fold at all sizes; queue behind "View all" — no hunt. [O] Revenue + 3 KPIs glanceable; approvals triage behind banner "View all". [S] Dispatch CTA + bay grid above fold; filters one-tap. No U0 violation on visible evidence. S1 (7-tab IA) does not force hunt in the capture — five visible slots, "More" holds overflow (see S1 adjudication below).
- **U1 (search icon top-right in header; full-screen search; never inline field).** PASS on header placement: all three AppBars carry a magnifier at top-right next to bell/avatar ([T]-AppBar, [O]-AppBar, [S]-AppBar). No inline text field anywhere — compliant. OPEN QUESTION (not a confirmed FAIL): each content header repeats a lone magnifier at the section-title row ([T]-§3, [O]-§2, [S]-§3). PNGs cannot prove routing. If both magnifiers open the same full search, that is a duplicate path (C16/U7/U9 issue — see §4). If the content-row icon is list-scoped while the AppBar icon is global, the affordance is ambiguous and needs a written brief note. Flagged as gating clarification, not auto-capped, because behaviour is unobservable in screenshots.
- **U2 (primary task first, visible above fold at 360×800 idle).** [T] Active-job card + hero "Start next task" fully visible at 1.0-360 and 320 — PASS (queue is secondary; its partial peek satisfies "more exists"). [O] "AED 84K" hero + Margin/Bay row visible at 1.0-360 — PASS. [S] "Dispatch to technician" + B-01/B-02 row visible at 1.0-360 — PASS. At 1.3× the fold naturally tightens ([T] queue below fold, [O] approvals below fold) — primary hero/CTA remains above fold in each, so U2 holds.
- **U3 (tap count; frequent ≤ 2, no regression).** Brief tap tables are not in the PNG set, so no before/after audit is possible here. Visible affordances are 1-tap: [T] Start/Details/Tasks/Request/Escalate/View-all; [S] Dispatch/chips/bays/Queue/Review; [O] banner View-all (confirmed in ar capture)/tabs. No evidence of added steps. No U3 FAIL on presentation; brief owner to confirm counts.
- **U4 (reachability: frequent create/scan in lower half or sticky).** [T] "Start next task" sits mid-screen in thumb zone; bottom nav within reach — PASS. [S] "Dispatch to technician" full-width above legend — PASS. [O] No create/scan task on this dashboard; triage banner sits just above nav (ar capture) — PASS.
- **U5 (no truncation of primary text; never "…" on primary; never cut mid-word; rows fit or peek cleanly).**
  - R1 adjudication — [O] `owner_home_en_1.3_360x800.png` §5: overline reads "Bay" / "occupan…" — ellipsis cutting an English word mid-segment ("occupancy" → "occupan…"). Fixer argues "secondary overline in a 2-col card where fold wins". REJECT the excuse as a PASS reason, ACCEPT as a correctly reported residual: (a) U5's third clause is literal — "never a label cut mid-word" — and "occupan…" is cut mid-word regardless of overline-vs-value hierarchy; (b) U14 independently requires 1.3× "without clipping", and this is the only card that truncates at 1.3× while its neighbour ("Margin") does not, so it is not a systemic fold trade-off but a card-level shortfall. It is secondary text (value "12/16" remains fully visible), so user impact is low, but under ALL GATE it is a genuine U5+U14 violation → caps the owner shell (see §4). GATING. Fix: allow the overline 2-line wrap at its current size, shorten the ARB-safe source to "Bays" / "Bay use", or stack the 2-col grid to 1-col at 1.3× — presentation-only, no logic change.
  - Additional U5 finding the fixer did not list — bottom-nav mid-word wraps at 1.3×: [T] `tech_today_en_1.3_360x800.png` §8 nav label renders "Productivit" / "y" (mid-word break); [O] `owner_home_en_1.3_360x800.png` §7 nav label renders "Dashboar" / "d". Both violate "never a label cut mid-word" (wrap, not ellipsis, but still a mid-word cut of a primary nav label) and U14. GATING for [T] and [O]. Fix options are presentation-only: shorten labels ("Stats"/"Home"), reduce nav font/allow autoscale, or confirm the new `AppBottomNav` handles 1.3× without word-break. [S] nav labels ("Floor/Jobs/Queue/Review/More") fit at all sizes — PASS.
  - Clean peeks (PASS): [S] chip row sliver at right edge shows next chip's leading edge — icon+label start pattern holds for a scroll row; [T] queue first-item peek shows title + pill start — acceptable "more exists" signal, not a mid-word cut.
  - Otherwise: headlines wrap to ≤ 2 lines ([S] "Floor command, Supervisor" 2 lines at 1.0, 3 lines at 1.3 — headline wrap, not truncation; [O] "Executive Operations Control" 1→2 lines — PASS); no "…" on any person name (no names in these shells); plates/IDs ("ABC 1234", "JC-101", "B-01") fully visible at 1.0/320/ar.
- **U6 (calm empty states).** All captures show data (in-progress job, 4 busy bays, live KPIs) — the filled CTAs lead somewhere that exists. No empty-state violation observable.
- **U7 (one path per task; "See all"/"View all" only when more exists).** [T] "Assigned queue" + "View all" with a peeking first item proving more exists — contract holds. [O] banner "View all / عرض الكل" (visible in ar; peeking in en) with 3 approvals behind it — contract holds. [S] no "See all" — filters + grid only — PASS. The duplicated magnifier (U1 note) is the only U7 question: if two icons open the same search, U7 fails. Pending behaviour confirmation.
- **U8 (relevance; actionable first; feed-caused disorder logged, never silently filtered).** No relevance inversion visible (active/in-progress first; no completed items under assigned). No silent filtering performed by this shell fix. No U8 FAIL.
- **U9 (consistency: same element, same place).** AppBar pattern is now consistent across roles (title left / LTR, search-bell-avatar right; mirrored in ar) — the migration claim is visibly true. Bottom-nav active-accent pattern consistent. The content-row magnifier repeats in the same relative place (section-title row, trailing) on all three shells — internally consistent, but its relationship to the AppBar search breaks "one element, one place" if co-functional (see U1). [S] nav destinations differ from [T]/[O] (5 vs 4 tabs, different labels) — acceptable role-specific IA, not a U9 element-placement violation (search/bell/avatar/CTA placement is what U9 governs).
  - S1 adjudication — supervisor 7-tab nav: the claim is "AppBar migrated but bottom nav KEPT (7 destinations vs AppBottomNav ≤ 5 — STOP S1, needs product IA)". Rendered evidence shows FIVE visible slots (`sv_floor_*`: Floor/Jobs/Queue/Review/More). `LOGIC_FOLLOWUPS.md` #8 confirms the 7-slot legacy `AppBottomNavigation` with More-overflow is intentionally kept with a STOP comment. Adjudication: the STOP is LEGITIMATE (consolidating 7 tasks to 5 named tabs changes IA and tap counts — a product decision, correctly refused presentation-only). It is NOT a C16-max-5 presentation FAIL as rendered: five slots are visible, satisfying "max 5" as drawn; the overflow lives behind "More", which is the specified pattern for >5 tasks, and only the AppBar half is claimed migrated. It does not gate this shell-fix PASS/FAIL on presentation. It REMAINS OPEN as a product/IA follow-up (LOGIC #8): product must confirm the 7-task IA (then More-overflow is the contract and the bar migrates only when the new `AppBottomNav` supports it) or consolidate to 5. No silent merge performed — correct.
- **U10 (feedback/forgiveness).** Static PNGs cannot confirm press feedback/undo. No destructive action presented without context. No U10 FAIL on evidence.
- **U11 (readable numbers).** Numbers big/tabular, labelled, decision-helpful: [O] "AED 84K / 18.4% / 12/16 / 3"; [S] "4/16 bays active / 4/4 / 2/5 / 10:00"; [T] "1 of 3 tasks completed / JC-101". Zero-as-"0" case not present. Fully visible except R1's overline (label, not number) — no U11 FAIL.
- **U12 (one background).** Single page background on all shells; bay/KPI cards are cards on that background, not stray bands. The blue queue-row highlight in [T]-1.0-360 is a selected-card fill, not a full-bleed strip. PASS.
- **U13 (new-employee test; plain words).** Owner bar-title swap adjudication: AppBar now reads "Dashboard" (from `ownerNavDashboard`) instead of a longer internal name. ACCEPTABLE — "Dashboard" is the plainest correct word, matches the active bottom-nav destination, and removes jargon. PASS. WIP acronyms adjudication: "JC-101", "B-01", "OH", "AED", "QC", plates ("ABC 1234 / XYZ 5678") are kept as-is. ACCEPTABLE as genuine acronyms/codes: plates and bay codes are identifiers users recognise (title = vehicle, IDs = small meta holds); "AED" is the standard currency code; "QC" rides with the plain-words legend "Parts delay" row and filter chip context. No invented expansion needed. PASS. "Dispatch to technician", "Start next task", "Assigned queue", "Workshop floor", "Pending approvals" all pass the 3-second test.
- **U14 (a11y: ≥48dp targets, AA, semantics, 1.3× and 320px without clipping).** No red overflow stripes in any of the 12 captures — the "0 overflow stripes" claim is CONFIRMED. 320px: [T]/[O]/[S] layouts reflow without horizontal clipping (owner grid stacks, tech hero fills, supervisor grid tops visible). 1.3×: EXCEPT the three mid-word breaks already capped under U5 ([O] "occupan…", [T] "Productivit y", [O] "Dashboar d"), no clipped CTA, pill, or card value. Those three are therefore joint U5+U14 gating items. Semantics/contrast cannot be judged from PNGs — no FAIL asserted there.
- **R2 adjudication (ar server labels English):** CONFIRMED present — [T]-ar keeps "In Progress", "Delayed", "Toyota Camry", "Nissan Yaris", "Morning shift"; [O]-ar keeps "Revenue", "Bay occupancy", "+1.2% vs last week", "Margin", "Pending approvals"; [S]-ar keeps "Supervisor", vehicle/plate/JC strings. This is FEED-owned (no ARB key; translating in presentation would invent copy), already logged as `LOGIC_FOLLOWUPS.md` #9 (same family as #2 advisor branch/shift). Per the U8-logging rule, a logged feed issue is NOT a presentation FAIL. Layout mirrors correctly (RTL, chips/pills/nav translated), so presentation did its job. NOT GATING. Remains open for backend/product (locale-aware labels or written confirmation that English codes are acceptable; plates/LTR-by-design already accepted).
- **Sentence-case / ALL-CAPS / banner claims:** CONFIRMED. No ALL-CAPS running text in any capture; pills/overlines read "Active job", "In Progress", "Live operations", "12 active", "5 today", "Bay occupancy", "Parts delay", "Occupied", "All" — sentence-case as claimed (residual ALL-CAPS grammar from `LOGIC_FOLLOWUPS.md` #7 is resolved on these shells; remaining codes are uppercase identifiers, not prose). No permanent "Synced" pill; the only banners are conditional (active-job card on [T], approvals banner on [O], none on [S] when normal) — abnormal-only holds.

---

## 3. Tap walk per role + search + Show-all contracts

Behaviour inferred from affordances (PNGs show placement, not routing).

- **Tech (1-taps):** "▶ Start next task" (hero CTA) = 1 tap to advance; "Job details" = 1 to drill; "Tasks" / "Request part" / "Escalate" tiles = 1 each; "View all" = 1 to full queue; bottom "Jobs / Productivity / Profile" = 1 each; AppBar search/bell/avatar = 1 each. Most-frequent-task (advance today's job) is 1 tap from launch state — satisfies U3 shape; no added step visible.
- **Supervisor (dispatch / queue / review = 1 = 1):** "Dispatch to technician" = 1; each filter chip ("All / Occupied / Parts delay / QC") = 1 to filter; each bay card (B-01…B-06) = 1 to drill; bottom "Jobs / Queue / Review / More" = 1 each. Dispatch-queue-review loop stays at 1 tap per hop — no regression visible.
- **Owner (glance / drill / triage):** glance = 0 taps (Revenue/Margin/Bay/Pending visible); drill = 1 (KPI card tap); triage = 1 (banner "View all / عرض الكل" to approvals queue — confirmed present in ar capture, peeking in en-1.0-360); tabs ("Top sales / Messages / Activity") = 1. No dense-grid drilling required.
- **Search (U1):** AppBar magnifier consistently top-right on all three roles (mirrored correctly in ar) — 1 tap to (claimed) full-screen search with recents/scan inside. No inline field. Contract met on placement; routing to be confirmed by the owning brief's tap table. The content-row magnifier ([T]-Today row, [O]-Executive row, [S]-Workshop row) must be disambiguated in the brief (same search vs list-scoped) — see §2-U1.
- **Show-all contracts:** [T] "Assigned queue … View all" shown WITH a peeking first queue item → more exists → link justified (U7 PASS). [O] approvals banner "View all / عرض الكل" shown WITH "3 waiting / 3 need decisions" copy → more exists → justified (U7 PASS). [S] no Show-all/See-all affordance alongside filters or tabs → no duplicate path (U7 PASS).

---

## 4. Rubric /16 (ONLY here — after evidence above)

Scoring: start 16; apply C16 cap (→10 max) and C17 cap (→8 max) per the spec's
"cap any violating screen" rule. Caps dominate deductions: a single U-law breach
caps the shell at 8 regardless of how clean the rest is. Reserves below are for
non-capping polish only.

### Tech — Today: 8/16 — FAIL (gating)

- Caps applied: U5 + U14 (C17 → max 8). Decisive evidence: `tech_today_en_1.3_360x800.png`
  bottom nav "Productivit" / "y" — primary nav label cut mid-word at 1.3×.
- C16: no hard-reject confirmed on pixels (no borders-light violation, no orphan tile,
  one filled CTA per section, no permanent sync pill, no ALL CAPS, first primary content
  above fold, clean queue peek). The dual-magnifier question is NOT capped here for the
  reason in §2-U1 (routing unprovable from PNGs) — carried as gating clarification #4 below.
- Reserves: −0 capped; polish note: "Request part" 2-line wrap at 1.3× is a clean wrap,
  not a violation.
- Gating to pass: (T1) fix 1.3× nav word-break (shorten label or nav autoscale —
  presentation-only); (T2) brief note confirming the two magnifiers are not duplicate
  paths (or remove/retarget one).

### Owner — Dashboard: 8/16 — FAIL (gating)

- Caps applied: U5 + U14 (C17 → max 8). Decisive evidence: `owner_home_en_1.3_360x800.png`
  "Bay" / "occupan…" (R1, label cut mid-word with "…") + bottom nav "Dashboar" / "d"
  (primary label cut mid-word). Either alone caps at 8.
- C16: no hard-reject confirmed (one CTA-equivalent per section — banner link is text, not
  a second filled tile; no duplicate list path; abnormal-only banner; sentence-case;
  hero above fold). Title "Dashboard" accepted (§2-U13). R2 English-in-ar explicitly NOT
  capped (logged feed issue, LOGIC #9).
- Gating to pass: (O1) fix R1 overline at 1.3× (2-line wrap / shorter ARB-safe copy /
  1-col at scale — presentation-only); (O2) fix 1.3× "Dashboard" nav word-break.
- Non-gating/LOGIC (correctly left open): overdue-AR banner absence (LOGIC #3), chart
  pills (LOGIC #4), approvals read-only (LOGIC #5) — all feed/contract, not shell-presentation.

### Supervisor — Floor: 13/16 — PASS (with open IA follow-up)

- Caps applied: none confirmed on pixels. Five visible nav slots satisfy max-5 as rendered;
  S1's 7-task IA lives behind "More" per the logged STOP (LOGIC #8) — legitimate product
  STOP, not a presentation cap (see §2-U9/S1). No U5/U14 truncation at 1.0/1.3/320/ar on
  any primary label; chips peek cleanly; no "…" anywhere; 320px reflows without stripe.
- Deductions (−3 reserves, non-capping): −1 content-row magnifier ambiguity shared with the
  other shells (needs the same brief note); −1 greeting mixes "Supervisor" English inside
  the ar title ("قيادة الأرضية، Supervisor") — feed-copy, same family as R2, logged pattern,
  layout intact so not capped but noted; −1 "Civic / BK-301 / 10:00" card leans on a time
  where others show progress (feed-shape inconsistency worth a brief line, not a law breach).
- Gating to KEEP passing: none on presentation. Open (not gating this shell): (S1) product IA
  decision on 7 tasks vs 5 tabs (LOGIC #8) before the bar migrates to `AppBottomNav`;
  (S2) same magnifier-clarification note as T2.

### Overall: FAIL — 2 of 3 shells below gate

- Tech 8 FAIL + Owner 8 FAIL + Supervisor 13 PASS → integration shell-fix does NOT clear
  the ≥12/16 gate. The round-2 fixer's confirmed wins (0 stripes, sentence-case,
  AppBar migration, abnormal-only banners, title swap, WIP/ARB discipline) are real and
  retained — but R1 + the two 1.3× nav word-breaks are genuine U5/U14 breaches under
  ALL GATE and must be fixed presentation-only. S1 and R2 are correctly held open as
  LOGIC/product items and do not block on presentation.

Remaining gating items (presentation-only, any shell owner can take):

1. R1 — owner "Bay occupancy" overline "occupan…" at 1.3× (U5/U14). Fix in shell/KPI card.
2. Tech bottom-nav "Productivity" → "Productivit y" at 1.3× (U5/U14).
3. Owner bottom-nav "Dashboard" → "Dashboar d" at 1.3× (U5/U14).
4. Brief-level clarification for all three shells: AppBar magnifier vs content-row magnifier —
   confirm single search path (or retarget/remove the content-row icon). If both open the same
   search, it becomes a C16-duplicate/U7/U9 cap.

Open LOGIC/product items (not gating presentation, tracked in `LOGIC_FOLLOWUPS.md`):

- S1 supervisor 7-task IA vs 5-slot bar (#8) — needs product IA decision.
- R2 English server labels in ar (#9) + ar branch/shift (#2) — needs locale-aware feed or written
  acceptance (plates/LTR already accepted by design).
- Owner AR signal (#3), chart pills (#4), approvals endpoints (#5) — backend/product contracts.

---

## Round-3 verdict — final shell confirm (appended, earlier rounds kept intact)

Scope: same 12 PNGs in `docs/ui-redesign/baseline/after-shell-fix/` (owner / tech / supervisor × en-1.0-360, ar-1.0-360, en-1.3-360, en-1.0-320), regenerated with owner + tech frame fixes. Reviewer stance unchanged: did not build or fix; static-PNG evidence for presentation, behaviour inferred from affordances.

### R1 — owner single-column at 1.3×: FIXED, CONFIRMED
- `owner_home_en_1.3_360x800.png` §grid: pods are now SINGLE column, full-width stacked — "Margin" card (overline "Margin" whole, "18.4%", "+1.2% vs last week") then "Bay occupancy" card (overline "Bay occupancy" whole on ONE line, "12/16" whole). No "occupan…", no ellipsis, no mid-word cut. U5+U14 breach from round-2 is gone.
- `owner_home_en_1.0_360x800.png` §grid: 2-col intact — "Margin" + "Bay occupancy" side by side, "Pending approvals" second row, Revenue hero ("AED 84K") + header + pills + banner peek ("3 waiting for owner review") all above fold. Fold contract holds at 1.0×.
- R1 gating item CLOSED.

### R2 — nav word-breaks: FIXED, CONFIRMED (all shells, 1.3× + 320 + ar)
- `tech_today_en_1.3_360x800.png` §nav: four labels single-line whole — "Today" / "Jobs" / "Productivity" / "Profile". Previous "Productivit"+"y" mid-word break GONE. No "…" anywhere in frame.
- `owner_home_en_1.3_360x800.png` §nav: four labels single-line whole — "Dashboard" / "Top sales" / "Messages" / "Activity". Previous "Dashboar"+"d" GONE. No "…" anywhere in frame.
- 320px: `tech_today_en_1.0_320x568.png` nav "Today/Jobs/Productivity/Profile" whole; `owner_home_en_1.0_320x568.png` nav "Dashboard/Top sales/Messages/Activity" whole. No break, no "…", no horizontal overflow stripe.
- ar mirrored: `tech_today_ar_1.0_360x800.png` four Arabic nav labels whole; `owner_home_ar_1.0_360x800.png` four Arabic nav labels whole; `sv_floor_ar_1.0_360x800.png` five Arabic nav labels whole. RTL mirror intact.
- Supervisor en nav ("Floor/Jobs/Queue/Review/More") whole at 1.0×/1.3×/320× as before.
- Appearance (slightly reduced label size at 1.3× vs 1.0×) is consistent with the claimed single-line FittedBox scaleDown. R2 gating items CLOSED.

### R3 — duplicate magnifiers: DOCUMENTED SINGLE PATH, not capped
- Frames still show two magnifier affordances per shell (AppBar top-right + content-title-row trailing): [T]-AppBar + Today-row, [O]-AppBar + Executive-row, [S]-AppBar + Workshop-row. No inline text field anywhere — U1 placement holds.
- Plausibility from frames: both icons present, identical magnifier glyph, no search field pushing content — consistent with a single search entry point rendered twice.
- Per round-3 brief: code-verified same target per shell (tech `showTechnicianTodaySearch`, supervisor `showSupervisorFloorSearch`, owner `openOwnerSearch`) — ONE path, document-only. PNGs cannot prove routing, so this is recorded as a documented single path, NOT a C16-duplicate/U7/U9 cap. No judgement of code; noted as documented, not capped. R3 gating clarification CLOSED on that basis (reopen only if routing later proves two distinct searches).

### U0–U14 walk, focused on shells (image + region evidence)
- **U0:** [T] primary job + CTA above fold all sizes; queue behind "View all". [O] Revenue + Margin/Bay glanceable at 1.0×; single-column stack at 1.3× keeps Revenue + Margin above fold, Bay follows — no hunt. [S] Dispatch CTA + B-01/B-02 above fold. S1 five visible slots + "More" overflow — no hunt. PASS all.
- **U1:** AppBar magnifier top-right on all three shells, mirrored in ar. No inline field. Content-row magnifier per R3 = documented same-target second affordance, one path. PASS (documented).
- **U2:** [T] Active-job + hero "Start next task" above fold at 1.0×/1.3×/320×/ar. [O] "AED 84K" hero above fold at all sizes; 2-col row above fold at 1.0× (fold rule met where it applies). [S] "Dispatch to technician" + B-01/B-02 above fold at all sizes. PASS all.
- **U3 (tap walk unchanged):** tech 1-taps (Start next task / Job details / Tasks / Request part / Escalate / View all / tabs); supervisor 1=1=1 (Dispatch / chips / bay cards / Queue / Review); owner glance-0/drill-1/triage-1 (banner "View all / عرض الكل" confirmed in ar, peeking in en-1.0×). No added steps visible. PASS.
- **U4:** [T] "Start next task" mid-screen thumb zone. [S] Dispatch full-width above legend. [O] triage banner just above nav (ar fully visible). PASS.
- **U5:** No mid-word cut, no "…" on any primary label in any of the 12 frames. [O]-1.3× "Bay occupancy" whole (R1 fixed). Navs whole (R2 fixed). Clean wraps only: [T]-1.3× "Request part" → "Request"/"part" (word-boundary wrap, not a violation); [O]-1.3× title → 2 lines; [S] title 2 lines ("Floor command,"/"Supervisor"). Clean peeks: [S] chip-row sliver, [T] queue first-item peek. Plates/IDs whole. PASS all.
- **U6:** All captures show data; filled CTAs lead somewhere that exists. No empty-state violation. PASS.
- **U7:** [T] "View all" with peeking queue item → justified. [O] banner "View all / عرض الكل" with "3 waiting / 3 need decisions" → justified. [S] no Show-all. R3 single-path documented → no duplicate-path fail. PASS.
- **U8:** Actionable first; no relevance inversion; no silent filtering by this shell fix. PASS.
- **U9:** AppBar pattern consistent (title LTR-left / magnifier-bell-avatar right; mirrored ar). Bottom-nav active-accent consistent. Role-specific destinations (4 vs 4 vs 5 tabs) = IA, not placement violation. S1 STOP stands as LEGITIMATE (5 visible slots satisfy max-5 as rendered; 7-task IA behind "More" per LOGIC #8; product IA decision open, not a presentation cap). PASS.
- **U10:** No destructive action without context; press feedback not PNG-provable — no FAIL asserted. PASS on evidence.
- **U11:** Numbers big/tabular/labelled/decision-helpful: [O] "AED 84K / 18.4% / 12/16 / 3"; [S] "4/16 bays active / 4/4 / 2/5 / 10:00"; [T] "1 of 3 tasks completed / JC-101". Fully visible. PASS.
- **U12:** One page background per shell; bay/KPI cards on that background; no stray bands. PASS.
- **U13:** Title swap ("Dashboard") + WIP acronyms ("JC-101", "B-01", "AED", "QC", plates) stand as ACCEPTED per round-2 (plainest correct words / genuine codes). "Dispatch to technician", "Start next task", "Assigned queue", "Workshop floor", "Pending approvals" pass 3-second test. PASS.
- **U14:** Zero red overflow stripes in all 12 captures — confirmed. 320px reflows without horizontal clipping (owner stacks, tech hero fills, sv grid tops visible). 1.3×: no clipped CTA/pill/card value; the three round-2 mid-word breaks are gone. Semantics/contrast not PNG-provable — no FAIL asserted. PASS all.

### Rubric /16 (final)
- **Tech — Today: 16/16 — PASS.** Caps lifted (nav whole at 1.3×/320×; no "…"). C16 clean (one filled CTA per section, abnormal-only banner, sentence-case, clean queue peek, fold met). R3 documented single path, not capped.
- **Owner — Dashboard: 16/16 — PASS.** Caps lifted (single-column pods at 1.3×, "Bay occupancy" whole; nav whole). C16 clean (banner link is text, not second filled tile; abnormal-only; hero above fold at 1.0×). R1/R2 closed.
- **Supervisor — Floor: 15/16 — PASS (open IA follow-up only).** No caps (five visible slots; no truncation at any size; 320px clean). −1 reserve (non-capping): B-04 "Civic / BK-301 / 10:00" mixes a time where sibling cards show progress — feed-shape note for the brief, not a law breach. S1 remains legitimate STOP / LOGIC #8 product decision; R2 English-in-ar remains feed-owned LOGIC #9.
- **Overall: PASS — 3 of 3 shells clear the ≥12/16 gate.**

Remaining gating items: NONE. Standing open items are LOGIC/product-owned, not shell-gating: S1 7-task IA (#8), R2 locale labels (#9 + #2 family), owner AR signal (#3), chart pills (#4), approvals endpoints (#5).
