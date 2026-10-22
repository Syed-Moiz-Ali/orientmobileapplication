# Adversarial Review — CRM Leads List (ui/list-crm)

**Role:** adversarial reviewer. Assume NOT Airbnb-level. Hunt defects.
**Worktree:** `wt-crm` (branch `ui/list-crm`). No checkout/commit/push performed. No touch of `71983229`.
**Screen brief:** `docs/ui-redesign/briefs/crm-leads-list.md` (list family; AppPageHeader + header search-icon-only-when->5 + filter sheet + borderless cards + Call-direct + kanban/table kept on medium+).
**References:** EMPTY — `docs/ui-redesign/references/` does not exist; `AIRBNB_PATTERNS.md` missing repo-wide (brief §References confirms dependency UNMET, proceeded on precedent). No reference-based claims made.
**Governance:** REDESIGN MANDATE + C16 hard-reject (caps 10/16) + U0–U14 per C17 (`DESIGN_SPEC.md` C17); any U-law fail caps at 8/16. Pass bar ≥12/16.
**Images inspected (Read, 11 files):**
- `docs/ui-redesign/baseline/after-crm-leads/leads_idle-6_light_1.0_en_360x800.png`
- `docs/ui-redesign/baseline/after-crm-leads/leads_idle-2_light_1.0_en_360x800.png`
- `docs/ui-redesign/baseline/after-crm-leads/leads_search-open_light_1.0_en_360x800.png`
- `docs/ui-redesign/baseline/after-crm-leads/leads_filter-open_light_1.0_en_360x800.png`
- `docs/ui-redesign/baseline/after-crm-leads/leads_empty-nocrm_light_1.0_en_360x800.png`
- `docs/ui-redesign/baseline/after-crm-leads/leads_empty-sync_light_1.0_en_360x800.png`
- `docs/ui-redesign/baseline/after-crm-leads/leads_idle-2_light_1.0_ar_360x800.png`
- `docs/ui-redesign/baseline/after-crm-leads/leads_idle-2_light_1.0_en_320x568.png`
- `docs/ui-redesign/baseline/after-crm-leads/leads_idle-2_light_1.3_en_360x800.png`
- `docs/ui-redesign/baseline/after-crm-leads/leads_idle-6_light_1.0_en_768x1024.png`
- `docs/ui-redesign/baseline/phase-crm-leads-light.png` (BEFORE vs AFTER comparator)
**Siblings checked for U9:** `phase-6-vehicles-light.png`, `phase-crm-tasks-light.png`, `phase-crm-sales-team-light.png`.

---
## Ranked defects (most severe first)

### 1. Card title is the database ID, not the thing the user recognizes — C16 hierarchy hard-reject
**Evidence:**
- `leads_idle-6_light_1.0_en_360x800.png`, top card, top-left region: large bold `LD-1000` as title, phone below, `AED 12000` below that, `Active` pill top-right.
- Same in `leads_idle-2_light_1.0_en_360x800.png` (both cards: `LD-1000`, `Customer 1`), `leads_search-open_...` background cards, `leads_idle-2_ar_...` (`LD-1000` right-aligned title), and `phase-crm-leads-light.png` AFTER side (both cards).
**Law/criterion:** C16 hard-reject: “Hierarchy inside cards: title = the thing the user recognizes (vehicle/customer), then status pill, then meta; IDs are small meta, not titles.” Brief §U0 CARD HIERARCHY (binding): “title = customer name … fallback leadNumber” + “value = small LTR meta.”
**What fails:** First record has no human name so the fallback ID is promoted to titleLarge and rendered at the same weight/size as real names (`Customer 1/2/3`). No small-meta treatment, no distinguishing style. A salesperson scanning “find Ahmed → Call” sees an ID string as the primary read. Vehicles AFTER comparator in the same repo does it right (`Toyota Camry · 2021` title, `ABC 1000` small badge over hero).
**GATES (strict): YES — C16 hard-reject, caps at 10/16.**

### 2. Primary text truncated mid-word on tablet table — U5
**Evidence:** `leads_idle-6_light_1.0_en_768x1024.png`, table rows region (all 6 rows): `Custome...`, `+971 ...` (ellipsis), `AED1...` (ellipsis). Lead name, phone, and value — all three primary fields — are cut with “…” mid-token.
**Law/criterion:** U5: “NEVER ‘…’ on a person's name or a primary label; never a label cut mid-word. Horizontal rows either fit completely or scroll with a clean peek.” C17: any U-law fail caps at 8/16.
**What fails:** The medium+ `AppTable + dossier` duality (brief-kept) does not fit: columns squeeze instead of reflowing to cards, and the dossier pane (`Select a lead to view details`) sits empty while the table itself is unreadable. No `See details` affordance recovers the truncated phone/value. 1.3x/320px phone cards avoid this only because they abandon the table, so the breakpoint itself is the defect.
**GATES (strict): YES — U5, caps at 8/16.**

