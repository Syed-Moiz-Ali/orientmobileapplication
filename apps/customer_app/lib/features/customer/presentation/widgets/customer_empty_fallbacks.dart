import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class CustomerEmptyStateCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String? buttonLabel;
  final VoidCallback? onButtonTap;
  final String? secondaryButtonLabel;
  final VoidCallback? onSecondaryButtonTap;

  const CustomerEmptyStateCard({
    super.key,
    required this.icon,
    this.iconColor = AppColors.accent,
    required this.title,
    required this.description,
    this.buttonLabel,
    this.onButtonTap,
    this.secondaryButtonLabel,
    this.onSecondaryButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final adaptive = context.adaptive;

    return AppCard(
      padding: EdgeInsets.all(
        adaptive.pick(compact: AppDimensions.s20, medium: AppDimensions.s24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: iconColor),
          ),
          const SizedBox(height: AppDimensions.s16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.s8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.text3,
              height: 1.4,
            ),
          ),
          if (buttonLabel != null && onButtonTap != null) ...[
            const SizedBox(height: AppDimensions.s20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onButtonTap,
                child: Text(buttonLabel!),
              ),
            ),
          ],
          if (secondaryButtonLabel != null && onSecondaryButtonTap != null) ...[
            const SizedBox(height: AppDimensions.s8),
            TextButton(
              onPressed: onSecondaryButtonTap,
              child: Text(
                secondaryButtonLabel!,
                style: textTheme.labelLarge?.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class EmptyVehiclesCard extends StatelessWidget {
  final VoidCallback onAddVehicle;

  const EmptyVehiclesCard({super.key, required this.onAddVehicle});

  @override
  Widget build(BuildContext context) {
    return CustomerEmptyStateCard(
      icon: Icons.directions_car_filled_rounded,
      iconColor: AppColors.accent,
      title: 'No Vehicles Registered',
      description:
          'Add your vehicle details to book services, track job card status, and receive maintenance reminders.',
      buttonLabel: 'Register Vehicle',
      onButtonTap: onAddVehicle,
    );
  }
}

class EmptyBookingsCard extends StatelessWidget {
  final VoidCallback onBookService;

  const EmptyBookingsCard({super.key, required this.onBookService});

  @override
  Widget build(BuildContext context) {
    return CustomerEmptyStateCard(
      icon: Icons.calendar_month_rounded,
      iconColor: const Color(0xFF1F6FEB),
      title: 'No Upcoming Appointments',
      description:
          'Need an oil change, brake check, or full service? Choose a date and book your workshop slot.',
      buttonLabel: 'Book Appointment',
      onButtonTap: onBookService,
    );
  }
}

class EmptyInvoicesCard extends StatelessWidget {
  const EmptyInvoicesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomerEmptyStateCard(
      icon: Icons.verified_rounded,
      iconColor: AppColors.success,
      title: 'All Invoices Paid',
      description:
          'You have no pending payments. Receipts and history will appear here.',
    );
  }
}

class IdleServiceCard extends StatelessWidget {
  final VoidCallback onBook;

  const IdleServiceCard({super.key, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return CustomerEmptyStateCard(
      icon: Icons.build_circle_rounded,
      iconColor: AppColors.cyan,
      title: 'Vehicle Idle - No Active Service',
      description:
          'Your vehicle is not currently in the workshop. Live updates will appear when it is checked in.',
      buttonLabel: 'Book Maintenance Service',
      onButtonTap: onBook,
    );
  }
}
