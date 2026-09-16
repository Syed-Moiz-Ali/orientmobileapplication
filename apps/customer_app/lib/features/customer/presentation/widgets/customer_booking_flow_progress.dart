import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/support/customer_bookings_presentation.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_plate_chip.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_surface_panel.dart';

/// Compact progress for the booking flow: where the customer is, and how much
/// is left. Deliberately small — a booking is four short decisions, not a
/// dashboard.
class CustomerBookingProgress extends StatelessWidget {
  final int currentStep;
  final List<String> labels;

  const CustomerBookingProgress({
    super.key,
    required this.currentStep,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final total = labels.length;
    final index = currentStep.clamp(0, total - 1);

    return Semantics(
      label: 'Step ${index + 1} of $total, ${labels[index]}',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Step ${index + 1} of $total',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(width: AppDimensions.s8),
              Expanded(
                child: Text(
                  labels[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s8),
          Row(
            children: [
              for (var step = 0; step < total; step++)
                Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(
                      right: step < total - 1 ? AppDimensions.s6 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: step <= index
                          ? colors.primary
                          : colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppDimensions.rPill),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Live summary of the booking being built.
///
/// On wide screens it stays beside the steps so the customer never has to
/// remember earlier choices; every row that has a selection can jump straight
/// back to the step that owns it.
class CustomerBookingSummaryPanel extends StatelessWidget {
  final CustomerVehicleEntity? vehicle;
  final ServiceTypeResponse? service;
  final DateTime? date;
  final String? time;
  final ValueChanged<int> onChangeStep;
  final List<String> stepLabels;

  const CustomerBookingSummaryPanel({
    super.key,
    required this.vehicle,
    required this.service,
    required this.date,
    required this.time,
    required this.onChangeStep,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selected = vehicle != null || service != null || date != null;
    final schedule = date == null
        ? ''
        : CustomerBookingsPresentation.scheduleLabel(
            CustomerBookingsPresentation.isoDate(date!),
            time ?? '',
          );

    return CustomerSurfacePanel(
      accent: colors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your booking',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimensions.s12),
          if (!selected)
            Text(
              'Nothing selected yet. Your vehicle, service and appointment '
              'appear here as you choose them.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            )
          else ...[
            if (vehicle != null)
              _SummaryEntry(
                label: 'Vehicle',
                value: vehicle!.displayName,
                trailing: vehicle!.plateNumber,
                onChange: () => onChangeStep(0),
              ),
            if (service != null) ...[
              if (vehicle != null) const SizedBox(height: AppDimensions.s10),
              _SummaryEntry(
                label: 'Service',
                value: service!.name,
                onChange: () => onChangeStep(1),
              ),
            ],
            if (schedule.isNotEmpty) ...[
              if (vehicle != null || service != null)
                const SizedBox(height: AppDimensions.s10),
              _SummaryEntry(
                label: 'Appointment',
                value: schedule,
                onChange: () => onChangeStep(2),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _SummaryEntry extends StatelessWidget {
  final String label;
  final String value;
  final String? trailing;
  final VoidCallback onChange;

  const _SummaryEntry({
    required this.label,
    required this.value,
    required this.onChange,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppDimensions.r2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (trailing != null && trailing!.trim().isNotEmpty) ...[
                const SizedBox(height: AppDimensions.s4),
                CustomerPlateChip(plate: trailing!.trim()),
              ],
            ],
          ),
        ),
        TextButton(
          onPressed: onChange,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s8),
          ),
          child: const Text('Change'),
        ),
      ],
    );
  }
}
