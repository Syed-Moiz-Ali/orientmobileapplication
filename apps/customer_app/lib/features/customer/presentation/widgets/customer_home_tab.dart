import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_garage_summary.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_header.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_quick_actions.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_service_summary.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_skeleton.dart';

/// Customer Home — answers four questions in the first viewport:
/// what is happening with my vehicle, do I need to act, how do I book, and
/// what do I own.
///
/// Everything on this screen is backed by real state. There is deliberately no
/// promotional content, no stock photography and only one Book service entry
/// point.
class CustomerHomeTab extends ConsumerWidget {
  const CustomerHomeTab({super.key});

  /// Index of the Status tab in the shared Customer navigation.
  static const int _statusTab = 1;
  static const int _bookingsTab = 2;
  static const int _approvalsTab = 3;
  static const int _vehiclesTab = 4;

  /// Booking states that still represent work the customer must be aware of.
  static const Set<BookingStatus> _liveStatuses = {
    BookingStatus.pending,
    BookingStatus.confirmed,
    BookingStatus.approvalRequired,
    BookingStatus.vehicleReceived,
    BookingStatus.approved,
    BookingStatus.workAssigned,
    BookingStatus.inProgress,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      return const CustomerHomeSkeleton();
    }

    if (state.loadError.isNotEmpty && !hasAnyData) {
      return AppResponsivePage(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.s48),
          child: EmptyState(
            icon: Icons.sync_problem_rounded,
            title: "We couldn't load your information",
            message: 'Please try again in a moment.',
            actionLabel: 'Retry',
            onAction: notifier.refresh,
          ),
        ),
      );
    }

    final vehicles = state.vehicles;
    final activeService = state.activeService?.hasActiveJob == true
        ? state.activeService
        : null;
    final activeBooking = _activeBooking(bookings);
    final recentActivity = _recentActivity(bookings);
    final isNewCustomer =
        vehicles.isEmpty && bookings.isEmpty && activeService == null;
    final hasAttention = approvals.isNotEmpty || state.unpaidInvoices > 0;

    final primary = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasAttention) ...[
          _AttentionPanel(
            approvals: approvals,
            unpaidInvoices: state.unpaidInvoices,
            formatAmount: state.formatAmount,
            onReview: () => notifier.selectTab(_approvalsTab),
          ),
          const SizedBox(height: AppDimensions.s20),
        ],
        CustomerHomeServiceSummary(
          activeService: activeService,
          activeBooking: activeBooking,
          vehicleCount: vehicles.length,
          onTrackService: () => notifier.selectTab(_statusTab),
          onViewBooking: () {
            final booking = activeBooking;
            if (booking != null) {
              context.push(AppRoutes.customerBookingDetail, extra: booking);
            }
          },
          onAddVehicle: () => context.push(AppRoutes.customerAddVehicle),
        ),
      ],
    );

    final secondary = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomerHomeQuickActions(
          hasVehicles: vehicles.isNotEmpty,
          onBookService: () => context.push(AppRoutes.customerBookService),
          onMyVehicles: () => notifier.selectTab(_vehiclesTab),
          onBreakdownHelp: () => context.push(AppRoutes.customerBreakdownHelp),
        ),
        if (vehicles.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.s24),
          CustomerHomeGarageSummary(
            vehicles: vehicles,
            onManageVehicles: () => notifier.selectTab(_vehiclesTab),
          ),
        ],
        if (recentActivity.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.s24),
          _RecentActivitySection(
            bookings: recentActivity,
            onViewAll: () => notifier.selectTab(_bookingsTab),
            onTap: (booking) =>
                context.push(AppRoutes.customerBookingDetail, extra: booking),
          ),
        ],
      ],
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
              _RefreshFailureNotice(onRetry: notifier.refresh),
              const SizedBox(height: AppDimensions.s16),
            ],
            CustomerHomeHeader(
              firstName: state.profile?.firstName ?? '',
              isNewCustomer: isNewCustomer,
              unreadCount: state.unreadCount,
              onNotifications: () =>
                  context.push(AppRoutes.customerNotifications),
            ),
            const SizedBox(height: AppDimensions.s20),
            AppSplitView(
              // Tablets get a balanced split; wider desktops give the service
              // summary the extra room it needs.
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
}

