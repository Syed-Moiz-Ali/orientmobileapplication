# Flutter Local-First Architecture Plan

> Implementation-ready plan for Orient Mobile Application (vehicle service workshop).

---

## 1. Context & Constraints

- Multi-role workshop app (Owner, Advisor, Technician, Supervisor, Customer, CRM).
- All data is mock/in-memory; no Hive, Dio, or real API yet.
- State management: hand-written `Notifier<State>` + `copyWith` for mutable state, `FutureProvider` for reads, `Result<T>` sealed class for errors.
- **Critical gap:** The Advisor Inspection Workflow (5-screen wizard) has ~35 form fields, 24 inspection items, per-item media, and service/parts line items. All state is lost on app kill. "Save draft" currently just pops the route and shows a toast — it does not persist anything.
- Navigation uses GoRouter with callbacks passed via `state.extra` as `Map<String, dynamic>`.

---

## 2. Dependencies to Add

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  dio: ^5.7.0
  connectivity_plus: ^6.0.5
  uuid: ^4.5.1
```

---

## 3. Core Infrastructure: `core/local/`

Create `lib/core/local/` with:

```
core/local/
├── hive/
│   └── hive_registry.dart          # initHive(), box open/close, adapter registration
├── sync/
│   ├── sync_engine.dart            # Singleton Riverpod provider, drains queue
│   ├── sync_queue.dart             # Thin wrapper over Box<SyncOperation>
│   ├── sync_operation.dart         # Value object + hand-written TypeAdapter
│   ├── conflict_resolver.dart      # Field-level merge: server non-null wins
│   └── sync_status.dart            # Enum: idle, syncing, success, failure, conflict
├── repositories/
│   ├── local_repository.dart       # Abstract CRUD interface
│   └── remote_repository.dart      # Abstract CRUD interface
└── exceptions/
    └── sync_exceptions.dart        # ConflictException, SyncQueueFullException
```

---

## 4. Hive Box Structure

Open these boxes in `HiveRegistry.initHive()`:

| Box Name      | Key Type | Value Type             | Purpose                              |
| ------------- | -------- | ---------------------- | ------------------------------------ |
| `inspections` | `String` | `Map<String, dynamic>` | Draft + submitted inspections        |
| `sync_queue`  | `String` | `SyncOperation`        | Pending remote operations            |
| `sync_failed` | `String` | `SyncOperation`        | Operations that exceeded retry limit |

**Storage strategy:** Store `Map<String, dynamic>` (not typed entities) in feature boxes. This avoids N `TypeAdapter` classes and tolerates schema evolution via null-safe `fromJson()` defaults. Only `SyncOperation` gets a hand-written `TypeAdapter` because it lives in the `sync_queue` box and must be queryable.

---

## 5. `SyncOperation` Shape

```dart
@HiveType(typeId: 0)
class SyncOperation extends HiveObject {
  @HiveField(0) final String id;           // UUID v4
  @HiveField(1) final String entityType;   // 'inspection', 'job_card', etc.
  @HiveField(2) final String entityId;     // stable business id
  @HiveField(3) final ChangeType changeType; // create, update, delete
  @HiveField(4) final Map<String, dynamic> payload;
  @HiveField(5) final int timestamp;
  @HiveField(6) int retryCount;
}

