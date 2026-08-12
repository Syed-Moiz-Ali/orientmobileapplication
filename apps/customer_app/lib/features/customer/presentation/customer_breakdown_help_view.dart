import 'package:customer_app/core/local/sync_providers.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';

class CustomerBreakdownHelpView extends ConsumerStatefulWidget {
  const CustomerBreakdownHelpView({super.key});

  @override
  ConsumerState<CustomerBreakdownHelpView> createState() =>
      _CustomerBreakdownHelpViewState();
}

class _CustomerBreakdownHelpViewState
    extends ConsumerState<CustomerBreakdownHelpView> {
  CustomerVehicleEntity? _selectedVehicle;
  String? _selectedIssue;
  final _locationCtrl = TextEditingController(
    text: 'Current GPS Location (Auto-detected)',
  );
  bool _isSaving = false;

  List<CustomerVehicleEntity> get _vehicles =>
      ref.watch(customerDashboardProvider).vehicles;

  static const _issues = [
    (
      Icons.battery_alert_rounded,
      'Battery Dead',
      'Jumpstart or battery replacement',
    ),
    (Icons.tire_repair_rounded, 'Flat Tyre', 'Tyre change or puncture repair'),
    (
      Icons.device_thermostat_rounded,
      'Overheating',
      'Coolant leak or engine heat',
    ),
    (Icons.local_gas_station_rounded, 'Fuel Empty', 'Emergency fuel delivery'),
    (Icons.key_rounded, 'Key Locked', 'Lockout assistance & key service'),
    (
      Icons.car_crash_rounded,
      'Accident / Towing',
      'Priority flatbed towing unit',
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (_vehicles.isNotEmpty) {
      _selectedVehicle = _vehicles.first;
    }
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedIssue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select the breakdown issue type'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    final local = GenericLocalDataSource(
      Hive.box<dynamic>('customer_breakdowns'),
    );
    final payload = {
      'issue': _selectedIssue ?? '',
      'vehicleId': _selectedVehicle?.id ?? '',
      'vehicleName': _selectedVehicle?.displayName ?? 'Vehicle',
      'vehiclePlate': _selectedVehicle?.plateNumber ?? '',
      'location': _locationCtrl.text,
    };
    var refId = '';
    var synced = true;
    final remote = ref.read(customerRemoteDataSourceProvider);

    try {
      final resp = await remote.createBreakdown(payload);
      refId = resp.id;
    } catch (e, st) {
      ref
          .read(loggerProvider)
          .e(
            'Breakdown API failed - queueing offline',
            error: e,
            stackTrace: st,
          );
      synced = false;
    }

    final id = refId.isNotEmpty ? refId : await IdGenerator.nextId('BD');
    await local.save(id, {
      ...payload,
      'id': id,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
    });

    if (!synced) {
      final queue = ref.read(syncQueueProvider);
      await queue.enqueue(
        SyncOperation(
          id: id,
          entityType: 'breakdown',
          entityId: id,
          changeType: ChangeType.create,
          payload: payload,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      await ref.read(syncEngineProvider).syncAll();
    }

    ref.invalidate(customerBreakdownsProvider);
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _callHelpline() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calling Emergency Helpline: 800-ORIENT (800-674368)'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(
              title: '24/7 Roadside SOS',
              trailing: IconButton(
                onPressed: _callHelpline,
                icon: const Icon(
                  Icons.phone_in_talk_rounded,
                  color: AppColors.danger,
                ),
                tooltip: 'Call Emergency Helpline',
              ),
            ),
            const Divider(height: 1, color: AppColors.line),
            Expanded(
              child: AppResponsivePage(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.s14),
                      decoration: BoxDecoration(
                        color: AppColors.dangerBg,
                        borderRadius: BorderRadius.circular(AppDimensions.r16),
                        border: Border.all(color: AppColors.dangerBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: AppColors.danger,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.sos_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.s12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Emergency Assistance',
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Avg response time: 15–20 mins • Free towing up to 40km',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.text3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s20),
                    Text(
                      'Select Issue Type',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s10),
                    Wrap(
                      spacing: AppDimensions.s8,
                      runSpacing: AppDimensions.s8,
                      children: [
                        for (final item in _issues)
                          _IssueCard(
                            icon: item.$1,
                            title: item.$2,
                            selected: _selectedIssue == item.$2,
                            onTap: () =>
                                setState(() => _selectedIssue = item.$2),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.s20),
                    AppCard(
                      padding: const EdgeInsets.all(AppDimensions.s14),
                      color: AppColors.surface,
                      borderColor: AppColors.border,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dispatch Details',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.s12),
                          Text(
                            'Vehicle Needing Assistance',
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.text3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.s12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.bg,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.r10,
                              ),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<CustomerVehicleEntity>(
                                value: _selectedVehicle,
                                isExpanded: true,
                                hint: Text(
                                  'Choose vehicle from garage',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.text4,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.text4,
                                  size: 20,
                                ),
                                items: _vehicles
                                    .map(
                                      (v) => DropdownMenuItem(
                                        value: v,
                                        child: Text(
                                          '${v.displayName} • ${v.plateNumber}',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedVehicle = v),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.s12),
                          Text(
                            'Current Location',
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.text3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.bg,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.r10,
                              ),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: AppDimensions.s10),
                                const Icon(
                                  Icons.my_location_rounded,
                                  size: 18,
                                  color: AppColors.danger,
                                ),
                                const SizedBox(width: AppDimensions.s8),
                                Expanded(
                                  child: TextFormField(
                                    controller: _locationCtrl,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Enter location or landmark',
                                      border: InputBorder.none,
                                      hintStyle: textTheme.bodySmall?.copyWith(
                                        color: AppColors.text4,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s24),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.s16,
                AppDimensions.s12,
                AppDimensions.s16,
                MediaQuery.of(context).padding.bottom + AppDimensions.s12,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _callHelpline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.dangerBorder),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.s14,
                        vertical: AppDimensions.s12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.rPill,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.phone_rounded, size: 18),
                    label: const Text('Call'),
                  ),
                  const SizedBox(width: AppDimensions.s10),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.rPill,
                            ),
                          ),
                        ),
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.warning_amber_rounded, size: 20),
                        label: Text(
                          _isSaving
                              ? 'Dispatching Unit...'
                              : 'Request Dispatch',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _IssueCard({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: selected ? AppColors.dangerBg : AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.rPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.rPill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s12,
            vertical: AppDimensions.s8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.rPill),
            border: Border.all(
              color: selected ? AppColors.danger : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? AppColors.danger : AppColors.textPrimary,
              ),
              const SizedBox(width: AppDimensions.s6),
              Text(
                title,
                style: textTheme.labelMedium?.copyWith(
                  color: selected ? AppColors.danger : AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
