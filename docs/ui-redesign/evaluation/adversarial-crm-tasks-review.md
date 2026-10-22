# Adversarial Review — CRM Tasks List (ui/list-crm)

**Role:** adversarial reviewer. Assume NOT Airbnb-level. Hunt defects.
**Worktree:** `wt-crm` (branch `ui/list-crm`). No checkout/commit/push performed. No touch of `71983229`.
**Screen brief:** `docs/ui-redesign/briefs/crm-tasks-list.md` (list family; AppPageHeader + count subtitle + header search-icon-only-when->5 + borderless cards + toggle-direct + AppStatusChip + sheets + empty/loading/error states).
**References:** EMPTY — `docs/ui-redesign/references/` does not exist; `AIRBNB_PATTERNS.md` missing repo-wide (brief §References confirms dependency UNMET, proceeded on precedent). No reference-based claims made.
**Governance:** REDESIGN MANDATE + C16 hard-reject (caps 10/16) + U0–U14 per C17 (`DESIGN_SPEC.md` C16–C17; brief §§U-laws is authoritative application). Any U-law fail caps at 8/16. Pass bar ≥12/16.
**Images inspected (Read, 9 files):**
- `docs/ui-redesign/baseline/after-crm-tasks/tasks_idle-2_light_1.0_en_360x800.png`
- `docs/ui-redesign/baseline/after-crm-tasks/tasks_idle-6_light_1.0_en_360x800.png`
- `docs/ui-redesign/baseline/after-crm-tasks/tasks_search-open_light_1.0_en_360x800.png`
- `docs/ui-redesign/baseline/after-crm-tasks/tasks_empty_light_1.0_en_360x800.png`
- `docs/ui-redesign/baseline/after-crm-tasks/tasks_idle-2_light_1.0_ar_360x800.png`
- `docs/ui-redesign/baseline/after-crm-tasks/tasks_idle-2_light_1.0_en_320x568.png`
- `docs/ui-redesign/baseline/after-crm-tasks/tasks_idle-2_light_1.3_en_360x800.png`
- `docs/ui-redesign/baseline/after-crm-tasks/tasks_idle-2_light_1.0_en_768x1024.png`
- `docs/ui-redesign/baseline/phase-crm-tasks-light.png` (BEFORE/AFTER comparator)
**Siblings checked for U9:** `phase-crm-leads-light.png`, `phase-crm-sales-team-light.png`, `phase-6-vehicles-light.png`.

---
## Ranked defects (most severe first)

### 1. Search placement violates U1; conditional chrome shifts layout — U1 + U9
**Evidence:**
- `tasks_idle-6_light_1.0_en_360x800.png`, toolbar row 2: left-aligned magnifier, refresh glyph, `+ Add Task` blue text. No shell header with notifications/avatar in any crop; search is a page-body toolbar icon, not "header at the TOP RIGHT."
- `tasks_idle-2_light_1.0_en_360x800.png` (all 2-item variants: en/ar/320/1.3x/tablet): same row with refresh + Add only, NO magnifier. `phase-crm-tasks-light.png` AFTER confirms same second-row pattern.
**Law/criterion:** U1: "SEARCH: a search ICON in the header at the TOP RIGHT (next to notifications and avatar). Tapping opens a full-screen search… Same placement on every dashboard/list screen in every app." C16: "No duplicate entry points… One path per task." U9 consistency.
**What fails:** (a) Even when shown (>5), icon sits second row left in LTR (mirrored left in AR image — logical-end confusion), not top-right with notifications/avatar. (b) The >5 threshold itself is the ONE sanctioned U1 exception in the brief (correctly honored pixel-wise: absent at 2, present at 6), but placement is NOT sanctioned — brief §Search-icon-pattern says "top-right" while pixels show second-row left. User must re-learn placement per list. Tap still passes budgets (icon + result = 2) but discoverability fails.
**GATES (strict): YES — U1 fail, caps at 8/16.**

