# PHASE 14 — Owner: Finance, Compliance & Subscription

## A. Phase identity

- **Phase number:** 14
- **Title:** Owner Finance, Compliance & Subscription (accounts receivable, document expiry, feedback moderation, subscription + owner cleanup)
- **Objective:** Redesign the owner's money and compliance surfaces with the same rigor as operations — aging clarity, document-expiry urgency, moderation decisions, plan selection — then remove the owner app's confirmed dead code. This phase closes the owner branch.
- **Priority:** Medium-High
- **Dependencies:** Phases 12, 13
- **Expected scope:** Medium

## B. Repository context

Files (relative to `apps/owner_app/`):

- `lib/features/dashboard/presentation/pages/accounts_receivable_view.dart`:
  aging summary cards + AR ledger table; search; `OwnerDashboardSkeleton`; no
  error/empty states; 8 hard-coded hex; repository
  `features/dashboard/domain/repositories/accounts_receivable_repository.dart`
  + `data/repositories/ar_repository_impl.dart`; entity
  `domain/entities/accounts_receivable.dart`.
- `pages/document_expiry_view.dart`: staff document compliance/expiry list;
  search; compliance-alerts snackbar; skeleton; no error/empty; 5 hard-coded
  hex.
- `pages/feedback_moderation_view.dart`: pending reviews approve/reject +
  refresh; `CircularProgressIndicator`; error + retry; empty message.
- `pages/subscription_view.dart`: current tier + 3 selectable plans; refresh;
  provider `providers/subscription_providers.dart`; snackbar; no error/empty.
- Dead code to remove (confirm zero references first): `widgets/card_title.dart`,
  `widgets/form_label.dart`, `features/common/presentation/owner_shimmer_skeletons.dart`
  `KpiGridSkeleton` (keep `ShimmerBox`/`OwnerDashboardSkeleton` only if still
  used after Phases 12–13 migrations — otherwise remove layer and rely on
  `AppSkeleton`).
- Tests: `test/logic_test.dart` (AR/activity parsing), `logic_test.dart` covers
  `OwnerAttendanceRecord`, `ActivityResponse` — untouched.

## C. Design objectives

1. **Accounts receivable = aging made obvious.** Summary strip: total
   outstanding (hero, tabular) + aging buckets (0–30 / 31–60 / 61–90 / 90+) as
   semantic cards (warning/danger escalation), each tappable to filter the
   ledger below. Ledger: customer, invoice ref, amount, due date, days overdue
   (semantic pill), status; desktop table, compact rows; sort by overdue where
   client-side possible; search by customer/invoice. States: skeleton, empty
   ("no outstanding balances" positive framing), error+retry, no-match.
2. **Document expiry = pre-emptive compliance.** Sorted by expiry urgency;
   groups: Expired / Expiring ≤30 days / Later; each row: staff name, document
   type, expiry date, days remaining pill (danger/warning/neutral); the
   compliance-alerts action (snackbar today) becomes a visible filter chip
   ("Needs attention") plus the existing alert behavior. Search by staff/doc.
3. **Feedback moderation = decision workflow.** Pending reviews as cards:
   rating stars (accessible + text label), customer, service date, text; actions
   Approve & publish (primary) / Reject (danger, confirmation); moderation
   history if the provider exposes it (otherwise omit); states: skeleton,
   empty ("all caught up"), error+retry, busy per card.
4. **Subscription = honest plan comparison.** Current plan card (status,
   renewal date if provided) → 3 plan cards (name, price tabular, feature list,
   select action with confirmation, current-plan marker); selection keeps the
   existing provider call and result snackbar → now a result panel; states:
   skeleton, error+retry, selection busy.
5. **Owner cleanup.** Remove confirmed-dead widgets and any superseded shimmer
   layer; ensure every remaining owner file uses tokens only.

## D. Screens and workflows

| Screen | New hierarchy | Key interactions | States |
|---|---|---|---|
| `AccountsReceivableView` | aging strip → ledger | bucket tap filters ledger, search, open invoice if wired today | skeleton, empty, no-match, error+retry |
| `DocumentExpiryView` | urgency groups → list | search, attention filter, alert action retained | skeleton, empty, no-match, error+retry |
| `FeedbackModerationView` | pending cards → decision bar per card | approve, reject (confirm), refresh | skeleton, empty, error+retry, per-card busy |
| `SubscriptionView` | current plan → plan cards | select plan (confirm), refresh | skeleton, empty-if-absent, error+retry, busy |
| Dead code | — | — | removal proof |

## E. Responsive specifications

