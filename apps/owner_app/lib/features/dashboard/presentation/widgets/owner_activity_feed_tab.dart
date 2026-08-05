import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/data/datasources/owner_remote_datasource.dart';
import 'package:shared_auth/shared_auth.dart';

/// Activity feed loaded from the backend (OwnerRemoteDataSource.getActivity).
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

Color _parseColor(String hex) {
  final val = int.tryParse(hex.replaceFirst('#', ''), radix: 16) ?? 0x1F6FEB;
  return Color(val | 0xFF000000);
}

String _formatTimestamp(String iso) {
  try {
    final dt = DateTime.parse(iso);
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  } catch (_) {
    return iso;
  }
}

class OwnerActivityFeedTab extends ConsumerWidget {
  const OwnerActivityFeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(ownerActivityFeedProvider);
    final activities = activitiesAsync.value ?? const <Map<String, dynamic>>[];

    if (activities.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(AppDimensions.s16),
        children: [
          const SizedBox(height: 60),
          const Icon(
            Icons.history_toggle_off_rounded,
            size: 48,
            color: AppColors.text4,
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'No activity yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.text3,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Job cards, approvals and payments will show up here.',
              style: TextStyle(fontSize: 12, color: AppColors.text4),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.s16),
      itemCount: activities.length,
      itemBuilder: (_, i) {
        final a = activities[i];
        final color = _parseColor(a['color'] as String? ?? '#1F6FEB');
        final icon = _iconFor(a['icon'] as String? ?? '');
        final title = a['title'] as String? ?? '';
        final desc = a['description'] as String? ?? '';
        final time = _formatTimestamp(a['timestamp'] as String? ?? '');

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.canvas, borderRadius: BorderRadius.circular(10)),
                          child: Text(time, style: const TextStyle(fontSize: 9, color: AppColors.text3, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.text3)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}