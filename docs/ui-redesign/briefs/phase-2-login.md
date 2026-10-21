# UX Brief — phase-2 login (SUPERSEDING DECISION 2026-10-20: password login is ONE screen; code/register keep steps)

## Scoped rule — step flows vs tap count (auth decision, also in C17)
Step flows are for ONE-TIME or genuinely complex tasks. Frequent tasks stay on a single screen. A step
flow may exceed the previous tap count for a one-time task, and then typed values must survive Back and
a progress bar must show position.

## User goal
A returning or new user opens any of the 4 apps and gets inside with the least possible friction.
Password login (the frequent task) takes ONE tap from launch. One task per screen.

## Single primary action
Password screen: Continue = the existing login call. Code flow: Verify. Register final: Create account.

## Top 3 tasks with tap counts (BEFORE = old single screen, AFTER = this brief)
1. Log in with password — before 1 tap → after 1 tap (identifier + password + Continue on one screen). No increase.
2. Log in with code — before 3 (switcher + Send + Verify) → after 2 (alt row + Verify). Decreased.
3. Reset forgotten password — before 2 (Send + Update) → after 2. No increase.
Register (one-time, documented exemption): 1 → 3 steps with persistent values + step X of 3 progress.

## What is REMOVED or moved
- REMOVED: `_MethodSwitcher` segmented toggle (gone already); code is an alt row, not a mode.
- REMOVED: resend cooldown ring (replaced by "Resend code" link + "in Ns" text).
- REMOVED: big brand lockup + app-context block from the form column (small lockup on password screen;
  full identity panel only on expanded split; per-app props preserved as muted trust line + split panel).
- KEPT (logic-owned): all LoginNotifier modes, setters, OTP send/verify, register(), resend cooldown,
  error mapping, navigation callbacks, autofill hints, focus order, keyboard actions.

## Flow (UI state only — maps onto existing notifier calls, no logic change)
1. **Password screen (all 4 apps, DEFAULT)**: big headline + identifier field + password field (toggle) +
   "Forgot password?" link + sticky full-width Continue → EXISTING login call (no new API timing).
   `AutofillGroup` with username + password hints so password managers work; focus identifier → password;
   keyboard action on password submits. Alt row "Send me a code instead" ONLY where code login already
   exists → code flow. Continue makes the same call as before, when as before.
2. **Code flow (2 steps, kept)**: Step 1 identifier? NO — entry is the alt row (identifier already typed
   on the password screen carries over); "Confirm your number": 6-digit Pinput, masked destination,
   resend link + countdown, back arrow. Auto-verify on complete.
3. **Register (customer only, 3 steps, documented one-time exemption)**: R1 name → R2 contact → R3
   password + strength → "Create account" → existing `register()`; values survive Back; progress X of 3.
4. **Recovery**: existing 3 stages recomposed as steps; code + new password together (backend single-call
   constraint); warm terminal confirmation (C10 exception) → single "Back to sign in" CTA.
5. **Supervisor**: ONE screen, same pattern as password (identifier + password + Continue → existing
   `login()`; forgot link preserved).
6. **Splash**: navy signature, tokens + Semantics polish only.

Logic-boundary check: every submit above calls an existing notifier method with already-available
state. Step-1-without-API-call is gone (no such step anymore). No new logic needed. If build discovers
otherwise, STOP and ask.

## Airbnb pattern used
C16 auth screen (not a step flow for password): brand lockup, headlineLarge + subtitle, App* inputs,
full-width 52 CTA, secondary text links, muted trust line, 480 max, keyboard-safe. Steps only where
the brief says: code confirm, register R1-R3.

## ASCII wireframe at 360x800 (password screen — first actionable item above the fold)
```
+----------------------------------+
| [lockup]              [search n/a]|
|                                  |
| Welcome back                     |
| Log in to continue.              |
|                                  |
| Phone or email                   |
| [ +971 | 5_ ___ ____ ]  (input)  |
| Password                         |
| [ ••••••••          ]  (toggle)  |
|            Forgot password?      |
|                                  |
| [          Continue     ] (CTA)   |
|                                  |
| ——————— or ———————               |
| [💬] Send me a code instead (row)|
|                                  |
| 🔒 We keep your account private. |
+----------------------------------+
Bottom nav: none (auth screens never have one).
```

## States
idle, loading (CTA busy, label swap, width preserved), field error (icon + text, live region),
form-level error (`AppBanner` above CTA where it fits, else mapped snackbar+retry), offline/retryable,
success (auto-advance; snackbar only for in-place confirmations like code-sent). 1.3x + 320px + RTL +
customer dark; staff/owner/CRM light-only.

## Copy keys needed (new ARB keys, en+ar, listed for phase 9)
Password screen headline/subtitle; "Send me a code instead"; existing step keys stay (code/register/
forgot already added). All existing validation/error keys stay.
