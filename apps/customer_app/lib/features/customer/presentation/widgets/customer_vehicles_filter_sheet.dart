import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';

/// The only honest facets the vehicles list can filter on: service context
/// derived via the existing `CustomerVehiclePresentation.contextFor` per
/// vehicle. No make/model/year/colour facets (no honest backing predicate —
/// inventing them would be fake filtering).
enum CustomerVehicleFilter { all, inService, upcoming, completed, none }

/// Opens the vehicles filter sheet (single-select chip group + Show results
/// CTA + Clear). The sheet owns presentation only; context derivation stays
/// in `CustomerVehiclePresentation.contextFor`, untouched.
Future<void> showCustomerVehiclesFilterSheet(
  BuildContext context, {
  required CustomerVehicleFilter selected,
  required ValueChanged<CustomerVehicleFilter> onApply,
}) {
  final t = context.cx;
  return showAppModalSheet<void>(
    context: context,
    title: t.vhFilterTitle,
    builder: (_) => _VehiclesFilterSheet(
      selected: selected,
      onApply: onApply,
    ),
  );
}

class _VehiclesFilterSheet extends StatefulWidget {
  final CustomerVehicleFilter selected;
  final ValueChanged<CustomerVehicleFilter> onApply;

  const _VehiclesFilterSheet({required this.selected, required this.onApply});

  @override
  State<_VehiclesFilterSheet> createState() => _VehiclesFilterSheetState();
}

class _VehiclesFilterSheetState extends State<_VehiclesFilterSheet> {
  late CustomerVehicleFilter _temp;

  @override
  void initState() {
    super.initState();
    _temp = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final options = <CustomerVehicleFilter, String>{
      CustomerVehicleFilter.all: t.vhFilterAll,
      CustomerVehicleFilter.inService: t.vhInService,
      CustomerVehicleFilter.upcoming: t.vhFilterBooked,
      CustomerVehicleFilter.completed: t.vhFilterLastService,
      CustomerVehicleFilter.none: t.vhFilterNone,
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
                  child: Text(t.vhFilterShow),
                ),
              ),
              const SizedBox(width: AppDimensions.s8),
              TextButton(
                onPressed: () {
                  widget.onApply(CustomerVehicleFilter.all);
                  Navigator.of(context).pop();
                },
                child: Text(t.vhFilterClear),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
