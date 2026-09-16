import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_destination.dart';
import 'package:customer_app/features/customer/presentation/support/customer_service_tracking.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_service_journey.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_status_details.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_status_notices.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_status_service_panel.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_status_skeleton.dart';

/// Customer Status â€” a focused operational tracking screen, not a second
/// dashboard.
///
/// It answers "what is happening with my vehicle right now?" using only real
/// state: the active workshop job from `/customers/services/active` (including
/// its real stage list), the bookings feed, and real approval/invoice data.
/// Nothing is synthesised â€” no invented stages, progress or ETAs.
class CustomerServiceStatusTab extends ConsumerStatefulWidget {
  /// Whether the screen renders its own "Service status" heading.
  ///
  /// The contextual [CustomerServiceStatusPage] supplies the title through its
  /// top bar instead, so the heading is suppressed there to avoid repeating it.
  final bool showTitle;

  const CustomerServiceStatusTab({super.key, this.showTitle = true});

  @override
  ConsumerState<CustomerServiceStatusTab> createState() =>
      _CustomerServiceStatusTabState();
}

class _CustomerServiceStatusTabState
    extends ConsumerState<CustomerServiceStatusTab> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Retained from the existing architecture: a genuinely live workshop job
    // is refreshed once a minute while this tab is actually visible.
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (!mounted || !TickerMode.of(context)) return;
      final dash = ref.read(customerDashboardProvider);
      if (!CustomerServiceTracking.isLiveService(dash.activeService)) return;
      ref.read(customerDashboardProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dash = ref.watch(customerDashboardProvider);
    final notifier = ref.read(customerDashboardProvider.notifier);
    final bookings =
        ref.watch(customerBookingsProvider).value ??
        const <CustomerBookingEntity>[];
    final approvals =
        ref.watch(customerApprovalsProvider).value ??
        const <CustomerApprovalSummaryResponse>[];
    final invoices =
        ref.watch(customerInvoicesProvider).value ?? const <InvoiceResponse>[];

    final hasAnyData =
        dash.profile != null ||
        dash.vehicles.isNotEmpty ||
        dash.notifications.isNotEmpty ||
        dash.activeService != null ||
        bookings.isNotEmpty;

    if (dash.isLoading && !hasAnyData) {
      return const CustomerStatusSkeleton();
    }

    if (dash.loadError.isNotEmpty && !hasAnyData) {
      return AppResponsivePage(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.s48),
          child: EmptyState(
            icon: Icons.sync_problem_rounded,
            title: "We couldn't load your service status",
            message: 'Please try again in a moment.',
            actionLabel: 'Retry',
            onAction: notifier.refresh,
          ),
        ),
      );
    }

    final liveService =
        CustomerServiceTracking.isLiveService(dash.activeService)
        ? dash.activeService
        : null;
    final activeBooking = CustomerServiceTracking.activeBooking(bookings);
    final otherLive = CustomerServiceTracking.otherLiveBookings(
      bookings,
      activeBooking,
    );
    final unpaid = CustomerServiceTracking.unpaidInvoices(invoices);
    final trackingBooking = liveService == null
        ? null
        : CustomerServiceTracking.bookingForJobCard(
            bookings,
            liveService.jobCardId,
          );
    final hasAttention = approvals.isNotEmpty || unpaid.isNotEmpty;

    final subtitle = liveService != null
        ? 'Your vehicle is in the workshop right now.'
        : activeBooking != null
        ? 'Your appointment is booked.'
        : 'Nothing is booked or in progress.';

    final detailRows = _detailRows(
      liveService: liveService,
      activeBooking: activeBooking,
    );

    final primary = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasAttention) ...[
          CustomerAttentionPanel(
            title: 'Action required',
            approvals: approvals,
            unpaidInvoices: unpaid.length,
            formatAmount: dash.formatAmount,
            onReviewEstimate: (estimateId) =>
                _openApproval(estimateId, approvals.length),
            onViewInvoices: () => context.push(AppRoutes.approvalsLocation()),
          ),
          const SizedBox(height: AppDimensions.s20),
        ],
        if (liveService != null)
          CustomerStatusLivePanel(
            service: liveService,
            onViewBooking: trackingBooking == null
                ? null
                : () => context.push(
                    AppRoutes.customerBookingDetail,
                    extra: trackingBooking,
                  ),
          )
        else if (activeBooking != null)
          CustomerStatusUpcomingPanel(
            booking: activeBooking,
            onViewBooking: () => context.push(
              AppRoutes.customerBookingDetail,
              extra: activeBooking,
            ),
          )
        else
          CustomerStatusIdlePanel(
            hasVehicles: dash.vehicles.isNotEmpty,
            showBookingsLink: bookings.isNotEmpty,
            onBookService: () => context.push(AppRoutes.customerBookService),
            onViewBookings: () =>
                notifier.selectDestination(CustomerDestination.bookings),
            onAddVehicle: () => context.push(AppRoutes.customerAddVehicle),
          ),
      ],
    );

    final secondary = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (liveService != null && liveService.stages.isNotEmpty) ...[
          CustomerServiceJourney(stages: liveService.stages),
          const SizedBox(height: AppDimensions.s24),
        ],
        if (detailRows.isNotEmpty) ...[
          CustomerStatusDetails(rows: detailRows),
          const SizedBox(height: AppDimensions.s24),
        ],
        if (otherLive.isNotEmpty)
          _OtherBookingsRow(
            count: otherLive.length,
            onTap: () =>
                notifier.selectDestination(CustomerDestination.bookings),
          ),
      ],
    );

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      color: colors.primary,
      child: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        maxContentWidth: 1080,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (dash.loadError.isNotEmpty) ...[
              CustomerRefreshNotice(onRetry: notifier.refresh),
              const SizedBox(height: AppDimensions.s16),
            ],
            if (widget.showTitle) ...[
              Semantics(
                header: true,
                child: Text(
                  'Service status',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.s4),
            ],
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppDimensions.s20),
            AppSplitView(
              primaryFlex: context.adaptive.isMedium ? 1 : 3,
              secondaryFlex: context.adaptive.isMedium ? 1 : 2,
              spacing: AppDimensions.s24,
              primary: primary,
              secondary: secondary,
            ),
          ],
        ),
      ),
    );
  }

  /// Routes into the contextual Approvals page. A single pending estimate opens
  /// straight into its own decision; several open the overview.
  void _openApproval(String estimateId, int approvalCount) {
    final target = approvalCount == 1 ? estimateId.trim() : '';
    context.push(AppRoutes.approvalsLocation(estimateId: target));
  }

  List<CustomerStatusDetail> _detailRows({
    CustomerServiceEntity? liveService,
    CustomerBookingEntity? activeBooking,
  }) {
    final rows = <CustomerStatusDetail>[];
    final service = liveService;

    if (service != null) {
      if (service.jobCardId.trim().isNotEmpty) {
        rows.add(
          CustomerStatusDetail(
            icon: Icons.confirmation_number_outlined,
            label: 'Job reference',
            value: service.jobCardId.trim(),
          ),
        );
      }
      if (service.started.trim().isNotEmpty) {
        rows.add(
          CustomerStatusDetail(
            icon: Icons.play_circle_outline_rounded,
            label: 'Started',
            value: service.started.trim(),
          ),
        );
      }
      if (service.technicianName.trim().isNotEmpty) {
        rows.add(
          CustomerStatusDetail(
            icon: Icons.person_outline_rounded,
            label: 'Technician',
            value: service.technicianName.trim(),
          ),
        );
      }
      return rows;
    }

    final booking = activeBooking;
    if (booking != null && booking.jobCardRef.trim().isNotEmpty) {
      rows.add(
        CustomerStatusDetail(
          icon: Icons.confirmation_number_outlined,
          label: 'Booking reference',
          value: booking.jobCardRef.trim(),
        ),
      );
    }
    return rows;
  }
}

class _OtherBookingsRow extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _OtherBookingsRow({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final label = count == 1
        ? '1 more upcoming booking'
        : '$count more upcoming bookings';

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s14,
            vertical: AppDimensions.s12,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: AppDimensions.iconMd,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: AppDimensions.iconMd,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
