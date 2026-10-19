import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/support/customer_booking_draft.dart';
import 'package:customer_app/features/customer/presentation/support/customer_bookings_presentation.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_plate_chip.dart';

/// The running booking beside (tablet+) or below (compact) the wizard
/// steps: vehicle, services, slot and drop-off lines with Change links, the
/// live total and the trust line. Pure record surface — every value comes
/// from the draft the customer is building.
class CustomerBookingSummaryPanel extends StatelessWidget {
  final CustomerVehicleEntity? vehicle;
  final List<ServiceTypeResponse> services;
  final DateTime? date;
  final String? time;
  final bool valet;
  final ValueChanged<int> onChangeStep;

  const CustomerBookingSummaryPanel({
    super.key,
    required this.vehicle,
    required this.services,
    required this.date,
    required this.time,
    required this.valet,
    required this.onChangeStep,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = context.cx;
    final d = date;
    final schedule = d == null
        ? ''
        : CustomerBookingsPresentation.scheduleLabel(
            CustomerBookingsPresentation.isoDate(d),
            time ?? '',
          );
    final total = CustomerBookingDraft.totalFor(services);
    final names = CustomerBookingDraft.serviceNames(services);
    return Container(
      padding: const EdgeInsets.all(AppDimensions.s16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.wizSummaryTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimensions.s12),
          if (vehicle == null && services.isEmpty && schedule.isEmpty)
            Text(
              t.wizSummaryEmpty,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            )
          else ...[
            _Entry(
              label: t.wizRowVehicle,
              onChange: () => onChangeStep(0),
              changeLabel: t.wizChange,
              child: vehicle == null
                  ? null
                  : Row(
                      children: [
                        if (vehicle!.plateNumber.trim().isNotEmpty) ...[
                          CustomerPlateChip(
                            plate: vehicle!.plateNumber.trim(),
                          ),
                          const SizedBox(width: AppDimensions.s8),
                        ],
                        Expanded(
                          child: Text(
                            vehicle!.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            _Entry(
              label: t.wizRowServices,
              onChange: () => onChangeStep(1),
              changeLabel: t.wizChange,
              child: names.isEmpty
                  ? null
                  : Text(
                      names,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            _Entry(
              label: t.wizRowSlot,
              onChange: () => onChangeStep(2),
              changeLabel: t.wizChange,
              child: schedule.isEmpty
                  ? null
                  : Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        schedule,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
            const Divider(height: AppDimensions.s24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.wizTotal,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    total == null
                        ? (services.isEmpty ? '—' : t.wizTotalPending)
                        : CustomerBookingDraft.formatAed(total),
                    style: AppTextStyles.mono(
                      color: colors.onSurface,
                    ).copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s4),
            Text(
              valet ? t.wizValetTitle : t.wizSelfTitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.s8),
            Text(
              t.wizTrust,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  final String label;
  final Widget? child;
  final VoidCallback onChange;
  final String changeLabel;

  const _Entry({
    required this.label,
    required this.child,
    required this.onChange,
    required this.changeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: onChange,
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(changeLabel),
              ),
            ],
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}
