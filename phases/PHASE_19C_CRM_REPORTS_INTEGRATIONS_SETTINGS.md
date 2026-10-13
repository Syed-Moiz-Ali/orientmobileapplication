# PHASE 19C — CRM: Reports, Integrations & Settings (palette deletion)

## A. Phase identity

- **Phase number:** 19C (part 3 of 3; split from the former Phase 19; closes the CRM branch)
- **Title:** CRM Reports, Integrations, Settings — plus deletion of the legacy `crm_constants.dart` palette and honest settings toggles
- **Objective:** Redesign the CRM's analytics/admin surfaces, finalize integrations and settings (resolving the dark-appearance toggle honestly), and delete the parallel palette once every consumer has migrated. This phase closes the CRM branch.
- **Priority:** Medium-High
- **Dependencies:** 19A, 19B (all other CRM surfaces on tokens)
- **Estimated scope:** Medium-Large

## B. Repository context

Files (relative to `apps/crm_app/`):

- `lib/features/crm_dashboard/presentation/widgets/crm_reports_page.dart`:
  conversion trend line, lead-source pie, salesperson performance,
  response-time buckets, key metrics — `CustomPaint` charts + `CrmCardTitle`.
- `crm_integrations_page.dart` (private `_CrmIntegrationCard`, `_ConnectedSheet`):
  integration cards grid with status pills (Connected/Syncing/Sync error/Not
  connected); connect → `ConnectIntegrationSheet`; connected sheet:
  sync/disconnect.
- `crm_settings_page.dart`: workflow + appearance preference toggles (push
  notifications, auto-assign leads, dark appearance); **verify each toggle's
  real effect** — the dark toggle currently does nothing.
- `widgets/connect_integration_sheet.dart`: META (page id + token) / ZOHO
  (client id/secret/refresh token) connect forms.
- Palette: `presentation/crm_constants.dart` — delete in this phase after
  proving zero references remain (19A/19B migrated their files).
- Providers: `crm_ui_provider.dart` (settings toggles, integrations),
  `crm_analytics_provider.dart` — preserve APIs.
- Tests: CRM suite from 19A/19B — extend here.

## C. Design objectives

1. **Reports = one chart language.** Adopt the shared chart theme (Phase 03B):
   palette, typography, tooltips, tabular value labels, RTL axis mirroring,
   empty-data states. Sections: conversion trend, source distribution,
   salesperson performance, response-time buckets, key metrics strip. Replace
   `CrmCardTitle` with `SectionHeader`; retire local painter styling.
2. **Integrations = honest connection states.** Cards grid with status pills;
   connect sheet with field validation (required credentials per platform);
   connected sheet: Sync now (busy + result feedback), Disconnect (confirm);
   per-card error/retry states. Same provider methods/payloads.
3. **Settings = only real toggles.**
   - Push notifications + auto-assign: bind to the existing `crmUiProvider`
     state (keep behavior).
   - **Dark appearance:** decision required — either (a) wire it to a real
     `ThemeMode` preference using the Phase 01 dark theme (persisted in the
     same Hive settings box pattern as locale), or (b) remove the toggle if
     product rejects dark exposure. Default recommendation: (a) wire it, since
     the UI already promises it; document either way.
   - Add the **language switcher row** (Phase 02 component) here.
4. **Palette deletion:** after 19A/19B migrated consumers, remove
   `crm_constants.dart` with zero-reference proof; the CRM becomes
   token-only.
5. **Localization:** all strings in these surfaces EN+AR.

## D. Screens and workflows

| Screen | New hierarchy | Key interactions | States |
|---|---|---|---|
| `CrmReportsPage` | metrics strip → chart sections | — (display only, as today) | empty-data per chart, error |
| `CrmIntegrationsPage` (+ sheets) | cards + status → sheets | connect (validated), sync now, disconnect (confirm) | per-card status states, busy, error |
| `CrmSettingsPage` | preference sections → language | toggles (real), language switch | — |

Tab contracts unchanged (indices 5/6/7). Provider methods unchanged.

## E. Responsive specifications

- **Compact:** reports single column (charts stacked, fixed heights); settings
  rows full width; integration cards stacked; sheets with keyboard insets.
- **Medium:** reports 2-up chart grid; integrations 2-up.
- **Expanded/large:** reports 2-col chart grid capped `contentStandard`; chart
  labels legible at desktop density; integrations 3-up; settings capped form
  width.
