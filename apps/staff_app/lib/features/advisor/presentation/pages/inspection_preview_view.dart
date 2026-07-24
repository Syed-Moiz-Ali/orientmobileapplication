import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/local/sync_providers.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/inspection_model.dart';
import 'package:staff_app/features/advisor/inspection_pages/presentation/widgets/inspection_widgets.dart';
import 'inspection_provider.dart';
import 'package:staff_app/core/router/app_router.dart';

class InspectionPreviewView extends ConsumerWidget {
  final VoidCallback onBack;
  final String jobId;

  const InspectionPreviewView({
    super.key,
    required this.onBack,
    this.jobId = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inspectionProvider);
    final hasRatings = state.statuses.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: onBack,
        ),
        title: const Text('Inspection Preview',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.rPill),
            ),
            child: Text('${state.statuses.length} items',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _summaryCard(state),
              const SizedBox(height: 16),
              if (hasRatings) ...[
                _sectionLabel('Rated Items'),
                const SizedBox(height: 8),
                ...kInspectionSections.expand((sec) =>
                    sec.items.asMap().entries
                        .where((e) => state.statuses.containsKey('${sec.id}_${e.key}'))
                        .map((e) => _ratedItemTile(e, sec, state))),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: Column(children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBg,
                        borderRadius: BorderRadius.circular(AppDimensions.r16),
                      ),
                      child: const Icon(Icons.search_outlined, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(height: 16),
                    const Text('No items rated',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    const Text('Rating is optional. You can save the job\nwithout rating any items.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.text2, height: 1.5)),
                  ]),
                ),
              ],
            ],
          ),
        ),
        _footer(context, ref, state, hasRatings),
      ]),
    );
  }

  Widget _summaryCard(InspectionState state) {
    final rated = state.statuses.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(AppDimensions.r10),
            ),
            child: const Icon(Icons.assignment_turned_in_outlined, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Vehicle Inspection', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            Text('$rated items rated',
                style: TextStyle(fontSize: 12, color: rated > 0 ? AppColors.success : AppColors.text3, fontWeight: FontWeight.w600)),
          ]),
        ]),
        const SizedBox(height: 16),
        const Divider(color: Color(0xFFE4E7EE), height: 1),
        ...kInspectionSections.map((sec) {
          final count = sec.items.asMap().entries.where((e) => state.statuses.containsKey('${sec.id}_${e.key}')).length;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF0F3F7)))),
            child: Row(children: [
              Expanded(child: Text(sec.label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: count == sec.items.length ? AppColors.successBg : AppColors.warningBg,
                  borderRadius: BorderRadius.circular(AppDimensions.rPill),
                ),
                child: Text('$count/${sec.items.length}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                        color: count == sec.items.length ? AppColors.success : AppColors.warning)),
              ),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _sectionLabel(String text) {
    return Row(children: [
      Container(width: 4, height: 18, decoration: BoxDecoration(
        color: AppColors.primary, borderRadius: BorderRadius.circular(AppDimensions.r2),
      )),
      const SizedBox(width: 10),
      Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    ]);
  }

  Widget _ratedItemTile(MapEntry<int, String> e, InspectionSection sec, InspectionState state) {
    final itemId = '${sec.id}_${e.key}';
    final status = state.statuses[itemId]!;
    final sc = statusColors(status);
    final m = state.media[itemId];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.r12),
        border: Border.all(color: sc.color.withValues(alpha: 0.15)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 4, height: 44,
            decoration: BoxDecoration(color: sc.color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(e.value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(sec.label, style: const TextStyle(fontSize: 11, color: AppColors.text3)),
          if (m?.note.isNotEmpty ?? false) ...[
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.notes_rounded, size: 12, color: AppColors.text3),
              const SizedBox(width: 4),
              Flexible(child: Text(m!.note, style: const TextStyle(fontSize: 11, color: AppColors.text2),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          ],
          if ((m?.photoPaths.isNotEmpty ?? false))
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(children: [
                const Icon(Icons.photo_outlined, size: 12, color: AppColors.primary),
                const SizedBox(width: 4),
                Text('${m!.photoPaths.length} photo(s)',
                    style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
              ]),
            ),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: sc.bg,
            borderRadius: BorderRadius.circular(AppDimensions.rPill),
            border: Border.all(color: sc.color.withValues(alpha: 0.2)),
          ),
          child: Text(sc.label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: sc.color)),
        ),
      ]),
    );
  }

  Widget _footer(BuildContext context, WidgetRef ref, InspectionState state, bool hasRatings) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE4E7EE))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _saveAndUpdate(context, ref),
            icon: const Icon(Icons.save_outlined, size: 20),
            label: Text(jobId.isNotEmpty ? 'Save & Update Job' : 'Save Inspection',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r14)),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onBack,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.text3,
              side: const BorderSide(color: Color(0xFFD4D9E6)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Back to Edit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }

  Future<void> _saveAndUpdate(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(inspectionProvider.notifier);
    await notifier.submitInspection();

    if (jobId.isNotEmpty) {
      final now = DateTime.now();
      final updated = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      final box = Hive.box<dynamic>('inspections');
      final existing = box.get(jobId);
      if (existing != null) {
        final data = Map<String, dynamic>.from(existing as Map);
        data['hasInspection'] = true;
        data['inspectionCompleted'] = now.toIso8601String();
        data['lastUpdated'] = updated;
        await box.put(jobId, data);
      }
    }

    ref.read(syncEngineProvider).syncAll();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(jobId.isNotEmpty ? 'Job updated with inspection' : 'Inspection saved',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ]),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        ),
      );
      context.go(AppRoutes.advisorDashboard);
    }
  }
}

