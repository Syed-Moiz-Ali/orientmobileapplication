import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/core/router/app_router.dart';
import 'package:owner_app/features/dashboard/data/datasources/owner_remote_datasource.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';
import 'package:shared_auth/shared_auth.dart';

/// Activity feed loaded from the backend (OwnerRemoteDataSource.getActivity).
/// Frozen fetch/sort logic — only chrome, grouping and taps are new.
final ownerActivityFeedProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final remote = OwnerRemoteDataSource(ref.read(apiClientProvider));
    final activities = await remote.getActivity(1, 50);
    return activities.map((a) {
      return <String, dynamic>{
        'id': a.id,
        'type': a.type,
        'title': a.title,
        'description': a.description,
        'timestamp': a.timestamp,
      };
    }).toList()
      ..sort((a, b) =>
          (b['timestamp'] as String? ?? '').compareTo(a['timestamp'] as String? ?? ''));
  } catch (_) {
    return [];
  }
});

IconData _iconFor(String icon) {
  switch (icon) {
    case 'assignment': return Icons.assignment_rounded;
    case 'fact_check': return Icons.fact_check_rounded;
    case 'thumb_up': return Icons.thumb_up_rounded;
    case 'receipt': return Icons.receipt_rounded;
    case 'inventory': return Icons.inventory_2_rounded;
    case 'check_circle': return Icons.check_circle_rounded;
    case 'payments': return Icons.payments_rounded;
    case 'engineering': return Icons.engineering_rounded;
    default: return Icons.circle_rounded;
  }
}

/// Server-sent accent dots are *data* (like a status payload), not palette
/// selection: the surrounding chrome resolves theme roles; only the 6px dot
/// carries the feed color so severity survives both themes.
Color _parseColor(String hex) {
  final val = int.tryParse(hex.replaceFirst('#', ''), radix: 16) ?? 0x1F6FEB;
  return Color(val | 0xFF000000);
}

/// Real destinations for feed taps. Types with no screen behind them return
/// null and render untappable — never a dead push.
String? _routeFor(String type) {
  final t = type.toLowerCase();
  if (t.contains('approv')) return AppRoutes.pendingApprovals;
  if (t.contains('pay') || t.contains('invoic') || t.contains('receiv')) {
    return AppRoutes.accountsReceivable;
  }
  if (t.contains('team') ||
      t.contains('staff') ||
      t.contains('technician') ||
      t.contains('advisor')) {
    return AppRoutes.team;
  }
  if (t.contains('invent') || t.contains('stock') || t.contains('part')) {
    return AppRoutes.inventory;
  }
  if (t.contains('document') || t.contains('expir') || t.contains('compli')) {
    return AppRoutes.documentExpiry;
  }
  if (t.contains('review') || t.contains('rating') || t.contains('feedback')) {
    return AppRoutes.feedbackModeration;
  }
  if (t.contains('attend') || t.contains('shift')) return AppRoutes.attendance;
  if (t.contains('subscri') || t.contains('plan')) return AppRoutes.subscription;
  if (t.contains('status')) return AppRoutes.jobStatus;
  if (t.contains('job') ||
      t.contains('assign') ||
      t.contains('qc') ||
      t.contains('quality') ||
      t.contains('bay')) {
    return AppRoutes.jobCards;
  }
  return null;
}

/// Tab destinations (the feed lives inside the tab shell, so these select
/// rather than push).
int? _tabFor(String type) {
  final t = type.toLowerCase();
  if (t.contains('message') || t.contains('broadcast')) return 2;
  if (t.contains('sale') || t.contains('top')) return 0;
  return null;
}

class _FeedGroup {
  final String label;
  final DateTime? day;
  final List<Map<String, dynamic>> items;

  _FeedGroup({required this.label, required this.day, required this.items});
}

/// Operational activity log (O4): backend feed grouped by day with
/// locale-aware relative times. Rows tap through to the real screen behind
/// the event type; unmapped types render as plain rows.
class OwnerActivityFeedTab extends ConsumerWidget {
  const OwnerActivityFeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = OwnerLocalizations.of(context)!;
    final formatters = AppFormatters.of(context);
    final activitiesAsync = ref.watch(ownerActivityFeedProvider);

    if (activitiesAsync.isLoading) {
      return ListView(
        padding: EdgeInsets.fromLTRB(
          context.pagePadding.left,
          AppDimensions.s16,
          context.pagePadding.right,
          AppDimensions.s32,
        ),
        children: const [
          AppSkeleton.listRows(rows: 6),
        ],
      );
    }

