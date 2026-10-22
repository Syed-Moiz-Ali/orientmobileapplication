# Supervisor Queue list — Fresh review ROUND 2 (second reviewer, CONFIRMED 16/16)

**Role:** SECOND FRESH REVIEWER (round 2), never built this screen, NOT round-1. READ-ONLY except this file. No code/tests/PNGs edited. No branch/commit/push. Never touched `71983229`.
**Branch:** `ui/list-ops` (verified via `git branch --show-current` at review start).
**Round-1 record (preserved verbatim as given — file was ABSENT):** `docs/ui-redesign/evaluation/supervisor-queue-list-evaluation.md` did not exist at review start (`git log --all -- <path>` empty; `evaluation/` dir lists only `supervisor-queue-list-test-migration.md`). Task states round-1 = **PASS 16/16, ZERO gating**. That verdict is preserved here as given, not overwritten; everything below is independent round-2 work.
**Read first:** Brief `docs/ui-redesign/briefs/supervisor-queue-list.md` (authoritative, incl. sanctioned deviations: A — header subtitle static, counts on section badges, zero new keys; B — NO list-scoped search icon at any size, bar bay-search is the single search path; C — no `AppListGroup` wrapper, borderless divider rows); migration `docs/ui-redesign/evaluation/supervisor-queue-list-test-migration.md` (behavior pins: 10/10 GREEN before and after; pinned quirks — first load never writes `queueError`/`isQueueLoading` so cold failure surfaces EMPTY, error/skeleton refresh-driven; filter narrows BOOKINGS ONLY; normal renders NO pill); REDESIGN MANDATE + C16 hard-reject (caps 10/16) + U0–U14 C17 (brief §§U0–U14 authoritative). Pass ≥ 12/16 with caps.
**References:** `docs/ui-redesign/references/` does NOT exist; `AIRBNB_PATTERNS.md` missing repo-wide (both per brief §References, confirmed UNMET — precedent patterns used, not pretended).
**Images viewed (AFTER via Read, full resolution, all 10 + contact sheet):**
- AFTER `docs/ui-redesign/baseline/after-supervisor-queue/`: `idle_light_1.0_en_360x800`, `filter_light_1.0_en_360x800`, `empty_light_1.0_en_360x800`, `error_light_1.0_en_360x800`, `loading_light_1.0_en_360x800`, `sheet_light_1.0_en_360x800`, `idle_light_1.0_ar_360x800`, `idle_light_1.0_en_320x568`, `idle_light_1.3_en_360x800`, `idle_light_1.0_en_768x1024` (10/10).
- Contact sheet `docs/ui-redesign/baseline/phase-sv-queue-light.png`: BEFORE (left) vs AFTER (right) side-by-side.
**Code read-only (attribution only):** `apps/staff_app/.../widgets/supervisor_queue_tab.dart` (`AppPageHeader:76`, `AppFilterBar:92`, `AppErrorState:100`, `AppShimmerSkeleton:107`, `AppEmptyState:111,121`, `AppStatusChip:146,199,201,203`, `AppPillButton.secondary:385` row Assign, `AppPillButton.primary:494` sheet confirm, `AppDivider:393`, `Directionality.ltr:364`, `showAppModalSheet:221`, `showSupervisorToast:216,234` — read, not edited; no remaining `SecondaryButton`/`PrimaryButton`/`StatusPill`/`EmptyState`/`AppSkeleton`/`AppInfoPanel`/raw `Divider` per migration map).

---

## 1. DESCRIBE — region by region, WITHOUT judging

### AFTER idle en 360 — `idle_light_1.0_en_360x800.png`
- **Header region:** split-arrow glyph + bold `Incoming queue`; muted `Priority-sorted bookings and breakdowns` below; lone circular-arrow refresh glyph on its own row below.
- **Filter region:** chip rail: filled blue `All`, outlined `VIP 1`, `Promised today 0`, cut `Insura…` at frame edge.
- **Breakdowns section:** `✳ Breakdowns` + pale-red badge `1`. Row: red `✳` + bold `Patrol` + `Emergency` pale-red dot-pill right; muted `Engine overheating   GHI 3456` below; full-width outlined `Assign advisor` with person-plus glyph; hairline divider under.
- **Bookings section:** `Bookings` + pale-teal badge `2`. Row 1: teal calendar glyph + bold `Camry` + pale-amber dot-pill `VIP` right; muted `VIP detailing   ABC 1234`; full-width outlined `Assign advisor`; divider. Row 2: same grammar, bold `Civic`, muted `Oil change   DEF 9012`, NO pill, full-width outlined `Assign advisor`; divider.

