import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_assign_tasks_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/choose_inspection_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/inspection_provider.dart';
import 'package:staff_app/features/advisor/presentation/pages/repair_order_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/vehicle_delivery_view.dart';

class AdvisorJobDetailView extends ConsumerStatefulWidget {
  final JobCardEntity jc;
  const AdvisorJobDetailView({super.key, required this.jc});

  @override
  ConsumerState<AdvisorJobDetailView> createState() =>
      _AdvisorJobDetailViewState();
}

class _AdvisorJobDetailViewState extends ConsumerState<AdvisorJobDetailView> {
  late JobCardEntity _jc;
  String _assignedTech = '';
  Map<String, dynamic>? _hiveData;
  JobCardDetailResponse? _details;
  String get _detailLookupId => _jc.dbId > 0 ? '${_jc.dbId}' : _jc.id;
  String get _jobCardRef =>
      _details?.id.isNotEmpty == true ? _details!.id : _jc.id;

  @override
  void initState() {
    super.initState();
    _jc = widget.jc;
    _assignedTech = _jc.technician;
    _loadHiveData();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final details = await ref
          .read(advisorRemoteDataSourceProvider)
          .getJobCard(_detailLookupId);
      if (!mounted) return;
      setState(() {
        _details = details;
        if (details.technician.isNotEmpty) _assignedTech = details.technician;
        _jc = _jc.copyWith(
          id: details.id.isNotEmpty ? details.id : _jc.id,
          dbId: details.dbId > 0 ? details.dbId : _jc.dbId,
          customerName: details.customerName.isNotEmpty
              ? details.customerName
              : _jc.customerName,
          vehicleInfo: details.vehicleInfo.isNotEmpty
              ? details.vehicleInfo
              : _jc.vehicleInfo,
          time: details.time.isNotEmpty ? details.time : _jc.time,
          createdDate: details.createdDate.isNotEmpty
              ? details.createdDate
              : _jc.createdDate,
          lastUpdated: details.lastUpdated.isNotEmpty
              ? details.lastUpdated
              : _jc.lastUpdated,
          technician: details.technician.isNotEmpty
              ? details.technician
              : _jc.technician,
          status: JobCardStatus.values.firstWhere(
            (status) => status.name == details.status,
            orElse: () => _jc.status,
          ),
        );
      });
    } catch (_) {}
  }

  void _loadHiveData() {
    try {
      final box = Hive.box<dynamic>('inspections');
      final allData = box.values
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();

      _hiveData = allData.cast<Map<String, dynamic>?>().firstWhere(
        (m) =>
            m?['type'] == 'vehicle_customer' &&
            (m?['id'] == _jc.id ||
                m?['id'] == _detailLookupId ||
                m?['registrationNumber'] == _jc.id ||
                m?['vin'] == _jc.id),
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
      JobCardStatus.inspected ||
      JobCardStatus.approved ||
      JobCardStatus.workAssigned ||
      JobCardStatus.waitingCustomerApproval => colorScheme.secondary,
      JobCardStatus.completed ||
      JobCardStatus.delivered ||
      JobCardStatus.qualityCheckPassed => const Color(0xFF10B981),
      JobCardStatus.waitingParts => colorScheme.error,
      JobCardStatus.qualityCheck ||
      JobCardStatus.vehicleReceived => colorScheme.primary,
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
    JobCardStatus.inspected => 'Inspected',
    JobCardStatus.approved => 'Approved',
    JobCardStatus.workAssigned => 'Work Assigned',
    JobCardStatus.waitingCustomerApproval => 'Waiting Approval',
    JobCardStatus.delivered => 'Delivered',
    JobCardStatus.qualityCheckPassed => 'QC Passed',
  };

  String _getVal(String key) => _hiveData?[key] as String? ?? '';

  String _apiVal(String value, String fallback) =>
      value.isNotEmpty ? value : fallback;

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
            _detailRow(
              Icons.person_outline_rounded,
              'Name',
              _apiVal(
                _details?.customerName ?? '',
                hasData ? _getVal('customerName') : _jc.customerName,
              ),
            ),
            _detailRow(
              Icons.phone_outlined,
              'Phone',
              _apiVal(_details?.phoneNumber ?? '', _getVal('phoneNumber')),
            ),
            _detailRow(
              Icons.email_outlined,
              'Email',
              _apiVal(_details?.email ?? '', _getVal('email')),
            ),
            if (_apiVal(
              _details?.customerGroup ?? '',
              _getVal('customerGroup'),
            ).isNotEmpty)
              _detailRow(
                Icons.group_outlined,
                'Group',
                _apiVal(
                  _details?.customerGroup ?? '',
                  _getVal('customerGroup'),
                ),
              ),
          ]),
          const SizedBox(height: 16),
          _section('Vehicle Telemetry', [
            _detailRow(
              Icons.directions_car_outlined,
              'Vehicle',
              _apiVal(
                _details?.vehicleInfo ?? '',
                hasData
                    ? '${_getVal('make')} ${_getVal('model')}'
                    : _jc.vehicleInfo,
              ),
            ),
            _detailRow(
              Icons.confirmation_number_outlined,
              'Plate',
              _apiVal(
                _details?.registrationNumber ?? '',
                _getVal('registrationNumber'),
              ).toUpperCase(),
              isMono: true,
            ),
            _detailRow(
              Icons.qr_code_rounded,
              'VIN',
              _apiVal(_details?.vin ?? '', _getVal('vin')),
              isMono: true,
            ),
            if (_apiVal(
              _details?.modelYear ?? '',
              _getVal('modelYear'),
            ).isNotEmpty)
              _detailRow(
                Icons.calendar_today,
                'Year',
                _apiVal(_details?.modelYear ?? '', _getVal('modelYear')),
              ),
            if (_apiVal(
              _details?.vehicleColor ?? '',
              _getVal('vehicleColor'),
            ).isNotEmpty)
              _detailRow(
                Icons.color_lens_outlined,
                'Color',
                _apiVal(_details?.vehicleColor ?? '', _getVal('vehicleColor')),
              ),
            _detailRow(
              Icons.speed_rounded,
              'Odometer',
              _getVal('odometerReading').isEmpty
                  ? '--'
                  : '${_getVal('odometerReading')} km',
              isMono: true,
            ),
          ]),
          const SizedBox(height: 16),
          _section('Fuel Level', [_buildFuelLevelDisplay()]),
          const SizedBox(height: 16),
          _section('Service Parameters', [
            _detailRow(
              Icons.build_outlined,
              'Service Type',
              'Vehicle Inspection',
            ),
            _detailRow(Icons.person_outline, 'Advisor', 'Assigned'),
            if (_assignedTech.isNotEmpty)
              _detailRow(
                Icons.engineering_outlined,
                'Technician',
                _assignedTech,
              ),
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
          if (hasData) ...[
            _buildInspectionMediaSection(),
            const SizedBox(height: 16),
          ],

          // ── ACTION BUTTONS ────────────────────────────────────────────────
          _buildWorkflowActions(),
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
              _openDelivery,
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
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _jc.id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.5,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _apiVal(
                        _details?.customerName ?? '',
                        hasData ? _getVal('customerName') : _jc.customerName,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    _statusLabel(_jc.status),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
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
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value, {
    bool isMono = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value.isEmpty ? '--' : value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                fontFeatures: isMono
                    ? const [FontFeature.tabularFigures()]
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelLevelDisplay() {
    final colorScheme = Theme.of(context).colorScheme;
    final fuelLevelValue = _hiveData?['fuelLevel'];
    final fuelLevel = fuelLevelValue is num
        ? fuelLevelValue.toInt()
        : switch (fuelLevelValue?.toString()) {
            '1/4' => 3,
            '1/2' => 5,
            '3/4' => 8,
            'Full' => 10,
            _ => 5,
          };
    final fuelLabel = fuelLevelValue?.toString().isNotEmpty == true
        ? fuelLevelValue.toString()
        : '$fuelLevel/10';

    return Row(
      children: [
        Icon(
          Icons.local_gas_station_rounded,
          size: 16,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 10),
        Text(
          'Gauge Level',
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
        ),
        const Spacer(),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: fuelLevel / 10,
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          fuelLabel,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkItemsSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    ref.watch(advisorWorkItemsRefreshProvider);
    final items =
        ref.watch(advisorWorkItemsProvider(_jobCardRef)).value ??
        const <WorkItemResponse>[];
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
                done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: done
                    ? const Color(0xFF10B981)
                    : colorScheme.onSurfaceVariant,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: done ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInspectionMediaSection() => const SizedBox.shrink();

  Widget _buildWorkflowActions() {
    final colorScheme = Theme.of(context).colorScheme;
    return _section('Next Step', [
      _actionButton(
        _primaryActionLabel,
        _primaryActionIcon,
        colorScheme.primary,
        _runPrimaryAction,
      ),
      if (_jc.status == JobCardStatus.approved) ...[
        const SizedBox(height: 10),
        _actionButton(
          'Assign Technician',
          Icons.assignment_ind_outlined,
          colorScheme.secondary,
          _openAssignTasks,
        ),
      ],
    ]);
  }

  String get _primaryActionLabel => switch (_jc.status) {
    JobCardStatus.vehicleReceived => 'Start Inspection',
    JobCardStatus.inspected => 'Create Estimate',
    JobCardStatus.waitingCustomerApproval => 'Waiting for Customer Approval',
    JobCardStatus.approved => 'Assign Technician',
    JobCardStatus.workAssigned ||
    JobCardStatus.inProgress ||
    JobCardStatus.waitingParts => 'Review Work Items',
    JobCardStatus.completed ||
    JobCardStatus.qualityCheckPassed => 'Deliver Vehicle',
    JobCardStatus.delivered => 'Vehicle Delivered',
    _ => 'Refresh Job Card',
  };

  IconData get _primaryActionIcon => switch (_jc.status) {
    JobCardStatus.vehicleReceived => Icons.fact_check_outlined,
    JobCardStatus.inspected => Icons.receipt_long_outlined,
    JobCardStatus.waitingCustomerApproval => Icons.hourglass_top_rounded,
    JobCardStatus.approved => Icons.assignment_ind_outlined,
    JobCardStatus.completed ||
    JobCardStatus.qualityCheckPassed ||
    JobCardStatus.delivered => Icons.check_circle_outline,
    _ => Icons.work_outline_rounded,
  };

  void _runPrimaryAction() {
    switch (_jc.status) {
      case JobCardStatus.vehicleReceived:
        _startInspection();
      case JobCardStatus.inspected:
        _openEstimate();
      case JobCardStatus.waitingCustomerApproval:
        _loadDetails();
      case JobCardStatus.approved:
        _openAssignTasks();
      case JobCardStatus.completed:
      case JobCardStatus.qualityCheckPassed:
        _openDelivery();
      case JobCardStatus.delivered:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle already delivered')),
        );
      default:
        _loadDetails();
    }
  }

  void _startInspection() {
    ref.read(inspectionProvider.notifier).reset();
    ref.read(inspectionProvider.notifier).setJobCardId(_detailLookupId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChooseInspectionView(
          jobId: _detailLookupId,
          onSelect: () => Navigator.pop(context),
          onSkip: () => Navigator.pop(context),
          onBack: () => Navigator.pop(context),
        ),
      ),
    ).then((_) => _loadDetails());
  }

  void _openEstimate() {
    ref.read(inspectionProvider.notifier).reset();
    ref.read(inspectionProvider.notifier).setJobCardId(_detailLookupId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RepairOrderView(
          fromInspection: true,
          onBack: () => Navigator.pop(context),
        ),
      ),
    ).then((_) => _loadDetails());
  }

  void _openAssignTasks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdvisorAssignTasksView(jobCardRef: _jobCardRef),
      ),
    ).then((_) => _loadDetails());
  }

  void _openDelivery() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VehicleDeliveryView(jobCardRef: _jobCardRef),
      ),
    ).then((_) => _loadDetails());
  }

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
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor ?? Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _callCustomer() {
    final phone = _apiVal(
      _details?.phoneNumber ?? '',
      _getVal('phoneNumber'),
    ).replaceAll(RegExp(r'[^\d+]'), '');
    if (phone.isNotEmpty) launchUrl(Uri.parse('tel:$phone'));
  }
}

class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _PressScale({required this.child, this.onTap});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale>
    with SingleTickerProviderStateMixin {
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
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
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
