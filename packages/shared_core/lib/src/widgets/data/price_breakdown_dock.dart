import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_text_styles.dart';

/// One line in the dock: a label and its caller-formatted amount.
///
/// Amounts are display strings owned by the caller (e.g. `AED 450`);
/// the dock never parses or computes money.
class PriceBreakdownItem {
  final String label;
  final String amount;

  const PriceBreakdownItem({required this.label, required this.amount});
}

/// Sticky bottom dock (Airbnb addendum §3.2, customer layer): itemized
/// lines, a tabular total, one primary CTA and an optional trust line
/// (e.g. free re-check). Used by booking, approvals and invoice.
///
/// All copy comes from the caller (localized); all color/type resolves
/// through the active theme. Amounts render LTR-locked in the mono face.
/// The CTA renders a busy label + spinner while [busy]; a null [onCta]
/// (or [ctaEnabled] false) disables it without hiding it.
class PriceBreakdownDock extends StatelessWidget {
  final List<PriceBreakdownItem> items;
  final String totalLabel;
  final String totalAmount;
  final String ctaLabel;
  final String? busyLabel;
  final VoidCallback? onCta;
  final bool busy;
  final bool ctaEnabled;
  final String? trustLine;

  const PriceBreakdownDock({
    super.key,
    this.items = const [],
    required this.totalLabel,
    required this.totalAmount,
    required this.ctaLabel,
    this.busyLabel,
    this.onCta,
    this.busy = false,
    this.ctaEnabled = true,
    this.trustLine,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final enabled = ctaEnabled && !busy && onCta != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.s20,
        AppDimensions.s12,
        AppDimensions.s20,
        AppDimensions.s20,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final item in items)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppDimensions.s4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.s12),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        item.amount,
                        maxLines: 1,
                        style: AppTextStyles.mono(
                          color: colors.onSurface,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            if (items.isNotEmpty)
              const SizedBox(height: AppDimensions.s4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    totalLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.s12),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    totalAmount,
                    maxLines: 1,
                    semanticsLabel: '$totalLabel $totalAmount',
                    style: AppTextStyles.mono(
                      color: colors.onSurface,
                    ).copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: AppDimensions.s18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s12),
            FilledButton(
              onPressed: enabled ? onCta : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
              child: busy
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        if (busyLabel != null && busyLabel!.isNotEmpty) ...[
                          const SizedBox(width: AppDimensions.s8),
                          Flexible(
                            child: Text(
                              busyLabel!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    )
                  : Text(ctaLabel),
            ),
            if (trustLine != null && trustLine!.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.s8),
              Text(
                trustLine!,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
