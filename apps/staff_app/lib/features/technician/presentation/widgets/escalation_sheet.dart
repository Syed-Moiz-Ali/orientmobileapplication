import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

import 'package:staff_app/features/technician/data/datasources/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_components.dart';

/// Contextual escalation, launched from Job Detail.
///
/// Raises a problem on the current job to the workshop workflow. It carries the
/// job context automatically and never invents severity, a recipient or a ticket
/// number — the endpoint returns none. Escalating does NOT change the job status.
///
/// The five issue types are the canonical backend values, so labels and the
/// sent payload stay identical — only the touch targets grow to 52px grease
/// rows. Photo evidence is intentionally absent: no escalation media endpoint
/// exists, and attaching bytes to this payload would alter a frozen contract.
///
/// Presented through [showAppModalSheet] by callers (bottom sheet on compact,
/// centred dialog on tablet/desktop); this widget is the content only.
class EscalationSheet extends ConsumerStatefulWidget {
  final String jobCardRef;
  final String technicianEmpId;
  final String vehicleLabel;
  final String plateNumber;

  const EscalationSheet({
    super.key,
    required this.jobCardRef,
    required this.technicianEmpId,
    this.vehicleLabel = '',
    this.plateNumber = '',
  });

  @override
  ConsumerState<EscalationSheet> createState() => _EscalationSheetState();
}

class _EscalationSheetState extends ConsumerState<EscalationSheet> {
  final _descriptionController = TextEditingController();
  String _issueType = 'Unexpected Damage';
  bool _isLoading = false;
  String _error = '';
  String _detailsError = '';

  /// Canonical issue types in display order. Values are the frozen backend
  /// enum — labels render them verbatim.
  static const _issueTypes = <(String, IconData)>[
    ('Unexpected Damage', Icons.car_crash_outlined),
    ('Missing Part', Icons.inventory_2_outlined),
    ('Safety Concern', Icons.health_and_safety_outlined),
    ('Customer Change', Icons.person_outline_rounded),
    ('Other', Icons.more_horiz_rounded),
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    final t = StaffLocalizations.of(context)!;
    if (_descriptionController.text.trim().isEmpty) {
      HapticFeedback.selectionClick();
      setState(() => _detailsError = t.techEscDetailsError);
      return;
    }
    HapticFeedback.heavyImpact();
    setState(() {
      _isLoading = true;
      _error = '';
      _detailsError = '';
    });
    try {
      // Exact established request body; the endpoint returns no status, so only
      // "sent" is claimed and the job status is never altered here.
      await ref.read(technicianRemoteDataSourceProvider).escalateIssue({
        'jobCardRef': widget.jobCardRef,
        'technicianEmpId': widget.technicianEmpId,
        'issueType': _issueType,
        'description': _descriptionController.text.trim(),
      });
      if (!mounted) return;
      Navigator.pop(context, true);
      _toast(t.techEscSent, icon: Icons.campaign_rounded);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = t.techEscError;
      });
    }
  }

  void _toast(String msg, {IconData? icon}) {
    final ink = context.semanticColors.onPrimary;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: ink, size: AppDimensions.iconSm),
              const SizedBox(width: AppDimensions.s8),
            ],
            Expanded(
              child: Text(
                msg,
                style: TextStyle(color: ink, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor: context.semanticColors.success.base,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final t = StaffLocalizations.of(context)!;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.s20,
          AppDimensions.s8,
          AppDimensions.s20,
          AppDimensions.s20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      t.techEscTitle,
                      style: text.titleLarge?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: t.techPartsClose,
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s12),
            TechnicianJobContext(
              jobCardNo: widget.jobCardRef,
              vehicleLabel: widget.vehicleLabel,
              plateNumber: widget.plateNumber,
            ),
            const SizedBox(height: AppDimensions.s20),
            Text(
              t.techEscWhat,
              style: text.titleSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.s10),
            for (var i = 0; i < _issueTypes.length; i++) ...[
              if (i > 0) const SizedBox(height: AppDimensions.s8),
              _IssueRow(
                label: _issueTypes[i].$1,
                icon: _issueTypes[i].$2,
                selected: _issueType == _issueTypes[i].$1,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _issueType = _issueTypes[i].$1);
                },
              ),
            ],
            const SizedBox(height: AppDimensions.s20),
            AppTextField(
              controller: _descriptionController,
              hint: t.techEscDetailsHint,
              label: t.techEscDetails,
              errorText: _detailsError.isEmpty ? null : _detailsError,
              minLines: 4,
              maxLines: 7,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) {
                if (_detailsError.isNotEmpty) {
                  setState(() => _detailsError = '');
                }
              },
            ),
            const SizedBox(height: AppDimensions.s12),
            Container(
              padding: const EdgeInsets.all(AppDimensions.s12),
              decoration: BoxDecoration(
                color: colors.errorContainer.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusControl,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: AppDimensions.iconSm,
                    color: colors.onErrorContainer,
                  ),
                  const SizedBox(width: AppDimensions.s8),
                  Expanded(
                    child: Text(
                      t.techEscSafety,
                      style: text.bodySmall?.copyWith(
                        color: colors.onErrorContainer,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.s16),
              Semantics(
                liveRegion: true,
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.s12),
                  decoration: BoxDecoration(
                    color: colors.errorContainer,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusControl,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: AppDimensions.iconSm,
                        color: colors.onErrorContainer,
                      ),
                      const SizedBox(width: AppDimensions.s8),
                      Expanded(
                        child: Text(
                          _error,
                          style: text.bodySmall?.copyWith(
                            color: colors.onErrorContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.s20),
            PrimaryButton(
              label: _isLoading ? t.techEscSending : t.techEscSend,
              icon: _isLoading ? null : Icons.campaign_rounded,
              isError: true,
              onPressed: _isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

/// 52px grease issue row: icon + canonical label + radio. Single-select; the
/// value sent is the label verbatim (frozen backend enum).
class _IssueRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _IssueRow({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected
            ? colors.primary.withValues(alpha: 0.08)
            : colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          side: BorderSide(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          child: SizedBox(
            height: 52,
            child: Row(
              children: [
                const SizedBox(width: AppDimensions.s14),
                Icon(
                  icon,
                  size: AppDimensions.iconMd,
                  color: selected
                      ? colors.primary
                      : colors.onSurfaceVariant,
                ),
                const SizedBox(width: AppDimensions.s12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: selected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: AppDimensions.iconMd,
                  color: selected
                      ? colors.primary
                      : colors.onSurfaceVariant,
                ),
                const SizedBox(width: AppDimensions.s14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
