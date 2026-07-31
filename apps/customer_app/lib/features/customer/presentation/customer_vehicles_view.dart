import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';

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
              trailing: GestureDetector(
                onTap: () => context.push(AppRoutes.customerAddVehicle),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.s12,
                    vertical: AppDimensions.s8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(AppDimensions.r10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: AppColors.primary, size: 16),
                      SizedBox(width: AppDimensions.s4),
                      Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.s18,
                  AppDimensions.s18,
                  AppDimensions.s18,
                  AppDimensions.s32,
                ),
                child: Column(
                  children: [
                    ...vehicles.map(
                      (v) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.s16,
                        ),
                        child: _VehicleCard(vehicle: v),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.s20,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.r14,
                          ),
                          border: Border.all(
                            color: AppColors.borderMd,
                            width: 1.5,
                          ),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.add_circle_outline_rounded,
                              color: AppColors.text4,
                              size: 28,
                            ),
                            SizedBox(height: AppDimensions.s8),
                            Text(
                              'Add new vehicle',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.text3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Color get _scoreColor => vehicle.healthScore >= 80
      ? AppColors.success
      : vehicle.healthScore >= 60
      ? AppColors.warning
      : AppColors.danger;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.s16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(AppDimensions.r12),
                  ),
                  child: const Icon(
                    Icons.directions_car_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppDimensions.s14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.s4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.s8,
                              vertical: AppDimensions.s4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.textPrimary.withValues(
                                alpha: .08,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.r6,
                              ),
                            ),
                            child: Text(
                              vehicle.plateNumber,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text2,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.s8),
                          Text(
                            '${vehicle.year}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.text3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 46,
                  height: 46,
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
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _scoreColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          Padding(
            padding: const EdgeInsets.all(AppDimensions.s14),
            child: Column(
              children: [
                Row(
                  children: [
                    _InfoTile(
                      icon: Icons.speed_rounded,
                      label: 'Mileage',
                      value: vehicle.mileage,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppDimensions.s10),
                    _InfoTile(
                      icon: Icons.palette_outlined,
                      label: 'Color',
                      value: vehicle.color,
                      color: AppColors.info,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.s10),
                Row(
                  children: [
                    _InfoTile(
                      icon: Icons.history_rounded,
                      label: 'Last service',
                      value: vehicle.lastService,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: AppDimensions.s10),
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
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        context.push(AppRoutes.customerBookService),
                    icon: const Icon(Icons.calendar_month_rounded, size: 15),
                    label: const Text('Book Service'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.s12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.r10),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.s10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.history_rounded, size: 15),
                    label: const Text('History'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primaryBorder),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.s12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.r10),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
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
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(AppDimensions.s12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(AppDimensions.r10),
        border: Border.all(color: color.withValues(alpha: .15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: AppDimensions.s8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: AppColors.text3),
                ),
                const SizedBox(height: AppDimensions.s4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
