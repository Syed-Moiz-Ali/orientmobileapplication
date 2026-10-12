import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/technician/data/datasources/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_components.dart';

/// Contextual escalation, launched from Job Detail.
///
/// Raises a problem on the current job to the workshop workflow. It carries the
/// job context automatically and never invents severity, a recipient or a ticket
/// number — the endpoint returns none. Escalating does NOT change the job status.
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
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _issueType = 'Unexpected Damage';
  bool _isLoading = false;
  String _error = '';

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
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _isLoading = true;
      _error = '';
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Escalation sent.')));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error =
            "We couldn't send the escalation. Check your connection and try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 560,
              maxHeight: MediaQuery.sizeOf(context).height * 0.92,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.s20,
                AppDimensions.s10,
                AppDimensions.s20,
                AppDimensions.s24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            header: true,
                            child: Text(
                              'Escalate an issue',
                              style: text.titleLarge?.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.pop(context),
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
                      'What happened?',
                      style: text.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s10),
                    Wrap(
                      spacing: AppDimensions.s8,
                      runSpacing: AppDimensions.s8,
                      children: _issueTypes.map((item) {
                        final selected = _issueType == item.$1;
                        return ChoiceChip(
                          avatar: Icon(
                            item.$2,
                            size: 17,
                            color: selected
                                ? colors.onPrimary
                                : colors.onSurfaceVariant,
                          ),
                          label: Text(item.$1),
                          selected: selected,
                          showCheckmark: false,
                          selectedColor: colors.primary,
                          labelStyle: text.labelLarge?.copyWith(
                            color: selected
                                ? colors.onPrimary
                                : colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                          onSelected: (_) {
                            HapticFeedback.selectionClick();
                            setState(() => _issueType = item.$1);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppDimensions.s20),
                    TextFormField(
                      controller: _descriptionController,
                      minLines: 4,
                      maxLines: 7,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Issue details',
                        hintText: 'Describe what you found and what you need…',
                        alignLabelWithHint: true,
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Describe the issue'
                          : null,
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
                              'For an immediate safety risk, stop work and '
                              'contact the supervisor directly.',
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
                    FilledButton.icon(
                      onPressed: _isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                          AppDimensions.touchTarget,
                        ),
                        backgroundColor: colors.error,
                        foregroundColor: colors.onError,
                      ),
                      icon: _isLoading
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.campaign_rounded),
                      label: Text(
                        _isLoading ? 'Sending\u2026' : 'Escalate issue',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
