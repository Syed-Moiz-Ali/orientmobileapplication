# Orient Mobile — Architecture Guide

## Overview

Monorepo with 4 Flutter apps sharing 3 packages. Each app targets a specific user role.

## Structure

```
orientmobileapplication/
├── packages/
│   ├── shared_core/          # Theme, widgets, network, local storage, sync, errors
│   ├── shared_auth/          # Auth domain + login UI + state management
│   └── shared_models/        # Shared enums & domain models
│
├── apps/
│   ├── staff_app/            # Advisor + Supervisor + Technician (3 roles)
│   ├── owner_app/            # Owner dashboard, KPIs, approvals
│   ├── customer_app/         # Customer portal, bookings, vehicles
│   └── crm_app/              # CRM leads, sales, tasks
│
├── melos.yaml                # Workspace config + build scripts
└── ARCHITECTURE.md           # This file
```

## Dependency Graph

```
shared_models (no deps)
    ↑
shared_core (flutter_riverpod, dio, hive, google_fonts)
    ↑
shared_auth (shared_core, shared_models)
    ↑
apps/* (shared_auth, shared_core)
```

## Clean Architecture (per feature)

```
features/<name>/
├── data/
│   ├── datasources/          # Remote API + local storage implementations
│   ├── models/               # JSON-serializable DTOs
│   └── repositories/         # Repository implementations
├── domain/
│   ├── entities/             # Domain models
│   ├── repositories/         # Abstract repository interfaces
│   └── usecases/             # Business logic
└── presentation/
    ├── pages/                # Full-screen views
    ├── providers/            # Riverpod state management
    └── widgets/              # Feature-specific widgets
```

### Rules
- Presentation never imports from data layer directly — always goes through domain
- Providers always in `presentation/providers/`
- Use cases extracted from providers (testable, reusable)
- Every feature has all 3 layers (data, domain, presentation)

## State Management

- **Riverpod** — `flutter_riverpod` v2.6
- **AsyncState<T>** — sealed class with `AsyncInitial`, `AsyncLoading`, `AsyncData`, `AsyncError`
- **AsyncValueWidget** — renders loading/error/data states uniformly
- **ListState<T> + ListNotifierMixin** — for list-based views with search

```dart
// Standard pattern:
class MyNotifier extends Notifier<AsyncState<List<Item>>> {
  @override
  AsyncState<List<Item>> build() => const AsyncInitial();
  
  Future<void> load() async {
    state = const AsyncLoading();
    final result = await repository.getItems();
    state = result.when(
      success: (data) => AsyncData(data),
      failure: (err) => AsyncError(err.message),
    );
  }
}
```

## Navigation

- **GoRouter** for all screen-to-screen navigation
- `context.push('/route')` for forward navigation
- `context.pop()` for back navigation
- `Navigator.push` reserved for modal sheets and dialogs only

## Theming & Branding

- **BrandConfig** in shared_core — single source of truth for colors, fonts, icons
- **AppTheme.light(brand)** — generates ThemeData from BrandConfig
- Override `brandConfigProvider` per client for whitelabeling

```dart
// To rebrand for a client:
final clientBrand = BrandConfig.orient.copyWith(
  appName: 'Client Name',
  iconColor: Color(0xFF...),
);
```

## Feature Flags

- **FeatureFlags** in shared_core — enable/disable features per client
- Override `featureFlagsProvider` per client
- Features: inspections, reports, chat, notifications, sync, offline mode

```dart
final flags = ref.watch(featureFlagsProvider);
if (flags.enableReports) {
  // show reports
}
```

## Whitelabeling

To sell to a new client:
1. Update `BrandConfig` in `packages/shared_core/lib/src/branding/`
2. Update `FeatureFlags` if needed
3. Run `melos run build:apk:all` to build all 4 apps
4. Distribute the APKs

## Build Commands

```bash
# Analyze all code
melos run analyze

# Build all apps
melos run build:apk:all

# Build specific app
cd apps/staff_app && flutter build apk --release

# Get dependencies
melos run get
```

## Testing

- Unit tests: `domain/usecases/` — pure Dart, fast
- Widget tests: `presentation/pages/` — Flutter test
- Integration tests: Full auth flow

```bash
melos run test
```