### 3. Frequent create (Add) is top-reach only; empties offer no Add at all — U4 + U8
**Evidence:**
- `leads_idle-6_..._360x800.png`, toolbar row 2: `+ Add Lead` ghost text at top, same line as search/filter/kanban icons. Same in `leads_idle-2_...` (all locales/scales) and `phase-crm-leads-light.png` AFTER.
- `leads_empty-nocrm_...`: header shows only kanban icon; body CTA is `Connect Now` only. `leads_empty-sync_...`: CTA is `Sync Now` only. No `Add Lead` anywhere on either empty.
**Law/criterion:** U4: “frequent create/scan actions are reachable without scrolling and in the lower half of the screen or in a sticky bar.” Brief tap budget lists Add as a top task (≤2 taps). U8: “no dead ends; empty always offers the honest next step.” Brief §MOVED: “Add stays a header action when non-empty and the empty-state CTA when empty.”
**What fails:** Add is never in the lower half / sticky bar / FAB position — always top-toolbar reach on a 6-foot phone. On empties the brief’s own “header-or-empty-only” rule collapses to zero Add paths: a user with no CRM connected (or sync pending) who just wants to hand-enter a lead is dead-ended to Connect/Sync. That is the opposite of progressive disclosure — the rarest action (kanban toggle) keeps a header slot on empties while the frequent create disappears.
**GATES (strict): YES — U4 (and U8 dead-end), caps at 8/16.**

### 4. Search placement violates U1; two find-paths violate one-path-per-task — U1 + U9 + C16
**Evidence:**
- `leads_idle-6_light_1.0_en_360x800.png`, rows 1–2: `Leads / 6 leads` title block, then a *second* toolbar row (magnifier, funnel, kanban, `Add Lead`) left-aligned below the subtitle. No shell header with notifications/avatar visible in any of the 10 crops; search is a page-body toolbar icon, not “header at the TOP RIGHT.”
- Brief §Single-affordance audit (p.102–116) admits the pair: inline `AppSearchField` removed, but shell palette (`Ctrl+K`/search → `selectTab(1)` + dossier) “keeps working unchanged” alongside the new list-scoped search sheet (`leads_search-open_...` bottom sheet with `Search leads...` field).
**Law/criterion:** U1: “SEARCH: a search ICON in the header at the TOP RIGHT (next to notifications and avatar). Tapping opens a full-screen search… Same placement on every dashboard/list screen.” C16: “No duplicate entry points for the same thing… One path per task.” U9 consistency. The brief’s >5-item threshold is the ONE sanctioned U1 exception (hide icon when ≤5 — correctly honored in `leads_idle-2_...` which shows no search/filter icons), but placement/duplication is not sanctioned.
**What fails:** (a) Even when shown (>5), the icon sits in a second row, left side in LTR (mirrored left in AR image, confirming logical-end confusion), not top-right with notifications/avatar. (b) Two live find-paths for one task remain: list search-sheet (filter-loaded-leads → reveal record) vs shell palette (jump-to-dossier over first 50). The brief justifies this as “shell-owned, not the list search” — that is exactly the duplicate-entry reasoning C16 forbids. Tap walkthrough still passes budgets (header search 1 + result 1 = 2; palette 1+1 = 2) but the user must now learn which search does what.
**GATES (strict): YES — U1 fail caps at 8/16 (C16 duplicate-entry independently caps at 10/16; stricter 8 applies).**

### 5. Numbers unreadable: no thousands separators, glued currency, no label — U11 + C11
**Evidence:**
- `leads_idle-6_...`: `AED 12000`, `AED 13000`, `AED 14000`, `AED 15000` (no comma). `leads_idle-2_...` (all scales/locales): same. `phase-crm-leads-light.png` BEFORE shows `AED 12000`; AFTER repeats it unchanged — the migration did not fix formatting. Tablet table: `AED1...` truncated so value is neither complete nor comparable.
**Law/criterion:** U11: “READABLE NUMBERS: stats have labels, are fully visible.” C11: “Numbers: thousands separators, consistent decimals, explicit +/- on deltas, currency symbols, relative time via central formatters only.” Brief §U4: “zero shown as `0`” and “value LTR” — LTR is honored, separators are not.
**What fails:** A salesperson comparing `12000` vs `13000` vs `14000` gets an ungrouped 5-digit string with no `12,000` grouping and no `Value` label on compact cards (tablet header says `Value`, cards do not). The search sheet (`leads_search-open_...`) drops value entirely (name + phone only), so the decision-helping number vanishes on the exact screen meant for fast triage.
**GATES (strict): YES — U11, caps at 8/16.**

