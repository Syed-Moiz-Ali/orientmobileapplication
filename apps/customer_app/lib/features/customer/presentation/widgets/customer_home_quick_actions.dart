import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';

/// The small, intentional set of Customer Home actions as four large touch
/// tiles: Book service (the one emphasised action), Breakdown help,
/// Invoices and History.
///
/// Book service is the only emphasised tile; everything else is neutral so
/// the screen never turns into a rainbow. When the customer has no vehicles
/// yet the history tile is dropped — the welcome panel already owns the
/// new-customer call to action.
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

    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            t.garActionsTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        const SizedBox(height: AppDimensions.s12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: wide ? 4 : 2,
            crossAxisSpacing: AppDimensions.s10,
            mainAxisSpacing: AppDimensions.s10,
            // Tall enough for icon + two-line label + hint at 1.3x.
            mainAxisExtent: 132,
          ),
          itemBuilder: (_, i) => _QuickActionTile(action: actions[i]),
        ),
      ],
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
        borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.s14),
          decoration: BoxDecoration(
            color: emphasised
                ? colors.primary.withValues(alpha: 0.08)
                : colors.surface,
            borderRadius:
                BorderRadius.circular(AppDimensions.radiusPanel),
            border: Border.all(
              color: emphasised
                  ? colors.primary.withValues(alpha: 0.32)
                  : colors.outlineVariant,
            ),
            boxShadow: AppDimensions.shadowCard,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                action.icon,
                size: 24,
                color: emphasised ? colors.primary : colors.onSurfaceVariant,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    action.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: emphasised ? colors.primary : colors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    action.hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
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
