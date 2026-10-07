import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_bookings_presentation.dart';
import 'package:customer_app/features/customer/presentation/support/customer_service_tracking.dart';
import 'package:customer_app/features/customer/presentation/support/failed_booking_sync.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_booking_item.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_bookings_skeleton.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_failed_booking_item.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_status_notices.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_surface_panel.dart';

/// Customer Bookings â€” "my appointments and service history".
///
/// A management/history surface, not a second tracker: rows stay compact and
/// the live service timeline stays in Status. Everything shown comes from real
/// booking fields; there is no service catalogue, pricing, stock imagery or
/// fabricated availability.
class CustomerBookingsTab extends ConsumerWidget {
  const CustomerBookingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dash = ref.watch(customerDashboardProvider);
    final bookingsAsync = ref.watch(customerBookingsProvider);
    // Local bookings whose replay the workshop never accepted are terminal
    // failures, not lifecycle records: they are pulled out of the workshop feed
    // so they never render (or count) as an ordinary requested booking.
    final failedBookings = ref.watch(customerFailedBookingsProvider);
    final failedKeys = failedBookings
        .map((booking) => booking.identityKey)
        .toSet();
    final bookings =
        (bookingsAsync.valueOrNull ?? const <CustomerBookingEntity>[])
            .where(
              (booking) => !failedKeys.contains(
                CustomerBookingsPresentation.bookingKey(
                  vehicleName: booking.vehicleName,
                  plateNumber: booking.plateNumber,
                  service: booking.service,
                  date: booking.date,
                  time: booking.time,
                ),
              ),
            )
            .toList();

    // The bookings feed falls back to the local cache, so "nothing readable"
    // plus a reported failure is the only honest first-load error signal.
    final firstLoadFailed =
        bookings.isEmpty &&
        failedBookings.isEmpty &&
        (bookingsAsync.hasError || dash.loadError.isNotEmpty);