- **Compact:** aging buckets 2×2; ledger rows; moderation cards full width;
  plans stacked.
- **Medium:** rail; buckets 4-up; AR two-column (summary | ledger) optional;
  plans 3-up.
- **Expanded/large:** ledger as real table with aligned money and overdue
  column; plans 3-up with comparison-readable feature lists; content caps.
- 320 px: no overflow; money values truncate safely (never mid-digit — use
  tabular + auto-size or wrap to line 2).
- RTL: numeric alignment per locale; bucket order mirrors; day-pill alignment
  mirrors.

## F. Localization and RTL

- All strings localized (`ownerAr*`, `ownerCompliance*`, `ownerFeedback*`,
  `ownerSubscription*`) EN+AR; money/dates via `AppFormatters`; pluralization
  ICU for "N days overdue/remaining".
- RTL: tables/rows mirror; star ratings render identically (universal);
  confirmation dialogs mirror.
- Tests: page tests EN+AR; RTL assertions; 320 px clean.

## G. Design system integration

- Use: `AppPageHeader`, `AppSearchField`, `AppKpiCard` (buckets), table
  primitives, `AppRecordRow`, `StatusPill`, `AppButton`, `AppConfirmationDialog`
  (reject, plan change), `AppSkeleton`, `EmptyState`, `ErrorView`,
  `AppInfoPanel`, `AppLinearProgress` if needed.
- Remove: dead owner widgets; superseded shimmer layer where the dashboard no
  longer uses it (verify Phase 12 outcome first).
- No new tokens expected.

## H. Technical implementation

- Modify: the four page files; ARB; tests.
- Preserve: AR repository API + entity shape, document provider, moderation
  approve/reject methods, subscription selection provider call; snackbar
  outcomes may upgrade to panels — keep the same result semantics.
- Deletions require zero-reference proof (rg across lib/test).
- No route/provider/API changes; no new packages.

## I. Functional preservation

- AR data mapping and displayed fields unchanged.
- Compliance alert behavior retained (now also a filter).
- Moderation decisions call the same methods with the same payloads.
- Subscription selection triggers the same provider method; current-plan
  detection logic unchanged.
- `logic_test.dart` stays green untouched.

## J. Testing requirements

- `melos run analyze:owner`; `melos run test:owner`.
- New widget tests for the four pages: render from fakes, bucket→filter,
  search/no-match, approve/reject confirm + busy, plan select confirm + busy,
  all states EN+AR; RTL; 320/768/1280; 1.3×.
- Deletion proof for dead code (rg output in report).
- Goldens: EN compact goldens for AR + subscription; AR golden for AR ledger.

## J2. Visual quality gates (mandatory)

Static analysis and widget tests alone are **not** proof of design quality. This
phase is not complete until all of the following evidence exists:

1. **Rendered review** — run the owner app and visually review Accounts
   Receivable, Document Expiry, Feedback Moderation and Subscription; no screen
   may be signed off from code-reading alone.
2. **Form factors** — renders captured at mobile (≤430 px), tablet (600–1023 px)
   and desktop (≥1280 px); the AR ledger table reviewed at desktop density.
3. **Locales** — EN-LTR and AR-RTL renders; aging buckets, due-date pills and
   table column mirroring reviewed.
4. **State matrix** — aging bucket emphasis, overdue/escalating states, empty
   "no outstanding balances", no-match search, moderation pending/empty/error,
   plan current/selectable/busy. Populated fixtures use realistic invoices and
   expiry dates.
5. **Interaction verification** — bucket→filter, search, approve/reject
   confirmations, plan selection confirm, refresh.
6. **Accessibility** — 1.0–1.3× scale clean; money never clipped (wraps safely);
   semantics on decision rows; contrast sampled on warning/danger pills.
7. **No visual overflow** at 320 px in either locale.
8. **Evidence attached** — goldens or a screenshot pack at
   `phases/reports/PHASE_14/` named `screen_width_locale_state.png`. Section K
   is unmet without this evidence.

## K. Acceptance criteria

1. Four pages redesigned on shared grammar; dead code removed with proof.
2. Provider/method behaviors unchanged (tests).
3. EN/AR complete; RTL correct; responsive per E; money tabular everywhere.
4. `melos run analyze:owner` + `test:owner` green.

## L. Deliverables

- File changes + deletions; ARB counts; test evidence; goldens; known
  limitations (e.g. moderation history omitted because no provider exposes it).

## M. Completion gate

Stop after this phase — this closes the Owner branch. Do not begin Phase 15A
until explicitly instructed.
