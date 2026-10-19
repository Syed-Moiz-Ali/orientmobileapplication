import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/presentation/support/customer_destination.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';
import 'package:customer_app/features/customer/presentation/support/customer_service_tracking.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_garage_carousel.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_header.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_quick_actions.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_service_summary.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_status_notices.dart';

/// Customer Home — an Airbnb-grade garage feed answering four questions in
/// the first viewport: who am I, which car needs me, what is happening with
/// it, and how do I book.
///
/// Everything on this screen is backed by real state: the hero carousel
/// shows registered vehicles with illustrative silhouette art (the API
/// carries no photography) and each card's real booking-derived context —
/// never a health score (no provenance), never a favorite (no contract),
/// never a promotion (no endpoint). There is exactly one Book service
/// emphasis; Home stays a feed while Service Status carries tracking detail.
class CustomerHomeTab extends ConsumerWidget {
  const CustomerHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.cx;
    final state = ref.watch(customerDashboardProvider);
    final notifier = ref.read(customerDashboardProvider.notifier);
    final bookings =
        ref.watch(customerBookingsProvider).value ??
        const <CustomerBookingEntity>[];
    final approvals =
        ref.watch(customerApprovalsProvider).value ??
        const <CustomerApprovalSummaryResponse>[];

    final hasAnyData =
        state.profile != null ||
        state.vehicles.isNotEmpty ||
        state.notifications.isNotEmpty ||
        state.activeService != null ||
        bookings.isNotEmpty;

