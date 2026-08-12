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

    if (state.isLoading) return const _CustomerHomeLoading();

    if (state.loadError.isNotEmpty) {
      return AppResponsivePage(
        child: EmptyState(
          title: 'Connection Error',
          message: 'Unable to load your vehicle dashboard.',
          icon: Icons.wifi_off_rounded,
          actionLabel: 'Retry Sync',
          onAction: notifier.refresh,
        ),
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: notifier.refresh,
        color: AppColors.primary,
        child: AppResponsivePage(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER GREETING & NOTIFICATION BELL
              _UnifiedHeader(
                firstName: state.profile?.firstName.isNotEmpty == true
                    ? state.profile!.firstName
                    : 'Customer',
                memberId: state.profile?.memberId ?? '102',
                unreadCount: state.unreadCount,
                onNotificationTap: () =>
                    context.push(AppRoutes.customerNotifications),
              ),
              const SizedBox(height: AppDimensions.s16),

              // PROMOTIONAL HERO BANNER CAROUSEL
              _PromotionalHeroBannerCarousel(
                onClaimOffer: () => context.push(AppRoutes.customerBookService),
              ),
              const SizedBox(height: AppDimensions.s16),

              // LIVE WORKSHOP EXPRESS SLOT TICKER BANNER
              _LiveWorkshopSlotBanner(
                onBook: () => context.push(AppRoutes.customerBookService),
              ),
              const SizedBox(height: AppDimensions.s16),

              // MASONRY QUICK ACTIONS (r24 Curves & Flush Baseline)
              _MasonryQuickActionGrid(
                onBook: () => context.push(AppRoutes.customerBookService),
                onTrack: () => notifier.selectTab(1),
                onGarage: () => notifier.selectTab(3),
                onBreakdown: () =>
                    context.push(AppRoutes.customerBreakdownHelp),
              ),
              const SizedBox(height: AppDimensions.s24),

              // SERVICE PLANS & PACKAGES
              _SectionHeader(
                title: 'Popular Service Packages',
                action: 'View All',
                onAction: () => context.push(AppRoutes.customerBookService),
              ),
              const SizedBox(height: AppDimensions.s10),
              _FeaturedServicePackagesDeck(
                onSelectPackage: (pkg) =>
                    context.push(AppRoutes.customerBookService),
              ),
              const SizedBox(height: AppDimensions.s24),

              // MY GARAGE SHOWCASE
              _SectionHeader(
                title: 'My Garage Showcase',
                action: '+ Add Vehicle',
                onAction: () => context.push(AppRoutes.customerAddVehicle),
              ),
              const SizedBox(height: AppDimensions.s10),
              _EnhancedGarageDeck(
                vehicles: state.vehicles,
                onAddVehicle: () => context.push(AppRoutes.customerAddVehicle),
                onBookService: () =>
                    context.push(AppRoutes.customerBookService),
                onManage: () => notifier.selectTab(3),
              ),
              const SizedBox(height: AppDimensions.s24),
            ],
          ),
        ),
      ),
    );
  }
}

/// PROMOTIONAL HERO BANNER CAROUSEL (Dribbble Grade 24px Curved Banner)
class _PromotionalHeroBannerCarousel extends StatefulWidget {
  final VoidCallback onClaimOffer;

  const _PromotionalHeroBannerCarousel({required this.onClaimOffer});

  @override
  State<_PromotionalHeroBannerCarousel> createState() =>
      __PromotionalHeroBannerCarouselState();
}