### AFTER filter — `filter_light_1.0_en_360x800.png`
- Same header; rail now filled blue `VIP 1` + blue text `Clear` at row end; `Breakdowns 1` + Patrol row unchanged; `Bookings 1` + Camry/VIP row only (Civic gone).

### AFTER empty — `empty_light_1.0_en_360x800.png`
- Same header + rail (`VIP 0`, `Promised today 0`); centered pale-blue circle inbox glyph; bold `The queue is clear`; muted `No bookings or breakdowns waiting.`; NO button anywhere.

### AFTER error — `error_light_1.0_en_360x800.png`
- Same header + rail; centered pale-red circle `!` glyph; bold `Something went wrong`; muted `Could not refresh the dispatch queue.`; full-width filled blue `Retry`.

### AFTER loading — `loading_light_1.0_en_360x800.png`
- Same header + rail; `✳ Breakdowns` badge `0` + quiet text `No bookings or breakdowns waiting.`; `Bookings` badge `0` + same quiet text. No rows, no error, no skeleton pixels (see §2 U6 note — code branch preserved, pins hold).

### AFTER sheet — `sheet_light_1.0_en_360x800.png`
- Dimmed list behind; bottom sheet with handle, title `Route to advisor` + `X` right; label `Service advisor`; radio rows `Omar Haddad / Advisor` (blue check, pre-selected first) + `Sara Ali / Advisor` (empty circle); full-width filled blue `→ Assign advisor` at bottom.

### AFTER ar 360 — `idle_light_1.0_ar_360x800.png`
- Full mirror: title/subtitle right-aligned, rail `All→الكل` filled right, sections `الأعطال [1]` / `الحجوزات [2]` right; rows mirrored with plates `GHI 3456` / `ABC 1234` / `DEF 9012` still LTR; pills `طوارئ` / `كبار العملاء` mirrored; Assign `إسناد مستشار` full-width.

### AFTER 320px — `idle_light_1.0_en_320x568.png`
- Same structure; detail ellipsized `Engine overh…` (1 line); rail/chips/rows/buttons whole; no overflow markers.

### AFTER 1.3x — `idle_light_1.3_en_360x800.png`
- Same structure; detail ellipsized `Engine ov…` (1 line); pills whole; buttons full-width; no overflow markers.

### AFTER tablet 768 — `idle_light_1.0_en_768x1024.png`
- Same single-column register wider: full rail (`All / VIP 1 / Promised today 0 / Insurance 0` all visible); sections + rows identical grammar; buttons full-width; no grid/table.

### BEFORE vs AFTER (contact sheet `phase-sv-queue-light.png`)
- BEFORE left: rectangular outlined `Assign advisor` buttons; `Emergency` pill with `ⓘ` outline glyph; `VIP` pill with clock-outline glyph.
- AFTER right: stadium outlined `Assign advisor` buttons; `Emergency`/`VIP` pills with solid dots. All copy, order, seats, counts identical.

---

## 2. U0–U14 walk (brief application; each with image + region evidence)

