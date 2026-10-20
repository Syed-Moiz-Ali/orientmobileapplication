# UI/UX Audit — Orient Mobile Workspace

Date: 2026-10-20. Scope: read-only analysis of melos monorepo (`melos.yaml`: `orient_mobile`).
Root `pubspec.yaml` holds only `melos`; SDK `^3.9.2`. All UI in `apps/*` + `packages/*`.

## 1. Architecture summary

| Unit | lib .dart files | Entry | Routing | Theme | l10n (template keys) | State mgmt |
|---|---|---|---|---|---|---|
| `apps/staff_app` | 111 | `lib/main.dart` (`StaffApp`, ConsumerStateful, ProviderScope + `dioClientProvider(appName:staff)`, Hive, syncEngine, push) | `lib/core/router/app_router.dart`, go_router, 26 routes, role-guard staff roles | none local (`core/theme/` empty) → `shared_core AppTheme.light` | `l10n.yaml` → `StaffLocalizations`, `lib/l10n/app_en.arb` 2510 keys + `app_ar.arb` | flutter_riverpod only (~123 refs) |
| `apps/owner_app` | 48 | `lib/main.dart` (`OwnerApp`, `dio(appName:owner)`) | `lib/core/router/app_router.dart`, go_router, 14 routes, owner-only guard | none local → `AppTheme.light` | `OwnerLocalizations`, `app_en.arb` 644 keys + `app_ar.arb` | riverpod only (~54 refs) |
| `apps/customer_app` | 70 | `lib/main.dart` (`CustomerApp`, `dio(appName:customer)`, CustomerPushScope; ONLY app wiring `AppTheme.dark`) | `lib/core/router/app_router.dart` (440 lines, richest), 16 routes + legacy redirects | none local → `AppTheme.light/dark` | `CustomerLocalizations`, `app_en.arb` 1008 keys + `app_ar.arb` | riverpod only (~48 refs) |
| `apps/crm_app` | 40 | `lib/main.dart` (`CrmApp`, `dio(appName:crm)`) | `lib/core/router/app_router.dart` (98 lines), 4 routes (kanban internally hosted) | none local → `AppTheme.light` | `CrmLocalizations`, `app_en.arb` 534 keys + `app_ar.arb` | riverpod only (~46 refs) |
| `packages/shared_core` | 130 | `shared_core.dart` (133 exports) | `src/router/inspection_callbacks.dart` (callbacks only) | `src/theme/` AUTHORITATIVE: `app_theme.dart` (552 lines, `authorizedPrimaryLight #215FE6`, light+dark), `app_colors/dark_surface/semantic/text_styles/fonts/dimensions/density/motion/interaction/chart` | `app_en.arb` 206 keys + `app_ar.arb` | riverpod, dio 5.7, hive, firebase_messaging |
| `packages/shared_auth` | 32 | `shared_auth.dart` (34 exports) | `login_view` + `forgot_password_view` consumed by all 4 routers | inherits shared_core | `app_en.arb` 196 keys + `app_ar.arb` | riverpod, flutter_animate, freezed |
| `packages/shared_models` | 8 | pure domain (`user_role`, `job_card_status`, `value_objects`: vin/plate/phone/money_aed) | — | — | none | freezed_annotation only |

Total: **439 lib .dart files** (451 incl. test/). No `Navigator 1.0`/`auto_route` — go_router everywhere.
Fonts bundled via shared_core only: `Plus Jakarta Sans Variable` + `IBM Plex Sans Arabic`. No `google_fonts` anywhere.
Assets: only `apps/staff_app/assets/vehicle_maps/{advisor_car_top_mapped.svg,advisor_car_top_mapping.json}` +
`packages/shared_core/assets/{.env,images/logo.png}`. `customer_app/assets/images/` empty placeholder.

## 2. Design-debt counts (per `lib/`, Select-String; gen/l10n excluded from interpretation)

| App (lib files) | `Color(0x` | `Colors.` | `TextStyle(fontSize` | `EdgeInsets` | `BorderRadius.circular` | `Text('`/`Text("` heuristic |
|---|---|---|---|---|---|---|
| staff_app (111) | 18 | 1256 | 5 | 374 | 221 | 688 |
| owner_app (48) | 0 | 170 | 0 | 60 | 27 | 129 |
| customer_app (70) | 0 | 437 | 0 | 92 | 68 | 323 |
| crm_app (40) | 22 | 383 | 2 | 100 | 89 | 191 |

Interpretation:
- `Colors.` is the #1 offender (esp. staff: `Colors.white/black/grey/amber` bypassing `AppColors`/`semanticColors`).
- `Color(0x` survives only in staff (inspection canvas/status colors) + crm (`crm_constants.dart` + widgets).
- `TextStyle(fontSize` near-zero = good; teams already use `AppTextStyles`/`context.text`.
- `EdgeInsets`/`BorderRadius.circular` high but mixed: new code uses `AppDimensions.s*`/`radius*`, legacy sheets still raw literals — grep per module in each phase.
- Hardcoded-`Text` overcounts login fallbacks but staff (688) + customer (323) still carry hundreds of literals despite 534–2510 ARB keys per app → centralize in ux-writing phase.

