import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';

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
    'BMW', 'Toyota', 'Mercedes-Benz', 'Audi', 'Ford',
    'Honda', 'Nissan', 'Hyundai', 'Volkswagen',
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
      mileage: _mileageCtrl.text.trim().isEmpty ? '0 miles' : _mileageCtrl.text.trim(),
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
            brand: vehicle.brand, model: vehicle.model,
            plateNumber: vehicle.plateNumber, vin: vehicle.vin,
            color: vehicle.color, year: vehicle.year,
            mileage: vehicle.mileage, lastService: vehicle.lastService,
            nextDue: vehicle.nextDue, healthScore: vehicle.healthScore,
          );
        }
      } else {
        final resp = await remote.addVehicle(vehicle.toJson());
        if (resp.id.isNotEmpty) {
          vehicle = CustomerVehicleEntity(
            id: resp.id,
            brand: vehicle.brand, model: vehicle.model,
            plateNumber: vehicle.plateNumber, vin: vehicle.vin,
            color: vehicle.color, year: vehicle.year,
            mileage: vehicle.mileage, lastService: vehicle.lastService,
            nextDue: vehicle.nextDue, healthScore: vehicle.healthScore,
          );
        }
      }
    } catch (_) {
      final box = Hive.box<dynamic>('customer_cache');
      final local = GenericLocalDataSource(box);
      await local.save('vehicle_$id', vehicle.toJson());
      final cached = List<Map<String, dynamic>>.from(
        (box.get('cached_vehicles') as List?)?.cast() ?? const [],
      );
      cached.removeWhere((m) => m['id'] == id);
      cached.add(vehicle.toJson());
      await box.put('cached_vehicles', cached);
      final queue = ref.read(syncQueueProvider);
      await queue.enqueue(
        SyncOperation(
          id: id,
          entityType: 'vehicle',
          entityId: id,
          changeType: _isEditing ? ChangeType.update : ChangeType.create,
          payload: vehicle.toJson(),
          timestamp: now.millisecondsSinceEpoch,
        ),
      );
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(title: _isEditing ? 'Edit Vehicle' : 'Add Vehicle'),
            const Divider(height: 1, color: AppColors.line),
            Expanded(
              child: AppResponsivePage(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppDimensions.s16),

                      // VEHICLE PHOTO ATTACHMENT CARD
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 160,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primaryBg,
                                            AppColors.surface,
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 52,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withValues(alpha: 0.12),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.add_a_photo_rounded,
                                              color: AppColors.primary,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(height: AppDimensions.s8),
                                          Text(
                                            'Upload Vehicle Photo',
                                            style: textTheme.titleSmall?.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Tap camera icon to capture or choose photo',
                                            style: textTheme.labelSmall?.copyWith(
                                              color: AppColors.text3,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.s20),

                      // LIVE PLATE PREVIEW
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.s20,
                            vertical: AppDimensions.s10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFACC15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.black, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1D4ED8),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'UK',
                                  style: textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.s14),
                              Text(
                                _plateCtrl.text.isNotEmpty
                                    ? _plateCtrl.text.toUpperCase()
                                    : 'REG PLATE',
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  fontFamily: AppFontFamilies.mono,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.s20),

                      // QUICK BRAND SELECTOR
                      _SectionHeader(
                        title: 'Quick Brand Select',
                        subtitle: 'Tap a brand or type manually below',
                      ),
                      const SizedBox(height: AppDimensions.s10),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _popularBrands.length,
                          itemBuilder: (ctx, i) {
                            final b = _popularBrands[i];
                            final sel = _brandCtrl.text.trim().toLowerCase() == b.toLowerCase();
                            return Padding(
                              padding: const EdgeInsets.only(right: AppDimensions.s8),
                              child: Material(
                                color: sel ? AppColors.primary : AppColors.surface,
                                borderRadius: BorderRadius.circular(AppDimensions.rPill),
                                child: InkWell(
                                  onTap: () => setState(() => _brandCtrl.text = b),
                                  borderRadius: BorderRadius.circular(AppDimensions.rPill),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimensions.s14,
                                      vertical: AppDimensions.s8,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(AppDimensions.rPill),
                                      border: Border.all(
                                        color: sel ? Colors.transparent : AppColors.border,
                                      ),
                                    ),
                                    child: Text(
                                      b,
                                      style: textTheme.labelSmall?.copyWith(
                                        color: sel ? Colors.white : AppColors.textPrimary,
                                        fontWeight: sel ? FontWeight.w900 : FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppDimensions.s24),

                      // VEHICLE IDENTITY SECTION
                      _SectionHeader(
                        title: 'Vehicle Identity',
                        subtitle: 'Enter registration details as they appear on the V5C logbook',
                      ),
                      const SizedBox(height: AppDimensions.s10),
                      AppCard(
                        borderRadius: 24,
                        padding: const EdgeInsets.all(AppDimensions.s16),
                        color: AppColors.surface,
                        borderColor: AppColors.border,
                        child: Column(
                          children: [
                            _FormRow(
                              icon: Icons.directions_car_rounded,
                              label: 'Brand / Make',
                              child: TextFormField(
                                controller: _brandCtrl,
                                validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                                decoration: _dec('e.g. BMW, Toyota, Audi'),
                              ),
                            ),
                            const Divider(height: AppDimensions.s24, color: AppColors.line),
                            _FormRow(
                              icon: Icons.minor_crash_rounded,
                              label: 'Model',
                              child: TextFormField(
                                controller: _modelCtrl,
                                validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                                decoration: _dec('e.g. 3 Series 320d, Corolla'),
                              ),
                            ),
                            const Divider(height: AppDimensions.s24, color: AppColors.line),
                            _FormRow(
                              icon: Icons.pin_rounded,
                              label: 'License Plate',
                              child: TextFormField(
                                controller: _plateCtrl,
                                textCapitalization: TextCapitalization.characters,
                                validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                                decoration: _dec('e.g. AB24 XYZ'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.s20),

                      // ADDITIONAL DETAILS SECTION
                      _SectionHeader(
                        title: 'Additional Details',
                        subtitle: 'Year, colour & mileage help us prepare accurate service quotes',
                      ),
                      const SizedBox(height: AppDimensions.s10),
                      AppCard(
                        borderRadius: 24,
                        padding: const EdgeInsets.all(AppDimensions.s16),
                        color: AppColors.surface,
                        borderColor: AppColors.border,
                        child: Column(
                          children: [
                            _FormRow(
                              icon: Icons.calendar_today_rounded,
                              label: 'Year',
                              child: TextFormField(
                                controller: _yearCtrl,
                                keyboardType: TextInputType.number,
                                decoration: _dec('e.g. 2023'),
                              ),
                            ),
                            const Divider(height: AppDimensions.s24, color: AppColors.line),
                            _FormRow(
                              icon: Icons.palette_outlined,
                              label: 'Colour',
                              child: TextFormField(
                                controller: _colorCtrl,
                                decoration: _dec('e.g. Metallic Blue'),
                              ),
                            ),
                            const Divider(height: AppDimensions.s24, color: AppColors.line),
                            _FormRow(
                              icon: Icons.speed_rounded,
                              label: 'Mileage',
                              child: TextFormField(
                                controller: _mileageCtrl,
                                keyboardType: TextInputType.number,
                                decoration: _dec('e.g. 42,100 miles'),
                              ),
                            ),
                            const Divider(height: AppDimensions.s24, color: AppColors.line),
                            _FormRow(
                              icon: Icons.fingerprint_rounded,
                              label: 'VIN (Optional)',
                              child: TextFormField(
                                controller: _vinCtrl,
                                textCapitalization: TextCapitalization.characters,
                                decoration: _dec('17-digit VIN code'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.s28),

                      // SAVE BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.rPill),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  _isEditing ? 'Update Vehicle' : 'Save Vehicle to Garage',
                                  style: textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.s32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _dec(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: AppColors.text4, fontSize: 13),
  filled: true,
  fillColor: AppColors.surfaceAlt,
  contentPadding: const EdgeInsets.symmetric(
    horizontal: AppDimensions.s12,
    vertical: AppDimensions.s10,
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppDimensions.r10),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppDimensions.r10),
    borderSide: BorderSide.none,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppDimensions.r10),
    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppDimensions.r10),
    borderSide: const BorderSide(color: AppColors.danger),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppDimensions.r10),
    borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
  ),
);

class _FormRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const _FormRow({required this.icon, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: AppColors.primaryBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: AppDimensions.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.text3,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              child,
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.text3,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
