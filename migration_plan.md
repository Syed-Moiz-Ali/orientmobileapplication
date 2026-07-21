# Orient Mobile — Architecture Migration Plan (Provider → Riverpod + Clean Architecture)

> This plan covers **Phase 1 (analysis)** and **Phase 2/3 (migration roadmap)**. No source files are modified by the planning agent. Implementation is incremental and keeps the app compiling after every step.

---

## 0. Snapshot of Current State (verified by reading the code)

| Aspect | Finding |
|--------|---------|
| State mgmt | 100% `ChangeNotifier` + `provider` (`MultiProvider` of 13 ViewModels in `main.dart`). Plus heavy `setState` inside large widgets. |
| Architecture | No layering. Files are organized by screen, not by feature/clean-architecture. |
| Data | **No network/API layer at all.** Every ViewModel returns hardcoded `mock` data via `Future.delayed`. Models contain `static mock` lists. |
| DI | Manual `ChangeNotifierProvider(create: …)` in `main.dart` and per-screen. Eagerly creates everything at startup (incl. duplicate `AdvisorDashboardViewModel`). |
| Navigation | `go_router` defined in `routes/approutes.dart`, but screens still use raw `Navigator.push`/`MaterialPageRoute` everywhere (two navigation systems co-exist). `routes/navigatorservice.dart` is a dead class with ~8 empty stub methods. |
| Storage | `Hive` used only by `CustomerSuggestionsService` (local customer suggestion cache for autofill). |
| Tests | Only `test/widget_test.dart` — the default **counter** smoke test (does not match the app; would fail). Zero real coverage. |
| Colors | **Two conflicting color systems**: `kBlue` etc. in `main.dart` AND `kBlue`/`kBg` in `core/constants/app_colors.dart`. |
| Dead code | `advisor_home_view_wiring.dart` (commented paste-doc), empty stub methods in `NavigatorService`, duplicate provider registration. |
| Naming | `crm_dasboard` (typo dir), `crmdasboard` (enum value), `inspection_vew_model.dart` (typo), `mock` data in models, `RoleModel`/`UserRoleModel` duplicate concepts. |
| God widgets | `advisor_home_view.dart` (~3600 lines, `setState` + `ChangeNotifierProvider`), `login_view.dart` (500 lines), `vehicle_customer_view.dart` (1000+ lines with `setState` + ViewModel). |
| Lints | `analysis_options.yaml` only includes `flutter_lints`; `print`/`debugPrint` not yet used but no strict rules. |

**Architecture score (current):** Maintainability ~3/10, Scalability ~2/10, Testability ~1/10.

---

## 1. Current Architecture

- **Style:** Screen-first, "MVVM-ish" using `ChangeNotifier` ViewModels. No domain layer, no repositories, no data sources.
- **Strengths:** Clear separation of view vs viewmodel file per screen; `go_router` is present (good choice, underused); Hive usage is isolated in one service; some shared widgets exist in `core/app_widgets.dart`.
- **Weaknesses:** Business logic lives in ViewModels that also drive UI; no real async/error handling (fake latency, no try/catch, no `Result`/`Failure`); no dependency inversion (widgets instantiate/look up concrete ViewModels); untestable (timers + `BuildContext` in ViewModels, e.g. `RoleSelectionViewModel.proceedWithRole` takes `BuildContext`).
- **Technical debt:** Hardcoded mock data stands in for an entire backend; duplicate color constants; dead navigation service; no tests; inconsistent naming; **mutable shared models mutated in place** (see §6).
- **Coupling:** High — screens import many sibling ViewModels and other screens directly (`login_view.dart` imports 6 dashboard views to navigate). Circular-ish imports likely.
- **Cohesion:** Low — a single ViewModel (`VehicleCustomerViewModel`) holds 30+ field setters, form state, suggestion logic, and validation.

### 1.1 Verified per-ViewModel findings (read, not assumed)
| ViewModel | Mock data location | Notable issues |
|-----------|-------------------|----------------|
| `AdvisorDashboardViewModel` | in-file `AdvisorStats`/`.mock` getters | Navigation callbacks are empty no-ops; UI-only. |
| `VehicleCustomerViewModel` | none (form) | 30+ setters; calls `CustomerSuggestionsService` (storage) directly; mutable `VehicleCustomerFormModel`. |
| `AccountsReceivableViewModel` | in-file list + `Future.delayed` | Filtering logic in VM; no error path. |
| `RoleSelectionViewModel` | `UserRoleModel.roles` | `proceedWithRole(BuildContext, …)` — framework dependency in domain. |
| `LoginViewModel` | none | Holds `TextEditingController`s; navigates via callback. |
| `TechnicianDashboardViewModel` | in-file list (194–286) | **Mutates `job.tasks[idx] = task.copyWith(...)` and `job.notes=` on shared objects**; `reset()`-style logic mixed with UI; `init` calls `refresh()`. |
| `SupervisorDashboardViewModel` | in-file lists | Tab/search state + assign-work row state + KPIs all in one class; `// Replace with real API` comments. |
| `CrmDashboardViewModel` | in-file lists | Mutates `_tasks[i].isDone`; settings booleans; imports a **broken filename** `crm%20_dashboard_model.dart` (literal space / URL-encoding artifact). |
| `InspectionViewModel` | `kInspectionSections` (const) | **Giant mutable form**: `Map<String,ItemStatus>`, `Map<String,ItemMedia>` (mutable `ItemMedia` fields), `List<ServiceLineItem>`/`PartLineItem` (non-final fields). Hardest to convert — needs a freezed state class, not a Notifier wrapping mutable maps. |