class __PromotionalHeroBannerCarouselState
    extends State<_PromotionalHeroBannerCarousel> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const _banners = [
    (
      '30% OFF FULL SERVICE',
      'Summer Maintenance Package',
      'Synthetic Oil & Filter + 20-pt Check',
      'Claim Offer →',
      Color(0xFF1D4ED8),
      Color(0xFF3B82F6),
      Icons.local_offer_rounded,
    ),
    (
      'FREE PRE-MOT CHECK',
      'VIP Member Exclusive',
      '20-Point Official DVSA Pre-Audit',
      'Book Check →',
      Color(0xFF0F766E),
      Color(0xFF14B8A6),
      Icons.verified_user_rounded,
    ),
    (
      '24/7 ROAD ASSIST',
      'Emergency SOS Support',
      'Instant Tow Truck & Battery Jumpstart',
      'Get SOS →',
      Color(0xFFB91C1C),
      Color(0xFFEF4444),
      Icons.emergency_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 140,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _banners.length,
            itemBuilder: (ctx, i) {
              final b = _banners[i];
              return AppCard(
                onTap: widget.onClaimOffer,
                borderRadius: 24,
                padding: const EdgeInsets.all(AppDimensions.s16),
                color: b.$5,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [b.$5, b.$6],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.rPill,
                                ),
                              ),
                              child: Text(
                                b.$1,
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 9,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              b.$2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              b.$3,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.s10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.s12,
                          vertical: AppDimensions.s8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.rPill,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          b.$4,
                          style: textTheme.labelSmall?.copyWith(
                            color: b.$5,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 10,
            right: 18,
            child: Row(
              children: List.generate(_banners.length, (i) {
                final sel = _currentPage == i;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(left: 4),
                  width: sel ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: sel
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppDimensions.rPill),
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

/// TOP HEADER WITH NOTIFICATION BELL ICON (Clean Native Header)
class _UnifiedHeader extends StatelessWidget {
  final String firstName;
  final String memberId;
  final int unreadCount;
  final VoidCallback onNotificationTap;

  const _UnifiedHeader({
    required this.firstName,
    required this.memberId,
    required this.unreadCount,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final greeting = _greetingTime();

    return Padding(
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
                  '$greeting, $firstName 👋',
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
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.s6),
                    Text(
                      'Member #$memberId • Workshop Online',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.text3,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.s12),

          // Notification Bell Button
          GestureDetector(
            onTap: onNotificationTap,
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                ),
                if (unreadCount > 0)
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
                        border: Border.all(color: AppColors.bg, width: 2),
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
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
    );
  }

  static String _greetingTime() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

/// LIVE WORKSHOP SLOT AVAILABILITY BANNER (Rounded Pill Banner)
class _LiveWorkshopSlotBanner extends StatelessWidget {
  final VoidCallback onBook;

  const _LiveWorkshopSlotBanner({required this.onBook});

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
                  'Next Slot Today: 2:30 PM (Bay 3)',
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

/// PERFECTLY ALIGNED MASONRY QUICK ACTION GRID (Flush Baseline via IntrinsicHeight)
class _MasonryQuickActionGrid extends StatelessWidget {
  final VoidCallback onBook;
  final VoidCallback onTrack;
  final VoidCallback onGarage;
  final VoidCallback onBreakdown;

  const _MasonryQuickActionGrid({
    required this.onBook,
    required this.onTrack,
    required this.onGarage,
    required this.onBreakdown,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Column (Hero Book Service + My Garage)
          Expanded(
            flex: 6,
            child: Column(
              children: [
                // Hero Book Card (Stretches to fill available space)
                Expanded(
                  child: AppCard(
                    onTap: onBook,
                    color: AppColors.primary,
                    borderRadius: 24,
                    padding: const EdgeInsets.all(AppDimensions.s16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.28),
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
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.calendar_month_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.s8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.rPill,
                                ),
                              ),
                              child: Text(
                                'QUICK SLOT',
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          'Book Service',
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Reserve slot & get estimate',
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.s14),
                        Container(
                          width: double.infinity,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.rPill,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Book Appointment',
                              style: textTheme.labelMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.s10),

                // My Garage Card (Aligns FLUSH with Roadside SOS on the right)
                AppCard(
                  onTap: onGarage,
                  color: AppColors.surface,
                  borderColor: AppColors.border,
                  borderRadius: 24,
                  padding: const EdgeInsets.all(AppDimensions.s14),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.directions_car_filled_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.s10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Garage',
                              style: textTheme.titleSmall?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Manage vehicles',
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.text3,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.s10),

          // Right Column (Track Repair + Roadside SOS)
          Expanded(
            flex: 5,
            child: Column(
              children: [
                // Track Repair Card
                Expanded(
                  child: AppCard(
                    onTap: onTrack,
                    color: AppColors.surface,
                    borderColor: AppColors.border,
                    borderRadius: 24,
                    padding: const EdgeInsets.all(AppDimensions.s14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.satellite_alt_rounded,
                                color: AppColors.accent,
                                size: 20,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: AppColors.text4,
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          'Live Tracking',
                          style: textTheme.titleSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Workshop updates',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.text3,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.s10),

                // Roadside SOS 24/7 Card
                Expanded(
                  child: AppCard(
                    onTap: onBreakdown,
                    color: AppColors.dangerBg,
                    borderColor: AppColors.dangerBorder,
                    borderRadius: 24,
                    padding: const EdgeInsets.all(AppDimensions.s14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                color: AppColors.danger,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.sos_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.danger,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.rPill,
                                ),
                              ),
                              child: Text(
                                '24/7',
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          'Roadside SOS',
                          style: textTheme.titleSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Emergency dispatch',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ],
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

/// ROUNDED FEATURED SERVICE PACKAGES CAROUSEL (r24 Curves)
class _FeaturedServicePackagesDeck extends StatelessWidget {
  final ValueChanged<String> onSelectPackage;

  const _FeaturedServicePackagesDeck({required this.onSelectPackage});

  static const _packages = [
    (
      'Full Synthetic Oil Service',
      '£89',
      '45 mins',
      'Engine flush, synthetic oil & filter + 20-pt check',
      Icons.oil_barrel_rounded,
      AppColors.primary,
    ),
    (
      'Complete Brake & Disc Service',
      '£149',
      '1.5 hrs',
      'Front & rear pads, rotor check & fluid flush',
      Icons.do_not_disturb_on_rounded,
      AppColors.danger,
    ),
    (
      'AC Regas & Sanitization',
      '£59',
      '30 mins',
      'Full R134a/R1234yf gas refill & anti-bacterial clean',
      Icons.ac_unit_rounded,
      AppColors.accent,
    ),
    (
      'Annual MOT & Pre-Check Test',
      '£45',
      '1.0 hr',
      'Official DVSA certified MOT testing & pre-audit',
      Icons.verified_user_rounded,
      AppColors.success,
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
              width: 260,
              child: AppCard(
                onTap: () => onSelectPackage(pkg.$1),
                borderRadius: 24,
                padding: const EdgeInsets.all(AppDimensions.s14),
                color: AppColors.surface,
                borderColor: AppColors.border,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: pkg.$6.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(pkg.$5, size: 18, color: pkg.$6),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.s8,
                            vertical: 3,
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
                    const SizedBox(height: AppDimensions.s12),
                    Text(
                      pkg.$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pkg.$4,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.text3,
                        height: 1.3,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s10),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: AppColors.text4,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pkg.$3,
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.text4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Book Slot →',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
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

/// ROUNDED ENHANCED GARAGE SHOWCASE (r24 Curves)
class _EnhancedGarageDeck extends StatelessWidget {
  final List<CustomerVehicleEntity> vehicles;
  final VoidCallback onAddVehicle;
  final VoidCallback onBookService;
  final VoidCallback onManage;

  const _EnhancedGarageDeck({
    required this.vehicles,
    required this.onAddVehicle,
    required this.onBookService,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    if (vehicles.isEmpty) {
      return EmptyState(
        title: 'No registered vehicles',
        message: 'Add your vehicle details to enable quick booking & tracking.',
        icon: Icons.directions_car_outlined,
        actionLabel: 'Add vehicle',
        onAction: onAddVehicle,
      );
    }

    final displayVehicles = vehicles.take(3).toList();

    return Column(
      children: [
        for (final vehicle in displayVehicles) ...[
          _EnhancedVehicleCard(
            vehicle: vehicle,
            onBookService: onBookService,
            onManage: onManage,
          ),
          if (vehicle != displayVehicles.last)
            const SizedBox(height: AppDimensions.s10),
        ],
      ],
    );
  }
}

class _EnhancedVehicleCard extends StatelessWidget {
  final CustomerVehicleEntity vehicle;
  final VoidCallback onBookService;
  final VoidCallback onManage;

  const _EnhancedVehicleCard({
    required this.vehicle,
    required this.onBookService,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final healthColor = vehicle.healthScore >= 80
        ? AppColors.success
        : vehicle.healthScore >= 60
        ? AppColors.warning
        : AppColors.danger;

    final healthProgress = (vehicle.healthScore.clamp(0, 100) / 100).toDouble();

    return AppCard(
      onTap: onManage,
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
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.directions_car_filled_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.displayName,
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
                            horizontal: 8,
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
                            vehicle.plateNumber,
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.s8),
                        if (vehicle.mileage.isNotEmpty)
                          Text(
                            vehicle.mileage,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.text3,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: '${vehicle.healthScore}% Healthy',
                bg: healthColor.withValues(alpha: 0.12),
                fg: healthColor,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Health Index',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.text3,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${vehicle.healthScore}/100',
                          style: textTheme.labelSmall?.copyWith(
                            color: healthColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.rPill),
                      child: LinearProgressIndicator(
                        value: healthProgress,
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceAlt,
                        valueColor: AlwaysStoppedAnimation(healthColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s12),
          const Divider(height: 1, color: AppColors.line),
          const SizedBox(height: AppDimensions.s10),
          Row(
            children: [
              const Icon(
                Icons.event_available_rounded,
                size: 14,
                color: AppColors.text3,
              ),
              const SizedBox(width: 4),
              Text(
                vehicle.nextDue.isNotEmpty
                    ? 'MOT Due: ${vehicle.nextDue}'
                    : 'Annual MOT & Service OK',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.text3,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onBookService,
                borderRadius: BorderRadius.circular(AppDimensions.rPill),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.s8,
                    vertical: 2,
                  ),
                  child: Text(
                    'Book Service →',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const _SectionHeader({required this.title, this.action, this.onAction});

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
            letterSpacing: -0.4,
          ),
        ),
        const Spacer(),
        if (action != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class _CustomerHomeLoading extends StatelessWidget {
  const _CustomerHomeLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}