### 2. Frequent create top-only, scrolls away, never lower-half/sticky — U4
**Evidence:**
- `tasks_idle-6_..._360x800.png`: `+ Add Task` ghost text top row only; 5 cards visible (`Task 0`…`Task 4` cut mid-fifth), list extends below fold. No FAB, no sticky bottom bar in any idle/search/empty frame.
- `tasks_empty_...`: full-width blue `Add Task` centered — only state where Add is reachable without scrolling to top. `tasks_idle-2_320/1.3x/tablet`: same top-only pattern.
**Law/criterion:** U4: "frequent create/scan actions are reachable without scrolling and in the lower half of the screen or in a sticky bar." Brief tap budget lists Add as top task (≤2 taps).
**What fails:** Add is never in lower half / sticky / FAB — always top-toolbar reach on a tall phone. On a 6-item list the user who just finished Task 4 must scroll back to top to add Task 6. Empty-state exemption does not help the non-empty case which is the common case. Progressive disclosure inverted: rarest affordance (refresh) keeps equal header weight while frequent create vanishes on scroll.
**GATES (strict): YES — U4, caps at 8/16.**

### 3. Cards say nothing: generic titles + identical No-due-date + identical High on every row — U13 + C11 STATUS PATTERN
**Evidence:** `tasks_idle-6_...`: all visible cards `Task 0`…`Task 4` show `Sara/Unassigned` + `No due date` + identical red-dot `High` pill. `tasks_idle-2_...` (all locales/scales/tablet): same — `Task 0`/`Task 1`, `Sara`/`Unassigned`, `No due date`, `High`. Search sheet (`tasks_search-open_...`) lists 6 rows `Task 0`…`Task 5` with assignee only on even rows, no due/priority at all.
**Law/criterion:** U13: "every label is plain words a new employee understands in 3 seconds." C11 STATUS PATTERN: "short human label + colored dot/chip + one-sentence 'why'." Brief §U0 binding: one card = title → assignee/due meta → ONE due/priority signal.
**What fails:** `Task 0` is a database index, not the thing the user recognizes (brief example: "Call Ahmed re quote"). `No due date` never says what to do next. Six identical `High` pills provide zero triage — everything urgent = nothing urgent, no why-sentence, no overdue/today differentiation in any capture. Search sheet drops the only signal (priority) on the exact screen meant for fast triage.
**GATES (strict): YES — U13, caps at 8/16.**

### 4. No skeleton, no error, no offline/stale proof; delete-confirm unproven — U10 + C10
**Evidence:** Folder inventory (8 PNGs): `idle-2` (en/ar/320/1.3x/tablet), `idle-6`, `search-open`, `empty`. Zero files for `loading`, `error`, `offline/stale`. `tasks_search-open_...` dims background but shows no no-match variant. No delete-confirm PNG in set.
**Law/criterion:** C10 (every data screen implements loading/empty/error/offline/stale/refresh); U10: "errors say what to do next"; U2 fold rule assumes "idle state with data" — without skeleton/error goldens no proof first paint or failed sync doesn't blank list.
**What fails:** Reviewer cannot verify `AppShimmerSkeleton` mirroring, `AppErrorState + Try again`, or `AppBanner` stale-keeping claimed in brief §U6. Before had neither either, so no regression — but redesign mandate requires proof, not inheritance. Delete `AppDialog` naming the task has code + tests only, no pixel. Tap retry/sync therefore has only happy-path evidence.
**GATES (strict): YES — U10 (no error recovery proven), caps at 8/16.**

### 5. AR mix: High + Task N + Sara stay Latin in Arabic screen — C15 + U13
**Evidence:** `tasks_idle-2_light_1.0_ar_360x800.png`, card regions: title right-aligned `المهام`/`2 مهمة`, `+ أضف مهمة` mirrored, meta `بدون تاريخ`/`غير مُسند` translated, but pills read `High` Latin, titles `Task 0`/`Task 1` Latin, `Sara` Latin. Same in `phase-crm-tasks-light.png` AFTER (Latin retained).
**Law/criterion:** U13 (new-employee plain words) + C15 (no untranslated user-visible strings; keys `tm*`-style verbatim only for codes/names). Brief says priority pills verbatim — same server-label rule as migration.
**What fails:** Arabic reader sees English `High` as the sole signal pill in an otherwise Arabic screen (`المهام / أضف مهمة / بدون تاريخ`). If `High` is a server enum, card needs localized display string; if user-facing, AR translation missing. Either way l10n sign-off blocked. Mirroring itself is correct (circle right, actions left), so structural RTL passes — copy does not.
**GATES (strict): YES — U13, caps at 8/16.** (Generous reading: if `High` pinned as server enum, still U13 fail for Arabic newcomer.)