enum ChangeType { create, update, delete }
```

Hand-write the `TypeAdapter` for `SyncOperation`. No other adapters needed.

---

## 6. Inspection State: Business vs. UI Separation

`InspectionState` currently mixes business data and UI state. For persistence, split into:

**Business state (persist to Hive):**

- `statuses` — `Map<String, ItemStatus>`
- `media` — `Map<String, ItemMedia>`
- `preServicePhotos` — `List<String>`
- `serviceLines` — `List<ServiceLineItem>`
- `partLines` — `List<PartLineItem>`
- `referenceNumber`, `placeOfSupply`, `customerRequests`, `garageRecommendations`, `estimatedDelivery`, `notifyOwnerSmsEmail`, `tag`

**UI state (do NOT persist):**

- `collapsed` — `Map<String, bool>`
- `globalSearch` — `String`
- `sectionSearch` — `Map<String, String>`
- `showAll` — `bool`
- `notifyOwner` — `bool` (if it's just a UI toggle; confirm with user)

Add `toPersistableMap()` and `fromPersistableMap()` methods on `InspectionState` that serialize only the business fields.

---

## 7. Draft Lifecycle

| Action                   | Hive Write                                                                               | Sync Queue                                                         | UI Feedback                                                    |
| ------------------------ | ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------ | -------------------------------------------------------------- |
| `onSaveDraft` pressed    | Write `InspectionState.toPersistableMap()` to `inspections` box with key `current_draft` | None                                                               | Toast "Draft saved", pop to dashboard                          |
| `onPreview` pressed      | No additional write (state already persisted by each mutation)                           | None                                                               | Navigate to preview                                            |
| `onSubmit` pressed       | Mark inspection as `status: 'submitted'` in Hive                                         | Enqueue `SyncOperation` with full payload                          | Show progress indicator, then navigate to dashboard on success |
| App killed and restarted | `InspectionNotifier.build()` reads `current_draft` from Hive                             | —                                                                  | Form restores to last saved state                              |
| Sync succeeds            | —                                                                                        | Remove from `sync_queue`, clear `current_draft` from `inspections` | Toast "Synced"                                                 |
| Sync fails               | —                                                                                        | Increment `retryCount`; if >= 3, move to `sync_failed`             | Show error with retry                                          |

**Draft key:** Use a single key `current_draft` per feature box. When a new inspection starts, overwrite the previous draft. When submitted successfully, delete the `current_draft` key.

---

## 8. Final Sync Trigger

The primary trigger is the **SUBMIT INSPECTION** button in `InspectionPreviewView`. When tapped:

1. `InspectionNotifier.submitInspection()` compiles `InspectionEntity` from state.
2. Repository calls `local.save()` with `status: 'submitted'`, then `syncQueue.enqueue()`.
3. `SyncEngine.syncAll()` drains the queue:
   - For each operation, call the appropriate remote repository method.
   - On `409 Conflict`, invoke `ConflictResolver`.
   - On unresolvable conflict, emit `SyncStatus.conflict` and surface to UI.
4. On full success: delete `current_draft`, emit `SyncStatus.success`.
5. On partial failure: leave remaining ops in queue; UI shows retry button.

**Secondary trigger:** Connectivity listener in `SyncEngine` auto-retries queued operations when network returns.

---

## 9. Dual-Datasource Pattern (Per Feature)

### 9.1 Abstract Interfaces

```dart
// core/local/repositories/local_repository.dart
abstract class LocalRepository<T> {
  Future<void> save(String id, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> get(String id);
  Future<List<Map<String, dynamic>>> getAll();
  Future<void> delete(String id);
  Future<void> clear();
}

// core/local/repositories/remote_repository.dart
abstract class RemoteRepository<T> {
  Future<Result<T>> create(T entity);
  Future<Result<T>> update(T entity);
  Future<Result<void>> delete(String id);
}
```

### 9.2 Feature Datasource Layout

```
features/advisor/data/datasources/
├── advisor_local_datasource.dart         # Hive-backed, implements LocalRepository
├── advisor_mock_remote_datasource.dart   # CURRENT default, keep as-is
└── advisor_remote_datasource.dart        # Future Dio-backed implementation
```

### 9.3 Repository Implementation

```dart
class AdvisorRepositoryImpl implements AdvisorRepository {
  final AdvisorLocalDataSource local;
  final AdvisorMockRemoteDataSource remote; // swap to real impl later
  final SyncQueue syncQueue;

  AdvisorRepositoryImpl(this.local, this.remote, this.syncQueue);

  @override
  Future<Result<InspectionEntity>> getInspection(String id) async {
    final cached = await local.get(id);
    if (cached != null) return Result.success(InspectionEntity.fromJson(cached));

    final remoteResult = await remote.fetchInspection(id);
    return remoteResult.when(
      success: (entity) async {
        await local.save(id, entity.toJson());
        return Result.success(entity);
      },
      failure: (e) => Result.failure(e),
    );
  }

