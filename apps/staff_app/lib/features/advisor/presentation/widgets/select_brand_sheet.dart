import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/data/models/vehicle_customer_model.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Searchable brand picker for the intake flow.
///
/// Delegates to the shared [AppSelectionSheet] (bottom sheet on compact
/// widths, bounded centered dialog at ≥600 px) instead of maintaining an
/// app-local sheet duplicate. Pops with the selected brand — the return
/// contract callers rely on is unchanged.
class SelectBrandSheet extends StatelessWidget {
  final String? selected;
  const SelectBrandSheet({super.key, this.selected});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    return AppSelectionSheet<String>(
      title: t.advisorIntakeMakeHint,
      selected: selected,
      options: [
        for (final brand in kCarBrands)
          AppSelectionOption<String>(value: brand, label: brand),
      ],
    );
  }
}

/// Searchable model picker for the selected brand. Pops with the chosen
/// model (unchanged return contract).
class SelectModelSheet extends StatelessWidget {
  final String brand;
  final String? selected;

  const SelectModelSheet({super.key, required this.brand, this.selected});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    return AppSelectionSheet<String>(
      title: t.advisorIntakeModelHint,
      selected: selected,
      options: [
        for (final model in modelsForBrand(brand))
          AppSelectionOption<String>(
            value: model,
            label: model,
            subtitle: brand,
          ),
      ],
    );
  }
}

/// Opens the shared selection surface (bottom sheet on compact, centered
/// dialog on ≥600 px) and returns the chosen brand.
Future<String?> showSelectBrandSheet({
  required BuildContext context,
  String? selected,
}) {
  final t = StaffLocalizations.of(context)!;
  return showAppSelectionSheet<String>(
    context: context,
    title: t.advisorIntakeMakeHint,
    selected: selected,
    options: [
      for (final brand in kCarBrands)
        AppSelectionOption<String>(value: brand, label: brand),
    ],
  );
}

/// Opens the shared selection surface and returns the chosen model for
/// [brand]. The empty state is the shared localized "no matches" view, so a
/// brand without models never dead-ends.
Future<String?> showSelectModelSheet({
  required BuildContext context,
  required String brand,
  String? selected,
}) {
  final t = StaffLocalizations.of(context)!;
  return showAppSelectionSheet<String>(
    context: context,
    title: t.advisorIntakeModelHint,
    selected: selected,
    options: [
      for (final model in modelsForBrand(brand))
        AppSelectionOption<String>(
          value: model,
          label: model,
          subtitle: brand,
        ),
    ],
  );
}

/// Legacy dead UI retained for Phase 08 removal. Kept compiling and tokenized.
class CustomerTagSheet extends StatefulWidget {
  final List<String> selected;
  const CustomerTagSheet({super.key, required this.selected});

  @override
  State<CustomerTagSheet> createState() => _CustomerTagSheetState();
}

class _CustomerTagSheetState extends State<CustomerTagSheet> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.s16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusSheet),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Select Customer Tag',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(_selected),
                icon: Icon(Icons.close_rounded, color: colors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s16),
          ...kCustomerTags.map((tag) {
            final isSelected = _selected.contains(tag.label);
            return Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.s10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: tag.color),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
                    ),
                    child: Text(
                      tag.label,
                      style: TextStyle(
                        color: tag.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  trailing: InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selected.remove(tag.label);
                        } else {
                          _selected.add(tag.label);
                        }
                      });
                    },
                    child: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isSelected ? colors.primary : colors.outline,
                    ),
                  ),
                ),
                const Divider(height: 1),
              ],
            );
          }),
          const SizedBox(height: AppDimensions.s40),
        ],
      ),
    );
  }
}

/// Model-year picker on the shared selection surface (bottom sheet on
/// compact, centered dialog on ≥600 px). Same signature and return contract
/// as the bespoke dialog it replaces.
Future<String?> showModelYearDialog(
  BuildContext context,
  String? current,
) async {
  final t = StaffLocalizations.of(context)!;
  return showAppSelectionSheet<String>(
    context: context,
    title: t.advisorIntakeModelYearHint,
    selected: current,
    options: [
      for (final year in kModelYears)
        AppSelectionOption<String>(value: year, label: year),
    ],
  );
}
