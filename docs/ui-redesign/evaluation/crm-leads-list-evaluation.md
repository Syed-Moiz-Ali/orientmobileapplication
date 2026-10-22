# CRM leads list — Fresh review ROUND 1 (FAIL 8/16, C17-capped)

**Role:** FRESH REVIEWER (round 1), never built this screen. READ-ONLY except this file. No code/tests/PNGs edited. No branch/commit/push. Never touched `71983229`.
**Branch:** `ui/list-crm`.
**Read first:** Brief `docs/ui-redesign/briefs/crm-leads-list.md` (authoritative, as amended — includes the ONE sanctioned U1 exception: search/filter icons only when > 5 items); migration `docs/ui-redesign/evaluation/crm-leads-list-test-migration.md` (behavior pins); REDESIGN MANDATE (PROGRESS.md working rule 13) + C16 hard-reject (caps 10/16) + U0–U14 C17 (DESIGN_SPEC §C16–C17; brief §§U-laws is the authoritative application). Pass ≥ 12/16 with caps.
**References:** `docs/ui-redesign/references/` does NOT exist; `AIRBNB_PATTERNS.md` missing repo-wide (both per brief §References, confirmed UNMET — not pretended; precedent patterns from phase-5/6/7 cited instead).
**Images viewed (10/10 AFTER via Read + contact sheet + 2 BEFORE for structure):**
- AFTER `docs/ui-redesign/baseline/after-crm-leads/`: `leads_idle-2_light_1.0_en_360x800`, `leads_idle-6_light_1.0_en_360x800`, `leads_search-open_light_1.0_en_360x800`, `leads_filter-open_light_1.0_en_360x800`, `leads_empty-nocrm_light_1.0_en_360x800`, `leads_empty-sync_light_1.0_en_360x800`, `leads_idle-2_light_1.0_ar_360x800`, `leads_idle-2_light_1.0_en_320x568`, `leads_idle-2_light_1.3_en_360x800`, `leads_idle-6_light_1.0_en_768x1024`.
- Contact sheet `docs/ui-redesign/baseline/phase-crm-leads-light.png` (BEFORE/AFTER side-by-side, viewed).
- BEFORE `docs/ui-redesign/baseline/before-crm-lists/`: `leads_idle-2_light_1.0_en_360x800`, `leads_empty-nocrm_light_1.0_en_360x800` (structure only).
**Code read-only (attribution only):** `apps/crm_app/.../widgets/crm_leads_page.dart` (`showFindAids = totalLoaded > 5`, `leadsCountN` subtitle null-when-empty, `_buildTable`/`_buildDossier`/`_buildWide` placeholder, `_buildNoMatch` zero message, `_confirmDelete` via `showAppDialog`), `packages/shared_core/.../app_empty_state.dart` (message maxLines 2 + ellipsis).

---

## 1. DESCRIBE — region by region, WITHOUT judging

### AFTER idle-2 en 360 — `leads_idle-2_light_1.0_en_360x800.png`
- **Header region:** first line bold `Leads`; second line muted `2 leads`. Below, a small kanban-toggle glyph left and blue `+ Add Lead` text right. No magnifier, no funnel icon on this frame.
- **Card 1 region:** white rounded card. Top row: bold `LD-1000` left, pale-blue pill `● Active` right. Second line muted `+971 50 100 0000`. Third line bold `AED 12000`. Bottom row: blue phone-glyph + `Call` left, vertical `⋮` dots next to it.
- **Card 2 region:** same structure: `Customer 1` / `+971 50 100 0001` / `AED 13000` / `Call` + `⋮`. Frame ends below card 2.

### AFTER idle-6 en 360 — `leads_idle-6_light_1.0_en_360x800.png`
- **Header region:** `Leads` + `6 leads`; second row four items left-to-right: grey magnifier, grey funnel, kanban glyph, blue `+ Add Lead`.
- **Cards region:** four cards visible (`LD-1000`, `Customer 1`, `Customer 2`, `Customer 3`), each with the card-1 structure above (title / phone / `AED` value / `Call` + `⋮`, `Active` pill top-right). Frame cuts mid fifth card.

### AFTER search-open en 360 — `leads_search-open_light_1.0_en_360x800.png`
- **Dimmed list behind:** two cards greyed (`LD-1000`, `Customer 1` partial).
- **Sheet region:** white rounded sheet with drag handle, title `Search leads` left + `×` right; rounded input with magnifier and hint `Search leads…`; six rows `LD-1000` / `Customer 1`…`Customer 5` left with `+971 50 100 000x` right.