- 320 px: no overflow; chart labels never clip (fallback density).
- RTL: chart axes/pies mirror via chart theme; setting rows mirror; sheets
  mirror.

## F. Localization and RTL

- All strings localized (`crmReports*`, `crmIntegrations*`, `crmSettings*`)
  EN+AR; platform names (Meta/Zoho) stay Latin; credential field labels
  localized.
- RTL: reports and sheets mirror; toggle rows keep switch position mirrored
  (end side).
- Tests: CRM suite extended in EN+AR; RTL chart/axis assertion; 320 px clean.

## G. Design system integration

- Use: `AppPageFrame`, `SectionHeader`, `AppCard`, `StatusPill`, `AppButton`,
  `AppTextField` (credential forms incl. identifier/LTR guidance where
  relevant), `showAppModalSheet`, `AppConfirmationDialog` (disconnect),
  `AppSkeleton`, `EmptyState` (+empty-data per chart), `ErrorView`,
  `AppInfoPanel`, `LanguageSwitcher`, chart theme helper.
- Delete: `crm_constants.dart`; retire `CrmCardTitle` in favor of
  `SectionHeader` (confirm zero references first).
- No new tokens expected.

## H. Technical implementation

- Modify: reports/integrations/settings pages + connect/connected sheets; CRM
  ARB; tests; delete `crm_constants.dart`.
- Preserve: analytics provider reads, integration connect/sync/disconnect
  payloads and flows, `crmUiProvider` toggles, badge/notification behaviors.
- Dark toggle decision implemented per C3 (wire with persisted preference using
  Phase 01 theme, or remove — documented).
- No route/provider/API changes; no new packages.

## I. Functional preservation

- Integration flows unchanged (connect/sync/disconnect payloads, confirmations).
- Report data series/aggregations unchanged.
- Settings toggles that already worked keep their exact behavior; the dark
  toggle either becomes real or is removed (no misleading UI remains).
- All prior CRM tests (19A/19B) remain green with the palette deletion.

## J. Testing requirements

- `melos run analyze:crm`; `melos run test:crm`.
- Extend widget tests: reports render + empty-data states; integrations cards +
  connect sheet validation + connected-sheet sync/disconnect; settings toggles
  (incl. dark decision behavior) + language switch; EN+AR; RTL; 320/390/768/
  1280; 1.3×.
- Palette deletion proof: `rg` output showing zero `crm_constants` references.
- Goldens: reports + integrations (EN compact + expanded); AR golden for
  reports.

## J2. Visual quality gates (mandatory)

Static analysis and widget tests alone are **not** proof of design quality. This
phase is not complete until all of the following evidence exists:

1. **Rendered review** — run the CRM app and visually review reports,
   integrations (incl. both sheets) and settings; no surface may be signed off
   from code-reading alone.
2. **Form factors** — renders captured at mobile (≤430 px), tablet (600–1023 px)
   and desktop (≥1280 px).
3. **Locales** — EN-LTR and AR-RTL renders; chart axis mirroring explicitly
   reviewed.
4. **State matrix** — per-chart empty-data, integration status variants
   (connected/syncing/error/not connected), connect validation errors, sync
   busy/result, disconnect confirm, settings toggle states incl. dark mode
   applied. Realistic analytics fixtures.
5. **Interaction verification** — connect/sync/disconnect flows, credential
   validation, settings toggles actually do what they claim (dark proves
   itself), language switch live.
6. **Accessibility** — 1.0–1.3× scale clean; chart labels legible; semantics on
   toggles/cards; contrast sampled (incl. dark theme if wired).
7. **No visual overflow** at 320 px in either locale.
8. **Evidence attached** — goldens or a screenshot pack at
   `phases/reports/PHASE_19C/` named `screen_width_locale_state.png`. Section K
   is unmet without this evidence.

## K. Acceptance criteria

1. Three surfaces + sheets redesigned; `crm_constants.dart` deleted with proof;
   CRM is token-only.
2. Integration/analytics/toggle behaviors unchanged except the documented dark
   decision.
3. EN/AR complete; RTL correct incl. charts; responsive per E.
4. `melos run analyze:crm` + `test:crm` green; J2 evidence attached.

## L. Deliverables

- File changes + deletion proof; ARB counts; dark-toggle decision note; golden
  diffs; test evidence; known limitations.

## M. Completion gate

Stop after this phase — the CRM branch is closed. Phase 20 (final validation)
follows once every branch is signed off. Do not begin until explicitly
instructed.