### 6. Status pill says nothing: “Active” with no why-sentence, no source/agent context — U13 (+ C11 STATUS PATTERN)
**Evidence:** Every card in every idle image (`idle-6`, `idle-2` en/ar/1.3x/320px, tablet, BEFORE/AFTER): identical blue-dot `Active` pill, no second line. Card body is only `phone + AED value`. No source (`Meta/Zoho`), no agent, no stage, no “why.”
**Law/criterion:** U13: “every label is plain words a new employee understands in 3 seconds.” C11 STATUS PATTERN: “short human label + colored dot/chip + one-sentence ‘why’.” Brief §U0 binding: “source/agent = secondary meta.”
**What fails:** “Active” is system jargon — new vs contacted vs qualified vs won are all “active.” Six identical pills provide zero triage signal, and the promised secondary meta (source/agent) present in the filter sheet (`Meta/Zoho`, `John/Sara` in `leads_filter-open_...`) never appears on the card. Vehicles AFTER shows the pattern done right (`Booked` pill + `Oil change · 12 Jun 2026 · 10:00 AM` sentence). Here the pill is decoration. Filter sheet proves the data exists; the card just doesn’t show it.
**GATES (strict): YES — U13, caps at 8/16.**

### 7. Missing states: no skeleton, no error, no offline/stale proof — U10 + C10
**Evidence:** Folder inventory (10 PNGs): `idle-6`, `idle-2` (en/ar/1.3x/320px/tablet), `search-open`, `filter-open`, `empty-nocrm`, `empty-sync`. Zero files for `loading`, `error`, `offline/stale`. Brief §Matrix requires only empty/with-data/search/filter/kanban/ar/1.3x/320px/tablet — loading/error are required by §U6 (“skeleton mirroring the cards… error + Try again”) but have no image.
**Law/criterion:** C10 (every data screen implements loading/empty/error/offline/stale/refresh); U10: “errors say what to do next.” U2 fold rule assumes “idle state with data” — without skeleton/error goldens there is no proof the first paint or a failed sync doesn’t push content or blank the list.
**What fails:** Reviewer cannot verify pull-to-refresh, `AppErrorState + Try again` (same retry), or `AppBanner` stale-keeping claimed in §U6. The two empties are the only failure-adjacent states, and both are terminal (Connect/Sync) with no “keep last data + retry inline” variant. Tap walkthrough step retry/sync therefore has only the happy-path evidence.
**GATES (strict): YES — U10 (no error recovery proven), caps at 8/16.** (Generous reading: if harness treats this as process gap not UI fail, score still capped by Defects 1–6.)

### 8. Consistency with siblings fails — U9 (supporting, non-independent cap)
**Evidence:** vs `phase-6-vehicles-light.png` AFTER (hero image + `Toyota Camry · 2021` title + plate badge + `Booked` pill + `View` + `Book service` + `···` bottom-right); vs `phase-crm-tasks-light.png` AFTER (`Tasks / 2 tasks` + refresh + `Add Task`, cards with left radio + title + meta + pill below meta + edit/delete circles top-right); vs `phase-crm-sales-team-light.png` AFTER (avatar + name/role + rank + `AED 12000` + 3-stat grid + progress bar). Leads cards: no avatar/initial, title-row + phone + value stacked left, `Call` + `···` bottom-left, large dead whitespace right half (most visible in `idle-6`/`idle-2` phone crops).
**Law/criterion:** U9: “the same element sits in the same place across screens.” C9 list screen + C8 `AppCard`/`AppStatusChip` shared atoms.
**What fails:** Primary action placement flips (vehicles/tasks: trailing/right; leads: leading/bottom-left). Add-action styling matches siblings (`+ Add X` ghost text — consistent, good), but card anatomy does not: siblings put identity visual left (car hero / radio / avatar) and actions right; leads puts nothing visual and strands actions left under the value. The AR mirror is structurally correct (title right, pill left, `اتصال` + `···`), but the pill stays English `Active` — untranslated string in an otherwise Arabic screen (`العملاء المحتملون / 2 عميل / أضف عميلاً` vs `Active / LD-1000 / AED 12000`). That is a C15/l10n defect riding on U9.
**GATES (strict): NO independent cap — U9 fail already subsumed by U1/U5 caps above; cited for fix, not an additional cap. The untranslated `Active` alone would block l10n sign-off.**

