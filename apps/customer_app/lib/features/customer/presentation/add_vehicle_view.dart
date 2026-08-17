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
    final id = _isEditing
        ? widget.vehicleId!
        : now.millisecondsSinceEpoch.toString();
    var vehicle = CustomerVehicleEntity(
      id: id,
      brand: _brandCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
      plateNumber: _plateCtrl.text.trim().toUpperCase(),
      vin: _vinCtrl.text.trim().toUpperCase(),
      color: _colorCtrl.text.trim(),
      year: int.tryParse(_yearCtrl.text.trim()) ?? now.year,
      mileage: _mileageCtrl.text.trim().isEmpty
          ? '0 km'
          : _mileageCtrl.text.trim(),
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
            brand: vehicle.brand,
            model: vehicle.model,
            plateNumber: vehicle.plateNumber,
            vin: vehicle.vin,
            color: vehicle.color,
            year: vehicle.year,
            mileage: vehicle.mileage,
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
            brand: vehicle.brand,
            model: vehicle.model,
            plateNumber: vehicle.plateNumber,
            vin: vehicle.vin,
            color: vehicle.color,
            year: vehicle.year,
            mileage: vehicle.mileage,
            lastService: vehicle.lastService,
            nextDue: vehicle.nextDue,
            healthScore: vehicle.healthScore,
          );
        }
      }
    } catch (e) {
      if (e is NetworkException) {
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
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is AppException ? e.message : 'Could not save vehicle.',
            ),
          ),
        );
        setState(() => _isSaving = false);
        return;
      }
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      // ── BOTTOM DOCKED CHECKOUT BAR ─────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(
          24,
        ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: _isSaving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              disabledBackgroundColor: colorScheme.surfaceContainerHighest,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: _isSaving
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: colorScheme.onPrimary,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    _isEditing ? 'Update Vehicle' : 'Save Vehicle to Garage',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(title: _isEditing ? 'Edit Vehicle' : 'Add Vehicle'),
            Divider(height: 1, color: colorScheme.outlineVariant),
            Expanded(
              child: AppResponsivePage(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // ── VEHICLE PHOTO ATTACHMENT CARD ──────────────────────
                      Center(
                        child: Container(
                          width: double.infinity,
                          height: 160,
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withValues(
                                  alpha: 0.05,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
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
                                        colorScheme.primaryContainer.withValues(
                                          alpha: 0.4,
                                        ),
                                        colorScheme.surface,
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
                                          color: colorScheme.primary.withValues(
                                            alpha: 0.15,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.add_a_photo_rounded,
                                          color: colorScheme.primary,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Upload Vehicle Photo',
                                        style: textTheme.titleSmall?.copyWith(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Tap to capture or choose photo from library',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── LIVE PLATE PREVIEW ─────────────────────────────────
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFACC15), // Yellow Plate
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withValues(
                                  alpha: 0.1,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF1D4ED8,
                                  ), // UAE plate styling
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'UAE',
                                  style: textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
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
                      const SizedBox(height: 32),

                      // ── QUICK BRAND SELECTOR ───────────────────────────────
                      _SectionHeader(
                        title: 'Quick Brand Select',
                        subtitle: 'Tap a popular brand or enter manually below',
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 44,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _popularBrands.length,
                          itemBuilder: (ctx, i) {
                            final b = _popularBrands[i];
                            final sel =
                                _brandCtrl.text.trim().toLowerCase() ==
                                b.toLowerCase();
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Material(
                                color: sel
                                    ? colorScheme.primary
                                    : colorScheme.surface,
                                borderRadius: BorderRadius.circular(100),
                                child: InkWell(
                                  onTap: () =>
                                      setState(() => _brandCtrl.text = b),
                                  borderRadius: BorderRadius.circular(100),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                        color: sel
                                            ? Colors.transparent
                                            : colorScheme.outlineVariant,
                                      ),
                                    ),
                                    child: Text(
                                      b,
                                      style: textTheme.labelMedium?.copyWith(
                                        color: sel
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurface,
                                        fontWeight: sel
                                            ? FontWeight.w900
                                            : FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── VEHICLE IDENTITY SECTION ───────────────────────────
                      _SectionHeader(
                        title: 'Vehicle Identity',
                        subtitle:
                            'Enter registration details as they appear on the V5C logbook',
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        borderRadius: 24,
                        elevation: 0,
                        padding: const EdgeInsets.all(20),
                        color: colorScheme.surface,
                        borderColor: colorScheme.outlineVariant,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        child: Column(
                          children: [
                            _FormRow(
                              icon: Icons.directions_car_rounded,
                              label: 'Brand / Make',
                              colorScheme: colorScheme,
                              child: TextFormField(
                                controller: _brandCtrl,
                                validator: (v) => v?.trim().isEmpty == true
                                    ? 'Required'
                                    : null,
                                decoration: _dec(
                                  'e.g. BMW, Toyota, Audi',
                                  colorScheme,
                                ),
                              ),
                            ),
                            Divider(
                              height: 32,
                              color: colorScheme.outlineVariant,
                            ),
                            _FormRow(
                              icon: Icons.minor_crash_rounded,
                              label: 'Model',
                              colorScheme: colorScheme,
                              child: TextFormField(
                                controller: _modelCtrl,
                                validator: (v) => v?.trim().isEmpty == true
                                    ? 'Required'
                                    : null,
                                decoration: _dec(
                                  'e.g. 3 Series 320d, Corolla',
                                  colorScheme,
                                ),
                              ),
                            ),
                            Divider(
                              height: 32,
                              color: colorScheme.outlineVariant,
                            ),
                            _FormRow(
                              icon: Icons.pin_rounded,
                              label: 'License Plate',
                              colorScheme: colorScheme,
                              child: TextFormField(
                                controller: _plateCtrl,
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (v) => v?.trim().isEmpty == true
                                    ? 'Required'
                                    : null,
                                decoration: _dec('e.g. AB24 XYZ', colorScheme),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── ADDITIONAL DETAILS SECTION ─────────────────────────
                      _SectionHeader(
                        title: 'Additional Details',
                        subtitle:
                            'Year, colour & mileage help us prepare accurate service quotes',
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        borderRadius: 24,
                        elevation: 0,
                        padding: const EdgeInsets.all(20),
                        color: colorScheme.surface,
                        borderColor: colorScheme.outlineVariant,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        child: Column(
                          children: [
                            _FormRow(
                              icon: Icons.calendar_today_rounded,
                              label: 'Year',
                              colorScheme: colorScheme,
                              child: TextFormField(
                                controller: _yearCtrl,
                                keyboardType: TextInputType.number,
                                decoration: _dec('e.g. 2023', colorScheme),
                              ),
                            ),
                            Divider(
                              height: 32,
                              color: colorScheme.outlineVariant,
                            ),
                            _FormRow(
                              icon: Icons.palette_outlined,
                              label: 'Colour',
                              colorScheme: colorScheme,
                              child: TextFormField(
                                controller: _colorCtrl,
                                decoration: _dec(
                                  'e.g. Metallic Blue',
                                  colorScheme,
                                ),
                              ),
                            ),
                            Divider(
                              height: 32,
                              color: colorScheme.outlineVariant,
                            ),
                            _FormRow(
                              icon: Icons.speed_rounded,
                              label: 'Mileage',
                              colorScheme: colorScheme,
                              child: TextFormField(
                                controller: _mileageCtrl,
                                keyboardType: TextInputType.number,
                                decoration: _dec('e.g. 42,100 km', colorScheme),
                              ),
                            ),
                            Divider(
                              height: 32,
                              color: colorScheme.outlineVariant,
                            ),
                            _FormRow(
                              icon: Icons.fingerprint_rounded,
                              label: 'VIN (Optional)',
                              colorScheme: colorScheme,
                              child: TextFormField(
                                controller: _vinCtrl,
                                textCapitalization:
                                    TextCapitalization.characters,
                                decoration: _dec(
                                  '17-digit VIN code',
                                  colorScheme,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 60),
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

InputDecoration _dec(String hint, ColorScheme colorScheme) => InputDecoration(
  hintText: hint,
  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
  filled: true,
  fillColor: colorScheme.surfaceContainerHighest,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide.none,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: colorScheme.primary, width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: colorScheme.error),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: colorScheme.error, width: 2),
  ),
);

class _FormRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;
  final ColorScheme colorScheme;

  const _FormRow({
    required this.icon,
    required this.label,
    required this.child,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: colorScheme.onSurfaceVariant, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