    if (firstLoadFailed) {
      return AppResponsivePage(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.s48),
          child: EmptyState(
            icon: Icons.sync_problem_rounded,
            title: "We couldn't load your bookings",
            message: 'Please try again in a moment.',
            actionLabel: 'Retry',
            onAction: () => _refresh(ref),
          ),
        ),
      );
    }

    if (bookingsAsync.isLoading && bookings.isEmpty) {
      return const CustomerBookingsSkeleton();
    }

    final active = <CustomerBookingEntity>[];
    final inWorkshop = <CustomerBookingEntity>[];
    final history = <CustomerBookingEntity>[];
    for (final booking in bookings) {
      switch (CustomerBookingsPresentation.groupOf(booking.status)) {
        case CustomerBookingGroup.inService:
          inWorkshop.add(booking);
          active.add(booking);
        case CustomerBookingGroup.upcoming:
          active.add(booking);
        case CustomerBookingGroup.history:
          history.add(booking);
      }
    }

    final activeOrdered = CustomerBookingsPresentation.sortByUpcoming(active);
    final historyOrdered = CustomerBookingsPresentation.sortByRecent(history);
    final liveService =
        CustomerServiceTracking.isLiveService(dash.activeService)
        ? dash.activeService
        : null;

    final sections = <Widget>[
      if (activeOrdered.isNotEmpty)
        _BookingSection(
          title: inWorkshop.isEmpty ? 'Upcoming' : 'Upcoming & in service',
          count: activeOrdered.length,
          bookings: activeOrdered,
          liveService: liveService,
          formatAmount: dash.formatAmount,
          onOpen: (booking) =>
              context.push(AppRoutes.customerBookingDetail, extra: booking),
          // Service Status is contextual: it is a pushed page, not a tab.
          onTrackService: () => context.push(AppRoutes.customerServiceStatus),
          onReviewApproval: (estimateId) =>
              context.go(AppRoutes.approvalsLocation(estimateId: estimateId)),
        ),
      if (historyOrdered.isNotEmpty)
        _BookingSection(
          title: 'History',
          count: historyOrdered.length,
          bookings: historyOrdered,
          liveService: liveService,
          formatAmount: dash.formatAmount,
          onOpen: (booking) =>
              context.push(AppRoutes.customerBookingDetail, extra: booking),
          // Service Status is contextual: it is a pushed page, not a tab.
          onTrackService: () => context.push(AppRoutes.customerServiceStatus),
          onReviewApproval: (estimateId) =>
              context.go(AppRoutes.approvalsLocation(estimateId: estimateId)),
        ),
    ];

    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      color: colors.primary,
      child: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        // A single group keeps a comfortable reading width; two groups share
        // the wider canvas instead of stretching one phone-wide column.
        maxContentWidth: sections.length == 2 ? 1080 : 760,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (dash.loadError.isNotEmpty && bookings.isNotEmpty) ...[
              CustomerRefreshNotice(onRetry: () => _refresh(ref)),
              const SizedBox(height: AppDimensions.s16),
            ],
            _BookingsHeader(
              subtitle: _subtitle(
                active: activeOrdered.length,
                inWorkshop: inWorkshop.length,
                history: historyOrdered.length,
              ),
              onBookService: bookings.isEmpty
                  ? null
                  : () => context.push(AppRoutes.customerBookService),
            ),
            const SizedBox(height: AppDimensions.s20),
            if (failedBookings.isNotEmpty) ...[
              _FailedBookingsSection(bookings: failedBookings),
              const SizedBox(height: AppDimensions.s24),
            ],
            if (bookings.isEmpty && failedBookings.isEmpty)
              _NoBookings(
                hasVehicles: dash.vehicles.isNotEmpty,
                onBookService: () =>
                    context.push(AppRoutes.customerBookService),
                onAddVehicle: () => context.push(AppRoutes.customerAddVehicle),
              )
            else if (sections.length == 2)
              AppSplitView(
                primaryFlex: context.adaptive.isMedium ? 1 : 3,
                secondaryFlex: context.adaptive.isMedium ? 1 : 2,
                spacing: AppDimensions.s24,
                primary: sections[0],
                secondary: sections[1],
              )
            else if (sections.isNotEmpty)
              sections.single,
          ],
        ),
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(customerBookingsProvider);
    await ref.read(customerDashboardProvider.notifier).refresh();
  }

  String _subtitle({
    required int active,
    required int inWorkshop,
    required int history,
  }) {
    final upcoming = active - inWorkshop;
    final parts = <String>[
      if (upcoming > 0) upcoming == 1 ? '1 upcoming' : '$upcoming upcoming',
      if (inWorkshop > 0)
        inWorkshop == 1 ? '1 in service' : '$inWorkshop in service',
      if (history > 0)
        history == 1 ? '1 past service' : '$history past services',
    ];
    if (parts.isEmpty) return 'Your appointments and service history.';
    return parts.join(' \u00b7 ');
  }
}

class _BookingsHeader extends StatelessWidget {
  final String subtitle;
  final VoidCallback? onBookService;

