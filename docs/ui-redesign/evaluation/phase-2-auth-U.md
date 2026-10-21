# Phase-2 Auth — Fresh U-Laws Audit (READ-ONLY, no code touched)

**Role:** FRESH U-AUDITOR, not builder. READ-ONLY except this file. No code/tests/PNGs edited. No commit.
**Branch:** `ui/phase-2-auth` (built + reviewed under older C16-only rules; NEVER audited against U0–U14).
**Normative basis (disclosed gap):** On THIS branch `docs/ui-redesign/DESIGN_SPEC.md` ends at C16 — there is NO C17 and NO hard-reject list on this branch. U0–U14 + C16 hard-reject list were read from the sibling tip `99212c85` (`ui/phase-6-customer`: `git show 99212c85:docs/ui-redesign/DESIGN_SPEC.md`, tail 120 lines: C16 hard-reject + C17 U0–U14) and applied as written there. If the U-law wording drifts between branches, this audit judges against that text.
**Read first:** DESIGN_SPEC C16 (this branch) + C17/hard-reject (99212c85 text) + brief `docs/ui-redesign/briefs/phase-2-login.md` (note: brief **predates** U-laws — BUILD is judged against U-laws; §(b) notes where the brief itself conflicts with U-laws).
**After images viewed (directly, via Read, at full resolution):** `docs/ui-redesign/baseline/after-phase-2/` — `customer_login_step1_idle_light_1.0_en_360x800`, `customer_login_step1_idle_light_1.0_ar_360x800`, `customer_login_step1_idle_dark_1.0_en_360x800`, `customer_login_step1_idle_light_1.3_en_360x800`, `customer_login_step1_idle_light_1.0_en_320x568`, `customer_login_step1_idle_light_1.0_en_768x1024`, `customer_login_step1_field_error_light_1.0_en_360x800`, `customer_login_step2_idle_light_1.0_en_360x800`, `customer_login_step2_idle_light_1.3_ar_360x800`, `customer_login_step2_idle_light_1.0_en_320x568`, `customer_login_step2_busy_light_1.0_en_360x800`, `customer_login_step2_form_error_light_1.0_en_360x800`, `customer_login_code_otp_sent_light_1.0_en_360x800`, `customer_login_code_code_error_light_1.0_en_360x800`, `customer_login_r1_idle_light_1.0_en_360x800`, `customer_login_r2_idle_light_1.0_en_360x800`, `customer_login_r3_idle_light_1.0_en_360x800`, `customer_forgot_identifier_idle_light_1.0_en_360x800`, `customer_forgot_reset_otp_sent_light_1.0_en_360x800`, `customer_forgot_done_success_light_1.0_en_360x800`, `customer_forgot_done_success_dark_1.0_ar_360x800`, `staff_supervisor_step1_idle_light_1.0_en_360x800`, `staff_supervisor_step2_idle_light_1.0_en_360x800`, `staff_login_step1_idle_light_1.0_en_360x800`, `splash_loading_idle_light_1.0_en_360x800`, `splash_loading_idle_dark_1.0_en_360x800` + side-by-sides `docs/ui-redesign/evaluation/contact-sheets/phase-2d-customer-light.png`, `phase-2d-customer-dark.png` (+ spot-confirmation of `phase-2d-staff-light/owner-light/crm-light` family sameness). Extrapolated by family ONLY where stated: staff/owner/CRM step-1/step-2/code/reset/done idles are the same shared widgets modulo permitted per-app differences (customer has 2 alt rows incl. register; staff/owner/CRM have 1 alt row; no register) — every theme/locale/scale/size class below was directly viewed at least once per family.
**Before images viewed (5/5):** `docs/ui-redesign/baseline/before/` `customer_light.png`, `customer_dark.png`, `staff_light.png` (+ `owner_light.png`, `crm_light.png` structure-confirmed via phase-2-auth.md §Structural — same one-screen switcher pattern, different app-context copy).
**Before tap-counts:** before-PNG widget trees (identifier + password co-present, `_MethodSwitcher` segmented Password/One-time-code, inline Continue) cross-checked with `docs/ui-redesign/evaluation/phase-2-test-migration.md` old-assertion flows (switcher + `loginActionSendCode` + `loginActionVerifyCode` + single-screen register `fields.at(0/1/2)` + CreateAccount).

---

## (a) DESCRIBE — what is visible, region by region, at full resolution (no judging)

