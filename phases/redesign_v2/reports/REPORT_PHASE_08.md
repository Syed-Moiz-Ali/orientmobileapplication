# REPORT PHASE 08 — Staff Spatial Inspection HUD & Evidence Workspace

**Document ID:** `phases/redesign_v2/reports/REPORT_PHASE_08.md`
**Execution Phase:** Concept A V2 — Phase 08 (Archetype 6: Spatial Inspection HUD)
**Specification:** `phases/redesign_v2/implementation/PHASE_08_STAFF_INSPECTION_HUD.md`
**Prerequisites:** Phases 01–07 + 01.2 + 07.1 complete & engineering-PASSED
**Status:** **ENGINEERING GATE PASSED** / **VISUAL GATE PENDING PRODUCT OWNER**
**Timestamp:** 2026-10-15
**Author:** Lead Flutter Architect & Systems Designer

> Mission summary: full screen-level redesign (not a color refresh) of the
> three Phase 08-owned inspection surfaces — package picker, spatial HUD
> sheet, health-report preview — plus every owned dialog/sheet/state, on the
> centralized theme + shared-widget architecture, with shell integration,
> EN/AR parity, and evidence goldens. Phase 09/10 not started.

---

## 1. Owned inventory (from source, nothing omitted)

| Ref | Surface | File | Route / entry | States owned & covered |
| :-- | :--- | :--- | :--- | :--- |
| S17 | `ChooseInspectionView` package picker | `advisor/presentation/pages/choose_inspection_view.dart` | `/choose-inspection` (`extra: {jobId}`, `onSelect/onSkip/onBack`) | 3 tiers, selection, single CTA, skip, offline pill |
| S18 | `InspectionSheetView` spatial HUD | `advisor/presentation/pages/inspection_sheet_view.dart` | `/inspection-sheet` (`extra: InspectionCallbacks`) | damage tab (canvas + kind sheet + pin sheet + pins list), checks tab (search + section pills + rings + evidence dock), voice states (idle/recording/saved/denied), photo states (tiles/thumbs/retry/denied), note sheet, footer (notify + queued + review) |
| S19 | `InspectionPreviewView` health report | `advisor/presentation/pages/inspection_preview_view.dart` | `/inspection-preview` (`extra: {onBack, jobId}`) | score dossier, 3 finding groups, damage recap, legacy body section, empty/blocked, confirm dialog, convert-to-estimate, submit (online + offline-queued + failure) |
| — | HUD pin bridge (new) | `inspection_pages/presentation/vehicle_map/hud_pin_bridge.dart` | shared by S18/S19 | zone↔part mapping, amber/crimson/blue kind mapping |
| — | Damage models/provider | `vehicle_damage_map_model.dart`, `inspection_view_model.dart`, `inspection_provider.dart` | — | **untouched** (contracts preserved) |
| — | Detailed part map | `vehicle_map/vehicle_inspection_map.dart`, `vehicle_body_condition_panel.dart` | embedded in S19 legacy section, job detail, intake | **untouched** (API stable, reused read-only) |
| — | `inspection_widgets.dart` (IC/InfoCard/SolidBtn/…) | inspection_pages widgets | used by `repair_order_view` (Phase 09) | **untouched** (Phase 09 owns its migration) |

Routes, `extra` shapes, role allowlist (`advisor` → all three routes),
`InspectionCallbacks`, Hive boxes (`inspections`, `sync_queue`,
`sync_failed`, `pending_media`), Dio/Riverpod/validation/grading logic and
the estimate handoff are byte-identical. No backend inventions.

---

## 2. Before / after composition (per screen)

