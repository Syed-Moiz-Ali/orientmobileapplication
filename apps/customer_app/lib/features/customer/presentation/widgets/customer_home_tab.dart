import 'dart:async';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

class CustomerHomeTab extends ConsumerWidget {
  const CustomerHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerDashboardProvider);
    final notifier = ref.read(customerDashboardProvider.notifier);
    final bookings = ref.watch(customerBookingsProvider).value ?? const [];

    if (state.isLoading) return const _HomeLoading();

    if (state.loadError.isNotEmpty) {
      return AppResponsivePage(
        child: EmptyState(
          title: 'Connection Error',
          message: 'Unable to load your dashboard.',
          icon: Icons.wifi_off_rounded,
          actionLabel: 'Retry',
          onAction: notifier.refresh,
        ),
      );
    }

    final firstName = state.profile?.firstName.isNotEmpty == true
        ? state.profile!.firstName
        : 'Customer';
    final vehicles = state.vehicles;
    final activeBooking = bookings
        .where(
          (b) =>
              b.status == BookingStatus.pending ||
              b.status == BookingStatus.confirmed,
        )
        .firstOrNull;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      // ── FLOATING BOOK ACTION ───────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'customer-home-book-service-fab',
        onPressed: () => context.push(AppRoutes.customerBookService),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        icon: Icon(Icons.build_circle_rounded, color: colorScheme.onPrimary),
        label: Text(
          'Book Service',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: notifier.refresh,
          color: colorScheme.primary,
          child: AppResponsivePage(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── 1. PREMIUM HEADER ──────────────────────────────────────────
                _PremiumHeader(
                  firstName: firstName,
                  unreadCount: state.unreadCount,
                  onNotificationTap: () =>
                      context.push(AppRoutes.customerNotifications),
                ),
                const SizedBox(height: 18),

                _TopCustomerBanners(
                  activeBooking: activeBooking,
                  vehicleCount: vehicles.length,
                  onPrimaryTap: activeBooking != null
                      ? () => context.push(
                          AppRoutes.customerBookingDetail,
                          extra: activeBooking,
                        )
                      : () => context.push(AppRoutes.customerBookService),
                  onSecondaryTap: () =>
                      context.push(AppRoutes.customerBreakdownHelp),
                  onGarageTap: () => notifier.selectTab(3),
                ),
                const SizedBox(height: 24),

                // ── 2. UBER-STYLE SEARCH PILL ──────────────────────────────────
                _UberSearchPill(
                  onTap: () => context.push(AppRoutes.customerBookService),
                ),
                const SizedBox(height: 32),

                // ── 3. BENTO-STYLE QUICK ACTIONS ───────────────────────────────
                _BentoQuickActions(
                  onBook: () => context.push(AppRoutes.customerBookService),
                  onTrack: () => notifier.selectTab(1),
                  onGarage: () => notifier.selectTab(3),
                  onSos: () => context.push(AppRoutes.customerBreakdownHelp),
                ),
                const SizedBox(height: 24),

                // ── 4. LIVE HUD ────────────────────────────────────────────────
                if (activeBooking != null) ...[
                  _ActiveJobTracker(
                    booking: activeBooking,
                    onTap: () => context.push(
                      AppRoutes.customerBookingDetail,
                      extra: activeBooking,
                    ),
                  ),
                  const SizedBox(height: 36),
                ] else ...[
                  const SizedBox(height: 12),
                ],

                // ── 5. PROMOTIONAL CAROUSEL BANNER ─────────────────────────────
                const _SectionHeading(title: 'Exclusive Promotions'),
                const SizedBox(height: 16),
                _PromoCarousel(
                  onTap: () => context.push(AppRoutes.customerBookService),
                ),
                const SizedBox(height: 36),

                // ── 6. PREMIUM MEMBERSHIP BANNER ───────────────────────────────
                const _OrientPlusBanner(),
                const SizedBox(height: 36),

                // ── 7. MY GARAGE SHOWCASE ──────────────────────────────────────
                _SectionHeadingWithAction(
                  title: 'My Garage',
                  actionText: 'Manage',
                  onAction: () => notifier.selectTab(3),
                ),
                const SizedBox(height: 16),
                if (vehicles.isEmpty)
                  _EmptyGarageTile(
                    onAdd: () => context.push(AppRoutes.customerAddVehicle),
                  )
                else
                  _GarageShowcase(
                    vehicles: vehicles,
                    onAddVehicle: () =>
                        context.push(AppRoutes.customerAddVehicle),
                    onBookService: (v) =>
                        context.push(AppRoutes.customerBookService),
                  ),
                const SizedBox(height: 36),

                // ── 8. RECOMMENDED SERVICES ────────────────────────────────────
                const _SectionHeading(title: 'Recommended for you'),
                const SizedBox(height: 16),
                _RecommendedServicesList(
                  onBook: () => context.push(AppRoutes.customerBookService),
                ),
                const SizedBox(height: 36),

                // ── 9. CAR CARE DISCOVERY (ICON DRIVEN) ────────────────────────
                const _SectionHeading(title: 'Car Care Guides'),
                const SizedBox(height: 16),
                const _CarCareTipsRow(),
                const SizedBox(height: 36),

                // ── 10. RECENT ACTIVITY ────────────────────────────────────────
                if (bookings.isNotEmpty) ...[
                  _SectionHeadingWithAction(
                    title: 'Recent Activity',
                    actionText: 'View All',
                    onAction: () => notifier.selectTab(2),
                  ),
                  const SizedBox(height: 16),
                  _RecentActivityList(
                    bookings: bookings.take(3).toList(),
                    onTap: (b) =>
                        context.push(AppRoutes.customerBookingDetail, extra: b),
                  ),
                  const SizedBox(height: 80),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── 1. Premium Header ───────────────────────────────────────────────────────
class _PremiumHeader extends StatelessWidget {
  final String firstName;
  final int unreadCount;
  final VoidCallback onNotificationTap;

  const _PremiumHeader({
    required this.firstName,
    required this.unreadCount,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Orient Customer',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Welcome, $firstName',
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onNotificationTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: colorScheme.onSurface,
                  size: 22,
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── 2. Uber-Style Search Pill ───────────────────────────────────────────────
class _TopCustomerBanners extends StatefulWidget {
  final CustomerBookingEntity? activeBooking;
  final int vehicleCount;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;
  final VoidCallback onGarageTap;

  const _TopCustomerBanners({
    required this.activeBooking,
    required this.vehicleCount,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
    required this.onGarageTap,
  });

  @override
  State<_TopCustomerBanners> createState() => _TopCustomerBannersState();
}

class _TopCustomerBannersState extends State<_TopCustomerBanners> {
  late final PageController _controller;
  Timer? _autoSlideTimer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.94);
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) return;

      final nextPage = (_index + 1) % _bannerCount;
      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  static const int _bannerCount = 3;

  @override
  Widget build(BuildContext context) {
    final booking = widget.activeBooking;
    final hasBooking = booking != null;
    final banners = [
      _TopBannerData(
        title: hasBooking
            ? 'Your service is in motion'
            : 'Book trusted car care',
        subtitle: hasBooking
            ? '${booking.service.isNotEmpty ? booking.service : "Service"} • ${booking.vehicleName}'
            : widget.vehicleCount == 0
            ? 'Add your vehicle and get workshop support faster.'
            : 'Pick a service, choose your vehicle, and track every step.',
        badge: hasBooking ? booking.statusLabel : 'Orient Service',
        actionLabel: hasBooking ? 'View status' : 'Book now',
        icon: hasBooking
            ? Icons.track_changes_rounded
            : Icons.build_circle_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1487754180451-c456f719a1fc?q=80&w=1000&auto=format&fit=crop',
        onTap: widget.onPrimaryTap,
      ),
      _TopBannerData(
        title: 'Breakdown help',
        subtitle:
            'Fast roadside assistance when your car needs urgent support.',
        badge: '24/7 support',
        actionLabel: 'Get help',
        icon: Icons.sos_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1517524008697-84bbe3c3fd98?q=80&w=900&auto=format&fit=crop',
        onTap: widget.onSecondaryTap,
      ),
      _TopBannerData(
        title: 'Your garage, ready',
        subtitle: widget.vehicleCount == 0
            ? 'Add your first vehicle to make booking quicker.'
            : '${widget.vehicleCount} vehicle${widget.vehicleCount == 1 ? "" : "s"} saved for quick service booking.',
        badge: 'My Garage',
        actionLabel: 'Manage',
        icon: Icons.directions_car_filled_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?q=80&w=1000&auto=format&fit=crop',
        onTap: widget.onGarageTap,
      ),
    ];

    return SizedBox(
      height: 200,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              padEnds: false,
              itemCount: banners.length,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (value) => setState(() => _index = value),
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == banners.length - 1 ? 0 : 12,
                  ),
                  child: _TopCustomerBannerCard(data: banners[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < banners.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: i == _index ? 20 : 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == _index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopBannerData {
  final String title;
  final String subtitle;
  final String badge;
  final String actionLabel;
  final IconData icon;
  final String imageUrl;
  final VoidCallback onTap;

  const _TopBannerData({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.actionLabel,
    required this.icon,
    required this.imageUrl,
    required this.onTap,
  });
}

class _TopCustomerBannerCard extends StatelessWidget {
  final _TopBannerData data;

  const _TopCustomerBannerCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      borderRadius: 24,
      elevation: 0,
      borderColor: colorScheme.outlineVariant,
      padding: EdgeInsets.zero,
      onTap: data.onTap,
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withValues(alpha: 0.10),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                data.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    data.icon,
                    color: colorScheme.primary.withValues(alpha: 0.35),
                    size: 52,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.inverseSurface.withValues(alpha: 0.88),
                      colorScheme.inverseSurface.withValues(alpha: 0.64),
                      colorScheme.inverseSurface.withValues(alpha: 0.16),
                    ],
                    stops: const [0, 0.62, 1],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.onInverseSurface.withValues(
                            alpha: 0.16,
                          ),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: colorScheme.onInverseSurface.withValues(
                              alpha: 0.20,
                            ),
                          ),
                        ),
                        child: Text(
                          data.badge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onInverseSurface,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        data.icon,
                        color: colorScheme.onInverseSurface,
                        size: 22,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onInverseSurface,
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        data.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onInverseSurface.withValues(
                            alpha: 0.84,
                          ),
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        data.actionLabel,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UberSearchPill extends StatelessWidget {
  final VoidCallback onTap;

  const _UberSearchPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      borderRadius: 30,
      elevation: 0,
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withValues(alpha: 0.05),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_rounded,
              color: colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What does your car need?',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Service, repairs, or breakdown help',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 3. Bento-Style Quick Actions ────────────────────────────────────────────
class _BentoQuickActions extends StatelessWidget {
  final VoidCallback onBook;
  final VoidCallback onTrack;
  final VoidCallback onGarage;
  final VoidCallback onSos;

  const _BentoQuickActions({
    required this.onBook,
    required this.onTrack,
    required this.onGarage,
    required this.onSos,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _BentoCard(
                title: 'Book\nService',
                icon: Icons.calendar_today_rounded,
                isPrimary: true,
                onTap: onBook,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _BentoCard(
                title: 'My\nGarage',
                icon: Icons.directions_car_rounded,
                isPrimary: false,
                onTap: onGarage,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _BentoCard(
                title: 'Live\nTrack',
                icon: Icons.track_changes_rounded,
                isPrimary: false,
                onTap: onTrack,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: _BentoCard(
                title: '24/7\nSOS',
                icon: Icons.sos_rounded,
                isDanger: true,
                isPrimary: false,
                onTap: onSos,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BentoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isPrimary;
  final bool isDanger;
  final VoidCallback onTap;

  const _BentoCard({
    required this.title,
    required this.icon,
    required this.isPrimary,
    this.isDanger = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final bgColor = isPrimary
        ? colorScheme.primary
        : isDanger
        ? colorScheme.error.withValues(alpha: 0.1)
        : colorScheme.surfaceContainerHighest;

    final fgColor = isPrimary
        ? colorScheme.onPrimary
        : isDanger
        ? colorScheme.error
        : colorScheme.onSurface;

    final iconBgColor = isPrimary
        ? colorScheme.onPrimary.withValues(alpha: 0.2)
        : isDanger
        ? colorScheme.error.withValues(alpha: 0.15)
        : colorScheme.surface;

    return AppCard(
      height: 110,
      borderRadius: 24,
      elevation: 0,
      color: bgColor,
      borderColor: isPrimary || isDanger
          ? Colors.transparent
          : colorScheme.outlineVariant,
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: fgColor, size: 20),
          ),
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 4. Active Job Tracker ───────────────────────────────────────────────────
class _ActiveJobTracker extends StatelessWidget {
  final CustomerBookingEntity booking;
  final VoidCallback onTap;

  const _ActiveJobTracker({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      borderRadius: 24,
      elevation: 0,
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      padding: const EdgeInsets.all(20),
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withValues(alpha: 0.05),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.satellite_alt_rounded,
              color: colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ACTIVE SERVICE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${booking.service} • ${booking.vehicleName}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

// ─── 5. Promotional Carousel Banner ──────────────────────────────────────────
class _PromoCarousel extends StatelessWidget {
  final VoidCallback onTap;

  const _PromoCarousel({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        children: [
          _PromoCard(
            tag: 'SEASONAL',
            title: 'Winter Readiness\nInspection',
            subtitle: 'Free battery & tire health check',
            imageUrl:
                'https://images.unsplash.com/photo-1469285994282-454ceb49e63c?q=80&w=800&auto=format&fit=crop',
            onTap: onTap,
          ),
          const SizedBox(width: 16),
          _PromoCard(
            tag: 'LIMITED TIME',
            title: '15% Off Major\nServices',
            subtitle: 'Use code ORIENT15 at checkout',
            imageUrl:
                'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?q=80&w=800&auto=format&fit=crop',
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final String tag;
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback onTap;

  const _PromoCard({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      width: 300,
      borderRadius: 24,
      elevation: 0,
      borderColor: colorScheme.outlineVariant,
      onTap: onTap,
      padding: EdgeInsets.zero,
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withValues(alpha: 0.1),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
      child: Stack(
        children: [
          Positioned.fill(child: Image.network(imageUrl, fit: BoxFit.cover)),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.inverseSurface.withValues(alpha: 0.2),
                    colorScheme.inverseSurface.withValues(alpha: 0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.onInverseSurface,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    tag,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.inverseSurface,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      fontSize: 9,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onInverseSurface,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onInverseSurface.withValues(
                          alpha: 0.9,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 6. Premium Membership Banner ────────────────────────────────────────────
class _OrientPlusBanner extends StatelessWidget {
  const _OrientPlusBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      height: 140,
      borderRadius: 24,
      elevation: 0,
      borderColor: colorScheme.outlineVariant,
      padding: EdgeInsets.zero,
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withValues(alpha: 0.1),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1603584173870-7f23fdae1b7a?q=80&w=800&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.inverseSurface.withValues(alpha: 0.8),
                    colorScheme.inverseSurface.withValues(alpha: 0.5),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.workspace_premium_rounded,
                            color: colorScheme.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ORIENT PLUS',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Unlock 10% off services\n& free instant towing.',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onInverseSurface,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.onInverseSurface,
                    foregroundColor: colorScheme.inverseSurface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Join',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.inverseSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 7. My Garage Showcase ───────────────────────────────────────────────────
class _GarageShowcase extends StatelessWidget {
  final List<CustomerVehicleEntity> vehicles;
  final VoidCallback onAddVehicle;
  final void Function(CustomerVehicleEntity) onBookService;

  const _GarageShowcase({
    required this.vehicles,
    required this.onAddVehicle,
    required this.onBookService,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        itemCount: vehicles.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (ctx, i) {
          if (i == vehicles.length) return _AddVehicleCard(onTap: onAddVehicle);
          return _VehicleCard(
            vehicle: vehicles[i],
            imageUrl: i % 2 == 0
                ? 'https://images.unsplash.com/photo-1550355291-bbee04a92027?q=80&w=800&auto=format&fit=crop'
                : 'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?q=80&w=800&auto=format&fit=crop',
            onBook: () => onBookService(vehicles[i]),
          );
        },
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final CustomerVehicleEntity vehicle;
  final String imageUrl;
  final VoidCallback onBook;

  const _VehicleCard({
    required this.vehicle,
    required this.imageUrl,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      width: 250,
      borderRadius: 24,
      elevation: 0,
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      padding: EdgeInsets.zero,
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
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        vehicle.plateNumber.toUpperCase(),
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSecondary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Health: ${vehicle.healthScore}%',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onBook,
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                  ),
                  icon: const Icon(Icons.build_rounded, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddVehicleCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddVehicleCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      width: 140,
      borderRadius: 24,
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      borderColor: colorScheme.outlineVariant,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle_outline_rounded,
            size: 36,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Add Vehicle',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 8. Recommended Services ─────────────────────────────────────────────────
class _RecommendedServicesList extends StatelessWidget {
  final VoidCallback onBook;

  const _RecommendedServicesList({required this.onBook});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        children: [
          _ServicePackageCard(
            title: 'Full MOT & Service',
            price: 'From \$199',
            imageUrl:
                'https://images.unsplash.com/photo-1487754180451-c456f719a1fc?q=80&w=800&auto=format&fit=crop',
            onTap: onBook,
          ),
          const SizedBox(width: 16),
          _ServicePackageCard(
            title: 'Oil & Filter Change',
            price: 'From \$49',
            imageUrl:
                'https://images.unsplash.com/photo-1632733711679-529326f6db12?q=80&w=800&auto=format&fit=crop',
            onTap: onBook,
          ),
          const SizedBox(width: 16),
          _ServicePackageCard(
            title: 'Brake Inspection',
            price: 'Free',
            imageUrl:
                'https://images.unsplash.com/photo-1600661653561-629509216228?q=80&w=800&auto=format&fit=crop',
            onTap: onBook,
          ),
        ],
      ),
    );
  }
}

class _ServicePackageCard extends StatelessWidget {
  final String title;
  final String price;
  final String imageUrl;
  final VoidCallback onTap;

  const _ServicePackageCard({
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      width: 200,
      borderRadius: 24,
      elevation: 0,
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 9. Car Care Discovery (ICON THUMBNAILS) ─────────────────────────────────
class _CarCareTipsRow extends StatelessWidget {
  const _CarCareTipsRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        children: const [
          _TipCard(
            title: '5 signs your brakes need replacing',
            icon: Icons.car_crash_rounded,
          ),
          SizedBox(width: 16),
          _TipCard(
            title: 'How to prep your car for winter',
            icon: Icons.ac_unit_rounded,
          ),
          SizedBox(width: 16),
          _TipCard(
            title: 'Understanding tire pressure codes',
            icon: Icons.tire_repair_rounded,
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const _TipCard({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = themeText(context);

    return AppCard(
      width: 260,
      borderRadius: 20,
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      borderColor: colorScheme.outlineVariant,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 80,
            height: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Center(
              child: Icon(icon, color: colorScheme.primary, size: 32),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextTheme themeText(BuildContext context) => Theme.of(context).textTheme;
}

// ─── 10. Recent Activity List ────────────────────────────────────────────────
class _RecentActivityList extends StatelessWidget {
  final List<CustomerBookingEntity> bookings;
  final void Function(CustomerBookingEntity) onTap;

  const _RecentActivityList({required this.bookings, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      borderRadius: 24,
      elevation: 0,
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      padding: EdgeInsets.zero,
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withValues(alpha: 0.05),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
      child: Column(
        children: [
          for (int i = 0; i < bookings.length; i++) ...[
            _ActivityTile(
              booking: bookings[i],
              onTap: () => onTap(bookings[i]),
            ),
            if (i < bookings.length - 1)
              Divider(height: 1, color: colorScheme.outlineVariant),
          ],
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final CustomerBookingEntity booking;
  final VoidCallback onTap;

  const _ActivityTile({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                color: colorScheme.onSurface,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.service.isNotEmpty ? booking.service : 'Service',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${booking.vehicleName} • ${booking.date}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers & Headings ──────────────────────────────────────────────────────
class _SectionHeading extends StatelessWidget {
  final String title;

  const _SectionHeading({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
    );
  }
}

class _SectionHeadingWithAction extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onAction;

  const _SectionHeadingWithAction({
    required this.title,
    required this.actionText,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = themeColor(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionText,
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  ColorScheme themeColor(BuildContext context) => Theme.of(context).colorScheme;
}

class _EmptyGarageTile extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyGarageTile({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderRadius: 24,
      elevation: 0,
      borderColor: Theme.of(context).colorScheme.outlineVariant,
      onTap: onAdd,
      child: const Center(child: Text("Add a vehicle")),
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