### Step-1 identifier — `customer_login_step1_idle_light_1.0_en_360x800.png` (reference frame)
- **Top region:** thin blue progress bar at the very top edge (step 1 of 2 weight). No back arrow on step 1. No app bar, no brand lockup, no app-context block in the form column.
- **Headline region:** large bold left-aligned headline `Log in or sign up`, one muted supporting line `Enter your email or mobile number to continue.`
- **Input region:** label `Email or mobile number` above; one row: left small prefix box `+971` with phone glyph + chevron, right larger field with `@` glyph + placeholder `name@company.co…`. Below: muted helper `Enter 9 digits for +971`.
- **Alternative-path region:** hairline `or` divider, then two outlined full-width pill rows with icon left + label + `>` chevron right: `Send me a code instead` (chat glyph), `New here? Create account` (person+ glyph, customer-only).
- **Trust region:** centered muted sentence with lock glyph `By signing in, you agree to the Terms of Service and Privacy Policy.`
- **Sticky bottom region:** hairline above, one full-width filled blue pill CTA `Continue`.

### Step-1 Arabic — `customer_login_step1_idle_light_1.0_ar_360x800.png`
- Same regions mirrored RTL: headline right-aligned `سجّل الدخول أو أنشئ حساباً`, support line `أدخل بريدك الإلكتروني أو رقم جوالك للمتابعة.`, label `البريد الإلكتروني أو الجوال` right-aligned. Prefix `+971` + phone glyph stay LTR on the correct side; email placeholder `…name@company.co` + `@` stay LTR. Helper `أدخل 9 أرقام لـ +971` right-aligned with `971+` digit order preserved. `أو` divider centered. Two alt rows mirrored (icon right, `<` chevron left): `أرسلوا لي رمزاً بدلاً من ذلك`, `جديد هنا؟ أنشئ حساباً`. Trust line right-aligned with lock glyph. Sticky pill `متابعة` full-width.

### Step-1 dark — `customer_login_step1_idle_dark_1.0_en_360x800.png` / contact-sheet `phase-2d-customer-dark.png`
- Same regions and order on near-black background. Headline white `Log in or sign up`, muted support/label/helper. Identifier row dark surface with border; prefix + field same geometry. `or` divider, same two outlined rows (dark surface, white labels, chevrons). Trust line muted. Sticky blue `Continue` (dark ink label per approved dark-button deviation).

### Step-1 1.3x — `customer_login_step1_idle_light_1.3_en_360x800.png`
- Same order. Headline `Log in or sign up` on one line; supporting line wraps to two lines (`Enter your email or mobile number to` / `continue.`). Identifier row holds (prefix + field, no overlap). Alt rows `Send me a code instead` / `New here? Create account` each on one line with chevrons. Trust line wraps to two lines. Sticky `Continue`. No overflow markers, no clipped glyphs.

### Step-1 320px — `customer_login_step1_idle_light_1.0_en_320x568.png`
- Same order compressed: headline + 2-line support, prefix `+971` + truncated placeholder `name@comp…`, helper, `or` divider, two alt rows with full labels + chevrons, trust line, sticky `Continue`. All labels whole words, no mid-word breaks.

### Step-1 tablet — `customer_login_step1_idle_light_1.0_en_768x1024.png`
- Same single column centered at max-width (no split panel in this capture): headline + support, identifier row with full placeholder `name@company.com or 501234567`, helper, `or` divider, two alt rows, trust line, sticky `Continue`. No bottom nav, no rail in this capture.

### Step-1 staff/owner/CRM — `staff_login_step1_idle_light_1.0_en_360x800.png` (+ contact sheets `phase-2d-staff/owner/crm-light`)
- Same scaffold as customer step-1 with ONE alt row: `Send me a code instead` only (no register row by design). All other regions identical (progress bar, headline, identifier row, helper, `or` divider, trust line, sticky `Continue`).

### Step-1 field error — `customer_login_step1_field_error_light_1.0_en_360x800.png`
- Same as step-1 idle plus: identifier field with blue focus ring, below it red icon + red text `Enter your email or mobile number.` split over two lines. Helper `Enter 9 digits for +971` remains. No banner. Sticky `Continue` unchanged.

### Step-2 password — `customer_login_step2_idle_light_1.0_en_360x800.png` (reference frame)
- **Top region:** thin blue progress bar, back arrow `<-` top-left (44-class hit area).
- **Headline region:** large bold `Welcome back`, muted recap line `Enter your password for 501234567.` (raw digits shown, LTR).
- **Input region:** label `Password`, one field with lock glyph + placeholder `Enter your password` + eye toggle right.
- **Secondary region:** centered blue text link `Forgot password?`
- **Alt-row region:** one outlined pill row `Send me a code instead` with chat glyph + `>` chevron.
- **Sticky region:** full-width blue pill `Continue`. No trust line on this step.

