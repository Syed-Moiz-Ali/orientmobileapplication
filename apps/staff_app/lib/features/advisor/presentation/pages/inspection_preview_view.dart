import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/inspection_model.dart';
import 'inspection_provider.dart';

class InspectionPreviewView extends ConsumerWidget {
  final VoidCallback onBack;
  final String jobId;

  const InspectionPreviewView({super.key, required this.onBack, this.jobId = ''});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final state = ref.watch(inspectionProvider);
    final hasRatings = state.statuses.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: onBack,
        ),
        title: Text(
          'Inspection Review',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: colorScheme.onSurface),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _summaryCard(context, state),
                const SizedBox(height: 16),
                if (hasRatings) ...[
                  ...kInspectionSections.expand(
                    (sec) => sec.items
                        .asMap()
                        .entries
                        .where((e) => state.statuses.containsKey('${sec.id}_${e.key}'))
                        .map((e) => _ratedItemTile(context, e, sec, state)),
                  ),
                ] else ...[
                  const Center(
                    child: EmptyState(icon: Icons.checklist, message: 'No checkpoints rated'),
                  ),
                ],
              ],
            ),
          ),
          _footer(context, ref, state, hasRatings),
        ],
      ),
    );
  }

  Widget _summaryCard(BuildContext context, InspectionState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.assignment_turned_in_outlined, color: colorScheme.primary),
              const SizedBox(width: 10),
              Text('Vehicle Inspection Summary', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              Text(
                '${state.statuses.length} Rated',
                style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ratedItemTile(BuildContext context, MapEntry<int, String> e, InspectionSection sec, InspectionState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final itemId = '${sec.id}_${e.key}';
    final status = state.statuses[itemId]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(e.value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Text(
            status.name.toUpperCase(),
            style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context, WidgetRef ref, InspectionState state, bool hasRatings) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colorScheme.surface),
      child: ElevatedButton(
        onPressed: () => _saveAndUpdate(context, ref),
        child: const Text('Confirm & Save Inspection'),
      ),
    );
  }

  Future<void> _saveAndUpdate(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(inspectionProvider.notifier);
    final currentJobCardId = ref.read(inspectionProvider).jobCardId;
    final result = await notifier.submitInspection();
    if (!context.mounted) return;
    await result.when(
      success: (_) async {
        final detail = await ref.read(advisorRemoteDataSourceProvider).getJobCard(currentJobCardId);
        if (!context.mounted) return;
        final status = JobCardStatus.values.firstWhere(
          (s) => s.name == detail.status,
          orElse: () => JobCardStatus.inspected,
        );
        context.pushReplacement(
          AppRoutes.advisorJobDetail,
          extra: JobCardEntity(
            id: detail.id.isNotEmpty ? detail.id : currentJobCardId,
            dbId: detail.dbId,
            customerName: detail.customerName,
            vehicleInfo: detail.vehicleInfo,
            time: detail.time,
            createdDate: detail.createdDate,
            lastUpdated: detail.lastUpdated,
            status: status,
            technician: detail.technician,
          ),
        );
      },
      failure: (error) async {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      },
    );
  }
}