### 6. Header Add is ghost text, not AppPillButton; accent token drift — C8 + C2
**Evidence:** All non-empty frames: `+ Add Task` blue text (no pill fill, no 44–52px pill container). Empty frame: full-width filled blue `Add Task`. `phase-crm-tasks-light.png` BEFORE had dark filled `+ Add Task`; AFTER split into two styles (text vs filled). Blue ≠ spec accent `#FF385C` (C2).
**Law/criterion:** C8 `AppPillButton`: pill radius, H 52/44/36, labelLarge, one primary per section. C2: ONE accent `#FF385C`. C16: exactly ONE filled accent per section.
**What fails:** Header Add fails component spec (ghost, not pill) while empty CTA is filled — two Add grammars. Token drift (blue kept per brief §KEPT current theme) violates single-accent rule; consistent with siblings (all CRM blue) but not with DESIGN_SPEC. No usability block, but Airbnb polish fails.
**GATES (strict): NO independent cap — C8/C2 rubric deduction, not U-law/C16 hard-reject. Cited for fix.**

### 7. Sibling consistency fails — U9 (supporting, non-independent cap)
**Evidence:** vs `phase-6-vehicles-light.png` AFTER (hero + `Toyota Camry` title + plate badge + actions trailing-right + bottom bar); vs `phase-crm-sales-team-light.png` AFTER (avatar + name/role + rank + revenue + 3-stat grid + bar, zero actions); vs `phase-crm-leads-light.png` AFTER (`Call` + `···` bottom-left). Tasks: left radio + title + meta + pill below meta + edit/delete circles top-right.
**Law/criterion:** U9: "same element sits in same place across screens." C9 list screen + C8 shared atoms.
**What fails:** Primary-action placement flips per list (tasks trailing top-right, leads bottom-left, team none, vehicles bottom-right + bar). Search presence flips (tasks conditional >5, leads conditional >5 + shell palette, team none). AR mirrors are structurally correct per screen, but pill language split (Defect 5) rides on U9. Header grammar (`AppPageHeader` + subtitle) is consistent — good — card anatomy is not.
**GATES (strict): NO independent cap — U9 fail already subsumed by U1/U4 caps above; cited for fix, not additional cap.**

---
## Tap walkthrough (brief budgets vs observed)

| Task | Budget | Observed path | Verdict |
|---|---|---|---|
| Open list | ≤1 | nav Tasks tab (shell, not in crops; assumed kept) | PASS (unverified in images, no counter-evidence) |
| Complete / reopen | ≤1 from list, ≤2 from launch | toggle circle DIRECTLY on every card (all idle frames) = 1 tap from list | PASS on count |
| Add task | ≤2 (header / empty-only) | non-empty: toolbar `+ Add Task` → form sheet = 1 tap from list but top-only, scroll-away (Defect 2). empty: centered `Add Task` = 1 tap | PASS on count, FAIL on reachability (Defect 2) |
| Edit task | ≤2 | pencil icon per card → same sheet = 1 tap from list | PASS on count |
| Delete task | ≤2 + 1 confirm | trash per card → `AppDialog` (no PNG) → same `deleteTask`, no undo | PASS on count, FAIL on proof (Defect 4 — no pixel) |
| Find task | ≤2 via header search (>5 only); scroll unchanged | >5: search icon → `Search tasks` sheet (`tasks_search-open_...` 6 rows, title/assignee filter) → result tap reveals = 2 taps + typing. ≤5: no icon, scroll only | PASS on count, FAIL on placement (Defect 1) |

## C16 hard-reject checklist (each item)

