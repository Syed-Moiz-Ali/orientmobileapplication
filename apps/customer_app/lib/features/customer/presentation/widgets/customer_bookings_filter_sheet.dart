import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';

/// The only honest facets the bookings list can filter on: lifecycle group
/// derived via the existing `CustomerBookingsPresentation.groupOf` per
/// booking. No service/vehicle/date facets (no honest backing predicate —
/// inventing them would be fake filtering).
enum CustomerBookingFilter { all, upcoming, inService, history }

/// Opens the bookings filter sheet (single-select chip group + Show results
/// CTA + Clear). The sheet owns presentation only; group derivation stays in
/// `CustomerBookingsPresentation.groupOf`, untouched.
Future<void> showCustomerBookingsFilterSheet(
  BuildContext context, {
  required CustomerBookingFilter selected,
  required ValueChanged<CustomerBookingFilter> onApply,
}) {
  final t = context.cx;
  return showAppModalSheet<void>(
    context: context,
    title: t.bkFilterTitle,
    builder: (_) => _BookingsFilterSheet(
      selected: selected,
      onApply: onApply,
    ),
  );
}

class _BookingsFilterSheet extends StatefulWidget {
  final CustomerBookingFilter selected;
  final ValueChanged<CustomerBookingFilter> onApply;

  const _BookingsFilterSheet({required this.selected, required this.onApply});

  @override
  State<_BookingsFilterSheet> createState() => _BookingsFilterSheetState();
}

class _BookingsFilterSheetState extends State<_BookingsFilterSheet> {
  late CustomerBookingFilter _temp;

  @override
  void initState() {
    super.initState();
    _temp = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final options = <CustomerBookingFilter, String>{
      CustomerBookingFilter.all: t.bkFilterAll,
      CustomerBookingFilter.upcoming: t.bkFilterUpcoming,
      CustomerBookingFilter.inService: t.bkFilterInService,
      CustomerBookingFilter.history: t.bkFilterHistory,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.xl,
            AppSpacing.xs,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          child: Wrap(
            spacing: AppDimensions.s8,
            runSpacing: AppDimensions.s4,
            children: [
              for (final entry in options.entries)
                AppChip(
                  label: entry.value,
                  selected: _temp == entry.key,
                  onSelected: (_) => setState(() => _temp = entry.key),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    widget.onApply(_temp);
                    Navigator.of(context).pop();
                  },
                  child: Text(t.bkFilterShow),
                ),
              ),
              const SizedBox(width: AppDimensions.s8),
              TextButton(
                onPressed: () {
                  widget.onApply(CustomerBookingFilter.all);
                  Navigator.of(context).pop();
                },
                child: Text(t.bkFilterClear),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
