import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';
import 'advisor_sheet.dart';
import 'advisor_notification_data.dart';
import 'advisor_notification_row.dart';

/// Notification inbox sheet. Shared with the technician dashboard (Phase 10),
/// so its import path and presentation contract are preserved.
class AdvisorNotificationSheet extends ConsumerWidget {
  const AdvisorNotificationSheet({super.key});

  List<AdvisorNotificationData> _loadNotifications(Color infoColor) {
    try {
      final box = Hive.box<dynamic>('inspections');
      final items = box.values
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .where((m) => m['type'] == 'notification')
          .map(
            (m) => AdvisorNotificationData(
              m['title'] as String? ?? '',
              m['message'] as String? ?? '',
              Icons.notifications_outlined,
              infoColor,
              m['timeAgo'] as String? ?? '',
            ),
          )
          .toList();
      if (items.isNotEmpty) return items;
    } catch (_) {}
    return [];
  }

  void _clearAll() {
    try {
      final box = Hive.box<dynamic>('inspections');
      final keys = box.keys.where((k) {
        final v = box.get(k);
        return v is Map && v['type'] == 'notification';
      }).toList();
      for (final k in keys) {
        box.delete(k);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final infoColor = context.semanticColors.info.base;
    final t = StaffLocalizations.of(context)!;

    final localItems = _loadNotifications(infoColor);
    final remoteAsync = ref.watch(advisorNotificationsProvider);
    final remoteItems =
        (remoteAsync.value ?? const <StaffNotificationResponse>[])
            .map(
              (n) => AdvisorNotificationData(
                n.title,
                n.body,
                n.isRead
                    ? Icons.notifications_outlined
                    : Icons.notifications_active_rounded,
                n.isRead ? colors.onSurfaceVariant : infoColor,
                n.time,
              ),
            )
            .toList();
    final items = [...remoteItems, ...localItems];

    return AdvisorSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.advisorNotificationsTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),
              if (items.isNotEmpty)
                TextButton(
                  onPressed: () {
                    _clearAll();
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: colors.primary,
                    minimumSize: const Size(0, AppDimensions.touchTarget),
                  ),
                  child: Text(t.advisorClearAll),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.s12),
          if (items.isNotEmpty)
            ...items.map((n) => AdvisorNotificationRow(n: n))
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.s24),
              child: EmptyState(
                icon: Icons.notifications_off_outlined,
                title: t.advisorNoNotifications,
                message: t.advisorNoNotificationsHint,
              ),
            ),
        ],
      ),
    );
  }
}
