import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_service_tracking.dart';
import 'package:customer_app/features/customer/presentation/support/customer_vehicle_presentation.dart';
import 'package:customer_app/features/customer/presentation/support/failed_vehicle_delete.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_vehicle_record.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_vehicles_filter_sheet.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_vehicles_search_sheet.dart';

/// My vehicles — the customer's registered cars.
///
/// A management surface, not a showcase: each record carries the vehicle's real
/// identity, the specification it actually holds, the real service state
/// derived from its own bookings, and the actions a customer has for it. There
/// is no vehicle photography (the API has no vehicle image), and no health or
/// service-due claim, because those fields are written by the client as
/// defaults rather than by the workshop.
///
/// Presentation only — providers, sync, predicates, refresh, routes and keys
/// are unchanged; the list is rebuilt on shared atoms (AppPageHeader, cards,
/// search/filter sheets, AppBanner, AppEmptyState/AppErrorState,
/// AppShimmerSkeleton).
class CustomerVehiclesTab extends ConsumerStatefulWidget {
  const CustomerVehiclesTab({super.key});

  @override
  ConsumerState<CustomerVehiclesTab> createState() =>
      _CustomerVehiclesTabState();
}

class _CustomerVehiclesTabState extends ConsumerState<CustomerVehiclesTab> {
  String _removingId = '';

  /// Server vehicle ids whose canonical reload has already been requested, so a
  /// failed refresh cannot turn the restore into an endless reload loop.
  final Set<String> _restoreRequested = {};

  /// List-scoped context filter (presentation state only; the context
  /// derivation stays in `CustomerVehiclePresentation.contextFor`).
  CustomerVehicleFilter _filter = CustomerVehicleFilter.all;

  /// Scroll anchors for search-result reveals (presentation only).
  final Map<String, GlobalKey> _scrollKeys = {};

  GlobalKey _scrollKeyFor(String id) =>
      _scrollKeys.putIfAbsent(id, () => GlobalKey());

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dash = ref.watch(customerDashboardProvider);
    final vehicles = dash.vehicles;
    final bookings =
        ref.watch(customerBookingsProvider).valueOrNull ??
        const <CustomerBookingEntity>[];
    final liveService =
        CustomerServiceTracking.isLiveService(dash.activeService)
        ? dash.activeService
        : null;