| Screen | Before | After |
| :-- | :-- | :-- |
| Package picker (S17) | Generic list of 3 tappable template cards (each navigating directly), gradient hero banner, bespoke `AppBar` + hardcoded English, raw `StatusPill(bg/fg)` + `Color(0xFF10B981)` badge | **Tiered selection studio:** selectable tier cards (Quick 20 / Comprehensive 60 / Safety Audit) with checkpoint breakdown, duration + section chips, focus-area chips (Brakes/Engine/Suspension/Lighting), Recommended/Selected badges, **one primary CTA** (`PrimaryButton` Start) + Skip; `WorkspaceAppBar` + offline pill + workflow indicator; 3-up row ≥1000px |
| Inspection sheet (S18) | Checkpoint card list with small segmented Good/Fair/Poor buttons, raw `TextField` search, hardcoded `Color(0xFF10B981)`/`AppColors.text3`, bespoke `AppBar`, audio dialog without playback, SnackBar errors | **Spatial HUD, two tabs:** (1) Damage canvas = shared 8-zone vector blueprint (tap zone → kind sheet → pin; tap pin → pin sheet; pins listed + 48dp deletable, incl. intake-legacy findings); (2) Checkpoints = `AppSearchField` + 48dp section pills + `SectionHeader` + cards with **56–64dp tactile Pass/Caution/Fail rings** + per-card **voice/photo dock** (record/stop/play/delete, camera/gallery tiles, thumbs, retry tile, mic/camera/gallery-denied cards with Open settings, note sheet); sticky footer (notify toggle + queued chip + Review CTA) |
| Preview (S19) | Summary card + flat rated-items list + submit-only footer, hardcoded `Color(0xFF059669)`, bespoke `AppBar`, raw `AlertDialog` confirm | **Health-report document:** `AppPageHeader(breadcrumbs: Jobs › Vehicle health report)`, big score dossier (computed 100/55/5 index + coverage + dossier splits), **Mandatory Safety (red) / Recommended (amber) / Good (green)** groups, damage-pin recap (LTR-locked canvas), legacy body section (conditional), **Convert-to-Estimate + Submit** footer, `showAppConfirmationDialog` confirm, empty/blocked states |

No screen repeats the header + KPI + grid + list template. The old
checkpoint-list-with-new-colors outcome was explicitly rejected during
development (rings, canvas, and dossier are new compositions).

---

## 3. Changed files + rationale

**Rewritten (Phase 08-owned):**
- `choose_inspection_view.dart` — tier selection + single CTA; shell + l10n.
- `inspection_sheet_view.dart` — HUD tabs, rings, dock, states; shell + l10n.
- `inspection_preview_view.dart` — health dossier, groups, convert; shell + l10n.

**Added (Phase 08-owned):**
- `hud_pin_bridge.dart` — zone↔`hud_<zone>` part mapping + kind mapping
  (pins ride the existing `vehicleBodyCondition.parts` payload; zero
  contract change).
- `test/advisor_phase08_theme_test.dart` (2 guards), `test/advisor_phase08_hud_test.dart` (24 tests), `test/advisor_phase08_visual_test.dart` (10 goldens + 10 baselines).
- `reports/PHASE_08/screens/` (10 evidence PNGs).

**Shared (justified, backward-compatible):**
- `spatial_damage_hud.dart` — additive optional `onZoneTap(VehicleZone)`
  (empty-zone taps resolve to the nearest zone; pin taps are suppressed from
  double-handling). No layout/paint change when null; all pre-existing
  shared goldens pixel-identical (417/417 green).
- `test/spatial_damage_hud_zone_tap_test.dart` (3 tests).

**l10n:** `app_en.arb` / `app_ar.arb` + regenerated gen files — 90 new keys
(package 22, HUD 44, health 20, zones 8, minus reused) with exact parity.

**Untouched by design:** provider/models, `vehicle_inspection_map.dart`,
`vehicle_body_condition_panel.dart`, `inspection_widgets.dart`,
`repair_order_view.dart` (Phase 09), intake/estimates/hub/tech/supervisor/
owner/customer/CRM screens, all routes/permissions/Hive boxes.

---

## 4. Theme audit

- All rendered color resolves via `context.colors` /
  `context.semanticColors` (`inspectionPass/Advisory/Fail`,
  `warning/danger/info` families for pins/kinds/groups). No `AppColors.*` /
  `AppDarkColors.*`, no `Color(0xFF…)`, no `Brightness` branches in owned
  files — enforced by the new guard (2/2 green).
