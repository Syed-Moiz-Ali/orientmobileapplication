# Phase 2 Auth evaluation — step-flow rebuild (fresh reviewer, branch `ui/phase-2-auth`)

Reviewer stance: harsh. READ-ONLY except this file. No code/tests/PNGs edited. No commit.
Supersedes the old restyle-FAIL verdict in this file — that verdict judged the pre-rebuild
(segmented-switcher) UI. Git history retains it. This review judges the rebuilt step-flow.

Sources read first: `docs/ui-redesign/DESIGN_SPEC.md` (C16 playbook + C8/C9/C10/C14),
`docs/ui-redesign/briefs/phase-2-login.md` (approved brief — fidelity judged against it),
all 5 `docs/ui-redesign/baseline/before/` PNGs.

## Method

- Viewed all 5 `before` PNGs (customer_light/dark, crm/staff/owner_light) with the Read tool.
- Viewed all 5 side-by-sides `docs/ui-redesign/evaluation/contact-sheets/phase-2d-*.png`.
- Directly inspected ~30 distinct `docs/ui-redesign/baseline/after-phase-2/` PNGs covering:
  Step-1 idle LTR+RTL light+dark (customer) / light (staff, owner, CRM), Step-2 idle LTR+RTL,
  Code-confirm (otp_sent) + code_error, Register R1/R2/R3 idle + R3 field/busy/form,
  Forgot-identifier idle + field/form error, Forgot-reset otp_sent + field/code error,
  Forgot-done success light+dark+AR, Supervisor S1/S2 idle + S1 field + S2 busy/form,
  Splash idle light+dark+AR, 1.0 + 1.3 scales, 320x568 + 360x800 + 390x844 + 768x1024 samples.
- Remaining files extrapolated by family only where stated: the four apps mount the same shared
  step widgets; staff/owner/CRM Step-1/Step-2/Code/Reset/Done idles were each spot-opened and are
  pixel-identical to customer modulo the permitted per-app differences (customer has 2 alt rows
  incl. register; staff/owner/CRM have 1 alt row; no register; supervisor has its own 2-step).
  Dark/AR/1.3/320 variants of the same family were spot-checked per family; no family is judged on
  extrapolation alone without at least one direct view per theme/locale/scale/size class.

## Verdict summary

- **PASS — step-flow rebuild accepted. Zero blocking fails.**
- Judged images: 5 befores + 5 side-by-sides + ~30 directly inspected afters, extrapolated to all
  179 `after-phase-2` files by family as stated above.
- **Pass/fail counts: 179/179 pass, 0 fail.** Every screen family scores >= 12/16 (lowest is
  15/16; most are 16/16). No "just the old layout restyled" — the after UI is structurally a
  different flow (see structural lists below).
- Brief fidelity: PASS. All 7 brief flow items delivered as specified: S1 identifier -> Continue,
  S2 password with recap + Forgot link, code-confirm with masked destination + Resend link +
  auto-verify fallback, Register R1->R2->R3, recovery recomposed with code+password together
  (backend single-call constraint honoured), supervisor 2-step, splash navy signature.
  No logic change required; no STOP condition triggered.
- C8/C9/C10/C14 basics: PASS (see checks below).

### C8/C9/C10/C14 checklist (all families)

- Contrast legibility: headline/body/supporting/error all legible in light+dark direct views;
  blue primary + white text, red errors + icon (never color-alone), muted trust/support lines
  readable; strength `Weak` red + track, `Good` muted — paired text+bar, not color-alone.
- Tap targets: identifier/prefix, text fields (~52h), pill CTAs (large), alt rows (tall),
  back arrow (44 hit), Pinput boxes + Resend link + eye toggle all comfortably tappable; no
  cramped controls at 1.3x/320px in any direct view.
- RTL mirroring: layout, headline, back arrow (EN <- / AR ->), alt-row chevrons (EN > / AR <),
  lock/eye positions swap correctly; digits/`+971`/masked `+971 ... 567`/emails stay LTR
  inside RTL (bidi-isolated); no mirrored digits observed in any AR direct view.
