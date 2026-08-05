import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Reusable enterprise empty state card with modern design tokens
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.s24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: AppDimensions.s6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.text3,
              height: 1.4,
            ),
          ),
          if (buttonLabel != null && onButtonTap != null) ...[
            const SizedBox(height: AppDimensions.s18),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: onButtonTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.r12),
                  ),
                ),
                child: Text(
                  buttonLabel!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
          if (secondaryButtonLabel != null && onSecondaryButtonTap != null) ...[
            const SizedBox(height: AppDimensions.s8),
            TextButton(
              onPressed: onSecondaryButtonTap,
              child: Text(
                secondaryButtonLabel!,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Fallback for Empty Vehicles list
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
          'Add your vehicle details to easily book services, track job card status, and receive MOT & maintenance reminders.',
      buttonLabel: 'Register Vehicle',
      onButtonTap: onAddVehicle,
    );
  }
}

/// Fallback for Empty Bookings list
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
          'Need oil change, brake check, or full service? Choose a date & time to book your workshop slot.',
      buttonLabel: 'Book Appointment',
      onButtonTap: onBookService,
    );
  }
}

/// Fallback for Empty Invoices
class EmptyInvoicesCard extends StatelessWidget {
  const EmptyInvoicesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomerEmptyStateCard(
      icon: Icons.verified_rounded,
      iconColor: AppColors.success,
      title: 'All Invoices Paid!',
      description:
          'You have no pending payments. Past invoices and service history receipts will appear here.',
    );
  }
}

/// Fallback for Active Service Status when idle
class IdleServiceCard extends StatelessWidget {
  final VoidCallback onBook;
  const IdleServiceCard({super.key, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return CustomerEmptyStateCard(
      icon: Icons.build_circle_rounded,
      iconColor: AppColors.cyan,
      title: 'Vehicle Idle — No Active Service',
      description:
          'Your vehicle is not currently in the workshop. When your car is checked in, live stage updates will appear here in real time.',
      buttonLabel: 'Book Maintenance Service',
      onButtonTap: onBook,
    );
  }
}