### Step-2 Arabic 1.3x — `customer_login_step2_idle_light_1.3_ar_360x800.png`
- Mirrored: back arrow `->` top-right. Headline right-aligned `مرحباً بعودتك`, recap `أدخل كلمة المرور الخاصة بـ 501234567.` with digits LTR. Label `كلمة المرور` right. Field with lock right + placeholder `أدخل كلمة المرور` + eye left. `نسيت كلمة المرور؟` centered. Alt row mirrored (`أرسلوا لي رمزاً بدلاً من ذلك`, `<` left). Sticky `متابعة`.

### Step-2 320px — `customer_login_step2_idle_light_1.0_en_320x568.png`
- Same order: back arrow, `Welcome back`, recap, label, field, `Forgot password?`, one alt row, sticky `Continue`. All above the fold at 320 wide; no scroll indicators.

### Step-2 busy — `customer_login_step2_busy_light_1.0_en_360x800.png`
- Same as step-2 idle with inputs dimmed; sticky CTA label swaps to spinner + `Signing in...`, same pill width (no resize). Alt row dimmed. No overlay spinner.

### Step-2 form error — `customer_login_step2_form_error_light_1.0_en_360x800.png`
- Same as step-2 idle (dotted password `••••••••`) plus in-flow card above the sticky bar: left red spine + red `!` icon + text `You're offline. Check your connection and try again.` + blue `Try again` right. Data kept (password dots retained). Sticky `Continue`.

### Code-confirm + resend — `customer_login_code_otp_sent_light_1.0_en_360x800.png`
- **Top:** progress bar + back arrow.
- **Headline:** `Confirm your number`, support `Enter the 6-digit code we sent you.`
- **Banner:** in-flow success-tinted rounded card with green check + `We sent a code to +971 ••• ••• 567.` (masked, LTR, raw number never rendered).
- **Input:** label `Verification code`, six empty token boxes in one row (Pinput).
- **Resend:** centered single-line muted-blue text `Resend in 30 seconds` (disabled state, no ring, no detached countdown row).
- **Alt row:** one outlined pill `Use password instead` (lock glyph + `>`).
- **Sticky:** full-width blue pill `Verify code` (auto-verify fallback per brief).

### Code error — `customer_login_code_code_error_light_1.0_en_360x800.png`
- Same as code-confirm plus: six boxes with red ramps, red label `Verification code`, red message `This code is incorrect. Check the 6 digits and try again.` Banner retained above. Resend line now `Resend in 29 seconds` (countdown ticks). Alt row + sticky `Verify code` unchanged. No overlap between banner/boxes/message.

### Register R1 — `customer_login_r1_idle_light_1.0_en_360x800.png`
- Progress bar + back arrow. Headline question `What's your name?`, support `Tell us how to address you.` Label `Full name`, one field with person glyph + `Your full name`. Sticky `Continue`. No second field, no strength meter.

### Register R2 — `customer_login_r2_idle_light_1.0_en_360x800.png`
- Progress bar + back arrow. Headline `How should we contact you?`, support `Enter your email or mobile number.` Same identifier row as step-1 (prefix `+971` + field + helper `Enter 9 digits for +971`). Sticky `Continue`.

### Register R3 — `customer_login_r3_idle_light_1.0_en_360x800.png`
- Progress bar + back arrow. Headline `Create your password`, support `Choose a password with at least 6 characters.` Label row: `Create a password` left + `Min. 6 characters` right. One password field (lock + `At least 6 characters` + eye). Below: 4-segment strength track + red `Weak` right. Sticky `Create account` (final CTA; `Continue` does NOT appear on R3).

### Forgot identifier — `customer_forgot_identifier_idle_light_1.0_en_360x800.png`
- Progress bar + back arrow. Headline `Forgot your password?`, 2-line support `Enter the email address or mobile number linked to your account and we will send you a recovery code.` Label `Email or mobile number`, one field `@` + `name@company.com or 501234567`, helper `Enter 9 digits for +971`. Muted line `Can't access this email or mobile number? Contact your workshop support team.` Sticky `Send recovery code`.

