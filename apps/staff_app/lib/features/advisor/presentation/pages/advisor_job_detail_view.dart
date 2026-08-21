import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_assign_tasks_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/vehicle_delivery_view.dart';

class AdvisorJobDetailView extends ConsumerStatefulWidget {
  final JobCardEntity jc;
  const AdvisorJobDetailView({super.key, required this.jc});

  @override
  ConsumerState<AdvisorJobDetailView> createState() => _AdvisorJobDetailViewState();
}

class _AdvisorJobDetailViewState extends ConsumerState<AdvisorJobDetailView> {
  late JobCardEntity _jc;
  String _assignedTech = '';
  Map<String, dynamic>? _hiveData;

  @override
  void initState() {
    super.initState();
    _jc = widget.jc;
    _assignedTech = _jc.technician;
    _loadHiveData();
  }

  void _loadHiveData() {
    try {
      final box = Hive.box<dynamic>('inspections');
      final allData = box.values.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();

      _hiveData = allData.cast<Map<String, dynamic>?>().firstWhere(
        (m) =>
            m?['type'] == 'vehicle_customer' &&
            (m?['id'] == _jc.id || m?['registrationNumber'] == _jc.id || m?['vin'] == _jc.id),
        orElse: () => null,
      );

      if (_hiveData != null && mounted) {
        setState(() {
          _assignedTech = _hiveData!['technician'] as String? ?? _assignedTech;
        });
      }
    } catch (_) {}
  }

  Color _statusColor(BuildContext context, JobCardStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (status) {
      JobCardStatus.inProgress => colorScheme.primary,
      JobCardStatus.pendingApproval ||
      JobCardStatus.pending ||
      JobCardStatus.awaitingSupervisor ||
      JobCardStatus.waitingCustomerApproval => colorScheme.secondary,
      JobCardStatus.completed || JobCardStatus.delivered || JobCardStatus.qualityCheckPassed => const Color(0xFF10B981),
      JobCardStatus.waitingParts => colorScheme.error,
      JobCardStatus.qualityCheck || JobCardStatus.vehicleReceived => colorScheme.primary,
      JobCardStatus.cancelled => colorScheme.onSurfaceVariant,
    };
  }

  String _statusLabel(JobCardStatus status) => switch (status) {
    JobCardStatus.inProgress => 'In Progress',
    JobCardStatus.pendingApproval => 'Pending Approval',
    JobCardStatus.completed => 'Completed',
    JobCardStatus.waitingParts => 'Waiting Parts',
    JobCardStatus.qualityCheck => 'QC Check',
    JobCardStatus.cancelled => 'Cancelled',
    JobCardStatus.pending => 'Pending',
    JobCardStatus.awaitingSupervisor => 'Awaiting Supervisor',
    JobCardStatus.vehicleReceived => 'Vehicle Received',
    JobCardStatus.waitingCustomerApproval => 'Waiting Approval',
    JobCardStatus.delivered => 'Delivered',
    JobCardStatus.qualityCheckPassed => 'QC Passed',
  };

