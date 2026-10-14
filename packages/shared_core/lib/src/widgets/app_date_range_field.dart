import 'package:flutter/material.dart';
import 'package:shared_core/src/localization/app_formatters.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';
import 'package:shared_core/src/widgets/directional_icon.dart';

/// Single date-range field (Phase 01.2 foundation primitive).
///
/// Displays the selected [value] with locale-aware [AppFormatters] dates
/// (`13 Oct 2026 – 20 Oct 2026`) and opens the Material date-range picker on
/// tap. A clear affordance resets to null. Identifiers and digits stay Latin
/// in both locales; layout mirrors in RTL via directional padding/icons.
class AppDateRangeField extends StatelessWidget {
  final DateTimeRange? value;
  final ValueChanged<DateTimeRange?> onChanged;
  final String? label;
  final bool enabled;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const AppDateRangeField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final t = SharedCoreL10n.of(context);
    final formatters = AppFormatters.of(context);

    final display = value == null
        ? (label ?? t.dateRangeSelect)
        : '${formatters.date(value!.start)} – ${formatters.date(value!.end)}';

    return Semantics(
      button: enabled,
      enabled: enabled,
      label: label ?? t.dateRangeSelect,
      value: display,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? () => _pick(context) : null,
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.s14,
              vertical: AppDimensions.s14,
            ),
            decoration: BoxDecoration(
              color: enabled
                  ? colors.surface
                  : semantic.surfaceSunken,
              borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
              border: Border.all(
                color: enabled
                    ? semantic.borderDefault
                    : semantic.disabledBorder,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: AppDimensions.iconMd,
                  color: enabled
                      ? colors.onSurfaceVariant
                      : semantic.disabledInk,
                ),
                const SizedBox(width: AppDimensions.s10),
                Expanded(
                  child: Text(
                    display,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: value == null
                          ? colors.onSurfaceVariant
                          : colors.onSurface,
                      fontWeight:
                          value == null ? FontWeight.w400 : FontWeight.w600,
                    ),
                  ),
                ),
                if (value != null && enabled) ...[
                  const SizedBox(width: AppDimensions.s4),
                  IconButton(
                    onPressed: () => onChanged(null),
                    tooltip: t.dateRangeClear,
                    constraints: const BoxConstraints(
                      minWidth: AppDimensions.touchTarget,
                      minHeight: AppDimensions.touchTarget,
                    ),
                    icon: const DirectionalIcon(Icons.clear_rounded, size: 18),
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate ?? DateTime(now.year - 5),
      lastDate: lastDate ?? DateTime(now.year + 5),
      initialDateRange: value,
    );
    if (picked != null) onChanged(picked);
  }
}
