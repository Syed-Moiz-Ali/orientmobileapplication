# PHASE 18 — Customer: Notifications, Roadside & Feedback

## A. Phase identity

- **Phase number:** 18
- **Title:** Customer Notifications, Roadside Assistance & Feedback (inbox, breakdown request/result, 3-step rating; feedback entry-point wiring). Closes the Customer branch.
- **Objective:** Redesign the customer's remaining flows — notification inbox, roadside breakdown request with its offline-safe result, and service feedback — and wire the already-routed `/feedback` screen into a real in-app entry point (no backend changes).
- **Priority:** Medium-High
- **Dependencies:** Phases 15–17
- **Expected scope:** Medium

## B. Repository context

Files (relative to `apps/customer_app/`):

- Notifications: `lib/features/customer/presentation/customer_notifications_view.dart`
  (route `/notifications`; `_NotificationsSkeleton`, `_LoadFailure`,
  `_AllCaughtUp`, mark-all-read with failure panel, `CustomerRefreshNotice`,
  pull refresh; `_NotificationRow`; push routing helpers in
  `presentation/support/customer_push_routing.dart`,
  `customer_notification_presentation.dart`).
- Roadside: `customer_breakdown_help_view.dart` (route
  `/customer_breakdown_help_view`; `_VehicleField`, `_VehicleOption`, `_Dock`,
  `_FailedRequestRecovery`; queues on `NetworkException`; "Sending…" notice;
  snackbar validation) and `customer_breakdown_result_view.dart` (route
  `/customer_breakdown_result`, extra map; distinguishes sent vs saved-on-device;
  route-error fallback).
- Feedback: `customer_feedback_view.dart` (route `/feedback`; `_OverallStep`,
  `_CategoryStep`, `_CategoryRating`, `_CommentStep`, `_RecommendedOption`,
  `_SubmittedView`, `_BottomBar`; progress bar; Next gated until rated; submit
  snackbar; hard-coded star color `#FFB800`; **no in-app entry point today**).
- Providers: notification provider + mark-all-read; breakdown provider/queue
  (`core/local/sync_providers.dart` handlers); feedback submission provider —
  all preserved.
- Tests: `customer_notifications_test.dart`, `customer_push_test.dart`,
  `customer_breakdown_test.dart` (contract, validation, submission, offline,
  failed-request recovery, result), no feedback test today; goldens.

## C. Design objectives

1. **Notifications = glanceable inbox.** Header with mark-all-read; rows:
   icon by category, title, body snippet (2 lines), relative time, unread dot;
   tap → existing safe destination (push routing unchanged); swipe or row action
   optional only if a delete/mark-one exists today (it does not — keep read
   state model as-is). States: skeleton, `_LoadFailure` → `ErrorView`+retry,
   all-caught-up empty, mark-all-read failure panel.
2. **Roadside = the most forgiving flow in the app.** Keep the structure
   (vehicle → location → symptom chips → detail → call/send) and refine:
   location entry clear (text field as today; no maps dependency), symptom
   chips wrap nicely, "Call workshop" secondary action visible (existing),
   submit busy state, validation snackbars → inline errors; **offline failure
   path preserved verbatim in behavior**: request queued, `_FailedRequestRecovery`
   restyled ("couldn't send — saved on this device", Retry sending / Remove
   request), result page states sent vs saved-on-device.
3. **Feedback = respectful, quick.**
   - Step chrome: progress + step titles; rating via large star tap targets
     (≥48 px) with accessible labels ("3 of 5"), category ratings, comment
     (optional where allowed today), recommend option, submit busy.
   - Star color becomes a token (`warning`-family gold token or a dedicated
     rating token added to `AppColors` in this phase — prefer dedicated
     `ratingStar` token documented in the spec).
   - Submitted view: thank-you state with clear exit.
4. **Wire `/feedback` entry points (UX completion, no backend work):**
   - After a booking that reached a completed/service-ready state where the
     existing providers expose such a booking, offer "Rate your service" from
     Booking detail and/or the Home attention panel **only when the provider
     data supports it**; if no reliable signal exists, add the entry from
     Profile ("Share feedback") — choose the safest option that the existing
     data model supports and document the decision.
   - The route itself stays deep-linkable exactly as today.
5. **Localization/RTL everywhere**, including notification relative times
   (ICU) and stars (never mirrored).

## D. Screens and workflows

| Screen | New hierarchy | Key interactions | States |
|---|---|---|---|
| `CustomerNotificationsView` | header + mark-all → list | open row (push routing), mark all read, refresh | skeleton, error+retry, empty, mark-all failure |
| `CustomerBreakdownHelpView` | vehicle → location → symptoms → detail → actions | select vehicle, type location, pick symptom, call, send | validation inline, sending, queued/offline recovery |
| `CustomerBreakdownResultView` | outcome hero → actions | Done / view bookings | sent vs saved-on-device, route fallback |
| `CustomerFeedbackView` | step progress → rating steps → submitted | rate, comment, recommend, submit | gated-next, busy, submit failure, submitted |
| Feedback entry points | added row/action | navigate `/feedback` | — |

## E. Responsive specifications

