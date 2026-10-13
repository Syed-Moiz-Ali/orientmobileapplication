import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';
import 'advisor_outline_action.dart';
import 'advisor_solid_action.dart';

/// Metric detail dialog opened from a Today metric tile.
///
/// The provider cannot yet filter the jobs list by a single metric, so the
/// drill-down is display-only unless a caller wires [onViewAll] to the jobs
/// tab (documented in the Phase 06 report — not faked).
class AdvisorStatDialog extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final VoidCallback? onViewAll;

  const AdvisorStatDialog({
    super.key,
    required this.label,
    required this.count,
    required this.color,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusDialog),
      ),
      backgroundColor: colors.surface,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: AppTextStyles.metric(color: color),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.s14),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: AppDimensions.s6),
              Text(
                t.advisorStatViewAllHint,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppDimensions.s24),
              Row(
                children: [
                  Expanded(
                    child: AdvisorOutlineAction(
                      label: t.advisorActionClose,
                      icon: Icons.close_rounded,
                      color: colors.onSurfaceVariant,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s10),
                  Expanded(
                    child: AdvisorSolidAction(
                      label: t.advisorActionViewAll,
                      icon: Icons.arrow_forward_rounded,
                      color: color,
                      onTap: () {
                        Navigator.pop(context);
                        onViewAll?.call();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
