import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_empty_fallbacks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

class CustomerVehiclesTab extends ConsumerWidget {
  const CustomerVehiclesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dash = ref.watch(customerDashboardProvider);
    final vehicles = dash.vehicles;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await ref.read(customerDashboardProvider.notifier).refresh();
        },
        color: AppColors.primary,
        child: AppResponsivePage(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. PAGE HEADER (Matches Home Tab Header Pattern)
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
                            'My Garage Showcase 🚗',
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
                            'Manage registered cars, MOT due dates & vehicle health',
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

              // 2. MASONRY QUICK ACTIONS GRID
              _GarageQuickActionsGrid(
                onAddVehicle: () => context.push(AppRoutes.customerAddVehicle),
                onBookService: () =>
                    context.push(AppRoutes.customerBookService),
                onSos: () => context.push(AppRoutes.customerBreakdownHelp),
              ),
              const SizedBox(height: AppDimensions.s24),

              // 3. VEHICLES LIST (Rich Garage Showcase Deck)
              if (vehicles.isEmpty)
                EmptyVehiclesCard(
                  onAddVehicle: () =>
                      context.push(AppRoutes.customerAddVehicle),
                )
              else ...[
                _ExplanatorySectionHeader(
                  title: 'Your Registered Vehicles (${vehicles.length})',
                  subtitle:
                      'Tap any car to book a service, check MOT due date, or edit details',
                ),
                const SizedBox(height: AppDimensions.s10),
                Column(
                  children: [
                    for (final vehicle in vehicles) ...[
                      _VehicleCardWithActions(vehicle: vehicle, ref: ref),
                      if (vehicle != vehicles.last)
                        const SizedBox(height: AppDimensions.s12),
                    ],
                  ],
                ),
              ],
              const SizedBox(height: AppDimensions.s32),
            ],
          ),
        ),
      ),
    );
  }
}

/// MASONRY QUICK ACTIONS GRID FOR GARAGE
class _GarageQuickActionsGrid extends StatelessWidget {
  final VoidCallback onAddVehicle;
  final VoidCallback onBookService;
  final VoidCallback onSos;

  const _GarageQuickActionsGrid({
    required this.onAddVehicle,
    required this.onBookService,
    required this.onSos,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: AppCard(
            onTap: onAddVehicle,
            borderRadius: 20,
            padding: const EdgeInsets.all(AppDimensions.s14),
            color: AppColors.surface,
            borderColor: AppColors.border,
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
                    Icons.add_rounded,
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
                        'Add Vehicle',
                        style: textTheme.titleSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Register car',
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
        ),
        const SizedBox(width: AppDimensions.s10),
        Expanded(
          child: AppCard(
            onTap: onBookService,
            borderRadius: 20,
            padding: const EdgeInsets.all(AppDimensions.s14),
            color: AppColors.surface,
            borderColor: AppColors.border,
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.s10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Book Service',
                        style: textTheme.titleSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Reserve slot',
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
        ),
      ],
    );
  }
}

class _VehicleCardWithActions extends StatelessWidget {
  final CustomerVehicleEntity vehicle;
  final WidgetRef ref;

  const _VehicleCardWithActions({required this.vehicle, required this.ref});

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
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.directions_car_filled_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 10,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                          'Vehicle Health Index',
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
                    : 'Annual MOT OK',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.text3,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => context.push(AppRoutes.customerBookService),
                    borderRadius: BorderRadius.circular(AppDimensions.rPill),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.s6,
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
                  const SizedBox(width: 6),
                  _ActionBtn(
                    icon: Icons.edit_outlined,
                    color: AppColors.info,
                    onTap: () =>
                        context.push(AppRoutes.customerEditVehicle(vehicle.id)),
                  ),
                  const SizedBox(width: 4),
                  _ActionBtn(
                    icon: Icons.delete_outline_rounded,
                    color: AppColors.danger,
                    onTap: () => _confirmDelete(context, vehicle, ref),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    CustomerVehicleEntity v,
    WidgetRef ref,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Remove ${v.displayName}?'),
        content: const Text(
          'This will remove the vehicle from your garage. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(customerDashboardProvider.notifier).removeVehicle(v.id);
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
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