- **Compact:** single column; notification rows full width (≥64 px);
  roadside form stacked with sticky send button; feedback steps centered with
  large targets; result hero centered.
- **Medium:** notifications in a capped list (~720); roadside two-column
  (form | summary of request); feedback step content + side summary of ratings
  so far.
- **Expanded/large:** content caps; notification list narrow column centered
  (inboxes read best ~640–720) — deliberate, documented.
- 320 px: chips wrap; stars fit 5×48 px with 8 px gaps (shrink gap, not
  target).
- RTL: rows mirror; chips order mirrors; stars remain LTR-order universal.

## F. Localization and RTL

- All strings localized (`customerNotifications*`, `customerRoadside*`,
  `customerFeedback*`) EN+AR; relative times + counts via ICU; symptom chips
  localized; star accessibility labels localized.
- RTL: notification rows/actions mirror; roadside form and result mirror;
  feedback progress mirrors.
- Tests: notifications/breakdown suites EN+AR + new feedback tests; RTL
  assertions; 320 px clean.

## G. Design system integration

- Use: `AppPageFrame`, `AppTopBar`, `AppRecordRow`, `StatusPill`, `AppButton`,
  `AppActionBar`, `AppTextField`, selection chips (theme), `AppInfoPanel`
  (sending/queued notices), `AppSkeleton`, `EmptyState`, `ErrorView`,
  `AppConfirmationDialog` (remove request/vehicle actions already existing),
  `AppStepProgress` (feedback), `SectionHeader`.
- Add `ratingStar` token to `AppColors` (documented) for the feedback stars.
- Retire ad-hoc `_LoadFailure`/`_AllCaughtUp`/`_NotificationsSkeleton` in favor
  of shared equivalents where behavior is preserved.

## H. Technical implementation

- Modify: the four view files; purchase/
  breakdown/notification providers untouched; ARB; tests/goldens; add feedback
  widget test; add entry-point wiring where decided (Home/Booking detail/Profile)
  using existing navigation only.
- Preserve: push routing destinations (`customer_push_routing.dart`), mark-all
  read method, breakdown queueing + failed-request recovery semantics, feedback
  submission payload, route extras (`breakdown-result` map, sent/queued flags).
- No route/provider/API changes; no new packages.

## I. Functional preservation

- Notification tap destinations unchanged (deep-link safety preserved).
- Offline breakdown behavior identical (queued, retry, remove) — the exact
  recovery contract tested by `customer_breakdown_test.dart` stays green with
  only copy/layout updates.
- Feedback submission identical; gating rule (Next until rated) kept.
- Result page distinguishes sent vs saved exactly as today.
- All listed tests pass (copy/layout updates only); goldens intentional.

## J. Testing requirements

- `melos run analyze:customer`; `melos run test:customer`.
- Update/extend: notifications (states, mark-all failure, push routing stub),
  breakdown (validation, submission, offline recovery, result), new feedback
  tests (step gating, submit busy/failure, submitted view, entry-point
  navigation); EN+AR; RTL; 320/390/768/1280; 1.3×.
- Goldens: regenerate notifications/roadside/result; add feedback goldens
  (EN+AR) and an AR golden for the notifications inbox.

## J2. Visual quality gates (mandatory)

Static analysis and widget tests alone are **not** proof of design quality. This
phase is not complete until all of the following evidence exists:

1. **Rendered review** — run the customer app and visually review the
   notification inbox, roadside request + result, and the 3-step feedback flow
   incl. its new entry point.
2. **Form factors** — renders captured at mobile (≤430 px), tablet (600–1023 px)
   and desktop (≥1280 px).
3. **Locales** — EN-LTR and AR-RTL renders; notification rows, symptom chips,
   stars and result hero reviewed in AR.
4. **State matrix** — inbox skeleton/empty/error/mark-all failure, roadside
   validation/sending/queued-recovery, result sent vs saved-on-device, feedback
   gating/busy/submitted. Realistic notification and symptom fixtures.
5. **Interaction verification** — row tap → safe destinations, mark all read,
   call workshop, retry/remove queued request, feedback step gating and submit.
6. **Accessibility** — 1.0–1.3× scale clean, ≥48 px star targets with "N of 5"
   semantics, contrast sampled on queued/error panels.
7. **No visual overflow** at 320 px in either locale (stars fit at 320 px).
8. **Evidence attached** — goldens or a screenshot pack at
   `phases/reports/PHASE_18/` named `screen_width_locale_state.png`. Section K
   is unmet without this evidence.

## K. Acceptance criteria

1. Section D surfaces redesigned; feedback wired to at least one in-app entry
   (decision documented) without backend changes.
2. Push routing, mark-all, offline queue/recovery, and feedback payload
   contracts unchanged (tests).
3. EN/AR complete; RTL correct; responsive per E.
4. `melos run analyze:customer` + `test:customer` green.

## L. Deliverables

- File changes; ARB counts; feedback entry-point decision; `ratingStar` token
  addition; golden diffs; test evidence; known limitations.

## M. Completion gate

Stop after this phase — this closes the Customer branch. Do not begin Phase 19A
until explicitly instructed.