- Removed: `Color(0xFF10B981)` ×4 (choose badge, sheet rings/sections),
  `Color(0xFF059669)` (preview), `AppColors.text3` (sheet footer), gradient
  hero (choose), raw `StatusPill(bg/fg:)` (choose).
- `Colors.*` survives only with `FIXED-INK` justification (white glyphs on
  saturated status fills; black87 scrim over user photos) or
  `Colors.transparent` (exempt) — second guard green.
- No new theme tokens were needed; no shared theme files changed.

## 5. Widget audit (reused 07.1 vs newly created)

**Reused from shared_core (zero new app-local duplicates):**
`WorkspaceAppBar`, `OfflineStatusPill` (via `showOfflineStatus` +
`advisorPendingSyncCountProvider`), `AppResponsivePage`, `AppPageHeader` +
`AppBreadcrumbs`/`AppBreadcrumbItem(.current)`, `AppSearchField`,
`SectionHeader`, `AppKpiCard` (choose? no — replaced, see below),
`StatusPill` tone ctors, `EmptyState`/`EmptyState.noMatch`,
`AppSkeleton.listRows`, `PrimaryButton`, `showAppModalSheet`,
`showAppConfirmationDialog`, `SpatialDamageHud` (+ new `onZoneTap`),
`AppLinearProgress`.
Grep proof: no new `apps/staff_app/**/widgets/*.dart` files; the single new
lib file is feature-domain mapping (`hud_pin_bridge.dart`), not a UI
primitive.

**Genuine gaps, solved without new shared API:**
- `_DossierSplit` (preview-local): the shared compact KPI tile truncates
  labels in the 3-up dossier slot (caught on golden review); the dossier
  strip is report-specific layout, theme-driven — not a primitive copy.
- Checkpoint rings, kind picker, pins list, evidence dock: task-specific
  Phase 08 compositions (kept local; a shared `CheckpointRing` was not
  promoted without a second consumer — creating shared API for one caller
  would violate the gap protocol).

## 6. Shell integration (04.1)

| Requirement | Implementation |
| :--- | :--- |
| Bespoke headers → `WorkspaceAppBar` | All three screens (title + live subtitle, back, `frosted: !context.isCompact` with reduced-transparency fallback in the component) |
| `OfflineStatusPill` + single announcement | `showOfflineStatus: true` + `offlinePendingCount`; none of the three pages renders `OfflineBanner` (announced exactly once; asserted in tests); footer queued chip only when count > 0 |
| Breadcrumbs | `AppPageHeader(breadcrumbs: Jobs › Vehicle health report)` on the pushed preview (choose/sheet are flow steps, not deep hierarchy — documented) |
| Master-detail | Damage tab ≥600px viewport: canvas 3flex + pins 2flex (golden-verified at 768); picker ≥1000px: 3-up tiers |
| Full-bleed | Header stays visible on all three (capture HUD scrolls beneath the frosted bar; hiding was not needed — documented) |
| Preserved | Routes/extras/permissions/Hive boxes; no Cmd+K (no global search in this workflow — spec-exempt); no backend inventions; one justified backward-compatible shared addition (§3) |

## 7. Localization & RTL proof

- 90 new keys, exact EN/AR parity (`arb_parity_test` green, untranslated
  clean). Professional MSA automotive Arabic (مساحة الفحص، لوحة الأضرار،
  تقرير صحة المركبة، بنود السلامة الإلزامية).
- Zero hardcoded user-facing strings in owned files (guard-adjacent: theme
  test + parity + review).
- RTL: directional APIs throughout; goldens confirm mirrored chrome, badges,
  tab order, footer actions.
- Non-mirroring: the damage blueprint is `Directionality`-LTR-locked inside
  the shared widget (identical pin geometry in EN/AR goldens); counts use
  tabular Latin figures; no plates/VIN/phones/money on these screens.