---

## 2. Folder Analysis (per existing folder)

| Folder | Purpose now | Problems | Suggested replacement |
|--------|-------------|----------|------------------------|
| `lib/main.dart` | App bootstrap + providers + colors | Mixes theme, colors, DI, routing | `main.dart` bootstraps only; move colors → `core/theme`; DI → Riverpod providers |
| `lib/routes/` | go_router config + dead `NavigatorService` | Two nav systems; dead code | `core/router/` with go_router only; delete `NavigatorService` |
| `lib/core/` | colors, fonts, text styles, shared widgets | Colors duplicated in main.dart; `app_widgets.dart` mixes 2 top bars | Keep `core/`; split `theme/`, `constants/`, `widgets/`, `errors/`, `network/`, `storage/` |
| `lib/features/` | Mixed feature folders | Inconsistent structure (some have data/domain/view/viewmodel, most don't); `crm_dasboard` typo; some roles are portals not features | Full feature-first restructure (see §14) |
| `lib/advisor_dashboard/` | Advisor screens + viewmodels + models | Not under `features/`; god widgets; mixed MVVM | Move into `features/advisor/`; split data/domain/presentation |
| `lib/forgotpasswordscreen/` | Forgot-password screen | Flat, not feature-scoped | `features/auth/forgot_password/` |
| `lib/features/login_pages/` | Login screens per role + config | Per-role login screens duplicate logic; navigation inside viewmodels | `features/auth/` with role param |
| `lib/features/role_selection/` | Role picker | `UserRoleModel`/`RoleModel` duplicate; enum misnamed `crmdasboard` | `features/auth/role_selection/` + `core/auth/` for `UserRole` |

### 2.1 Naming & filename fixes (do alongside moves)
- `UserRole.crmdasboard` → `UserRole.crmDashboard` (typo + missing underscore). Touches enum, `user_role_model.dart`, `login_config_model.dart`, `login_view.dart` switches, `approutes.dart`.
- `lib/features/crm_dasboard/` directory → `lib/features/crm/`; file `crm_dasboard_view_model.dart` → `crm_dashboard_view_model.dart`.
- `crm%20_dashboard_model.dart` (literal space / URL-encoding artifact in import at `crm_dasboard_view_model.dart:7`) → rename to `crm_dashboard_model.dart` and fix import. This is a **real broken-path artifact** that must be corrected.
- `inspection_vew_model.dart` → `inspection_view_model.dart`.
- `RoleModel` (user_role_model.dart:105, holds a `VoidCallback onTap`) → remove; it duplicates `UserRoleModel` intent and is unused navigation glue.
- **Dead code to delete (verified unused):** `core/theme/app_text_styles.dart` (duplicate `AppTextStyles` that hardcodes `fontFamily:` without `GoogleFonts`; zero imports — the live theme is `app_fonts.dart` → `AppTypography`). `main.dart` `MultiProvider` block is **almost entirely dead**: every dashboard view creates its own `ChangeNotifierProvider` locally; only `RoleSelectionViewModel` is actually consumed via the global provider. Delete `MultiProvider`; keep only what each screen needs via Riverpod `ProviderScope` (auto).
- **Coupling fact (drives pilot order):** `login_view.dart` imports all 6 dashboard views and switches on `UserRole` to `Navigator.push` them; `role_card_widget.dart` imports `login_view.dart`. Therefore **auth (role selection + login + role→route mapping) must be migrated first** — no other feature can be isolated until login navigates via go_router. This is *why* Phase 2 is the pilot.

---

## 3. State Management Analysis

- **`ChangeNotifier` ViewModels (13+):** Convert to Riverpod `Notifier`/`AsyncNotifier`. Replace `notifyListeners()` with immutable state classes + `state = …`.
- **`MultiProvider` in `main.dart`:** Delete. Use Riverpod `ProviderScope` + `ref.watch`. No eager global creation.
- **`setState` in god widgets:** Split into small `ConsumerWidget`/`ConsumerStatefulWidget` pieces each watching a focused provider. Local-only UI state (tab index, step index) becomes `StateProvider` or stays `setState` in a small leaf widget.
- **`ChangeNotifierProvider.value` sharing:** Replace with `ref.watch(someViewModelProvider)` (Riverpod scopes automatically).
- **Global mutable state:** `NavigatorService.navigatorKey` (static) → use go_router `GoRouter` instance via a Riverpod provider or `context.go`.

---

## 4. Dependency Analysis

Current `pubspec.lock` verified: **only `provider` + `go_router`** are present for state/navigation. No `riverpod`, `freezed`, `build_runner`, `dio`, `mocktail`, or `either_dart` yet — clean slate.

- **Remove:** `provider` (after full migration, last step). `NavigatorService` usage removed (its class deleted once navigation moves to go_router).
- **Keep:** `go_router` (^17.1.0, good), `hive`/`hive_flutter` (local cache), `intl`, `google_fonts`, `fl_chart`, `image_picker`, `signature`, `cupertino_icons`.
- **Add (recommended for target architecture):**
  - `flutter_riverpod` (state mgmt + DI) + `riverpod_generator` + `riverpod_annotation` (codegen, per user decision) + `build_runner` (dev).
  - `freezed` + `freezed_annotation` — immutable entities/DTOs (replaces hand-written `toJson/fromJson` and non-const mutable form models like `ServiceLineItem`/`ItemMedia`). If JSON serialization is wanted later, add `json_serializable` + `freezed`'s `fromJson` support.
  - `either_dart` or a small in-repo `Result`/`Failure` type — consistent error handling (no silent `catch (_)`).
  - (Optional later) `dio` — when a real network layer is introduced.
- **Remove package `provider`:** after full migration; do it last to avoid a big-bang break.

---

## 5. SOLID Violations (representative files)

- **SRP:** `VehicleCustomerViewModel` (vehicle_customer_viewmodel.dart) holds form fields, suggestion filtering, validation, persistence — many responsibilities. `LoginViewModel` mixes controllers + validation + navigation callback.
- **OCP:** `LoginView._navigateAfterLogin` (login_view.dart:349) is a switch over `UserRole` that must be edited to add a portal — open for modification, not extension.
- **LSP:** `RoleModel` (user_role_model.dart:105) holds a `VoidCallback onTap` — not substitutable for `UserRoleModel` despite similar name; confusing hierarchy by naming, not inheritance.
- **ISP:** ViewModels expose broad public surfaces (30+ setters) when views need only a few. No granular interfaces.
- **DIP:** Widgets depend on concrete ViewModels (`context.read<AdvisorDashboardViewModel>()`); no repository interfaces; `RoleSelectionViewModel.proceedWithRole` depends on `BuildContext` (framework) instead of an abstraction.

---

## 6. Clean Architecture Violations

Files mixing UI + business + storage + navigation:
- `login_view.dart` — UI + navigation switch + imports 6 dashboards.
- `vehicle_customer_viewmodel.dart` — state + suggestion persistence call (`CustomerSuggestionsService`) + validation.
- `customer_suggestions_service.dart` — storage + serialization + dedup logic (acceptable as a datasource, but called directly from ViewModel = no repository seam).
- `advisor_home_view_wiring.dart` — documentation-as-code; should not exist.
- `navigatorservice.dart` — dead navigation abstraction mixing `pushNamed`/`pop`/`fetchData` stubs.

**Mutation bug (must fix during migration):** Several ViewModels mutate shared model objects in place:
- `technician_dashboard_viewmodel.dart:325-369` — `job.tasks[idx] = task.copyWith(...)` and `job.notes =` on objects from a shared list.
- `crm_dashboard_viewmodel.dart:419-421` — `_tasks[i].isDone = !_tasks[i].isDone`.
- `inspection_vew_model.dart` — `mediaOf(itemId).photoPaths.add(path)`, `s.qty = qty` on non-final `ServiceLineItem`/`PartLineItem`/`ItemMedia` fields.

Under Riverpod (immutable state + auto-dispose), in-place mutation causes **stale UI and lost updates**. Rule: every entity/DTO is **deeply immutable (freezed)**; all updates go through `state = state.copyWith(...)` (or new freezed state). No mutable lists/maps held in providers.

**Untyped route coupling (must fix):** `approutes.dart:64-66` does `JobCardDetailView(jobCard: state.extra as JobCardModel)` — casts an untyped `Object?` to a concrete model and couples the router to a data model. Replace with a **typed go_router parameter** (path/query or `extra` typed via a small wrapper) or pass the selected entity through a Riverpod provider (`selectedJobCardProvider`) so the detail view reads it via `ref.watch`.

**Target separation:** UI (presentation) → Notifier (state) → UseCase → Repository (interface) → Datasource (Hive/API). Mappers convert DTO ↔ Entity.

---

## 7. Widget Analysis

- **God widgets:** `advisor_home_view.dart` (~3600 lines), `vehicle_customer_view.dart` (~1000+), `login_view.dart` (500), `technician_dashboard_view.dart`.
- **Duplication:** Input field styling repeated in `login_view.dart` (`_InputField`/`_PasswordField`) vs form fields in `vehicle_customer_view.dart`. Top bars duplicated (`InnerTopBar`/`CustomerTopBar` in `app_widgets.dart` vs inline AppBars in dashboards). Loading spinners, empty states, status pills repeated.
- **Reusable widgets to extract:** `AppTextField`, `PrimaryButton`, `AppTopBar`, `StatusPill` (exists), `SectionHeader` (exists), `LoadingIndicator`, `ErrorView`, `EmptyState`.

---

## 8. Performance Issues

- **Unnecessary rebuilds:** `MultiProvider` + `context.watch<LoginViewModel>()` in many small private widgets rebuild the whole card on any change. Riverpod `ref.watch` on granular providers fixes this.
- **Large widget trees:** god widgets build thousands of lines in one `build` → split into leaf `ConsumerWidget`s.
- **Fake async:** `Future.delayed` in every ViewModel blocks real error paths; replace with real repository calls wrapped in `AsyncNotifier`.
- **Improper FutureBuilder/StreamBuilder:** none found, but `loadData()` patterns will become `AsyncNotifier`/`FutureProvider` (cleaner than manual `_isLoading`/`_error` flags).
- **Memory leaks:** `LoginViewModel` disposes controllers (good), but many `ChangeNotifier`s created in `main.dart` live for app lifetime; Riverpod auto-disposes unused providers.

---

## 9. API Layer (current: none)

No HTTP client, no endpoints, no auth, no token refresh, no timeouts, no retry. All data is `mock`.
**Target:** `core/network/` with an `ApiClient` (Dio later), interceptors for auth/refresh, timeout + retry policy. Datasources call `ApiClient` and return DTOs; repositories map to entities. Until a backend exists, keep a `MockDatasource` implementing the same repository interface so the architecture is real and swappable.

---

## 10. Data Layer

- **Models:** `XModel` classes mix entity fields + `static mock` + serialization. Split into `entity` (domain) + `dto` (data, with `fromJson/toJson`) + mapper.
- **Repositories:** none — add `XRepository` interface (domain) + `XRepositoryImpl` (data) depending on datasource interface.
- **Datasource:** `CustomerSuggestionsService` → `CustomerSuggestionLocalDatasource` behind an interface.

---

## 11. Domain Layer (missing entirely)

Add per feature: `entities/`, `repositories/` (abstract), `usecases/`. Define business rules (e.g. `validateVehicleCustomer`, `getRoleConfigs`) as pure, testable use cases.

---

## 12. Presentation Layer Migration to Riverpod

- Wrap `MaterialApp.router` in `ProviderScope`.
- Each screen: `ConsumerWidget`/`ConsumerStatefulWidget` watching `someNotifierProvider`.
- `AsyncNotifier` for data-loading screens (replaces `_isLoading`/`_error`/`Future.delayed`).
- Navigation: use `context.go`/`context.push` (go_router); remove `Navigator.push` + `MaterialPageRoute`; delete `NavigatorService`.

---

## 13. Testing Strategy

- **Unit:** entities, mappers, use cases, repository impls (with mocked datasource), `Result`/`Failure` handling.
- **Widget:** one per migrated screen (render + tap + assert state via providers).
- **Integration:** go_router navigation flow (role → login → dashboard).
- **First concrete test:** replace the broken counter test with a `ProviderScope` + `MaterialApp.router` smoke test that pumps `RoleSelectionView` and asserts it renders.
- Add `mockito`/`mocktail` for datasource mocking.

---

## 14b. Centralized App Foundation (user requirement: "centralized app")

**Requirement:** Theme, colors, typography, and shared widgets are defined **once** in `core/`. No feature may redefine or re-code them. This is enforced as a hard rule (see §16b lint + Definition of Done).

### 14b.1 Verified fragmentation (why this is needed)
- **842 inline `Color(0xFF…)` literals** across the app; **763 inline `BorderRadius.circular`/`BoxShadow`/`withOpacity`** repetitions.
- **`kBlue` is defined 3× with different values:** `main.dart:21` (`0xFF1A73E8`), `core/constants/app_colors.dart` (`0xFF2563EB`), `advisor_dashboard/vehicle_customer/shared_widgets.dart:4` (`0xFF2196F3`). Files importing two of them must `hide` duplicates (e.g. `customer_service_status_view.dart:6` `import '…/main.dart' hide kBlue, kText, kText3, kBlueBg, kText4;`). This is a compile landmine.
- **`DC` color class is copy-pasted** into `dashboard_view.dart:39`, `crm_dasboard_view.dart:59`, `customer_dashboard_view.dart:33` (identical palettes).
- **`app_text_styles.dart`** duplicates `app_fonts.dart`'s `AppTextStyles` but without `GoogleFonts` (dead; delete).
- **Two `AppTextStyles`/`kSurface` pairs** coexist (main.dart vs core/constants).

### 14b.2 Single source of truth (the `core/` foundation)
**Goal: SAME UI / SAME layout — only moved into one place.** No redesign, no restyle.
The canonical palette is the existing `core/constants/app_colors.dart` `k*` set (already used by `customer_*` features and is the most complete). Conflicting duplicates in `DC` (dashboard/crm/customer) and advisor `_k*` are mapped to the canonical `k*` value (one value chosen per token; recorded below so the look is preserved 1:1).

```
lib/core/
  theme/
    app_colors.dart        # AppColors — canonical tokens (values taken from
                            #   current app_colors.dart / DC / advisor, choosing ONE
                            #   value per token so the on-screen look is unchanged):
                            #   bg         = 0xFFF4F6FA   (kBg)
                            #   surface     = 0xFFFFFFFF   (kSurface)
                            #   surfaceAlt  = 0xFFF0F3F7   (DC.surfaceAlt)
                            #   border      = 0xFFE4E7EE   (kBorder)   [DC.border 0xFFE2E8EF also used -> pick kBorder]
                            #   borderMd    = 0xFFCDD1DB   (kBorderMd)
                            #   line        = 0xFFE9ECF2   (advisor _kLine)
                            #   stroke      = 0xFFD4D9E6   (advisor _kStroke)
                            #   textPrimary = 0xFF0F172A   (kText)
                            #   text2       = 0xFF334155   (kText2)
                            #   text3       = 0xFF64748B   (kText3 / DC.textM)
                            #   text4       = 0xFF94A3B8   (kText4)
                            #   primary      = 0xFF2563EB   (kBlue)   [resolves 3x kBlue conflict]
                            #   primaryBg   = 0xFFEFF6FF   (kBlueBg)
                            #   primaryBorder= 0xFFBFDBFE   (kBlueBorder)
                            #   success     = 0xFF16A34A   (kGreen)
                            #   successBg  = 0xFFF0FDF4   (kGreenBg)
                            #   successBorder=0xFFBBF7D0  (kGreenBorder)
                            #   warning     = 0xFFD97706   (kAmber)  [resolves amber 0xFFB86B00 vs 0xFFD97706]
                            #   warningBg  = 0xFFFFFBEB   (kAmberBg)
                            #   warningBorder=0xFFFDE68A (kAmberBorder)
                            #   danger      = 0xFFDC2626   (kRed)
                            #   dangerBg   = 0xFFFEF2F2   (kRedBg)
                            #   dangerBorder=0xFFFECACA  (kRedBorder)
                            #   info        = 0xFF7C3AED   (kPurple)
                            #   infoBg     = 0xFFF5F3FF   (kPurpleBg)
                            #   infoBorder = 0xFFDDD6FE   (kPurpleBorder)
                            #   navy        = 0xFF0F1D3A   (advisor _kNavy)   # dark gradient start
                            #   accent      = 0xFF1B9AAA   (DC.accent)        # teal gradient end
                            #   canvas      = 0xFFF4F6FA   (advisor _kCanvas)
                            # NO raw Color(0xFF…) literals anywhere in lib/features.
    app_dimensions.dart    # radii actually in use (verified): 2,3,4,5,6,7,8,9,10,
                            #   11,12,13,14,15,16,18,20,22,24,99 -> name them
                            #   r2..r24 + rPill(99). Plus spacing s4..s32 and
                            #   elevation/icon sizes. (kills 763 inline BorderRadius)
    app_text_styles.dart  # AppTextStyles.* via GoogleFonts (Orbitron/Rajdhani/JetBrainsMono).
                            #   = current app_fonts.dart content; the OTHER
                            #   app_text_styles.dart (no GoogleFonts) is deleted.
    app_theme.dart        # AppTheme.light / .dark -> ThemeData(colorScheme, textTheme,
                            #   appBarTheme, cardTheme, inputDecorationTheme, elevatedButtonTheme).
                            #   main.dart calls AppTheme.light only.
  widgets/                # AppTextField, PrimaryButton, SecondaryButton, AppTopBar,
                            #   StatusPill, SectionHeader, AppCard, LoadingIndicator,
                            #   ErrorView, EmptyState, ShimmerCard. All consume AppColors/
                            #   AppDimensions ONLY.
  constants/             # AppStrings, AppDurations, AppTimeSlots (kTimeSlots moved here).
```
Rules:
- **Colors:** features reference `AppColors.primary` / `AppColors.successBg` etc.; never `Color(0xFF…)`. The chosen canonical hex per token is fixed above so the rendered UI is identical to today.
- **Radii/spacing:** `AppDimensions.r12`, `AppDimensions.s16` — no `BorderRadius.circular(12)` in features. (Every radius value currently used is already covered by the named set, so zero visual change.)
- **Typography:** `AppTextStyles.rajdhaniTitle()` (GoogleFonts-backed), never raw `TextStyle(fontFamily:…)` or inline `GoogleFonts.*` in feature widgets.
- **Buttons/inputs/cards:** always the `core/widgets` equivalents; no re-implemented text field / button / top bar per screen.
- **Theme switch:** `MaterialApp.theme = AppTheme.light` (and `.dark` only if settings require). No per-screen `ThemeData` or `ColorScheme.fromSeed` in `main.dart` beyond delegating to `AppTheme`.
- **No UI restyle:** this phase is purely relocation. Token *names* may be normalized to the `AppColors.*` scheme, but the *hex values and layout metrics stay exactly as the app renders today*. Do not "improve" spacing, contrast, or branding.

### 14b.3 De-duplication steps (Phase 0) — relocation only, no restyle
1. Delete `core/theme/app_text_styles.dart` (dead dup). Keep `core/theme/app_fonts.dart` → rename to `app_text_styles.dart` as the single `AppTextStyles` (GoogleFonts-backed). **Keep every GoogleFonts style exactly as-is** (Orbitron/Rajdhani/JetBrains Mono, same sizes/weights) so typography is unchanged.
2. Collapse `main.dart` color constants + `core/constants/app_colors.dart` + `shared_widgets.dart` `kBlue`/`kBorderColor` + all `DC` classes → **one** `AppColors` in `core/theme/app_colors.dart`, using the canonical hex values in §14b.2 (each chosen to preserve the current on-screen look; the 3× `kBlue` and 2× `amber`/`green` conflicts are resolved to one value each, recorded in the migration commit). Move `kTimeSlots` → `core/constants/app_durations.dart` (`AppTimeSlots`).
3. Add `AppDimensions` (the exact radii set 2..24/99 + spacing) and `AppTheme` (light/dark `ThemeData`) — mirror the metrics already used; do not change values.
4. Build `core/widgets` set from existing `app_widgets.dart` (`InnerTopBar`, `CustomerTopBar`, `StatusPill`, `SectionHeader`) + `app_card.dart` (`AppCard`), unified onto `AppColors`/`AppDimensions`. Widgets keep their current visual treatment.
5. Replace every `import '…/main.dart' hide …` (the `hide` hacks) with `core/theme` imports; delete the duplicate constants from `main.dart`. After this, the app renders identically — only the import source changed.



```
lib/
  main.dart                      # bootstrap only
  core/
    config/                     # env, app_config
    theme/                      # colors, text_styles, app_theme
    constants/                  # strings, dims, enums (UserRole)
    errors/                     # failures, exceptions, result
    network/                    # api_client, interceptors (later)
    storage/                    # hive init, local datasource base
    router/                     # go_router config (replaces routes/)
    utils/                      # extensions, formatters
    widgets/                    # shared: AppTextField, PrimaryButton, AppTopBar, StatusPill, LoadingIndicator, ErrorView
  shared/                       # cross-feature widgets/models if truly shared
  features/
    auth/                       # login, role_selection, forgot_password
      data/{datasources,models/repositories}
      domain/{entities,repositories,usecases}
      presentation/{pages,widgets,providers,state}
    advisor/                    # advisor dashboard + inspection + vehicle_customer
      data/ domain/ presentation/
    customer/
    dashboard/                  # owner dashboard
    crm/
    supervisor/
    technician/
    job_cards/
    dashboard_menu/             # accounts receivable, approvals, etc. (or fold into owner dashboard)
```

Each feature contains `data/`, `domain/`, `presentation/` with the standard inner folders.

---

## 15. Migration Roadmap (incremental, compile-safe)

### Phase 0 — Prerequisites + Centralized Foundation (low risk)
- Add `flutter_riverpod` + codegen (`riverpod_generator`, `riverpod_annotation`, `build_runner`) + `freezed`/`freezed_annotation` + `mocktail` (dev) to `pubspec.yaml`; run `flutter pub get` + `dart run build_runner build`.
- **Centralize (§14b):** build the single-source `core/theme` (`AppColors`, `AppDimensions`, `AppTextStyles` via GoogleFonts, `AppTheme` light/dark) and `core/widgets` (`AppTextField`, `PrimaryButton`, `AppTopBar`, `StatusPill`, `SectionHeader`, `AppCard`, `LoadingIndicator`, `ErrorView`, `EmptyState`). Collapse the 3× `kBlue`, the `DC` class copies, and the dead `app_text_styles.dart` into `AppColors`. Resolve the `import '…/main.dart' hide …` hacks.
- Create `core/errors/` (`Result`, `Failure` subtypes, `AppException`).
- Replace broken `test/widget_test.dart` with a Riverpod + go_router smoke test (pump `RoleSelectionView`).
- **Risk:** low. **Depends on:** none. **Effort:** M (foundation is the biggest single chunk; do it once, correctly).

### Phase 1 — Routing + DI foundation
- Create `core/router/app_router.dart` with go_router; migrate screens to `context.go`/`push`.
- Delete `routes/navigatorservice.dart` and `advisor_home_view_wiring.dart`.
- Wrap app in `ProviderScope`; remove `MultiProvider` from `main.dart` (keep providers defined locally per feature).
- **Risk:** medium (navigation touches many files). **Depends on:** Phase 0. **Effort:** M.

### Phase 2 — Auth feature (pilot migration, end-to-end)
- `features/auth/`: extract `UserRole` entity + `RoleConfig` entity; repository interface + mock impl; use cases (`GetRoleConfigs`, `Authenticate`); `RoleSelectionNotifier` (AsyncNotifier) + `LoginNotifier`; convert `role_selection_view` & `login_view` to Riverpod; remove per-role login screens' duplicated nav switch (use go_router by role).
- **Risk:** medium. **Depends on:** Phase 1. **Effort:** M. **This proves the pattern for all other features.**

### Phase 3..N — Migrate remaining features one at a time
Order (lowest coupling first). For each feature follow the **Definition of Done** below.
Order: `dashboard_menu` items (AR, approvals, job status, document expiry, pending job cards, active job cards) → `job_cards` → `advisor` (incl. `vehicle_customer` + Hive suggestions datasource + `inspection`) → `customer` → `technician` → `supervisor` → `crm` → `dashboard` (owner).
- **Risk:** per-feature low/medium. **Depends on:** Phase 2 pattern. **Effort:** M each.

#### 3.1 Mock data strategy (applies to every feature)
Each feature gets a `MockXDatasource` implementing the same repository interface the future real API will. Mock datasources:
- Return `Future` (with a small `Future.delayed` only to simulate latency, kept in the datasource, NOT the Notifier).
- Wrap failures in `Result.failure(...)` so error paths are real and testable.
- Live in `features/<f>/data/datasources/`. The repository impl chooses mock vs real via a flag/DI later.

#### 3.2 Hardest feature: `advisor` inspection flow
`InspectionViewModel` is a giant mutable form. Do NOT wrap it in a Notifier that holds mutable maps/lists. Instead:
1. Define a freezed `InspectionState` (statuses map, collapsed map, media map, service/part lines as freezed lists, repair-order fields).
2. `InspectionNotifier extends Notifier<InspectionState>` with pure reducers: `setStatus`, `addPhoto`, `addService`, etc., each doing `state = state.copyWith(...)`.
3. `ServiceLineItem`/`PartLineItem`/`ItemMedia` become **freezed, deeply immutable**; updates return new instances.
4. Media paths (camera/gallery) come from `image_picker` in the view → passed into the notifier as strings (no framework deps in state).
- **Risk:** high (large surface, many widgets depend on it). Migrate inspection **last within the advisor feature**, after its dashboard + vehicle_customer are done.

#### Definition of Done — per feature
- [ ] Uses **only** `core/theme` (`AppColors`/`AppDimensions`/`AppTextStyles`/`AppTheme`) and `core/widgets`; **zero** inline `Color(0xFF…)`, `BorderRadius.circular`, or raw `GoogleFonts.*` in the feature.
- [ ] `domain/entities/` freezed entities (deeply immutable); `domain/repositories/<f>_repository.dart` abstract interface.
- [ ] `data/models/` DTOs (+ `fromJson/toJson` if a real API is anticipated); mapper DTO↔entity.
- [ ] `data/datasources/` mock datasource implementing the interface; `data/repositories/` impl depending on the datasource interface.
- [ ] `domain/usecases/` pure, testable use cases (fetch list, filter, submit, validate).
- [ ] `presentation/providers/` `@riverpod` Notifier/AsyncNotifier; **no `ChangeNotifier`, no mutable shared objects, no `BuildContext` in providers**.
- [ ] `presentation/pages/` + `presentation/widgets/` use `ConsumerWidget`/`ref.watch`; local-only UI (tab index, step index) uses `StateProvider` or a leaf `ConsumerStatefulWidget`'s `setState`.
- [ ] `flutter analyze` clean; unit test for use cases + repository (mocktail); widget test for the main page.
- [ ] No remaining `provider`/`ChangeNotifier` import inside the feature.

### Final — Cleanup
- Remove `provider` package once no `ChangeNotifier`/`context.watch` remains.
- Run `flutter analyze` + `flutter test`; enable stricter `analysis_options.yaml` (add `prefer_const_constructors`, `avoid_print`, etc.).
- **Risk:** low. **Effort:** S.

---

## 16. Riverpod Rules (to enforce during implementation)
- Use `Notifier`/`AsyncNotifier` + `NotifierProvider`/`AsyncNotifierProvider`; `FutureProvider`/`StreamProvider`/`Provider` as needed.
- No `ChangeNotifier`. No global mutable state. No `MultiProvider` nesting.
- `ref.watch` selectively; `ref.read` for one-shot actions; `ref.listen` for navigation/side-effects.
- Immutable state (freezed or hand-written const + copyWith).

## 16b. Centralization Rules (hard, user requirement)
- **No color literals in features:** reference `AppColors.*` only. `Color(0xFF…)` in `lib/features/**` is a lint error (custom analyzer rule or `custom_lint`).
- **No duplicate palettes:** the `DC` class, `kBlue`, `kSurface`, `kBg`, `kBorder` families are deleted; everything routes through `AppColors`. The `import '…/main.dart' hide …` hacks are removed.
- **No inline radii/spacing:** use `AppDimensions.r*` / `AppDimensions.s*`. No `BorderRadius.circular(<n>)` in features.
- **No raw `GoogleFonts.*` / `TextStyle(fontFamily:…)` in feature widgets:** use `AppTextStyles.*`.
- **No re-implemented buttons/inputs/top-bars/cards:** use `core/widgets`. A new shared widget is added to `core/widgets`, never duplicated per screen.
- **One `ThemeData`:** `AppTheme.light`/`AppTheme.dark`; `main.dart` delegates and never redefines colors/schemes inline.
- **No UI restyle (hard):** centralization is relocation only. Token names may normalize to `AppColors.*`, but hex values, radii, spacing, font sizes/weights, and branding stay **exactly as the app renders today**. Do not "improve" contrast, spacing, or look. Visual diff of the app before vs after Phase 0 must be nil except import paths.
- Enforcement: add `custom_lint` (or analyzer `avoid_classes_with_only_static_members` exceptions + a CI grep guard `rg 'Color\(0x' lib/features`) to block regressions.

## 17. Error Handling
- `Result<T, Failure>` (or `Either`). `Failure` subtypes: `NetworkFailure`, `CacheFailure`, `ValidationFailure`, `UnknownFailure`. No silent `catch (_)` (the one in `customer_suggestions_service.dart:47` must log/rethrow or return explicit failure).

## 18. Scoring Targets (post-migration)
- Maintainability 8/10, Scalability 8/10, Testability 8/10.

## 19. Decided Approach (user-confirmed)
- **Backend:** Mock now, real later. Every feature gets a repository interface + a `MockDatasource` implementing it; a real `ApiClient` (Dio) drops in later with zero UI/use-case changes.
- **Riverpod style:** Codegen. Use `riverpod_generator` (`@riverpod`) + `freezed` for immutable state/entities/DTOs. Add `build_runner` to the workflow.
- **Scope:** This session is **plan/approval only** — no source edits. Implementation begins in a later session once the plan is approved.

## 20. Prioritized Checklist
1. Add `flutter_riverpod`, `riverpod_generator`, `riverpod_annotation`, `freezed`, `freezed_annotation`, `build_runner`, `mocktail` (dev), `custom_lint` (dev) to `pubspec.yaml`; run `flutter pub get` + `dart run build_runner build`.
2. **Centralize foundation (§14b):** build `core/theme` (`AppColors`, `AppDimensions`, `AppTextStyles` via GoogleFonts, `AppTheme` light/dark) + `core/widgets` (`AppTextField`, `PrimaryButton`, `SecondaryButton`, `AppTopBar`, `StatusPill`, `SectionHeader`, `AppCard`, `LoadingIndicator`, `ErrorView`, `EmptyState`). Collapse the 3× `kBlue`, all `DC` class copies, `kSurface`/`kBg`/`kBorder` pairs, and dead `app_text_styles.dart` into `AppColors`; remove every `import '…/main.dart' hide …` hack. Add a `custom_lint` rule + CI grep guard (`rg 'Color\(0x' lib/features`) to block color/radius/font literals in features.
3. Create `core/errors/` (`Result`, `Failure` subtypes, `AppException`).
4. Fix/replace the default counter test with a Riverpod + go_router smoke test (pump `RoleSelectionView`).
5. Set up `ProviderScope` + `core/router/app_router.dart` (go_router only); delete dead `NavigatorService` + `advisor_home_view_wiring.dart`.
6. **Pilot (auth):** `features/auth/` — `UserRole`/`RoleConfig` freezed entities → `AuthRepository` interface + `MockAuthDatasource` → use cases (`GetRoleConfigs`, `Authenticate`) → `@riverpod` `RoleSelectionNotifier`/`LoginNotifier` → convert views using `core/widgets` + `AppColors`/`AppTextStyles`; drop per-role nav switch in favor of go_router-by-role. Add unit + widget tests.
7. Migrate remaining features incrementally in order: dashboard_menu → job_cards → advisor (vehicle_customer + Hive local datasource + inspection) → customer → technician → supervisor → crm → dashboard. Each: entities → repo+mock datasource → use cases → @riverpod Notifier → view (only `core` tokens/widgets) → tests.
8. Replace `setState` god widgets with composed `ConsumerWidget`s + `core/widgets`; local-only UI state uses `StateProvider` or leaf `setState`.
9. Move `CustomerSuggestionsService` behind `CustomerSuggestionLocalDatasource` interface + `CustomerSuggestionRepository` (used by advisor feature).
10. Remove `provider` package once no `ChangeNotifier`/`context.watch` remains; tighten `analysis_options.yaml` (+ `custom_lint` rules); run `flutter analyze` + `flutter test` + CI guard.

---

## 21. Validation Plan (per phase)
- `flutter pub get` + `dart run build_runner build --delete-conflicting-outputs` succeeds.
- `flutter analyze` reports no errors after each phase.
- `flutter test` green (smoke test + new unit/widget tests per migrated feature).
- App still launches to `RoleSelectionView` and navigates through at least one full role flow after the auth pilot.
- No `ChangeNotifier`/`provider` import remains after the final cleanup phase.
- **Regression check for mutation bug:** after migrating `technician`/`crm`/`inspection`, verify a task-status toggle / lead toggle / inspection photo-add updates the UI and survives a route pop+push (no lost updates). This is the key correctness gate for the immutable-state conversion.

## 22. Risks
- Navigation refactor (Phase 1) touches many files → do it behind go_router and verify each route.
- God-widget decomposition can introduce visual regressions → keep leaf widgets visually identical; compare against current screens during review.
- Codegen adds build_runner to CI/dev workflow → document the `build_runner` watch command in README/AGENTS.md.
- **In-place mutation bug** (§6) is silent today; converting to immutable state will surface it. Mitigation: freeze entities with freezed and route all updates through `copyWith`; add a widget test that toggles state and asserts the rebuild.
- **Inspection feature** is the largest risk (giant mutable form + media + repair order). Sequence it last within `advisor`; keep `AsyncNotifier` only for the submit, `Notifier` for the in-memory form.

## 23. Open design questions (resolve at implementation start, recommended answers)
1. **`BuildContext`-free navigation:** Use go_router `context.go`/`push` from widgets (keeps providers pure). **CONFIRMED by user.** No Riverpod navigation service will be built; `NavigatorService` is deleted.
2. **Selected JobCard for detail route:** typed go_router param vs `selectedJobCardProvider`. Recommended: `selectedJobCardProvider` set on tap, detail view reads via `ref.watch` (avoids `state.extra as` cast).
3. **Settings (CRM notifications/dark/autoAssign):** keep as local `StateProvider`/notifier (UI-only prefs) or persist via Hive `AppPreferencesDatasource`? Recommended: `StateProvider` for now, Hive persistence optional later.
4. **`dashboard` (owner) vs `dashboard_menu`:** fold the menu items (AR, approvals, job status, etc.) into the owner `dashboard` feature as sub-pages, or keep `dashboard_menu` as its own feature? Recommended: keep `dashboard_menu` items as routes/pages within the owner `dashboard` feature to avoid a feature with no domain of its own.
5. **Fonts offline behavior (verified):** `Orbitron`/`Rajdhani`/`JetBrains Mono` are used 144× via `GoogleFonts.*` but are **NOT declared in pubspec** — they download at runtime (breaks offline / first paint). Recommended: keep `GoogleFonts` for now (no behavior change), and as a follow-up optionally bundle the 3 fonts via pubspec `fonts:` + `GoogleFonts` offline config. **Out of scope for the migration** unless you want it bundled now.
6. **Riverpod + go_router integration (verified):** no Riverpod present. Use `ProviderScope` (from `flutter_riverpod`) wrapping `MaterialApp.router(routerConfig: appRouter)`, where `appRouter` is a top-level `GoRouter` (go_router ^17.1.0 already used). No extra `riverpod_go_router` package required for basic `context.go`/`push` + `ref.watch`. If a `refreshListenable`/auth-gate is needed later, a `Listenable` backed by a Riverpod auth provider can be added without restructuring.
