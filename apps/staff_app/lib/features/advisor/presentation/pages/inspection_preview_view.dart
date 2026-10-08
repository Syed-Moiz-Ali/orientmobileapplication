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
    final remaining = (state.totalItems - state.completedCount).clamp(
      0,
      state.totalItems,
    );

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
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
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
              children: [
                _summaryCard(context, state),
                if (remaining > 0 && hasRatings) ...[
                  const SizedBox(height: 12),
                  _IncompleteNotice(
                    remaining: remaining,
                    onEdit: widget.onBack,
                  ),
                ],
                const SizedBox(height: 16),
                if (state.vehiclePartInspections.isNotEmpty) ...[
                  _ReviewSectionHeader(
                    icon: Icons.directions_car_outlined,
                    title: 'Vehicle Body Condition',
                    subtitle: 'Recorded damage and marked vehicle areas',
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: const VehicleBodyConditionPanel(
                      readOnly: true,
                      embedded: true,
                      showTitle: false,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (hasRatings) ...[
                  const _ReviewSectionHeader(
                    icon: Icons.fact_check_outlined,
                    title: 'Checkpoint Results',
                    subtitle:
                        'Review every recorded condition before submission',
                  ),
                  const SizedBox(height: 8),
                  ...state.sections.map(
                    (section) => _sectionReview(context, section, state),
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

    final good = state.statuses.values
        .where((status) => status == ItemStatus.good)
        .length;
    final fair = state.statuses.values
        .where((status) => status == ItemStatus.fair)
        .length;
    final poor = state.statuses.values
        .where((status) => status == ItemStatus.poor)
        .length;
    final progress = state.totalItems == 0
        ? 0.0
        : state.completedCount / state.totalItems;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${state.completedCount} of ${state.totalItems} checkpoints completed',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatusSummary(
                  label: 'Good',
                  count: good,
                  color: const Color(0xFF059669),
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatusSummary(
                  label: 'Fair',
                  count: fair,
                  color: colorScheme.secondary,
                  icon: Icons.error_outline_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatusSummary(
                  label: 'Poor',
                  count: poor,
                  color: colorScheme.error,
                  icon: Icons.cancel_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionReview(
    BuildContext context,
    InspectionSection section,
    InspectionState state,
  ) {
    final rated = section.items
        .asMap()
        .entries
        .where(
          (entry) => state.statuses.containsKey('${section.id}_${entry.key}'),
        )
        .toList();
    if (rated.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.label,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ...rated.map(
            (entry) => _ratedItemTile(context, entry, section, state),
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
    final media = state.media[itemId];
    final attachmentCount =
        (media?.photoPaths.length ?? 0) +
        (media?.videoPaths.length ?? 0) +
        ((media?.audioPath.isNotEmpty ?? false) ? 1 : 0) +
        ((media?.note.isNotEmpty ?? false) ? 1 : 0);
    final statusColor = status == ItemStatus.good
        ? const Color(0xFF059669)
        : status == ItemStatus.fair
        ? colorScheme.secondary
        : colorScheme.error;
    final statusIcon = status == ItemStatus.good
        ? Icons.check_circle_rounded
        : status == ItemStatus.fair
        ? Icons.error_rounded
        : Icons.cancel_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(statusIcon, size: 19, color: statusColor),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.value,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (attachmentCount > 0) ...[
                  const SizedBox(height: 3),
                  Text(
                    '$attachmentCount attachment${attachmentCount == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              status.name[0].toUpperCase() + status.name.substring(1),
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -3),
            ),
          ],
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
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: !hasRatings || _isSubmitting
                    ? null
                    : _confirmAndSave,
                icon: _isSubmitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(
                  _isSubmitting
                      ? 'Submitting Inspection…'
                      : 'Submit Inspection',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _isSubmitting ? null : widget.onBack,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Go back and edit'),
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

class _ReviewSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ReviewSectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IncompleteNotice extends StatelessWidget {
  final int remaining;
  final VoidCallback onEdit;

  const _IncompleteNotice({required this.remaining, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: colors.secondaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: colors.onSecondaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$remaining checkpoint${remaining == 1 ? '' : 's'} still need a condition.',
              style: TextStyle(
                color: colors.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(onPressed: onEdit, child: const Text('Complete')),
        ],
      ),
    );
  }
}

class _StatusSummary extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatusSummary({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 19),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
