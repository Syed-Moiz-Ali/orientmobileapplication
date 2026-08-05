import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
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

  static const List<String> _popularBrands = [
    'BMW',
    'Toyota',
    'Mercedes-Benz',
    'Audi',
    'Ford',
    'Honda',
    'Nissan',
    'Hyundai',
    'Volkswagen',
  ];

  @override
  void initState() {
    super.initState();
    _plateCtrl.addListener(() => setState(() {}));
    _brandCtrl.addListener(() => setState(() {}));
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
    var vehicle = CustomerVehicleEntity(
      id: id,
      brand: _brandCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
      plateNumber: _plateCtrl.text.trim().toUpperCase(),
      vin: _vinCtrl.text.trim().toUpperCase(),
      color: _colorCtrl.text.trim(),
      year: int.tryParse(_yearCtrl.text.trim()) ?? now.year,
      mileage: _mileageCtrl.text.trim().isEmpty ? '0 km' : _mileageCtrl.text.trim(),
      lastService: _isEditing ? _lastService() : 'N/A',
      nextDue: 'N/A',
      healthScore: 90,
    );

    try {
      final remote = ref.read(customerRemoteDataSourceProvider);
      if (_isEditing) {
        final resp = await remote.updateVehicle(id, vehicle.toJson());
        if (resp.id.isNotEmpty) {
          vehicle = CustomerVehicleEntity(
            id: resp.id,
            brand: resp.brand.isNotEmpty ? resp.brand : vehicle.brand,
            model: resp.model.isNotEmpty ? resp.model : vehicle.model,
            plateNumber: resp.plateNumber.isNotEmpty ? resp.plateNumber : vehicle.plateNumber,
            vin: resp.vin.isNotEmpty ? resp.vin : vehicle.vin,
            color: resp.color.isNotEmpty ? resp.color : vehicle.color,
            year: resp.year > 0 ? resp.year : vehicle.year,
            mileage: resp.mileage.isNotEmpty ? resp.mileage : vehicle.mileage,
            lastService: vehicle.lastService,
            nextDue: vehicle.nextDue,
            healthScore: vehicle.healthScore,
          );
        }
      } else {
        final resp = await remote.addVehicle(vehicle.toJson());
        if (resp.id.isNotEmpty) {
          vehicle = CustomerVehicleEntity(
            id: resp.id,
            brand: resp.brand.isNotEmpty ? resp.brand : vehicle.brand,
            model: resp.model.isNotEmpty ? resp.model : vehicle.model,
            plateNumber: resp.plateNumber.isNotEmpty ? resp.plateNumber : vehicle.plateNumber,
            vin: resp.vin.isNotEmpty ? resp.vin : vehicle.vin,
            color: resp.color.isNotEmpty ? resp.color : vehicle.color,
            year: resp.year > 0 ? resp.year : vehicle.year,
            mileage: resp.mileage.isNotEmpty ? resp.mileage : vehicle.mileage,
            lastService: vehicle.lastService,
            nextDue: vehicle.nextDue,
            healthScore: vehicle.healthScore,
          );
        }
      }
    } catch (_) {
      // offline fallback
      final local = GenericLocalDataSource(Hive.box<dynamic>('customer_cache'));
      await local.save('vehicle_$id', vehicle.toJson());
      final queue = ref.read(syncQueueProvider);
      await queue.enqueue(SyncOperation(
        id: id,
        entityType: 'vehicle',
        entityId: id,
        changeType: _isEditing ? ChangeType.update : ChangeType.create,
        payload: vehicle.toJson(),
        timestamp: now.millisecondsSinceEpoch,
      ));
    }

    ref.read(customerDashboardProvider.notifier).refresh();
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
                      // Header Card
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.directions_car_rounded,
                              color: AppColors.accent,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isEditing ? 'Update Vehicle' : 'Register New Vehicle',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Track maintenance, job cards & MOT reminders',
                                style: TextStyle(fontSize: 12, color: AppColors.text3),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Live License Plate Badge Preview
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFACC15), // Yellow UK Style Plate
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1A000000),
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1D4ED8),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: const Text(
                                  'UK',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _plateCtrl.text.isNotEmpty
                                    ? _plateCtrl.text.toUpperCase()
                                    : 'REG PLATE',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  letterSpacing: 2.0,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Popular Brand Chips
                      const Text(
                        'Select Brand',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 36,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _popularBrands.length,
                          itemBuilder: (ctx, i) {
                            final b = _popularBrands[i];
                            final sel = _brandCtrl.text.trim().toLowerCase() == b.toLowerCase();
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(b),
                                selected: sel,
                                selectedColor: AppColors.accent,
                                backgroundColor: AppColors.surface,
                                labelStyle: TextStyle(
                                  color: sel ? Colors.white : AppColors.textPrimary,
                                  fontSize: 12,
                                  fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                                ),
                                onSelected: (_) {
                                  setState(() => _brandCtrl.text = b);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Form Fields
                      _Field(
                        label: 'Make / Brand',
                        hint: 'e.g. Toyota, BMW, Ford',
                        icon: Icons.directions_car_filled_rounded,
                        ctrl: _brandCtrl,
                      ),
                      const SizedBox(height: 12),
                      _Field(
                        label: 'Model Name',
                        hint: 'e.g. Camry, 3 Series, Focus',
                        icon: Icons.subtitles_rounded,
                        ctrl: _modelCtrl,
                      ),
                      const SizedBox(height: 12),
                      _Field(
                        label: 'Registration Plate Number',
                        hint: 'e.g. AB19 XYZ',
                        icon: Icons.badge_rounded,
                        ctrl: _plateCtrl,
                      ),
                      const SizedBox(height: 12),
                      _Field(
                        label: 'VIN (Vehicle Identification Number)',
                        hint: '17-character chassis number (optional)',
                        icon: Icons.qr_code_2_rounded,
                        ctrl: _vinCtrl,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _Field(
                              label: 'Year',
                              hint: 'e.g. 2021',
                              icon: Icons.calendar_today_rounded,
                              ctrl: _yearCtrl,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: _Field(
                              label: 'Color',
                              hint: 'e.g. Black / Silver',
                              icon: Icons.palette_rounded,
                              ctrl: _colorCtrl,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _Field(
                        label: 'Current Odometer Mileage',
                        hint: 'e.g. 45,000 km',
                        icon: Icons.speed_rounded,
                        ctrl: _mileageCtrl,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ),
            _BottomBar(
              label: _isEditing ? 'Save Vehicle Changes' : 'Register Vehicle',
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

  const _Field({
    required this.label,
    required this.hint,
    required this.icon,
    required this.ctrl,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.text3,
          ),
        ),
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
              Icon(icon, size: 18, color: AppColors.accent),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: ctrl,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    hintStyle: const TextStyle(color: AppColors.text4, fontSize: 13),
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
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bg,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 14,
                color: AppColors.text3,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isEditing ? 'Edit Vehicle Details' : 'Register Vehicle',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
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
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: isLoading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
        ),
      ),
    );
  }
}