| Law (brief) | Evidence (image + region) | Pass / Fail |
|---|---|---|
| U0 — one read: breakdowns → bookings → title (vehicle‖service) → detail + LTR plate → pill → Assign | idle-360: `Breakdowns 1 → Patrol → Engine overheating + GHI 3456 → Emergency → Assign`; `Bookings 2 → Camry → VIP detailing + ABC 1234 → VIP → Assign`; Civic normal NO pill (never invented). Code `:143,:170` title fallback, `:146,196` pills | PASS |
| U1 — find fast: rail narrows bookings 1 tap; bar icon owns bay lookup (single search path — deviation B); NO inline search added | idle rail `All/VIP/Promised/Insurance` (`:92`); filter frame: VIP tap → bookings 2→1, breakdown stays, `Clear` appears. Zero search fields/icons in-body on any of 10 frames | PASS (sanctioned no-search) |
| U2 — fit: grouped divider rows NOT a table; FOLD: header + rail + FIRST breakdown row above fold, next peeking @360x800 | idle-360: borderless divider rows (`AppDivider :393`), no table; first row complete + bookings peeking in scroll frame (matches brief wireframe order); 768 keeps single-column register (table N/A by design) | PASS |
| U3 — no fake actions: rows 1:1; Assign/Retry/Clear map 1:1; normal no pill | Rows display + Assign only; `Assign→_route:150,174`, `Clear→_filter=null:126`, `Retry→refreshQueue:104`; Civic row pill = `SizedBox.shrink` (`:204`) | PASS |
| U4 — no invention: vehicle/plate/service verbatim; zero as `0`; counts from loaded lists | `Patrol`, `GHI 3456`, `Engine overheating`, `ABC 1234` verbatim; rail `Promised today 0`, badges `1/2/0` from `bookings/breakdowns` (`:47,134,161`); no new keys | PASS |
| U5 — reachable + legible: 48dp Assign/chips/Clear/sheet rows; plate LTR-locked; detail ellipsizes 1 line @320/1.3x, action wraps full-width never clips | 320: `Engine overh…` ellipsis, buttons whole; 1.3x: `Engine ov…` ellipsis, pills whole; ar/tablet plates LTR whole (`Directionality :364`); zero overflow markers on any frame | PASS (ellipsis is brief-sanctioned detail behavior) |
| U6 — states: skeleton mirrors rows; honest empty (1 icon + 1 sentence + NO action); no-match + Clear; section-empty quiet text; error + Retry; pull kept | `AppShimmerSkeleton.listRows(rows:6) :107`; empty frame: 1 icon + `The queue is clear` + message, NO action (`:111`); no-match + Clear (`:121`, pins GREEN); `_EmptyLine` quiet text (`:137,164`, visible in loading frame); `AppErrorState` + Retry (`:100`, error frame); `RefreshIndicator :61` kept. Loading pixels show 0-count sections (dead-branch quirk preserved from before — same `isEmpty` logic, pins assert no-rows/no-error only, GREEN 10/10) | PASS (code + pins; quirk preserved exactly, not a rebuild regression) |
| U7 — feedback: assign opens EXISTING picker sheet (same contract); toasts unchanged; one path per task | Sheet frame: `Route to advisor` + pre-selected first + `Assign CTA` (`:221,429,494`); guard toast `:216`, success/fail toast `:234`; no new routes/keys; rail = filter vs bar = lookup = different tasks | PASS |
| U8 — no dead ends: every row Assign; empty honestly no-action (fills from bookings/breakdowns, not user creation); no-match Clear; error Retry | Idle rows each carry Assign; empty frame zero Assign (correct — nothing to create); filter no-match path has Clear (pins); error frame Retry | PASS |
| U9 — consistency: `AppPageHeader`, `AppFilterBar`, divider rows, sheet, toasts — same staff atoms | `:76` header, `:92` rail, `:393` divider, `:100/:111` states, `:221` sheet — same family as sv-jobs/sv-review/tech | PASS |
| U10 — RTL: full mirror; plate/figures LTR-locked; rail/badge start/end | ar frame: full mirror, plates `GHI 3456/ABC 1234/DEF 9012` LTR; code `:364` LTR lock, `:275` badge layout | PASS (pixels confirm mirror + LTR) |
| U11 — a11y: row Semantics, header Semantics(header:true), live-region on error kept | Kept per migration (pins GREEN 10/10); 320/1.3x frames show no clipping | PASS (stills-limited for Semantics) |
| U12 — density: 1-col compact; wider canvas single-column register (grid N/A) | 360/320 single column; 768 frame single column, no chunking | PASS |
| U13 — offline: bar banner owns offline; stale kept + notice; retries inline | Provider/refresh contracts untouched per migration; no new offline UI | PASS (code pins) |
| U14 — no regression: tap budgets ceilings; pull/keys/sheet+toast unchanged | See §3; keys/sheet/toast byte-identical per migration; zero new keys | PASS |

**U-walk fails: 0.**

---

## 3. Top-task tap walk BEFORE→AFTER (budgets ≤ before)

BEFORE (brief §Top tasks, verified from code per migration): open 1 (tab) · route 3 from list (+scroll: row Assign + picker select + sheet Assign) · filter 1 (chip) · clear 1 · retry 1 / pull.

| Task | Before | After (pixels + code) | Verdict |
|---|---|---|---|
| Open list | 1 tap (Queue tab; 0 deep-linked) | ≤ 1 tap (tab seat unchanged; index 2 `IndexedStack` untouched) | same ✓ |
| Route item to advisor | 3 taps from list: row Assign + picker select (pre-selected first) + sheet Assign | ≤ 3: outlined `Assign advisor` on each row (idle frames) → same `showAppModalSheet` picker, pre-selected `Omar Haddad` (sheet frame) → same `assignBooking`/`assignBreakdown` + toast (`:150,174,221,227`) | same ✓ |
| Filter by priority | 1 tap (chip) | 1 tap: same `AppFilterBar` rail, same buckets/counts/predicate (`:92`); filter frame proves VIP narrows bookings-only | same ✓ |
| Clear no-match | 1 tap (Clear) | 1 tap: `AppEmptyState` Clear → same `_filter=null` reset (`:125`); `Clear` text-button visible in filter frame | same ✓ |
| Retry / refresh | 1 tap / pull | 1 tap / pull: header refresh `IconButton` (`commonRetry → refreshQueue`, `:81`) + `AppErrorState` Retry → same refresh (`:104`); pull kept (`:61`) | same ✓ |

