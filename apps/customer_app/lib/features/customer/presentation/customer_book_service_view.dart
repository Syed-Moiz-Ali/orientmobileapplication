import 'package:customer_app/core/local/sync_providers.dart'; // ignore: unused_import
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
  ConsumerState<CustomerBookServiceView> createState() =>
      _CustomerBookServiceViewState();
}

class _CustomerBookServiceViewState
    extends ConsumerState<CustomerBookServiceView> {
  final _notesCtrl = TextEditingController();

  List<ServiceTypeResponse> _services = const [];
  List<String> _slots = const [];
  bool _loadingServices = true;
  bool _loadingSlots = false;
  bool _submitting = false;
  String? _error;
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
      _error = services.isEmpty ? 'No service types available right now.' : null;
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

  bool get _canConfirm =>
      _selectedVehicle != null &&
      _selectedService != null &&
      _selectedDate != null &&
      _selectedTime != null &&
      !_submitting;

  String get _displayDate {
    final d = _selectedDate;
    if (d == null) return 'Not selected';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> _confirm() async {
    if (!_canConfirm) {
      setState(() => _error = 'Choose a vehicle, service, date and time.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final vehicle = _selectedVehicle!;
    final service = _selectedService!;
    final now = DateTime.now();
    final bookingId = now.millisecondsSinceEpoch.toString();
    final payload = <String, dynamic>{
      'id': bookingId,
      'vehicleId': vehicle.id,
      'vehicleName': vehicle.displayName,
      'plateNumber': vehicle.plateNumber,
      'serviceId': service.id,
      'service': service.name,
      'date': _displayDate,
      'time': _selectedTime ?? '',
      'status': BookingStatus.pending.name,
      'notes': _notesCtrl.text.trim(),
    };

    try {
      final remote = ref.read(customerRemoteDataSourceProvider);
      final resp = await remote.createBooking(payload);
      if (resp.id.isNotEmpty) {
        payload['id'] = resp.id;
      }
    } catch (_) {
      final box = Hive.box<dynamic>('customer_cache');
      final local = GenericLocalDataSource(box);
      await local.save('booking_$bookingId', payload);
      final cached = List<Map<String, dynamic>>.from(
        (box.get('cached_bookings') as List?)?.cast() ?? const [],
      );
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


    context.push(AppRoutes.customerBookingSuccess, extra: <String, dynamic>{
      'ref': (payload['id'] ?? bookingId).toString(),
      'service': service.name,
      'date': _displayDate,
      'time': _selectedTime ?? '',
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final vehicles = ref.watch(customerDashboardProvider).vehicles;

    if (_selectedVehicle == null && vehicles.isNotEmpty) {
      _selectedVehicle = vehicles.first;
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(title: 'Book Service'),
            const Divider(height: 1, color: AppColors.line),
            Expanded(
              child: AppResponsivePage(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimensions.s16),

                    // ERROR BANNER
                    if (_error != null) ...[
                      AppCard(
                        color: AppColors.dangerBg,
                        borderColor: AppColors.dangerBorder,
                        borderRadius: 20,
                        padding: const EdgeInsets.all(AppDimensions.s12),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: AppColors.danger, size: 18),
                            const SizedBox(width: AppDimensions.s10),
                            Expanded(
                              child: Text(
                                _error!,
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.s16),
                    ],

                    // SECTION 1: SELECT VEHICLE
                    _SectionHeader(
                      icon: Icons.directions_car_rounded,
                      title: 'Select Vehicle',
                      subtitle: 'Choose which car to bring in',
                    ),
                    const SizedBox(height: AppDimensions.s10),
                    if (vehicles.isEmpty)
                      AppCard(
                        borderRadius: 20,
                        padding: const EdgeInsets.all(AppDimensions.s20),
                        color: AppColors.surface,
                        borderColor: AppColors.border,
                        child: Column(
                          children: [
                            const Icon(Icons.directions_car_outlined,
                                color: AppColors.text4, size: 36),
                            const SizedBox(height: AppDimensions.s10),
                            Text(
                              'No vehicles in garage',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Register a vehicle first to book a service',
                              textAlign: TextAlign.center,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.text3,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.s14),
                            OutlinedButton.icon(
                              onPressed: () => context.push(AppRoutes.customerAddVehicle),
                              icon: const Icon(Icons.add_rounded, size: 16),
                              label: const Text('Add Vehicle'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.rPill),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                        height: 88,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: vehicles.length,
                          separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.s8),
                          itemBuilder: (ctx, i) {
                            final v = vehicles[i];
                            final selected = _selectedVehicle?.id == v.id;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedVehicle = v),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 188,
                                padding: const EdgeInsets.all(AppDimensions.s12),
                                decoration: BoxDecoration(
                                  color: selected ? AppColors.primaryBg : AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: selected ? AppColors.primary : AppColors.border,
                                    width: selected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38, height: 38,
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? AppColors.primary.withValues(alpha: 0.2)
                                            : AppColors.surfaceAlt,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(Icons.directions_car_rounded,
                                          color: selected ? AppColors.primary : AppColors.text4,
                                          size: 20),
                                    ),
                                    const SizedBox(width: AppDimensions.s10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            v.displayName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: textTheme.labelMedium?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              v.plateNumber.toUpperCase(),
                                              style: textTheme.labelSmall?.copyWith(
                                                color: const Color(0xFFFACC15),
                                                fontWeight: FontWeight.w900,
                                                fontSize: 10,
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (selected)
                                      const Icon(Icons.check_circle_rounded,
                                          color: AppColors.primary, size: 16),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: AppDimensions.s24),

                    // SECTION 2: SELECT SERVICE
                    _SectionHeader(
                      icon: Icons.build_rounded,
                      title: 'Select Service',
                      subtitle: 'Choose the service type you need',
                    ),
                    const SizedBox(height: AppDimensions.s10),
                    if (_loadingServices)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppDimensions.s24),
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      )
                    else
                      AppCard(
                        borderRadius: 24,
                        padding: EdgeInsets.zero,
                        color: AppColors.surface,
                        borderColor: AppColors.border,
                        child: Column(
                          children: [
                            for (int i = 0; i < _services.length; i++) ...[
                              _ServiceRow(
                                service: _services[i],
                                selected: _selectedServiceId == _services[i].id,
                                onTap: () => setState(
                                  () => _selectedServiceId = _services[i].id,
                                ),
                              ),
                              if (i < _services.length - 1)
                                const Divider(height: 1, color: AppColors.line),
                            ],
                          ],
                        ),
                      ),
                    const SizedBox(height: AppDimensions.s24),

                    // SECTION 3: DATE & TIME
                    _SectionHeader(
                      icon: Icons.event_available_rounded,
                      title: 'Date & Time Slot',
                      subtitle: 'Choose when to bring your vehicle in',
                    ),
                    const SizedBox(height: AppDimensions.s10),
                    AppCard(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(AppDimensions.s16),
                      color: AppColors.surface,
                      borderColor: AppColors.border,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date picker
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(const Duration(days: 1)),
                                firstDate: DateTime.now().add(const Duration(days: 1)),
                                lastDate: DateTime.now().add(const Duration(days: 90)),
                                builder: (ctx, child) => Theme(
                                  data: Theme.of(ctx).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: AppColors.primary,
                                      onSurface: AppColors.textPrimary,
                                    ),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (picked != null) _loadSlots(picked);
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.s14,
                                vertical: AppDimensions.s12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded,
                                      color: AppColors.primary, size: 18),
                                  const SizedBox(width: AppDimensions.s10),
                                  Expanded(
                                    child: Text(
                                      _selectedDate != null
                                          ? _displayDate
                                          : 'Tap to choose a date',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: _selectedDate != null
                                            ? AppColors.textPrimary
                                            : AppColors.text4,
                                        fontWeight: _selectedDate != null
                                            ? FontWeight.w700
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded,
                                      color: AppColors.text4, size: 18),
                                ],
                              ),
                            ),
                          ),
                          if (_loadingSlots) ...[
                            const SizedBox(height: AppDimensions.s12),
                            const Center(
                              child: SizedBox(
                                width: 24, height: 24,
                                child: CircularProgressIndicator(
                                  color: AppColors.primary, strokeWidth: 2,
                                ),
                              ),
                            ),
                          ] else if (_slots.isNotEmpty) ...[
                            const SizedBox(height: AppDimensions.s14),
                            Text(
                              'Available Slots',
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.text3,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.s8),
                            Wrap(
                              spacing: AppDimensions.s8,
                              runSpacing: AppDimensions.s8,
                              children: _slots.map((slot) {
                                final sel = _selectedTime == slot;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedTime = slot),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimensions.s12,
                                      vertical: AppDimensions.s8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: sel ? AppColors.primary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(AppDimensions.rPill),
                                      border: Border.all(
                                        color: sel ? AppColors.primary : AppColors.border,
                                      ),
                                    ),
                                    child: Text(
                                      slot,
                                      style: textTheme.labelSmall?.copyWith(
                                        color: sel ? Colors.white : AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ] else if (_selectedDate != null) ...[
                            const SizedBox(height: AppDimensions.s12),
                            Text(
                              'No slots available for this date.',
                              style: textTheme.bodySmall?.copyWith(color: AppColors.text4),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s24),

                    // SECTION 4: NOTES
                    _SectionHeader(
                      icon: Icons.notes_rounded,
                      title: 'Service Notes',
                      subtitle: 'Describe any symptoms or special requests (optional)',
                    ),
                    const SizedBox(height: AppDimensions.s10),
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'e.g. Strange noise when braking, oil light on…',
                        hintStyle: const TextStyle(color: AppColors.text4, fontSize: 13),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.all(AppDimensions.s14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s28),

                    // CONFIRM BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _canConfirm ? _confirm : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.surfaceAlt,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.rPill),
                          ),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : Text(
                                'Confirm Booking',
                                style: textTheme.labelLarge?.copyWith(
                                  color: _canConfirm ? Colors.white : AppColors.text4,
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
          ],
        ),
      ),
    );
  }
}

// ─── Supporting Widgets ────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: AppColors.primaryBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 16),
        ),
        const SizedBox(width: AppDimensions.s10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.text3,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final ServiceTypeResponse service;
  final bool selected;
  final VoidCallback onTap;

  const _ServiceRow({
    required this.service,
    required this.selected,
    required this.onTap,
  });

  IconData get _icon {
    final n = service.name.toLowerCase();
    if (n.contains('oil')) return Icons.oil_barrel_rounded;
    if (n.contains('brake')) return Icons.do_not_disturb_on_rounded;
    if (n.contains('tyre') || n.contains('tire')) return Icons.radio_button_checked_rounded;
    if (n.contains('battery')) return Icons.battery_charging_full_rounded;
    if (n.contains('air') || n.contains('filter')) return Icons.air_rounded;
    if (n.contains('diagnos')) return Icons.biotech_rounded;
    if (n.contains('mot')) return Icons.assignment_turned_in_rounded;
    if (n.contains('full') || n.contains('service')) return Icons.build_rounded;
    return Icons.settings_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.s16,
          vertical: AppDimensions.s14,
        ),
        color: selected ? AppColors.primaryBg : Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _icon,
                color: selected ? AppColors.primary : AppColors.text4,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimensions.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (service.price.isNotEmpty || service.duration.isNotEmpty)
                    Text(
                      [
                        if (service.price.isNotEmpty) service.price,
                        if (service.duration.isNotEmpty) service.duration,
                      ].join(' · '),
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.text3,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 18)
            else
              const Icon(Icons.radio_button_unchecked_rounded,
                  color: AppColors.border, size: 18),
          ],
        ),
      ),
    );
  }
}
