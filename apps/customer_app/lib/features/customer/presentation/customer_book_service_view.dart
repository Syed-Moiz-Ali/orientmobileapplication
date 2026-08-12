import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/core/local/sync_providers.dart';
import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';

class CustomerBookServiceView extends ConsumerStatefulWidget {
  const CustomerBookServiceView({super.key});
  @override
  ConsumerState<CustomerBookServiceView> createState() =>
      _CustomerBookServiceViewState();
}

class _CustomerBookServiceViewState
    extends ConsumerState<CustomerBookServiceView> {
  int _step = 0;
  // FIX (audit P0): the calendar opened on a hardcoded April 2026.
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDate;
  String? _selectedTime;
  CustomerVehicleEntity? _selectedVehicle;
  final _notesCtrl = TextEditingController();

  List<ServiceTypeResponse> _serviceTypes = [];
  bool _isLoadingTypes = true;
  String? _selectedServiceTypeId;

  // FE-FLOW: real availability slots for the selected date.
  List<String> _availableSlots = [];
  bool _isLoadingSlots = false;

  static const _months = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static const _wd = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  @override
  void initState() {
    super.initState();
    _loadServiceTypes();
  }

  Future<void> _loadServiceTypes() async {
    final types = await ref.read(customerRemoteDataSourceProvider).getServiceTypes();
    if (mounted) {
      setState(() {
        _serviceTypes = types;
        _isLoadingTypes = false;
      });
    }
  }

  // FE-FLOW: fetch real slot availability for the selected date (was a
  // hardcoded 09:00-16:00 list with no workshop awareness).
  Future<void> _loadAvailability(DateTime date) async {
    setState(() => _isLoadingSlots = true);
    final slots = await ref
        .read(customerRemoteDataSourceProvider)
        .getAvailability(
            '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}');
    if (mounted) {
      setState(() {
        _availableSlots = slots;
        _isLoadingSlots = false;
      });
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  List<DateTime?> _calDays() {
    final first = DateTime(_focusedMonth.year, _focusedMonth.month);
    final last = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final days = <DateTime?>[];
    for (int i = 0; i < first.weekday % 7; i++) {
      days.add(null);
    }
    for (int d = 1; d <= last.day; d++) {
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month, d));
    }
    while (days.length % 7 != 0) {
      days.add(null);
    }
    return days;
  }

  String get _summaryDate => _selectedDate == null
      ? '\u2014'
      : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}';

  List<CustomerVehicleEntity> get _vehicles =>
      ref.watch(customerDashboardProvider).vehicles;

  IconData _getServiceIcon(String name) {
    switch (name) {
      case 'Full Service': return Icons.build_rounded;
      case 'Oil Change': return Icons.opacity_rounded;
      case 'Brakes': return Icons.disc_full_rounded;
      case 'Tyres': return Icons.radio_button_checked_rounded;
      case 'MOT': return Icons.fact_check_rounded;
      case 'Battery': return Icons.battery_charging_full_rounded;
      case 'Diagnostics': return Icons.analytics_rounded;
      default: return Icons.miscellaneous_services_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(
              step: _step,
              onBack: () {
                if (_step == 0) {
                  Navigator.pop(context);
                } else {
                  setState(() => _step--);
                }
              },
            ),
            const Divider(height: 1),
            _StepBar(step: _step),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.s18,
                  AppDimensions.s20,
                  AppDimensions.s18,
                  AppDimensions.s20,
                ),
                child: [_buildStep0, _buildStep1, _buildStep2][_step](context),
              ),
            ),
            _BottomBar(
              label: _step == 2 ? 'Confirm Booking' : 'Continue',
              onTap: () async {
                if (_step == 0) {
                  if (_selectedServiceTypeId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a service type')),
                    );
                    return;
                  }
                  setState(() => _step++);
                } else if (_step == 1) {
                  if (_selectedDate == null || _selectedTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a date and time')),
                    );
                    return;
                  }
                  setState(() => _step++);
                } else {
                  if (_selectedVehicle == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a vehicle')),
                    );
                    return;
                  }
                  await _showConfirmSheet(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep0(BuildContext ctx) {
    if (_isLoadingTypes) {
      return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Service',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.s4),
        const Text(
          'What does your vehicle need today?',
          style: TextStyle(fontSize: 13, color: AppColors.text3),
        ),
        const SizedBox(height: AppDimensions.s18),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppDimensions.s10,
            mainAxisSpacing: AppDimensions.s10,
            childAspectRatio: 0.85,
          ),
          itemCount: _serviceTypes.length,
          itemBuilder: (context, index) {
            final type = _serviceTypes[index];
            final isSelected = _selectedServiceTypeId == type.id;

            return GestureDetector(
              onTap: () => setState(() => _selectedServiceTypeId = type.id),
              child: AppCard(
                color: isSelected ? AppColors.primaryBg : AppColors.surface,
                borderColor: isSelected ? AppColors.primary : AppColors.border,
                padding: const EdgeInsets.all(AppDimensions.s14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getServiceIcon(type.name),
                      size: 32,
                      color: isSelected ? AppColors.primary : AppColors.text2,
                    ),
                    const SizedBox(height: AppDimensions.s12),
                    Text(
                      type.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s6),
                    Text(
                      type.price,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s4),
                    Text(
                      type.duration,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.text3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStep1(BuildContext ctx) {
    final today = DateTime.now();
    final calDays = _calDays();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Book an appointment',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.s4),
        const Text(
          'Pick a date & time \u2014 the workshop advisor will confirm the service needed',
          style: TextStyle(fontSize: 13, color: AppColors.text3),
        ),
        const SizedBox(height: AppDimensions.s18),
        AppCard(
          child: Column(
            children: [
              Row(
                children: [
                  _NavBtn(
                    icon: Icons.chevron_left,
                    onTap: () => setState(
                      () => _focusedMonth = DateTime(
                        _focusedMonth.year,
                        _focusedMonth.month - 1,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${_months[_focusedMonth.month]} ${_focusedMonth.year}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _NavBtn(
                    icon: Icons.chevron_right,
                    onTap: () => setState(
                      () => _focusedMonth = DateTime(
                        _focusedMonth.year,
                        _focusedMonth.month + 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.s14),
              Row(
                children: _wd
                    .map(
                      (d) => Expanded(
                        child: Text(
                          d,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text3,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppDimensions.s8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.1,
                ),
                itemCount: calDays.length,
                itemBuilder: (_, i) {
                  final d = calDays[i];
                  if (d == null) return const SizedBox();
                  final isToday =
                      d.year == today.year &&
                      d.month == today.month &&
                      d.day == today.day;
                  final isSel =
                      _selectedDate != null &&
                      d.year == _selectedDate!.year &&
                      d.month == _selectedDate!.month &&
                      d.day == _selectedDate!.day;
                  final isPast = d.isBefore(
                    DateTime(today.year, today.month, today.day),
                  );
                  return GestureDetector(
                    onTap: isPast
                        ? null
                        : () {
                            setState(() {
                              _selectedDate = d;
                              _selectedTime = null;
                              _availableSlots = [];
                            });
                            _loadAvailability(d);
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSel
                            ? AppColors.primary
                            : isToday
                            ? AppColors.primaryBg
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppDimensions.r8),
                        border: isToday && !isSel
                            ? Border.all(color: AppColors.primary)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '${d.day}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSel || isToday
                                ? FontWeight.w700
                                : FontWeight.normal,
                            color: isSel
                                ? Colors.white
                                : isPast
                                ? AppColors.text4
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.s20),
        const Text(
          'Available times',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.s12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          crossAxisSpacing: 9,
          mainAxisSpacing: 9,
          childAspectRatio: 2.2,
          children: _isLoadingSlots
              ? const [
                  Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                ]
              : (_availableSlots.isEmpty
                  ? [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimensions.r9),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Text(
                          'No slots available for this date yet',
                          style: TextStyle(fontSize: 12, color: AppColors.text3),
                        ),
                      )
                    ]
                  : _availableSlots.map((t) {
                      final isSel = _selectedTime == t;
                      return Semantics(
                        button: true,
                        selected: isSel,
                        label: 'Book at $t',
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTime = t),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(AppDimensions.r9),
                              border: Border.all(
                                color: isSel ? AppColors.primary : AppColors.border,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                t,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSel ? Colors.white : AppColors.text2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList()),
        ),
        const SizedBox(height: AppDimensions.s20),
      ],
    );
  }

  Widget _buildStep2(BuildContext ctx) {
    final selService = _serviceTypes.firstWhere((t) => t.id == _selectedServiceTypeId, orElse: () => const ServiceTypeResponse(name: 'Appointment'));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Almost done!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.s4),
        const Text(
          'Choose your vehicle and review',
          style: TextStyle(fontSize: 13, color: AppColors.text3),
        ),
        const SizedBox(height: AppDimensions.s18),

        if (_vehicles.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                const Icon(Icons.directions_car_outlined, size: 48, color: AppColors.text4),
                const SizedBox(height: 12),
                const Text(
                  'No vehicles yet \u2014 add your vehicle first',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.text3),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ctx.push(AppRoutes.customerAddVehicle),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Vehicle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r12),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ..._vehicles.map((v) {
          final isSel = _selectedVehicle?.id == v.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedVehicle = v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 130),
              margin: const EdgeInsets.only(bottom: AppDimensions.s10),
              padding: const EdgeInsets.all(AppDimensions.s14),
              decoration: BoxDecoration(
                color: isSel ? AppColors.primaryBg : AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.r12),
                border: Border.all(
                  color: isSel ? AppColors.primary : AppColors.border,
                  width: isSel ? 1.5 : 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.primaryBg : AppColors.bg,
                      borderRadius: BorderRadius.circular(AppDimensions.r10),
                    ),
                    child: Icon(
                      Icons.directions_car_rounded,
                      color: isSel ? AppColors.primary : AppColors.text3,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v.displayName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isSel
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.s4),
                        Text(
                          '${v.plateNumber}  \u00b7  ${v.year}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.text3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSel)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: AppDimensions.s8),

        AppCard(
          padding: EdgeInsets.zero,
          child: TextField(
            controller: _notesCtrl,
            maxLines: 3,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Additional notes (optional)\u2026',
              hintStyle: TextStyle(color: AppColors.text4, fontSize: 13),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(AppDimensions.s14),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.s18),

        AppCard(
          color: AppColors.primaryBg,
          borderColor: AppColors.primaryBorder,
          child: Column(
            children: [
              _SumRow(
                icon: Icons.build_rounded,
                label: 'Service',
                value: selService.name,
              ),
              const Divider(height: 18, color: AppColors.primaryBorder),
              _SumRow(
                icon: Icons.calendar_month_rounded,
                label: 'Date',
                value: _summaryDate,
              ),
              const Divider(height: 18, color: AppColors.primaryBorder),
              _SumRow(
                icon: Icons.access_time_rounded,
                label: 'Time',
                value: _selectedTime ?? '\u2014',
              ),
              const Divider(height: 18, color: AppColors.primaryBorder),
              _SumRow(
                icon: Icons.directions_car_rounded,
                label: 'Vehicle',
                value: _selectedVehicle?.displayName ?? '\u2014',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.s20),
      ],
    );
  }

  Future<void> _showConfirmSheet(BuildContext context) async {
    final now = DateTime.now();

    final selected = _selectedDate ?? DateTime.now();
    final bookingDate = _selectedTime == null
        ? selected.toIso8601String()
        : '${selected.year.toString().padLeft(4, '0')}-'
            '${selected.month.toString().padLeft(2, '0')}-'
            '${selected.day.toString().padLeft(2, '0')}T'
            '$_selectedTime:00';
            
    final selService = _serviceTypes.firstWhere((t) => t.id == _selectedServiceTypeId, orElse: () => const ServiceTypeResponse(name: 'Appointment'));

    final payload = {
      'vehicleId': _selectedVehicle?.id ?? '',
      'vehicleName': _selectedVehicle?.displayName ?? '',
      'plateNumber': _selectedVehicle?.plateNumber ?? '',
      'serviceType': selService.name,
      'bookingDate': bookingDate,
      'notes': _notesCtrl.text,
    };

    final local = GenericLocalDataSource(Hive.box<dynamic>('customer_bookings'));
    var bookingRef = '';
    var synced = true;
    final remote = ref.read(customerRemoteDataSourceProvider);
    try {
      final resp = await remote.createBooking(payload);
      // FIX (audit QA BUG-020): prefer the human-friendly booking ref (BK-...)
      // over the numeric DB id when the backend provided one.
      bookingRef = resp.bookingRef.isNotEmpty ? resp.bookingRef : resp.id;
    } catch (e, st) {
      ref.read(loggerProvider).e('Booking API failed \u2014 queueing offline',
          error: e, stackTrace: st);
      synced = false;
    }

    final id = bookingRef.isNotEmpty ? bookingRef : await IdGenerator.nextId('BK');
    local.save(id, {
      'id': id,
      'serviceType': selService.name,
      'vehicleName': _selectedVehicle?.displayName ?? '',
      'plateNumber': _selectedVehicle?.plateNumber ?? '',
      'date': _summaryDate,
      'time': _selectedTime ?? '',
      'notes': _notesCtrl.text,
      'status': 'pending',
      'createdAt': now.toIso8601String(),
    });

    if (!synced) {
      final queue = ref.read(syncQueueProvider);
      await queue.enqueue(SyncOperation(
        id: id,
        entityType: 'booking',
        entityId: id,
        changeType: ChangeType.create,
        payload: payload,
        timestamp: now.millisecondsSinceEpoch,
      ));
      await ref.read(syncEngineProvider).syncAll();
    }
    ref.invalidate(customerBookingsProvider);
    if (!context.mounted) return;
    
    context.go(AppRoutes.customerBookingSuccess, extra: {
      'ref': id,
      'service': selService.name,
      'date': _summaryDate,
      'time': _selectedTime ?? '--',
    });
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(AppDimensions.r8),
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, size: 20, color: AppColors.text2),
    ),
  );
}

class _SumRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _SumRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 16, color: AppColors.text3),
      const SizedBox(width: AppDimensions.s10),
      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.text3)),
      const Spacer(),
      Text(
        value,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    ],
  );
}

class _StepBar extends StatelessWidget {
  final int step;
  const _StepBar({required this.step});

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.surface,
    padding: const EdgeInsets.fromLTRB(
      AppDimensions.s18,
      AppDimensions.s10,
      AppDimensions.s18,
      AppDimensions.s12,
    ),
    child: Row(
      children: [
        _Node(n: 0, step: step, label: 'Service'),
        _Line(done: step > 0),
        _Node(n: 1, step: step, label: 'Schedule'),
        _Line(done: step > 1),
        _Node(n: 2, step: step, label: 'Confirm'),
      ],
    ),
  );
}

class _Node extends StatelessWidget {
  final int n;
  final int step;
  final String label;
  const _Node({required this.n, required this.step, required this.label});

  @override
  Widget build(BuildContext context) {
    final done = step > n;
    final active = step == n;
    return Column(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done
                ? AppColors.success
                : active
                ? AppColors.primary
                : AppColors.bg,
            border: Border.all(
              color: done
                  ? AppColors.success
                  : active
                  ? AppColors.primary
                  : AppColors.borderMd,
              width: 1.5,
            ),
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, size: 13, color: Colors.white)
                : Text(
                    '${n + 1}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: active ? Colors.white : AppColors.text3,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: AppDimensions.s4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: done
                ? AppColors.success
                : active
                ? AppColors.primary
                : AppColors.text4,
          ),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  final bool done;
  const _Line({required this.done});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      height: 1.5,
      margin: const EdgeInsets.only(bottom: AppDimensions.s16),
      color: done ? AppColors.success : AppColors.border,
    ),
  );
}

class _TopBar extends StatelessWidget {
  final int step;
  final VoidCallback onBack;
  const _TopBar({required this.step, required this.onBack});

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.surface,
    height: 60,
    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s18),
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
        const Expanded(
          child: Center(
            child: Text(
              'Book Service',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 34),
      ],
    ),
  );
}

class _BottomBar extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _BottomBar({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.surface,
    padding: const EdgeInsets.fromLTRB(
      AppDimensions.s18,
      AppDimensions.s14,
      AppDimensions.s18,
      AppDimensions.s24,
    ),
    child: SafeArea(
      top: false,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.s14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.r12),
            ),
            elevation: 0,
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    ),
  );
}
