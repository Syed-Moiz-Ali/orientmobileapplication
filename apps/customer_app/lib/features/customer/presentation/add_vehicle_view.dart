import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/features/customer/data/datasources/customer_remote_datasource.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';

class AddVehicleView extends ConsumerStatefulWidget {
  final String? vehicleId;
  const AddVehicleView({super.key, this.vehicleId});
  @override
  ConsumerState<AddVehicleView> createState() => _AddVehicleViewState();
}

class _AddVehicleViewState extends ConsumerState<AddVehicleView> {
  final _formKey = GlobalKey<FormState>();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _vinCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _mileageCtrl = TextEditingController();
  bool _isSaving = false;
  bool get _isEditing => widget.vehicleId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _loadVehicle();
  }

  void _loadVehicle() {
    final state = ref.read(customerDashboardProvider);
    final v = state.vehicles.where((v) => v.id == widget.vehicleId).firstOrNull;
    if (v != null) {
      _brandCtrl.text = v.brand;
      _modelCtrl.text = v.model;
      _plateCtrl.text = v.plateNumber;
      _vinCtrl.text = v.vin;
      _yearCtrl.text = v.year.toString();
      _colorCtrl.text = v.color;
      _mileageCtrl.text = v.mileage;
    }
  }

  @override
  void dispose() {
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _plateCtrl.dispose();
    _vinCtrl.dispose();
    _yearCtrl.dispose();
    _colorCtrl.dispose();
    _mileageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final now = DateTime.now();
    final id = _isEditing ? widget.vehicleId! : now.millisecondsSinceEpoch.toString();
    final vehicle = CustomerVehicleEntity(
      id: id, brand: _brandCtrl.text.trim(), model: _modelCtrl.text.trim(),
      plateNumber: _plateCtrl.text.trim(), vin: _vinCtrl.text.trim(),
      color: _colorCtrl.text.trim(), year: int.tryParse(_yearCtrl.text.trim()) ?? now.year,
      mileage: _mileageCtrl.text.trim().isEmpty ? '0 km' : _mileageCtrl.text.trim(),
      lastService: _isEditing ? _lastService() : 'N/A',
      nextDue: 'N/A', healthScore: 100,
    );

    try {
      final remote = ref.read(customerRemoteDataSourceProvider);
      if (_isEditing) {
        await remote.updateVehicle(id, vehicle.toJson());
      } else {
        await remote.addVehicle(vehicle.toJson());
      }
    } catch (_) {
      // offline — save locally and sync later
      final local = GenericLocalDataSource(Hive.box<dynamic>('customer_cache'));
      await local.save('vehicle_$id', vehicle.toJson());
      final queue = ref.read(syncQueueProvider);
      await queue.enqueue(SyncOperation(
        id: id, entityType: 'vehicle', entityId: id,
        changeType: _isEditing ? ChangeType.update : ChangeType.create,
        payload: vehicle.toJson(), timestamp: now.millisecondsSinceEpoch,
      ));
    }

    ref.read(customerDashboardProvider.notifier).addVehicle(vehicle);
    if (!mounted) return;
    Navigator.pop(context);
  }

  String _lastService() {
    final state = ref.read(customerDashboardProvider);
    final v = state.vehicles.where((v) => v.id == widget.vehicleId).firstOrNull;
    return v?.lastService ?? 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(isEditing: _isEditing, onBack: () => Navigator.pop(context)),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Vehicle Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      const Text('Fill in the information below', style: TextStyle(fontSize: 13, color: AppColors.text3)),
                      const SizedBox(height: 18),
                      _Field(label: 'Brand', hint: 'e.g. Toyota', icon: Icons.badge_outlined, ctrl: _brandCtrl),
                      const SizedBox(height: 12),
                      _Field(label: 'Model', hint: 'e.g. Camry', icon: Icons.directions_car_outlined, ctrl: _modelCtrl),
                      const SizedBox(height: 12),
                      _Field(label: 'Plate Number', hint: 'e.g. ABC 1234', icon: Icons.confirmation_number_outlined, ctrl: _plateCtrl),
                      const SizedBox(height: 12),
                      _Field(label: 'VIN', hint: 'e.g. 1HGCM82633A004352', icon: Icons.qr_code_outlined, ctrl: _vinCtrl),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(flex: 2, child: _Field(label: 'Year', hint: 'e.g. 2020', icon: Icons.calendar_today_outlined, ctrl: _yearCtrl, keyboardType: TextInputType.number)),
                          const SizedBox(width: 12),
                          Expanded(flex: 3, child: _Field(label: 'Color', hint: 'e.g. White', icon: Icons.palette_outlined, ctrl: _colorCtrl)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _Field(label: 'Mileage', hint: 'e.g. 25,000 km', icon: Icons.speed_outlined, ctrl: _mileageCtrl),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            _BottomBar(
              label: _isEditing ? 'Update Vehicle' : 'Add Vehicle',
              isLoading: _isSaving,
              onTap: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController ctrl;
  final TextInputType? keyboardType;
  const _Field({required this.label, required this.hint, required this.icon, required this.ctrl, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text3)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(icon, size: 18, color: AppColors.text4),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: ctrl,
                  keyboardType: keyboardType,
                  style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: hint, border: InputBorder.none,
                    hintStyle: const TextStyle(color: AppColors.text4, fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onBack;
  const _TopBar({required this.isEditing, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.bg, border: Border.all(color: AppColors.border)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.text3),
            ),
          ),
          const SizedBox(width: 12),
          Text(isEditing ? 'Edit Vehicle' : 'Add Vehicle', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;
  const _BottomBar({required this.label, required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(18, 12, 18, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : onTap,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          child: isLoading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(label),
        ),
      ),
    );
  }
}