    // A terminally failed delete means the workshop may still hold the vehicle,
    // so the app must converge back to server truth instead of continuing to
    // hide it. Reload once per missing vehicle; if the reload fails the
    // persistent failed operation keeps the recovery available.
    final failedDeletes = ref.watch(customerFailedVehicleDeletesProvider);
    final failedByVehicle = <String, FailedVehicleDelete>{
      for (final failed in failedDeletes) failed.vehicleId: failed,
    };
    final missing = failedByVehicle.keys.toSet().difference(
      vehicles.map((vehicle) => vehicle.id).toSet(),
    );
    final toRestore = missing.difference(_restoreRequested);
    if (toRestore.isNotEmpty) {
      _restoreRequested.addAll(toRestore);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(customerDashboardProvider.notifier).refresh();
        }
      });
    }

    final firstLoadFailed =
        vehicles.isEmpty && dash.loadError.isNotEmpty && !dash.isLoading;

    // One derivation per build (same predicate the records use): the filter
    // sheet and the rendered list read the same map, so the filter can never
    // promise a vehicle the list does not show.
    final contexts = <String, CustomerVehicleContext?>{
      for (final vehicle in vehicles)
        vehicle.id: CustomerVehiclePresentation.contextFor(
          vehicle: vehicle,
          bookings: bookings,
          liveService: liveService,
        ),
    };
    bool matchesFilter(CustomerVehicleContext? serviceContext) =>
        switch (_filter) {
          CustomerVehicleFilter.all => true,
          CustomerVehicleFilter.inService =>
            serviceContext?.kind ==
              CustomerVehicleContextKind.inService,
          CustomerVehicleFilter.upcoming =>
            serviceContext?.kind == CustomerVehicleContextKind.upcoming,
          CustomerVehicleFilter.completed =>
            serviceContext?.kind == CustomerVehicleContextKind.completed,
          CustomerVehicleFilter.none => serviceContext == null,
        };
    final visible = [
      for (final vehicle in vehicles)
        if (matchesFilter(contexts[vehicle.id])) vehicle,
    ];
    _scrollKeys.removeWhere(
      (id, _) => !vehicles.any((vehicle) => vehicle.id == id),
    );

    // Progressive disclosure (the ONE sanctioned U1 exception on this
    // screen): the search + filter find-aids appear ONLY when the loaded list
    // has MORE THAN 5 items; with ≤ 5 items the cards stand alone.
    final showFindAids = vehicles.length > 5;
    final t = context.cx;
    final subtitle = _filter == CustomerVehicleFilter.all
        ? (vehicles.isEmpty
              ? t.vhCountNone
              : vehicles.length == 1
              ? t.vhCountOne
              : t.vhCountMany(vehicles.length))
        : t.vhCountMany(visible.length);

    return RefreshIndicator(
      onRefresh: () => ref.read(customerDashboardProvider.notifier).refresh(),
      color: colors.primary,
      child: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        maxContentWidth: 1040,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (dash.isLoading && vehicles.isEmpty)
              // Skeleton mirrors the cards: header lines + card shape.
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppShimmerSkeleton(width: 160, height: 26),
                  const SizedBox(height: AppDimensions.s10),
                  const AppShimmerSkeleton(width: 180, height: 12),
                  const SizedBox(height: AppDimensions.s20),
                  const AppShimmerSkeleton.card(height: 208),
                ],
              )
            else ...[
              AppPageHeader(
                title: t.vhTitle,
                subtitle: subtitle,
                actions: [
                  if (showFindAids) ...[
                    AppIconButton(
                      icon: Icons.search_rounded,
                      tooltip: t.vhSearchTitle,
                      onPressed: () => _openSearch(vehicles),
                    ),
                    AppIconButton(
                      icon: Icons.filter_list_rounded,
                      tooltip: t.vhFilterTitle,
                      onPressed: _openFilter,
                    ),
                  ],
                  if (vehicles.isNotEmpty)
                    TextButton.icon(
                      onPressed: () =>
                          context.push(AppRoutes.customerAddVehicle),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(t.vhAdd),
                    ),
                ],
              ),
              if (dash.loadError.isNotEmpty && vehicles.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.s16),
                AppBanner(
                  kind: AppBannerKind.warning,
                  message: t.stRefreshFail,
                  actionLabel: t.stRetry,
                  onAction: () => ref
                      .read(customerDashboardProvider.notifier)
                      .refresh(),
                ),
              ],
              // A failed delete whose vehicle cannot yet be restored still
              // needs a visible, retryable recovery path.
              if (missing.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.s16),
                for (final operation in [
                  for (final id in missing) failedByVehicle[id]!,
                ]) ...[
                  AppBanner(
                    kind: AppBannerKind.error,
                    message:
                        '${t.vhDeleteFailTitle} ${t.vhDeleteFailBody}',
                    actionLabel: _removingId.isEmpty
                        ? t.vhRetryRemoval
                        : null,
                    onAction: _removingId.isEmpty
                        ? () => _retryRemoval(operation)
                        : null,
                  ),
                  const SizedBox(height: AppDimensions.s8),
                ],
              ],
              const SizedBox(height: AppDimensions.s20),
              if (firstLoadFailed)
                AppErrorState(
                  title: t.vhLoadFailTitle,
                  message: t.vhLoadFailBody,
                  retryLabel: t.vhRetry,
                  onRetry: () => ref
                      .read(customerDashboardProvider.notifier)
                      .refresh(),
                )
              else if (vehicles.isEmpty)
                AppEmptyState(
                  icon: Icons.directions_car_outlined,
                  title: t.vhEmptyTitle,
                  message: t.vhEmptyBody,
                  actionLabel: t.vhAdd,
                  onAction: () =>
                      context.push(AppRoutes.customerAddVehicle),
                )
              else if (visible.isEmpty)
                _FilterNoMatch(
                  onClear: () => setState(
                    () => _filter = CustomerVehicleFilter.all,
                  ),
                )
              else
                _records(visible, contexts, failedByVehicle),
              const SizedBox(height: AppDimensions.s32),
            ],
          ],
        ),
      ),
    );
  }

  Widget _records(
    List<CustomerVehicleEntity> vehicles,
    Map<String, CustomerVehicleContext?> contexts,
    Map<String, FailedVehicleDelete> failedByVehicle,
  ) {
    final records = [
      for (final vehicle in vehicles)
        SizedBox(
          key: _scrollKeyFor(vehicle.id),
          child: CustomerVehicleRecord(
            key: ValueKey('vehicle-${vehicle.id}'),
            vehicle: vehicle,
            busy: _removingId == vehicle.id,
            serviceContext: contexts[vehicle.id],
            onBookService: () => context.push(
              AppRoutes.customerBookServiceLocation(vehicleId: vehicle.id),
            ),
            onEdit: () => context.push(AppRoutes.customerEditVehicle(vehicle.id)),
            onRemove: () => _confirmRemove(vehicle),
            onOpenBooking: (booking) =>
                context.push(AppRoutes.customerBookingDetail, extra: booking),
            onTrackService: () => context.push(AppRoutes.customerServiceStatus),
            syncFailed: ref
                .watch(vehicleIdentityReaderProvider)
                .hasFailedCreate(vehicle.id),
            onRetrySync: () => customerRetryVehicleSync(ref),
            deleteFailed: failedByVehicle.containsKey(vehicle.id),
            onRetryRemoval: () => _retryRemoval(failedByVehicle[vehicle.id]!),
          ),
        ),
    ];

    // One column on phones, two balanced columns where there is room.
    if (records.length < 4 || context.adaptive.isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < records.length; index++) ...[
            records[index],
            if (index < records.length - 1)
              const SizedBox(height: AppDimensions.s12),
          ],
        ],
      );
    }
    final columns = context.adaptive.isLarge ? 3 : 2;
    final size = (records.length / columns).ceil();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < columns; index++) ...[
          if (index > 0) const SizedBox(width: AppDimensions.s20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (
                  var row = index * size;
                  row < (index + 1) * size && row < records.length;
                  row++
                ) ...[
                  records[row],
                  if (row < (index + 1) * size - 1 && row < records.length - 1)
                    const SizedBox(height: AppDimensions.s12),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _openSearch(List<CustomerVehicleEntity> vehicles) {
    showCustomerVehiclesSearchSheet(
      context,
      vehicles: vehicles,
      onSelect: (vehicle) {
        final anchor = _scrollKeys[vehicle.id]?.currentContext;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (anchor != null) {
            Scrollable.ensureVisible(
              anchor,
              duration: const Duration(milliseconds: 300),
              alignment: 0.05,
            );
          }
        });
      },
    );
  }

  void _openFilter() {
    showCustomerVehiclesFilterSheet(
      context,
      selected: _filter,
      onApply: (selected) => setState(() => _filter = selected),
    );
  }

  Future<void> _confirmRemove(CustomerVehicleEntity vehicle) async {
    if (_removingId.isNotEmpty) return;
    final name = vehicle.displayName.trim();
    final plate = CustomerVehiclePresentation.plateLabel(vehicle.plateNumber);
    final t = context.cx;
    final colors = Theme.of(context).colorScheme;
    // Confirmation becomes a bottom sheet (destructive, no undo — same
    // customerRemoveVehicle handler + snackbar contracts as before).
    final confirmed =
        await showAppModalSheet<bool>(
          context: context,
          title: name.isEmpty ? t.vhRemoveNoName : t.vhRemoveTitle(name),
          builder: (sheetContext) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                plate.isEmpty
                    ? t.vhRemoveBodyNoPlate
                    : t.vhRemoveBody(plate),
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppDimensions.s16),
              FilledButton(
                onPressed: () => Navigator.of(sheetContext).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.error,
                  foregroundColor: colors.onError,
                ),
                child: Text(t.vhRemoveCta),
              ),
              const SizedBox(height: AppDimensions.s8),
              TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(false),
                child: Text(t.vhKeepCta),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;

    setState(() => _removingId = vehicle.id);
    var removed = false;
    try {
      removed = await customerRemoveVehicle(ref, vehicle.id);
    } catch (_) {
      removed = false;
    }
    if (!mounted) return;
    setState(() => _removingId = '');

    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          removed ? t.vhRemoved : t.vhRemoveFail,
        ),
        action: removed
            ? null
            : SnackBarAction(
                label: t.vhRetry,
                onPressed: () => _confirmRemove(vehicle),
              ),
      ),
    );
  }

  /// Replays one failed removal. The vehicle stays visible throughout; a failed
  /// retry leaves the recovery in place, and a successful one never restores the
  /// failure even if the follow-up refresh fails.
  Future<void> _retryRemoval(FailedVehicleDelete failed) async {
    if (_removingId.isNotEmpty) return;
    setState(() => _removingId = failed.vehicleId);

    final accepted = await ref
        .read(failedVehicleDeleteSyncProvider)
        .retry(failed.operationId);
    if (!mounted) return;

    ref.invalidate(customerFailedVehicleDeletesProvider);
    await ref.read(customerDashboardProvider.notifier).refresh();
    if (!mounted) return;
    setState(() => _removingId = '');

    if (!accepted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(context.cx.vhRemoveFail),
        ),
      );
    }
  }
}

/// Filter-no-match state: the loaded list is non-empty but nothing matches the
/// active context filter. One sentence + one Clear control.
class _FilterNoMatch extends StatelessWidget {
  final VoidCallback onClear;

  const _FilterNoMatch({required this.onClear});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.cx.vhFilterNoMatch,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.s8),
            TextButton(
              onPressed: onClear,
              child: Text(context.cx.vhFilterClear),
            ),
          ],
        ),
      ),
    );
  }
}
