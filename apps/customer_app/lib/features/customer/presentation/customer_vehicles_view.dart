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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final vehicles = ref.watch(customerDashboardProvider).vehicles;

    return Scaffold(
      backgroundColor: colorScheme.surface,
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
            Divider(height: 1, color: colorScheme.outlineVariant),
            Expanded(
              child: AppResponsivePage(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (vehicles.isEmpty)
                      AppCard(
                        borderRadius: AppDimensions.r24,
                        color: colorScheme.surface,
                        borderColor: colorScheme.outlineVariant,
                        onTap: () => context.push(AppRoutes.customerAddVehicle),
                        child: Column(
                          children: [
                            Icon(
                              Icons.add_circle_outline_rounded,
                              color: colorScheme.onSurfaceVariant,
                              size: 34,
                            ),
                            const SizedBox(height: AppDimensions.s10),
                            Text(
                              'Add your first vehicle',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: colorScheme.onSurface,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      padding: EdgeInsets.zero,
      borderRadius: AppDimensions.r24,
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
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
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimensions.r16),
                  ),
                  child: Icon(
                    Icons.directions_car_rounded,
                    color: colorScheme.primary,
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
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.s6),
                      Wrap(
                        spacing: AppDimensions.s8,
                        runSpacing: AppDimensions.s6,
                        children: [
                          StatusPill(
                            label: vehicle.plateNumber,
                            bg: colorScheme.surfaceContainerLow,
                            fg: colorScheme.onSurface,
                          ),
                          Text(
                            '${vehicle.year}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
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
                        backgroundColor: colorScheme.outlineVariant,
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
          Divider(
            height: 1,
            color: colorScheme.outlineVariant,
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
                  color: colorScheme.primary,
                ),
                _InfoTile(
                  icon: Icons.palette_outlined,
                  label: 'Color',
                  value: vehicle.color,
                  color: colorScheme.secondary,
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
                      ? colorScheme.error
                      : const Color(0xFFFFB800),
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
                          backgroundColor: colorScheme.primary,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.s10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppDimensions.r12),
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
                  style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      onTap: onTap,
      borderRadius: AppDimensions.r24,
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle_outline_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 34,
          ),
          const SizedBox(height: AppDimensions.s10),
          Text(
            'Add new vehicle',
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
