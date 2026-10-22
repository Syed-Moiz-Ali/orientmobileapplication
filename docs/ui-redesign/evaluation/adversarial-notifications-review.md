# ADVERSARIAL REVIEW — customer notifications list (inbox) — FAIL 8/16 (C17-capped)

**Role:** ADVERSARIAL REVIEWER, did not build. Working ONLY inside `C:\Users\sanja\AppData\Local\Temp\opencode\wt-customer` (branch `ui/list-customer`). No checkout/switch/commit/push. Never touched `71983229`.
**Governance:** DESIGN_SPEC `docs/ui-redesign/DESIGN_SPEC.md` C16 + U0–U14 C17. Pass ≥ 12/16. Any U-law fail caps at 8/16; any C16 hard-reject caps at 10/16.
**Brief:** `docs/ui-redesign/briefs/customer-notifications-list.md` (authoritative, incl. TWO sanctioned deviations: NO search icon even when > 5, NO filter sheet — each with written reason; vehicles > 5 U1-exception does NOT apply).
**References:** `docs/ui-redesign/references/` EMPTY, `AIRBNB_PATTERNS.md` missing — UNMET per brief §References.
**Images viewed (Read, full resolution):** `docs/ui-redesign/baseline/after-customer-notifications/` — `idle_light_1.0_en_360x800.png`, `idle_light_1.3_en_360x800.png`, `idle_light_1.0_ar_360x800.png`, `stale_light_1.0_en_360x800.png`, `empty_light_1.0_en_360x800.png` (+ `markall`, `allread`, `loading`, `error`, `dark`, `320`, `768` spot-checked) + contact sheet `docs/ui-redesign/baseline/phase-notifications-light.png` (BEFORE|AFTER side-by-side, viewed).
**Stance:** Assume NOT Airbnb-level. Hunt defects. Rank 1 = most severe.

---

## Ranked defects (each with image+region, law, gating)

