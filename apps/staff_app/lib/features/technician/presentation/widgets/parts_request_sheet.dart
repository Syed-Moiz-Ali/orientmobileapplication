import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_app/features/technician/data/datasources/technician_providers.dart';

class PartsRequestSheet extends ConsumerStatefulWidget {
  final String jobCardRef;
  final String technicianEmpId;

  const PartsRequestSheet({
    super.key,
    required this.jobCardRef,
    required this.technicianEmpId,
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

  @override
  void dispose() {
    _partNameCtrl.dispose();
    _partNumberCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    try {
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
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Part request sent to the parts desk')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not send the request. Try again.')),
      );
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
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.92,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.outlineVariant,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SheetHeader(
                    icon: Icons.inventory_2_outlined,
                    title: 'Request a part',
                    subtitle: '${widget.jobCardRef} • Sent to the parts desk',
                    onClose: _isLoading ? null : () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 22),
                  TextFormField(
                    controller: _partNameCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Part name',
                      hintText: 'Example: Front brake pad set',
                      prefixIcon: Icon(Icons.build_outlined),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter the required part'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _partNumberCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Part number (optional)',
                      hintText: 'OEM or workshop reference',
                      prefixIcon: Icon(Icons.tag_rounded),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(18),
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
                          width: 38,
                          child: Text(
                            '$_quantity',
                            textAlign: TextAlign.center,
                            style: text.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton.filled(
                          tooltip: 'Increase quantity',
                          onPressed: () => setState(() => _quantity++),
                          icon: const Icon(Icons.add_rounded),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Priority',
                    style: text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _notesCtrl,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'Add fitment details or preferred alternatives',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: _isLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                    ),
                    icon: _isLoading
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(
                      _isLoading ? 'Sending request…' : 'Send part request',
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

class _SheetHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onClose;

  const _SheetHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: colors.onPrimaryContainer),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: text.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Close',
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }
}
