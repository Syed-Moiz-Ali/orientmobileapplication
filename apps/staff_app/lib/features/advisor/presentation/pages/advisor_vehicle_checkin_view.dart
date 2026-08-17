import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            'Damage on $area',
            style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w800),
          ),
          content: TextField(
            controller: ctrl,
            decoration: InputDecoration(
              hintText: 'Describe damage (e.g. scratch, dent)',
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (ctrl.text.trim().isNotEmpty) {
                  setState(() => _damages.add('$area: ${ctrl.text.trim()}'));
                }
                Navigator.pop(context);
              },
              child: const Text('Add Damage'),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => _step == 0 ? Navigator.pop(context) : setState(() => _step = 0),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Intake',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: colorScheme.onSurface),
            ),
            Text(
              '${widget.vehicleInfo} · ${widget.customerName}',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
      body: _step == 0 ? _buildStep0() : _buildStep1(),
    );
  }

  Widget _buildStep0() {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _odometerCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Odometer Reading (km)',
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 16),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: '1/4', label: Text('1/4')),
            ButtonSegment(value: '1/2', label: Text('1/2')),
            ButtonSegment(value: '3/4', label: Text('3/4')),
            ButtonSegment(value: 'Full', label: Text('Full')),
          ],
          selected: {_fuelLevel},
          onSelectionChanged: (set) => setState(() => _fuelLevel = set.first),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _notesCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Customer Notes',
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: () => setState(() => _step = 1),
            child: const Text('Next: Document Condition'),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.4,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _damageBtn('Front'),
            _damageBtn('Rear'),
            _damageBtn('Left Side'),
            _damageBtn('Right Side'),
            _damageBtn('Roof'),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          children: _damages
              .map(
                (d) => Chip(
                  label: Text(d),
                  onDeleted: () => setState(() => _damages.remove(d)),
                  backgroundColor: colorScheme.error.withValues(alpha: 0.12),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 40),
        SizedBox(
          height: 48,
          child: ElevatedButton(onPressed: _isLoading ? null : _submit, child: const Text('Complete Intake')),
        ),
      ],
    );
  }

  Widget _damageBtn(String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: () => _addDamage(label),
      style: OutlinedButton.styleFrom(side: BorderSide(color: colorScheme.outlineVariant)),
      child: Text(label),
    );
  }
}
