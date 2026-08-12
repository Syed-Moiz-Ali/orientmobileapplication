import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

class CustomerBookingsTab extends ConsumerStatefulWidget {
  const CustomerBookingsTab({super.key});

  @override
  ConsumerState<CustomerBookingsTab> createState() =>
      _CustomerBookingsTabState();
}

class _CustomerBookingsTabState extends ConsumerState<CustomerBookingsTab> {
  BookingStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dash = ref.watch(customerDashboardProvider);
    final bookingsAsync = ref.watch(customerBookingsProvider);
    final bookings =
        bookingsAsync.valueOrNull ?? const <CustomerBookingEntity>[];
    final filtered = _filter == null
        ? bookings
        : bookings.where((booking) => booking.status == _filter).toList();

    final scheduledCount = bookings
        .where(
          (b) =>
              b.status == BookingStatus.confirmed ||
              b.status == BookingStatus.pending,
        )
        .length;
    final completedCount = bookings
        .where((b) => b.status == BookingStatus.completed)
        .length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.customerBookService),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.rPill),
        ),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'Book Appointment',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(customerBookingsProvider),
          color: AppColors.primary,
          child: AppResponsivePage(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. PAGE HEADER
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppDimensions.s12,
                    bottom: AppDimensions.s8,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Appointments & Slots 📅',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.headlineLarge?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w900,
                                fontSize: 26,
                                letterSpacing: -0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Schedule new appointments or manage upcoming visits',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.text3,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.s12),
                      GestureDetector(
                        onTap: () =>
                            context.push(AppRoutes.customerNotifications),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Icon(
                                Icons.notifications_outlined,
                                color: AppColors.textPrimary,
                                size: 22,
                              ),
                            ),
                            if (dash.unreadCount > 0)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.danger,
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.rPill,
                                    ),
                                    border: Border.all(
                                      color: AppColors.bg,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    dash.unreadCount > 99
                                        ? '99+'
                                        : '${dash.unreadCount}',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.s16),

                // 2. LIVE EXPRESS SLOT TICKER BANNER
                _LiveSlotTickerBanner(
                  onBook: () => context.push(AppRoutes.customerBookService),
                ),
                const SizedBox(height: AppDimensions.s16),

                // 3. BOOKINGS QUICK STATS DECK
                _BookingsStatsDeck(
                  scheduledCount: scheduledCount,
                  completedCount: completedCount,
                ),
                const SizedBox(height: AppDimensions.s24),

                // 4. POPULAR PACKAGES PROMO CAROUSEL
                _ExplanatorySectionHeader(
                  title: 'Popular Service Packages',
                  subtitle: 'Tap to instantly reserve a package slot',
                ),
                const SizedBox(height: AppDimensions.s10),
                _FeaturedPackagesCarousel(
                  onSelect: (pkg) =>
                      context.push(AppRoutes.customerBookService),
                ),
                const SizedBox(height: AppDimensions.s24),

                // 5. EXPLANATORY FILTER BAR & APPOINTMENT LIST
                _ExplanatorySectionHeader(
                  title: 'Your Appointments (${filtered.length})',
                  subtitle:
                      'Filter by status or tap any booking to view details',
                ),
                const SizedBox(height: AppDimensions.s10),
                _BookingFilterPills(
                  selected: _filter,
                  onChanged: (status) => setState(() => _filter = status),
                ),
                const SizedBox(height: AppDimensions.s16),

                if (bookingsAsync.isLoading && bookings.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppDimensions.s32),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (bookingsAsync.hasError && bookings.isEmpty)
                  EmptyState(
                    title: 'Could not load bookings',
                    message: 'Check your connection and try again.',
                    icon: Icons.wifi_off_rounded,
                    actionLabel: 'Retry Sync',
                    onAction: () => ref.invalidate(customerBookingsProvider),
                  )
                else if (filtered.isEmpty)
                  EmptyState(
                    title: _filter == null
                        ? 'No Bookings Scheduled'
                        : 'No Matching Appointments',
                    message: _filter == null
                        ? 'You have no active or past service appointments. Tap below to reserve your slot.'
                        : 'Try selecting another status filter above or book a new appointment.',
                    icon: Icons.calendar_month_outlined,
                    actionLabel: '+ Reserve Appointment Slot',
                    onAction: () => context.push(AppRoutes.customerBookService),
                  )
                else
                  _BookingsList(bookings: filtered),
                const SizedBox(height: AppDimensions.s32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// LIVE EXPRESS SLOT TICKER BANNER (Pill style)
class _LiveSlotTickerBanner extends StatelessWidget {
  final VoidCallback onBook;

  const _LiveSlotTickerBanner({required this.onBook});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.primaryBg,
      borderRadius: BorderRadius.circular(AppDimensions.rPill),
      child: InkWell(
        onTap: onBook,
        borderRadius: BorderRadius.circular(AppDimensions.rPill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s14,
            vertical: AppDimensions.s10,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryBg,
            borderRadius: BorderRadius.circular(AppDimensions.rPill),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppDimensions.rPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'EXPRESS SLOT',
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.s10),
              Expanded(
                child: Text(
                  'Next Open Bay Today: 2:30 PM (Bay 3)',
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                'Reserve →',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// BOOKINGS QUICK STATS DECK
class _BookingsStatsDeck extends StatelessWidget {
  final int scheduledCount;
  final int completedCount;

  const _BookingsStatsDeck({
    required this.scheduledCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Scheduled',
            value: '$scheduledCount Active',
            icon: Icons.event_available_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppDimensions.s8),
        Expanded(
          child: _StatCard(
            title: 'Completed',
            value: '$completedCount Done',
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppDimensions.s8),
        Expanded(
          child: _StatCard(
            title: 'Time Saved',
            value: '3.5 Hrs',
            icon: Icons.speed_rounded,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(AppDimensions.s10),
      color: AppColors.surface,
      borderColor: AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.labelLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          Text(
            title,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.text3,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// FEATURED PACKAGES CAROUSEL
class _FeaturedPackagesCarousel extends StatelessWidget {
  final ValueChanged<String> onSelect;

  const _FeaturedPackagesCarousel({required this.onSelect});

  static const _packages = [
    (
      'Full Synthetic Oil Service',
      '£89',
      '45 mins',
      Icons.oil_barrel_rounded,
      AppColors.primary,
    ),
    (
      'Brake Disc & Pad Replacement',
      '£149',
      '1.5 hrs',
      Icons.do_not_disturb_on_rounded,
      AppColors.danger,
    ),
    (
      'Air Conditioning Regas',
      '£59',
      '30 mins',
      Icons.ac_unit_rounded,
      AppColors.accent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (final pkg in _packages) ...[
            SizedBox(
              width: 220,
              child: AppCard(
                onTap: () => onSelect(pkg.$1),
                borderRadius: 20,
                padding: const EdgeInsets.all(AppDimensions.s12),
                color: AppColors.surface,
                borderColor: AppColors.border,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: pkg.$5.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(pkg.$4, size: 16, color: pkg.$5),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBg,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.rPill,
                            ),
                          ),
                          child: Text(
                            pkg.$2,
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.s10),
                    Text(
                      pkg.$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Est. Duration: ${pkg.$3}',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.text3,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.s10),
          ],
        ],
      ),
    );
  }
}

class _BookingFilterPills extends StatelessWidget {
  final BookingStatus? selected;
  final ValueChanged<BookingStatus?> onChanged;

  const _BookingFilterPills({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final items = <(String, BookingStatus?)>[
      ('All', null),
      ('Pending', BookingStatus.pending),
      ('Confirmed', BookingStatus.confirmed),
      ('Completed', BookingStatus.completed),
      ('Cancelled', BookingStatus.cancelled),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (final item in items) ...[
            _FilterPill(
              label: item.$1,
              isSelected: selected == item.$2,
              onTap: () => onChanged(item.$2),
            ),
            const SizedBox(width: AppDimensions.s8),
          ],
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: isSelected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.rPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.rPill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s14,
            vertical: AppDimensions.s8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.rPill),
            border: Border.all(
              color: isSelected ? Colors.transparent : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: isSelected ? Colors.white : AppColors.text2,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  final List<CustomerBookingEntity> bookings;

  const _BookingsList({required this.bookings});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final booking in bookings) ...[
          _BookingListItem(booking: booking),
          if (booking != bookings.last)
            const SizedBox(height: AppDimensions.s10),
        ],
      ],
    );
  }
}

class _BookingListItem extends StatelessWidget {
  final CustomerBookingEntity booking;

  const _BookingListItem({required this.booking});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = _statusColors(booking.status);

    return AppCard(
      onTap: () =>
          context.push(AppRoutes.customerBookingDetail, extra: booking),
      borderRadius: 24,
      padding: const EdgeInsets.all(AppDimensions.s16),
      color: AppColors.surface,
      borderColor: AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.$1,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: colors.$2,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.service.isNotEmpty
                          ? booking.service
                          : 'Service Appointment',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.rPill,
                            ),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            booking.plateNumber,
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.s6),
                        Expanded(
                          child: Text(
                            booking.vehicleName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.text3,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: booking.statusLabel,
                bg: colors.$1,
                fg: colors.$2,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s12),
          const Divider(height: 1, color: AppColors.line),
          const SizedBox(height: AppDimensions.s10),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 14,
                color: AppColors.text3,
              ),
              const SizedBox(width: 4),
              Text(
                '${booking.date}${booking.time.isNotEmpty ? " at ${booking.time}" : ""}',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.text3,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Text(
                'View Details →',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  (Color, Color) _statusColors(BookingStatus status) {
    return switch (status) {
      BookingStatus.confirmed => (AppColors.primaryBg, AppColors.primary),
      BookingStatus.completed => (AppColors.successBg, AppColors.success),
      BookingStatus.pending => (AppColors.warningBg, AppColors.warning),
      BookingStatus.cancelled => (AppColors.dangerBg, AppColors.danger),
    };
  }
}

class _ExplanatorySectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ExplanatorySectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.text3,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
