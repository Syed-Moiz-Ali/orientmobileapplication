import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

class CustomerBookServiceTab extends ConsumerWidget {
  const CustomerBookServiceTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerDashboardProvider);
    final notifier = ref.read(customerDashboardProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    return AppResponsivePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Book a Service',
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.s6),
          Text(
            'Choose a vehicle, service type, and preferred workshop date.',
            style: textTheme.bodyLarge?.copyWith(color: AppColors.text3),
          ),
          const SizedBox(height: AppDimensions.s24),
          const SectionHeader(title: 'Select Vehicle'),
          const SizedBox(height: AppDimensions.s10),
          AppAdaptiveGrid(
            minChildWidth: 300,
            childAspectRatio: 3.35,
            children: [
              for (final vehicle in state.vehicles)
                _OptionCard(
                  selected: state.selectedVehicle == vehicle.id,
                  icon: Icons.directions_car_rounded,
                  title: vehicle.displayName,
                  subtitle: '${vehicle.plateNumber} - ${vehicle.year}',
                  onTap: () => notifier.setSelectedVehicle(vehicle.id),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.s24),
          const SectionHeader(title: 'Service Type'),
          const SizedBox(height: AppDimensions.s10),
          AppAdaptiveGrid(
            minChildWidth: 300,
            childAspectRatio: 3.35,
            children: [
              for (final service in notifier.serviceTypes)
                _OptionCard(
                  selected: state.selectedServiceType == service,
                  icon: Icons.build_outlined,
                  title: service,
                  onTap: () => notifier.setSelectedServiceType(service),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.s24),
          const SectionHeader(title: 'Preferred Date'),
          const SizedBox(height: AppDimensions.s10),
          AppCard(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate:
                    state.bookingDate ??
                    DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                notifier.setBookingDate(date);
              }
            },
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.r10),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: AppDimensions.s12),
                Expanded(
                  child: Text(
                    state.bookingDate != null
                        ? '${state.bookingDate!.day}/${state.bookingDate!.month}/${state.bookingDate!.year}'
                        : 'Tap to select date',
                    style: textTheme.titleSmall?.copyWith(
                      color: state.bookingDate != null
                          ? AppColors.textPrimary
                          : AppColors.text3,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.text4),
              ],
            ),
          ),
          if (state.bookingError != null) ...[
            const SizedBox(height: AppDimensions.s14),
            Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 18,
                  color: AppColors.danger,
                ),
                const SizedBox(width: AppDimensions.s8),
                Expanded(
                  child: Text(
                    state.bookingError!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppDimensions.s24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                final ok = await notifier.submitBooking();
                if (ok && context.mounted) {
                  notifier.selectTab(0);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking submitted successfully!'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Submit Booking'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _OptionCard({
    required this.selected,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = selected ? AppColors.accent : AppColors.text3;

    return AppCard(
      onTap: onTap,
      color: selected ? AppColors.cyanLight : AppColors.surface,
      borderColor: selected ? AppColors.accent : AppColors.border,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.accent.withValues(alpha: 0.12)
                  : AppColors.bg,
              borderRadius: BorderRadius.circular(AppDimensions.r10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: selected ? AppColors.accent : AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppDimensions.s4),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.text3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (selected)
            const Icon(Icons.check_circle_rounded, color: AppColors.accent),
        ],
      ),
    );
  }
}