- Pre-existing (not Phase 08): `AdvisorWorkflowIndicator` renders English
  copy in AR goldens — owned by Phase 06.

## 8. Viewport matrix

| Width | Verified | Composition |
| :-- | :-- | :-- |
| 320, 360, 390, 430 | ✅ EN+AR widget smoke (320/390) + goldens (390) | single-column HUD, stacked tiers, bottom CTAs, modal sheets |
| 600, 768, 834 | ✅ 768 goldens + smoke | damage tab 40/60 master-detail; picker stays stacked <1000px |
| 1024, 1280, 1440 | ✅ 768 proxy + `AppResponsivePage` 1440 cap | 3-up tiers ≥1000px; studio-max canvas |

1.3× text, 48dp targets (rings 64px, pills 48px, delete 48px, mic 48px),
semantics (tabs/rings/pins/dock labelled + selected/expanded states),
reduced-motion (no custom animation beyond 160–180ms state fades),
contrast (status fills carry white FIXED-INK glyphs both themes), dark-theme
smoke — all asserted in `advisor_phase08_hud_test.dart`.

## 9. Baseline vs final

| Suite | Baseline (post-07.1 tree) | Final | Δ |
| :--- | ---: | ---: | :--- |
| staff_app analyze (`lib test`) | 0 | **0** | clean |
| staff_app tests | 374 / 41 | **410 / 41** | **+36 (24 hud + 2 theme + 10 visual), 0 regressions** |
| shared_core analyze / tests | 0 / 414/414 | 0 / **417/417** | +3 zone-tap |
| shared_auth / shared_models | untouched | untouched | — |
| staff guards (06/07/07.1/theme) | green | **green** (18/18 incl. new file) | — |
| deprecation / semantic / primary guards | green | **green** | — |
| ARB parity (staff + shared) | clean | **clean** | — |

### Remaining failures + owners (all pre-existing, name-identical to 07.1)

| Failures | Owner | Nature |
| :--- | :--- | :--- |
| `supervisor_login_phase05` 2 | Phase 05/11 | stale-golden pixel rot |
| `technician_today` 7, `technician_job_detail` 9, `technician_productivity` 6, `technician_profile` 9, `technician_support_flows` 8 | Phase 10 | stale-golden pixel rot (touch files this phase never imported) |
| customer_app 80 (unchanged set) | Phases 16–18 | same stale-golden rot (untouched by this phase) |

## 10. Golden updates + evidence

10 new Phase 08-owned baselines (real fonts: Plus Jakarta Sans + IBM Plex
Sans Arabic + MaterialIcons, same loader as Phase 07), each inspected at
native resolution before acceptance:
`inspection_package_{390_en,390_ar,768_en}`,
`inspection_hud_{390_en,390_ar,768_en}`, `inspection_checks_390_en`,
`inspection_health_{390_en,390_ar,768_en}`.
Evidence: `reports/PHASE_08/screens/` (copies of the baselines).
Defects found by review and fixed before acceptance: dossier-split label
truncation (replaced shared compact tiles with a dossier strip,
re-baselined) and tablet single-column (viewport breakpoint, re-baselined).
No other golden touched.

## 11. Limitations

1. No live device/emulator/browser is available — verification is headless
   widget + golden tests; live visual/interaction acceptance is
   **NOT PERFORMED** and must not be reported as passed.
2. Camera/gallery capture, signature strokes, real audio I/O and app-settings
   intents are not exercisable headless — covered by permission-denied /
   retry / playback-state UI instead (playback uses `audioplayers`, record
   uses the existing method-channel service; contracts unchanged).
3. Template load failure is defensive UI only (the provider swallows fetch
   errors and keeps the bundled checklist by design).
4. `phases/README.md` (cited by the brief) does not exist — the ledger update
   went to `phases/redesign_v2/README.md` §5 (same substitution as 07.1).
5. Health score (100/55/5 per grade) is a transparent presentation index over
   real grades — documented here, no fake pins/scores/photos/endpoints.

## 12. Gate verdicts + ledger

