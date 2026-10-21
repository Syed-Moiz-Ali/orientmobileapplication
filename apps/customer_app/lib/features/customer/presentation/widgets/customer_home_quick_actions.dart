import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';

/// The small, intentional set of Customer Home actions: Book service (the one
/// emphasised action), Breakdown help, Invoices and History.
///
/// Wide canvases keep the C16 one-row intent (four tiles across); narrower
/// rows reflow to a 2x2 grid so every label keeps full words instead of
/// truncating mid-word. Tile labels always wrap to two lines — Arabic and
/// 1.3x text scale reflow instead of overflowing. When the customer has no
/// vehicles yet the history tile is dropped — the new-customer empty state
/// already owns that call to action.
class CustomerHomeQuickActions extends StatelessWidget {
  final bool hasVehicles;
  final VoidCallback onBookService;
  final VoidCallback onBreakdownHelp;
  final VoidCallback onInvoices;
  final VoidCallback onHistory;

  const CustomerHomeQuickActions({
    super.key,
    required this.hasVehicles,
    required this.onBookService,
    required this.onBreakdownHelp,
    required this.onInvoices,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final actions = <_QuickAction>[
      _QuickAction(
        label: t.garActionBook,
        hint: t.garActionBookHint,
        icon: Icons.calendar_month_rounded,
        emphasised: true,
        onTap: onBookService,
      ),
      _QuickAction(
        label: t.garActionSos,
        hint: t.garActionSosHint,
        icon: Icons.car_crash_rounded,
        onTap: onBreakdownHelp,
      ),
      _QuickAction(
        label: t.garActionInvoices,
        hint: t.garActionInvoicesHint,
        icon: Icons.receipt_long_rounded,
        onTap: onInvoices,
      ),
      if (hasVehicles)
        _QuickAction(
          label: t.garActionHistory,
          hint: t.garActionHistoryHint,
          icon: Icons.history_rounded,
          onTap: onHistory,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // 4-across needs ~120px per tile for full-word 13sp labels; narrower
        // rows (phones, half-width medium column) use a 2x2 grid instead of
        // truncating mid-word. Both keep >= 48dp targets and full Semantics.
        if (constraints.maxWidth < 480) {
          final rows = <List<_QuickAction>>[];
          for (var i = 0; i < actions.length; i += 2) {
            rows.add(actions.sublist(i, (i + 2).clamp(0, actions.length)));
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var r = 0; r < rows.length; r++) ...[
                if (r > 0) const SizedBox(height: AppSpacing.md),
                Row(
                  // start (not stretch): this column scrolls, so the row's
                  // height is unbounded and stretch would force infinity.
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < rows[r].length; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.md),
                      Expanded(child: _QuickActionTile(action: rows[r][i])),
                    ],
                    // Odd tile count: keep the last row balanced.
                    if (rows[r].length == 1)
                      const Expanded(child: SizedBox.shrink()),
                  ],
                ),
              ],
            ],
          );
        }
        return Row(
          // start (not stretch): see above — the home column scrolls.
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.md),
              Expanded(child: _QuickActionTile(action: actions[i])),
            ],
          ],
        );
      },
    );
  }
}

class _QuickAction {
  final String label;
  final String hint;
  final IconData icon;
  final VoidCallback onTap;
  final bool emphasised;

  const _QuickAction({
    required this.label,
    required this.hint,
    required this.icon,
    required this.onTap,
    this.emphasised = false,
  });
}

class _QuickActionTile extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final emphasised = action.emphasised;

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: '${action.label}, ${action.hint}',
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          action.onTap();
        },
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          constraints: const BoxConstraints(minHeight: 88),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: emphasised
                ? colors.primary.withValues(alpha: 0.08)
                : colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: emphasised
                  ? colors.primary.withValues(alpha: 0.32)
                  : colors.outlineVariant,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                action.icon,
                size: 24,
                color: emphasised ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.sm),
              // Two-line wrap on word boundaries; the 2x2 reflow above keeps
              // full words visible at 1.3x/320/ar instead of mid-word cuts.
              Text(
                action.label,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: emphasised ? colors.primary : colors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
