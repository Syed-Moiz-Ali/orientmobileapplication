import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';

/// Display labels for the frozen period state values. The notifier keeps the
/// canonical English values (`setPeriod('Today')` etc.) — only the rendered
/// copy is localized, so this widget is presentation-only.
String _periodLabel(OwnerLocalizations t, String value) => switch (value) {
      'Today' => t.ownerPeriodToday,
      'This Month' => t.ownerPeriodMonth,
      'This Year' => t.ownerPeriodYear,
      _ => t.ownerPeriodWeek,
    };

class PeriodDropdown extends ConsumerWidget {
  const PeriodDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final state = ref.watch(dashboardUiProvider);
    final notifier = ref.read(dashboardUiProvider.notifier);

    const values = <String>['Today', 'This Week', 'This Month', 'This Year'];

    // Shell-compressed trigger (C16/U14): on phones the trigger collapses
    // to an icon-only 48px target so the primary bar title never
    // ellipsizes; tablets keep the labeled pill. Same values, same
    // notifier, same menu — only the trigger density changes, and the
    // tooltip still announces the current period (a11y preserved).
    final compact = MediaQuery.sizeOf(context).width < 600;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: compact ? 48 : 128),
      child: PopupMenuButton<String>(
        initialValue: state.period,
        tooltip: _periodLabel(t, state.period),
        onSelected: (v) {
          HapticFeedback.selectionClick();
          notifier.setPeriod(v);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        itemBuilder: (context) => [
          for (final v in values)
            PopupMenuItem(value: v, child: Text(_periodLabel(t, v))),
        ],
        child: compact
            ? Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _periodLabel(t, state.period),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