- States complete: idle, busy (CTA label-swap + spinner, width preserved, inputs dimmed),
  field error (red label + icon + message), form/offline error (`AppBanner`-style in-flow card
  + `Try again`), otp-sent (success banner, in-flow, no overlap), resend countdown
  (`Resend in Ns` disabled single line), success (dedicated `Password updated` screen per C10
  exception). No raw exceptions in any capture.
- No overflow at 1.3x/320px: 1.3 EN/AR subtitles wrap to 2 lines cleanly; 320x568 idles hold
  without clipping/ellipsis on actions; prefix + field row holds; 768 tablet constrains to
  centered max-width single column; 390 idles hold.
- 4-app consistency except branding: identical step scaffolds, progress bar, sticky pill CTA,
  Pinput, banners, trust line; only permitted differences are register row (customer-only) and
  per-app copy/absence of brand lockup per brief.

## Structural changes versus before (layout/flow/steps/sheets — not color/spacing)

Before (all 5 PNGs): one dense screen = big brand lockup + app-context block (name/purpose/notice)
+ `Welcome back` + `_MethodSwitcher` segmented Password/One-time-code toggle + identifier row +
password field + end-aligned `Forgot password?` + inline (non-sticky) Continue + `Create account`
text link + legal line. Everything on one screen; mode is a toggle.

- **Step-1 `Log in or sign up`:** REMOVED brand lockup + app-context block from form column;
  REMOVED `_MethodSwitcher` toggle; REMOVED password field from this step; ADDED `AppStepScaffold`
  (thin top progress bar, no back arrow on step 1, big left headlineLarge question + one
  supporting line); KEPT identifier only (prefix + field); MOVED password/code/register to
  alternative-path outlined full-width rows (`AppOrDivider` + `AppAltAuthRow`: `Send me a code
  instead`, customer-only `New here? Create account`) + muted trust line; MOVED Continue to
  STICKY bottom action bar (pill, full-width). One task per screen.
- **Step-2 `Welcome back` (password path):** NEW step (was a toggle state, now a pushed step):
  back arrow -> Step-1, headline + masked identifier recap (`Enter your password for 501...`),
  single password field + toggle, quiet `Forgot password?` secondary link, single alt row
  (`Send me a code instead`), sticky Continue. No switcher, no identifier re-entry.
- **Code-confirm `Confirm your number`:** NEW step (was toggle + inline boxes): back arrow,
  question headline + supporting line, in-flow success banner with masked destination
  (`We sent a code to +971 ... 567`), 6-box token Pinput, single-line `Resend in Ns` disabled
  link (replaces resend ring + detached countdown row), alt row `Use password instead`,
  sticky `Verify code` (auto-verify fallback per brief). One task.
- **Register R1 `What's your name?` / R2 `How should we contact you?` / R3 `Create your password`:**
  NEW 3-step flow (was single `Create an account` link + combined form): each step one field
  group, question headline + support line, back arrow, sticky Continue / final `Create account`;
  R3 adds strength meter + `Min. 6 characters` cue. No boxes-in-boxes.
- **Forgot-identifier `Forgot your password?`:** RECOMPOSED into step scaffold (was separate
  legacy screen): back arrow, question headline + 2-line support copy, single identifier,
  sticky `Send recovery code`, muted `Can't access... Contact support` line. Progress =
  existing 2-step indicator per brief.
- **Forgot-reset `Choose a new password`:** RECOMPOSED into one step collecting code + new
  password together (backend single-call constraint, brief-approved exception to one-input rule):
  success banner (`Recovery code sent to ...`), `Recovery code` Pinput + `New password` field +
  strength meter, `Change email or mobile` secondary link, `Resend in Ns` line, sticky
  `Update password`. Banner in-flow above inputs, zero overlap (old overlap fixed).
- **Forgot-done `Password updated`:** NEW warm terminal confirmation per C10 exception (was
  snackbar+redirect): headline + single subtitle (duplication removed), centered success icon,
  single sticky `Back to sign in`. No auto-redirect.
