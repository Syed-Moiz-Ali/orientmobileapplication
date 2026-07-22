import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/job_card_entity.dart';
import 'package:orientmobileapplication/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:orientmobileapplication/features/advisor/presentation/widgets/advisor_status_badge.dart';

class _StatusStyle {
  final String label;
  final Color color;
  final Color bg;
  const _StatusStyle(this.label, this.color, this.bg);
}

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

  @override
  void initState() {
    super.initState();
    _jc = widget.jc;
    _assignedTech = _jc.technician;
  }

  _StatusStyle get _s => switch (_jc.status) {
    JobCardStatus.inProgress => _StatusStyle(
      'In Progress',
      AppColors.accent,
      AppColors.accent.withValues(alpha: 0.12),
    ),
    JobCardStatus.pendingApproval => _StatusStyle(
      'Pending',
      AppColors.warning,
      AppColors.warningBg,
    ),
    JobCardStatus.completed => _StatusStyle(
      'Completed',
      AppColors.success,
      AppColors.successBg,
    ),
    JobCardStatus.waitingParts => _StatusStyle(
      'Waiting Parts',
      AppColors.danger,
      AppColors.dangerBg,
    ),
    JobCardStatus.qualityCheck => _StatusStyle(
      'QC Check',
      AppColors.info,
      AppColors.infoBg,
    ),
    JobCardStatus.cancelled => _StatusStyle(
      'Cancelled',
      AppColors.text3,
      AppColors.surfaceAlt,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final s = _s;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _jc.id,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.text2),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        children: [
          _headerCard(s),
          const SizedBox(height: 14),
          _section('Customer Details', [
            _detailRow(Icons.person_outline_rounded, 'Name', _jc.customerName),
            _detailRow(Icons.phone_outlined, 'Phone', '+971 50 123 4567'),
            _detailRow(
              Icons.email_outlined,
              'Email',
              '${_jc.customerName.toLowerCase().replaceAll(' ', '.')}@email.com',
            ),
          ]),
          const SizedBox(height: 14),
          _section('Vehicle Information', [
            _detailRow(
              Icons.directions_car_outlined,
              'Vehicle',
              _jc.vehicleInfo,
            ),
            _detailRow(Icons.qr_code_rounded, 'VIN', 'WBA8E9G58GNT44078'),
            _detailRow(Icons.color_lens_outlined, 'Color', 'Alpine White'),
            _detailRow(Icons.speed_rounded, 'Odometer', '41,200 km'),
          ]),
          const SizedBox(height: 14),
          _section('Service Details', [
            _detailRow(Icons.build_outlined, 'Service Type', 'Full Inspection'),
            _detailRow(Icons.person_outline, 'Advisor', 'Ali Rahman'),
            if (_assignedTech.isNotEmpty)
              _detailRow(
                Icons.engineering_outlined,
                'Technician',
                _assignedTech,
              ),
            _detailRow(Icons.engineering_outlined, 'Bay', 'Bay 03'),
            _detailRow(
              Icons.schedule_outlined,
              'Created',
              _jc.createdDate.isNotEmpty ? _jc.createdDate : _jc.time,
            ),
            _detailRow(
              Icons.update_rounded,
              'Last Updated',
              _jc.lastUpdated.isNotEmpty ? _jc.lastUpdated : _jc.time,
            ),
          ]),
          const SizedBox(height: 14),
          _section('Job Timeline', [
            _timelineStep('Job Created', _jc.time, true),
            _timelineStep('Vehicle Received', '09:15 AM', true),
            _timelineStep(
              'Inspection Started',
              '09:30 AM',
              _jc.status == JobCardStatus.inProgress ||
                  _jc.status == JobCardStatus.completed ||
                  _jc.status == JobCardStatus.qualityCheck,
            ),
            _timelineStep(
              'Service Work',
              '10:00 AM',
              _jc.status == JobCardStatus.completed ||
                  _jc.status == JobCardStatus.qualityCheck,
            ),
            _timelineStep(
              'Quality Check',
              '--:--',
              _jc.status == JobCardStatus.qualityCheck ||
                  _jc.status == JobCardStatus.completed,
            ),
            _timelineStep(
              'Ready for Delivery',
              '--:--',
              _jc.status == JobCardStatus.completed,
            ),
          ]),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  context,
                  'Update Status',
                  Icons.edit_outlined,
                  AppColors.accent,
                  () => _showStatusSheet(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionButton(
                  context,
                  'Assign Technician',
                  Icons.person_add_outlined,
                  AppColors.success,
                  () => _showAssignTechSheet(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: _actionButton(
              context,
              'Call Customer',
              Icons.phone_outlined,
              AppColors.text3,
              () {},
            ),
          ),
        ],
      ),
    );
  }

  List<String> get _technicians => const [
    'Mohammed Hassan',
    'Ali Ahmed',
    'Ravi Kumar',
    'Hassan Ibrahim',
    'Omar Khalid',
    'Yousef Ali',
    'Bilal Khan',
    'David Osei',
    'James Patel',
    'Mohammed Salim',
  ];

  void _showStatusSheet(BuildContext context) {
    final statuses = JobCardStatus.values;
    final labels = {
      JobCardStatus.inProgress: 'In Progress',
      JobCardStatus.pendingApproval: 'Pending Approval',
      JobCardStatus.completed: 'Completed',
      JobCardStatus.waitingParts: 'Waiting Parts',
      JobCardStatus.qualityCheck: 'QC Check',
      JobCardStatus.cancelled: 'Cancelled',
    };
    final colors = {
      JobCardStatus.inProgress: AppColors.accent,
      JobCardStatus.pendingApproval: AppColors.warning,
      JobCardStatus.completed: AppColors.success,
      JobCardStatus.waitingParts: AppColors.danger,
      JobCardStatus.qualityCheck: AppColors.info,
      JobCardStatus.cancelled: AppColors.text3,
    };
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.r28),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(AppDimensions.r2),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Update Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...statuses
                .where((s) => s != _jc.status)
                .map((s) => _statusOption(ctx, s, labels[s]!, colors[s]!)),
          ],
        ),
      ),
    );
  }

  void _showAssignTechSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.r28),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.4,
          maxChildSize: 0.8,
          expand: false,
          builder: (_, scrollCtrl) => SingleChildScrollView(
            controller: scrollCtrl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(AppDimensions.r2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Assign Technician',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._technicians.map((t) => _techOption(ctx, t)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateStatus(JobCardStatus status, BuildContext ctx) {
    final now = DateTime.now();
    final updated =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    Navigator.pop(ctx);
    final box = Hive.box<dynamic>('inspections');
    final allData = box.values
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
    final match = allData.where((m) => m['vin'] == _jc.id).toList();
    for (final m in match) {
      m['status'] = status.name;
      m['lastUpdated'] = updated;
      box.put(m['vin'], m);
    }
    setState(() {
      _jc = _jc.copyWith(status: status, lastUpdated: updated);
    });
    ref.read(advisorRefreshProvider.notifier).state++;
  }

  void _assignTechnician(String technician, BuildContext ctx) {
    final now = DateTime.now();
    final updated =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    Navigator.pop(ctx);
    final box = Hive.box<dynamic>('inspections');
    final allData = box.values
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
    final match = allData.where((m) => m['vin'] == _jc.id).toList();
    for (final m in match) {
      m['technician'] = technician;
      m['status'] = JobCardStatus.inProgress.name;
      m['lastUpdated'] = updated;
      box.put(m['vin'], m);
    }
    setState(() {
      _jc = _jc.copyWith(
        status: JobCardStatus.inProgress,
        lastUpdated: updated,
      );
      _assignedTech = technician;
    });
    ref.read(advisorRefreshProvider.notifier).state++;
  }

  Widget _statusOption(
    BuildContext ctx,
    JobCardStatus status,
    String label,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _updateStatus(status, ctx),
        borderRadius: BorderRadius.circular(AppDimensions.r12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppDimensions.r12),
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.text3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _techOption(BuildContext ctx, String name) {
    final initials = name
        .split(' ')
        .map((n) => n.isNotEmpty ? n[0] : '')
        .join();
    final isSelected = _assignedTech == name;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => _assignTechnician(name, ctx),
        borderRadius: BorderRadius.circular(AppDimensions.r12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accent.withValues(alpha: 0.08)
                : AppColors.surfaceAlt,
            border: isSelected
                ? Border.all(color: AppColors.accent.withValues(alpha: 0.3))
                : null,
            borderRadius: BorderRadius.circular(AppDimensions.r12),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.navy, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      'Technician',
                      style: TextStyle(fontSize: 11, color: AppColors.text3),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected ? Icons.check_circle : Icons.add_circle_outline,
                size: 20,
                color: isSelected ? AppColors.accent : AppColors.text3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerCard(_StatusStyle s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navy, AppColors.navy.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.r18),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                  color: s.color,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppDimensions.r2),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _jc.id,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _jc.customerName,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              AdvisorStatusBadge(s.label, s.color, s.bg),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              _headerStat(
                '\$${(_jc.id.hashCode % 5000 + 500).toString()}',
                'Est. Amount',
              ),
              const SizedBox(width: 24),
              _headerStat(
                _jc.vehicleInfo.split(' ').firstOrNull ?? '-',
                'Brand',
              ),
              const SizedBox(width: 24),
              _headerStat('Bay 03', 'Location'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.5),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppDimensions.r2),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.text3),
          const SizedBox(width: 9),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.text2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineStep(String title, String time, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: done ? 10 : 8,
                height: done ? 10 : 8,
                decoration: BoxDecoration(
                  color: done ? AppColors.success : AppColors.text4,
                  shape: BoxShape.circle,
                ),
              ),
              Container(width: 1, height: 22, color: AppColors.line),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: done ? AppColors.textPrimary : AppColors.text3,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              color: done ? AppColors.text2 : AppColors.text4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.8)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.r12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
