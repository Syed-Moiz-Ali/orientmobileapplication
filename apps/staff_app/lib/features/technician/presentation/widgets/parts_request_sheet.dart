import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/technician/data/datasources/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_components.dart';

/// Contextual parts request, launched from Job Detail.
///
/// A short workshop-floor form: what part, how many, and why. It carries the
/// current job context automatically and never browses inventory (the Technician
/// API exposes none). Success means exactly what the endpoint confirms — the
/// request was accepted — not that a part is ordered, approved or arriving.
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
  final _formKey = GlobalKey<FormState>();
  final _partNameCtrl = TextEditingController();
  final _partNumberCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  int _quantity = 1;
  String _urgency = 'Normal';
  bool _isLoading = false;
  String _error = '';

  @override
  void dispose() {
    _partNameCtrl.dispose();
    _partNumberCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
      _error = '';
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Part request sent.')));
    } catch (_) {
      // Keep the form and the technician's input; a retryable inline message.
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error =
            "We couldn't send the request. Check your connection and try again.";
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
                              'Request a part',
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
                    TextFormField(
                      controller: _partNameCtrl,
                      textInputAction: TextInputAction.next,
                      autofocus: false,
                      decoration: const InputDecoration(
                        labelText: 'Part name',
                        hintText: 'What part or material do you need?',
                        prefixIcon: Icon(Icons.build_outlined),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Enter the part you need'
                          : null,
                    ),
                    const SizedBox(height: AppDimensions.s14),
                    TextFormField(
                      controller: _partNumberCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Part number (optional)',
                        hintText: 'OEM or workshop reference',
                        prefixIcon: Icon(Icons.tag_rounded),
                      ),
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
                                  'Quantity',
                                  style: text.titleSmall?.copyWith(
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Units needed',
                                  style: text.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton.filledTonal(
                            tooltip: 'Decrease quantity',
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                            icon: const Icon(Icons.remove_rounded),
                          ),
                          SizedBox(
                            width: 44,
                            child: Text(
                              '$_quantity',
                              textAlign: TextAlign.center,
                              style: text.titleMedium?.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton.filled(
                            tooltip: 'Increase quantity',
                            onPressed: _quantity < 999
                                ? () => setState(() => _quantity++)
                                : null,
                            icon: const Icon(Icons.add_rounded),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s18),
                    Text(
                      'Urgency',
                      style: text.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s8),
                    SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: 'Normal',
                          icon: Icon(Icons.schedule_rounded),
                          label: Text('Normal'),
                        ),
                        ButtonSegment(
                          value: 'Urgent',
                          icon: Icon(Icons.bolt_rounded),
                          label: Text('Urgent'),
                        ),
                      ],
                      selected: {_urgency},
                      onSelectionChanged: (value) {
                        HapticFeedback.selectionClick();
                        setState(() => _urgency = value.first);
                      },
                    ),
                    const SizedBox(height: AppDimensions.s18),
                    TextFormField(
                      controller: _notesCtrl,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        hintText: 'Fitment details or preferred alternatives',
                        alignLabelWithHint: true,
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
                      ),
                      icon: _isLoading
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(
                        _isLoading ? 'Sending\u2026' : 'Send request',
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