- **Supervisor S1 `Supervisor access` / S2 `Welcome back`:** RECOMPOSED from single login form
  to 2-step identifier -> password collecting into existing `login()` call: S1 headline +
  support + username field + sticky Continue; S2 recap (`supervisor`) + password + Forgot link +
  offline banner fit + sticky `Sign in`. No logic change.
- **Splash:** KEPT navy signature (brief-approved); TOKENS + Semantics polish only — centered
  lockup, progress bar, localized caption (`Restoring your session` / AR). No flow change.

## Per-screen table (representative files; families marked identical-modulo-permitted-diffs)

| Screen | App | Theme | Locale | Scale | Size | State | Rubric /16 | Result | Issues | Fix | Re-verified |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Step-1 idle (side-by-side) | customer | light | en | 1.0 | 360x800 | idle | 16 | PASS | none blocking; mandate clearly visible | — | n/a (new baseline) |
| Step-1 idle (side-by-side) | customer | dark | en | 1.0 | 360x800 | idle | 16 | PASS | same | — | n/a |
| Step-1 idle (side-by-side) | staff/owner/crm | light | en | 1.0 | 360x800 | idle | 16 | PASS | single alt row by design (no register) | — | n/a |
| Step-1 idle | customer | light | en | 1.0 | 360x800 | idle | 16 | PASS | — | — | n/a |
| Step-1 idle | customer | light | ar | 1.0 | 360x800 | idle | 16 | PASS | chevrons/back/digits correctly mirrored | — | n/a |
| Step-1 idle | customer | dark | en | 1.0 | 360x800 | idle | 16 | PASS | — | — | n/a |
| Step-1 idle | customer | light/dark | en/ar | 1.3 | 360x800 | idle | 16 | PASS | wraps cleanly, no truncation | — | n/a |
| Step-1 idle | customer | light | en/ar | 1.0 | 320x568 | idle | 16 | PASS | holds, no overflow | — | n/a |
| Step-1 idle | customer | light | en | 1.0 | 390x844 | idle | 16 | PASS | identical to 360 family | — | n/a |
| Step-1 idle | customer | light | en | 1.0 | 768x1024 | idle | 16 | PASS | max-width centered single column | — | n/a |
| Step-1 field error | customer | light | en | 1.0 | 360x800 | field error | 16 | PASS | inline icon+text, focus ring correct | — | n/a |
| Step-1 idle | staff/owner/crm | light | en/ar | 1.0/1.3 | 360x800 | idle | 16 | PASS | spot-verified identical modulo 1 alt row | — | n/a |
| Step-2 idle | customer | light | en | 1.0 | 360x800 | idle | 16 | PASS | Forgot link present, recap correct | — | n/a |
| Step-2 idle | customer | light | ar | 1.0 | 360x800 | idle | 16 | PASS | digits LTR, arrows mirrored | — | n/a |
| Step-2 idle | customer | light | en/ar | 1.3 | 360x800 | idle | 16 | PASS | no overflow | — | n/a |
| Step-2 idle | customer | light | en | 1.0 | 320x568 | idle | 16 | PASS | holds | — | n/a |
| Step-2 field error | customer | light | en + 1.3 ar | 1.0/1.3 | 360x800 | field error | 16 | PASS | red label+message, layout holds | — | n/a |
| Step-2 form error (offline+retry) | customer | light | en | 1.0 | 360x800 | form error | 16 | PASS | banner in-flow + Try again, data kept | — | n/a |
| Step-2 busy | customer | light | en | 1.0 | 360x800 | busy | 16 | PASS | `Signing in...` keeps width, dims | — | n/a |
| Code-confirm otp_sent | customer | light | en | 1.0 | 360x800 | otp-sent | 16 | PASS | token Pinput, LTR lock, banner in-flow, single-line Resend | — | n/a |
| Code-confirm code error | customer | light | en | 1.0 | 360x800 | code error | 16 | PASS | red ramp + message, no overlap | — | n/a |
| Code-confirm | owner/crm/staff | light | en/ar | 1.0 | 360x800 | otp-sent | 16 | PASS | spot-verified identical modulo branding | — | n/a |
| Register R1 idle | customer | light/dark | en/ar | 1.0/1.3 | 360x800 | idle | 16 | PASS | one question, sticky Continue | — | n/a |
| Register R1 field error | customer | light | en | 1.0 | 360x800 | field error | 16 | PASS | inline errors, layout holds | — | n/a |
| Register R2 idle | customer | light/dark | en/ar | 1.0/1.3 | 360x800 | idle | 16 | PASS | one question | — | n/a |
| Register R2 field error | customer | light | en | 1.0 | 360x800 | field error | 16 | PASS | inline errors | — | n/a |
| Register R3 idle | customer | light/dark | en/ar | 1.0/1.3 | 360x800 | idle | 16 | PASS | strength + Weak cue (track faint in dark, non-blocking) | — | n/a |
| Register R3 field/form/busy | customer | light | en | 1.0 | 360x800 | field/form/busy | 16 | PASS | `Creating account...` keeps width; banner+retry | — | n/a |
| Forgot-identifier idle | customer | light/dark | en/ar | 1.0 | 360x800 | idle | 16 | PASS | step progress, back link mirrored in AR | — | n/a |
| Forgot-identifier field/form error | customer | light | en | 1.0 | 360x800 | field+form | 16 | PASS | inline + offline banner w/ retry | — | n/a |
| Forgot-reset otp_sent | customer (+staff/crm/owner spot) | light/dark | en/ar | 1.0 | 360x800 | otp-sent | 15 | PASS | (1) docked 1pt for code+password together — brief-approved backend constraint; otherwise 2s | — | n/a |
| Forgot-reset field/code error | customer | light | en | 1.0 | 360x800 | field error | 15 | PASS | same 1pt dock; errors correct, no overlap | — | n/a |
| Forgot-done success | customer/all | light/dark | en/ar | 1.0/1.3 | 360x800 | success | 16 | PASS | subtitle exactly once, C10 terminal screen correct | — | n/a |
| Supervisor S1 idle | staff | light | en/ar | 1.0/1.3 | 360x800 (+320) | idle | 16 | PASS | clean form, no overflow at 320 | — | n/a |
| Supervisor S1 field error | staff | light | en | 1.0 | 360x800 | field error | 16 | PASS | inline errors | — | n/a |
| Supervisor S2 idle/busy/form | staff | light | en | 1.0 | 360x800 | idle/busy/form | 16 | PASS | busy keeps width; banner+retry, no raw text | — | n/a |
| Splash idle | shared | light/dark | en/ar | 1.0/1.3 | 360x800 | loading | 15 | PASS | navy signature per brief; centered, localized, no overflow at 1.3x | — | n/a |

Rubric key (each 0-2): (1) one task/step flow; (2) headline-first hierarchy; (3) whitespace no boxes;
(4) sheet/secondary-action usage (auth alt-rows per C16 = correct, sheets N/A); (5) sticky CTA;
(6) carousel/section N/A scored fairly as 2; (7) plain friendly copy; (8) single primary CTA.
Pass >= 12/16. Lowest score awarded is 15/16 (two principled 1pt docks, both brief-approved).

## Concrete fixes

None blocking. Zero-fail statement: **no FAILs; no code changes required before blessing.**
Opportunistic polish only (visual, no logic change; implement only if trivial):
- R3/dark strength track is faint — raise track contrast one token step in dark only.
- Staff Step-1 leaves tall whitespace above the sticky bar (single alt row by design) — acceptable
  per C9 auth whitespace; do not add filler.

## Re-verification protocol

1. Bless only recaptured goldens from this step-flow build; do not mix with pre-rebuild captures.
2. Plain `flutter test` must be green after blessing; CI golden diffs are the review artifact.
3. Any future layout change must recapture the affected family at 360x800 EN+AR light (1.0+1.3)
   plus one 320x568 sample before re-blessing.
