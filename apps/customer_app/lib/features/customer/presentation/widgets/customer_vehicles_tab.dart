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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 88),
        child: FloatingActionButton.extended(
          heroTag: 'customer-vehicles-add-vehicle-fab',
          onPressed: () => context.push(AppRoutes.customerAddVehicle),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 4,
          icon: Icon(Icons.add_rounded, color: colorScheme.onPrimary),
          label: Text(
            'Add Vehicle',
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onPrimary,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(customerDashboardProvider.notifier).refresh();
          },
          color: colorScheme.primary,
          child: AppResponsivePage(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── 1. PREMIUM HEADER ──────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Garage',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.headlineMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage registered cars and upcoming services',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
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
                              color: colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.outlineVariant,
                              ),
                            ),
                            child: Icon(
                              Icons.notifications_outlined,
                              color: colorScheme.onSurface,
                              size: 24,
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
                                  color: colorScheme.error,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: colorScheme.surface,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  dash.unreadCount > 99
                                      ? '99+'
                                      : '${dash.unreadCount}',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onError,
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
                const SizedBox(height: 36),

                // ── 2. VEHICLES SHOWCASE DECK (FULL STACK IMAGES) ──────────────
                if (vehicles.isEmpty)
                  EmptyVehiclesCard(
                    onAddVehicle: () =>
                        context.push(AppRoutes.customerAddVehicle),
                  )
                else ...[
                  // _ExplanatorySectionHeader(
                  //   title: 'Your Registered Vehicles (${vehicles.length})',
                  //   subtitle: 'Tap any car to book a service or edit details',
                  // ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      for (int i = 0; i < vehicles.length; i++) ...[
                        _VehicleCardWithActions(
                          vehicle: vehicles[i],
                          ref: ref,
                          imageUrl: i % 2 == 0
                              ? 'https://images.unsplash.com/photo-1550355291-bbee04a92027?q=80&w=800&auto=format&fit=crop'
                              : 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?q=80&w=800&auto=format&fit=crop',
                        ),
                        if (i != vehicles.length - 1)
                          const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 100), // Extended FAB Padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── PREMIUM VEHICLE HERO CARD (FULL STACK WITH GRADIENT) ────────────────────
class _VehicleCardWithActions extends StatelessWidget {
  final CustomerVehicleEntity vehicle;
  final WidgetRef ref;
  final String imageUrl;

  const _VehicleCardWithActions({
    required this.vehicle,
    required this.ref,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      height: 280, // Taller to let the image breathe
      borderRadius: 24,
      padding: EdgeInsets.zero,
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full Background Image
          Image.network(imageUrl, fit: BoxFit.cover),

          // 2. Heavy Dark Gradient (Fades up from bottom for text clarity)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                  Colors.black.withValues(alpha: 0.95),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.3, 0.7, 1.0],
              ),
            ),
          ),

          // 3. Content Overlay
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plate Number Chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFFACC15,
                    ), // High Contrast Yellow Plate
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    vehicle.plateNumber.toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Vehicle Name
                Text(
                  vehicle.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),

                // Details (Mileage & MOT)
                Text(
                  '${vehicle.mileage.isNotEmpty ? vehicle.mileage : "No mileage"} • ${vehicle.nextDue.isNotEmpty ? "MOT Due: ${vehicle.nextDue}" : "MOT OK"}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                // Actions Row
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            context.push(AppRoutes.customerBookService),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              'Book Service',
                              style: textTheme.titleSmall?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _GlassActionButton(
                      icon: Icons.edit_outlined,
                      onTap: () => context.push(
                        AppRoutes.customerEditVehicle(vehicle.id),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _GlassActionButton(
                      icon: Icons.delete_outline_rounded,
                      isDanger: true,
                      onTap: () =>
                          _confirmDelete(context, vehicle, ref, colorScheme),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    CustomerVehicleEntity v,
    WidgetRef ref,
    ColorScheme colorScheme,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Remove ${v.displayName}?'),
        content: const Text(
          'This will remove the vehicle from your garage. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final removed = await ref
                  .read(customerDashboardProvider.notifier)
                  .removeVehicle(v.id);
              if (!removed && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not remove this vehicle.'),
                  ),
                );
              }
            },
            child: Text(
              'Remove',
              style: TextStyle(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── GLASSMORPHIC ACTION BUTTON ──────────────────────────────────────────────
class _GlassActionButton extends StatelessWidget {
  final IconData icon;
  final bool isDanger;
  final VoidCallback onTap;

  const _GlassActionButton({
    required this.icon,
    this.isDanger = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDanger
              ? const Color(0xFFEF4444).withValues(
                  alpha: 0.2,
                ) // Danger red with opacity
              : Colors.white.withValues(alpha: 0.15), // Glass white
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDanger
                ? const Color(0xFFEF4444).withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Icon(
          icon,
          size: 22,
          color: isDanger ? const Color(0xFFEF4444) : Colors.white,
        ),
      ),
    );
  }
}

// // ─── EXPLANATORY SECTION HEADER ──────────────────────────────────────────────
// class _ExplanatorySectionHeader extends StatelessWidget {
//   final String title;
//   final String subtitle;

//   const _ExplanatorySectionHeader({required this.title, required this.subtitle});

//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//     final colorScheme = Theme.of(context).colorScheme;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: textTheme.titleLarge?.copyWith(
//             color: colorScheme.onSurface,
//             fontWeight: FontWeight.w900,
//             letterSpacing: -0.4,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(subtitle, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
//       ],
//     );
//   }
// }
