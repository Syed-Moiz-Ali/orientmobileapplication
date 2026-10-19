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
import 'package:customer_app/features/customer/presentation/widgets/customer_status_notices.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_vehicle_record.dart';

/// My vehicles — the customer's registered cars.
///
/// A management surface, not a showcase: each record carries the vehicle's real
/// identity, the specification it actually holds, the real service state
/// derived from its own bookings, and the actions a customer has for it. There
/// is no vehicle photography (the API has no vehicle image), and no health or
/// service-due claim, because those fields are written by the client as
/// defaults rather than by the workshop.
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
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
              // Phase 07.1: bespoke _VehiclesSkeleton migrated to AppSkeleton.
              const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSkeleton.text(width: 160, height: 26),
                  SizedBox(height: AppDimensions.s10),
                  AppSkeleton.text(width: 180, height: 12),
                  SizedBox(height: AppDimensions.s20),
                  AppSkeleton.card(height: 208),
                ],
              )
            else ...[
              _Header(
                count: vehicles.length,
                onAdd: vehicles.isEmpty
                    ? null
                    : () => context.push(AppRoutes.customerAddVehicle),
              ),
              if (dash.loadError.isNotEmpty && vehicles.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.s16),
                CustomerRefreshNotice(
                  onRetry: () =>
                      ref.read(customerDashboardProvider.notifier).refresh(),
                ),
              ],
              // A failed delete whose vehicle cannot yet be restored still needs
              // a visible, retryable recovery path.
              if (missing.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.s16),
                _UnmatchedDeleteRecovery(
                  operations: [for (final id in missing) failedByVehicle[id]!],
                  busyId: _removingId,
                  onRetry: _retryRemoval,
                ),
              ],
              const SizedBox(height: AppDimensions.s20),
              if (firstLoadFailed)
                _LoadFailure(
                  onRetry: () =>
                      ref.read(customerDashboardProvider.notifier).refresh(),
                )
              else if (vehicles.isEmpty)
                _NoVehicles(
                  onAdd: () => context.push(AppRoutes.customerAddVehicle),
                )
              else
                _records(vehicles, bookings, liveService, failedByVehicle),
              const SizedBox(height: AppDimensions.s32),
            ],
          ],
        ),
      ),
    );
  }

  Widget _records(
    List<CustomerVehicleEntity> vehicles,
    List<CustomerBookingEntity> bookings,
    CustomerServiceEntity? liveService,
    Map<String, FailedVehicleDelete> failedByVehicle,
  ) {
    final records = [
      for (final vehicle in vehicles)
        CustomerVehicleRecord(
          key: ValueKey('vehicle-${vehicle.id}'),
          vehicle: vehicle,
          busy: _removingId == vehicle.id,
          serviceContext: CustomerVehiclePresentation.contextFor(
            vehicle: vehicle,
            bookings: bookings,
            liveService: liveService,
          ),
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
    ];

    // One column on phones, two balanced columns where there is room.
    if (records.length < 4 || context.adaptive.isCompact) {
      return _Grouped(children: records);
    }
    final columns = context.adaptive.isLarge ? 3 : 2;
    final size = (records.length / columns).ceil();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < columns; index++) ...[
          if (index > 0) const SizedBox(width: AppDimensions.s20),
          Expanded(
            child: _Grouped(
              children: records.skip(index * size).take(size).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmRemove(CustomerVehicleEntity vehicle) async {
    if (_removingId.isNotEmpty) return;
    final name = vehicle.displayName.trim();
    final plate = CustomerVehiclePresentation.plateLabel(vehicle.plateNumber);
    final t = context.cx;
    final confirmed = await showAppConfirmationDialog(
      context,
      title: name.isEmpty ? t.vhRemoveNoName : t.vhRemoveTitle(name),
      message: plate.isEmpty
          ? t.vhRemoveBodyNoPlate
          : t.vhRemoveBody(plate),
      confirmLabel: t.vhRemoveCta,
      cancelLabel: t.vhKeepCta,
      icon: Icons.delete_outline_rounded,
      destructive: true,
    );
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

class _Header extends StatelessWidget {
  final int count;
  final VoidCallback? onAdd;

  const _Header({required this.count, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  t.vhTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
            ),
            if (onAdd != null) ...[
              const SizedBox(width: AppDimensions.s8),
              TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(context.cx.vhAdd),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppDimensions.s4),
        Text(
          count == 0
              ? t.vhCountNone
              : count == 1
              ? t.vhCountOne
              : t.vhCountMany(count),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// One grouped surface per column, rows separated by dividers.
class _Grouped extends StatelessWidget {
  final List<Widget> children;

  const _Grouped({required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1)
              Divider(height: 1, color: colors.outlineVariant),
          ],
        ],
      ),
    );
  }
}

class _NoVehicles extends StatelessWidget {
  final VoidCallback onAdd;

  const _NoVehicles({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.s18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.cx.vhEmptyTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.s4),
            Text(
              context.cx.vhEmptyBody,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppDimensions.s16),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(context.cx.vhAdd),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadFailure extends StatelessWidget {
  final VoidCallback onRetry;

  const _LoadFailure({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.s18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.cx.vhLoadFailTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.s4),
            Text(
              context.cx.vhLoadFailBody,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.s12),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(
                onPressed: onRetry,
                child: Text(context.cx.vhRetry),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Page-level recovery for a failed removal whose vehicle cannot yet be shown
/// (canonical reload pending or failing). It never fabricates the vehicle: it
/// states the honest server truth and offers the single retry.
class _UnmatchedDeleteRecovery extends StatelessWidget {
  final List<FailedVehicleDelete> operations;
  final String busyId;
  final Future<void> Function(FailedVehicleDelete operation) onRetry;

  const _UnmatchedDeleteRecovery({
    required this.operations,
    required this.busyId,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      liveRegion: true,
      container: true,
      label:
          '${context.cx.vhDeleteFailTitle} ${context.cx.vhDeleteFailBody}',
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.s14),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            colors.error.withValues(alpha: 0.05),
            colors.surface,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: colors.error.withValues(alpha: 0.20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: AppDimensions.iconSm,
                  color: colors.error,
                ),
                const SizedBox(width: AppDimensions.s6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.cx.vhDeleteFailTitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.r2),
                      Text(
                        context.cx.vhDeleteFailBody,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            for (final operation in operations) ...[
              const SizedBox(height: AppDimensions.s8),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: AppDimensions.touchTarget,
                  child: FilledButton(
                    onPressed: busyId.isNotEmpty
                        ? null
                        : () => onRetry(operation),
                    child: Text(
                      busyId == operation.vehicleId
                          ? context.cx.vhRetrying
                          : context.cx.vhRetryRemoval,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