  String _getVal(String key) => _hiveData?[key] as String? ?? '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final hasData = _hiveData != null;
    final statusColor = _statusColor(context, _jc.status);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _jc.id,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        children: [
          _headerCard(statusColor, hasData),
          const SizedBox(height: 16),
          _section('Customer Details', [
            _detailRow(Icons.person_outline_rounded, 'Name', hasData ? _getVal('customerName') : _jc.customerName),
            _detailRow(Icons.phone_outlined, 'Phone', _getVal('phoneNumber')),
            _detailRow(Icons.email_outlined, 'Email', _getVal('email')),
            if (_getVal('customerGroup').isNotEmpty)
              _detailRow(Icons.group_outlined, 'Group', _getVal('customerGroup')),
          ]),
          const SizedBox(height: 16),
          _section('Vehicle Telemetry', [
            _detailRow(
              Icons.directions_car_outlined,
              'Vehicle',
              hasData ? '${_getVal('make')} ${_getVal('model')}' : _jc.vehicleInfo,
            ),
            _detailRow(
              Icons.confirmation_number_outlined,
              'Plate',
              _getVal('registrationNumber').toUpperCase(),
              isMono: true,
            ),
            _detailRow(Icons.qr_code_rounded, 'VIN', _getVal('vin'), isMono: true),
            if (_getVal('modelYear').isNotEmpty) _detailRow(Icons.calendar_today, 'Year', _getVal('modelYear')),
            if (_getVal('vehicleColor').isNotEmpty)
              _detailRow(Icons.color_lens_outlined, 'Color', _getVal('vehicleColor')),
            _detailRow(
              Icons.speed_rounded,
              'Odometer',
              _getVal('odometerReading').isEmpty ? '--' : '${_getVal('odometerReading')} km',
              isMono: true,
            ),
          ]),
          const SizedBox(height: 16),
          _section('Fuel Level', [_buildFuelLevelDisplay()]),
          const SizedBox(height: 16),
          _section('Service Parameters', [
            _detailRow(Icons.build_outlined, 'Service Type', 'Vehicle Inspection'),
            _detailRow(Icons.person_outline, 'Advisor', 'Assigned'),
            if (_assignedTech.isNotEmpty) _detailRow(Icons.engineering_outlined, 'Technician', _assignedTech),
            _detailRow(
              Icons.schedule_outlined,
              'Created',
              _jc.createdDate.isNotEmpty ? _jc.createdDate : _jc.time,
              isMono: true,
            ),
            _detailRow(
              Icons.update_rounded,
              'Last Updated',
              _jc.lastUpdated.isNotEmpty ? _jc.lastUpdated : _jc.time,
              isMono: true,
            ),
          ]),
          const SizedBox(height: 16),
          _buildWorkItemsSection(),
          const SizedBox(height: 16),
          if (hasData) ...[_buildInspectionMediaSection(), const SizedBox(height: 16)],

          // ── ACTION BUTTONS ────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  'Update Status',
                  Icons.edit_outlined,
                  colorScheme.primary,
                  () => _showStatusSheet(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionButton(
                  'Assign Tasks',
                  Icons.assignment_ind_outlined,
                  colorScheme.secondary,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdvisorAssignTasksView(jobCardRef: _jc.id)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _actionButton(
            'Call Customer',
            Icons.phone_outlined,
            colorScheme.surfaceContainerHighest,
            _callCustomer,
            textColor: colorScheme.onSurface,
            iconColor: colorScheme.primary,
          ),
          if (_jc.status == JobCardStatus.completed) ...[
            const SizedBox(height: 10),
            _actionButton(
              'Deliver Vehicle',
              Icons.check_circle_outline,
              const Color(0xFF10B981),
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => VehicleDeliveryView(jobCardRef: _jc.id))),
            ),
          ],
        ],
      ),
    );
  }

  Widget _headerCard(Color statusColor, bool hasData) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _jc.id,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasData ? _getVal('customerName') : _jc.customerName,
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabel(_jc.status).toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: colorScheme.onSurface),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, {bool isMono = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value.isEmpty ? '--' : value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              fontFeatures: isMono ? const [FontFeature.tabularFigures()] : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelLevelDisplay() {
    final colorScheme = Theme.of(context).colorScheme;
    final fuelLevel = (_hiveData?['fuelLevel'] as num?)?.toInt() ?? 5;

    return Row(
      children: [
        Icon(Icons.local_gas_station_rounded, size: 16, color: colorScheme.primary),
        const SizedBox(width: 10),
        Text('Gauge Level', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
        const Spacer(),
        Row(
          children: List.generate(10, (i) {
            return Container(
              width: 12,
              height: 6,
              margin: const EdgeInsets.only(right: 2),
              decoration: BoxDecoration(
                color: i < fuelLevel ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
        const SizedBox(width: 8),
        Text(
          '$fuelLevel/10',
          style: TextStyle(fontWeight: FontWeight.w800, color: colorScheme.onSurface, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildWorkItemsSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    ref.watch(advisorWorkItemsRefreshProvider);
    final items = ref.watch(advisorWorkItemsProvider(_jc.id)).value ?? const <WorkItemResponse>[];
    if (items.isEmpty) return const SizedBox.shrink();

    return _section(
      'Work Items (${items.where((i) => i.status == 'completed').length}/${items.length} done)',
      items.map((item) {
        final done = item.status == 'completed';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(
                done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: done ? const Color(0xFF10B981) : colorScheme.onSurfaceVariant,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.description,
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: done ? FontWeight.w700 : FontWeight.w500),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInspectionMediaSection() => const SizedBox.shrink();

  Widget _actionButton(
    String label,
    IconData icon,
    Color bg,
    VoidCallback onTap, {
    Color? textColor,
    Color? iconColor,
  }) {
    return _PressScale(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor ?? Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: textColor ?? Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _callCustomer() {
    final phone = _getVal('phoneNumber').replaceAll(RegExp(r'[^\d+]'), '');
    if (phone.isNotEmpty) launchUrl(Uri.parse('tel:$phone'));
  }

  void _showStatusSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Update Status', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 12),
            ...JobCardStatus.values.map(
              (s) => ListTile(title: Text(_statusLabel(s)), onTap: () => _updateStatus(s, ctx)),
            ),
          ],
        ),
      ),
    );
  }

  void _updateStatus(JobCardStatus status, BuildContext ctx) {
    Navigator.pop(ctx);
    setState(() => _jc = _jc.copyWith(status: status));
    ref.read(advisorRefreshProvider.notifier).state++;
  }
}

class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _PressScale({required this.child, this.onTap});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