  @override
  Future<Result<InspectionEntity>> saveInspection(InspectionEntity entity) async {
    try {
      await local.save(entity.id, entity.toJson());
      syncQueue.enqueue(SyncOperation(
        id: const Uuid().v4(),
        entityType: 'inspection',
        entityId: entity.id,
        changeType: ChangeType.create,
        payload: entity.toJson(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
      return Result.success(entity);
    } catch (e) {
      return Result.failure(CacheException('Local save failed: $e'));
    }
  }
}
```

**Key rule:** Writes always go to Hive first. The remote datasource is only called during `SyncEngine.syncAll()`.

---

## 10. Riverpod Wiring

```dart
// Local datasource
final advisorLocalDataSourceProvider = Provider<AdvisorLocalDataSource>((ref) {
  return AdvisorLocalDataSource(Hive.box('inspections'));
});

// Remote datasource — mock is default, swap to real impl later
final advisorRemoteDataSourceProvider = Provider<AdvisorRemoteDataSource>((ref) {
  return const AdvisorMockRemoteDataSource();
});

// Sync queue
final syncQueueProvider = Provider<SyncQueue>((ref) {
  return SyncQueue(Hive.box('sync_queue'));
});

// Repository
final advisorRepositoryProvider = Provider<AdvisorRepository>((ref) {
  return AdvisorRepositoryImpl(
    ref.watch(advisorLocalDataSourceProvider),
    ref.watch(advisorRemoteDataSourceProvider),
    ref.watch(syncQueueProvider),
  );
});

// Sync engine
final syncEngineProvider = Provider<SyncEngine>((ref) {
  return SyncEngine(
    queueBox: Hive.box('sync_queue'),
    failedBox: Hive.box('sync_failed'),
    remoteRepository: ref.watch(advisorRepositoryProvider),
    connectivity: Connectivity(),
  );
});
```

---

## 11. InspectionNotifier Refactor

```dart
@riverpod
class InspectionNotifier extends _$InspectionNotifier {
  @override
  InspectionState build() {
    final local = ref.watch(advisorLocalDataSourceProvider);
    final draft = local.get('current_draft');
    return draft != null
        ? InspectionState.fromPersistableMap(draft)
        : const InspectionState();
  }

  Future<Result<void>> submitInspection() async {
    final entity = InspectionEntity.fromState(state);
    final repo = ref.watch(advisorRepositoryProvider);
    final result = await repo.saveInspection(entity);
    result.when(
      success: (_) async {
        final syncResult = await ref.watch(syncEngineProvider).syncAll();
        syncResult.when(
          success: (_) {
            state = state.copyWith(submitStatus: SubmitStatus.success);
          },
          failure: (e) {
            state = state.copyWith(submitStatus: SubmitStatus.failure, error: e.message);
          },
        );
      },
      failure: (e) {
        state = state.copyWith(submitStatus: SubmitStatus.failure, error: e.message);
      },
    );
    return result;
  }

  Future<void> updateItemRating(String itemId, ItemStatus status) async {
    state = state.copyWith(statuses: {...state.statuses, itemId: status});
    await _persistDraft();
  }

  Future<void> _persistDraft() async {
    final local = ref.watch(advisorLocalDataSourceProvider);
    await local.save('current_draft', state.toPersistableMap());
  }
}
```

**Rule:** Every mutating method calls `_persistDraft()` after updating state.

---

## 12. Navigation Callback Refactor

Replace the fragile `Map<String, dynamic>` extra callbacks with typed route parameters or a dedicated callback holder:

```dart
class InspectionCallbacks {
  final VoidCallback onBack;
  final VoidCallback onSaveDraft;
  final VoidCallback onPreview;
  const InspectionCallbacks({
    required this.onBack,
    required this.onSaveDraft,
    required this.onPreview,
  });
}
```

Pass `InspectionCallbacks` via `state.extra` and cast safely. This is a small refactor in `app_router.dart` and the two call sites in `advisor_home_view.dart` and `choose_inspection_view.dart`.

---

## 13. Logout Behavior

Current logout only shows a toast. For local-first:

- **Decision needed:** Should logout clear all Hive data, or keep it for next login?
  - **Recommendation:** Clear all Hive boxes on logout (call `Hive.box('inspections').clear()`, etc.). This is a single-user device assumption. If multi-user is needed later, scope boxes by `userId`.
- After clearing, navigate to `/role_selection_view`.

---

## 14. Scope: Which Workflows Get Local-First?

| Workflow                | Local-First Needed?      | Final Sync Trigger                    |
| ----------------------- | ------------------------ | ------------------------------------- |
| Advisor Inspection      | **Yes (critical)**       | Submit in InspectionPreviewView       |
| Advisor Repair Order    | Yes (follows inspection) | Submit in RepairOrderPreviewView      |
| Technician Job Complete | Yes                      | `completeJob()` in TechnicianNotifier |
| Supervisor Work Assign  | Yes                      | `saveAndAssign()`                     |
| Customer Booking        | Yes                      | `submitBooking()`                     |
| Dashboard/CRM reads     | No                       | N/A (read-only, mock is fine)         |
| Auth login              | No                       | N/A                                   |

---

## 15. Implementation Order

1. **Add pubspec dependencies** (`hive`, `hive_flutter`, `dio`, `connectivity_plus`, `uuid`).
2. **Create `core/local/`** — `HiveRegistry`, `SyncEngine`, `SyncQueue`, `SyncOperation` + `TypeAdapter`, `ConflictResolver`, abstract `LocalRepository`/`RemoteRepository`.
3. **Add `initHive()` in `main.dart`** before `runApp()`.
4. **Refactor `InspectionState`** — add `toPersistableMap()` / `fromPersistableMap()`, split business vs. UI fields.
5. **Create `AdvisorLocalDataSource`** wrapping `Hive.box('inspections')` with `saveDraft`, `getDraft`, `saveInspection`, `getInspection`.
6. **Refactor `InspectionNotifier`** to persist draft on every mutation, restore draft on `build()`.
7. **Refactor `advisor_home_view.dart` callbacks** — `onSaveDraft` calls `local.saveDraft()` instead of just popping; `onSubmit` calls `submitInspection()` then `syncEngine.syncAll()`.
8. **Wire `SyncEngine`** as Riverpod provider and implement `syncAll()`.
9. **Refactor navigation callbacks** from `Map<String, dynamic>` to typed `InspectionCallbacks`.
10. **Implement logout** — clear Hive boxes, navigate to role selection.
11. **Test:** fill inspection form, kill app, restart → state restores. Submit → sync drains queue.
12. **Migrate Technician** feature to same pattern (dual datasource + local-first mutations).
13. **Migrate remaining features** (supervisor, customer) in same pattern.

---

## 16. Data Integrity Guarantees

| Concern          | Mechanism                                                                               |
| ---------------- | --------------------------------------------------------------------------------------- |
| Atomicity        | Hive `box.put()` is synchronous within isolate; enqueue happens after successful write. |
| No data loss     | Draft persisted after every mutation; survives app kill.                                |
| Idempotency      | `SyncOperation.id` = UUID; remote endpoints accept idempotency-key header.              |
| Retry            | `retryCount` on `SyncOperation`; max 3, then move to `sync_failed` box.                 |
| Partial failure  | Sequential drain; successful ops removed from queue, failures stay for retry.           |
| Offline pause    | `connectivity_plus` listener pauses/resumes `SyncEngine`.                               |
| Schema evolution | `Map<String, dynamic>` storage + null-safe `fromJson()` tolerates missing fields.       |

---

## 17. Open Question

**Q: Should Hive data be cleared on logout, or scoped per user?**

Current app has no auth token or userId concept (mock login only). If this is a single-user kiosk-style device, clearing all Hive on logout is correct. If multiple users share the device, boxes must be scoped by `userId` and cleared only on user switch.

**My recommendation:** Clear all Hive on logout for now (single-user assumption). Add userId scoping later if multi-user is confirmed.
