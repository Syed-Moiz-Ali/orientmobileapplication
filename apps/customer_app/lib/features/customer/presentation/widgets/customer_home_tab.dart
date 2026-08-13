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

    final firstName = state.profile?.firstName.isNotEmpty == true ? state.profile!.firstName : 'Customer';
    final vehicles = state.vehicles;
    final activeBooking = bookings
        .where((b) => b.status == BookingStatus.pending || b.status == BookingStatus.confirmed)
        .firstOrNull;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: notifier.refresh,
        color: AppColors.primary,
        child: AppResponsivePage(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.s16),

              // ── 1. USER PROFILE HEADER ─────────────────────────────────
              _UberHeader(
                firstName: firstName,
                unreadCount: state.unreadCount,
                onNotificationTap: () => context.push(AppRoutes.customerNotifications),
              ),
              const SizedBox(height: AppDimensions.s16),

              // ── 2. HERO FEATURED CAROUSEL ──────────────────────────────
              _UberHeroCarousel(onBook: () => context.push(AppRoutes.customerBookService)),
              const SizedBox(height: AppDimensions.s20),

              // ── 3. ACTIVE REPAIR STATUS BAR (If active) ────────────────
              if (activeBooking != null) ...[
                _ActiveJobBanner(
                  booking: activeBooking,
                  onTap: () => context.push(AppRoutes.customerBookingDetail, extra: activeBooking),
                ),
                const SizedBox(height: AppDimensions.s20),
              ],

              // ── 4. CATEGORY TILES (Uber / Airbnb Square Cards) ────────
              const _SectionHeading(title: 'What would you like to do?'),
              const SizedBox(height: AppDimensions.s12),
              _UberCategoryGrid(
                onBook: () => context.push(AppRoutes.customerBookService),
                onTrack: () => notifier.selectTab(1),
                onGarage: () => notifier.selectTab(3),
                onSos: () => context.push(AppRoutes.customerBreakdownHelp),
              ),
              const SizedBox(height: AppDimensions.s24),

              // ── 5. MY GARAGE VEHICLE CARDS ─────────────────────────────
              _SectionHeadingWithAction(
                title: 'My Vehicles',
                actionText: 'Manage Garage',
                onAction: () => notifier.selectTab(3),
              ),
              const SizedBox(height: AppDimensions.s12),
              if (vehicles.isEmpty)
                _EmptyGarageTile(onAdd: () => context.push(AppRoutes.customerAddVehicle))
              else
                _UberGarageDeck(
                  vehicles: vehicles,
                  onAddVehicle: () => context.push(AppRoutes.customerAddVehicle),
                  onBookService: (v) => context.push(AppRoutes.customerBookService),
                ),
              const SizedBox(height: AppDimensions.s24),

              // ── 6. RECENT ACTIVITY CARDS ───────────────────────────────
              if (bookings.isNotEmpty) ...[
                _SectionHeadingWithAction(
                  title: 'Recent Bookings',
                  actionText: 'View All',
                  onAction: () => notifier.selectTab(2),
                ),
                const SizedBox(height: AppDimensions.s12),
                _UberRecentBookings(
                  bookings: bookings.take(3).toList(),
                  onTap: (b) => context.push(AppRoutes.customerBookingDetail, extra: b),
                ),
                const SizedBox(height: AppDimensions.s24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _UberHeader extends StatelessWidget {
  final String firstName;
  final int unreadCount;
  final VoidCallback onNotificationTap;

  const _UberHeader({required this.firstName, required this.unreadCount, required this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Center(
            child: Text(
              firstName.isNotEmpty ? firstName[0].toUpperCase() : 'C',
              style: textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $firstName',
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Orient Auto Service • Open Today',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.text3,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 22),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Hero Carousel (Uber/Airbnb Visual Banner) ────────────────────────────────

class _UberHeroCarousel extends StatefulWidget {
  final VoidCallback onBook;
  const _UberHeroCarousel({required this.onBook});

  @override
  State<_UberHeroCarousel> createState() => _UberHeroCarouselState();
}

class _UberHeroCarouselState extends State<_UberHeroCarousel> {
  final _pageCtrl = PageController();
  int _currPage = 0;
  Timer? _timer;

  static const _slides = [
    (
      tag: 'RECOMMENDED',
      title: 'Full Vehicle Service & Check',
      sub: 'Engine oil, filter replacement & 30-point inspection',
      cta: 'Book Now',
      img: 'assets/images/banner_workshop.jpg',
      color: Color(0xFF1E3A8A),
    ),
    (
      tag: 'FREE AUDIT',
      title: 'Pre-MOT Inspection',
      sub: 'Avoid test failures with DVSA official check',
      cta: 'Claim Free Check',
      img: 'assets/images/banner_service.jpg',
      color: Color(0xFF065F46),
    ),
    (
      tag: 'EMERGENCY',
      title: '24/7 Roadside Assistance',
      sub: 'Flat tire, dead battery or instant towing support',
      cta: 'Get Assistance',
      img: 'assets/images/banner_sos.jpg',
      color: Color(0xFF991B1B),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final next = (_currPage + 1) % _slides.length;
      _pageCtrl.animateToPage(next, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 165,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _currPage = i),
            itemCount: _slides.length,
            itemBuilder: (ctx, i) {
              final s = _slides[i];
              return GestureDetector(
                onTap: widget.onBook,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: s.color,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Image background
                      Positioned.fill(
                        child: Image.asset(
                          s.img,
                          fit: BoxFit.cover,
                          colorBlendMode: BlendMode.darken,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                      // Text content overlay
                      Padding(
                        padding: const EdgeInsets.all(AppDimensions.s16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                              child: Text(
                                s.tag,
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 9,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              s.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              s.sub,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  s.cta,
                                  style: textTheme.labelMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Page indicators
          Positioned(
            bottom: 12,
            right: 16,
            child: Row(
              children: List.generate(_slides.length, (i) {
                final sel = _currPage == i;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(left: 4),
                  width: sel ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: sel ? Colors.white : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Active Job Banner ───────────────────────────────────────────────────────

class _ActiveJobBanner extends StatelessWidget {
  final CustomerBookingEntity booking;
  final VoidCallback onTap;

  const _ActiveJobBanner({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.s14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.build_circle_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: AppDimensions.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Active Booking In Progress',
                            style: textTheme.labelMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${booking.service} • ${booking.vehicleName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Uber/Airbnb Style 2x2 Category Grid ────────────────────────────────────

class _UberCategoryGrid extends StatelessWidget {
  final VoidCallback onBook;
  final VoidCallback onTrack;
  final VoidCallback onGarage;
  final VoidCallback onSos;

  const _UberCategoryGrid({required this.onBook, required this.onTrack, required this.onGarage, required this.onSos});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _CategoryCard(
                title: 'Book Service',
                subtitle: 'Maintenance & repair',
                icon: Icons.calendar_month_rounded,
                color: AppColors.primary,
                bgColor: AppColors.primaryBg,
                onTap: onBook,
              ),
              const SizedBox(height: AppDimensions.s12),
              _CategoryCard(
                title: 'My Garage',
                subtitle: 'Registered vehicles',
                icon: Icons.directions_car_rounded,
                color: const Color(0xFF0F766E),
                bgColor: const Color(0xFFCCFBF1),
                onTap: onGarage,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.s12),
        Expanded(
          child: Column(
            children: [
              _CategoryCard(
                title: 'Live Tracking',
                subtitle: 'Repair status updates',
                icon: Icons.satellite_alt_rounded,
                color: const Color(0xFF6D28D9),
                bgColor: const Color(0xFFEDE9FE),
                onTap: onTrack,
              ),
              const SizedBox(height: AppDimensions.s12),
              _CategoryCard(
                title: '24/7 SOS',
                subtitle: 'Breakdown help',
                icon: Icons.sos_rounded,
                color: AppColors.danger,
                bgColor: AppColors.dangerBg,
                onTap: onSos,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.s14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: AppDimensions.s10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(color: AppColors.text3, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Uber/Airbnb Style Garage Deck ──────────────────────────────────────────

class _UberGarageDeck extends StatelessWidget {
  final List<CustomerVehicleEntity> vehicles;
  final VoidCallback onAddVehicle;
  final void Function(CustomerVehicleEntity) onBookService;

  const _UberGarageDeck({required this.vehicles, required this.onAddVehicle, required this.onBookService});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: vehicles.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.s12),
        itemBuilder: (ctx, i) {
          if (i == vehicles.length) {
            return GestureDetector(
              onTap: onAddVehicle,
              child: Container(
                width: 120,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: AppColors.primaryBg, shape: BoxShape.circle),
                      child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add Vehicle',
                      style: textTheme.labelMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            );
          }

          final v = vehicles[i];
          final healthColor = v.healthScore >= 80
              ? AppColors.success
              : v.healthScore >= 60
              ? AppColors.warning
              : AppColors.danger;

          return Container(
            width: 220,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle Photo Banner
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      image: DecorationImage(
                        image: AssetImage(i % 2 == 0 ? 'assets/images/car_sedan.jpg' : 'assets/images/car_suv.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(color: healthColor, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${v.healthScore}%',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFACC15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.black, width: 1.5),
                            ),
                            child: Text(
                              v.plateNumber.toUpperCase(),
                              style: textTheme.labelSmall?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontFamily: AppFontFamilies.mono,
                                fontSize: 9,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Vehicle Details & Action
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.s12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 32,
                          child: ElevatedButton(
                            onPressed: () => onBookService(v),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              'Book Service',
                              style: textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
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
          );
        },
      ),
    );
  }
}

class _EmptyGarageTile extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyGarageTile({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onAdd,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.s16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: AppColors.primaryBg, shape: BoxShape.circle),
                  child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: AppDimensions.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add your first vehicle',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Tap to register a vehicle to your garage',
                        style: textTheme.bodySmall?.copyWith(color: AppColors.text3),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.text4, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Uber/Airbnb Style Recent Bookings List ──────────────────────────────────

class _UberRecentBookings extends StatelessWidget {
  final List<CustomerBookingEntity> bookings;
  final void Function(CustomerBookingEntity) onTap;

  const _UberRecentBookings({required this.bookings, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < bookings.length; i++) ...[
            _BookingTile(booking: bookings[i], onTap: () => onTap(bookings[i])),
            if (i < bookings.length - 1) const Divider(height: 1, color: AppColors.line),
          ],
        ],
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  final CustomerBookingEntity booking;
  final VoidCallback onTap;

  const _BookingTile({required this.booking, required this.onTap});

  Color get _statusFg {
    switch (booking.status) {
      case BookingStatus.confirmed:
        return AppColors.primary;
      case BookingStatus.completed:
        return AppColors.success;
      case BookingStatus.cancelled:
        return AppColors.danger;
      case BookingStatus.pending:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s16, vertical: AppDimensions.s14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.primaryBg, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.service.isNotEmpty ? booking.service : 'Service',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${booking.vehicleName} • ${booking.date}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(color: AppColors.text3, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.s8),
              StatusPill(label: booking.statusLabel, bg: _statusFg.withValues(alpha: 0.12), fg: _statusFg),
            ],
          ),
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
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w900,
        fontSize: 17,
        letterSpacing: -0.4,
      ),
    );
  }
}

class _SectionHeadingWithAction extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onAction;

  const _SectionHeadingWithAction({required this.title, required this.actionText, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 17,
            letterSpacing: -0.4,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionText,
            style: textTheme.labelMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

// ─── Loading Skeleton ────────────────────────────────────────────────────────

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return AppResponsivePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimensions.s16),
          _SkeletonBox(width: 200, height: 28, radius: 8),
          const SizedBox(height: 8),
          _SkeletonBox(width: 140, height: 14, radius: 6),
          const SizedBox(height: AppDimensions.s20),
          _SkeletonBox(width: double.infinity, height: 165, radius: 20),
          const SizedBox(height: AppDimensions.s20),
          Row(
            children: [
              Expanded(child: _SkeletonBox(width: double.infinity, height: 70, radius: 18)),
              const SizedBox(width: AppDimensions.s12),
              Expanded(child: _SkeletonBox(width: double.infinity, height: 70, radius: 18)),
            ],
          ),
          const SizedBox(height: AppDimensions.s12),
          Row(
            children: [
              Expanded(child: _SkeletonBox(width: double.infinity, height: 70, radius: 18)),
              const SizedBox(width: AppDimensions.s12),
              Expanded(child: _SkeletonBox(width: double.infinity, height: 70, radius: 18)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _SkeletonBox({required this.width, required this.height, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(radius)),
    );
  }
}
