import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';

class AdvisorVehicleCheckinView extends ConsumerStatefulWidget {
  final String bookingId;
  final String customerName;
  final String vehicleInfo;

  const AdvisorVehicleCheckinView({
    super.key,
    required this.bookingId,
    required this.customerName,
    required this.vehicleInfo,
  });

  @override
  ConsumerState<AdvisorVehicleCheckinView> createState() => _AdvisorVehicleCheckinViewState();
}

class _AdvisorVehicleCheckinViewState extends ConsumerState<AdvisorVehicleCheckinView> {
  int _step = 0;
  final _odometerCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _fuelLevel = '1/4';
  final List<String> _damages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _odometerCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _addDamage(String area) {
    showDialog(
      context: context,
      builder: (_) {
        final ctrl = TextEditingController();
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Damage on $area', style: const TextStyle(color: AppColors.textPrimary)),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              hintText: 'Describe damage (e.g. scratch, dent)',
              filled: true,
              fillColor: AppColors.primaryBg,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (ctrl.text.trim().isNotEmpty) {
                  setState(() => _damages.add('$area: ${ctrl.text.trim()}'));
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final remote = ref.read(advisorRemoteDataSourceProvider);
      final ok = await remote.checkInVehicle(widget.bookingId, {
        'odometer': _odometerCtrl.text.trim(),
        'fuelLevel': _fuelLevel,
        'existingDamages': _damages,
        'customerNote': _notesCtrl.text.trim(),
      });
      if (mounted) {
        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehicle checked in successfully')));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to check in')));
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => _step == 0 ? Navigator.pop(context) : setState(() => _step = 0),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vehicle Check-In',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            ),
            Text(
              '${widget.vehicleInfo} · ${widget.customerName}',
              style: const TextStyle(fontSize: 13, color: AppColors.text3),
            ),
          ],
        ),
      ),
      body: _step == 0 ? _buildStep0() : _buildStep1(),
    );
  }

  Widget _buildStep0() {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.s16),
      children: [
        const Text(
          'Vehicle Intake',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _odometerCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Odometer Reading (km)',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.r12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Fuel Level',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: '1/4', label: Text('1/4')),
            ButtonSegment(value: '1/2', label: Text('1/2')),
            ButtonSegment(value: '3/4', label: Text('3/4')),
            ButtonSegment(value: 'Full', label: Text('Full')),
          ],
          selected: {_fuelLevel},
          onSelectionChanged: (set) => setState(() => _fuelLevel = set.first),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.accent.withValues(alpha: 0.2);
              }
              return AppColors.surface;
            }),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _notesCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Customer Notes',
            filled: true,
            fillColor: AppColors.surface,
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
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r12)),
            ),
            onPressed: () => setState(() => _step = 1),
            child: const Text('Next', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.s16),
      children: [
        const Text(
          'Document Existing Condition',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 8),
        const Text('Tap an area to add damage notes', style: TextStyle(color: AppColors.text3, fontSize: 13)),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _damageBtn('Front'),
            _damageBtn('Rear'),
            _damageBtn('Left Side'),
            _damageBtn('Right Side'),
            _damageBtn('Roof/Top'),
          ],
        ),
        const SizedBox(height: 24),
        if (_damages.isNotEmpty) ...[
          const Text(
            'Noted Damages:',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _damages
                .map(
                  (d) => Chip(
                    label: Text(d, style: const TextStyle(fontSize: 12)),
                    onDeleted: () => setState(() => _damages.remove(d)),
                    backgroundColor: AppColors.dangerBg,
                    deleteIconColor: AppColors.danger,
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r12)),
            ),
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Proceed to Check-In', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _damageBtn(String label) {
    return OutlinedButton(
      onPressed: () => _addDamage(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r8)),
      ),
      child: Text(label),
    );
  }
}
