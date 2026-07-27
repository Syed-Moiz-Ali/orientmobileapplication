import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';

final ownerActivityFeedProvider = Provider<List<Map<String, dynamic>>>((ref) {
  try {
    final box = Hive.box<dynamic>('owner_activity');
    final saved = box.values
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
    if (saved.isEmpty) {
      _seedMockData(box);
      return box.values
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList()
        ..sort((a, b) => (b['timestamp'] as String? ?? '').compareTo(a['timestamp'] as String? ?? ''));
    }
    saved.sort((a, b) => (b['timestamp'] as String? ?? '').compareTo(a['timestamp'] as String? ?? ''));
    return saved;
  } catch (_) {
    return [];
  }
});

void _seedMockData(Box<dynamic> box) {
  final now = DateTime.now();
  final mock = [
    {'id': 'a1', 'type': 'job_card', 'title': 'New job card created', 'description': 'Ahmed Hassan \u00b7 Toyota Camry \u00b7 Full Service', 'timestamp': now.subtract(const Duration(minutes: 15)).toIso8601String(), 'icon': 'assignment', 'color': '#1F6FEB'},
    {'id': 'a2', 'type': 'inspection', 'title': 'Inspection completed', 'description': 'BMW 3 Series \u00b7 AB19 XYZ \u00b7 All sections passed', 'timestamp': now.subtract(const Duration(minutes: 45)).toIso8601String(), 'icon': 'fact_check', 'color': '#238636'},
    {'id': 'a3', 'type': 'approval', 'title': 'Estimate approved', 'description': 'Nissan Patrol \u00b7 EST-2024-089 \u00b7 AED 1,250', 'timestamp': now.subtract(const Duration(hours: 1)).toIso8601String(), 'icon': 'thumb_up', 'color': '#8957E5'},
    {'id': 'a4', 'type': 'invoice', 'title': 'Invoice raised', 'description': 'Ford Focus \u00b7 INV-2026-003 \u00b7 AED 3,800', 'timestamp': now.subtract(const Duration(hours: 2)).toIso8601String(), 'icon': 'receipt', 'color': '#DA3633'},
    {'id': 'a5', 'type': 'parts', 'title': 'Parts arrived', 'description': 'Order #PO-2026-042 \u00b7 Brake pads, Oil filters', 'timestamp': now.subtract(const Duration(hours: 3)).toIso8601String(), 'icon': 'inventory', 'color': '#E3B341'},
    {'id': 'a6', 'type': 'job_card', 'title': 'Job card completed', 'description': 'Mercedes C-Class \u00b7 Full Inspection \u00b7 Ready for delivery', 'timestamp': now.subtract(const Duration(hours: 5)).toIso8601String(), 'icon': 'check_circle', 'color': '#238636'},
    {'id': 'a7', 'type': 'payment', 'title': 'Payment received', 'description': 'Honda Accord \u00b7 INV-2026-001 \u00b7 AED 2,450', 'timestamp': now.subtract(const Duration(hours: 6)).toIso8601String(), 'icon': 'payments', 'color': '#1F6FEB'},
    {'id': 'a8', 'type': 'technician', 'title': 'Technician assigned', 'description': 'Ravi Kumar \u2192 Toyota Camry \u00b7 AC Repair', 'timestamp': now.subtract(const Duration(hours: 8)).toIso8601String(), 'icon': 'engineering', 'color': '#FF7B00'},
  ];
  for (final item in mock) {
    box.put(item['id'], item);
  }
}

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
    final activities = ref.watch(ownerActivityFeedProvider);

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