import 'package:customer_app/core/local/vehicle_identity_store.dart';
import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';
import 'package:customer_app/features/customer/presentation/support/failed_breakdown_sync.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_notice_panel.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_plate_chip.dart';
import 'package:customer_app/l10n/gen/customer_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_core/shared_core.dart';

/// Roadside assistance as an emergency HUD: what broke, where the car is,
/// which car — with the hotline and the send action always in reach.
///
/// The backend contract is deliberately small — an issue, an optional vehicle,
/// and a free-text location — and it stores a `pending` request that a
/// supervisor later assigns to an advisor. Nothing here claims more than that:
/// no dispatch, no live arrival time, no towing, no automatic location. The
/// customer using this screen is standing next to a broken-down car, so
/// targets are large, contrast is high and validation is inline.
class CustomerBreakdownHelpView extends ConsumerStatefulWidget {
  const CustomerBreakdownHelpView({super.key});

  @override
  ConsumerState<CustomerBreakdownHelpView> createState() =>
      _CustomerBreakdownHelpViewState();
}

class _CustomerBreakdownHelpViewState
    extends ConsumerState<CustomerBreakdownHelpView> {
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

  /// Symptom presets with emergency iconography. They fill the single text
  /// field the contract has; the backend stores the text as the issue and
  /// promises no specific service, so nothing here names one.
  List<(String, IconData)> _symptoms(CustomerLocalizations t) => [
    (t.sosTyre, Icons.tire_repair),
    (t.sosNoStart, Icons.key_off_rounded),
    (t.sosBattery, Icons.battery_alert_rounded),
    (t.sosOverheat, Icons.thermostat_rounded),
    (t.sosBrake, Icons.stop_circle_outlined),
    (t.sosWarning, Icons.warning_amber_rounded),
    (t.sosAccident, Icons.car_crash_rounded),
    (t.sosLockout, Icons.lock_rounded),
    (t.sosOther, Icons.more_horiz_rounded),
  ];

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

    final t = context.cx;
    final issue = _issueText;
    if (issue.isEmpty) {
      _notice(t.sosIssueRequired);
      return;
    }
    final location = _locationCtrl.text.trim();
    if (location.isEmpty) {
      _notice(t.sosLocationRequired);
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
        _notice(t.sosTimeout);
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
      _notice(e is AppException ? e.message : t.sosSendFail);
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
        _notice(context.cx.sosQueueFail);
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
    final t = context.cx;
    _notice(cleared ? t.sosRetryDone : t.sosRetryFail);
  }

  /// Discards a saved request that cannot be delivered.
  Future<void> _confirmRemoveFailedRequest() async {
    if (_retrying || _removing) return;
    final t = context.cx;
    final confirmed = await showAppConfirmationDialog(
      context,
      title: t.sosRemoveTitle,
      message: t.sosRemoveBody,
      confirmLabel: t.sosRemove,
      cancelLabel: t.sosKeep,
      icon: Icons.delete_outline_rounded,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => _removing = true);
    await ref.read(failedBreakdownSyncProvider).remove();
    if (!mounted) return;
    setState(() => _removing = false);
    _notice(context.cx.sosRemoved);
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
    if (!opened && mounted) _notice(context.cx.sosDialFail);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = context.cx;
    final vehicles = _vehicles;
    final failedRequests = ref
        .watch(failedBreakdownSyncProvider)
        .failedBreakdowns();

    return Scaffold(
      // Phase 07.1: bespoke AppTopBar migrated to the shared workspace bar.
      appBar: WorkspaceAppBar(title: t.sosTitle, showBack: true),
      bottomNavigationBar: _Dock(
        sending: _sending,
        onCall: _callWorkshop,
        onSubmit: _submit,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
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
                    _EmergencyBanner(onCall: _callWorkshop),
                    const SizedBox(height: AppDimensions.s20),
                    _Section(
                      title: t.sosVehicleTitle,
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
                      title: t.sosLocationTitle,
                      child: TextField(
                        controller: _locationCtrl,
                        maxLines: 2,
                        minLines: 1,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: t.sosLocationHint,
                          helperText: t.sosLocationHelp,
                          prefixIcon: const Icon(
                            Icons.location_on_outlined,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s16),
                    _Section(
                      title: t.sosIssueTitle,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: AppDimensions.s8,
                            runSpacing: AppDimensions.s8,
                            children: [
                              for (final (label, icon)
                                  in _symptoms(t))
                                ChoiceChip(
                                  label: Text(label),
                                  avatar: Icon(icon, size: 18),
                                  selected: _symptom == label,
                                  onSelected: (selected) => setState(
                                    () => _symptom = selected ? label : null,
                                  ),
                                  // The app's chip theme labels in primary, which
                                  // would be invisible on the primary fill.
                                  labelStyle: theme.textTheme.labelLarge
                                      ?.copyWith(
                                        color: _symptom == label
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
                            decoration: InputDecoration(
                              labelText: t.sosDetailLabel,
                              hintText: t.sosDetailHint2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_sending) ...[
                      const SizedBox(height: AppDimensions.s16),
                      CustomerNoticePanel(
                        message: t.sosSendingNote,
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

/// High-contrast emergency band: the situation, the subtitle and the
/// LTR-locked hotline. The number dials the same workshop line as the dock.
class _EmergencyBanner extends StatelessWidget {
  final VoidCallback onCall;

  const _EmergencyBanner({required this.onCall});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = context.cx;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.s16),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: colors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.error,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sos,
              color: colors.onError,
            ),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.sosSub,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.s4),
                InkWell(
                  onTap: onCall,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.sosHotlineLabel,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.error,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          '800 674 368',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
    final t = context.cx;
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
      label: plural ? t.sosRecoveryMany : t.sosRecoveryOne,
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
                    plural ? t.sosRecoveryMany : t.sosRecoveryOne,
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
              plural ? t.sosRecoveryBodyMany : t.sosRecoveryBodyOne,
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
                    t.sosSavedCount(requests.length),
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
                  child: Text(retrying ? t.sosRetrying : t.sosRetry),
                ),
                OutlinedButton.icon(
                  onPressed: _busy ? null : onRemove,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: Text(t.sosRemove),
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
    final t = context.cx;

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
                t.sosNoVehicles,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppDimensions.s4),
              Text(
                t.sosNoVehiclesBody,
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
                  label: Text(t.sosAddVehicle),
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
    final t = context.cx;

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
              label: Text(t.sosCallWorkshop),
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
                  sending ? t.sosSending : t.sosSend,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