  const _BookingsHeader({required this.subtitle, this.onBookService});

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
                  'Bookings',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
            ),
            if (onBookService != null) ...[
              const SizedBox(width: AppDimensions.s8),
              TextButton.icon(
                onPressed: onBookService,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Book service'),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppDimensions.s4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// Section title with its real record count.
class _BookingsSectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _BookingsSectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.s10),
      child: Row(
        children: [
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.s8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.s8,
              vertical: AppDimensions.r2,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppDimensions.rPill),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Upcoming/current or history group inside one grouped surface.
class _BookingSection extends StatelessWidget {
  final String title;
  final int count;
  final List<CustomerBookingEntity> bookings;
  final CustomerServiceEntity? liveService;
  final String Function(double amount) formatAmount;
  final void Function(CustomerBookingEntity booking) onOpen;
  final VoidCallback onTrackService;
  final void Function(String estimateId) onReviewApproval;

  const _BookingSection({
    required this.title,
    required this.count,
    required this.bookings,
    required this.formatAmount,
    required this.onOpen,
    required this.onTrackService,
    required this.onReviewApproval,
    this.liveService,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BookingsSectionHeader(title: title, count: count),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            children: [
              for (var index = 0; index < bookings.length; index++) ...[
                CustomerBookingItem(
                  booking: bookings[index],
                  liveService: _liveServiceFor(bookings[index]),
                  formatAmount: formatAmount,
                  onOpen: () => onOpen(bookings[index]),
                  onTrackService: onTrackService,
                  onReviewApproval: onReviewApproval,
                ),
                if (index < bookings.length - 1)
                  Divider(height: 1, color: colors.outlineVariant),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Only the booking that owns the live job card carries live stage detail.
  CustomerServiceEntity? _liveServiceFor(CustomerBookingEntity booking) {
    final service = liveService;
    if (service == null) return null;
    final owner = CustomerServiceTracking.bookingForJobCard([
      booking,
    ], service.jobCardId);
    return owner == null ? null : service;
  }
}

class _NoBookings extends StatelessWidget {
  final bool hasVehicles;
  final VoidCallback onBookService;
  final VoidCallback onAddVehicle;

  const _NoBookings({
    required this.hasVehicles,
    required this.onBookService,
    required this.onAddVehicle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return CustomerSurfacePanel(
      accent: colors.onSurfaceVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusControl,
                  ),
                ),
                child: Icon(
                  Icons.calendar_month_outlined,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasVehicles ? 'No bookings yet' : 'No vehicle yet',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s4),
                    Text(
                      hasVehicles
                          ? "When you're ready, book a service for your "
                                'vehicle.'
                          : 'Bookings need a registered vehicle so the workshop '
                                'knows what to service.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s18),
          FilledButton.icon(
            onPressed: hasVehicles ? onBookService : onAddVehicle,
            icon: Icon(
              hasVehicles ? Icons.calendar_month_rounded : Icons.add_rounded,
              size: 18,
            ),
            label: Text(hasVehicles ? 'Book service' : 'Add your vehicle'),
          ),
        ],
      ),
    );
  }
}

/// The local bookings the workshop never received. Every recovery action
/// targets one stable failed operation, so more than one failed booking is
/// supported and each is handled on its own.
class _FailedBookingsSection extends ConsumerStatefulWidget {
  final List<FailedBooking> bookings;

  const _FailedBookingsSection({required this.bookings});

  @override
  ConsumerState<_FailedBookingsSection> createState() =>
      _FailedBookingsSectionState();
}

class _FailedBookingsSectionState
    extends ConsumerState<_FailedBookingsSection> {
  /// Operation ids with a recovery action in flight, so a second tap cannot
  /// replay the same failed booking twice.
  final Set<String> _busy = {};

  Future<void> _retry(FailedBooking booking) async {
    final id = booking.operationId;
    if (_busy.contains(id)) return;
    setState(() => _busy.add(id));

    final accepted = await ref.read(failedBookingSyncProvider).retry(id);
    if (!mounted) return;

    // The terminal state is read from the failed operation, so a successful
    // replay clears it whether or not the follow-up refresh succeeds. A failed
    // refresh must never bring "Not sent" back — the workshop has the booking.
    ref.invalidate(customerFailedBookingsProvider);
    ref.invalidate(customerBookingsProvider);
    await ref.read(customerDashboardProvider.notifier).refresh();
    if (!mounted) return;

    setState(() => _busy.remove(id));
    if (!accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("We couldn't send this booking. Please try again."),
        ),
      );
    }
  }

  Future<void> _remove(FailedBooking booking) async {
    final id = booking.operationId;
    if (_busy.contains(id)) return;

    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Remove saved booking?',
      message:
          'This removes the booking stored on this device. The workshop has '
          'not received it.',
      confirmLabel: 'Remove booking',
      cancelLabel: 'Keep booking',
      icon: Icons.delete_outline_rounded,
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _busy.add(id));
    await ref.read(failedBookingSyncProvider).remove(id);
    if (!mounted) return;
    ref.invalidate(customerFailedBookingsProvider);
    ref.invalidate(customerBookingsProvider);
    setState(() => _busy.remove(id));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BookingsSectionHeader(
          title: 'Needs attention',
          count: widget.bookings.length,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            children: [
              for (var index = 0; index < widget.bookings.length; index++) ...[
                CustomerFailedBookingItem(
                  booking: widget.bookings[index],
                  busy: _busy.contains(widget.bookings[index].operationId),
                  onRetry: () => _retry(widget.bookings[index]),
                  onRemove: () => _remove(widget.bookings[index]),
                ),
                if (index < widget.bookings.length - 1)
                  Divider(height: 1, color: colors.outlineVariant),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
