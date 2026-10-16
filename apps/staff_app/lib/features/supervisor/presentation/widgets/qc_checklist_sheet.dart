import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_components.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Opens the QC sign-off sheet through the shared responsive modal (bottom
/// sheet on compact, centred dialog ≥600).
Future<void> showQcChecklistSheet(
  BuildContext context, {
  required int jobCardId,
  required String jobCardRef,
  required String customerName,
  required String vehicleInfo,
  required List<String> workItems,
}) {
  return showAppModalSheet<void>(
    context: context,
    builder: (_) => QcChecklistSheet(
      jobCardId: jobCardId,
      jobCardRef: jobCardRef,
      customerName: customerName,
      vehicleInfo: vehicleInfo,
      workItems: workItems,
    ),
  ).then((_) {});
}

/// Formal quality-control sign-off: standard checkpoints + the job's real work
/// items as large toggles, evidence slots, notes, and one primary dock
/// (Approve emerald / Send back crimson). The `qcReview` call and its payload
/// are byte-identical to the frozen contract.
class QcChecklistSheet extends ConsumerStatefulWidget {
  final int jobCardId;
  final String jobCardRef;
  final String customerName;
  final String vehicleInfo;
  final List<String> workItems;

  const QcChecklistSheet({
    super.key,
    required this.jobCardId,
    required this.jobCardRef,
    required this.customerName,
    required this.vehicleInfo,
    this.workItems = const [],
  });

  @override
  ConsumerState<QcChecklistSheet> createState() => _QcChecklistSheetState();
}

class _QcChecklistSheetState extends ConsumerState<QcChecklistSheet> {
  late final List<String> _checkpoints;
  late final List<bool> _checked;
  final _notesCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkpoints = widget.workItems
        .map((w) => w.trim())
        .where((w) => w.isNotEmpty)
        .toList();
    _checked = List.filled(4 + _checkpoints.length, false);
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  int get _checkedCount => _checked.where((c) => c).length;
  bool get _allChecked => _checkedCount == _checked.length;

  void _toggle(int i) {
    HapticFeedback.selectionClick();
    setState(() => _checked[i] = !_checked[i]);
  }

  Future<void> _approve() async {
    final t = StaffLocalizations.of(context)!;
    if (!_allChecked) {
      showSupervisorToast(context, t.svQcVerifyAll,
          icon: Icons.info_outline_rounded,
          color: context.semanticColors.warning.base);
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    final msg = await ref
        .read(supervisorDashboardProvider.notifier)
        .qcReview(
          widget.jobCardRef,
          'approve',
          checklistPassed: true,
          notes: _notesCtrl.text.trim(),
        );
    if (!mounted) return;
    final ok = !msg.startsWith('Could not');
    Navigator.pop(context);
    showSupervisorToast(
      context,
      ok ? t.svQcApproved : t.svQcFailed,
      icon: ok ? Icons.verified_outlined : Icons.error_outline,
      color: ok ? context.semanticColors.success.base : context.semanticColors.danger.base,
    );
  }

  Future<void> _reject() async {
    final t = StaffLocalizations.of(context)!;
    final reason = _notesCtrl.text.trim();
    if (reason.isEmpty) {
      showSupervisorToast(context, t.svQcRejectReasonRequired,
          icon: Icons.info_outline_rounded,
          color: context.semanticColors.warning.base);
      return;
    }
    HapticFeedback.heavyImpact();
    setState(() => _isLoading = true);
    final msg = await ref
        .read(supervisorDashboardProvider.notifier)
        .qcReview(
          widget.jobCardRef,
          'reject',
          checklistPassed: false,
          notes: reason,
          rejectReason: reason,
        );
    if (!mounted) return;
    final ok = !msg.startsWith('Could not');
    Navigator.pop(context);
    showSupervisorToast(
      context,
      ok ? t.svQcRejected : t.svQcFailed,
      icon: ok ? Icons.undo_rounded : Icons.error_outline,
      color: ok ? context.colors.primary : context.semanticColors.danger.base,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = StaffLocalizations.of(context)!;
    final total = _checkpoints.length + 4;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          jobCardRef: widget.jobCardRef,
          customerName: widget.customerName,
          vehicleInfo: widget.vehicleInfo,
          checked: _checkedCount,
          total: total,
        ),
        const SizedBox(height: AppDimensions.s12),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _GroupLabel(
                  icon: Icons.fact_check_outlined,
                  label: t.svQcCheckpoints,
                ),
                _CheckRow(
                  label: t.svQcRoadTest,
                  icon: Icons.directions_car_filled_outlined,
                  checked: _checked[0],
                  onTap: () => _toggle(0),
                ),
                _CheckRow(
                  label: t.svQcTorque,
                  icon: Icons.build_circle_outlined,
                  checked: _checked[1],
                  onTap: () => _toggle(1),
                ),
                _CheckRow(
                  label: t.svQcFluid,
                  icon: Icons.water_drop_outlined,
                  checked: _checked[2],
                  onTap: () => _toggle(2),
                ),
                _CheckRow(
                  label: t.svQcWash,
                  icon: Icons.local_car_wash_outlined,
                  checked: _checked[3],
                  onTap: () => _toggle(3),
                ),
                if (_checkpoints.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.s12),
                  _GroupLabel(
                    icon: Icons.handyman_outlined,
                    label: t.svQcRepairVerification,
                  ),
                  for (var i = 0; i < _checkpoints.length; i++)
                    _CheckRow(
                      label: _checkpoints[i],
                      icon: Icons.check_circle_outline_rounded,
                      checked: _checked[4 + i],
                      onTap: () => _toggle(4 + i),
                    ),
                ],
                const SizedBox(height: AppDimensions.s12),
                _GroupLabel(
                  icon: Icons.photo_camera_outlined,
                  label: t.svQcPhotoProof,
                ),
                const _PhotoSlots(),
                const SizedBox(height: AppDimensions.s16),
                TextField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  minLines: 2,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    labelText: t.svQcNotes,
                    hintText: t.svQcNotesHint,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.s12),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: t.svQcReject,
                icon: Icons.undo_rounded,
                isError: true,
                onPressed: _isLoading ? null : _reject,
              ),
            ),
            const SizedBox(width: AppDimensions.s12),
            Expanded(
              child: PrimaryButton(
                label: t.svQcApprove,
                icon: Icons.verified_rounded,
                backgroundColor: context.semanticColors.success.base,
                foregroundColor: context.semanticColors.onPrimary,
                isLoading: _isLoading,
                onPressed: _allChecked ? _approve : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String jobCardRef;
  final String customerName;
  final String vehicleInfo;
  final int checked;
  final int total;

  const _Header({
    required this.jobCardRef,
    required this.customerName,
    required this.vehicleInfo,
    required this.checked,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = StaffLocalizations.of(context)!;
    final done = total > 0 && checked == total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                t.svQcTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: context.colors.onSurface,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.s8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.s8,
                vertical: AppDimensions.s4,
              ),
              decoration: BoxDecoration(
                color: done
                    ? context.semanticColors.success.subtle
                    : context.semanticColors.surfaceSunken,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                border: Border.all(
                  color: done
                      ? context.semanticColors.success.border
                      : context.semanticColors.borderDefault,
                ),
              ),
              child: Text(
                t.svQcVerified(checked, total),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: done
                      ? context.semanticColors.success.ink
                      : context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.s4),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            jobCardRef,
            style: supervisorMono(
              context,
              color: context.colors.onSurfaceVariant,
            ).copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$customerName · $vehicleInfo',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimensions.s10),
        AppLinearProgress(
          value: total == 0 ? 0 : checked / total,
          height: 5,
          color: done
              ? context.semanticColors.success.base
              : context.colors.primary,
        ),
      ],
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _GroupLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppDimensions.s4,
        bottom: AppDimensions.s8,
      ),
      child: Row(
        children: [
          Icon(icon, size: AppDimensions.iconSm, color: context.colors.primary),
          const SizedBox(width: AppDimensions.s8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: context.colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// Large toggle checkpoint row (52 dp).
class _CheckRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool checked;
  final VoidCallback onTap;

  const _CheckRow({
    required this.label,
    required this.icon,
    required this.checked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final success = context.semanticColors.success;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.s8),
      child: Semantics(
        checked: checked,
        button: true,
        label: label,
        child: Material(
          color: checked ? success.subtle : context.semanticColors.surfaceRaised,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            side: BorderSide(
              color: checked ? success.border : context.semanticColors.borderDefault,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 52),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.s14,
                vertical: AppDimensions.s12,
              ),
              child: Row(
                children: [
                  Icon(
                    checked
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: AppDimensions.iconLg,
                    color: checked
                        ? success.base
                        : context.colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppDimensions.s12),
                  Icon(icon, size: AppDimensions.iconSm, color: context.colors.onSurfaceVariant),
                  const SizedBox(width: AppDimensions.s8),
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: checked ? FontWeight.w700 : FontWeight.w500,
                        color: context.colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Evidence slots. Upload has no backend endpoint on this API (same deferral
/// documented in Phase 10), so the slots are explicit placeholders rather than
/// fake capture — the honest state, with the reason shown once.
class _PhotoSlots extends StatelessWidget {
  const _PhotoSlots();

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final border = context.semanticColors.borderStrong;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < 4; i++) ...[
              if (i > 0) const SizedBox(width: AppDimensions.s8),
              Expanded(
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: context.semanticColors.surfaceSunken,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        size: AppDimensions.iconMd,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.svQcPhotoAdd,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppDimensions.s6),
        Text(
          t.svQcPhotoUnavailable,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
