import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_bookings_presentation.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_booking_flow_progress.dart';
import 'package:customer_app/core/local/vehicle_identity_store.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_booking_steps.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_notice_panel.dart';

/// Creating a service booking, end to end.
///
/// Four short decisions — which vehicle, which service, which real appointment
/// slot, and a review of exactly what will be submitted — followed by the
/// booking result. Every value shown comes from the customer's own records or
/// the workshop's own catalogue and availability; nothing is invented, and the
/// flow is the only place a booking is created.
class CustomerBookServiceView extends ConsumerStatefulWidget {
  /// A vehicle to preselect, when the customer came here for one car.
  final String vehicleId;

  const CustomerBookServiceView({super.key, this.vehicleId = ''});

  @override
  ConsumerState<CustomerBookServiceView> createState() =>
      _CustomerBookServiceViewState();
}

class _CustomerBookServiceViewState
    extends ConsumerState<CustomerBookServiceView> {
  static const _stepLabels = ['Vehicle', 'Service', 'Appointment', 'Review'];

  final _notesCtrl = TextEditingController();

  List<ServiceTypeResponse> _services = const [];
  List<String> _slots = const [];
  bool _loadingServices = true;
  bool _loadingSlots = false;
  bool _submitting = false;
  String _servicesError = '';
  String _slotsError = '';
  String _submitError = '';
  bool _retryVehicleSync = false;

  int _currentStep = 0;
  String? _selectedServiceId;
  CustomerVehicleEntity? _selectedVehicle;
  DateTime? _selectedDate;
  String? _selectedTime;
  late final List<DateTime> _dates;

  @override
  void initState() {
    super.initState();
    _dates = _bookableDates();
    _loadServices();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  /// Today plus the next two weeks: the workshop publishes hourly slots for
  /// every working day, so the choice belongs to the customer, not to us.
  List<DateTime> _bookableDates() {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    return List<DateTime>.generate(
      14,
      (index) => start.add(Duration(days: index)),
    );
  }

  CustomerVehicleEntity? get _resolvedVehicle {
    final vehicles = ref.watch(customerDashboardProvider).vehicles;
    if (vehicles.isEmpty || _selectedVehicle == null) return null;
    // Resolve through the identity map: a vehicle that was registered while this
    // flow was open keeps its selection under the server id.
    final wanted = VehicleIdentityStore.resolve(_selectedVehicle!.id);
    for (final vehicle in vehicles) {
      if (vehicle.id == wanted) return vehicle;
    }
    return _selectedVehicle;
  }

  ServiceTypeResponse? get _selectedService {
    for (final service in _services) {
      if (service.id == _selectedServiceId) return service;
    }
    return null;
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _resolvedVehicle != null;
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

  Future<void> _loadServices() async {
    setState(() {
      _loadingServices = true;
      _servicesError = '';
    });
    List<ServiceTypeResponse> services = const [];
    String error = '';
    try {
      services = await ref
          .read(customerRemoteDataSourceProvider)
          .getServiceTypes();
    } catch (e) {
      error = e is AppException ? e.message : "We couldn't load the services.";
    }
    if (!mounted) return;
    setState(() {
      _services = services;
      _loadingServices = false;
      _servicesError = error;
    });
  }

  Future<void> _loadSlots(DateTime date) async {
    setState(() {
      _selectedDate = date;
      _selectedTime = null;
      _loadingSlots = true;
      _slots = const [];
      _slotsError = '';
    });
    List<String> slots = const [];
    String error = '';
    try {
      slots = await ref
          .read(customerRemoteDataSourceProvider)
          .getAvailability(CustomerBookingsPresentation.isoDate(date));
    } catch (e) {
      error = e is AppException
          ? e.message
          : "We couldn't load the available times.";
    }
    if (!mounted) return;
    setState(() {
      _slots = _bookableSlots(slots, date);
      _loadingSlots = false;
      _slotsError = error;
    });
  }

  /// The workshop offers fixed hourly slots, so on today's date any slot that
  /// has already passed is not actually bookable.
  List<String> _bookableSlots(List<String> slots, DateTime date) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    if (!isToday) return slots;
    return slots.where((slot) {
      final minutes = CustomerBookingsPresentation.minutesOfDay(slot);
      if (minutes == null) return true;
      return DateTime(
        date.year,
        date.month,
        date.day,
        minutes ~/ 60,
        minutes % 60,
      ).isAfter(now);
    }).toList();
  }

  /// The vehicle this flow was opened for, when the caller named one.
  CustomerVehicleEntity? _vehicleFromRoute(
    List<CustomerVehicleEntity> vehicles,
  ) {
    // A vehicle reconciled during this session resolves through the identity
    // map, so a route that still holds the temporary id keeps working.
    final requested = VehicleIdentityStore.resolve(widget.vehicleId.trim());
    if (requested.isEmpty) return null;
    for (final vehicle in vehicles) {
      if (vehicle.id == requested) return vehicle;
    }
    return null;
  }

  Future<void> _openAddVehicle() async {
    // The form returns the vehicle it really saved, so a vehicle added inside
    // this flow is selected without another tap.
    final added = await context.push<CustomerVehicleEntity>(
      AppRoutes.customerAddVehicle,
    );
    await ref.read(customerDashboardProvider.notifier).refresh();
    if (!mounted) return;
    final vehicles = ref.read(customerDashboardProvider).vehicles;
    final saved = added ?? (vehicles.length == 1 ? vehicles.first : null);
    if (saved != null) {
      setState(() => _selectedVehicle = saved);
    }
  }

  void _goToStep(int step) {
    if (_submitting) return;
    setState(() => _currentStep = step.clamp(0, _stepLabels.length - 1));
  }

  Future<void> _confirm() async {
    final vehicle = _resolvedVehicle;
    final service = _selectedService;
    final date = _selectedDate;
    final time = _selectedTime;
    if (_submitting ||
        vehicle == null ||
        service == null ||
        date == null ||
        time == null) {
      return;
    }

    setState(() {
      _submitting = true;
      _submitError = '';
      _retryVehicleSync = false;
    });

    final localId = DateTime.now().millisecondsSinceEpoch.toString();
    final bookingDate =
        '${CustomerBookingsPresentation.isoDate(date)}T'
        '${time.length >= 5 ? time.substring(0, 5) : time}:00';
    final response = await customerSubmitBooking(
      ref,
      vehicle: vehicle,
      serviceName: service.name,
      bookingDate: bookingDate,
      bookingTime: time,
      notes: _notesCtrl.text.trim(),
      localId: localId,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (!response.accepted) {
      setState(() {
        _retryVehicleSync = response.retryVehicleSync;
        _submitError = response.error.isEmpty
            ? "We couldn't create this booking. Please try again."
            : response.error;
      });
      return;
    }

    // Replace the form so a back gesture can never return to a submitted
    // booking and create it twice.
    context.pushReplacement(
      AppRoutes.customerBookingSuccess,
      extra: <String, dynamic>{
        'ref': response.bookingRef,
        'id': response.bookingId,
        'service': service.name,
        'date': CustomerBookingsPresentation.isoDate(date),
        'time': time,
        'vehicle': vehicle.displayName,
        'plate': vehicle.plateNumber,
        'queued': response.queuedOffline,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dashboard = ref.watch(customerDashboardProvider);
    final vehicles = dashboard.vehicles;

    // A vehicle-specific entry point wins; otherwise one vehicle in the garage
    // is not a choice, so select it without making the customer tap.
    if (_selectedVehicle == null) {
      final requested = _vehicleFromRoute(vehicles);
      if (requested != null) {
        _selectedVehicle = requested;
      } else if (vehicles.length == 1) {
        _selectedVehicle = vehicles.first;
      }
    }

    final vehicle = _resolvedVehicle;
    final service = _selectedService;
    final lastStep = _stepLabels.length - 1;
    final onReview = _currentStep == lastStep;

    final step = _stepContent(
      vehicles: vehicles,
      loadingVehicles: dashboard.isLoading,
      vehicle: vehicle,
      service: service,
    );
    final summary = CustomerBookingSummaryPanel(
      vehicle: vehicle,
      service: service,
      date: _selectedDate,
      time: _selectedTime,
      onChangeStep: _goToStep,
      stepLabels: _stepLabels,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: _ActionBar(
        step: _currentStep,
        lastStep: lastStep,
        busy: _submitting,
        enabled: _canProceed,
        onBack: () => _goToStep(_currentStep - 1),
        onContinue: () {
          if (_currentStep < lastStep) {
            _goToStep(_currentStep + 1);
          } else {
            _confirm();
          }
        },
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppTopBar(title: 'Book service'),
            Divider(height: 1, color: colors.outlineVariant),
            Expanded(
              child: AppResponsivePage(
                physics: const AlwaysScrollableScrollPhysics(),
                maxContentWidth: 1040,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppDimensions.s16),
                    CustomerBookingProgress(
                      currentStep: _currentStep,
                      labels: _stepLabels,
                    ),
                    const SizedBox(height: AppDimensions.s20),
                    _stepBody(step: step, summary: summary, onReview: onReview),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The review step *is* the summary, so it takes the whole width instead of
  /// repeating itself beside the step.
  Widget _stepBody({
    required Widget step,
    required Widget summary,
    required bool onReview,
  }) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepHeading(
          title: _stepTitle(_currentStep),
          subtitle: _stepSubtitle(_currentStep),
        ),
        const SizedBox(height: AppDimensions.s16),
        if (_submitError.isNotEmpty) ...[
          CustomerNoticePanel(
            message: _submitError,
            actionLabel: _retryVehicleSync ? 'Retry vehicle sync' : 'Try again',
            onAction: _retryVehicleSync
                ? () async {
                    await customerRetryVehicleSync(ref);
                    if (mounted) _confirm();
                  }
                : _confirm,
          ),
          const SizedBox(height: AppDimensions.s16),
        ],
        step,
        const SizedBox(height: AppDimensions.s32),
      ],
    );

    if (onReview) return content;

    return AppSplitView(
      primaryFlex: 3,
      secondaryFlex: 2,
      spacing: AppDimensions.s20,
      primary: content,
      secondary: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          summary,
          const SizedBox(height: AppDimensions.s32),
        ],
      ),
    );
  }

  String _stepTitle(int step) => switch (step) {
    0 => 'Which vehicle?',
    1 => 'What service?',
    2 => 'When suits you?',
    _ => 'Check your booking',
  };

  String _stepSubtitle(int step) => switch (step) {
    0 => 'Choose the registered vehicle the workshop should service.',
    1 => 'Services come from the workshop catalogue.',
    2 => 'Times shown are the workshop’s real availability for that date.',
    _ => 'This is exactly what we will send to the workshop.',
  };

  Widget _stepContent({
    required List<CustomerVehicleEntity> vehicles,
    required bool loadingVehicles,
    required CustomerVehicleEntity? vehicle,
    required ServiceTypeResponse? service,
  }) {
    switch (_currentStep) {
      case 0:
        return CustomerBookingVehicleStep(
          vehicles: vehicles,
          loading: loadingVehicles,
          selected: vehicle,
          onSelect: (selected) => setState(() => _selectedVehicle = selected),
          onAddVehicle: _openAddVehicle,
        );
      case 1:
        return CustomerBookingServiceStep(
          services: _services,
          loading: _loadingServices,
          error: _servicesError,
          selectedId: _selectedServiceId,
          onSelect: (selected) =>
              setState(() => _selectedServiceId = selected.id),
          onRetry: _loadServices,
        );
      case 2:
        return CustomerBookingScheduleStep(
          dates: _dates,
          selectedDate: _selectedDate,
          onSelectDate: _loadSlots,
          slots: _slots,
          loadingSlots: _loadingSlots,
          slotsError: _slotsError,
          selectedSlot: _selectedTime,
          onSelectSlot: (slot) => setState(() => _selectedTime = slot),
          onRetrySlots: () {
            final date = _selectedDate;
            if (date != null) _loadSlots(date);
          },
        );
      default:
        return CustomerBookingReviewStep(
          vehicle: vehicle,
          service: service,
          date: _selectedDate,
          time: _selectedTime,
          notes: _notesCtrl,
          onChangeStep: _goToStep,
        );
    }
  }
}

/// The single place the flow moves forward: one primary action, plus a step
/// back that keeps every selection.
class _ActionBar extends StatelessWidget {
  final int step;
  final int lastStep;
  final bool busy;
  final bool enabled;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const _ActionBar({
    required this.step,
    required this.lastStep,
    required this.busy,
    required this.enabled,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final last = step == lastStep;

    return Material(
      color: colors.surface,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.s16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colors.outlineVariant)),
          ),
          child: Row(
            children: [
              if (step > 0) ...[
                OutlinedButton(
                  onPressed: busy ? null : onBack,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(88, AppDimensions.touchTarget),
                  ),
                  child: const Text('Back'),
                ),
                const SizedBox(width: AppDimensions.s12),
              ],
              Expanded(
                child: FilledButton.icon(
                  onPressed: busy || !enabled ? null : onContinue,
                  icon: busy
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colors.onPrimary,
                            ),
                          ),
                        )
                      : Icon(
                          last
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                  label: Text(
                    busy
                        ? 'Booking…'
                        : last
                        ? 'Confirm booking'
                        : 'Continue',
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(
                      AppDimensions.touchTarget,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StepHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.s4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