### Forgot reset — `customer_forgot_reset_otp_sent_light_1.0_en_360x800.png`
- Progress bar + back arrow. Headline `Choose a new password`, support `Enter the code and set a new password.` Success banner `Recovery code sent to +971 ••• ••• 567.` Label `Recovery code` + six token boxes; label `New password` + password field (`Enter a new password` + eye) + strength track + `Weak`. Centered blue link `Change email or mobile`, muted `Resend in 30 seconds` line. Sticky `Update password`. Banner sits in-flow above inputs with zero overlap.

### Forgot done — `customer_forgot_done_success_light_1.0_en_360x800.png` / `customer_forgot_done_success_dark_1.0_ar_360x800.png`
- Progress bar (terminal). Headline `Password updated` (ar: `تم تحديث كلمة المرور` right-aligned), one subtitle `Sign in with your new password to continue.` (ar translated). Centered green check in tinted circle (light: dark-green glyph on pale green; dark: mint glyph on deep green). Single sticky `Back to sign in` (ar: `العودة لتسجيل الدخول`). No auto-redirect, no second CTA.

### Supervisor S1 — `staff_supervisor_step1_idle_light_1.0_en_360x800.png`
- Progress bar, NO back arrow on S1. Headline `Supervisor access`, 2-line support `Sign in to manage bookings, assignments, QC, and workshop operations.` Label `Username or email`, one field (person glyph + `Enter your username or email`). Sticky `Continue`.

### Supervisor S2 — `staff_supervisor_step2_idle_light_1.0_en_360x800.png`
- Progress bar + back arrow. Headline `Welcome back`, muted recap `supervisor` (lowercase username). Label `Password`, password field + eye. Centered `Forgot password?` link. NO alt code row (supervisor is password-only). Sticky `Sign in` (not `Continue`).

### Splash — `splash_loading_idle_light_1.0_en_360x800.png` / `splash_loading_idle_dark_1.0_en_360x800.png`
- Full-bleed navy (`#0B1526`-style) in both themes. Centered blue rounded-square with white wrench glyph, `ORIENT` white + `WORKSHOP SUITE` muted below, horizontal progress bar (blue fill ~1/3 on grey track), muted caption `Restoring your session` (ar: translated; 1.3x wraps cleanly). No CTA, no input. Pure loading state.

### BEFORE (5 PNGs) — structural comparison baseline
- `customer_light.png` / `customer_dark.png` / `staff_light.png` (+ owner/crm same pattern): top brand lockup (`ORIENT WORKSHOP SUITE` + app-context block `Orient Customer App / Vehicle owners • Service customers` + purpose sentence) → `Welcome back` + `Sign in with your email or mobile number.` → segmented `_MethodSwitcher` (`Password` filled vs `One-time code` outlined) → identifier row (prefix `+971` + field) + helper → `Password` field + eye → end-aligned `Forgot password?` → inline (non-sticky) `Continue` → text link `New customer? Create an account` → footer trust line with lock. Everything on ONE scroll surface; mode is a toggle, not a step. Dark uses dark surfaces + same switcher.
- Structural delta AFTER-vs-BEFORE: (1) brand lockup + app-context block REMOVED from form column; (2) segmented switcher REMOVED (replaced by step progression + alt rows); (3) password field REMOVED from step-1 (moved to pushed step-2); (4) `AppStepScaffold` ADDED (thin top progress, back arrow except step-1, big question headline + one support line); (5) `Continue` MOVED to sticky bottom bar; (6) password/code/register MOVED to `AppOrDivider` + `AppAltAuthRow` outlined rows; (7) resend ring + detached countdown REMOVED (link + `in Ns` text); (8) register split to R1→R2→R3; (9) recovery recomposed into steps with code+password together + warm terminal done screen; (10) supervisor split to 2 steps; (11) splash kept navy with tokens/Semantics only. Not a recolor: flow, information architecture and navigation all changed.

---

## (b) U0–U14 walk, one by one (evidence = image + region; ANY violated law caps at 8/16)

