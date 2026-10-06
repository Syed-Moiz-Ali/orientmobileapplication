import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/inspection_model.dart';
import 'package:staff_app/features/advisor/inspection_pages/presentation/vehicle_map/vehicle_body_condition_panel.dart';
import 'inspection_provider.dart';

class InspectionPreviewView extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final String jobId;

  const InspectionPreviewView({
    super.key,
    required this.onBack,
    this.jobId = '',
  });

  @override
  ConsumerState<InspectionPreviewView> createState() =>
      _InspectionPreviewViewState();
}

class _InspectionPreviewViewState extends ConsumerState<InspectionPreviewView> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
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
          onPressed: _isSubmitting ? null : widget.onBack,
        ),
        title: Text(
          'Inspection Review',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
          ),
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
                if (state.vehiclePartInspections.isNotEmpty) ...[
                  Text(
                    'VEHICLE BODY CONDITION',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(
                    height: 680,
                    child: VehicleBodyConditionPanel(readOnly: true),
                  ),
                  const SizedBox(height: 16),
                ],
                if (hasRatings) ...[
                  ...state.sections.expand(
                    (sec) => sec.items
                        .asMap()
                        .entries
                        .where(
                          (e) =>
                              state.statuses.containsKey('${sec.id}_${e.key}'),
                        )
                        .map((e) => _ratedItemTile(context, e, sec, state)),
                  ),
                ] else ...[
                  const Center(
                    child: EmptyState(
                      icon: Icons.checklist,
                      message: 'No checkpoints rated',
                    ),
                  ),
                ],
              ],
            ),
          ),
          _footer(context, state, hasRatings),
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
              Icon(
                Icons.assignment_turned_in_outlined,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Text(
                'Vehicle Inspection Summary',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '${state.statuses.length} Rated',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ratedItemTile(
    BuildContext context,
    MapEntry<int, String> e,
    InspectionSection sec,
    InspectionState state,
  ) {
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
            child: Text(
              e.value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            status.name.toUpperCase(),
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context, InspectionState state, bool hasRatings) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          boxShadow: AppDimensions.shadowCard,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              hasRatings
                  ? '${state.statuses.length} checkpoints ready to submit'
                  : 'Rate at least one checkpoint before submitting',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSubmitting ? null : widget.onBack,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Inspection'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: !hasRatings || _isSubmitting
                        ? null
                        : _confirmAndSave,
                    icon: _isSubmitting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_upload_outlined),
                    label: Text(
                      _isSubmitting ? 'Submitting…' : 'Submit Inspection',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndSave() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.assignment_turned_in_outlined),
        title: const Text('Submit this inspection?'),
        content: const Text(
          'Please confirm that the checkpoint ratings, body condition and attachments are correct.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Review Again'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isSubmitting = true);
    await _saveAndUpdate();
    if (mounted) setState(() => _isSubmitting = false);
  }

  Future<void> _saveAndUpdate() async {
    final notifier = ref.read(inspectionProvider.notifier);
    final currentJobCardId = ref.read(inspectionProvider).jobCardId;
    final result = await notifier.submitInspection();
    if (!context.mounted) return;
    await result.when(
      success: (_) async {
        JobCardEntity? target;
        try {
          final detail = await ref
              .read(advisorRemoteDataSourceProvider)
              .getJobCard(currentJobCardId);
          final status = JobCardStatus.values.firstWhere(
            (s) => s.name == detail.status,
            orElse: () => JobCardStatus.inspected,
          );
          target = JobCardEntity(
            id: detail.id.isNotEmpty ? detail.id : currentJobCardId,
            dbId: detail.dbId,
            customerName: detail.customerName,
            vehicleInfo: detail.vehicleInfo,
            time: detail.time,
            createdDate: detail.createdDate,
            lastUpdated: detail.lastUpdated,
            status: status,
            technician: detail.technician,
            odometer: detail.odometer,
            fuelLevel: detail.fuelLevel,
          );
        } catch (_) {
          // Offline: the inspection is queued and will sync later; we cannot
          // refresh the job card right now.
        }
        if (!mounted) return;
        if (target != null) {
          context.pushReplacement(AppRoutes.advisorJobDetail, extra: target);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Inspection saved offline. It will sync automatically.',
              ),
            ),
          );
          widget.onBack();
        }
      },
      failure: (error) async {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      },
    );
  }
}
