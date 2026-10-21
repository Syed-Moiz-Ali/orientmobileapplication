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