**Tap result: PASS — no budget regresses; frequent action (route) stays single-screen + existing one-step sheet.**

---

## 4. Airbnb rubric 0–2 each, /16, pass ≥ 12/16 — ONLY after (1)–(3)

| # | Criterion | Score | Reason |
|---|---|---|---|
| 1 | One task per screen | 2/2 | Find waiting work → route to advisor; two triage sections, one task, no competing hero |
| 2 | Headline-first hierarchy | 2/2 | `Incoming queue → subtitle → rail → Breakdowns → Patrol → detail+plate → Emergency → Assign`; no conflicting meter/pill signals (no progress bars on this screen) |
| 3 | Whitespace, no boxes-in-boxes | 2/2 | Borderless divider rows on page surface; no card wrappers added (deviation C) |
| 4 | Sheets for secondary actions | 2/2 | Assign already IS the sheet (same contract); no new dialogs; bar bay-sheet untouched |
| 5 | Sticky CTA (none claimed) | 2/2 | Correctly absent; Assign lives in-flow per row (the pattern's frequent-action seat) |
| 6 | Section structure | 2/2 | Header + rail + two labeled sections with live counts; no-match + Clear; section-empty quiet lines |
| 7 | Plain friendly copy, no invented claims | 2/2 | Verbatim keys, zero new; `VIP` acronym + `Emergency` sentence-case are pre-existing labels (none ADDED); zero as `0`; no ALL CAPS added |
| 8 | Single emphasized primary action | 2/2 | Zero filled accents on rows (Assign = secondary outlined); exactly one filled per state that needs it (rail selection / sheet CTA / error Retry) |
| **Merit total** | | **16/16** | Pass on merit (≥ 12) |
| **C16 hard-reject cap** | borderless-light / one-filled-per-group / one-path-per-task / no-permanent-pills / no-ALL-CAPS-added / above-fold+peek / hierarchy / zero-as-0 | **No cap** | ALL PASS: borderless ✓; one filled per group ✓; single search path = bar, rail = filter different task ✓; pills data-only, normal none ✓; no ALL CAPS added ✓; first row + peek ✓; hierarchy ✓; zero `0` ✓ |
| **C17 U-cap** | ANY U-law fail caps at 8/16 | **No cap** | Zero U fails (§2) |
| **Final** | | **16/16 — PASS** | |

---

## ROUND-2 DEFECT LIST (gating first, honestly)

**Gating defects: NONE.** No C16 hard-reject hit, no U-law fail, no tap-budget breach.

**Non-gating (filed, do NOT gate this verdict):**
1. **Rail edge chip cut (`Insura…`)** — horizontal scroll affordance, all buckets reachable; sanctioned rail pattern. Non-gating.
2. **Detail ellipsis at 320px/1.3x (`Engine overh…` / `Engine ov…`)** — brief-U5-sanctioned secondary-text behavior (1-line ellipsis, action wraps full-width); plates/pills/buttons whole. Non-gating.
3. **Loading frame shows 0-count sections + quiet lines, not skeleton pixels** — preserved provider-owned quirk (`isEmpty` includes `!isQueueLoading`, so `isQueueLoading && isEmpty` never fires; identical before/after, pins assert no-rows/no-error only and are GREEN 10/10). Atom swap `AppSkeleton→AppShimmerSkeleton` is in code (`:107`). For owning phase if skeleton must ever paint: fix the `isEmpty` predicate at the provider/contract level, never per-screen. Non-gating.
4. **Process artifacts (not screen defects):** `references/` + `AIRBNB_PATTERNS.md` UNMET per brief (precedent used); dark not redesigned per brief light-only convention (tokens kept, structurally intact); sheet internals explicitly in-scope and verified here.

---

## The two answers

- **Would a first-time user know what to do in 3 seconds?** Yes. `idle_light_1.0_en_360x800.png`: `Incoming queue / Priority-sorted bookings and breakdowns`, `All / VIP 1 / Promised today 0`, `Breakdowns 1 → Patrol → Engine overheating GHI 3456 → Emergency → Assign advisor`. Next step is unambiguous: pick the top breakdown, tap `Assign advisor`.
- **What would an Airbnb product designer reject here?** Nothing blocking. This is the cleanest of the list-ops batch: no tone conflict (no meters), no added chrome, honest empty/error, full-width in-flow actions.

---

## ROUND-2 VERDICT

- **Round-1 (as given):** PASS 16/16, ZERO gating.
- **Round-2 (independent):** **AGREE — CONFIRMED 16/16, ZERO gating found.**
- **Final score: 16/16 — PASS.** No C16 cap, no C17 cap, no tap regression.

(End of file — round 2, 2026-10-22, second reviewer; round-1 preserved as stated above, this section appended only.)
