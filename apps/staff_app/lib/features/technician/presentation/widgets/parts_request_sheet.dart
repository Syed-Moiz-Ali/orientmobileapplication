import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
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

    setState(() => _isLoading = true);
    try {
      final remote = ref.read(technicianRemoteDataSourceProvider);
      await remote.requestPart({
        'jobCardRef': widget.jobCardRef,
        'technicianEmpId': widget.technicianEmpId,
        'partName': _partNameCtrl.text.trim(),
        'partNumber': _partNumberCtrl.text.trim(),
        'quantity': _quantity,
        'urgency': _urgency,
        'notes': _notesCtrl.text.trim(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Parts request submitted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to request part: $e')));
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
              Text(
                'Request a Part',
                style: AppTextStyles.rajdhaniTitle(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _partNameCtrl,
                decoration: InputDecoration(
                  labelText: 'Part Name *',
                  filled: true,
                  fillColor: AppColors.primaryBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.r12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _partNumberCtrl,
                decoration: InputDecoration(
                  labelText: 'Part Number (Optional)',
                  filled: true,
                  fillColor: AppColors.primaryBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.r12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'Quantity:',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: AppColors.text3,
                    ),
                  ),
                  Text(
                    '$_quantity',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _quantity++),
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Urgency:',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text(
                        'Normal',
                        style: TextStyle(fontSize: 14),
                      ),
                      value: 'Normal',
                      groupValue: _urgency,
                      onChanged: (v) => setState(() => _urgency = v!),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text(
                        'Urgent',
                        style: TextStyle(fontSize: 14),
                      ),
                      value: 'Urgent',
                      groupValue: _urgency,
                      onChanged: (v) => setState(() => _urgency = v!),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  filled: true,
                  fillColor: AppColors.primaryBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.r12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
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
                          'Submit Request',
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
