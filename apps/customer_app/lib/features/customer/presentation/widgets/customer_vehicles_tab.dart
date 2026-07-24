import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_vehicle_card.dart';

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
          child: CustomerVehicleCard(vehicle: v),
        );
      },
    );
  }
}