---
## Tap walkthrough (brief budgets vs observed)

| Task | Budget | Observed path | Verdict |
|---|---|---|---|
| Open list | ≤1 | nav Leads tab (shell, not in crops; assumed kept) | PASS (unverified in images, no counter-evidence) |
| Find + open dossier | ≤2 (≤1 from list) | >5: search icon → `Search leads` sheet (`leads_search-open_...` lists 6 rows, field filters loaded leads) → result tap reveals record → card tap opens `LeadDetailSheet` = 2 taps + typing. ≤5: no search icon, scroll → card tap = 1 tap | PASS on count, FAIL on placement/duplication (Defect 4) |
| Add lead | ≤2 (header / empty-only) | non-empty: toolbar `+ Add Lead` → `LeadFormSheet` = 1 tap from list. empty: NO Add affordance (Defect 3) | FAIL (empty has no path; top-only placement) |
| Call / WhatsApp | ≤1 from list, ≤2 from launch | `Call` direct on every card (`idle-6`, `idle-2` all variants) = 1 tap. WhatsApp/Edit/Detail behind `···` = 2nd tap + menu pick | PASS on Call count; stage/WhatsApp discoverability FAIL (Defect 6 — pill looks static, `···` hides the rest) |
| Move stage | ≤3 | card `Active` pill → (claimed) dossier quick-select; or card tap → sheet quick-select; or kanban swimlane (kept). Pill has no chevron/affordance in any image | PASS on count, FAIL on affordance (U0 hunt: user must discover pill-tap or open-then-find) |
| Retry / Connect | ≤1 inline | `empty-nocrm`: `Connect Now` inline; `empty-sync`: `Sync Now` inline | PASS on count; FAIL on copy density (see below) |

**Non-gating copy note (C11):** both empties violate the brief’s own `AppEmptyState` contract (EXACTLY 1 icon + 1 sentence + 1 action). `empty-nocrm` has title + truncated 2-line body (`...lead...` ellipsis = U5 smell on secondary text) + `Connect Now` + extra caption line (`Leads will appear here automatically once connected`). `empty-sync` same shape (`No leads yet` + `Sync now...` + `Sync Now` + `You can also manage connections in the Integrations tab`). One caption too many in each; truncate-with-ellipsis instead of wrapping to 2 lines.

## C16 hard-reject checklist (each item)

- [x] Light cards borderless (soft shadow/flat): PASS — AFTER cards in `phase-crm-leads-light.png` drop the BEFORE hairline borders; phone/tablet crops show shadow/whitespace separation.
- [x] FAIL — Card hierarchy (ID as title): see Defect 1. **Caps 10/16.**
- [ ] No orphan tiles / carousel peek: N/A (no tile rows, no carousels on this screen).
- [ ] Exactly ONE filled accent element per section: PASS on cards (no filled CTA inside cards; `Call` is ghost). Filter sheet `Show results` is the single filled element when open. (Note: empty-state `Connect Now`/`Sync Now` full-width filled blue is the single CTA when shown — okay — but blue ≠ spec accent `#FF385C`; token drift, non-gating here since CRM app keeps current theme per brief §KEPT.)
- [x] FAIL — Duplicate entry points (list search-sheet + shell palette for “find a lead”): see Defect 4. **Caps 10/16.**
- [ ] No permanent status pills / badges covering icons: PASS (no badges; `Active` is content, not sync-chrome).
- [ ] ALL CAPS / label+number duplication: PASS — pills sentence-cased (`Active`), counts in subtitle (`6 leads`), no `ACTIVE` shouting (BEFORE had `ACTIVE` green tag; AFTER fixed it — visible in comparator).
- [ ] Search = one pill/sheet, never inline pushing content: PASS on pattern (icon → sheet, `leads_search-open_...`), subject to Defect 4 placement/duplication.
- [ ] Above-the-fold rule (first record above bottom nav at 360×800 idle): LIKELY PASS — `idle-6_360x800` shows first card fully + second card peeking; bottom nav is outside the crop so not strictly provable, but no header bloat pushes content down (title + one toolbar row only). Not claimed as defect.
- [ ] Carousels peek: N/A.

