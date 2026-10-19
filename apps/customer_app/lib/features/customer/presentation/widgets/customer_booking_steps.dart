import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/support/customer_bookings_presentation.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_notice_panel.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_plate_chip.dart';

/// Step 1: which registered vehicle the workshop will receive.
///
/// Same contract as before (garage list + quick-add that returns the saved
/// vehicle), recomposed as selectable art rows with radio semantics instead
/// of plain list tiles.
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
    final t = context.cx;
    if (loading && vehicles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vehicles.isEmpty) {
      return _EmptyBlock(
        icon: Icons.directions_car_outlined,
        title: t.wizGarageEmptyTitle,
        body: t.wizGarageEmptyBody,
        actionLabel: t.wizAddVehicle,
        onAction: onAddVehicle,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < vehicles.length; i++) ...[
          _VehicleCard(
            vehicle: vehicles[i],
            selected: selected?.id == vehicles[i].id,
            onTap: () => onSelect(vehicles[i]),
          ),
          if (i < vehicles.length - 1)
            const SizedBox(height: AppDimensions.s12),
        ],
        const SizedBox(height: AppDimensions.s12),
        OutlinedButton.icon(
          onPressed: onAddVehicle,
          icon: const Icon(Icons.add_rounded),
          label: Text(t.wizAddVehicle),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(AppDimensions.touchTarget),
          ),
        ),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final CustomerVehicleEntity vehicle;
  final bool selected;
  final VoidCallback onTap;

  const _VehicleCard({
    required this.vehicle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final specs = [
      if (vehicle.year > 0) vehicle.year.toString(),
      if (vehicle.color.trim().isNotEmpty) vehicle.color.trim(),
      if (vehicle.mileage.trim().isNotEmpty) vehicle.mileage.trim(),
    ];
    final name = vehicle.displayName.trim().isEmpty
        ? 'Your vehicle'
        : vehicle.displayName;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.s12),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.08)
              : colors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 72,
              height: 45,
              child: VehicleSilhouetteArt(),
            ),
            const SizedBox(width: AppDimensions.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (vehicle.plateNumber.trim().isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.s4),
                    CustomerPlateChip(plate: vehicle.plateNumber.trim()),
                  ],
                  if (specs.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.s4),
                    Text(
                      specs.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.s8),
            Semantics(
              selected: selected,
              child: Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Step 2: multi-select service packages with upfront AED prices.
///
/// The catalogue rows keep their exact `price · duration` contract; tapping
/// toggles membership in [selectedIds]. Totals are composed by the caller.
class CustomerBookingServiceStep extends StatelessWidget {
  final List<ServiceTypeResponse> services;
  final bool loading;
  final String error;
  final Set<String> selectedIds;
  final ValueChanged<ServiceTypeResponse> onToggle;
  final VoidCallback onRetry;

  const CustomerBookingServiceStep({
    super.key,
    required this.services,
    required this.loading,
    required this.error,
    required this.selectedIds,
    required this.onToggle,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    if (loading) {
      return Column(
        children: [
          for (var i = 0; i < 3; i++) ...[
            AppSkeleton.card(height: 76),
            const SizedBox(height: AppDimensions.s12),
          ],
        ],
      );
    }
    if (error.isNotEmpty) {
      return CustomerNoticePanel(
        message: error,
        actionLabel: t.wizRetryServices,
        onAction: onRetry,
      );
    }
    if (services.isEmpty) {
      return _EmptyBlock(
        icon: Icons.build_outlined,
        title: t.wizNoServicesTitle,
        body: t.wizNoServicesBody,
        actionLabel: t.wizRetryServices,
        onAction: onRetry,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < services.length; i++) ...[
          _ServiceCard(
            service: services[i],
            selected: selectedIds.contains(services[i].id),
            onTap: () => onToggle(services[i]),
          ),
          if (i < services.length - 1)
            const SizedBox(height: AppDimensions.s12),
        ],
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceTypeResponse service;
  final bool selected;
  final VoidCallback onTap;

  const _ServiceCard({
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
    final meta = [price, duration].where((s) => s.isNotEmpty).join(' · ');
    final name = service.name.trim().isEmpty ? 'Service' : service.name;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.s12),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.08)
              : colors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Icon(
                Icons.build_rounded,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: AppDimensions.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.s4),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.mono(
                          color: colors.onSurfaceVariant,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.s8),
            Semantics(
              selected: selected,
              child: Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.add_circle_outline_rounded,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Step 3: a real day from the diary, then that day's real slots grouped
/// into morning / afternoon. Nothing renders that the workshop did not
/// publish; an empty day says so plainly.
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

  static bool _sameDay(DateTime a, DateTime? b) =>
      b != null && a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final morning = <String>[];
    final afternoon = <String>[];
    for (final slot in slots) {
      final minutes = CustomerBookingsPresentation.minutesOfDay(slot);
      if (minutes != null && minutes >= 12 * 60) {
        afternoon.add(slot);
      } else {
        morning.add(slot);
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.wizChooseDate,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppDimensions.s8),
        SizedBox(
          // Grows with text scale so the three-line chip never overflows.
          height: MediaQuery.textScalerOf(context).scale(76),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: AppDimensions.s8),
            itemBuilder: (context, index) => _DateChip(
              date: dates[index],
              selected: _sameDay(dates[index], selectedDate),
              onTap: () => onSelectDate(dates[index]),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.s16),
        if (selectedDate == null)
          _HintLine(text: t.wizNoDateBody)
        else if (loadingSlots)
          Column(
            children: [
              AppSkeleton.card(height: 44),
              const SizedBox(height: AppDimensions.s8),
              AppSkeleton.card(height: 44),
            ],
          )
        else if (slotsError.isNotEmpty)
          CustomerNoticePanel(
            message: slotsError,
            actionLabel: t.wizRetryTimes,
            onAction: onRetrySlots,
          )
        else if (slots.isEmpty)
          _EmptyBlock(
            icon: Icons.event_busy_outlined,
            title: t.wizNoTimesTitle,
            body: t.wizNoTimesBody,
            actionLabel: null,
            onAction: null,
          )
        else ...[
          Text(
            '${t.wizTimesFor} · ${CustomerBookingsPresentation.dateLabel(CustomerBookingsPresentation.isoDate(selectedDate!))}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (morning.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s8),
            _SlotGroup(
              label: t.wizMorning,
              slots: morning,
              selectedSlot: selectedSlot,
              onSelectSlot: onSelectSlot,
            ),
          ],
          if (afternoon.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s12),
            _SlotGroup(
              label: t.wizAfternoon,
              slots: afternoon,
              selectedSlot: selectedSlot,
              onSelectSlot: onSelectSlot,
            ),
          ],
        ],
      ],
    );
  }
}

class _SlotGroup extends StatelessWidget {
  final String label;
  final List<String> slots;
  final String? selectedSlot;
  final ValueChanged<String> onSelectSlot;

  const _SlotGroup({
    required this.label,
    required this.slots,
    required this.selectedSlot,
    required this.onSelectSlot,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppDimensions.s8),
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
    );
  }
}

class _DateChip extends StatelessWidget {
  final DateTime date;
  final bool selected;
  final VoidCallback onTap;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  const _DateChip({
    required this.date,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.s8),
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: selected ? colors.primary : colors.outlineVariant,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _weekdays[date.weekday - 1],
              style: theme.textTheme.labelSmall?.copyWith(
                color: selected ? colors.onPrimary : colors.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
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
              ),
            ),
          ],
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.s16,
          vertical: AppDimensions.s12,
        ),
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          border: Border.all(
            color: selected ? colors.primary : colors.outlineVariant,
          ),
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            CustomerBookingsPresentation.timeLabel(slot),
            style: theme.textTheme.labelLarge?.copyWith(
              color: selected ? colors.onPrimary : colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// Step 4: how the car reaches the workshop, plus the workshop note.
///
/// Self drop-off needs nothing more. Valet reveals the pick-up address,
/// which is required while valet is chosen; the choice travels inside the
/// existing free-text notes field (no new payload keys — the backend
/// rejects unknown keys).
class CustomerBookingDropoffStep extends StatelessWidget {
  final bool valet;
  final ValueChanged<bool> onValetChanged;
  final TextEditingController addressCtrl;
  final TextEditingController notesCtrl;

  const CustomerBookingDropoffStep({
    super.key,
    required this.valet,
    required this.onValetChanged,
    required this.addressCtrl,
    required this.notesCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DropoffCard(
          icon: Icons.storefront_outlined,
          title: t.wizSelfTitle,
          body: t.wizSelfBody,
          selected: !valet,
          onTap: () => onValetChanged(false),
        ),
        const SizedBox(height: AppDimensions.s12),
        _DropoffCard(
          icon: Icons.delivery_dining_outlined,
          title: t.wizValetTitle,
          body: t.wizValetBody,
          selected: valet,
          onTap: () => onValetChanged(true),
        ),
        if (valet) ...[
          const SizedBox(height: AppDimensions.s12),
          TextField(
            controller: addressCtrl,
            textInputAction: TextInputAction.done,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: t.wizAddressLabel,
              hintText: t.wizAddressHint,
              prefixIcon: const Icon(Icons.location_on_outlined),
            ),
          ),
        ],
        const SizedBox(height: AppDimensions.s16),
        TextField(
          controller: notesCtrl,
          maxLines: 3,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            labelText: t.wizNotesLabel,
            hintText: t.wizNotesHint,
          ),
        ),
      ],
    );
  }
}

class _DropoffCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final bool selected;
  final VoidCallback onTap;

  const _DropoffCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.s16),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.08)
              : colors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Icon(icon, color: colors.primary),
            ),
            const SizedBox(width: AppDimensions.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.s4),
                  Text(
                    body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.s8),
            Semantics(
              selected: selected,
              child: Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyBlock({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.s20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: colors.onSurfaceVariant),
          const SizedBox(height: AppDimensions.s12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimensions.s4),
          Text(
            body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppDimensions.s12),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _HintLine extends StatelessWidget {
  final String text;

  const _HintLine({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppDimensions.s8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