Top offending areas (spot-checked): staff `features/advisor/presentation/widgets/` (26 files: `AdvisorSheet/JobCardSheet/ApprovalSheet/SearchSheet`, `repair_estimate_math`, `price_breakdown_dock`), inspection canvas `real_damage_canvas.dart` + `vehicle_map/*`, `profile_screen.dart` (~958-line `_SignOutButton`); crm `presentation/crm_constants.dart` + `crm_*_widget.dart`; customer `presentation/widgets/customer_*_tab.dart` + `customer_profile_rows.dart`.

Duplicated widgets: `profile_data.dart` ×3 (staff full class vs owner/crm `const …ProfileSheetData` — consolidate on shared_core `ProfileSheetData`); `sync_providers.dart` ×3; `main.dart/app_router.dart/firebase_options.dart` ×4 (expected per-app, keep); buttons `PrimaryButton/SecondaryButton` (core) vs `AuthPrimaryButton/Auth*Button` (auth) vs private `_SignOutButton/_GreaseButton/_BellButton/_FilterButton` (extract to core); status pills `StatusPill/NotificationBell/PendingSyncChip` (core) vs ~10 local variants (`advisor_status`, `supervisor_components`, `technician_components`, `job_status_ui`, `customer_status_*`, `crm_pipeline/channel_widgets`); scaffolds `WorkspaceAppBar/DashboardShell/AppTopBar/AppPageHeader` (core) vs `SupervisorScaffold/SupervisorSubPageWrapper/CustomerScaffold/CrmDrawer`.

## 3. UX debt per area

- Hierarchy: dashboards (supervisor, owner, crm) show 5+ competing sections above the fold; no single hero number + plain-language sentence. Inspection + repair-order screens are data-dense with technical labels and no "Advanced details" collapse.
- Jargon: VIN/estimate sync states, QC checklist codes, AR aging buckets, pipeline stages shown raw; no `AppInfoTooltip`/expander.
- Cramped spacing: legacy sheets use raw 8/10/14 paddings, mixed 6–22 radii (spec: tokens only, cards 16–20, inputs 12, buttons pill).
- Missing states: most lists have spinner-or-data only; no skeleton-mirrors-layout, no friendly empty, no `Try again` error, no offline/stale banner (syncEngine exists but UI rarely surfaces `PendingSyncChip`/`OfflineBanner`).
- Tap targets: icon buttons in app bars/sheets/lists often 20–32px visuals without 48dp hit area.
- Feedback: silent mutations (assign, approve, parts request) without snackbar; destructive actions sit next to primary CTAs (no danger-zone separation).
- Navigation: 4 apps × own `app_router.dart` is correct, but breadcrumbs/top bars differ per app; max-width unconstrained on desktop/web; tables (AR aging, inventory, job status) horizontal-scroll on phones instead of card transformation.
- Accessibility: no semantics labels on icon-only buttons/charts, no visible focus states, text-scale overflow untested, contrast of `Colors.grey` on white unchecked.

## 4. Useful packages already present (do NOT install anything this session)

`go_router ^17.1`, `flutter_riverpod ^2.6.1`, `flutter_localizations` + `intl` (all apps + core/auth), `hive`, `dio`, `connectivity_plus`, `firebase_core` (+ messaging/local_notifications via core), `flutter_svg` (staff only, 2 uses), `fl_chart` (staff), `mobile_scanner`, `image_picker`, `audioplayers/video_player`, `pdf/share_plus/url_launcher`, `pinput`, `flutter_animate` (auth), bundled fonts (no google_fonts), custom shimmer in `shared_core/src/widgets/app_skeleton.dart` (no shimmer dep), `cached_network_image` absent (use `AppNetworkImage` wrapper in phase-1).

## 5. Risks

1. Existing `shared_core` theme (Concept A automotive, primary `#215FE6`, chamfered 4/8/12/16/24 radii, Jakarta Sans) CONFLICTS with spec C2–C6 (Airbnb accent `#FF385C`, 6/8/12/16/20/28 radii, Inter). Decision needed: full token swap vs bridge.
2. ARB systems already exist per app (en+ar) + core/auth — l10n tail phases must MERGE, not greenfield.
3. Only customer wires dark mode; staff/owner/crm light-only → dark QA will surface unreadable `Colors.*`.
4. Inspection canvas + vehicle SVG map is the most fragile visual; golden harness must stub it deterministically.
5. 688+323 hardcoded strings in staff/customer mean ux-writing phase is large; needs glossary + `COPY_QUESTIONS.md`.
