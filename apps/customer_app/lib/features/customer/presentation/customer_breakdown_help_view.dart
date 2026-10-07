import 'package:customer_app/core/local/vehicle_identity_store.dart';
import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/failed_breakdown_sync.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_notice_panel.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_plate_chip.dart';
import 'package:flutter/material.dart';
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
  /// exist.
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
  bool _retrying = false;
  bool _removing = false;

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
      if (!await _queue(payload)) {
        // Nothing was saved, so the customer must not be told the request is
        // waiting to reach the workshop; their input and the Call action remain.
        return;
      }
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
  /// True only when the request is durably queued for replay.
  Future<bool> _queue(Map<String, dynamic> payload) async {
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
      return true;
    } catch (e, st) {
      ref
          .read(loggerProvider)
          .e('Failed to queue breakdown request', error: e, stackTrace: st);
      if (mounted) {
        _notice("We couldn't save this request on your device.");
      }
      return false;
    }
  }

  /// Replays the failed requests through the existing sync retry, so the same
  /// operation (and the same delivery key) is re-sent rather than a new one.
  Future<void> _retryFailedRequest() async {
    if (_retrying || _removing) return;
    setState(() => _retrying = true);
    final cleared = await ref.read(failedBreakdownSyncProvider).retry();
    if (!mounted) return;
    setState(() => _retrying = false);
    _notice(
      cleared
          ? 'Your saved request was sent to the workshop.'
          : "We still couldn't send your request. The workshop has not received "
                'it.',
    );
  }

  /// Discards a saved request that cannot be delivered.
  Future<void> _confirmRemoveFailedRequest() async {
    if (_retrying || _removing) return;
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Remove saved request?',
      message:
          'This removes the copy stored on this device. The workshop has not '
          'received it.',
      confirmLabel: 'Remove request',
      cancelLabel: 'Keep request',
      icon: Icons.delete_outline_rounded,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => _removing = true);
    await ref.read(failedBreakdownSyncProvider).remove();
    if (!mounted) return;
    setState(() => _removing = false);
    _notice('Saved request removed.');
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
    final failedRequests = ref
        .watch(failedBreakdownSyncProvider)
        .failedBreakdowns();

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
                    if (failedRequests.isNotEmpty) ...[
                      _FailedRequestRecovery(
                        requests: failedRequests,
                        retrying: _retrying,
                        removing: _removing,
                        onRetry: _retryFailedRequest,
                        onRemove: _confirmRemoveFailedRequest,
                      ),
                      const SizedBox(height: AppDimensions.s16),
                    ],
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
                                  // The app's chip theme labels in primary, which
                                  // would be invisible on the primary fill.
                                  labelStyle: theme.textTheme.labelLarge
                                      ?.copyWith(
                                        color: _symptom == symptom
                                            ? colors.onPrimary
                                            : colors.primary,
                                        fontWeight: FontWeight.w700,
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

/// Recovery for a roadside request the workshop never received.
///
/// This is recovery state, not history: it exists only while a request is still
/// undelivered, and disappears the moment it is sent or removed.
class _FailedRequestRecovery extends StatelessWidget {
  final List<SyncOperation> requests;
  final bool retrying;
  final bool removing;
  final VoidCallback onRetry;
  final VoidCallback onRemove;

  const _FailedRequestRecovery({
    required this.requests,
    required this.retrying,
    required this.removing,
    required this.onRetry,
    required this.onRemove,
  });

  bool get _busy => retrying || removing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final plural = requests.length > 1;

    final payload = requests.first.payload;
    final detail =
        [payload['vehicleName'], payload['issue'], payload['location']]
            .map((value) => (value ?? '').toString().trim())
            .where((value) => value.isNotEmpty)
            .join('  ·  ');

    return Semantics(
      container: true,
      liveRegion: true,
      label: plural
          ? "We couldn't send your saved roadside requests. The workshop has "
                'not received them.'
          : "We couldn't send your saved roadside request. The workshop has "
                'not received it.',
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.s14),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            colors.error.withValues(alpha: 0.06),
            colors.surface,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: colors.error.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.sync_problem_rounded,
                  size: AppDimensions.iconMd,
                  color: colors.error,
                ),
                const SizedBox(width: AppDimensions.s8),
                Expanded(
                  child: Text(
                    plural
                        ? "We couldn't send your roadside requests"
                        : "We couldn't send your roadside request",
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s6),
            Text(
              plural
                  ? 'They are saved on this device, but the workshop has not '
                        'received them. Try again, or call the workshop if you '
                        'need help now.'
                  : "It's saved on this device, but the workshop has not "
                        'received it. Try sending it again, or call the '
                        'workshop if you need help now.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface,
                height: 1.45,
              ),
            ),
            if (detail.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.s6),
              if (plural)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '${requests.length} saved requests',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              Text(
                detail,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.s10),
            Wrap(
              spacing: AppDimensions.s8,
              runSpacing: AppDimensions.s4,
              children: [
                FilledButton(
                  onPressed: _busy ? null : onRetry,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, AppDimensions.touchTarget),
                  ),
                  child: Text(retrying ? 'Retrying…' : 'Retry sending'),
                ),
                OutlinedButton.icon(
                  onPressed: _busy ? null : onRemove,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Remove request'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.error,
                    minimumSize: const Size(0, AppDimensions.touchTarget),
                    side: BorderSide(
                      color: colors.error.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ],
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppDimensions.touchTarget,
          ),
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
        // A plain Row (not a Center) so the bar keeps its intrinsic height;
        // centring here would make it claim the whole Scaffold.
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
