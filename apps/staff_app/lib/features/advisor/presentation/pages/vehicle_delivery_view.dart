import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';

class VehicleDeliveryView extends ConsumerStatefulWidget {
  final String jobCardRef;

  const VehicleDeliveryView({super.key, required this.jobCardRef});

  @override
  ConsumerState<VehicleDeliveryView> createState() =>
      _VehicleDeliveryViewState();
}

class _VehicleDeliveryViewState extends ConsumerState<VehicleDeliveryView> {
  final _notesCtrl = TextEditingController();
  final List<bool> _checked = List.filled(5, false);
  bool _isLoading = false;

  final List<String> _checklist = [
    'Invoice copy provided to customer',
    'Vehicle keys handed over',
    'Vehicle documents returned',
    'Next service reminder given',
    'Warranty information explained',
  ];

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  bool get _allChecked => _checked.every((c) => c);

  Future<void> _deliver() async {
    setState(() => _isLoading = true);
    try {
      final remote = ref.read(advisorRemoteDataSourceProvider);
      final ok = await remote.deliverVehicle(widget.jobCardRef, {
        'notes': _notesCtrl.text.trim(),
      });
      if (mounted) {
        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle delivered successfully')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to complete delivery')),
          );
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vehicle Handover',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              widget.jobCardRef,
              style: const TextStyle(fontSize: 13, color: AppColors.text3),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.s16),
        children: [
          const Text(
            'Delivery Checklist',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: List.generate(_checklist.length, (i) {
                return CheckboxListTile(
                  title: Text(
                    _checklist[i],
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  value: _checked[i],
                  activeColor: AppColors.success,
                  onChanged: (v) => setState(() => _checked[i] = v ?? false),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Advisor Notes (Optional)',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              hintText: 'Add any final delivery notes',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.r12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.r12),
                ),
              ),
              onPressed: (_isLoading || !_allChecked) ? null : _deliver,
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
                      'Complete Delivery',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
