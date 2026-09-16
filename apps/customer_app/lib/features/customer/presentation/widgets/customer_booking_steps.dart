import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/support/customer_bookings_presentation.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_notice_panel.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_skeleton.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_plate_chip.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_surface_panel.dart';

/// Step 1 — which registered vehicle is being booked.
///
/// Real garage records only: name, plate and the genuine secondary details the
/// vehicle itself carries. No photography, no invented specifications.
class CustomerBookingVehicleStep extends StatelessWidget {
  final List<CustomerVehicleEntity> vehicles;
  final bool loading;
  final CustomerVehicleEntity? selected;
  final ValueChanged<CustomerVehicleEntity> onSelect;
  final VoidCallback onAddVehicle;

  const CustomerBookingVehicleStep({
    super.key,
    required this.vehicles,
    required this.loading,
    required this.selected,
    required this.onSelect,
    required this.onAddVehicle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (loading && vehicles.isEmpty) {
      return const CustomerSurfacePanel(
        accent: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppDimensions.s24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (vehicles.isEmpty) {
      return CustomerSurfacePanel(
        accent: colors.onSurfaceVariant,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'No vehicle yet',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.s4),
            Text(
              'A booking needs a registered vehicle so the workshop knows what '
              'to service.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppDimensions.s16),
            FilledButton.icon(
              onPressed: onAddVehicle,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add your vehicle'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            children: [
              for (var index = 0; index < vehicles.length; index++) ...[
                _VehicleRow(
                  vehicle: vehicles[index],
                  selected: selected?.id == vehicles[index].id,
                  onTap: () => onSelect(vehicles[index]),
                ),
                if (index < vehicles.length - 1)
                  Divider(height: 1, color: colors.outlineVariant),
              ],
            ],
          ),
        ),
        if (selected != null) ...[
          const SizedBox(height: AppDimensions.s12),
          Text(
            'Bookings are created for the selected vehicle.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _VehicleRow extends StatelessWidget {
  final CustomerVehicleEntity vehicle;
  final bool selected;
  final VoidCallback onTap;

  const _VehicleRow({
    required this.vehicle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    // Genuine vehicle details only — whatever the garage record actually holds.
    final specs = <String>[
      if (vehicle.year > 0) '${vehicle.year}',
      if (vehicle.color.trim().isNotEmpty) vehicle.color.trim(),
      if (vehicle.mileage.trim().isNotEmpty) vehicle.mileage.trim(),
    ];
    final name = vehicle.displayName.trim();
    final plate = vehicle.plateNumber.trim();

    return Semantics(
      button: true,
      selected: selected,
      excludeSemantics: true,
      label: [
        name.isEmpty ? 'Vehicle' : name,
        if (plate.isNotEmpty) plate,
        if (specs.isNotEmpty) specs.join(', '),
        if (selected) 'Selected',
      ].join(', '),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: selected ? colors.primary.withValues(alpha: 0.05) : null,
            border: Border(
              left: BorderSide(
                width: 3,
                color: selected ? colors.primary : Colors.transparent,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.s12,
            AppDimensions.s14,
            AppDimensions.s14,
            AppDimensions.s14,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Your vehicle' : name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (plate.isNotEmpty || specs.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.s6),
                      Row(
                        children: [
                          if (plate.isNotEmpty) CustomerPlateChip(plate: plate),
                          if (plate.isNotEmpty && specs.isNotEmpty)
                            const SizedBox(width: AppDimensions.s8),
                          if (specs.isNotEmpty)
                            Expanded(
                              child: Text(
                                specs.join(' \u00b7 '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.s8),
              // Selection is signalled by the tick, the tint and the left rule,
              // so colour is never the only indicator.
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 22,
                color: selected ? colors.primary : colors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Step 2 — which real service is being requested.
///
/// The catalogue comes from the workshop's own `service_types` records; price
/// and duration are shown exactly as the backend states them, and omitted when
/// the backend does not state them.
class CustomerBookingServiceStep extends StatelessWidget {
  final List<ServiceTypeResponse> services;
  final bool loading;
  final String error;
  final String? selectedId;
  final ValueChanged<ServiceTypeResponse> onSelect;
  final VoidCallback onRetry;

  const CustomerBookingServiceStep({
    super.key,
    required this.services,
    required this.loading,
    required this.error,
    required this.selectedId,
    required this.onSelect,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (loading) {
      return const _StepSkeleton(rows: 4);
    }

    if (error.isNotEmpty) {
      return CustomerNoticePanel(
        message: error,
        actionLabel: 'Retry services',
        onAction: onRetry,
      );
    }

    if (services.isEmpty) {
      return CustomerSurfacePanel(
        accent: colors.onSurfaceVariant,
        child: Text(
          'No services are available to book right now. Please try again '
          'shortly.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          for (var index = 0; index < services.length; index++) ...[
            _ServiceRow(
              service: services[index],
              selected: selectedId == services[index].id,
              onTap: () => onSelect(services[index]),
            ),
            if (index < services.length - 1)
              Divider(height: 1, color: colors.outlineVariant),
          ],
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final ServiceTypeResponse service;
  final bool selected;
  final VoidCallback onTap;

  const _ServiceRow({
    required this.service,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final price = service.price.trim();
    final duration = service.duration.trim();
    final description = [
      price,
      duration,
    ].where((v) => v.isNotEmpty).join(' \u00b7 ');

    return Semantics(
      button: true,
      selected: selected,
      excludeSemantics: true,
      label: [
        service.name.trim().isEmpty ? 'Service' : service.name.trim(),
        if (description.isNotEmpty) description,
        if (selected) 'Selected',
      ].join(', '),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: selected ? colors.primary.withValues(alpha: 0.05) : null,
            border: Border(
              left: BorderSide(
                width: 3,
                color: selected ? colors.primary : Colors.transparent,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.s12,
            AppDimensions.s14,
            AppDimensions.s14,
            AppDimensions.s14,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name.trim().isEmpty
                          ? 'Service'
                          : service.name.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.s4),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.s8),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 22,
                color: selected ? colors.primary : colors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Step 3 — a real appointment slot.
///
/// Dates come first, then the workshop's genuine availability for the chosen
/// date. Every state the customer can hit is explicit: loading, available,
/// nothing left, and a failure that keeps the chosen date.
class CustomerBookingScheduleStep extends StatelessWidget {
  final List<DateTime> dates;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onSelectDate;
  final List<String> slots;
  final bool loadingSlots;
  final String slotsError;
  final String? selectedSlot;
  final ValueChanged<String> onSelectSlot;
  final VoidCallback onRetrySlots;

  const CustomerBookingScheduleStep({
    super.key,
    required this.dates,
    required this.selectedDate,
    required this.onSelectDate,
    required this.slots,
    required this.loadingSlots,
    required this.slotsError,
    required this.selectedSlot,
    required this.onSelectSlot,
    required this.onRetrySlots,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return CustomerSurfacePanel(
      accent: colors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Choose a date',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.s10),
          SizedBox(
            // Grows with the text scale so the date stack never has to squeeze.
            height: MediaQuery.textScalerOf(context).scale(72),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppDimensions.s8),
              itemBuilder: (context, index) {
                final date = dates[index];
                return _DateChip(
                  date: date,
                  selected: _sameDay(date, selectedDate),
                  onTap: () => onSelectDate(date),
                );
              },
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          Divider(height: 1, color: colors.outlineVariant),
          const SizedBox(height: AppDimensions.s14),
          Text(
            selectedDate == null
                ? 'Available times'
                : 'Available times \u00b7 '
                      '${CustomerBookingsPresentation.dateLabel(CustomerBookingsPresentation.isoDate(selectedDate!))}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.s10),
          if (selectedDate == null)
            Text(
              'Choose a date to see the times the workshop has free.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            )
          else if (loadingSlots)
            const _StepSkeleton(rows: 2)
          else if (slotsError.isNotEmpty)
            CustomerNoticePanel(
              message: slotsError,
              actionLabel: 'Retry times',
              onAction: onRetrySlots,
            )
          else if (slots.isEmpty)
            Text(
              'No times available on this date. Choose another date.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            )
          else
            Wrap(
              spacing: AppDimensions.s8,
              runSpacing: AppDimensions.s8,
              children: [
                for (final slot in slots)
                  _SlotChip(
                    slot: slot,
                    selected: slot == selectedSlot,
                    onTap: () => onSelectSlot(slot),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime? b) =>
      b != null && a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DateChip extends StatelessWidget {
  final DateTime date;
  final bool selected;
  final VoidCallback onTap;

  const _DateChip({
    required this.date,
    required this.selected,
    required this.onTap,
  });

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final label =
        '${_weekdays[date.weekday - 1]} ${date.day} ${_months[date.month - 1]}';

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        child: Container(
          width: 62,
          decoration: BoxDecoration(
            color: selected ? colors.primary : colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
            border: Border.all(
              color: selected ? colors.primary : colors.outlineVariant,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Day and month only: the full date (with its weekday) is stated
              // above the times, and two lines stay readable at any text scale.
              Text(
                '${date.day}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: selected ? colors.onPrimary : colors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                _months[date.month - 1],
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected ? colors.onPrimary : colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  final String slot;
  final bool selected;
  final VoidCallback onTap;

  const _SlotChip({
    required this.slot,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final label = CustomerBookingsPresentation.timeLabel(slot);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        child: Container(
          // Compact pill that still keeps a 48px touch target.
          constraints: const BoxConstraints(
            minWidth: 84,
            minHeight: AppDimensions.touchTarget,
            maxHeight: AppDimensions.touchTarget,
            maxWidth: 120,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s14),
          decoration: BoxDecoration(
            color: selected ? colors.primary : colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            border: Border.all(
              color: selected ? colors.primary : colors.outlineVariant,
            ),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: selected ? colors.onPrimary : colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

/// Step 4 — exactly what is about to be submitted.
class CustomerBookingReviewStep extends StatelessWidget {
  final CustomerVehicleEntity? vehicle;
  final ServiceTypeResponse? service;
  final DateTime? date;
  final String? time;
  final TextEditingController notes;
  final ValueChanged<int> onChangeStep;

  const CustomerBookingReviewStep({
    super.key,
    required this.vehicle,
    required this.service,
    required this.date,
    required this.time,
    required this.notes,
    required this.onChangeStep,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final schedule = date == null
        ? ''
        : CustomerBookingsPresentation.scheduleLabel(
            CustomerBookingsPresentation.isoDate(date!),
            time ?? '',
          );
    final specs = <String>[
      if (vehicle != null && vehicle!.year > 0) '${vehicle!.year}',
      if (vehicle != null && vehicle!.color.trim().isNotEmpty)
        vehicle!.color.trim(),
      if (vehicle != null && vehicle!.mileage.trim().isNotEmpty)
        vehicle!.mileage.trim(),
    ];
    final price = service?.price.trim() ?? '';
    final duration = service?.duration.trim() ?? '';
    final serviceMeta = [
      price,
      duration,
    ].where((value) => value.isNotEmpty).join(' \u00b7 ');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ReviewSection(
            title: 'Your vehicle',
            onChange: () => onChangeStep(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle?.displayName.trim().isNotEmpty == true
                      ? vehicle!.displayName.trim()
                      : 'Not selected',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (vehicle != null &&
                    vehicle!.plateNumber.trim().isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.s6),
                  CustomerPlateChip(plate: vehicle!.plateNumber.trim()),
                ],
                if (specs.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.s6),
                  Text(
                    specs.join(' \u00b7 '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: colors.outlineVariant),
          _ReviewSection(
            title: 'Service',
            onChange: () => onChangeStep(1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service?.name.trim().isNotEmpty == true
                      ? service!.name.trim()
                      : 'Not selected',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (serviceMeta.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.s4),
                  Text(
                    serviceMeta,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: colors.outlineVariant),
          _ReviewSection(
            title: 'Appointment',
            onChange: () => onChangeStep(2),
            child: Text(
              schedule.isEmpty ? 'Not selected' : schedule,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Divider(height: 1, color: colors.outlineVariant),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.s14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Notes for the workshop',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimensions.s8),
                TextField(
                  controller: notes,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    hintText: 'Optional — e.g. noise when braking',
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

class _ReviewSection extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onChange;

  const _ReviewSection({
    required this.title,
    required this.child,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.s14,
        AppDimensions.s12,
        AppDimensions.s8,
        AppDimensions.s12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: AppDimensions.s6),
                child,
              ],
            ),
          ),
          TextButton(onPressed: onChange, child: const Text('Change')),
        ],
      ),
    );
  }
}

/// Small inline placeholder used while one section is still loading.
class _StepSkeleton extends StatelessWidget {
  final int rows;

  const _StepSkeleton({required this.rows});

  @override
  Widget build(BuildContext context) {
    return CustomerSkeleton(
      builder: (context, block) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var row = 0; row < rows; row++) ...[
            CustomerSkeletonBox(
              height: 56,
              color: block,
              radius: AppDimensions.radiusControl,
            ),
            if (row < rows - 1) const SizedBox(height: AppDimensions.s8),
          ],
        ],
      ),
    );
  }
}