### AFTER filter-open en 360 — `leads_filter-open_light_1.0_en_360x800.png`
- **Dimmed list behind:** same two greyed cards.
- **Sheet region:** handle + `Filter leads` + `×`; `Source` label with chips `✓ All` (dark filled) / `Meta` / `Zoho`; `Agent` label with chips `✓ All` / `John` / `Sara`; full-width blue `Show results`; `Clear` text below.

### AFTER empty-nocrm en 360 — `leads_empty-nocrm_light_1.0_en_360x800.png`
- **Header region:** `Leads` only, no subtitle; kanban glyph below, no Add action.
- **Empty region:** pale circle with link-off glyph; bold `No third-party CRMs connected`; one muted sentence truncated with ellipsis (`…manage your lead…`); full-width blue `Connect Now`; small muted caption `Leads will appear here automatically once connected`.

### AFTER empty-sync en 360 — `leads_empty-sync_light_1.0_en_360x800.png`
- **Header region:** same (`Leads`, kanban glyph, no Add).
- **Empty region:** pale circle with people glyph; bold `No leads yet`; muted `Sync now to fetch leads from Meta.`; full-width blue `Sync Now`; caption `You can also manage connections in the Integrations tab`.

### AFTER ar 360 — `leads_idle-2_light_1.0_ar_360x800.png`
- Title right-aligned `العملاء المحتملون`, subtitle `2 عميل`; `+ أضف عميلاً` + kanban glyph row below (mirrored positions). Cards mirrored: `Active` pill left, `LD-1000`/`Customer 1` right-aligned, phone `+971 50 100 0000` and `AED 12000` LTR, `⋮` left of blue `اتصال` + phone glyph.

### AFTER 320px — `leads_idle-2_light_1.0_en_320x568.png`
- Same header stacked (`Leads` / `2 leads` / kanban + `Add Lead`); card 1 full-width single column; card 2 below; no clipped controls visible.

### AFTER 1.3x 360 — `leads_idle-2_light_1.3_en_360x800.png`
- Same two-card stack as idle-2; all rows legible; no overflow markers visible in the still.

### AFTER tablet 768 — `leads_idle-6_light_1.0_en_768x1024.png`
- **Left panel (~half width):** table with header row `Lead ↑ / Phone / Value / Stage / Agent`; six rows: lead `LD-10…`, phone `+971 5…`, value `AED 12…`, stage pill with `Active` stacked one letter per line vertically (`A / ct / iv / e` with dot), agent `Sara`/`John` alternating.
- **Right panel:** centered muted text `Search leads…`, otherwise empty.

### BEFORE vs AFTER structure (idle-2, empty-nocrm, contact sheet)
- BEFORE idle-2: inline `Search leads…` field + kanban toggle on row 1; source row (`All` filled blue / `Meta` / `Clear` + filled `+ Add Lead`); agent row (`All` / `John` / `Sara` / `Clear`); `2 Leads` pill; bordered rows with `LD-1000` / phone / green `ACTIVE` (ALL CAPS) + `AED 12000` and `›` chevron.
- AFTER idle-2: no inline search, no filter rows, no count pill — `Leads` + `2 leads` subtitle, kanban glyph + `+ Add Lead`, borderless cards with `Active` sentence-case pill, `Call` direct + `⋮`. Visible before/after difference is structural — redesign delivered.
- BEFORE empty-nocrm: inline search + kanban toggle kept above the empty panel; dark `Connect Now` button with icon; full two-line sentence.
- AFTER empty-nocrm: header chrome gone above the empty art; blue `Connect Now`; sentence renders truncated with ellipsis (see §2 U5 note).

---

## 2. U0–U14 walk (brief application; each with image + region evidence)

