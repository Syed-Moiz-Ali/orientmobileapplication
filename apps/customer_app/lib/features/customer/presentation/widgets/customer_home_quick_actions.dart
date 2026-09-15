import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// The small, intentional set of Customer Home actions.
///
/// Book service is the only emphasised action; everything else is neutral so
/// the screen never turns into a rainbow of quick-action colours. When the
/// customer has no vehicles yet the garage action is dropped entirely because
/// the service summary already owns that call to action.
class CustomerHomeQuickActions extends StatelessWidget {
  final bool hasVehicles;
  final VoidCallback onBookService;
  final VoidCallback onMyVehicles;
  final VoidCallback onBreakdownHelp;

  const CustomerHomeQuickActions({
    super.key,
    required this.hasVehicles,
    required this.onBookService,
    required this.onMyVehicles,
    required this.onBreakdownHelp,
  });

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickAction>[
      _QuickAction(
        label: 'Book service',
        icon: Icons.calendar_month_rounded,
        emphasised: true,
        onTap: onBookService,
      ),
      if (hasVehicles)
        _QuickAction(
          label: 'My vehicles',
          icon: Icons.directions_car_rounded,
          onTap: onMyVehicles,
        ),
      _QuickAction(
        label: 'Breakdown help',
        icon: Icons.car_crash_rounded,
        onTap: onBreakdownHelp,
      ),
    ];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: AppDimensions.s10),
            Expanded(child: _QuickActionTile(action: actions[i])),
          ],
        ],
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final bool emphasised;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
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
      label: action.label,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        child: Container(
          constraints: const BoxConstraints(minHeight: 92),
          padding: const EdgeInsets.all(AppDimensions.s12),
          decoration: BoxDecoration(
            color: emphasised
                ? colors.primary.withValues(alpha: 0.08)
                : colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(
              color: emphasised
                  ? colors.primary.withValues(alpha: 0.32)
                  : colors.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                action.icon,
                size: 22,
                color: emphasised ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(height: AppDimensions.s10),
              Text(
                action.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: emphasised ? colors.primary : colors.onSurface,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
