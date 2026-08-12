import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

class CustomerVehiclesView extends ConsumerWidget {
  const CustomerVehiclesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(customerDashboardProvider).vehicles;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(
              title: 'My Vehicles',
              trailing: FilledButton.icon(
                onPressed: () => context.push(AppRoutes.customerAddVehicle),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add'),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: AppResponsivePage(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (vehicles.isEmpty)
                      AppCard(
                        onTap: () => context.push(AppRoutes.customerAddVehicle),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.add_circle_outline_rounded,
                              color: AppColors.text4,
                              size: 34,
                            ),
                            const SizedBox(height: AppDimensions.s10),
                            Text(
                              'Add your first vehicle',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                          ],
                        ),
                      )
                    else
                      AppAdaptiveGrid(
                        minChildWidth: 360,
                        childAspectRatio: 1.12,
                        children: [
                          for (final vehicle in vehicles)
                            _VehicleCard(vehicle: vehicle),
                          _AddVehicleCard(
                            onTap: () =>
                                context.push(AppRoutes.customerAddVehicle),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final CustomerVehicleEntity vehicle;

  const _VehicleCard({required this.vehicle});

  Color get _scoreColor {
    if (vehicle.healthScore >= 80) return AppColors.success;
    if (vehicle.healthScore >= 60) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.s16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(AppDimensions.r12),
                  ),
                  child: const Icon(
                    Icons.directions_car_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppDimensions.s14),
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
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.s6),
                      Wrap(
                        spacing: AppDimensions.s8,
                        runSpacing: AppDimensions.s6,
                        children: [
                          StatusPill(
                            label: vehicle.plateNumber,
                            bg: AppColors.bg,
                            fg: AppColors.text2,
                          ),
                          Text(
                            '${vehicle.year}',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.text3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: vehicle.healthScore / 100,
                        strokeWidth: 4,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation(_scoreColor),
                        strokeCap: StrokeCap.round,
                      ),
                      Text(
                        '${vehicle.healthScore}',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: _scoreColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            indent: AppDimensions.s16,
            endIndent: AppDimensions.s16,
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.s14),
            child: AppAdaptiveGrid(
              columns: 2,
              spacing: AppDimensions.s10,
              runSpacing: AppDimensions.s10,
              childAspectRatio: 2.9,
              children: [
                _InfoTile(
                  icon: Icons.speed_rounded,
                  label: 'Mileage',
                  value: vehicle.mileage,
                  color: AppColors.primary,
                ),
                _InfoTile(
                  icon: Icons.palette_outlined,
                  label: 'Color',
                  value: vehicle.color,
                  color: AppColors.info,
                ),
                _InfoTile(
                  icon: Icons.history_rounded,
                  label: 'Last service',
                  value: vehicle.lastService,
                  color: AppColors.success,
                ),
                _InfoTile(
                  icon: Icons.event_outlined,
                  label: 'Next due',
                  value: vehicle.nextDue,
                  color: vehicle.healthScore < 70
                      ? AppColors.danger
                      : AppColors.warning,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.s14,
              0,
              AppDimensions.s14,
              AppDimensions.s14,
            ),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        context.push(AppRoutes.customerBookService),
                    icon: const Icon(Icons.calendar_month_rounded),
                    label: const Text('Book Service'),
                  ),
                ),
                const SizedBox(width: AppDimensions.s10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Last service: ${vehicle.lastService} - Next due: ${vehicle.nextDue}',
                          ),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.history_rounded),
                    label: const Text('History'),
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

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.s10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppDimensions.r10),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: AppDimensions.s8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(color: AppColors.text3),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.text2,
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

class _AddVehicleCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddVehicleCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.add_circle_outline_rounded,
            color: AppColors.text4,
            size: 34,
          ),
          const SizedBox(height: AppDimensions.s10),
          Text(
            'Add new vehicle',
            style: textTheme.titleSmall?.copyWith(
              color: AppColors.text3,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