| Law (brief) | Evidence (image + region) | Pass / Fail + attribution |
|---|---|---|
| U0 — one read: identity (name → phone) → ONE status pill → meta (value LTR); CARD HIERARCHY binding; borderless light | idle-2 card 1: `LD-1000` (leadNumber fallback, name empty) → `+971 50 100 0000` → `AED 12000` LTR → ONE `Active` pill; idle-6 card 2 same shape. Light frames show soft shadow, no borders/dividers. Code `crm_leads_page.dart:466-469` (`AppStatusChip` + `_displayStatus` sentence-case) | PASS (owner-file) |
| U1 — find fast: header search icon top-right, list-scoped sheet; THE ONE sanctioned exception: icon ONLY when > 5 items | idle-2 (2 items): header has NO magnifier/funnel — cards only ✓. idle-6 (6 items): magnifier + funnel + kanban + Add ✓. Code `:94` `showFindAids = totalLoaded > 5`, `:118-145` icon block. Search sheet: handle + `×` + `AppSearchField` + 6 name/phone rows; result reveals record per migration | PASS — header-only collapse verified both directions; inline field removed (C16 one-path) |
| U2 — fit content: cards on compact; FOLD: first card above fold + second peeking @360x800 | Compact frames: single-column borderless cards; idle-2 360 shows card 1 complete + card 2; 320 shows card 1 + card 2 band. Tablet keeps sanctioned table+dossier duality (brief) | PASS on compact (tablet column defect scored under U5, not here) |
| U3 — no fake actions: Call/WhatsApp only with dialable target; stage pill from existing status | Every card carries direct `Call` + `⋮` (idle-2, idle-6, ar). Pills only `Active` from entity status; no invented health/priority pills. Handlers byte-identical per migration (`callLeadPhone`/`whatsAppLeadPhone`, same fail notices) | PASS |
| U4 — no invention: names/phones/values verbatim; zero as `0`; counts from `leads.length` | Titles/phones/`AED` values verbatim across idle/search/filter frames; phone/value LTR-locked incl. ar. Counts: `2 leads` / `6 leads` via ICU `leadsCountN` (code `:98-99`); filtered-to-zero message = `leadsCountN(0)` → `0 leads` (code `:333`) | PASS — **Call ≤ 1 from list** (direct on card) and **ICU count** (`=0/=1/other`, `2 leads`/`6 leads` pixel; `0 leads` code path) both verified |
| U5 — reachable + legible: 48dp targets, never clipped @320/1.3x, phone/value LTR, never a label cut mid-word | 320 + 1.3x frames: cards stack, `Call` + `⋮` intact, no overflow markers; ar LTR locks hold. **FAIL on tablet:** `leads_idle-6_…_768x1024` Stage column renders `Active` stacked one letter per line (`A/ct/iv/e`) — a status label cut mid-word, unreadable at a glance. Cells also ellipsize (`LD-10…`, `+971 5…`, `AED 12…`) — acceptable sanctioned-table behavior with the dossier as the full-record path, but the per-letter chip wrap is not | **FAIL (owner-file layout)** — tablet Stage chip. Code: `_buildTable` Stage flex 2 + `AppStatusChip` (`:425`, `:466-469`); `AppMasterDetailScaffold` keeps the placeholder half open (`:403-415`), squeezing the master to ~half of 768 |
| U6 — states: skeleton mirroring cards; empty 1-icon-1-sentence-1-action; error + retry; stale kept; pull-to-refresh | Empty-nocrm: 1 icon + title + sentence + 1 `Connect Now` (+ verbatim `leadsAutoNote` caption, brief-mandated) + same sheet handler. Empty-sync: same shape + same `refresh()`. Filtered-to-zero: `AppEmptyState` + Clear (code `:323-344`, migration-tested). Skeleton/`RefreshIndicator` per migration (structural tests GREEN). Observation (non-gating): the 90-char `leadsNoCrmBody` renders ellipsis-truncated at 360 (shared `AppEmptyState` message `maxLines: 2`, `app_empty_state.dart:100-104`) where BEFORE wrapped fully — copy length vs atom cap, not a U-law break | PASS (with noted observation) |
| U7 — feedback: Call/WhatsApp keep launcher + snackbar; delete = `AppDialog` destructive naming the record, NO undo; busy disables acting record only | Delete: `showAppDialog` + `dtDeleteTitle`/`dtDeleteBody(name, number)` + same `deleteLead` + `dtDeleted` snackbar, no undo (code `:299-312`, migration-tested). No delete-sheet PNG in the capture set — capture gap, code + structural tests are the evidence (same standing as vehicles-R1 U7). Call/WhatsApp contracts unchanged per migration | PASS (code + tests; PNG gap filed) |
| U8 — no dead ends: every card with a contact offers Call; stage pill opens the dossier quick-select; empty always offers next step | Every card shows `Call`; `⋮` holds WhatsApp/Edit/Delete (existing destinations, migration). Empty-nocrm → Connect sheet; empty-sync → `refresh()`; filtered-zero → Clear restores six | PASS |
| U9 — consistency: `AppPageHeader` + search/filter icons + `AppBanner` — same atoms as staff/customer/owner lists | `AppPageHeader` (title + ICU subtitle) + `AppIconButton` find-aids + `AppSurfaceCard(outlined: false)` + `AppStatusChip` + `AppEmptyState` + `showAppDialog` — same shared-atom family as the tasks rebuild on this branch | PASS |
| U10 — RTL: full mirror; phone/value/leadNumber LTR-locked | ar frame: full mirror (title/Add/cards/actions), `⋮` left of `اتصال`, pill left; `+971…`, `AED 12000`, `LD-1000`, `Customer 1` LTR; count `2 عميل` (ICU ar) | PASS |
| U11 — a11y: record `Semantics` label; header semantics; 48dp; AA pairs | Targets visually ≥48dp-intent, harness tests GREEN per migration; stills show no clipping @320/1.3x. Zero-as-`0`: `2/6 leads` pixel + `leadsCountN(0)` code path + ICU `=0/=1/other` (gen `crm_localizations_en.dart:887`) | PASS (stills-limited for exact dp) |
| U12 — density: 1-col compact; table + dossier on medium+ (existing breakpoint, shared atoms) | Compact = 1-col cards (all 360/320 frames); medium+ = `AppMasterDetailScaffold` table + dossier (tablet frame). Correct duality; density break itself is not the defect — the Stage column width inside it is (scored U5) | PASS (structure) |
| U13 — offline: shell pill owns offline state; stale list + inline retry; no new banner unless the feed errors here | No offline banner added on this surface per brief/shell contract; `refresh()`/sync CTAs stay inline in the empty states; `RefreshIndicator` kept per migration | PASS (no offline PNG in set; code pins per migration) |
| U14 — no regression: tap budgets ceilings; pull-to-refresh, keys, confirmation + snackbar unchanged in behavior | Keys/handlers/routes unchanged per migration (no new routes, no invented leads). Tap budgets: see §3 | PASS |

