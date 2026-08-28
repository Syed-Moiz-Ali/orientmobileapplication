import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_app/features/technician/data/datasources/technician_providers.dart';

class EscalationSheet extends ConsumerStatefulWidget {
  final String jobCardRef;
  final String technicianEmpId;

  const EscalationSheet({
    super.key,
    required this.jobCardRef,
    required this.technicianEmpId,
  });

  @override
  ConsumerState<EscalationSheet> createState() => _EscalationSheetState();
}

class _EscalationSheetState extends ConsumerState<EscalationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _issueType = 'Unexpected Damage';
  bool _isLoading = false;

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
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.heavyImpact();
    setState(() => _isLoading = true);
    try {
      await ref.read(technicianRemoteDataSourceProvider).escalateIssue({
        'jobCardRef': widget.jobCardRef,
        'technicianEmpId': widget.technicianEmpId,
        'issueType': _issueType,
        'description': _descriptionController.text.trim(),
      });
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supervisor notified about this issue')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not escalate the issue. Try again.'),
        ),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colors.errorContainer,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.report_gmailerrorred_rounded,
                          color: colors.onErrorContainer,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Escalate an issue',
                              style: text.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${widget.jobCardRef} • Supervisor will be notified',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
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
                  const SizedBox(height: 22),
                  Text(
                    'What happened?',
                    style: text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _issueTypes.map((item) {
                      return ChoiceChip(
                        avatar: Icon(item.$2, size: 17),
                        label: Text(item.$1),
                        selected: _issueType == item.$1,
                        onSelected: (_) {
                          HapticFeedback.selectionClick();
                          setState(() => _issueType = item.$1);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 4,
                    maxLines: 7,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Issue details',
                      hintText:
                          'Describe what you found, the impact, and what you need…',
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      final description = value?.trim() ?? '';
                      if (description.isEmpty) return 'Describe the issue';
                      if (description.length < 20) {
                        return 'Add more detail (at least 20 characters)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: colors.errorContainer.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 19,
                          color: colors.onErrorContainer,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'For an immediate safety risk, stop work and contact the supervisor directly.',
                            style: text.bodySmall?.copyWith(
                              color: colors.onErrorContainer,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: _isLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
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
                      _isLoading
                          ? 'Notifying supervisor…'
                          : 'Notify supervisor',
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