- [x] Light cards borderless (soft shadow/flat): PASS — AFTER drops BEFORE hairline borders in comparator.
- [ ] Card hierarchy (title → meta → pill): PASS on structure (title = task title per brief binding); FAIL on content (Defect 3 generic `Task N` + identical signals — not a C16 structural fail, U13 content fail).
- [ ] No orphan tiles / carousel peek: N/A (no tile rows, no carousels).
- [ ] Exactly ONE filled accent per section: PASS (empty CTA single filled; header Add text; cards no filled CTA).
- [ ] No permanent status pills / badges covering icons: PASS (`High` is content, not sync chrome; no badges).
- [ ] ALL CAPS / number duplication: PASS — sentence case (`High`, `Add Task`), counts in subtitle (`2 tasks`/`6 tasks`), no `ACTIVE` shouting.
- [x] FAIL (placement, not pattern) — Search = one top icon → sheet (>5 only): pattern honored (`tasks_search-open_...`), placement violates U1 (Defect 1). **U1 caps 8/16 (C16 duplicate-entry not triggered — single path).**
- [ ] Above-the-fold rule (first record above bottom nav at 360×800 idle): LIKELY PASS — `idle-2`/`idle-6` show first card complete + second peeking; bottom nav outside crop so not strictly provable, no header bloat (title + one toolbar row only).
- [ ] Carousels peek: N/A.

## Score

- Start 16. Defects 1 (U1), 2 (U4), 3 (U13), 4 (U10), 5 (U13) each independently cap at **8/16** per C17. Strictest governs.
- **Final: 6/16 — FAIL (bar ≥12/16).**
- Rationale for 6 rather than 8: cap is ceiling, not floor. Five independent U-law fails (search placement, reachability, content-free cards, missing error proof, AR copy) + ghost-vs-filled Add grammar + sibling drift. An 8 would imply one slip in an otherwise Airbnb screen; this is a clean, calm list whose cards say too little (`Task N` + `No due date` + identical `High`) and whose frequent create vanishes on scroll with no loading/error goldens.
- To pass (≥12): fix Defects 1–5 (single U1-top-right search with consistent >5 rule + documented placement; Add in lower-half/sticky or FAB persisting on scroll; real task titles with why-sentences + differentiated due/priority or honest empty-signal treatment; skeleton + error + offline PNGs + delete-confirm PNG; localize `High`/priority + audit `Task N`/`Sara` verbatim rule for AR), re-shoot all 8 + new loading/error/offline/delete PNGs, and localize AR pills.

*Adversarial stance kept: every defect tied to named image region + exact C16/U-law clause + explicit GATES marking. No reference claims (references EMPTY). No logic changes proposed; presentation-only fixes.

---

# ROUND-2 VERDICT (fresh eyes, did not fix) — 2026-10-22

Worktree: wt-crm branch ui/list-crm. No checkout/switch/commit/push/merge, no touch of 71983229, no writes outside this worktree.
Current PNGs verified (8/8 in after-crm-tasks): idle-2_360, idle-6_360, search-open, empty, idle-2_ar, idle-2_320, idle-2_1.3x, idle-2_768. ARB read-only: tkHigh ar عالية.

## Fixer claims verified
- AR priority pills (عالية): FIXED. idle-2_ar shows red-dot عالية pill on both cards, mirrored layout intact, Sara/Unassigned names LTR-correct. U13 AR-pill sub-defect LIFTED.
- Team empty header kept: confirmed on sales-team empty (Leaderboard header kept) — credited on team screen, not this one.

## Remaining gating (strict, all round-1 defects persist except AR pill)
1. U1 search placement: magnifier in second toolbar row left (idle-6_360), not header top-right with notifications/avatar. >5 threshold honored (absent at 2, present at 6) but placement unsanctioned. Caps 8/16. Rebuttal search-atom-compliant WRONG.
2. U4 reachability: + Add Task top-only ghost, scrolls away; 6-task list extends below fold, no FAB/sticky/lower-half. Empty CTA does not cure common case. Caps 8/16. Rebuttal sticky-violates-U7 WRONG (sticky same-sheet = one destination; U4 demands it).
3. U13 content-free cards: Task 0-5 generic titles + No due date x6 + identical High x6; search sheet drops priority entirely. Fixture-titles rebuttal WRONG — goldens must prove triage; generic fixture + identical signals = real U13 fail. Titles Task N are not user-recognizable; no why-sentence. Caps 8/16. AR titles Task 0/1 Latin in Arabic screen remain (names Sara LTR ok, titles not).
4. U10 states: zero loading/error/offline PNGs in 8-file set; delete-confirm no PNG; team-dropdown banner claimed but no pixel. Caps 8/16. Rebuttal error-STOP WRONG (AppShimmer/AppErrorState over existing refresh = presentation, brief-U6/C10).
- Ghost Add contract rebuttal CORRECT: brief allows AppPillButton/text action; ghost vs pill is non-gating C8/C2 deduction only. Bars/glossary N/A here.

