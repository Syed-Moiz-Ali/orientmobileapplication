import 'package:customer_app/core/local/vehicle_identity_store.dart';
import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_notice_panel.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_plate_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_core/shared_core.dart';

/// Roadside assistance: one request to the workshop.
///
/// The backend contract is deliberately small — an issue, an optional vehicle,
/// and a free-text location — and it stores a `pending` request that a
/// supervisor later assigns to an advisor. Nothing here claims more than that:
/// no dispatch, no ETA, no towing, no automatic location. The screen is a
/// short form with the send action always in reach, because a customer using it
/// is standing next to a broken-down car.
class CustomerBreakdownHelpView extends ConsumerStatefulWidget {
  const CustomerBreakdownHelpView({super.key});

  @override
  ConsumerState<CustomerBreakdownHelpView> createState() =>
      _CustomerBreakdownHelpViewState();
}

class _CustomerBreakdownHelpViewState
    extends ConsumerState<CustomerBreakdownHelpView> {
  /// Symptoms only. The backend stores this text as the request's issue and
  /// promises no specific service, so nothing here names a service that may not
  /// exist (towing, fuel delivery, lockout).
  static const List<String> _symptoms = [
    'Flat tyre',
    "Won't start",
    'Dead battery',
    'Overheating',
    'Brake problem',
    'Warning light',
    'Accident damage',
    'Something else',
  ];

  final _locationCtrl = TextEditingController();
  final _detailCtrl = TextEditingController();
  String? _symptom;
  CustomerVehicleEntity? _vehicle;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // Preselect only when there is no ambiguity about which car needs help.
    final vehicles = ref.read(customerDashboardProvider).vehicles;
    if (vehicles.length == 1) _vehicle = vehicles.first;
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    _detailCtrl.dispose();
    super.dispose();
  }

  List<CustomerVehicleEntity> get _vehicles =>
      ref.watch(customerDashboardProvider).vehicles;

  /// The single text field the contract has, filled from the symptom chip
  /// plus anything the customer adds, so no typed detail is thrown away.
  String get _issueText {
    final symptom = _symptom?.trim() ?? '';
    final detail = _detailCtrl.text.trim();
    if (symptom.isEmpty) return detail;
    if (detail.isEmpty) return symptom;
    return '$symptom — $detail';
  }

  /// The vehicle id the workshop can actually use.
  ///
  /// A vehicle created offline still carries a temporary local id; sending that
  /// would store a meaningless reference, so the request travels with the real
  /// name and plate instead of a fake id.
  String get _workshopVehicleId {
    final id = _vehicle?.id.trim() ?? '';
    if (id.isEmpty) return '';
    final serverId = VehicleIdentityStore.serverIdFor(id);
    if (serverId != null && serverId.isNotEmpty) return serverId;
    if (VehicleIdentityStore.isPending(id)) return '';
    return id;
  }

  void _notice(String message) {
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (_sending) return;

    final issue = _issueText;
    if (issue.isEmpty) {
      _notice("Tell us what's wrong so the workshop can help.");
      return;
    }
    final location = _locationCtrl.text.trim();
    if (location.isEmpty) {
      _notice('Add where the vehicle is so the workshop can find you.');
      return;
    }

    final payload = <String, dynamic>{
      'issue': issue,
      'vehicleName': _vehicle?.displayName ?? '',
      'vehiclePlate': _vehicle?.plateNumber ?? '',
      'location': location,
    };
    final vehicleId = _workshopVehicleId;
    if (vehicleId.isNotEmpty) payload['vehicleId'] = vehicleId;

    setState(() => _sending = true);
    try {
      final response = await ref
          .read(customerRemoteDataSourceProvider)
          .createBreakdown(payload);
      if (!mounted) return;
      _showResult(sent: true, reference: response.id, location: location);
    } on NetworkException catch (e) {
      if (!mounted) return;
      if (e.message.toLowerCase().contains('receive data')) {
        // The workshop may already hold this request; queueing it would risk
        // sending a second one, so the customer is asked to retry instead.
        _notice(
          "We couldn't confirm whether the workshop received this request. "
          'Check your connection and try again.',
        );
        return;
      }
      await _queue(payload);
      if (!mounted) return;
      _showResult(sent: false, reference: '', location: location);
    } on UnauthorizedException {
      await ref.read(authNotifierProvider.notifier).logout();
    } catch (e) {
      if (!mounted) return;
      _notice(
        e is AppException
            ? e.message
            : "We couldn't send your request. Please try again.",
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  /// Queues the request for the workshop.
  ///
  /// It is deliberately *not* pushed to the network here: while offline every
  /// attempt counts as a failed retry, and a request that was never actually
  /// sent must not exhaust its retries. The sync engine sends it when the
  /// connection returns.
  Future<void> _queue(Map<String, dynamic> payload) async {
    final localId = 'breakdown-${DateTime.now().millisecondsSinceEpoch}';
    try {
      await ref
          .read(syncQueueProvider)
          .enqueue(
            SyncOperation(
              id: localId,
              entityType: 'breakdown',
              entityId: localId,
              changeType: ChangeType.create,
              payload: payload,
              timestamp: DateTime.now().millisecondsSinceEpoch,
            ),
          );
    } catch (e, st) {
      ref
          .read(loggerProvider)
          .e('Failed to queue breakdown request', error: e, stackTrace: st);
      if (mounted) {
        _notice("We couldn't save this request on your device.");
      }
    }
  }

  void _showResult({
    required bool sent,
    required String reference,
    required String location,
  }) {
    context.pushReplacement(
      AppRoutes.customerBreakdownResult,
      extra: <String, dynamic>{
        'sent': sent,
        'reference': reference,
        'vehicleName': _vehicle?.displayName ?? '',
        'vehiclePlate': _vehicle?.plateNumber ?? '',
        'location': location,
        'issue': _issueText,
      },
    );
  }

  Future<void> _callWorkshop() async {
    final uri = Uri(scheme: 'tel', path: '800674368');
    final opened = await launchUrl(uri);
    if (!opened && mounted) _notice('Unable to open the phone dialer.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final vehicles = _vehicles;

    return Scaffold(
      bottomNavigationBar: _Dock(
        sending: _sending,
        onCall: _callWorkshop,
        onSubmit: _submit,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppTopBar(title: 'Roadside assistance'),
            Divider(height: 1, color: colors.outlineVariant),
            Expanded(
              child: AppResponsivePage(
                maxContentWidth: 720,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppDimensions.s12),
                    Text(
                      'Tell the workshop which vehicle needs help, where it '
                      "is, and what's wrong.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s20),
                    _Section(
                      title: 'Which vehicle needs help?',
                      child: _VehicleField(
                        vehicles: vehicles,
                        selected: _vehicle,
                        onSelect: (vehicle) =>
                            setState(() => _vehicle = vehicle),
                        onAddVehicle: () =>
                            context.push(AppRoutes.customerAddVehicle),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s16),
                    _Section(
                      title: 'Where are you?',
                      child: TextField(
                        controller: _locationCtrl,
                        maxLines: 2,
                        minLines: 1,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Enter your current location or landmark',
                          helperText:
                              'Type an address, exit or nearby landmark.',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s16),
                    _Section(
                      title: "What's wrong?",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: AppDimensions.s8,
                            runSpacing: AppDimensions.s8,
                            children: [
                              for (final symptom in _symptoms)
                                ChoiceChip(
                                  label: Text(symptom),
                                  selected: _symptom == symptom,
                                  onSelected: (selected) => setState(
                                    () => _symptom = selected ? symptom : null,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.s12),
                          TextField(
                            controller: _detailCtrl,
                            maxLines: 3,
                            minLines: 2,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              labelText: 'Anything else? (optional)',
                              hintText:
                                  'e.g. Parked in the basement, hard to see',
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_sending) ...[
                      const SizedBox(height: AppDimensions.s16),
                      const CustomerNoticePanel(
                        message: 'Sending your request…',
                        icon: Icons.cloud_upload_outlined,
                        destructive: false,
                      ),
                    ],
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

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.s8),
        child,
      ],
    );
  }
}

/// The customer's own vehicles, or an honest note when there are none.
class _VehicleField extends StatelessWidget {
  final List<CustomerVehicleEntity> vehicles;
  final CustomerVehicleEntity? selected;
  final ValueChanged<CustomerVehicleEntity> onSelect;
  final VoidCallback onAddVehicle;

  const _VehicleField({
    required this.vehicles,
    required this.selected,
    required this.onSelect,
    required this.onAddVehicle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (vehicles.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.s14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'No vehicles registered yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppDimensions.s4),
              Text(
                'You can still send a request. Adding the vehicle helps the '
                'workshop keep your history in one place.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppDimensions.s8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onAddVehicle,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add vehicle'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          for (var index = 0; index < vehicles.length; index++) ...[
            if (index > 0) Divider(height: 1, color: colors.outlineVariant),
            _VehicleOption(
              vehicle: vehicles[index],
              selected: selected?.id == vehicles[index].id,
              onTap: () => onSelect(vehicles[index]),
            ),
          ],
        ],
      ),
    );
  }
}

class _VehicleOption extends StatelessWidget {
  final CustomerVehicleEntity vehicle;
  final bool selected;
  final VoidCallback onTap;

  const _VehicleOption({
    required this.vehicle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: '${vehicle.displayName} ${vehicle.plateNumber}'.trim(),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s14,
            vertical: AppDimensions.s12,
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                size: AppDimensions.iconMd,
                color: selected ? colors.primary : colors.outline,
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Text(
                  vehicle.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
              if (vehicle.plateNumber.trim().isNotEmpty) ...[
                const SizedBox(width: AppDimensions.s8),
                CustomerPlateChip(plate: vehicle.plateNumber),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The send action, always reachable without scrolling.
class _Dock extends StatelessWidget {
  final bool sending;
  final VoidCallback onCall;
  final VoidCallback onSubmit;

  const _Dock({
    required this.sending,
    required this.onCall,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.outlineVariant)),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.s16,
          AppDimensions.s12,
          AppDimensions.s16,
          0,
        ),
        child: Row(
          children: [
            OutlinedButton.icon(
              onPressed: sending ? null : onCall,
              icon: const Icon(Icons.phone_outlined, size: 18),
              label: const Text('Call'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(96, AppDimensions.touchTarget),
              ),
            ),
            const SizedBox(width: AppDimensions.s12),
            Expanded(
              child: FilledButton(
                onPressed: sending ? null : onSubmit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppDimensions.touchTarget),
                ),
                child: Text(
                  sending ? 'Sending request…' : 'Request assistance',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
