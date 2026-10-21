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
import 'package:customer_app/features/customer/presentation/widgets/customer_home_garage.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_header.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_hero.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_quick_actions.dart';

/// Customer Home — an Airbnb-grade garage feed answering four questions in
/// the first viewport: who am I, which car needs me, what is happening with
/// it, and how do I book.
///
/// Composition (C9 dashboard + C16 collections): greeting header -> ONE hero
/// card (approval > payment due > in-service > upcoming > idle) -> one row of
/// quick-action tiles -> garage carousel (~2.2 peek, "Show all" into the
/// vehicles tab) -> recent activity as an inset list group. Everything on
/// this screen is backed by real state: the hero shows the first attention
/// item with a "+N more" row into approvals, garage cards show registered
/// vehicles with illustrative silhouette art (the API carries no photography)
/// and each card's real booking-derived context — never a health score (no
/// provenance), never a favorite (no contract), never a promotion (no
/// endpoint). There is exactly one Book service emphasis; Home stays a feed
/// while Service Status carries tracking detail.
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
      return const AppResponsivePage(
        maxContentWidth: 1080,
        child: _HomeLoadingSkeleton(),
      );
    }

    if (state.loadError.isNotEmpty && !hasAnyData) {
      return AppResponsivePage(
        maxContentWidth: 1080,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xxxl,
          ),
          child: AppErrorState(
            title: t.garLoadTitle,
            message: t.garLoadBody,
            retryLabel: t.garRetry,
            onRetry: notifier.refresh,
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

    void bookVehicle(CustomerVehicleEntity vehicle) => context.push(
      AppRoutes.customerBookServiceLocation(vehicleId: vehicle.id),
    );

    final wide = context.adaptive.pick(
      compact: false,
      // C4/C9 medium (600-1024, e.g. 768 portrait): two-column dashboard —
      // hero + quick actions side by side, same as expanded.
      medium: true,
      expanded: true,
      large: true,
    );

    final Widget heroSlot = isNewCustomer
        ? AppEmptyState(
            icon: Icons.directions_car_filled_rounded,
            title: t.garHeroEmpty,
            message: t.garHeroEmptyBody,
            actionLabel: t.garHeroAdd,
            onAction: () => context.push(AppRoutes.customerAddVehicle),
          )
        : CustomerHomeHero(
            approvals: approvals,
            unpaidInvoices: state.unpaidInvoices,
            formatAmount: state.formatAmount,
            activeService: activeService,
            activeBooking: activeBooking,
            vehicleCount: vehicles.length,
            // Approvals is contextual: each decision opens its own estimate,
            // and the approvals page is where invoices live.
            onReviewEstimate: (estimateId) => context.push(
              AppRoutes.approvalsLocation(estimateId: estimateId),
            ),
            onViewInvoices: () =>
                context.push(AppRoutes.approvalsLocation()),
            onViewAllAttention: () =>
                context.push(AppRoutes.approvalsLocation()),
            onTrackService: () =>
                context.push(AppRoutes.customerServiceStatus),
            onViewBooking: () {
              final booking = activeBooking;
              if (booking != null) {
                context.push(
                  AppRoutes.customerBookingDetail,
                  extra: booking,
                );
              }
            },
            onBookService: () =>
                context.push(AppRoutes.customerBookService),
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
              AppBanner(
                kind: AppBannerKind.warning,
                message: state.loadError,
                actionLabel: t.garRetry,
                onAction: notifier.refresh,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            CustomerHomeHeader(
              firstName: state.profile?.firstName ?? '',
              isNewCustomer: isNewCustomer,
            ),
            const SizedBox(height: AppSpacing.screenPaddingPhone),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: heroSlot),
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(child: actions),
                ],
              )
            else ...[
              heroSlot,
              const SizedBox(height: AppSpacing.xl),
              actions,
            ],
            if (vehicles.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              CustomerHomeGarage(
                vehicles: vehicles,
                bookings: bookings,
                liveService: activeService,
                onBookVehicle: bookVehicle,
                onSeeAll: () => notifier.selectDestination(
                  CustomerDestination.vehicles,
                ),
                onOpenBooking: (booking) => context.push(
                  AppRoutes.customerBookingDetail,
                  extra: booking,
                ),
                onTrackService: () =>
                    context.push(AppRoutes.customerServiceStatus),
              ),
            ],
            if (recentActivity.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
            AppSection(
              title: t.garRecentTitle,
              seeAllLabel: t.garRecentAll,
              onSeeAll: () => notifier.selectDestination(
                CustomerDestination.bookings,
              ),
              child: AppListGroup(
                items: [
                  for (final booking in recentActivity)
                    AppListGroupItem(
                      leadingIcon: Icons.receipt_long_rounded,
                      title: booking.service.trim().isEmpty
                          ? t.bkServiceAppt
                          : booking.service.trim(),
                      subtitle: _activityMeta(booking),
                      // Locale-aware status (same English copy as before).
                      valueText: AppStatusLabels.of(
                        context,
                      ).booking(booking.status.name),
                      onTap: () {
                          HapticFeedback.selectionClick();
                          context.push(
                            AppRoutes.customerBookingDetail,
                            extra: booking,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Skeleton mirroring the final home layout: header, hero card, garage peek,
/// quick-action tiles, then activity rows — no full-screen spinner.
class _HomeLoadingSkeleton extends StatelessWidget {
  const _HomeLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: const [
            Expanded(
              child: AppShimmerSkeleton.textBlock(lines: 2, lineHeight: 14),
            ),
            SizedBox(width: AppSpacing.lg),
            AppShimmerSkeleton.circle(size: 42),
          ],
        ),
        const SizedBox(height: AppSpacing.screenPaddingPhone),
        const AppShimmerSkeleton.card(height: 190),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: const [
            Expanded(child: AppShimmerSkeleton.card(height: 120)),
            SizedBox(width: AppSpacing.md),
            Expanded(child: AppShimmerSkeleton.card(height: 120)),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: const [
            Expanded(child: AppShimmerSkeleton.card(height: 88)),
            SizedBox(width: AppSpacing.md),
            Expanded(child: AppShimmerSkeleton.card(height: 88)),
            SizedBox(width: AppSpacing.md),
            Expanded(child: AppShimmerSkeleton.card(height: 88)),
            SizedBox(width: AppSpacing.md),
            Expanded(child: AppShimmerSkeleton.card(height: 88)),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const AppShimmerSkeleton.listRows(rows: 3),
      ],
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
    if (recent.length == 3) break;
  }
  return recent;
}

String _activityMeta(CustomerBookingEntity booking) {
  final vehicle = booking.vehicleName.trim();
  final date = booking.date.trim();
  final meta = [
    if (vehicle.isNotEmpty) vehicle,
    if (date.isNotEmpty) date,
  ].join(' \u00b7 ');
  return meta;
}