CustomerBookingEntity? _activeBooking(List<CustomerBookingEntity> bookings) {
  for (final booking in bookings) {
    if (CustomerHomeTab._liveStatuses.contains(booking.status)) {
      return booking;
    }
  }
  return null;
}

/// Most recent finished work, used for a compact activity summary. Provider
/// order is preserved instead of parsing backend date strings.
List<CustomerBookingEntity> _recentActivity(
  List<CustomerBookingEntity> bookings,
) {
  final recent = <CustomerBookingEntity>[];
  for (final booking in bookings) {
    if (CustomerHomeTab._liveStatuses.contains(booking.status)) continue;
    recent.add(booking);
    if (recent.length == 2) break;
  }
  return recent;
}

/// Real, action-required states only. Renders nothing when the customer has
/// nothing to decide or pay.
class _AttentionPanel extends StatelessWidget {
  final List<CustomerApprovalSummaryResponse> approvals;
  final int unpaidInvoices;
  final String Function(double amount) formatAmount;
  final VoidCallback onReview;

  const _AttentionPanel({
    required this.approvals,
    required this.unpaidInvoices,
    required this.formatAmount,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final rows = <Widget>[];

    if (approvals.isNotEmpty) {
      final single = approvals.length == 1;
      final amount = approvals.first.amount;
      rows.add(
        _AttentionRow(
          icon: Icons.fact_check_rounded,
          message: single
              ? (amount > 0
                    ? 'Estimate ${formatAmount(amount)} awaiting your approval'
                    : 'An estimate is awaiting your approval')
              : '${approvals.length} estimates awaiting your approval',
          onTap: onReview,
        ),
      );
    }

    if (unpaidInvoices > 0) {
      rows.add(
        _AttentionRow(
          icon: Icons.receipt_long_rounded,
          message: unpaidInvoices == 1
              ? '1 unpaid invoice'
              : '$unpaidInvoices unpaid invoices',
          onTap: onReview,
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.s14),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          colors.error.withValues(alpha: 0.06),
          colors.surface,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.error.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline_rounded, size: 16, color: colors.error),
              const SizedBox(width: AppDimensions.s6),
              Text(
                'Needs your attention',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.error,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s6),
          for (var index = 0; index < rows.length; index++) ...[
            if (index > 0) const SizedBox(height: AppDimensions.s4),
            rows[index],
          ],
        ],
      ),
    );
  }
}

class _AttentionRow extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback onTap;

  const _AttentionRow({
    required this.icon,
    required this.message,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: message,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s4,
            vertical: AppDimensions.s10,
          ),
          child: Row(
            children: [
              Icon(icon, size: AppDimensions.iconMd, color: colors.error),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
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
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Recent activity',
          action: 'All bookings',
          onAction: onViewAll,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
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
    final title = service.isEmpty ? 'Workshop visit' : service;

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: [title, if (meta.isNotEmpty) meta, booking.statusLabel].join(', '),
      child: InkWell(
        onTap: onTap,
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
                        _StatusChip(
                          label: booking.statusLabel,
                          status: booking.status,
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

class _StatusChip extends StatelessWidget {
  final String label;
  final BookingStatus status;

  const _StatusChip({required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tint = switch (status) {
      BookingStatus.completed || BookingStatus.delivered => colors.tertiary,
      BookingStatus.cancelled => colors.onSurfaceVariant,
      BookingStatus.approvalRequired => colors.error,
      _ => colors.primary,
    };

    return StatusPill(label: label, bg: tint.withValues(alpha: 0.12), fg: tint);
  }
}

class _RefreshFailureNotice extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _RefreshFailureNotice({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.s12,
        AppDimensions.s8,
        AppDimensions.s8,
        AppDimensions.s8,
      ),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          colors.error.withValues(alpha: 0.06),
          colors.surface,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.error.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: colors.error),
          const SizedBox(width: AppDimensions.s10),
          Expanded(
            child: Text(
              "We couldn't refresh your information.",
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
