import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/data/datasources/customer_remote_datasource.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_vehicle_card.dart';

class CustomerVehiclesTab extends ConsumerWidget {
  const CustomerVehiclesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(customerDashboardProvider).vehicles;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: vehicles.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Text('My Vehicles', style: AppTextStyles.rajdhaniTitle(color: AppColors.textPrimary)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.customerAddVehicle),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, size: 16, color: AppColors.accent),
                          SizedBox(width: 4),
                          Text('Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          final v = vehicles[i - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _VehicleCardWithActions(vehicle: v, ref: ref),
          );
        },
      ),
    );
  }
}

class _VehicleCardWithActions extends StatelessWidget {
  final CustomerVehicleEntity vehicle;
  final WidgetRef ref;
  const _VehicleCardWithActions({required this.vehicle, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomerVehicleCard(vehicle: vehicle),
        Positioned(
          top: 12, right: 12,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionBtn(
                icon: Icons.edit_outlined,
                color: AppColors.info,
                onTap: () => context.push(AppRoutes.customerEditVehicle(vehicle.id)),
              ),
              const SizedBox(width: 6),
              _ActionBtn(
                icon: Icons.delete_outline_rounded,
                color: AppColors.danger,
                onTap: () => _confirmDelete(context, vehicle, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, CustomerVehicleEntity v, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Vehicle', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Remove ${v.displayName} (${v.plateNumber})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _delete(context, v, ref);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(BuildContext context, CustomerVehicleEntity v, WidgetRef ref) async {
    try {
      final remote = ref.read(customerRemoteDataSourceProvider);
      await remote.deleteVehicle(v.id);
    } catch (_) {
      final local = GenericLocalDataSource(Hive.box<dynamic>('customer_cache'));
      await local.save('vehicle_${v.id}_deleted', {'id': v.id, 'deleted': true});
      final queue = ref.read(syncQueueProvider);
      await queue.enqueue(SyncOperation(
        id: v.id, entityType: 'vehicle', entityId: v.id,
        changeType: ChangeType.delete, payload: {'id': v.id},
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    }
    ref.read(customerDashboardProvider.notifier).removeVehicle(v.id);
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