## Score

- Start 16. Defects 1 (C16) and 4 (C16 duplicate) each independently cap at **10/16**.
- Defects 2 (U5), 3 (U4/U8), 4 (U1), 5 (U11), 6 (U13), 7 (U10) each independently cap at **8/16** per C17. Strictest governs.
- **Final: 5/16 — FAIL (bar ≥12/16).**
- Rationale for 5 rather than 8: the cap is a ceiling, not a floor. Six independent U-law fails (truncation, reachability/dead-end, search placement, numbers, plain-language status, missing error proof) + one C16 hierarchy fail + one C16 duplication fail + empty-state contract drift + untranslated `Active` in AR + tablet table unreadable + no skeleton/error goldens. An 8 would imply “one slip in an otherwise Airbnb screen”; this is a clean, calm, consistent list whose cards say too little (ID + phone + bare value + content-free pill) and whose tablet/error paths are unproven. Fix order is the rank order above.
- To pass (≥12): fix Defects 1–7 (real name titles with ID as small meta; tablet columns→cards or fitting columns with no ellipsis on primary; Add in lower-half/sticky + Add on empties alongside Connect/Sync; single U1-top-right search with palette de-duplicated or explicitly scoped in-product; `AED 12,000` grouping + value labels; pill + one-sentence why + source/agent meta; skeleton + error + offline goldens), re-shoot all 10 + new loading/error/offline PNGs, and localize `Active`/stage strings (AR evidence).

*Adversarial stance kept: every defect tied to a named image region + exact C16/U-law clause + explicit GATES marking. No reference claims (references EMPTY). No logic changes proposed; presentation-only fixes.

---

# ROUND-2 VERDICT (fresh eyes, did not fix) — 2026-10-22

Worktree: `wt-crm` branch `ui/list-crm`. No checkout/switch/commit/push/merge, no touch of 71983229, no writes outside this worktree.
Current PNGs verified (11/11 in after-crm-leads): idle-6_360, idle-2_360, search-open, filter-open, empty-nocrm, empty-sync, idle-2_ar, idle-2_320, idle-2_1.3x, idle-6_768, loading (new). Code attribution (read-only): crm_leads_page.dart moneyAED lines 511/540/612/728.

## Fixer claims verified
- Name-first titles (no ID titles): PARTLY FIXED. idle-6_360 top card title now +971 50 100 0000 (phone), others Customer 1/2/3; LD-1000 demoted to meta line Value - AED 12,000 - LD-1000. No bare-ID titles. C16 ID-title cap LIFTED (phone fallback accepted as recognizable; not leadNumber per brief but better than ID).
- Tablet 30/30 whole: FIXED. idle-6_768 shows Lead/Phone/Value/Stage/Agent all whole, Active pill whole on 6/6 rows, no per-letter stacking, no ellipsis on primary. U5 tablet cap LIFTED.
- Empty Add buttons: FIXED (dead-end lifted). empty-nocrm and empty-sync both show + Add Lead ghost below primary CTA. U8 dead-end LIFTED.
- Grouped AED 12,000 via AppFormatters: FIXED. All cards/tablet/AR show grouping + Value label. U11 numbers LIFTED.
- Context line from existing fields: ADDED but INSUFFICIENT. Cards carry Meta-Sara-Called / Zoho-John-Called. Pill still bare Active with no why-sentence; Active still jargon. C11 STATUS PATTERN unmet, U13 still GATES.
- New loading frame: ADDED partial. leads_loading skeleton mirrors cards. No error/offline PNGs, so U10 still GATES.

## Remaining gating (strict)
1. U4 reachability: Add top-toolbar only on non-empty, no lower-half/sticky/FAB. Caps 8/16.
2. U1 search placement + C16 duplication: search/funnel in second toolbar row left, not header top-right with notifications/avatar; shell palette + list sheet remain two find-paths. Caps 8/16 (C16 10/16, stricter 8 applies).
3. U13 status + AR verbatim: six identical Active pills, no why-sentence; AR pill stays Latin Active. Caps 8/16. Rebuttal ar-verbatim-must-stay-Latin is WRONG (tasks AR now عالية proves localization possible). Defect real+gating.
4. U10 error/offline: no error goldens, no Try-again pixel. Caps 8/16. Rebuttal skeleton/error-STOP is WRONG (C10/brief-U6 presentation states over existing refresh, not logic). Defect real+gating.
- Other rebuttals: search-placement-atom WRONG (pixels second-row left vs spec top-right; tablet top-right proves inconsistency). sticky-Add-U7 WRONG (sticky same-sheet is one destination, U4 demands it). fixture-titles WRONG (goldens must prove triage; Task-N/LD-1000 + identical pills = U13 fail). ghost-Add-contract CORRECT (brief allows text action, non-gating).