**U-walk fails: 1 (U5 tablet Stage chip — owner-file layout). Zero shell/shared fails.**

---

## 3. Top-task tap walk BEFORE→AFTER (budgets ≤ before; Call ≤ 1 from list)

BEFORE counts (brief §Top tasks, verified from code per migration doc): open list 1 (tab) · find+open 2 + type (inline filter + record, or palette + dossier) · Add 2 (tab + tonal Add) · Call 3 + scroll (tab + record + sheet Call) · move stage 3 (record + sheet quick-select) · retry/connect 1 inline.

| Task | Before | After (pixels + code) | Verdict |
|---|---|---|---|
| Open list | 1 tap (tab/`selectTab(1)`) | ≤ 1 tap (unchanged entry, nav kept) | same ✓ |
| Find + open lead | 2 taps + type (inline filter + record) or 2 taps (palette + dossier) | ≤ 2 taps: header icon + result reveal + record tap; palette unchanged (shell-owned). idle-6 shows both icons; search sheet lists 6 name/phone rows | same ✓ |
| Add lead (reach form) | 2 taps (tab + tonal Add) | ≤ 2 taps: header `+ Add Lead` when non-empty (idle-2/idle-6/ar headers), empty-state CTA when empty (both empty frames show NO header Add) — never both at once; same `LeadFormSheet.show` | same ✓ |
| Call lead | 3 taps + scroll (tab + record + sheet Call) | **≤ 1 from list**: `Call` DIRECT on every card (all idle frames incl. ar `اتصال`); ≤ 2 from launch. Same `tel:` intent + fail notice per migration | better ✓ (frequent action meets budget) |
| Move stage | 3 taps (record + sheet quick-select) | ≤ 3 taps: card tap → same sheet quick-select; kanban kept verbatim (legacy atoms remain per migration §deviations) | same ✓ |
| Retry sync / connect | 1 tap inline | ≤ 1 tap inline: `Sync Now` / `Connect Now` same handlers (`refresh()` / `ConnectIntegrationSheet.show`) | same ✓ |

**Tap result: PASS — Call (the frequent action) is ≤ 1 tap from list; Add/search/retry unchanged-or-better; no regression on any budgeted task.**

---

## 4. Airbnb rubric 0–2 each, /16, pass ≥ 12/16 — ONLY after (1)–(3)

