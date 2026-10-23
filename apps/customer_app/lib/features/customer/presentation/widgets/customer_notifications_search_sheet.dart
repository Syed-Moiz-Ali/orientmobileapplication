import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';

/// Opens the notifications find sheet: a list-scoped search over the already
/// loaded inbox rows (no new routes, no new logic). Result taps reuse the row
/// contract — tapping a result closes the sheet and opens the row's
/// destination (or marks read for read-only rows); navigation stays with the
/// opener. Single path by construction: the AppBar search action is the only
/// visible entry point.
Future<void> showCustomerNotificationsSearchSheet(
  BuildContext context, {
  required List<CustomerNotificationEntity> notifications,
  required ValueChanged<CustomerNotificationEntity> onSelect,
}) {
  final t = context.cx;
  return showAppModalSheet<void>(
    context: context,
    title: t.ntSearchTitle,
    builder: (_) => _NotificationsSearchSheet(
      notifications: notifications,
      onSelect: onSelect,
    ),
  );
}

/// Presentation-only notifications search: filters the loaded inbox rows by
/// title/body/time substring (case-insensitive). Mirrors the row content so
/// the sheet can never promise a notification the list does not show.
class _NotificationsSearchSheet extends StatefulWidget {
  final List<CustomerNotificationEntity> notifications;
  final ValueChanged<CustomerNotificationEntity> onSelect;

  const _NotificationsSearchSheet({
    required this.notifications,
    required this.onSelect,
  });

  @override
  State<_NotificationsSearchSheet> createState() =>
      _NotificationsSearchSheetState();
}

class _NotificationsSearchSheetState
    extends State<_NotificationsSearchSheet> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<CustomerNotificationEntity> _results() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.notifications;
    return widget.notifications.where((n) {
      final title = n.title.toLowerCase();
      final body = n.body.toLowerCase();
      final time = n.time.toLowerCase();
      return title.contains(q) || body.contains(q) || time.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final results = _results();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.xl,
            AppSpacing.xs,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          child: AppSearchField(
            controller: _ctrl,
            hintText: t.ntSearchHint,
            onChanged: (v) => setState(() => _query = v),
            onClear: () => setState(() {
              _ctrl.clear();
              _query = '';
            }),
          ),
        ),
        Flexible(
          child: results.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.ntSearchNoMatch,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: () => setState(() {
                          _ctrl.clear();
                          _query = '';
                        }),
                        child: Text(t.ntSearchClear),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: results.length,
                  itemBuilder: (rowContext, index) {
                    final n = results[index];
                    final title = n.title.trim();
                    final body = n.body.trim();
                    // D4 (ui/fix-rulings): result rows render whole — title/body
                    // wrap ≤2 lines at word boundaries (softWrap) on tokens
                    // only; time is secondary meta (1-line ellipsis allowed).
                    // Vertical stack (no Row competition) so 320/1.3x/ar fit.
                    return InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(rowContext).pop();
                        widget.onSelect(n);
                      },
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppDimensions.s20,
                          AppDimensions.s8,
                          AppDimensions.s20,
                          AppDimensions.s8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (body.isNotEmpty) ...[
                              const SizedBox(height: AppDimensions.s4),
                              Text(
                                body,
                                maxLines: 2,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                            if (n.time.trim().isNotEmpty) ...[
                              const SizedBox(height: AppDimensions.s4),
                              Text(
                                n.time.trim(),
                                maxLines: 1,
                                softWrap: false,
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
                  },
                ),
        ),
      ],
    );
  }
}
