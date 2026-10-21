# Logic follow-ups (data-feed issues — presentation must NOT paper over these)

U8 rule: actionable items first; historical/completed items never sit under
"Assigned"/"To do". When the data feed causes it, the UI keeps current
behavior and the issue is logged here with feed, evidence and a proposed
owner. No silent filtering.

## 1. Completed/delivered job cards render under "Assigned work orders" (advisor home)

- Feed: `advisorRecentJobCardsProvider`
  (`apps/staff_app/lib/features/advisor/presentation/providers/advisor_providers.dart:95-190`)
  returns the status-agnostic server page
  (`advisorRemoteDataSourceProvider.getJobCards(page: 1, size: 50)`) plus
  local-first intake cards, with NO status filter. Terminal statuses
  (`completed`, `delivered`, `approved`, `qualityCheckPassed`) are admitted
  by the feed itself.
- Evidence: home sorts urgent-first (`_sortedUrgentFirst` in
  `apps/staff_app/lib/features/advisor/presentation/pages/advisor_home_view.dart`
  — ordering only, rank 2 sorts last, stable within rank), so a completed
  card ("JC-1040 · Sara · Civic · Yesterday") sits at the bottom of the
  "Assigned work orders" list. Sort and fixture verified innocent; the feed
  is responsible. Reproduced in `apps/staff_app/test/advisor_home_view_test.dart`
  fixtures (completed card present because the feed returns one).
- Proposed owner: backend/product — either exclude terminal statuses from
  the recent/assigned feed (or add an `assignedOnly` flag / dedicated
  assigned endpoint), or confirm that "Assigned work orders" is meant to
  include recently completed work and rename the section. Frontend takes no
  silent-filter action until then.
- Status: open. Home behavior intentionally unchanged.

## 2. Advisor branch/shift identity data untranslated in Arabic

- Feed: advisor home identity (branch · shift) strings arrive from the
  backend untranslated; the ar locale still renders English
  (e.g. "Morning shift").
- Evidence: phase-3 advisor re-gate accepted exception (2 accepted
  exceptions recorded in the phase-3 evaluation); visible in ar captures.
  Fixture/backend data issue, not a presentation bug.
- Proposed owner: backend/product — localize branch/shift names or expose
  locale-aware labels.
- Status: open. Home behavior intentionally unchanged.

## 3. Owner dashboard has no overdue-AR signal in its payload (blocker banner omitted)

- Feed: the dashboard payload carries no accounts-receivable summary;
  fetching AR from home would be a logic change.
- Evidence: owner builder STOP report (phase-7 brief
  `docs/ui-redesign/briefs/phase-7-owner-home.md` + migration doc
  `docs/ui-redesign/evaluation/owner-home-test-migration.md`);
  the approvals-WIP banner is the only conditional banner on home.
- Proposed owner: backend/product — add an AR-overdue field to the
  dashboard payload or confirm the omission; frontend adds the banner only
  when the feed provides it.
- Status: open. Home intentionally shows no AR banner.

## 4. Owner chart timeframe pills would be fake (period state does not drive trends)

- Feed/state: dashboard period state does not recompute the trend series;
  timeframe pills would not change the data.
- Evidence: owner builder STOP report; charts render a fixed series.
- Proposed owner: product — either wire period to trend computation
  (logic change, owning phase) or remove the period control from the home
  contract; frontend keeps charts without timeframe pills.
- Status: open.

## 5. Owner approvals have no approve/reject endpoint (queue stays read-only triage)

- Feed/API: no approve/reject endpoint exists in the owner app; adding
  buttons would imply actions that do not exist.
- Evidence: phase-7 brief + builder STOP; banner "View all" drills to the
  read-only triage queue.
- Proposed owner: backend/product — provide decision endpoints +
  semantics; frontend adds buttons only then.
- Status: open.

## 6. TechnicianStopwatch ticks live time, blocking golden stability (needs injectable clock)

- Feed/logic: `TechnicianStopwatch`
  (`technician_components.dart`) renders live HH:MM:SS from
  `DateTime.now()` every second, so every golden containing an in-progress
  task drifts (0.01–0.09% between back-to-back runs); empty/error frames
  without a stopwatch are byte-stable.
- Evidence: phase-5 capture/recapture reports; suggested fix is to freeze
  elapsed when a fixed refresh time is set, or to accept an injected
  clock — a harness/logic seam, not a presentation fix.
- Proposed owner: phase 13 (test-harness owning phase).
- Status: open. No production change made for goldens.

## 7. Shared ALL-CAPS grammar: DELAYED/PENDING/ELAPSED pills (+ pod overlines)

- Feed/copy: shared `technician_components.dart` status pills and
  `AppKpiCard` pod overlines render ALL-CAPS, breaking the C16
  no-ALL-CAPS hard-reject on every surface using them.
- Evidence: phase-5 and phase-7 reviews (recorded non-gating then; gating
  from this integration session per explicit order — fix lands here on
  `ui/integration-1` in the shell-fix step).
- Proposed owner: shared-grammar owning phase (this session, §4) —
  sentence-case shared pills/overlines with ARB-safe copy.
- Status: in progress (integration session, §4).
