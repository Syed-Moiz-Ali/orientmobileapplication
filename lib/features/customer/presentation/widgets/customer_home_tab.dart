import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/core/theme/app_text_styles.dart';
import 'package:orientmobileapplication/features/customer/domain/entities/customer_entities.dart';
import 'package:orientmobileapplication/features/customer/presentation/widgets/customer_service_card.dart';
import 'package:orientmobileapplication/features/customer/presentation/widgets/customer_stat_card.dart';
import 'package:orientmobileapplication/features/customer/presentation/widgets/customer_vehicle_card.dart';
import 'package:orientmobileapplication/features/customer/providers/customer_providers.dart';

const Color _navy = AppColors.darkNavy;
const Color _cyanLight = AppColors.cyanLight;

class CustomerHomeTab extends ConsumerWidget {
  const CustomerHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerDashboardProvider);
    final notifier = ref.read(customerDashboardProvider.notifier);

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.accent,
          strokeWidth: 2.5,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => notifier.refresh(),
      color: AppColors.accent,
      strokeWidth: 2.5,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderBanner(state: state),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.s16,
                AppDimensions.s24,
                AppDimensions.s16,
                AppDimensions.s32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomerActiveServiceCard(
                    svc: CustomerServiceEntity.mock,
                    onTap: () => notifier.selectTab(1),
                  ),
                  const SizedBox(height: AppDimensions.s24),
                  _sectionLabel('Overview'),
                  const SizedBox(height: AppDimensions.s12),
                  CustomerStatGrid(state: state),
                  const SizedBox(height: AppDimensions.s28),
                  _sectionLabel('Quick Actions'),
                  const SizedBox(height: AppDimensions.s12),
                  _QuickActionsGrid(notifier: notifier),
                  const SizedBox(height: AppDimensions.s28),
                  _sectionLabel('My Vehicles'),
                  const SizedBox(height: AppDimensions.s12),
                  _VehicleScrollRow(vehicles: state.vehicles),
                  const SizedBox(height: AppDimensions.s28),
                  _sectionLabel('Recent Bookings'),
                  const SizedBox(height: AppDimensions.s12),
                  _RecentBookingsList(bookings: CustomerBookingEntity.mock),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Row(
    children: [
      Container(
        width: 4,
        height: 20,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(AppDimensions.r2),
        ),
      ),
      const SizedBox(width: AppDimensions.s10),
      Text(
        text,
        style: AppTextStyles.rajdhaniTitle(color: AppColors.textPrimary),
      ),
    ],
  );
}

class _HeaderBanner extends StatelessWidget {
  final CustomerDashboardState state;
  const _HeaderBanner({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.s20,
        AppDimensions.s24,
        AppDimensions.s20,
        AppDimensions.s28,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_navy, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 6, top: 1),
                      decoration: const BoxDecoration(
                        color: AppColors.cyan,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Text(
                      'Live',
                      style: TextStyle(
                        color: AppColors.cyan,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.s6),
                const Text(
                  'Good Morning,',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  CustomerEntity.mock.name,
                  style: AppTextStyles.orbitronDisplayMedium(
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.s14),
                Row(
                  children: [
                    _pill(
                      Icons.build_circle_outlined,
                      '${CustomerServiceEntity.mock.progressPercent}% Done',
                      AppColors.warning,
                    ),
                    const SizedBox(width: AppDimensions.s8),
                    _pill(
                      Icons.directions_car_rounded,
                      '${state.vehicles.length} Vehicles',
                      AppColors.cyan,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s12,
        vertical: AppDimensions.s6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.r22),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 14),
          const SizedBox(width: AppDimensions.s6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final CustomerDashboardNotifier notifier;
  const _QuickActionsGrid({required this.notifier});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QAction(
        Icons.calendar_month_rounded,
        'Book\nAppointment',
        AppColors.accent,
        _cyanLight,
        () => notifier.selectTab(2),
      ),
      _QAction(
        Icons.directions_car_rounded,
        'My\nVehicles',
        AppColors.success,
        AppColors.successBg,
        () => notifier.selectTab(3),
      ),
      _QAction(
        Icons.track_changes_rounded,
        'Service\nStatus',
        AppColors.info,
        AppColors.infoBg,
        () => notifier.selectTab(1),
      ),
      _QAction(
        Icons.emergency_rounded,
        'Breakdown\nHelp',
        AppColors.danger,
        AppColors.dangerBg,
        () {},
      ),
    ];

    return Row(
      children: actions.asMap().entries.map((e) {
        final a = e.value;
        final isLast = e.key == actions.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 10),
            child: GestureDetector(
              onTap: a.onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.s16,
                ),
                decoration: BoxDecoration(
                  color: a.bg,
                  borderRadius: BorderRadius.circular(AppDimensions.r14),
                  border: Border.all(color: a.color.withValues(alpha: 0.20)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: a.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(a.icon, size: 20, color: a.color),
                    ),
                    const SizedBox(height: AppDimensions.s8),
                    Text(
                      a.label,
                      style: AppTextStyles.rajdhaniBodySmall(color: a.color),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _QAction {
  final IconData icon;
  final String label;
  final Color color, bg;
  final VoidCallback onTap;
  const _QAction(this.icon, this.label, this.color, this.bg, this.onTap);
}

class _VehicleScrollRow extends StatelessWidget {
  final List<CustomerVehicleEntity> vehicles;
  const _VehicleScrollRow({required this.vehicles});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 128,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: vehicles.length,
        itemBuilder: (_, i) {
          final v = vehicles[i];
          return Container(
            width: 200,
            margin: EdgeInsets.only(right: i < vehicles.length - 1 ? 12 : 0),
            child: CustomerVehicleCard(vehicle: v, compact: true),
          );
        },
      ),
    );
  }
}

class _RecentBookingsList extends StatelessWidget {
  final List<CustomerBookingEntity> bookings;
  const _RecentBookingsList({required this.bookings});

  (Color, Color) _statusColors(BookingStatus s) {
    switch (s) {
      case BookingStatus.confirmed:
        return (_cyanLight, AppColors.accent);
      case BookingStatus.completed:
        return (AppColors.successBg, AppColors.success);
      case BookingStatus.pending:
        return (AppColors.warningBg, AppColors.warning);
      case BookingStatus.cancelled:
        return (AppColors.dangerBg, AppColors.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r14)),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: bookings.asMap().entries.map((e) {
          final b = e.value;
          final isLast = e.key == bookings.length - 1;
          final (bg, fg) = _statusColors(b.status);

          return Container(
            padding: EdgeInsets.fromLTRB(
              0,
              e.key == 0 ? 0 : 12,
              0,
              isLast ? 0 : 12,
            ),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(
                      bottom: BorderSide(color: AppColors.border, width: 0.8),
                    ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _cyanLight,
                    borderRadius: BorderRadius.circular(AppDimensions.r12),
                  ),
                  child: const Icon(
                    Icons.build_circle_outlined,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.service,
                        style: AppTextStyles.rajdhaniLabel(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.s4),
                      Text(
                        '${b.vehicleName}  ·  ${b.date}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.text3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.s10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.s10,
                    vertical: AppDimensions.s4,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(AppDimensions.r20),
                  ),
                  child: Text(
                    b.statusLabel,
                    style: TextStyle(
                      color: fg,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