    final activities = activitiesAsync.value ?? const <Map<String, dynamic>>[];
    if (activities.isEmpty) {
      return ListView(
        padding: EdgeInsets.fromLTRB(
          context.pagePadding.left,
          AppDimensions.s24,
          context.pagePadding.right,
          AppDimensions.s32,
        ),
        children: [
          EmptyState(
            icon: Icons.history_toggle_off_rounded,
            message: t.ownerActEmpty,
          ),
          const SizedBox(height: AppDimensions.s8),
          Text(
            t.ownerActEmptyHint,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      );
    }

    final groups = _groupByDay(activities, t, formatters);
    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );

    Widget groupSection(_FeedGroup group) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: SectionHeader(title: group.label),
            ),
            const SizedBox(height: AppDimensions.s8),
            for (final a in group.items) ...[
              _ActivityRow(
                activity: a,
                formatters: formatters,
                onOpenTab: (index) => ref
                    .read(dashboardUiProvider.notifier)
                    .selectTab(index),
              ),
              const SizedBox(height: AppDimensions.s8),
            ],
          ],
        );

    if (wide) {
      final mid = (groups.length / 2).ceil();
      return ListView(
        padding: EdgeInsets.fromLTRB(
          context.pagePadding.left,
          AppDimensions.s16,
          context.pagePadding.right,
          AppDimensions.s32,
        ),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < mid; i++) ...[
                      groupSection(groups[i]),
                      const SizedBox(height: AppDimensions.s16),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.s24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = mid; i < groups.length; i++) ...[
                      groupSection(groups[i]),
                      const SizedBox(height: AppDimensions.s16),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
        context.pagePadding.left,
        AppDimensions.s16,
        context.pagePadding.right,
        AppDimensions.s32,
      ),
      children: [
        for (final group in groups) ...[
          groupSection(group),
          const SizedBox(height: AppDimensions.s16),
        ],
      ],
    );
  }
}

List<_FeedGroup> _groupByDay(
  List<Map<String, dynamic>> activities,
  OwnerLocalizations t,
  AppFormatters formatters,
) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final buckets = <String, _FeedGroup>{};
  final order = <String>[];

  String dayKey(DateTime day) => '${day.year}-${day.month}-${day.day}';

  for (final a in activities) {
    final raw = (a['timestamp'] as String? ?? '').trim();
    final parsed = DateTime.tryParse(raw);
    final String key;
    final String label;
    final DateTime? day;
    if (parsed != null) {
      final d = DateTime(parsed.year, parsed.month, parsed.day);
      final diff = today.difference(d).inDays;
      day = d;
      if (diff == 0) {
        key = 'today';
        label = t.ownerActToday;
      } else if (diff == 1) {
        key = 'yesterday';
        label = t.ownerActYesterday;
      } else {
        key = dayKey(d);
        label = formatters.date(d);
      }
    } else {
      key = 'undated';
      label = raw.isEmpty ? '—' : raw;
      day = null;
    }
    final bucket = buckets[key];
    if (bucket == null) {
      buckets[key] = _FeedGroup(label: label, day: day, items: [a]);
      order.add(key);
    } else {
      bucket.items.add(a);
    }
  }

  // Dated groups newest-first; undated trails (stable input order kept).
  order.sort((a, b) {
    final da = buckets[a]!.day;
    final db = buckets[b]!.day;
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return db.compareTo(da);
  });
  return [for (final k in order) buckets[k]!];
}

class _ActivityRow extends StatelessWidget {
  final Map<String, dynamic> activity;
  final AppFormatters formatters;
  final ValueChanged<int> onOpenTab;

  const _ActivityRow({
    required this.activity,
    required this.formatters,
    required this.onOpenTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final type = (activity['type'] as String? ?? '').trim();
    final title = (activity['title'] as String? ?? '').trim();
    final desc = (activity['description'] as String? ?? '').trim();
    final rawTime = (activity['timestamp'] as String? ?? '').trim();
    final parsed = DateTime.tryParse(rawTime);
    // Locale-aware relative time; unparseable stamps render verbatim.
    final time = parsed == null
        ? rawTime
        : formatters.relativeTime(parsed);

    final accent = _parseColor(
      (activity['color'] as String? ?? '#1F6FEB').trim(),
    );
    final route = _routeFor(type);
    final tab = route == null ? _tabFor(type) : null;
    final tappable = route != null || tab != null;

    void open() {
      HapticFeedback.selectionClick();
      if (route != null) {
        context.push(route);
      } else if (tab != null) {
        onOpenTab(tab);
      }
    }

    return AppRecordRow(
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        alignment: Alignment.center,
        child: Icon(
          _iconFor((activity['icon'] as String? ?? '').trim()),
          color: accent,
          size: 22,
        ),
      ),
      title: title.isEmpty ? type : title,
      subtitle: desc.isEmpty ? null : desc,
      metadata: Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          time,
          style: AppTextStyles.mono(color: colors.onSurfaceVariant)
              .copyWith(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      onTap: tappable ? open : null,
    );
  }
}
