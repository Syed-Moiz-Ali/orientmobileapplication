import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/core/theme/app_text_styles.dart';
import 'package:orientmobileapplication/features/customer/presentation/widgets/customer_vehicle_card.dart';
import 'package:orientmobileapplication/features/customer/providers/customer_providers.dart';

class CustomerVehiclesTab extends ConsumerWidget {
  const CustomerVehiclesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(customerDashboardProvider).vehicles;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.s16,
        AppDimensions.s12,
        AppDimensions.s16,
        AppDimensions.s32,
      ),
      itemCount: vehicles.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.s16),
            child: Text(
              'My Vehicles',
              style: AppTextStyles.rajdhaniTitle(color: AppColors.textPrimary),
            ),
          );
        }
        final v = vehicles[i - 1];
        return Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.s12),
          child: CustomerVehicleCard(vehicle: v, compact: false),
        );
      },
    );
  }
}