| # | Criterion | Score | Reason |
|---|---|---|---|
| 1 | One task per screen | 2/2 | Find lead → act. Identity + phone + one pill + value + Call/menu; no competing heroes |
| 2 | Headline-first hierarchy | 2/2 | `Leads` → ICU count subtitle; title → ONE pill → LTR meta on every card; dossier mirrors the same record |
| 3 | Whitespace, no boxes-in-boxes | 2/2 | Borderless light cards (shadow, whitespace gaps); inline filter chrome + count pill removed; table hairlines only inside the sanctioned medium+ duality |
| 4 | Sheets for secondary actions | 2/2 | Search = sheet, filter = sheet (chips + Show results + Clear), delete = `AppDialog` destructive, add/edit/detail = existing sheets; no inline field pushing content |
| 5 | Sticky CTA (list has none) | 2/2 | Correctly absent by omission — Add lives header XOR empty-state (pixel-verified both), Call in-flow; no sticky bar claimed |
| 6 | Section structure (density/filter) | 1/2 | Compact list + filter predicates correct (count updates, no-match + Clear restores); **tablet table density breaks the Stage chip** (per-letter wrap) and the unselected dossier shows the search-hint copy (see #7) |
| 7 | Plain friendly copy, no invented claims | 1/2 | Sentence-case pills (`ACTIVE`→`Active`), verb-first Call/Add/Show results/Clear, ICU counts both languages, ar fully mirrored with LTR codes, zero as `0`. **−1: the wide-layout dossier placeholder reuses the search-field hint `leadsSearch` (`crm_leads_page.dart:407-414`), rendering a bare `Search leads…` where no search exists** — misleading copy in a real (captured) state |
| 8 | Single emphasized primary action | 2/2 | Idle: zero filled (correct — no competing CTA); empty-nocrm exactly one filled (`Connect Now`); empty-sync exactly one (`Sync Now`); sheets exactly one filled each |
| **Merit total** | | **14/16** | Pass on merit (≥ 12) |
| **C16 hard-reject cap** | header-icon search / one-path-per-task / borderless-light / no-duplicate-filled / no-permanent-pills / badges-clear / no-ALL-CAPS / above-fold+peek / hierarchy / zero-as-0 | **No cap** | ALL PASS: inline search collapsed to header-icon-only with written justification (brief §Single-affordance audit); one path per task; borderless light; one filled per state, Add never duplicated; pills only from status; `ACTIVE`→`Active`; first card + second visible @360; hierarchy held; zero `0` in code |
| **C17 U-cap** | ANY owner-file U-law violated caps at 8/16 | **CAP → 8/16** | **U5 FAIL (tablet Stage chip cut mid-word, §2).** The U1 > 5 threshold is the ONE sanctioned exception; no exception covers the tablet column break |
| **Final** | | **8/16** | **FAIL — capped (merit 14/16 would otherwise pass)** |

---

## ROUND-1 DEFECT LIST (each: image + region evidence · law/criterion · gating?)

**Gating defects (cap the verdict):**
1. **Tablet Stage status chip wraps one letter per line** — `leads_idle-6_light_1.0_en_768x1024.png`, left-panel Stage column (`A/ct/iv/e` + dot). U5 (never a label cut mid-word) → **C17 cap 8/16. GATING.** Owner-file layout: Stage `flex: 2` column (`crm_leads_page.dart:425`) + wrapping `AppStatusChip` (`:466-469`) inside a master constrained to ~half of 768 by the always-visible placeholder (`AppMasterDetailScaffold`, `:403-415`). Fix directions (presentation only): full-width master until a row is selected, or min-width/no-wrap chip column, or chip `softWrap: false` with column min-width — owner's choice, no logic change.

**Non-gating defects (scored or filed — do NOT cap beyond the single C17 hit above):**
2. **Wide-layout dossier placeholder shows the search hint `Search leads…`** — same tablet frame, right panel + code `:407-414` (`placeholder:` reuses `t.leadsSearch`). A find-aid string where no find-aid exists; misleads (criterion 7, −1 accounted in 14/16 merit). Non-gating. Fix: dedicated dossier-empty copy (new key, phase 9) or reuse an existing neutral string — never the search hint.
3. **Empty-nocrm sentence ellipsized at 360** — `leads_empty-nocrm_light_1.0_en_360x800.png` (`…manage your lead…` vs ARB `leadsNoCrmBody` `…manage your leads here`). Shared `AppEmptyState` caps message at 2 lines (`app_empty_state.dart:100-104`); the 90-char body does not fit and BEFORE wrapped it fully. Copy-length-vs-atom-cap mismatch; meaning survives. Non-gating observation for the owning phase (shorten/keep — copy keys are frozen, so likely keep + accept).
4. **No delete-confirm and no no-match PNGs in the capture set** — U7 delete and the `leadsCountN(0)` no-match state are code + structural-test evidence only (`_confirmDelete`, `_buildNoMatch`). Capture gap, not a behavior gap (same standing as vehicles-R1 U7). For the capture phase.
5. **Process artifacts (not screen defects):** `references/` + `AIRBNB_PATTERNS.md` UNMET per brief (precedent patterns used); kanban legacy atoms remain verbatim per migration §deviations (filed next slice); `crm-modules-sweep` / LOGIC follow-ups (no error-signal branch) owned elsewhere.

---

## The two answers

- **Would a first-time user know what to do in 3 seconds?** Yes on compact. `leads_idle-2_light_1.0_en_360x800.png`: `Leads / 2 leads` names the place, card 1 says `LD-1000`, `+971 50 100 0000`, `AED 12000`, `Active`, with `Call` sitting directly on the card. Next step is unambiguous: tap `Call`, or `+ Add Lead`, or the record for the dossier.
- **What would an Airbnb product designer reject here?** One blocking item: the tablet table at 768 renders the status pill unreadable (letters stacked vertically) — a list must stay legible at every matrix size, and the dossier placeholder parroting `Search leads…` compounds the wide-layout impression. Fix the Stage column (width/wrap/placeholder layout), add a tablet re-capture plus the missing delete-confirm/no-match PNGs, and this screen's 14/16 merit converts to a pass.

(End of file — round 1, 2026-10-22. Fresh reviewer, did not build. READ-ONLY except this file.)

---

# Fresh review ROUND 2 (PASS 16/16) — fix verification, 2026-10-22

**Role:** FRESH REVIEWER (round 2), did not fix. READ-ONLY except this append. Round 1 above kept verbatim. No code/tests/PNGs touched. No branch/commit/push. Never touched `71983229`.
**Branch:** `ui/list-crm` (same working tree as round 1 + fix commit).
**Fix claims verified against:** working-tree diff of `crm_leads_page.dart` (Stage `flex: 2 → 3` + matching `cellFlex: [3,2,2,3,2]` + `FittedBox(fit: scaleDown)` on the chip; placeholder `t.leadsSearch → t.leadsSelectLead`) + ARB diff (`leadsSelectLead` en/ar + gen) + regenerated PNGs (`leads_idle-6_light_1.0_en_768x1024.png`, `leads_idle-6_light_1.0_en_360x800.png` timestamps 5:08 PM; compact/1.3x/320/ar unchanged 4:48 PM).
**Images viewed (current PNGs):** `after-crm-leads/leads_idle-6_light_1.0_en_768x1024` (tablet) · `leads_idle-6_light_1.0_en_360x800` (compact 6) · `leads_idle-2_light_1.0_en_360x800` (compact 2) · `leads_idle-2_light_1.3_en_360x800` · `leads_idle-2_light_1.0_en_320x568` · `leads_idle-2_light_1.0_ar_360x800`. Code read-only (attribution only): `crm_leads_page.dart` `_buildWide`/`_buildTable`/chip; `app_en.arb`/`app_ar.arb` `leadsSelectLead`.
**Tests executed (read-only runs, no edits):** `crm_leads_list_characterization_test.dart` + `crm_leads_list_fixer_test.dart` → **15/15 passed**; `crm_after_leads_capture_test.dart` → **10/10 passed** (the regeneration harness for these PNGs). Full-suite `flutter test` still shows failures in `crm_lists_before_capture_test.dart` (BEFORE golden-capture infrastructure, out of scope for this surface verdict — not re-litigated here).

## (a) Tablet Stage chips — FIXED, pixel-verified
- Current tablet frame: all six Stage cells render whole pill `● Active` on one line — no per-letter stacking, no mid-word cut, no overflow markers. Header `Stage` + 6/6 `Active` chips legible at a glance.
- Residual truncation is only the sanctioned kind: Lead (`LD-10…`, `Custome…`), Phone (`+971…`), Value (`AED 1…`) use `…` ellipsis with the dossier as the full-record path (brief-kept table duality). The status label itself is never cut mid-word — the U5 violation is gone.
- U5 → **PASS** (owner-file layout). C17 cap **lifted**.

## (b) Dossier-empty placeholder — FIXED, copy-verified
- Current tablet right panel: centered muted `Select a lead to view details` — the dedicated `leadsSelectLead` key (`crm_leads_page.dart` `_buildWide` placeholder), no longer the search-hint reuse. Plain, friendly, accurate for the state (nothing to search; a selection is needed).
- ar key `اختر عميلاً لعرض التفاصيل` (ARB) — sane MSA, mirrors en 1:1. No ar tablet PNG in the set, but the string is a direct equivalent and LTR-locking is untouched by this change.
- Criterion 7 −1 → **restored**.

## (c) Regression check — compact / 1.3x / 320 / ar unchanged-and-clean
- idle-2 en 360: `Leads / 2 leads`, kanban + `+ Add Lead`, cards `LD-1000`/`Customer 1` with `● Active`, phone, `AED` value, `Call + ⋮` — intact, no clipped controls.
- idle-6 en 360: header magnifier + funnel + kanban + `+ Add Lead` (> 5 rule holds), 4 cards + peeking 5th — fold/peeks intact.
- 1.3x + 320px: two stacked cards, `Call + ⋮` intact, no overflow markers.
- ar 360: full mirror (title/subtitle/Add/cards/actions), `Active` pill left, `+971…`/`AED`/`LD-1000` LTR, `⋮` left of `اتصال` — intact.
- Rails/fold/pills/dark: no dark-scope change per brief (CRM keeps current theme wiring); no rail/nav edits in the diff; pills remain `AppStatusChip` sentence-case; search/filter sheets untouched (PNGs byte-unchanged timestamps). Nothing regressed.

## (d) U-law re-walk (deltas only; all else per round 1)
| Law | Round-2 |
|---|---|
| U0–U4, U6–U14 | Unchanged — still PASS as in round 1 (no logic/handler/route/key changes in the fix diff; only Stage flex + chip wrap + placeholder copy). U6 ellipsis observation (90-char `leadsNoCrmBody` truncated at 360) persists as the filed non-gating note, not a break. |
| U5 | **FAIL → PASS** — tablet chip whole on all 6 rows. |
| Tap budgets (§3) | Unchanged — Call ≤ 1 from list, all others ≤ before. |

## Rubric re-score (Airbnb 0–2 each, /16)
| # | Criterion | Round-1 → Round-2 |
|---|---|---|
| 1–5 | One task / headline hierarchy / whitespace / sheets / sticky-absent | 2/2 each, unchanged |
| 6 | Section structure | 1/2 → **2/2** (tablet density fixed; duality correct) |
| 7 | Plain friendly copy | 1/2 → **2/2** (dedicated dossier-empty copy en + sane ar) |
| 8 | Single emphasized primary | 2/2, unchanged |
| **Merit** | | **14/16 → 16/16** |
| **C16 hard-reject** | | **No cap** (unchanged — all pass) |
| **C17 U-cap** | | **Cap 8/16 → NO CAP** (zero U-law fails) |
| **Final** | | **16/16 — PASS** (≥ 12 gate met) |

## The two answers (round 2)
- **Would a first-time user know what to do in 3 seconds?** Yes on compact (unchanged) and now yes on tablet: six scannable `Active` rows left, explicit `Select a lead to view details` right.
- **What would an Airbnb product designer reject here?** Nothing gating. Residual non-gating notes carried forward unchanged: (i) empty-nocrm 90-char sentence ellipsizes at 360 (shared `AppEmptyState` 2-line cap; copy frozen); (ii) no delete-confirm / no-match PNGs in the capture set (code + structural tests are the evidence); (iii) `references/` + `AIRBNB_PATTERNS.md` UNMET per brief; kanban legacy atoms remain verbatim per migration doc.

## Remaining gating items: **ZERO**
Both round-1 gating defects are closed with pixel evidence: (1) tablet Stage chip whole ×6, no mid-word cut/overflow; (2) dossier-empty copy correct en + sane ar. No new fails, no caps. **Verdict: PASS 16/16 — clear to merge this surface.**

(End of file — round 2, 2026-10-22. Fresh reviewer, did not fix. READ-ONLY except this file.)
