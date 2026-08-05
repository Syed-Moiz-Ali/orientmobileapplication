import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
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
  final _descCtrl = TextEditingController();
  String _issueType = 'Unexpected Damage';
  bool _isLoading = false;

  final List<String> _issueTypes = [
    'Unexpected Damage',
    'Missing Part',
    'Safety Concern',
    'Customer Change',
    'Other',
  ];

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final remote = ref.read(technicianRemoteDataSourceProvider);
      await remote.escalateIssue({
        'jobCardRef': widget.jobCardRef,
        'technicianEmpId': widget.technicianEmpId,
        'issueType': _issueType,
        'description': _descCtrl.text.trim(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Issue escalated to supervisor')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to escalate issue: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.r24),
          ),
        ),
        padding: const EdgeInsets.all(AppDimensions.s16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.flag_rounded, color: AppColors.danger),
                  const SizedBox(width: 8),
                  Text(
                    'Flag an Issue',
                    style: AppTextStyles.rajdhaniTitle(color: AppColors.danger),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Issue Type:',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _issueTypes.map((type) {
                  final isSelected = _issueType == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _issueType = type);
                    },
                    selectedColor: AppColors.danger.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.danger : AppColors.text3,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description *',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: AppColors.primaryBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.r12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (v.trim().split('\n').length < 2 && v.trim().length < 20) {
                    return 'Please provide more details (at least 2 lines or 20 chars)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Escalate to Supervisor',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
