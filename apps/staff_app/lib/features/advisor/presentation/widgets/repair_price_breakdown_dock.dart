import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_models/shared_models.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

import 'repair_estimate_math.dart';

/// Phase 09 — sticky money dock for the Work Order Studio.
///
/// Presentation only: the parts/labor totals are the provider-owned
/// `InspectionState.partsTotal` / `servicesTotal`; the 5% VAT line is a
/// statutory display projection. Zero line totals are recomputed here, so the
/// dock can never drift from the frozen estimate math. Live recalculation is a
/// function of the incoming totals on every rebuild.
class RepairPriceBreakdownDock extends StatelessWidget {
  /// Provider `InspectionState.partsTotal`.
  final double partsTotal;

  /// Provider `InspectionState.servicesTotal` (labor operations).
  final double laborTotal;

  /// Number of priced lines; drives the confirm-vs-add label.
  final int lineCount;

  /// True while the parent submit is in flight.
  final bool isSubmitting;

  /// Invoked by the single primary CTA.
  final VoidCallback? onConfirm;

  const RepairPriceBreakdownDock({
    super.key,
    required this.partsTotal,
    required this.laborTotal,
    required this.lineCount,
    this.isSubmitting = false,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final t = StaffLocalizations.of(context)!;
    final arabic = AppTypography.isArabic(Localizations.maybeLocaleOf(context));
    final totals = RepairEstimateTotals.from(
      partsTotal: partsTotal,
      laborTotal: laborTotal,
    );
    final hasLines = lineCount > 0;

    String money(double value) => MoneyAed(value).format(arabic: arabic);

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: semantic.borderDefault)),
          boxShadow: AppDimensions.shadowModal,
        ),
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.s16,
          AppDimensions.s14,
          AppDimensions.s16,
          AppDimensions.s12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MoneyRow(
              label: t.advisorStudioPartsSubtotal,
              value: money(totals.parts),
            ),
            const SizedBox(height: AppDimensions.s4),
            _MoneyRow(
              label: t.advisorStudioLabor,
              value: money(totals.labor),
            ),
            const SizedBox(height: AppDimensions.s4),
            _MoneyRow(label: t.advisorStudioVat, value: money(totals.vat)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.s10),
              child: Divider(height: 1, color: semantic.borderDefault),
            ),
            _MoneyRow(
              label: t.advisorStudioTotal,
              value: money(totals.total),
              emphasized: true,
            ),
            const SizedBox(height: AppDimensions.s14),
            PrimaryButton(
              label: hasLines ? t.advisorStudioConfirm : t.advisorStudioAddItems,
              icon: hasLines
                  ? Icons.preview_outlined
                  : Icons.add_circle_outline_rounded,
              isLoading: isSubmitting,
              onPressed: hasLines ? onConfirm : null,
            ),
            const SizedBox(height: AppDimensions.s8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: AppDimensions.iconXs,
                  color: semantic.success.base,
                ),
                const SizedBox(width: AppDimensions.s6),
                Flexible(
                  child: Text(
                    t.advisorStudioTrustLine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const _MoneyRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (emphasized
                    ? theme.textTheme.titleSmall
                    : theme.textTheme.bodySmall)
                ?.copyWith(
                  fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
                  color: emphasized
                      ? colors.onSurface
                      : colors.onSurfaceVariant,
                ),
          ),
        ),
        const SizedBox(width: AppDimensions.s12),
        Text(
          value,
          maxLines: 1,
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: emphasized ? 18 : 13,
            fontWeight: emphasized ? FontWeight.w800 : FontWeight.w700,
            color: emphasized ? colors.onSurface : colors.onSurfaceVariant,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
