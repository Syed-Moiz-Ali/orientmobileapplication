import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_service_tracking.dart';
import 'package:customer_app/features/customer/presentation/support/customer_vehicle_presentation.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_skeleton.dart';
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
              const _VehiclesSkeleton()
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
                _records(vehicles, bookings, liveService),
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
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Remove ${name.isEmpty ? 'this vehicle' : name}?',
      message: plate.isEmpty
          ? 'This vehicle will no longer appear in your vehicles.'
          : '$plate will be removed from your vehicles.',
      confirmLabel: 'Remove vehicle',
      cancelLabel: 'Keep vehicle',
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
          removed
              ? 'Vehicle removed.'
              : "We couldn't remove this vehicle. Please try again.",
        ),
        action: removed
            ? null
            : SnackBarAction(
                label: 'Retry',
                onPressed: () => _confirmRemove(vehicle),
              ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int count;
  final VoidCallback? onAdd;

  const _Header({required this.count, required this.onAdd});

  @override
  Widget build(BuildContext context) {
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
                  'My vehicles',
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
                label: const Text('Add vehicle'),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppDimensions.s4),
        Text(
          count == 0
              ? 'Registered vehicles appear here.'
              : count == 1
              ? '1 registered vehicle'
              : '$count registered vehicles',
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
              'No vehicles added yet',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.s4),
            Text(
              'Add your first vehicle to book service and keep your workshop '
              'activity connected to the correct car.',
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
                label: const Text('Add vehicle'),
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
              "We couldn't load your vehicles",
              style: theme.textTheme.titleSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.s4),
            Text(
              'Please try again in a moment.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.s12),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehiclesSkeleton extends StatelessWidget {
  const _VehiclesSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomerSkeleton(
      builder: (context, block) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomerSkeletonBox(width: 160, height: 26, color: block),
          const SizedBox(height: AppDimensions.s10),
          CustomerSkeletonBox(width: 180, height: 12, color: block),
          const SizedBox(height: AppDimensions.s20),
          CustomerSkeletonBox(
            height: 208,
            color: block,
            radius: AppDimensions.radiusCard,
          ),
        ],
      ),
    );
  }
}