**Gate 1 — Engineering: PASS.** All owned screens/states/dialogs redesigned;
shell integrated; analyzer 0/0; theme + fixed-ink + deprecation + primary +
parity guards green; contracts/routes/persistence preserved (payloads
verbatim; pins ride the existing parts map); 410/41 with zero new failures
(41 name-identical to 07.1); report + evidence produced.

**Gate 2 — Visual: PENDING PRODUCT OWNER.** Side-by-side compositions are
rebuilt per task (picker studio / spatial HUD / health dossier), Concept A
identity throughout (navy ink, cobalt action, hairline borders, 8/12/16
radii, no gradients/glass-cards/gauges), mobile/tablet + EN/AR + dark
renders reviewed headless. Live acceptance **not performed**. This report
does **not** claim Product Owner approval.

### Ledger update (`phases/redesign_v2/README.md` §5)

Phase 08 Spatial Inspection HUD & Evidence Workspace: S17–S19 redesigned
(tiered packages + single CTA, 8-zone damage canvas with tap-to-pin +
tactile rings + voice/photo dock, health-report dossier with safety groups
+ convert-to-estimate), shell-integrated, theme-guarded, localized EN/AR
(90 keys), 36 new staff tests + 3 shared tests, 10 goldens reviewed.
Evidence: this report + `reports/PHASE_08/screens/`.

---

## 13. Rework — InspectionSheet scroll-room recomposition (2026-10-15)

**Defect:** stacked chrome (app bar + Inspect card + 5-node stepper +
tab bar + search card + section chips + section header + 64px rings +
dock toggle + footer toggle + CTA) left one visible checkpoint at 390×844.

**Recomposition (sheet file only; no Phase 09, no shared changes):**
1. Deleted the Inspect card + `AdvisorWorkflowIndicator` stepper from the
   sheet; a 4px linear progress sits under the slim `WorkspaceAppBar`.
2. One compact control row: 40px segmented Damage/Checkpoints + search
   collapsible to an icon button (expands inline, clearable).
3. Category chips → 36px horizontal snap strip with counts.
4. Checks list owns the viewport via slivers: 32px sticky mini-header
   (label + remaining + All-pass) + cards; completed sections collapse to
   a re-expandable summary bar; empty search shows no-match + Clear action.
5. Cards compressed: padding 12, gaps 8, rings 64→48 inline segmented
   control, evidence dock → single row (chevron + count badge + attach
   icon), reset moved to a header icon button (also fixes a nested-tap).
6. Dock fixed once: single Review CTA opens a Review sheet (progress +
   pins summary + notify toggle + Continue → `onPreview`); the queued chip
   is gone (header pill is the single announcement).

**Viewport audit (390×844, widget-measured):** list viewport **613px =
72.6% ≥ 55%**, **3 compressed cards visible without scrolling** (EN + AR
asserted in `advisor_phase08_hud_test.dart`). Matrix re-verified: 320,
390, 390@1.3×, 768, dark, AR — no overflow. Known corner (pre-existing,
shared chrome, identical app-bar inputs before/after): 360@1.3× shows a
4.8px `WorkspaceAppBar` toolbar overflow; fixing it would be a global
shared change, so it is documented, not patched here.

**Goldens re-rendered (sheet only, reviewed native):**
`inspection_hud_{390_en,390_ar,768_en}`, `inspection_checks_390_en` —
chrome collapse + compressed cards + single CTA visible; EN/AR pin geometry
identical. No other golden touched. Evidence overwritten in
`reports/PHASE_08/screens/`.

**Suites:** staff **413/41** (was 410/41; +3: viewport audit, collapse,
review-sheet; the 41 are the name-identical pre-existing Phase 05/10 stale
goldens); analyzer 0; theme + fixed-ink + parity guards green; 2 new l10n
keys (`advisorHudClear`, `advisorHudResetGrade`, exact parity). Live-device
gap: **NOT PERFORMED** (no device/emulator/browser).

---

**Phase 08 executed in isolation. Phase 09 and later were not started.**