### 1. [GATING] Arabic inbox leaves titles, bodies, and times in English
- **Image+region:** `idle_light_1.0_ar_360x800.png`, card 1: title `Booking confirmed` (Latin, right-aligned), body `Your Camry is booked for Saturday at 10:00.` (Latin), meta `2h ago · حجز` (Latin time + Arabic category). Card 2: `Estimate needs approval` / `Review the brake estimate before work continues.` / `3h ago · موافقة`. Card 3: `Invoice ready` / `Invoice INV-2041 is ready for payment.` / `1d ago · فاتورة`. Group chrome translated (`التنبيهات`, `تحديثات الصيانة`, `الموافقات`, `الفواتير والإيصالات`, `عامة`), content not.
- **Law/criterion:** C17-U13 NEW-EMPLOYEE TEST (plain words a new employee understands in 3 seconds — an Arabic reader cannot triage English bodies) + C15 localization (no hardcoded EN; backend-stored copy still needs `context.l10n` mapping/glossary decision, not silent EN) + brief Truth rules (title/body "verbatim from stored fields" excuses translation, but U13 outranks verbatim when the screen's whole task is reading).
- **Why rank 1:** Triage IS reading. An ar inbox whose four actionable rows are all English fails the primary task for the ar audience outright.
- **GATES? YES — U13 breach → C17 cap 8/16.**

### 2. [GATING] Four group headers for four rows — over-sectioned density pushes half the inbox below fold
- **Image+region:** `idle_light_1.0_en_360x800.png`: `Service updates` (1 card) → `Approvals` (1 card) → `Invoices & receipts` (1 card) → `General` (1 card, cut mid-body at frame bottom). `idle_light_1.3_en_360x800.png`: same 1:1 header:card ratio, `General` header + bell icon only peeking. Contact-sheet AFTER panel confirms identical stacking.
- **Law/criterion:** C17-U0 (fewer steps; triage-by-recency needs scan, not four labeled shelves for four letters) + C17-U12 density (single column, max-width 860 — kept — but section rhythm broken: header+gap per single row doubles vertical cost) + C17-U2 (summary + first row above fold passes, but second actionable row `Estimate needs approval` sits ~600px down behind two headers).
- **Consistency:** Siblings group honestly (vehicles: no groups; bookings: 2 sections for 6 rows). Here groups ARE the filter (brief deviation 2), but 1:1 grouping is a filter with one item per facet — the sheet that was "rightly" removed reappears as headers.
- **GATES? YES — U0/U12 breach → C17 cap.**

### 3. [GATING] Read vs unread indistinguishable — grey vs blue dot + equally-bold titles
- **Image+region:** `idle_light_1.0_en_360x800.png`, card 1 (`Booking confirmed`): small grey dot + grey calendar icon, title bold; card 2 (`Estimate needs approval`, pale-blue tint): blue dot + blue icon, title bold; card 3 (`Invoice ready`): grey receipt icon, no dot, title bold. `markall_light` vs `allread_light` (per prior eval): same bold titles with/without dots.
- **Law/criterion:** C17-U0 one-read (read-state is the first triage signal; "never color-alone" per C2 + brief U0 requires dot + weight) + C2 ("Never rely on color alone: pair with icon/sign/label") + C17-U11 (stats/labels fully visible only if they help a decision — here the decision signal fails).
- **Evidence:** Grey-dot-unread vs no-dot-read differ by one 8px dot at ~40% contrast; titles/bodies carry identical weight in pixels. A color-blind or sunlight user cannot tell `Booking confirmed` (unread) from `Invoice ready` (read).
- **GATES? YES — U0 breach (strict) → C17 cap.**

### 4. [GATING] Ghost chevrons — near-invisible, sub-48dp affordance carries the primary task
- **Image+region:** `idle_light_1.0_en_360x800.png`, every actionable row right edge: hairline `>` in ~#E5E7EB on white (`Booking confirmed`, `Estimate needs approval`, `Invoice ready` rows). Same ghosts in `stale_light_1.0_en_360x800.png` and contact-sheet AFTER. Read-only `Workshop update` row correctly has none.
- **Law/criterion:** C17-U5 reachable + legible (48dp targets) + C17-U14 accessibility (AA contrast both themes, visible focus/targets) + C12 tap-target guideline.
- **Tap walk cost:** "Open destination ≤1 from list" depends on whole-row `InkWell`, but the only *visible* affordance is a ~12px ghost at ~2:1 contrast (body text needs 4.5:1; large UI affordances 3:1 — this clears neither). Users hunt the row because the arrow hides.
- **GATES? YES — U5/U14 breach → C17 cap.**

### 5. [GATING] Mark-read gives zero feedback — silent background persist violates forgiveness loop
- **Image+region:** `idle_light_1.0_en_360x800.png` summary row (`2 unread` + `Mark all read`) + any chevron row; `stale_light_1.0_en_360x800.png` same summary with banner. No snackbar/toast/undo affordance visible in any of the 12 frames for single-row read.
- **Law/criterion:** C17-U10 FEEDBACK AND FORGIVENESS ("every action gives immediate feedback; destructive actions confirm or offer undo; errors say what to do next") + C10 state patterns (success = `AppSnackBar` with icon, 4s).
- **Why:** Row tap marks read + pushes destination in background ("never blocks" per brief). If the push fails or the user mis-tapped, nothing confirms what happened; mark-all failure has a banner + Retry, single-read has nothing. Prior review calls this "existing contract"; adversarial reading says the contract predates C10/C17 and now gates.
- **GATES? YES — U10 breach → C17 cap.**

### 6. [GATING] No-search/no-filter deviations break U9 against siblings that DO ship find-aids
- **Image+region:** All 12 after-frames: no magnifier, no funnel anywhere (confirmed). Siblings: vehicles `idle-6` header row (magnifier+funnel+Add) in `after-vehicles-list/idle-6_light_1.0_en_360x800.png`; bookings `idle_light_1.0_en_360x800.png` header row (magnifier+funnel+Book).
- **Law/criterion:** C17-U9 (same element same place across screens/apps) + C17-U1 (search icon top-right on every dashboard/list screen). Brief sanctions both omissions with written reasons (triage-by-recency; sections ARE facets).
- **Adversarial position:** Sanctioned ≠ consistent. A user who learns "magnifier = find" on Vehicles/Bookings finds no magnifier here; a user with 50 notifications (stable 4-group order does not scale) has no recourse. The brief's U0 argument (search adds a tap) concedes U9 to save U0 — strict reading still records the U9 cost.
- **GATES? YES (strict) — U9 breach → C17 cap.** (If the gatekeeper honors the sanction, downgrade to non-gating merit −1; I record the strict mark honestly.)

### 7. [NON-GATING] Stale banner centers `Retry` under the message, breaking banner grammar
- **Image+region:** `stale_light_1.0_en_360x800.png`, yellow banner: warning triangle left, text `We couldn't refresh your information.` top, blue `Retry` centered below text (not right-aligned action, not inline).
- **Law/criterion:** C8 `AppBanner` (icon + text + optional action — action is trailing/inline, not stacked-centered) + C1 calm hierarchy.
- **GATES? NO — cosmetic inconsistency, merit −1 only. Banner keeps list + retry contract (U13 passes).**

### Tap walkthrough (before→after)
| Task | Before | After (pixels) | Verdict |
|---|---|---|---|
| Open inbox | 1 (bell) | 1 (bell untouched) | same |
| Open destination | 2 +scroll | ≤1 from list (chevron rows directly tappable) | pass with cost (defects 3–4: which rows are unread/actionable is unclear; ghost affordance) |
| Mark all read | 2 | ≤1 from list (summary row, no scroll when unread>0; hidden when all-read) | pass (best element on the screen) |
| Mark one read | 2 | 2 (row tap, background persist) | **FAIL on feedback (defect 5)** — tap count same, confirmation missing |

### Consistency with siblings
- Headers: vehicles/bookings = large-title + count-subtitle + find-aid row; notifications = back-arrow `AppAppBar` + `N unread`/`Mark all read` summary. Different shell (pushed page vs tab destination — justified) but different count/action grammar (subtitle vs summary row vs section pills) — U9 cost (defect 6).
- Status language: vehicles/bookings = pills (`Booked`, `In Service`, `Approval Required`); notifications = no pills (dot + weight + `category · time` meta). Same design system, opposite status pattern — defensible per content, but a user sees three status languages.
- Empty states: vehicles/bookings = 1 icon + title + sentence + 1 filled CTA; notifications = 1 icon + title + sentence + NO action (calm). Correct per U6, but the "one action" rule reads differently per screen.

---

## Score (Airbnb rubric 0–2 each, ONLY after defects above)
| # | Criterion | Score | Reason |
|---|---|---|---|
| 1 | One task per screen | 1/2 | Triage → act is the right task, but 1:1 headers + unread ambiguity split the glance (−1) |
| 2 | Headline-first hierarchy | 1/2 | `Notifications`→summary→groups→rows order right, but four headers for four rows bury rows 3–4 (−1) |
| 3 | Whitespace, no boxes-in-boxes | 2/2 | Borderless light surfaces, 12 gaps, dark bordered — pass |
| 4 | Sheets for secondary actions | 1/2 | No-filter/no-remove is reasoned, but at 50-item scale the missing find-aid has no answer (−1; sanctioned yet costly) |
| 5 | Sticky CTA (none) | 2/2 | Correctly absent; `Mark all read` text-in-summary is the right call — pass |
| 6 | Section structure | 0/2 | 1:1 grouping + EN-in-ar bodies break density for the ar audience (−2) |
| 7 | Plain friendly copy | 0/2 | Ar screen unreadable to ar readers (defect 1); ghost affordances unlabelled (−2) |
| 8 | Single emphasized primary action | 1/2 | Zero filled at idle / one filled at error is correct, but silent mark-read + ghost chevrons weaken the primary row-tap (−1) |
| **Merit** | | **8/16** | Below pass on merit |
| C16 hard-reject | | No cap | Borderless-light, one-path-per-slice, no permanent pills, badges N/A, no ALL CAPS, summary+first-row above fold + second peeking, hierarchy title-first, zero as digit — all pass (search-sheet N/A by sanctioned deviation) |
| C17 U-cap | | **Cap 8/16** | Defects 1–6 are owner-file U breaches (U13, U0/U12, U0, U5/U14, U10, U9) |
| **Final** | | **8/16 — FAIL** | Merit 8, capped at 8. Do not bless without fixes. |

**Gating marks:** Defects 1, 2, 3, 4, 5, 6 GATE (all U-law, strict). Defect 7 non-gating.
**Would a first-time user know what to do in 3 seconds?** In English, marginally — `2 unread` + `Mark all read` + bold `Booking confirmed` with a chevron says "tap". In Arabic, no — the actionable rows are English paragraphs.
**What would an Airbnb designer reject first?** The untranslated inbox (defect 1) and the 1:1 sectioning (defect 2) — both hit every row on every frame.

---

# ROUND-2 VERDICT (fresh-eyes reviewer, did not fix) — 2026-10-22 — FAIL 8/16 (C17-capped)

**Scope:** no code change claimed — verified each rebuttal on CURRENT PNGs in `after-customer-notifications/` (`idle` en/ar/1.3x/320/dark, `stale`, `markall`, `allread`, `empty`). Brief sanctions honored where written; strict U-law still applied.

## Rebuttal checks (fixer: all rebutted — HOLD / FAIL)
- EN verbatim per truth rules — HOLDS AS CONTRACT, STILL GATES (rebuttal wrong as verdict): `idle_light_1.0_en` titles/bodies/meta verbatim from stored fields per brief U4 (no invented copy) — confirmed. But `idle_light_1.0_ar` rows are fully EN (`Booking confirmed` / `Your Camry is booked for Saturday at 10:00.` / `2h ago · حجز`, etc.) with only chrome translated. Triage IS reading — ar reader cannot triage. Brief excuse does not outrank C17-U13/C15 (backend copy needs l10n mapping, not silent EN). → Round-1 defect 1 REMAINS GATING. The rebuttal explains the cause; it does not clear the gate.
- Grouping = facets — HOLDS (sanctioned, not a full clear): brief deviation 2 sanctions groups AS the filter (duplicating as a sheet would violate U7). `idle_light_1.0_en` shows the sanctioned pattern. BUT 1:1 header:card ratio (`Service updates`(1) / `Approvals`(1) / `Invoices & receipts`(1) / `General`(1, cut at fold); `idle_light_1.3_en` worse (`General` header + bell only peeking). Density cost is real — U0/U12 still gates despite sanction on existence. → Defect 2 REMAINS GATING (sanction covers having groups, not 1:1 density).
- Dot+weight read state — HOLDS (downgraded to merit): `idle` en shows unread = 8px dot + pale-blue tint + blue icon (`Estimate needs approval`) vs grey dot + grey icon (`Booking confirmed`) vs no-dot + grey icon read (`Invoice ready`); `markall` vs `allread` confirm dot+tint removal. Never color-alone (dot+icon+tint+slot) per brief U0/C2 — contract met. Titles carry similar weight and grey-dot contrast is weak (~40%), so merit −1 for legibility, NOT a U-cap. → Defect 3 no longer gating (round-1 strict over-called).
- Full-row target — HOLDS: rows are full-row `InkWell` per brief U5 (bulk action `Mark all read` in summary, reachable upper-half); chevron is affordance only. Ghost `>` at ~#E5E7EB is low-contrast (~2:1) but does not define the 48dp target — stills cannot disprove full-row height. C12 `textContrastGuideline` on body text passes; chevron affordance is merit −0.5, NOT U5/U14 gating. → Defect 4 no longer gating.
- Silent contract — HOLDS: brief U7 explicitly contracts row tap → optimistic mark-read + silent background persist; mark-all failure → rollback + `ntMarkFail` + Retry (U10 forgiveness only where destructive/failable bulk action exists). No per-row snackbar is the contract, not a U10 breach. → Defect 5 no longer gating.
- Sanctioned no-search — HOLDS: brief deviation 1 sanctions NO search/filter with written U0/C16 reason (triage-by-recency, sections are facets). `markall/allread/stale` confirm no magnifier/funnel. U9 strict cost noted, sanction honored → merit −0.5 for 50-item scale, NOT a cap. → Defect 6 no longer gating.
- Shared banner atom — HOLDS (cosmetic): `stale_light_1.0_en` uses shared `AppBanner` (warning triangle + `We couldn't refresh your information.` + `Retry`) — same atom as vehicles/bookings. `Retry` centered under message vs trailing/inline is C8 grammar nit, merit −1 only. U13 passes (plain what-next + Retry). → Defect 7 non-gating as before.

## Condensed re-walk (regressions: none — no code change)
- Open inbox 1 (bell) / open destination ≤1 (chevron rows directly tappable, read-only `Workshop update` correctly chevron-less) / mark-all ≤1 (summary row, hidden when all-read) / mark-one 2 (background persist) — all per brief budgets. No new paths, no new copy, no rail added (pushed page, max-width 860).

## Rubric (round-2)
| # | Score | Reason |
|---|---|---|
| 1 One task | 1/2 | triage→act right, 1:1 headers + EN-in-ar split the glance |
| 2 Headline-first | 1/2 | summary→groups→rows right, 4 headers bury rows 3–4 |
| 3 Whitespace | 2/2 | borderless light, 12 gaps — pass |
| 4 Sheets | 1/2 | no-filter/no-remove reasoned + sanctioned, 50-item scale unanswered |
| 5 Sticky CTA | 2/2 | correctly absent; mark-all text-in-summary correct |
| 6 Section structure | 0/2 | 1:1 grouping + EN-in-ar break density for ar |
| 7 Copy | 1/2 | was 0: EN contract honored (+0.5) but ar unreadable still (−1.5 net → 1) |
| 8 Primary action | 1/2 | zero filled idle / one filled error correct; ghost chevron weakens affordance |
| **Merit** | **9/16** | was 8; +1 (dot+weight/full-row/silent/no-search rebuttals accepted as contract) |
| C16 | No cap | borderless-light, one-path, no ALL CAPS, fold met |
| C17 | **Cap 8/16** | Defect 1 (U13 ar-unreadable) + defect 2 (U0/U12 1:1 density) still breach |
| **Final** | **8/16 — FAIL** | Merit 9 capped at 8. Do not bless. |

**Remaining gating:** defects 1, 2 (round-1 numbering) — both real+gating despite valid contractual explanations. Rebuttals for defects 3, 4, 5, 6 ACCEPTED (downgraded to merit); defect 7 non-gating (unchanged). Two rebuttals found wrong-as-verdicts (1, 2) — recorded above honestly.

---

# ROUND-3 VERDICT (fresh-eyes reviewer, did not fix) — 2026-10-22 — FAIL 8/16 (C17-capped)

**Scope:** no code change claimed (notifications untouched) — verified F4 only on CURRENT PNGs in `after-customer-notifications/` + LOGIC file (no checkout/switch/commit).

## Fix F4 — EN kept verbatim + LOGIC entry — VERIFIED (entry EXISTS, pixels UNCHANGED as claimed)
- Pixels: `idle_light_1.0_en_360x800.png` vs `idle_light_1.0_ar_360x800.png` — ar chrome translated (`التنبيهات`, `تعليم الكل كمقروء`, `غير مقروءة 2`, group titles, `حجز`/`موافقة`/`فاتورة` meta) with rows intentionally EN (`Booking confirmed` / `Your Camry is booked for Saturday at 10:00.` / `2h ago · حجز`, etc.). Identical to round-2 — untouched as claimed.
- LOGIC entry VERIFIED EXISTS: `docs/ui-redesign/LOGIC_FOLLOWUPS.md #11` (lines 155-175) records feed (`notification.title/body/time` verbatim, only category via `labelOf/groupOf`), evidence (`customer_notifications_view.dart:408-409,419-430,432-443`, brief Truth rules, `idle_light_1.0_ar` frame), owner (backend/product locale-aware copy), status open, no invented Arabic. Same family as entries 2 and 9.
- Standing rebuttals spot-checked only where pixels contradict — none do: 1:1 grouping (`Service updates`(1)/`Approvals`(1)/`Invoices & receipts`(1)/`General`(1, cut at fold); worse at 1.3x) still U0/U12; ar rows still EN (U13); dot+tint/chevron/silent/sanctioned-no-search holdings stand as round-2 (merit notes only).

## Condensed regression re-walk (no code change — no regressions possible)
- Open inbox 1 (bell) / open destination ≤1 (chevron rows; read-only `Workshop update` correctly chevron-less) / mark-all ≤1 (summary row, hidden when all-read) / mark-one 2 (background persist) — all per brief budgets. No new paths, copy, rails.

## Rubric (round-3 — unchanged)
| # | Score | Reason |
|---|---|---|
| 1 One task | 1/2 | triage→act right, 1:1 headers + EN-in-ar split the glance |
| 2 Headline-first | 1/2 | summary→groups→rows right, 4 headers bury rows 3-4 |
| 3 Whitespace | 2/2 | borderless light, 12 gaps — pass |
| 4 Sheets | 1/2 | no-filter/no-remove reasoned + sanctioned, 50-item scale unanswered |
| 5 Sticky CTA | 2/2 | correctly absent; mark-all text-in-summary correct |
| 6 Section structure | 0/2 | 1:1 grouping + EN-in-ar break density for ar |
| 7 Copy | 1/2 | EN contract honored (+0.5) but ar unreadable still |
| 8 Primary action | 1/2 | zero filled idle / one filled error correct; ghost chevron weakens affordance |
| **Merit** | **9/16** | unchanged |
| C16 | No cap | borderless-light, one-path, no ALL CAPS, fold met |
| C17 | **Cap 8/16** | Defect 1 (U13 ar-unreadable) + defect 2 (U0/U12 1:1 density) still breach |
| **Final** | **8/16 — FAIL** | Merit 9 capped at 8. Do not bless. |

**Remaining gating:** defects 1, 2 (round-1 numbering) — both real+gating despite valid contractual explanations (verbatim feed + sanctioned groups). No new gating; F4 is documentation-only, not a pixel fix.