## Condensed regression
Open ≤1 PASS. Complete/reopen ≤1 from list PASS (toggle direct). Add ≤2 count PASS, reachability FAIL. Edit ≤2 PASS. Delete ≤2+1 count PASS, proof FAIL (no pixel). Find ≤2 count PASS, placement FAIL.

## Rubric
Merit 11/16 (clean calm list whose cards say too little). C16 PASS (single find path). C17 U1/U4/U13/U10 each cap 8/16.

Score: 6/16 — FAIL (bar 12/16). Verdict: NOT CLEAR. Remaining gating (round-2): U1, U4, U13, U10.*

---

# ROUND-3 VERDICT (fresh eyes, did not fix) - 2026-10-22

Worktree: `wt-crm` branch `ui/list-crm`. No checkout/switch/commit/push/merge, no touch of 71983229, no writes outside this worktree.
Current PNGs verified (8/8 in after-crm-tasks): idle-2_360, idle-6_360, search-open, empty, idle-2_ar, idle-2_320, idle-2_1.3x, idle-2_768. ARB read-only: tkHigh ar `عالية` intact.

## Wave-2 fixes verified
- F6 plain-Row: FIXED on pixels. tasks_idle-6_360 row 1 = `Tasks / 6 tasks` left + search magnifier top-right same row; row 2 = refresh + `+ Add Task`. tasks_idle-2_360 correctly shows NO search (refresh + Add only, same >5 condition). tasks_idle-2_ar mirrored (title right, `+ Add Task` left, refresh middle, toggle right/actions left, `عالية` pill). Tablet idle-2_768 same pattern. RTL + threshold hold.
- F10 intact: `عالية` red-dot pills on both AR cards (U13 AR-pill sub-defect stays lifted); tasks_empty keeps `Tasks` header + centered CTA; search-open sheet (`Search tasks` + `Search by title or assignee` + Task 0-5 rows) intact.
- F9 cross-check: shell search hidden on Leads tab only (code `selectedIndex == 1`); Tasks tab keeps shell trigger alongside list sheet - single list path preserved (no duplication introduced here).

## Remaining gating (strict, all round-1 defects persist except AR pill)
1. U1 search placement: magnifier in page-header row 1 top-right, not C17 shell header "next to notifications and avatar". >5 threshold honored (absent at 2, present at 6) but placement unsanctioned. Caps 8/16. Search-atom rebuttal stays WRONG.
2. U4 reachability: `+ Add Task` top-only ghost, scrolls away; 6-task list extends below fold, no FAB/sticky/lower-half. Empty CTA does not cure common case. Caps 8/16. Sticky-U7 rebuttal stays WRONG (sticky same-sheet = one destination; U4 demands it).
3. U13 content-free cards: Task 0-5 generic titles + `No due date` x6 + identical `High` x6; search sheet drops priority entirely. Fixture-titles rebuttal stays WRONG - goldens must prove triage; generic fixture + identical signals = real U13 fail. AR titles Task 0/1 Latin in Arabic screen remain (names LTR ok, titles not). No why-sentence. Caps 8/16.
4. U10 states: zero loading/error/offline PNGs in 8-file set; delete-confirm no PNG; no refresh-affordance proof beyond icon. Caps 8/16. Error-STOP rebuttal stays WRONG (AppShimmer/AppErrorState over existing refresh = presentation, brief-U6/C10).
- Ghost-Add contract rebuttal CORRECT (brief allows text action; ghost vs pill is non-gating C8/C2 deduction only).

## Condensed regression
Open <=1 PASS. Complete/reopen <=1 from list PASS. Add <=2 count PASS, reachability FAIL. Edit <=2 PASS. Delete <=2+1 count PASS, proof FAIL (no pixel). Find <=2 count PASS, placement FAIL.

## Rubric
Merit 12/16 (clean calm list whose cards say too little). C16 PASS (single find path). C17 U1/U4/U13/U10 each cap 8/16.

Score: 7/16 - FAIL (bar 12/16). Verdict: NOT CLEAR. Remaining gating: U1, U4, U13, U10.