## Condensed regression
Open ≤1 PASS. Find ≤2 count PASS, placement/duplication FAIL. Add ≤2 count PASS incl new empty path, reachability FAIL. Call ≤1 from list PASS. Move stage ≤3 count PASS. Retry ≤1 inline PASS.

## Rubric
Merit 14/16. C16 duplication still FAIL caps 10/16. C17 U1/U4/U13/U10 each cap 8/16.

Score: 7/16 — FAIL (bar 12/16). Verdict: NOT CLEAR. Remaining gating (round-2): U1, U4, U13, U10.*

---

# ROUND-3 VERDICT (fresh eyes, did not fix) - 2026-10-22

Worktree: `wt-crm` branch `ui/list-crm`. No checkout/switch/commit/push/merge, no touch of 71983229, no writes outside this worktree.
Current PNGs verified (11/11 in after-crm-leads): idle-6_360, idle-2_360, search-open, filter-open, empty-nocrm, empty-sync, idle-2_ar, idle-2_320, idle-2_1.3x, idle-6_768, loading. Code read-only: crm_leads_page.dart showFindAids `totalLoaded > 5` (l.123), moneyAED ll.627/699/815; crm_dashboard_view.dart F9 `shellSearchOnLeads = selectedIndex == 1` + `onSearch: null` (ll.226-242).

## Wave-2 fixes verified
- F6 plain-Row: FIXED on pixels. idle-6_360 row 1 = `Leads / 6 leads` left + search + filter icons top-right same row; row 2 = kanban + `+ Add Lead` right. idle-2_360 (2 items) correctly shows NO search/filter, only kanban + Add (same >5 condition). idle-2_ar mirrored (title right, Add left, kanban middle). idle-6_768 wide single row (title + search + filter + kanban + Add one row, all whole, no ellipsis on Lead/Phone/Value/Stage/Agent). RTL + threshold + wide-row all hold.
- F9 single path: FIXED in code. Shell WorkspaceAppBar search trigger is null on Leads tab (index 1); Ctrl+K stays wired (keyboard only, no second visible entry). List search-sheet (`Search leads` + 6 rows) is now the single visible find-path. C16 duplicate-entry cap LIFTED.
- F10 intact: `Value - AED 12,000 - LD-1000` grouping + label on all cards/tablet/AR (`القيمة` localized); context line `Meta - Sara - Called` intact; empty-nocrm/empty-sync keep `+ Add Lead` ghost below primary CTA; leads_loading skeleton still present.

## Remaining gating (strict, caps applied)
1. U1 placement: page-header top-right is not C17 shell header "next to notifications and avatar". F6 moves icon to row-1 top-right (progress) but shell trigger is now hidden on this tab, so no shell-header search exists here. Strict U1 still FAILS. Caps 8/16.
2. U4 reachability: `+ Add Lead` top-row-2 only on non-empty; no lower-half/sticky/FAB; 6-card list scrolls. Empty Add path cures dead-end, not common-case reach. Caps 8/16. Sticky-Add rebuttal stays WRONG (sticky same-sheet = one destination; U4 demands it).
3. U13 status: six identical `Active` pills, no why-sentence; AR pill stays Latin `Active` while value label is localized - tasks-`عالية` proves localization possible, so ar-verbatim rebuttal stays WRONG. Caps 8/16.
4. U10 states: skeleton exists (loading PNG), but zero error/offline PNGs, no `Try again` pixel. Skeleton/error-STOP rebuttal stays WRONG (AppErrorState over existing refresh = presentation, C10/brief-U6). Caps 8/16.

## Condensed regression
Open <=1 PASS. Find <=2 count PASS, single path PASS (F9), placement FAIL (U1). Add <=2 count PASS incl empty path, reachability FAIL. Call <=1 PASS. Move <=3 count PASS. Retry <=1 inline PASS (happy path only).

## Rubric
Merit 14/16 (borderless, no-ID-title hierarchy, grouped numbers, context line, single find-path, tablet whole). C16 PASS (duplication lifted; no other hard-reject). C17 U1/U4/U13/U10 each cap 8/16.

Score: 8/16 - FAIL (bar 12/16). Verdict: NOT CLEAR. Remaining gating: U1, U4, U13, U10.
