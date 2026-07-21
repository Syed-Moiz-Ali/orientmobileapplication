// lib/features/advisor/inspection_pages/inspection_preview_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/features/advisor/inspection_pages/data/models/inspection_model.dart';
import 'package:orientmobileapplication/features/advisor/inspection_pages/presentation/widgets/inspection_widgets.dart';
import 'package:orientmobileapplication/features/advisor/inspection_pages/inspection_provider.dart';

class InspectionPreviewView extends ConsumerWidget {
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  const InspectionPreviewView({
    super.key,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inspectionProvider);

    return Scaffold(
      backgroundColor: IC.canvas,
      appBar: AppBar(
        backgroundColor: IC.navy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: onBack,
        ),
        title: const Text('Inspection Preview',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
      ),
      body: Column(children: [
        Expanded(child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Summary card ──────────────────────────────────────────────
            InfoCard(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: IC.tealBg, borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r9))),
                    child: const Icon(Icons.assignment_turned_in_outlined, color: IC.accent, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Vehicle Inspection Sheet',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: IC.text1)),
                    Text('Ready to submit',
                        style: TextStyle(fontSize: 11, color: IC.text2)),
                  ]),
                ]),
                const SizedBox(height: 14),
                const Divider(color: IC.line, height: 1),
                // Section summaries
                ...kInspectionSections.map((sec) {
                  final ratedCount = sec.items.asMap().entries.where((e) {
                    final itemId = '${sec.id}_${e.key}';
                    return state.statuses.containsKey(itemId);
                  }).length;
                  final total = sec.items.length;
                  final complete = ratedCount == total;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: IC.line))),
                    child: Row(children: [
                      Expanded(child: Text(sec.label,
                          style: const TextStyle(fontSize: 12, color: IC.text1))),
                      AppBadge(
                        label: '$ratedCount / $total',
                        color: complete ? IC.green : IC.amber,
                        bg: complete ? IC.greenBg : IC.amberBg,
                        small: true,
                      ),
                    ]),
                  );
                }),
              ],
            )),

            const SizedBox(height: 12),

            // ── Rated items list ──────────────────────────────────────────
            if (state.statuses.isNotEmpty) ...[
              const Text('Rated Items',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: IC.text2)),
              const SizedBox(height: 8),
              ...kInspectionSections.expand((sec) =>
                  sec.items.asMap().entries
                      .where((e) => state.statuses.containsKey('${sec.id}_${e.key}'))
                      .map((e) {
                    final itemId = '${sec.id}_${e.key}';
                    final status = state.statuses[itemId]!;
                    final sc = statusColors(status);
                    final m = state.media[itemId];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: IC.surface, borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
                        border: Border.all(color: IC.line),
                      ),
                      child: Row(children: [
                        Container(width: 3, height: 36,
                            decoration: BoxDecoration(color: sc.color, borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r2)))),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(e.value,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: IC.text1)),
                          Text(sec.label,
                              style: const TextStyle(fontSize: 10, color: IC.text3)),
                          if (m?.note.isNotEmpty ?? false) ...[
                            const SizedBox(height: 3),
                            Text('Note: ${m!.note}',
                                style: const TextStyle(fontSize: 10, color: IC.text2),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                          if ((m?.photoPaths.isNotEmpty ?? false))
                            Text('${m!.photoPaths.length} photo(s)',
                                style: const TextStyle(fontSize: 10, color: IC.accent)),
                        ])),
                        AppBadge(label: sc.label.toUpperCase(), color: sc.color, bg: sc.bg, small: true),
                      ]),
                    );
                  })),
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No items rated yet.\nGo back and rate some items.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: IC.text3)),
                ),
              ),
            ],
          ],
        )),

        // ── Submit button ─────────────────────────────────────────────────
        Container(
          color: IC.surface,
          padding: const EdgeInsets.all(16),
          child: SolidBtn(label: 'SUBMIT INSPECTION', onTap: onSubmit),
        ),
      ]),
    );
  }
}
