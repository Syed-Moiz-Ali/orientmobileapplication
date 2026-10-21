# UX Brief — phase-2 login (first family under the mandate; STOPPED for go)

## User goal
A returning or new user opens any of the 4 apps and gets inside with the least possible friction,
understanding at every step what is asked and why. One task per screen; never a form of everything.

## Single primary action
Per step, exactly one: Step 1 "Continue", Step 2 auto-verifies the code (fallback "Verify" CTA),
Password "Log in", Register steps "Continue" / final "Create account".

## What is REMOVED or moved
- REMOVED: `_MethodSwitcher` segmented password/code toggle (replaced by step progression).
- REMOVED: big brand lockup + app-context block from the form column (kept small on Step 1; full
  identity panel only on expanded split; per-app `appName/purpose/notice` props preserved and shown
  as the muted trust line + split panel).
- REMOVED: resend cooldown ring + detached countdown row (replaced by "Resend code" link + "in Ns" text).
- MOVED: "Use password instead" and "Forgot password?" become quiet secondary links (password is a
  secondary path per C16); registration becomes its own step flow behind "New here? Create account".
- KEPT (logic-owned): all LoginNotifier modes, setters, OTP send/verify, register(), resend cooldown,
  error mapping, navigation callbacks.

## Flow broken into steps (UI state only — maps onto existing notifier calls, no logic change)
1. **Step 1 "Log in or sign up"**: identifier field (dual phone/email, country prefix, LTR-locked) →
   Continue. Digits → send code → Step 2. (Email identifiers route the same; code-first for all.)
2. **Step 2 "Confirm your number"**: 6-digit Pinput (token-styled), masked destination line,
   "Resend code in Ns" → "Resend code" link, back arrow → Step 1. Auto-verify on complete.
3. **Password path** ("Use password instead" from Step 1 or 2): "Welcome back" + identifier recap,
   password field (toggle), Continue → `loginWithPassword`; "Forgot password?" → recovery flow.
4. **Register (customer only)**: R1 "What's your name?" → R2 "How should we contact you?" (identifier) →
   R3 "Create a password" (strength meter) → "Create account" → existing `register()`.
5. **Recovery**: existing 3 stages recomposed as steps in `AppStepScaffold` (progress = existing 2-step
   indicator); code + new password collected together (backend single-call constraint); warm terminal
   confirmation (C10 exception) → single "Back to sign in" CTA.
6. **Supervisor**: 2 steps (identifier → password) collecting into the existing `login()` call.
7. **Splash**: navy signature, tokens + Semantics polish only.

Logic-boundary check: every transition above calls an existing notifier method with already-available
state (setEmail/setPhone/setPassword/setName/send*/verify*/loginWithPassword/register/reset). No new
logic needed. If build discovers otherwise, STOP and ask (per C16 rule).

## Airbnb pattern used
C16 auth step flow: `AppStepScaffold` (thin progress, back arrow, headlineLarge question, supporting
line, input, sticky full-width CTA), `AppOrDivider` + `AppAltAuthRow` on Step 1 for alternative paths
(password, register), muted trust/security line under CTAs, `AppStickyActionBar` where recap + CTA
coexist. No boxes-in-boxes; one CTA per step.

## ASCII wireframe (Step 1, 360px)
```
+----------------------------------+
| —— progress (step 1 of 2)        |
| <                                |
|                                  |
| Log in or sign up                |
| Enter your number to continue.   |
|                                  |
| [ +971 | 5_ ___ ____ ]  (input)  |
|                                  |
| [        Continue        ] (CTA)  |
|                                  |
| ——————— or ———————               |
| [📱] Use password instead   (row)|
| [👤] New here? Create account(row)|
|                                  |
| 🔒 We keep your number private.  |
+----------------------------------+
Step 2 swaps input → [ _ _ _ _ _ _ ] + "Resend code in 27s" + destination line.
```

## States (per step)
idle, loading (CTA busy, label swap, width preserved — no spinner overlays), field error
(icon + text, live region), form-level error (`AppBanner` above CTA where it fits, else mapped
snackbar+retry — reviewer judges fit per state), offline/retryable, success (auto-advance; snackbar
only for in-place confirmations like code-sent).

## Copy keys needed (new ARB keys, en+ar, listed for phase 9)
Step headlines + supporting lines + "Use password instead" + "New here? Create account" +
"Resend code (in Ns)" + masked-destination line + trust line. All existing validation/error keys stay.
