import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

import 'package:staff_app/features/technician/data/datasources/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_components.dart';

/// Contextual parts request, launched from Job Detail or Today.
///
/// A short workshop-floor form: what part, how many, and why. It carries the
/// current job context automatically and never browses inventory (the Technician
/// API exposes none). Success means exactly what the endpoint confirms — the
/// request was accepted — not that a part is ordered, approved or arriving.
///
/// Presented through [showAppModalSheet] by callers (bottom sheet on compact,
/// centred dialog on tablet/desktop); this widget is the content only.
class PartsRequestSheet extends ConsumerStatefulWidget {
  final String jobCardRef;
  final String technicianEmpId;
  final String vehicleLabel;
  final String plateNumber;

  const PartsRequestSheet({
    super.key,
    required this.jobCardRef,
    required this.technicianEmpId,
    this.vehicleLabel = '',
    this.plateNumber = '',
  });

  @override
  ConsumerState<PartsRequestSheet> createState() => _PartsRequestSheetState();
}

class _PartsRequestSheetState extends ConsumerState<PartsRequestSheet> {
  final _partNameCtrl = TextEditingController();
  final _partNumberCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  int _quantity = 1;
  String _urgency = 'Normal';
  bool _isLoading = false;
  String _error = '';
  String _nameError = '';

  @override
  void dispose() {
    _partNameCtrl.dispose();
    _partNumberCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  bool get _isUrgent => _urgency == 'Urgent';

  Future<void> _submit() async {
    if (_isLoading) return;
    final t = StaffLocalizations.of(context)!;
    if (_partNameCtrl.text.trim().isEmpty) {
      HapticFeedback.selectionClick();
      setState(() => _nameError = t.techPartsNameError);
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
      _error = '';
      _nameError = '';
    });
    try {
      // Exact established request body; the endpoint has no response body, no
      // status and no idempotency key, so nothing beyond "sent" is claimed.
      await ref.read(technicianRemoteDataSourceProvider).requestPart({
        'jobCardRef': widget.jobCardRef,
        'technicianEmpId': widget.technicianEmpId,
        'partName': _partNameCtrl.text.trim(),
        'partNumber': _partNumberCtrl.text.trim(),
        'quantity': _quantity,
        'urgency': _urgency,
        'notes': _notesCtrl.text.trim(),
      });
      if (!mounted) return;
      Navigator.pop(context, true);
      _toast(t.techPartsSent, icon: Icons.check_circle_outline_rounded);
    } catch (_) {
      // Keep the form and the technician's input; a retryable inline message.
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = t.techPartsError;
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
                      t.techPartsTitle,
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
            AppTextField(
              controller: _partNameCtrl,
              hint: t.techPartsNameHint,
              label: t.techPartsName,
              prefixIcon: Icons.build_outlined,
              errorText: _nameError.isEmpty ? null : _nameError,
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                if (_nameError.isNotEmpty) {
                  setState(() => _nameError = '');
                }
              },
            ),
            const SizedBox(height: AppDimensions.s14),
            AppTextField(
              controller: _partNumberCtrl,
              hint: t.techPartsNumberHint,
              label: t.techPartsNumber,
              prefixIcon: Icons.tag_rounded,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppDimensions.s18),
            Container(
              padding: const EdgeInsets.all(AppDimensions.s14),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusControl,
                ),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.techPartsQty,
                          style: text.titleSmall?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          t.techPartsQtyHint,
                          style: text.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppQuantityStepper(
                    value: _quantity.toDouble(),
                    min: 1,
                    max: 999,
                    semanticLabel: t.techPartsQty,
                    onChanged: (v) =>
                        setState(() => _quantity = v.toInt()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.s18),
            Text(
              t.techPartsUrgency,
              style: text.titleSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.s8),
            Row(
              children: [
                Expanded(
                  child: _UrgencyOption(
                    label: t.techPartsNormal,
                    icon: Icons.schedule_rounded,
                    selected: !_isUrgent,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _urgency = 'Normal');
                    },
                  ),
                ),
                const SizedBox(width: AppDimensions.s8),
                Expanded(
                  child: _UrgencyOption(
                    label: t.techPartsUrgent,
                    icon: Icons.bolt_rounded,
                    selected: _isUrgent,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _urgency = 'Urgent');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s18),
            AppTextField(
              controller: _notesCtrl,
              hint: t.techPartsNotesHint,
              label: t.techPartsNotes,
              minLines: 3,
              maxLines: 5,
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
              label: _isLoading
                  ? t.techPartsSending
                  : t.techPartsSendCount(_quantity),
              icon: _isLoading ? null : Icons.send_rounded,
              onPressed: _isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

/// 52px grease urgency toggle. Single-select pair, selected fills primary.
class _UrgencyOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _UrgencyOption({
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
        color: selected ? colors.primary : colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          side: BorderSide(
            color: selected ? colors.primary : colors.outlineVariant,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          child: SizedBox(
            height: 52,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: AppDimensions.iconMd,
                  // FIXED-INK: white glyph on the saturated selected fill.
                  color: selected
                      ? colors.onPrimary
                      : colors.onSurfaceVariant,
                ),
                const SizedBox(width: AppDimensions.s8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected
                          ? colors.onPrimary
                          : colors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
