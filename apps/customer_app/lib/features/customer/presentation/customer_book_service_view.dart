import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/local/vehicle_identity_store.dart';
import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/l10n/gen/customer_localizations.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_booking_draft.dart';
import 'package:customer_app/features/customer/presentation/support/customer_bookings_presentation.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_booking_flow_progress.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_booking_steps.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_notice_panel.dart';

/// Booking a service as an Airbnb-style guided flow.
///
/// Four short decisions — which vehicle, which packages, which real slot,
/// how the car reaches us — with a running summary and a price dock beside
/// every step. Every value shown comes from the customer's own garage, the
/// workshop's own catalogue or the workshop's own availability; nothing is
/// invented. Multi-select names travel in the existing `serviceType` field
/// and the valet choice travels inside the existing free-text `notes`
/// field, because the backend rejects unknown payload keys. The flow is the
/// only place a booking is created.
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
  static const _stepCount = 4;

  final _notesCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

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
  final Set<String> _selectedServiceIds = <String>{};
  CustomerVehicleEntity? _selectedVehicle;
  DateTime? _selectedDate;
  String? _selectedTime;
  bool _valet = false;
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
    _addressCtrl.dispose();
    super.dispose();
  }

  /// Today plus the next two weeks: the workshop publishes slots per
  /// working day, so the choice belongs to the customer, not to us.
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

  /// Selected catalogue entries in catalogue order.
  List<ServiceTypeResponse> get _selectedServices {
    final byId = {for (final s in _services) s.id: s};
    return [
      for (final id in _selectedServiceIds)
        if (byId[id] != null) byId[id]!,
    ];
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _resolvedVehicle != null;
      case 1:
        return _selectedServices.isNotEmpty;
      case 2:
        return _selectedDate != null && _selectedTime != null;
      case 3:
        return !_valet || _addressCtrl.text.trim().isNotEmpty;
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
      _selectedServiceIds.removeWhere(
        (id) => services.every((s) => s.id != id),
      );
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

  /// The workshop offers fixed slots, so on today's date any slot that has
  /// already passed is not actually bookable.
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
    setState(() => _currentStep = step.clamp(0, _stepCount - 1));
  }

  void _toggleService(ServiceTypeResponse service) {
    setState(() {
      if (!_selectedServiceIds.remove(service.id)) {
        _selectedServiceIds.add(service.id);
      }
    });
  }

  Future<void> _confirm() async {
    final vehicle = _resolvedVehicle;
    final services = _selectedServices;
    final date = _selectedDate;
    final time = _selectedTime;
    final address = _addressCtrl.text.trim();
    if (_submitting ||
        vehicle == null ||
        services.isEmpty ||
        date == null ||
        time == null ||
        (_valet && address.isEmpty)) {
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
    // Same payload keys as ever: the joined names ride the existing
    // serviceType string, the valet line rides the free-text notes.
    final serviceName = CustomerBookingDraft.serviceNames(services);
    final notes = CustomerBookingDraft.notesWithValet(
      typed: _notesCtrl.text,
      valet: _valet,
      address: address,
    );
    final response = await customerSubmitBooking(
      ref,
      vehicle: vehicle,
      serviceName: serviceName,
      bookingDate: bookingDate,
      bookingTime: time,
      notes: notes,
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
        'service': serviceName,
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
    final t = context.cx;
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
    final services = _selectedServices;
    final stepLabels = [
      t.wizStepVehicle,
      t.wizStepPackage,
      t.wizStepSlot,
      t.wizStepDropoff,
    ];
    final total = CustomerBookingDraft.totalFor(services);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: _stepTitle(t, _currentStep),
          subtitle: _stepSubtitle(t, _currentStep),
        ),
        const SizedBox(height: AppDimensions.s16),
        if (_submitError.isNotEmpty) ...[
          CustomerNoticePanel(
            message: _submitError,
            actionLabel: _retryVehicleSync ? t.wizRetrySync : t.wizTryAgain,
            onAction: _retryVehicleSync
                ? () async {
                    await customerRetryVehicleSync(ref);
                    if (mounted) _confirm();
                  }
                : _confirm,
          ),
          const SizedBox(height: AppDimensions.s16),
        ],
        if (!_canProceed && !_submitting) ...[
          _InlineHint(text: _stepHint(t, _currentStep)),
          const SizedBox(height: AppDimensions.s12),
        ],
        _stepContent(
          vehicles: vehicles,
          loadingVehicles: dashboard.isLoading,
        ),
        const SizedBox(height: AppDimensions.s32),
      ],
    );
    final summary = CustomerBookingSummaryPanel(
      vehicle: vehicle,
      services: services,
      date: _selectedDate,
      time: _selectedTime,
      valet: _valet,
      onChangeStep: _goToStep,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Phase 07.1: bespoke AppTopBar migrated to the shared workspace bar.
      appBar: WorkspaceAppBar(title: t.wizTitle, showBack: true),
      bottomNavigationBar: PriceBreakdownDock(
        items: [
          for (final service in services)
            PriceBreakdownItem(
              label: service.name.trim().isEmpty
                  ? 'Service'
                  : service.name.trim(),
              amount: service.price.trim().isNotEmpty
                  ? service.price.trim()
                  : (service.duration.trim().isNotEmpty
                        ? service.duration.trim()
                        : '—'),
            ),
        ],
        totalLabel: t.wizTotal,
        totalAmount: total == null
            ? (services.isEmpty ? '—' : t.wizTotalPending)
            : CustomerBookingDraft.formatAed(total),
        ctaLabel: _currentStep == _stepCount - 1 ? t.wizConfirm : t.wizContinue,
        busyLabel: t.wizBooking,
        busy: _submitting,
        ctaEnabled: _canProceed,
        trustLine: t.wizTrust,
        onCta: () {
          if (_currentStep < _stepCount - 1) {
            _goToStep(_currentStep + 1);
          } else {
            _confirm();
          }
        },
      ),
      body: SafeArea(
        bottom: false,
        child: AppResponsivePage(
          physics: const AlwaysScrollableScrollPhysics(),
          maxContentWidth: 1040,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.s16),
              // Phase 07.1: bespoke progress migrated to AppStepper
              // (same steps + position; localized Step X of Y built in).
              AppStepper(
                steps: stepLabels,
                currentIndex: _currentStep,
                onStepTap: _goToStep,
              ),
              if (_currentStep > 0) ...[
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: _submitting
                        ? null
                        : () => _goToStep(_currentStep - 1),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: Text(t.wizBack),
                  ),
                ),
              ] else
                const SizedBox(height: AppDimensions.s20),
              if (context.adaptive.isCompact) ...[
                content,
                summary,
                const SizedBox(height: AppDimensions.s32),
              ] else
                AppSplitView(
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
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _stepTitle(CustomerLocalizations t, int step) => switch (step) {
    0 => t.wizVehicleTitle,
    1 => t.wizPackageTitle,
    2 => t.wizSlotTitle,
    _ => t.wizDropTitle,
  };

  String _stepSubtitle(CustomerLocalizations t, int step) => switch (step) {
    0 => t.wizVehicleSub,
    1 => t.wizPackageSub,
    2 => t.wizSlotSub,
    _ => t.wizDropSub,
  };

  String _stepHint(CustomerLocalizations t, int step) => switch (step) {
    0 => t.wizNeedVehicle,
    1 => t.wizNeedPackage,
    2 => t.wizNeedSlot,
    _ => t.wizAddressRequired,
  };

  Widget _stepContent({
    required List<CustomerVehicleEntity> vehicles,
    required bool loadingVehicles,
  }) {
    switch (_currentStep) {
      case 0:
        return CustomerBookingVehicleStep(
          vehicles: vehicles,
          loading: loadingVehicles,
          selected: _resolvedVehicle,
          onSelect: (selected) => setState(() => _selectedVehicle = selected),
          onAddVehicle: _openAddVehicle,
        );
      case 1:
        return CustomerBookingServiceStep(
          services: _services,
          loading: _loadingServices,
          error: _servicesError,
          selectedIds: _selectedServiceIds,
          onToggle: _toggleService,
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
        return CustomerBookingDropoffStep(
          valet: _valet,
          onValetChanged: (valet) => setState(() => _valet = valet),
          addressCtrl: _addressCtrl,
          notesCtrl: _notesCtrl,
        );
    }
  }
}

/// Inline per-step guidance: the one thing still missing before Continue
/// activates. Always visible (never color-only), never a toast.
class _InlineHint extends StatelessWidget {
  final String text;

  const _InlineHint({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s12,
        vertical: AppDimensions.s8,
      ),
      decoration: BoxDecoration(
        color: colors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: AppDimensions.s8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
