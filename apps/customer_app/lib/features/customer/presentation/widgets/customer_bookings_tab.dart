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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final dash = ref.watch(customerDashboardProvider);
    final bookingsAsync = ref.watch(customerBookingsProvider);
    final bookings =
        bookingsAsync.valueOrNull ?? const <CustomerBookingEntity>[];

    final filtered = _filter == null
        ? bookings
        : bookings.where((booking) => booking.status == _filter).toList();

    // ── INTELLIGENT STATE ROUTING ────────────────────────────────────────────
    final upcomingBooking = bookings
        .where(
          (b) =>
              b.status == BookingStatus.confirmed ||
              b.status == BookingStatus.pending,
        )
        .firstOrNull;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 88),
        child: FloatingActionButton.extended(
          heroTag: 'customer-bookings-book-service-fab',
          onPressed: () => context.push(AppRoutes.customerBookService),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 4,
          icon: Icon(Icons.add_rounded, color: colorScheme.onPrimary),
          label: Text(
            'Book Appointment',
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onPrimary,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(customerBookingsProvider),
          color: colorScheme.primary,
          child: AppResponsivePage(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── 1. PREMIUM HEADER ──────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Appointments',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.headlineMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Schedule and manage your garage visits',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
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
                              color: colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.outlineVariant,
                              ),
                            ),
                            child: Icon(
                              Icons.notifications_outlined,
                              color: colorScheme.onSurface,
                              size: 24,
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
                                  color: colorScheme.error,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: colorScheme.surface,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  dash.unreadCount > 99
                                      ? '99+'
                                      : '${dash.unreadCount}',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onError,
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
                const SizedBox(height: 32),

                // ── 2. CONTEXTUAL HERO BANNER (Replaces the clunky boxes) ──────
                if (upcomingBooking != null)
                  _UpNextHeroCard(
                    booking: upcomingBooking,
                    onTap: () => context.push(
                      AppRoutes.customerBookingDetail,
                      extra: upcomingBooking,
                    ),
                  )
                else
                  _BookNowHeroCard(
                    onBook: () => context.push(AppRoutes.customerBookService),
                  ),
                const SizedBox(height: 36),

                // ── 3. QUICK RESERVE PACKAGES ──────────────────────────────────
                _ExplanatorySectionHeader(
                  title: 'Quick Reserve',
                  subtitle: 'Instantly lock in popular service packages',
                ),
                const SizedBox(height: 16),
                _FeaturedPackagesCarousel(
                  onSelect: (pkg) =>
                      context.push(AppRoutes.customerBookService),
                ),
                const SizedBox(height: 36),

                // ── 4. ALL APPOINTMENTS & HISTORY ──────────────────────────────
                _ExplanatorySectionHeader(
                  title: 'All Appointments (${filtered.length})',
                  subtitle: 'Review your upcoming schedule and service history',
                ),
                const SizedBox(height: 16),
                _BookingFilterPills(
                  selected: _filter,
                  onChanged: (status) => setState(() => _filter = status),
                ),
                const SizedBox(height: 24),

                if (bookingsAsync.isLoading && bookings.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
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

                const SizedBox(
                  height: 80,
                ), // Padding for Floating Action Button
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── CONTEXTUAL HERO CARDS ───────────────────────────────────────────────────

/// Shown when the user has an upcoming appointment
class _UpNextHeroCard extends StatelessWidget {
  final CustomerBookingEntity booking;
  final VoidCallback onTap;

  const _UpNextHeroCard({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isConfirmed = booking.status == BookingStatus.confirmed;

    return AppCard(
      onTap: onTap,
      borderRadius: 24,
      elevation: 0,
      color: colorScheme.primaryContainer,
      borderColor: Colors.transparent,
      padding: const EdgeInsets.all(24),
      boxShadow: [
        BoxShadow(
          color: colorScheme.primary.withValues(alpha: 0.2),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'UP NEXT',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    fontSize: 9,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isConfirmed
                      ? colorScheme.primary
                      : colorScheme.onPrimaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  booking.statusLabel.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: isConfirmed
                        ? colorScheme.onPrimary
                        : colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w900,
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            booking.service.isNotEmpty ? booking.service : 'Scheduled Service',
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            booking.vehicleName,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_available_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${booking.date}${booking.time.isNotEmpty ? " at ${booking.time}" : ""}',
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: colorScheme.outline,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when the user has NO appointments, prompting an Express Slot
class _BookNowHeroCard extends StatelessWidget {
  final VoidCallback onBook;

  const _BookNowHeroCard({required this.onBook});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      borderRadius: 24,
      elevation: 0,
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      padding: const EdgeInsets.all(24),
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withValues(alpha: 0.05),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.flash_on_rounded,
                  color: colorScheme.onSecondaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready for a checkup?',
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'You have no upcoming appointments.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981), // Live green indicator
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Next Express Slot: Today at 2:30 PM',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: onBook,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.onSurface,
                foregroundColor: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Reserve Slot Now',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── FEATURED PACKAGES CAROUSEL ──────────────────────────────────────────────
class _FeaturedPackagesCarousel extends StatelessWidget {
  final ValueChanged<String> onSelect;

  const _FeaturedPackagesCarousel({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final packages = [
      (
        'Full Synthetic Oil Service',
        'AED 89',
        '45 mins',
        Icons.oil_barrel_rounded,
        colorScheme.primary,
      ),
      (
        'Brake Disc & Pad Replacement',
        'AED 149',
        '1.5 hrs',
        Icons.minor_crash_rounded,
        colorScheme.error,
      ),
      (
        'Air Conditioning Regas',
        'AED 59',
        '30 mins',
        Icons.ac_unit_rounded,
        colorScheme.secondary,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final pkg in packages) ...[
            AppCard(
              width: 240,
              onTap: () => onSelect(pkg.$1),
              borderRadius: 24,
              padding: const EdgeInsets.all(20),
              color: colorScheme.surface,
              borderColor: colorScheme.outlineVariant,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: pkg.$5.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(pkg.$4, size: 22, color: pkg.$5),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          pkg.$2,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    pkg.$1,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Est. Duration: ${pkg.$3}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],
        ],
      ),
    );
  }
}

// ─── FILTER PILLS ────────────────────────────────────────────────────────────
class _BookingFilterPills extends StatelessWidget {
  final BookingStatus? selected;
  final ValueChanged<BookingStatus?> onChanged;

  const _BookingFilterPills({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final items = <(String, BookingStatus?)>[
      ('All', null),
      ('Upcoming', BookingStatus.confirmed),
      ('Pending', BookingStatus.pending),
      ('History', BookingStatus.completed),
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
            const SizedBox(width: 8),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Material(
      color: isSelected ? colorScheme.primary : colorScheme.surface,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── BOOKINGS LIST ───────────────────────────────────────────────────────────
class _BookingsList extends StatelessWidget {
  final List<CustomerBookingEntity> bookings;

  const _BookingsList({required this.bookings});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final booking in bookings) ...[
          _BookingListItem(booking: booking),
          if (booking != bookings.last) const SizedBox(height: 16),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final colors = _statusColors(booking.status, colorScheme);

    return AppCard(
      onTap: () =>
          context.push(AppRoutes.customerBookingDetail, extra: booking),
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withValues(alpha: 0.03),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.$1,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: colors.$2,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
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
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          child: Text(
                            booking.plateNumber.toUpperCase(),
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            booking.vehicleName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
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
          const SizedBox(height: 16),
          Divider(height: 1, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                '${booking.date}${booking.time.isNotEmpty ? " at ${booking.time}" : ""}',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'View Details →',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  (Color, Color) _statusColors(BookingStatus status, ColorScheme colorScheme) {
    return switch (status) {
      BookingStatus.confirmed => (
        colorScheme.primary.withValues(alpha: 0.15),
        colorScheme.primary,
      ),
      BookingStatus.completed => (
        const Color(0xFF10B981).withValues(alpha: 0.15),
        const Color(0xFF10B981),
      ),
      BookingStatus.pending => (
        colorScheme.secondary.withValues(alpha: 0.15),
        colorScheme.secondary,
      ),
      BookingStatus.cancelled => (
        colorScheme.error.withValues(alpha: 0.15),
        colorScheme.error,
      ),
    };
  }
}

// ─── EXPLANATORY SECTION HEADER ──────────────────────────────────────────────
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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