    // First load only — a user-initiated refresh must never blank the screen.
    if (state.isLoading && !hasAnyData) {
      // Phase 07.1: bespoke skeleton migrated to AppSkeleton primitives.
      return AppResponsivePage(
        maxContentWidth: 1080,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeleton.text(width: 96, height: 12),
                      SizedBox(height: AppDimensions.s8),
                      AppSkeleton.text(width: 150, height: 26),
                    ],
                  ),
                ),
                AppSkeleton.circle(size: 42),
              ],
            ),
            const SizedBox(height: AppDimensions.s20),
            AppSplitView(
              primaryFlex: context.adaptive.isMedium ? 1 : 3,
              secondaryFlex: context.adaptive.isMedium ? 1 : 2,
              spacing: AppDimensions.s24,
              primary: const AppSkeleton.card(height: 190),
              secondary: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < 3; i++) ...[
                          if (i > 0)
                            const SizedBox(width: AppDimensions.s10),
                          const Expanded(
                            child: AppSkeleton.card(height: 92),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.s24),
                  const AppSkeleton.text(width: 120, height: 18),
                  const SizedBox(height: AppDimensions.s12),
                  const AppSkeleton.card(height: 128),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (state.loadError.isNotEmpty && !hasAnyData) {
      return AppResponsivePage(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.s48),
          child: EmptyState(
            icon: Icons.sync_problem_rounded,
            title: t.garLoadTitle,
            message: t.garLoadBody,
            actionLabel: t.garRetry,
            onAction: notifier.refresh,
          ),
        ),
      );
    }

    final vehicles = state.vehicles;
    final activeService =
        CustomerServiceTracking.isLiveService(state.activeService)
        ? state.activeService
        : null;
    final activeBooking = CustomerServiceTracking.activeBooking(bookings);
    final recentActivity = _recentActivity(bookings);
    final isNewCustomer =
        vehicles.isEmpty && bookings.isEmpty && activeService == null;
    final hasAttention = approvals.isNotEmpty || state.unpaidInvoices > 0;

    void bookVehicle(CustomerVehicleEntity vehicle) => context.push(
          AppRoutes.customerBookServiceLocation(vehicleId: vehicle.id),
        );

    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );

    final journey = CustomerHomeServiceSummary(
      activeService: activeService,
      activeBooking: activeBooking,
      vehicleCount: vehicles.length,
      // Service Status is contextual: it is a pushed page, not a tab.
      onTrackService: () => context.push(AppRoutes.customerServiceStatus),
      onViewBooking: () {
        final booking = activeBooking;
        if (booking != null) {
          context.push(
            AppRoutes.customerBookingDetail,
            extra: booking,
          );
        }
      },
      onAddVehicle: () => context.push(AppRoutes.customerAddVehicle),
    );
    final actions = CustomerHomeQuickActions(
      hasVehicles: vehicles.isNotEmpty,
      onBookService: () => context.push(AppRoutes.customerBookService),
      onBreakdownHelp: () => context.push(AppRoutes.customerBreakdownHelp),
      onInvoices: () => context.push(AppRoutes.approvalsLocation()),
      onHistory: () =>
          notifier.selectDestination(CustomerDestination.bookings),
    );

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      color: Theme.of(context).colorScheme.primary,
      child: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        maxContentWidth: 1080,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.loadError.isNotEmpty) ...[
              CustomerRefreshNotice(onRetry: notifier.refresh),
              const SizedBox(height: AppDimensions.s16),
            ],
            CustomerHomeHeader(
              firstName: state.profile?.firstName ?? '',
              isNewCustomer: isNewCustomer,
            ),
            const SizedBox(height: AppDimensions.s20),
            if (hasAttention) ...[
              CustomerAttentionPanel(
                approvals: approvals,
                unpaidInvoices: state.unpaidInvoices,
                formatAmount: state.formatAmount,
                // Approvals is contextual: each decision opens its own estimate,
                // and the approvals page is where invoices live.
                onReviewEstimate: (estimateId) => context.push(
                  AppRoutes.approvalsLocation(estimateId: estimateId),
                ),
                onViewInvoices: () =>
                    context.push(AppRoutes.approvalsLocation()),
              ),
              const SizedBox(height: AppDimensions.s20),
            ],
            if (vehicles.isNotEmpty) ...[
              SectionHeader(
                title: vehicles.length == 1
                    ? t.garTitleOne
                    : t.garTitleMany,
                action: t.garManage,
                onAction: () => notifier.selectDestination(
                  CustomerDestination.vehicles,
                ),
              ),
              const SizedBox(height: AppDimensions.s12),
              CustomerGarageCarousel(
                vehicles: vehicles,
                bookings: bookings,
                liveService: activeService,
                onBookVehicle: bookVehicle,
                onOpenBooking: (booking) => context.push(
                  AppRoutes.customerBookingDetail,
                  extra: booking,
                ),
                onTrackService: () =>
                    context.push(AppRoutes.customerServiceStatus),
              ),
              const SizedBox(height: AppDimensions.s28),
            ],
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: journey),
                  const SizedBox(width: AppDimensions.s24),
                  Expanded(child: actions),
                ],
              )
            else ...[
              journey,
              const SizedBox(height: AppDimensions.s28),
              actions,
            ],
            if (recentActivity.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.s28),
              _RecentActivitySection(
                bookings: recentActivity,
                onViewAll: () => notifier.selectDestination(
                  CustomerDestination.bookings,
                ),
                onTap: (booking) => context.push(
                  AppRoutes.customerBookingDetail,
                  extra: booking,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Most recent finished work, used for a compact activity summary. Provider
/// order is preserved instead of parsing backend date strings.
List<CustomerBookingEntity> _recentActivity(
  List<CustomerBookingEntity> bookings,
) {
  final recent = <CustomerBookingEntity>[];
  for (final booking in bookings) {
    if (CustomerServiceTracking.liveBookingStatuses.contains(booking.status)) {
      continue;
    }
    recent.add(booking);
    if (recent.length == 2) break;
  }
  return recent;
}

class _RecentActivitySection extends StatelessWidget {
  final List<CustomerBookingEntity> bookings;
  final VoidCallback onViewAll;
  final void Function(CustomerBookingEntity booking) onTap;

  const _RecentActivitySection({
    required this.bookings,
    required this.onViewAll,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: t.garRecentTitle,
          action: t.garRecentAll,
          onAction: onViewAll,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius:
                BorderRadius.circular(AppDimensions.radiusPanel),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            children: [
              for (var index = 0; index < bookings.length; index++) ...[
                _ActivityRow(
                  booking: bookings[index],
                  onTap: () => onTap(bookings[index]),
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
}

class _ActivityRow extends StatelessWidget {
  final CustomerBookingEntity booking;
  final VoidCallback onTap;

  const _ActivityRow({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final service = booking.service.trim();
    final vehicle = booking.vehicleName.trim();
    final date = booking.date.trim();
    final meta = [
      if (vehicle.isNotEmpty) vehicle,
      if (date.isNotEmpty) date,
    ].join(' \u00b7 ');
    final title =
        service.isEmpty ? context.cx.bkServiceAppt : service;
    final tone = CustomerServiceTracking.bookingTone(colors, booking.status);

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: [title, if (meta.isNotEmpty) meta, booking.statusLabel].join(', '),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.s14),
          child: Row(
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
                  Icons.receipt_long_rounded,
                  size: AppDimensions.iconMd,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s6),
                    Row(
                      children: [
                        StatusPill(
                          label: booking.statusLabel,
                          bg: tone.withValues(alpha: 0.12),
                          fg: tone,
                        ),
                        if (meta.isNotEmpty) ...[
                          const SizedBox(width: AppDimensions.s8),
                          Expanded(
                            child: Text(
                              meta,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.s8),
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


