import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';

class CustomerBookServiceView extends ConsumerStatefulWidget {
  const CustomerBookServiceView({super.key});

  @override
  ConsumerState<CustomerBookServiceView> createState() => _CustomerBookServiceViewState();
}

class _CustomerBookServiceViewState extends ConsumerState<CustomerBookServiceView> {
  final _notesCtrl = TextEditingController();

  List<ServiceTypeResponse> _services = const [];
  List<String> _slots = const [];
  bool _loadingServices = true;
  bool _loadingSlots = false;
  bool _submitting = false;
  String? _error;

  // Wizard State
  int _currentStep = 0;
  String? _selectedServiceId;
  CustomerVehicleEntity? _selectedVehicle;
  DateTime? _selectedDate;
  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    final services = await ref.read(customerRemoteDataSourceProvider).getServiceTypes();
    if (!mounted) return;
    setState(() {
      _services = services;
      _loadingServices = false;
      _error = services.isEmpty ? 'No service packages available right now.' : null;
    });
  }

  Future<void> _loadSlots(DateTime date) async {
    setState(() {
      _selectedDate = date;
      _selectedTime = null;
      _loadingSlots = true;
      _slots = const [];
    });
    final iso =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final slots = await ref.read(customerRemoteDataSourceProvider).getAvailability(iso);
    if (!mounted) return;
    setState(() {
      _slots = slots;
      _loadingSlots = false;
    });
  }

  ServiceTypeResponse? get _selectedService {
    for (final s in _services) {
      if (s.id == _selectedServiceId) return s;
    }
    return null;
  }

  String get _displayDate {
    final d = _selectedDate;
    if (d == null) return 'Select date';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String _bookingDateForApi(DateTime date, String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final dateTime = DateTime(date.year, date.month, date.day, hour, minute);
    return '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')}T'
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:00';
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _selectedVehicle != null;
      case 1:
        return _selectedService != null;
      case 2:
        return _selectedDate != null && _selectedTime != null;
      case 3:
        return true;
      default:
        return false;
    }
  }

  Future<void> _confirm() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    final vehicle = _selectedVehicle!;
    final service = _selectedService!;
    final now = DateTime.now();
    final bookingId = now.millisecondsSinceEpoch.toString();
    final bookingTime = _selectedTime ?? '';
    final bookingDate = _bookingDateForApi(_selectedDate!, bookingTime);
    final payload = <String, dynamic>{
      'id': bookingId,
      'vehicleId': vehicle.id,
      'vehicleName': vehicle.displayName,
      'plateNumber': vehicle.plateNumber,
      'serviceId': service.id,
      'service': service.name,
      'serviceType': service.name,
      'date': _displayDate,
      'time': bookingTime,
      'bookingDate': bookingDate,
      'bookingTime': bookingTime,
      'status': BookingStatus.pending.name,
      'notes': _notesCtrl.text.trim(),
    };
    final remotePayload = <String, dynamic>{
      'vehicleId': vehicle.id.toString(),
      'vehicleName': vehicle.displayName,
      'plateNumber': vehicle.plateNumber,
      'serviceType': service.name,
      'bookingDate': bookingDate,
      'bookingTime': bookingTime,
      'notes': _notesCtrl.text.trim(),
    };

    try {
      final remote = ref.read(customerRemoteDataSourceProvider);
      final resp = await remote.createBooking(remotePayload);
      if (resp.id.isNotEmpty) {
        payload['id'] = resp.id;
      }
      if (resp.bookingRef.isNotEmpty) {
        payload['bookingRef'] = resp.bookingRef;
      }
    } catch (e) {
      if (e is NetworkException && e.message.toLowerCase().contains('receive data')) {
        if (!mounted) return;
        setState(() {
          _submitting = false;
          _error = 'Booking request timed out. Please check My Bookings before trying again.';
        });
        return;
      }
      final box = Hive.box<dynamic>('customer_cache');
      final local = GenericLocalDataSource(box);
      await local.save('booking_$bookingId', payload);
      final cached = List<Map<String, dynamic>>.from((box.get('cached_bookings') as List?)?.cast() ?? const []);
      cached.removeWhere((m) => m['id'] == bookingId);
      cached.add(payload);
      await box.put('cached_bookings', cached);
      final queue = ref.read(syncQueueProvider);
      await queue.enqueue(
        SyncOperation(
          id: bookingId,
          entityType: 'booking',
          entityId: bookingId,
          changeType: ChangeType.create,
          payload: payload,
          timestamp: now.millisecondsSinceEpoch,
        ),
      );
    }

    ref.invalidate(customerBookingsProvider);
    ref.read(customerDashboardProvider.notifier).refresh();

    if (!mounted) return;
    setState(() => _submitting = false);

    context.push(
      AppRoutes.customerBookingSuccess,
      extra: <String, dynamic>{
        'ref': (payload['bookingRef'] ?? payload['id'] ?? bookingId).toString(),
        'service': service.name,
        'date': _displayDate,
        'time': bookingTime,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final vehicles = ref.watch(customerDashboardProvider).vehicles;

    if (_selectedVehicle == null && vehicles.isNotEmpty) {
      _selectedVehicle = vehicles.first;
    }

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      // ── BOTTOM WIZARD CHECKOUT DOCK ────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24).copyWith(bottom: MediaQuery.of(context).padding.bottom + 24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          boxShadow: [
            BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, -8)),
          ],
        ),
        child: Row(
          children: [
            if (_currentStep > 0) ...[
              SizedBox(
                height: 56,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.onSurface,
                    side: BorderSide(color: colorScheme.outlineVariant),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  onPressed: () => setState(() => _currentStep--),
                  child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: SizedBox(
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                    disabledForegroundColor: colorScheme.onSurfaceVariant,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    elevation: 0,
                  ),
                  onPressed: !_canProceed
                      ? null
                      : () {
                          if (_currentStep < 3) {
                            setState(() => _currentStep++);
                          } else {
                            _confirm();
                          }
                        },
                  child: _submitting
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2.5),
                        )
                      : Text(
                          _currentStep == 3 ? 'Confirm & Reserve' : 'Continue',
                          style: textTheme.titleMedium?.copyWith(
                            color: _canProceed ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(title: 'Express Booking'),
            Divider(height: 1, color: colorScheme.outlineVariant),
            Expanded(
              child: AppResponsivePage(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // ── IMMERSIVE STEP PROGRESS BAR ──────────────────────────
                    _StepProgressBar(currentStep: _currentStep),
                    const SizedBox(height: 32),

                    // ── ERROR NOTIFICATION BANNER ────────────────────────────
                    if (_error != null) ...[
                      AppCard(
                        color: colorScheme.errorContainer,
                        borderColor: colorScheme.error.withValues(alpha: 0.5),
                        borderRadius: 24,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _error!,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.error,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ── STEP 0: SELECT VEHICLE WITH IMAGES ───────────────────
                    if (_currentStep == 0) ...[
                      _StepTitleBlock(
                        title: 'Select Your Vehicle',
                        subtitle: 'Choose which registered car requires service',
                      ),
                      const SizedBox(height: 24),
                      if (vehicles.isEmpty)
                        AppCard(
                          borderRadius: 24,
                          padding: const EdgeInsets.all(36),
                          color: colorScheme.surface,
                          borderColor: colorScheme.outlineVariant,
                          child: Column(
                            children: [
                              Icon(Icons.directions_car_outlined, color: colorScheme.onSurfaceVariant, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                'No vehicles in your garage',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 24),
                              OutlinedButton.icon(
                                onPressed: () => context.push(AppRoutes.customerAddVehicle),
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: const Text('Add Vehicle'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colorScheme.primary,
                                  side: BorderSide(color: colorScheme.primary),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: [
                            for (int i = 0; i < vehicles.length; i++) ...[
                              _VehicleSelectionCard(
                                vehicle: vehicles[i],
                                selected: _selectedVehicle?.id == vehicles[i].id,
                                imageUrl: i % 2 == 0
                                    ? 'https://images.unsplash.com/photo-1550355291-bbee04a92027?q=80&w=800&auto=format&fit=crop'
                                    : 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?q=80&w=800&auto=format&fit=crop',
                                onTap: () => setState(() => _selectedVehicle = vehicles[i]),
                              ),
                              if (vehicles[i] != vehicles.last) const SizedBox(height: 16),
                            ],
                          ],
                        ),
                    ],

                    // ── STEP 1: SELECT SERVICE PACKAGE ───────────────────────
                    if (_currentStep == 1) ...[
                      _StepTitleBlock(
                        title: 'Select Service Package',
                        subtitle: 'Tap to choose the appropriate maintenance level',
                      ),
                      const SizedBox(height: 24),
                      if (_loadingServices)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: CircularProgressIndicator(color: colorScheme.primary),
                          ),
                        )
                      else
                        AppCard(
                          borderRadius: 24,
                          padding: EdgeInsets.zero,
                          color: colorScheme.surface,
                          borderColor: colorScheme.outlineVariant,
                          child: Column(
                            children: [
                              for (int i = 0; i < _services.length; i++) ...[
                                _ServiceRow(
                                  service: _services[i],
                                  selected: _selectedServiceId == _services[i].id,
                                  onTap: () => setState(() => _selectedServiceId = _services[i].id),
                                ),
                                if (i < _services.length - 1) Divider(height: 1, color: colorScheme.outlineVariant),
                              ],
                            ],
                          ),
                        ),
                    ],

                    // ── STEP 2: INLINE DATE & TIME SLOT ──────────────────────
                    if (_currentStep == 2) ...[
                      _StepTitleBlock(
                        title: 'Select Date & Time',
                        subtitle: 'Pick your preferred workshop bay schedule',
                      ),
                      const SizedBox(height: 24),
                      AppCard(
                        borderRadius: 24,
                        padding: const EdgeInsets.all(24),
                        color: colorScheme.surface,
                        borderColor: colorScheme.outlineVariant,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Workshop Date',
                              style: textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Inline Horizontal Date Strip
                            SizedBox(
                              height: 84,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: 14,
                                separatorBuilder: (_, __) => const SizedBox(width: 10),
                                itemBuilder: (ctx, index) {
                                  final date = DateTime.now().add(Duration(days: index + 1));
                                  final isSelected =
                                      _selectedDate?.year == date.year &&
                                      _selectedDate?.month == date.month &&
                                      _selectedDate?.day == date.day;

                                  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                  final dayName = weekdays[date.weekday - 1];

                                  return GestureDetector(
                                    onTap: () => _loadSlots(date),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 64,
                                      decoration: BoxDecoration(
                                        color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            dayName,
                                            style: textTheme.labelSmall?.copyWith(
                                              color: isSelected
                                                  ? colorScheme.onPrimary.withValues(alpha: 0.8)
                                                  : colorScheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${date.day}',
                                            style: textTheme.titleMedium?.copyWith(
                                              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 28),
                            Divider(height: 1, color: colorScheme.outlineVariant),
                            const SizedBox(height: 24),
                            Text(
                              'Available Time Slots',
                              style: textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 14),
                            if (_loadingSlots)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: CircularProgressIndicator(strokeWidth: 2.5),
                                ),
                              )
                            else if (_slots.isNotEmpty)
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: _slots.map((slot) {
                                  final sel = _selectedTime == slot;
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedTime = slot),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: sel ? colorScheme.primary : colorScheme.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(100),
                                        border: Border.all(
                                          color: sel ? colorScheme.primary : colorScheme.outlineVariant,
                                        ),
                                      ),
                                      child: Text(
                                        slot,
                                        style: textTheme.labelMedium?.copyWith(
                                          color: sel ? colorScheme.onPrimary : colorScheme.onSurface,
                                          fontWeight: sel ? FontWeight.w900 : FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              )
                            else
                              Text(
                                _selectedDate == null
                                    ? 'Select a date above to view slots'
                                    : 'No available slots for this date.',
                                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                              ),
                          ],
                        ),
                      ),
                    ],

                    // ── STEP 3: REVIEW & SPECIAL NOTES ───────────────────────
                    if (_currentStep == 3) ...[
                      _StepTitleBlock(
                        title: 'Review Booking Details',
                        subtitle: 'Confirm your specifications and add optional notes',
                      ),
                      const SizedBox(height: 24),
                      AppCard(
                        borderRadius: 24,
                        padding: const EdgeInsets.all(24),
                        color: colorScheme.surface,
                        borderColor: colorScheme.outlineVariant,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ReviewRow(label: 'Selected Vehicle', value: _selectedVehicle?.displayName ?? 'None'),
                            const SizedBox(height: 16),
                            Divider(height: 1, color: colorScheme.outlineVariant),
                            const SizedBox(height: 16),
                            _ReviewRow(label: 'Service Package', value: _selectedService?.name ?? 'None'),
                            const SizedBox(height: 16),
                            Divider(height: 1, color: colorScheme.outlineVariant),
                            const SizedBox(height: 16),
                            _ReviewRow(
                              label: 'Scheduled Slot',
                              value: '$_displayDate at ${_selectedTime ?? "Not set"}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Special Service Notes',
                        style: textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _notesCtrl,
                        maxLines: 4,
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'e.g. Strange noise when braking, oil light on…',
                          hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                          filled: true,
                          fillColor: colorScheme.surface,
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: colorScheme.outlineVariant),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: colorScheme.outlineVariant),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: colorScheme.primary, width: 2),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SUPPORTING WIDGETS ──────────────────────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  final int currentStep;

  const _StepProgressBar({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    const steps = ['Vehicle', 'Service', 'Schedule', 'Review'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step ${currentStep + 1} of 4',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              steps[currentStep],
              style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (index) {
            final isActive = index <= currentStep;
            return Expanded(
              child: Container(
                height: 6,
                margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
                decoration: BoxDecoration(
                  color: isActive ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _StepTitleBlock extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StepTitleBlock({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _VehicleSelectionCard extends StatelessWidget {
  final CustomerVehicleEntity vehicle;
  final bool selected;
  final String imageUrl;
  final VoidCallback onTap;

  const _VehicleSelectionCard({
    required this.vehicle,
    required this.selected,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      onTap: onTap,
      borderRadius: 24,
      padding: EdgeInsets.zero,
      color: colorScheme.surface,
      borderColor: selected ? colorScheme.primary : colorScheme.outlineVariant,
      boxShadow: [
        BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4)),
      ],
      child: Stack(
        children: [
          // Background Image with gradient
          SizedBox(
            height: 150,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(imageUrl, fit: BoxFit.cover),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content over image
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFACC15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.black.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            vehicle.plateNumber.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          vehicle.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: selected ? colorScheme.primary : Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: selected ? colorScheme.primary : Colors.white),
                    ),
                    child: Center(
                      child: Icon(
                        selected ? Icons.check_rounded : Icons.circle_outlined,
                        color: selected ? colorScheme.onPrimary : Colors.transparent,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final ServiceTypeResponse service;
  final bool selected;
  final VoidCallback onTap;

  const _ServiceRow({required this.service, required this.selected, required this.onTap});

  IconData get _icon {
    final n = service.name.toLowerCase();
    if (n.contains('oil')) return Icons.oil_barrel_rounded;
    if (n.contains('brake')) return Icons.minor_crash_rounded;
    if (n.contains('tyre') || n.contains('tire')) return Icons.tire_repair_rounded;
    if (n.contains('battery')) return Icons.battery_charging_full_rounded;
    if (n.contains('air') || n.contains('filter')) return Icons.ac_unit_rounded;
    if (n.contains('diagnos')) return Icons.biotech_rounded;
    if (n.contains('mot')) return Icons.assignment_turned_in_rounded;
    if (n.contains('full') || n.contains('service')) return Icons.build_circle_rounded;
    return Icons.settings_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: selected ? colorScheme.primary.withValues(alpha: 0.06) : Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _icon,
                color: selected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: textTheme.titleSmall?.copyWith(
                      color: selected ? colorScheme.primary : colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (service.price.isNotEmpty || service.duration.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (service.price.isNotEmpty) service.price,
                        if (service.duration.isNotEmpty) service.duration,
                      ].join(' • '),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: colorScheme.primary, size: 26)
            else
              Icon(Icons.circle_outlined, color: colorScheme.outline, size: 26),
          ],
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
        ),
        Text(
          value,
          style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}