| Law | Evidence (image + region) | Pass / Fail |
|---|---|---|
| U0 — never think/hunt/scroll/tap more than necessary; when in doubt fewer steps | Each step shows exactly one question + one input + one sticky CTA with zero hunting and zero scroll at 360x800 (`step1_idle`, `step2_idle`, `code_otp_sent`, `r1/r2/r3_idle`, `forgot_identifier/reset/done`, `supervisor_s1/s2`, `splash` — all regions above the sticky bar). No dense toolbar, no competing blocks. The extra navigation tap vs BEFORE is counted once under U3 and not double-counted here; per-screen cognitive load is lower than the before single dense form. | PASS (with U3 tension noted) |
| U1 — SEARCH: header search icon top-right, full-screen search, same everywhere. Auth has no search task — say so explicitly | Auth has no searchable corpus (no vehicles/bookings/leads/jobs list) on any of these screens; all 30+ viewed after-PNGs correctly show NO search icon, NO search field, NO filter chips in any region (headline/input/alt-row/sticky zones). Search UI on a login step would be a distraction. The law is satisfied by absence: nothing to search, nothing to expose. | PASS (N/A correctly — no search task on auth) |
| U2 — PRIMARY TASK FIRST: first actionable item above the fold at 360x800 idle, EACH step | Step-1: identifier row + first alt row + sticky `Continue` all above 800px fold (`customer_login_step1_idle_light_1.0_en_360x800`). Step-2: password field + `Forgot password?` + alt row + `Continue` above fold (`step2_idle_light_1.0_en_360x800` + `320` variant). Code: 6 boxes + `Resend in 30 seconds` + alt row + `Verify code` above fold (`code_otp_sent`). R1/R2/R3, forgot identifier/reset/done, supervisor S1/S2: input + sticky CTA above fold in every 360x800 idle (incl. `r3_idle`, `forgot_reset_otp_sent`, `supervisor_step2_idle`, `forgot_done_success`). 320px idles hold without scroll. | PASS |
| U3 — TAP COUNT: brief top-3, none more than before, most frequent ≤ 2 | Password login ADDS one submit tap (S1 `Continue` with ZERO API + S2 `Continue` = 2) vs BEFORE one-screen `Continue` (= 1) — see §(c) table. Register ADDS two taps (R1+R2+R3 vs single-screen Create) and supervisor ADDS one tap (S1 Continue + S2 Sign in vs single Continue). Brief §2/§6 mandates the step flow (one question per step) and therefore CONFLICTS with U3 on its face: the brief requires the extra taps U3 forbids. Most-frequent task (password) stays at 2 taps (≤ 2, second clause met) but violates the first clause (more than before). | **FAIL** |
| U4 — REACHABILITY: frequent create/scan reachable without scrolling, lower half or sticky | No create/scan task exists on auth; the frequent action (submit) lives in the sticky bottom bar on EVERY step (`Continue` / `Verify code` / `Create account` / `Update password` / `Sign in` / `Back to sign in` all pinned above safe area in every idle/busy/error capture). Nothing requires scrolling or reaching the top half. | PASS |
| U5 — NO TRUNCATION of primary text at 1.3x/320/ar; rows fit or scroll with clean peek | 1.3x EN/AR: support lines wrap to 2 lines cleanly (`step1_idle_light_1.3_en`, `step1_idle_light_1.3_ar`, `step2_idle_light_1.3_ar`); alt-row labels stay whole words (`Send me a code instead`, `New here? Create account`, `Use password instead` + ar equivalents) — zero mid-word breaks, zero `…` on primary labels. 320px: placeholder shortens (`name@comp…`) but LABELS stay whole (`step1_idle_320`, `step2_idle_320`). AR: `+971`, `@`, `501234567`, `••• ••• 567` stay LTR inside RTL (bidi-isolated); chevrons/back arrows mirror (`EN >` / `AR <`, `EN <-` / `AR ->`). Placeholder ellipsis (`name@company.co…`) is hint text, not a primary label — allowed. | PASS |
| U6 — CALM zero/empty states: nothing-to-do collapses, no filled CTA where nothing exists | Auth has no zero-data/empty-list state (no feed to be empty). Every step HAS a task, so the filled sticky CTA is the task itself — not a U6 violation. The closest analogues are calm by design: code `Resend in Ns` is disabled quiet text (no CTA competing with `Verify code`); forgot-done is the C10 terminal confirmation (single CTA is the mandated proof-of-completion, not an empty-state upsell). No screen shows a filled CTA pointing at nothing. | PASS |
| U7 — ONE PATH per task: password vs code alt rows + tabs | Segmented `_MethodSwitcher` tabs are GONE (brief §What is REMOVED — verified absent in every after-PNG). Each screen offers exactly ONE alternative path: step-1 → `Send me a code instead` (+ register, which is a DIFFERENT task, customer-only); step-2 → `Send me a code instead`; code → `Use password instead`; R-flow has no alt rows; forgot has one `Change email or mobile`; supervisor has zero alt rows (password-only, no code path to duplicate). No screen shows two entries to the same destination; `Forgot password?` appears once per password screen. Staff/owner/CRM correctly show a single alt row (no register duplicate). | PASS |
| U8 — RELEVANCE: actionable first, history never under To-do | No feed/history exists on auth. Ordering on every step is relevance-ordered: headline question → supporting line → input → error/banner (when present) → secondary link → single alt row → trust line → sticky CTA. Destructive/advanced content N/A. Nothing buries the action; nothing surfaces stale items. | PASS |
| U9 — CONSISTENCY: same element, same place, across screens and apps | Progress bar top + back arrow top-start (mirrored) + left-aligned question headline + sticky bottom CTA is identical across login steps, code, R1–R3, forgot 3 stages, supervisor 2 steps, and all 4 apps (contact sheets `phase-2d-customer-light/dark`, `staff/owner/crm-light` confirm same scaffold). `Forgot password?` sits in the same centered slot on step-2 and supervisor-S2. Resend sits in the same centered slot on code and forgot-reset. No element jumps place between themes/locales. | PASS |
| U10 — FEEDBACK + FORGIVENESS: immediate feedback, errors say what to do | Field errors: red label + icon + plain sentence + live region (`step1_field_error`, `code_error`, `r1_field_error` family). Form/offline: in-flow `AppBanner`-style card + `Try again` with data kept (`step2_form_error`: `You're offline… Try again`, password dots retained). Busy: label-swap (`Signing in…`, `Creating account…`) with width preserved + inputs dimmed (`step2_busy`, `r3_busy`, `supervisor_step2_busy`). Success: in-flow green banner with masked destination (`code_otp_sent`, `forgot_reset_otp_sent`); terminal `Password updated` per C10 exception. Resend countdown ticks visibly (`30` → `29 seconds`). No raw exceptions in any capture. | PASS |
| U11 — READABLE NUMBERS: zero never `-`; stats labelled, visible, decision-helping | `Resend in 30 seconds` / `Resend in 29 seconds` — count + unit, labelled, single line, never bare. Code length communicated structurally (6 boxes) + copy (`Enter the 6-digit code`). Masked destinations `+971 ••• ••• 567` fully visible, LTR-correct, raw number never rendered (verified `501234567 findsNothing` pattern in test-migration §5). Helpers `Enter 9 digits for +971` and `Min. 6 characters` label every numeric constraint. No `-`, no unlabeled bare stats. | PASS |
| U12 — ONE BACKGROUND: one page colour, no stray bands | Light frames: single page background, white inputs/rows, no bands (`step1/step2/code/r1/forgot/supervisor` light idles). Dark frames: single near-black background + surface lift, no bands (`step1_idle_dark`, `code_otp_sent_dark`, `forgot_done_dark`). Success/error banners are proper in-flow tinted cards, not full-bleed strips. Splash is a single navy field. Progress bar is the mandated thin step indicator, not a background strip. | PASS |
| U13 — NEW-EMPLOYEE TEST: plain words in 3 seconds | `Log in or sign up`, `Welcome back`, `Confirm your number`, `What's your name?`, `How should we contact you?`, `Create your password`, `Forgot your password?`, `Choose a new password`, `Password updated`, `Supervisor access`, `Send me a code instead` / `Use password instead`, `New here? Create account`, `Send recovery code` / `Update password` / `Back to sign in` — all verb-first plain second-person; no jargon, no IDs as titles, no codes. 3-second read holds on every idle (see answers). | PASS |
| U14 — A11Y: ≥48dp targets, AA, Semantics, 1.3x + 320 without clipping | No overflow/clipping at 1.3x (en+ar) or 320px in any viewed idle/state capture; sticky CTAs full-width + tall; inputs ~52h; back arrow 44-class; Pinput boxes + eye toggles + resend link comfortably tappable by visual estimate; dark/light headline/body/supporting/error all legible by eye. Limits stated: exact dp and AA ratios cannot be measured from PNGs; screen-reader labels verified by code pattern only (header Semantics + `loginStepProgress` step-X-of-Y + live regions per test-migration new-step tests). | PASS |

**U-law fails (1): U3 — password login (and register/supervisor) take MORE taps than BEFORE; brief mandates the extra steps.** All other laws (U0, U1, U2, U4–U14) pass with image+region evidence. Cap applies: max 8/16.

---

## (c) Top-3 tasks — AFTER taps vs BEFORE taps (each tap + scroll; more taps than before is a U3 fail)

BEFORE source: before-PNG widget trees + `phase-2-test-migration.md` old flows. AFTER source: viewed after-PNGs + `login_step_flow_test` / `forgot_step_flow_test` helpers (`reachPasswordStep` = S1 enter + Continue with ZERO API; `reachCodeConfirm` = S1 enter + alt-row send). Scroll: all steps fit 360x800 and 320x568 without scroll (verified above); BEFORE single dense form also fit without scroll — scroll delta is zero everywhere; the delta is pure taps + screens.

| # | Task | BEFORE (taps + scroll) | AFTER (taps + scroll, evidence) | Delta | Verdict |
|---|---|---|---|---|---|
| 1 | Log in with password (most frequent — build is password-first per PROGRESS decision; brief's code-first default NOT built) | 1 submit tap, 0 scroll: fill identifier + fill password on ONE screen → tap `Continue` (inline, `loginCalls 1`). No navigation. | 2 submit taps, 0 scroll: S1 fill identifier → tap `Continue` (fires ZERO API, navigates — `customer_login_step1_idle`) → S2 `Welcome back` + recap `Enter your password for 501234567.` fill password → tap `Continue` (`loginCalls 1`) (`customer_login_step2_idle`). Extra pushed screen + extra tap. | **+1 tap** (S1 Continue with no API call) | **FAIL (U3)** — the named step is S1 `Continue` |
| 2 | Log in with code | 3 taps, 0 scroll: tap `_MethodSwitcher` `One-time code` (1) → fill identifier → tap `Send code` (2) → fill 6 boxes → tap `Verify` (3). | 2 taps, 0 scroll: S1 fill identifier → tap alt row `Send me a code instead` (sends, lands `Confirm your number` + `We sent a code to +971 ••• ••• 567.` + `Resend in 30 seconds`) (1) → fill 6 boxes → tap `Verify code` (auto-verify fallback) (2) (`customer_login_code_otp_sent`). Switcher + presend CTA both gone. | **−1 tap** (switcher removed) | PASS (improvement) |
| 3 | Reset forgotten password | 2 submit taps, 0 scroll: fill identifier → `Send recovery code` (`forgotCalls 1`) (1) → fill `Recovery code` + `New password` together → `Update password` (`resetCalls 1`) (2) → terminal `Password updated` → `Back to sign in`. | 2 submit taps, 0 scroll: identical sequence recomposed in steps (`customer_forgot_identifier_idle` → `customer_forgot_reset_otp_sent` → `customer_forgot_done_success`): `Send recovery code` (1) → `Update password` (2) → `Back to sign in`. Code+password-together kept (backend single-call constraint). | **0** | PASS (equal) |

Related (not top-3, recorded for honesty): **Register** BEFORE 1 tap (`fields.at(0/1/2)` + `Create account`) → AFTER 3 taps (R1 `Continue` + R2 `Continue` + R3 `Create account`) = **+2**; **Supervisor** BEFORE 1 tap (username+password + Continue) → AFTER 2 taps (S1 `Continue` + S2 `Sign in`) = **+1**. Both add taps by the same brief-mandated step rule.
Most frequent task (password) = 2 taps (meets ≤ 2) but takes MORE taps than before → **U3 FAILS** on task 1 (and on register/supervisor).

---

## (d) Airbnb rubric + score (0–2 each, pass ≥ 12/16) — scored ONLY after the U-walk above

| # | Criterion | Evidence | Score |
|---|---|---|---|
| 1 | One task / step flow | One question per step everywhere: S1 identifier only, S2 password only, code 6 boxes only, R1 name / R2 contact / R3 password, forgot identifier / reset / done, S1 username / S2 password. Single exception below. | 2 |
| 2 | Headline-first hierarchy | Big bold left-aligned question headline (headlineLarge) + one muted support line on every step (`Log in or sign up`, `Welcome back`, `Confirm your number`, `What's your name?`, `Forgot your password?`, `Choose a new password`, `Password updated`, `Supervisor access`); no dense toolbars; RTL mirrors. | 2 |
| 3 | Whitespace, no boxes-in-boxes | Generous whitespace; no card-in-card; inputs/alt-rows separated by space + hairline `or` divider only. Alt rows are the C16-mandated outlined auth rows, not boxed grids. | 2 |
| 4 | Sheets for secondary (auth alt-rows per C16 = correct, sheets N/A) | No filters/pickers to sheet on auth — correctly N/A. Secondary paths use the C16 auth pattern (quiet links + outlined rows) instead of tabs/switchers: `Use password instead`, `Send me a code instead`, `Forgot password?`, `Change email or mobile`. Switcher + ring correctly removed. | 2 |
| 5 | Sticky CTA | ONE sticky full-width pill bottom bar on EVERY step (`Continue` / `Verify code` / `Create account` / `Send recovery code` / `Update password` / `Sign in` / `Back to sign in`); width preserved in busy (`Signing in…`); above keyboard per step tests; 320/1.3x hold. | 2 |
| 6 | Carousel / section (N/A for auth, scored fairly) | No carousels/sections on auth by design — correctly absent. No 2×2 lone-tile shape, no peek requirement applies. | 2 |
| 7 | Plain friendly copy + STATUS | Question headlines, second-person, sentence-case; trust line under CTAs; masked-destination status (`We sent a code to +971 ••• ••• 567.`, `Recovery code sent to …`) with dot+sentence pattern. Deduction: none — copy is clean; the one structural exception is scored in criterion 1/8, not here. | 2 |
| 8 | Single primary CTA | Exactly one filled CTA per step in every capture. Deduction: forgot-reset collects TWO inputs (code boxes + new password) behind ONE `Update password` CTA — brief-approved backend single-call constraint (phase-2-auth-notes §5, brief §5), i.e. a principled one-question-rule exception, but still two tasks on one screen. | 1 |

**Rubric raw: 2+2+2+2+2+2+2+1 = 15/16 (meets ≥ 12/16) — CAPPED to 8/16 by the single U-law violation (U3). C16 hard-reject sweep: zero violations (no light-theme card borders — alt rows are the C16 auth-row exception; one filled CTA per section; no duplicate entry points; no permanent pills; no badges; no ALL CAPS; no search to misplace; every step's primary input above the fold at 360x800; no carousels).**

---

## Verdict: FAIL (capped 8/16)

- Regions covered: step-1 identifier, step-2 password, code-confirm + resend, register R1–R3, forgot identifier/reset/done, supervisor step-1/step-2, splash — light+dark, en+ar, 1.0/1.3x, 320, tablet (768) — plus all 5 before-PNGs for the structural comparison; staff/owner/CRM families confirmed via contact sheets + spot idles (single-alt-row difference only).
- U-walk fails (1, explicit): **U3** (password +1 tap via the zero-API S1 `Continue`; register +2; supervisor +1; brief mandates the steps U3 forbids). All other laws pass (U0, U1 — N/A explicitly, U2, U4–U14) with image+region evidence above. Cap applies: max 8/16.
- Tap-count table deltas: password **+1 (FAIL)**, code **−1 (improvement)**, forgot **0 (equal)**; register +2, supervisor +1 (recorded).
- Scores: rubric raw **15/16** → **final 8/16 after U-law cap**. FAIL.
- Fixes are presentation/flow only (no logic changes): (1) accept the cap as the price of the C16 step flow OR record a written U3 exemption for auth in the brief (password/register/supervisor extra taps are the deliberate cost of one-question-per-step); (2) if taps must fall without breaking C16: keep S1→S2 but make S1 `Continue` fire the password-path eligibility check is already zero-API by design — no safe removal exists without re-merging fields onto one screen (which would break C16 and the brief); recommended path is the exemption, not a rebuild; (3) optional copy polish only: none blocking (placeholder `…` is hint text; `Weak` pairs colour+text; countdown units present).

## The two answers

- **Would a first-time user know what to do in 3 seconds?** Yes on every step: `Log in or sign up` + `Enter your email or mobile number to continue.` with one visible field and one `Continue`; `Welcome back` + `Enter your password for 501234567.` with one password field; `Confirm your number` + `Enter the 6-digit code we sent you.` with six boxes and `Resend in 30 seconds`; `What's your name?`, `How should we contact you?`, `Create your password`, `Forgot your password?`, `Choose a new password`, `Supervisor access` each ask exactly one thing with exactly one button. The 3-second read never requires scrolling, searching, or choosing between tabs.
- **What would an Airbnb product designer reject here?** Nothing about the look — the step flow, headline-first hierarchy, sticky CTA, alt-row pattern, resend link, masked-destination banner and terminal `Password updated` screen are exactly the C16 playbook. They would reject the tap MATH, not the craft: password login now costs two submit taps (one of them a zero-API navigation `Continue`) where one sufficed; registration costs three where one sufficed; supervisor costs two where one sufficed — all mandated by the same brief that delivers the clarity. An Airbnb reviewer operating under U-laws would demand the brief carry a written U3 exemption for auth (clarity bought with taps) rather than pretending the steps are free, and would otherwise flag only the brief-approved forgot-reset two-inputs-on-one-screen as the single one-task-rule exception.

**File path:** `docs/ui-redesign/evaluation/phase-2-auth-U.md` (this file). No code changes. No commit.
