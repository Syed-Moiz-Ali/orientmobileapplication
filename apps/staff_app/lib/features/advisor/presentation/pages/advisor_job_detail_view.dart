import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:staff_app/core/platform/file_ops.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_status_badge.dart';

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

  _StatusStyle get _s => switch (_jc.status) {
    JobCardStatus.inProgress => _StatusStyle('In Progress', AppColors.accent, AppColors.accent.withValues(alpha: 0.12)),
    JobCardStatus.pendingApproval => _StatusStyle('Pending', AppColors.warning, AppColors.warningBg),
    JobCardStatus.completed => _StatusStyle('Completed', AppColors.success, AppColors.successBg),
    JobCardStatus.waitingParts => _StatusStyle('Waiting Parts', AppColors.danger, AppColors.dangerBg),
    JobCardStatus.qualityCheck => _StatusStyle('QC Check', AppColors.info, AppColors.infoBg),
    JobCardStatus.cancelled => _StatusStyle('Cancelled', AppColors.text3, AppColors.surfaceAlt),
  };

  String _getVal(String key) => _hiveData?[key] as String? ?? '';

  @override
  Widget build(BuildContext context) {
    final s = _s;
    final hasData = _hiveData != null;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
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
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        children: [
          _headerCard(s, hasData),
          const SizedBox(height: 14),
          _section('Customer Details', [
            _detailRow(Icons.person_outline_rounded, 'Name', hasData ? _getVal('customerName') : _jc.customerName),
            _detailRow(Icons.phone_outlined, 'Phone', _getVal('phoneNumber')),
            _detailRow(Icons.email_outlined, 'Email', _getVal('email')),
            if (_getVal('customerGroup').isNotEmpty)
              _detailRow(Icons.group_outlined, 'Group', _getVal('customerGroup')),
          ]),
          const SizedBox(height: 14),
          _section('Vehicle Information', [
            _detailRow(
              Icons.directions_car_outlined,
              'Vehicle',
              hasData ? '${_getVal('make')} ${_getVal('model')}' : _jc.vehicleInfo,
            ),
            _detailRow(Icons.confirmation_number_outlined, 'Reg No', _getVal('registrationNumber')),
            _detailRow(Icons.qr_code_rounded, 'VIN', _getVal('vin')),
            if (_getVal('modelYear').isNotEmpty) _detailRow(Icons.calendar_today, 'Year', _getVal('modelYear')),
            if (_getVal('vehicleColor').isNotEmpty)
              _detailRow(Icons.color_lens_outlined, 'Color', _getVal('vehicleColor')),
            _detailRow(
              Icons.speed_rounded,
              'Odometer',
              _getVal('odometerReading').isEmpty ? '--' : '${_getVal('odometerReading')} km',
            ),
          ]),
          const SizedBox(height: 14),
          _section('Fuel Level', [_buildFuelLevelDisplay()]),
          const SizedBox(height: 14),
          _section('Service Details', [
            _detailRow(Icons.build_outlined, 'Service Type', 'Vehicle Inspection'),
            _detailRow(Icons.person_outline, 'Advisor', '--'),
            if (_assignedTech.isNotEmpty) _detailRow(Icons.engineering_outlined, 'Technician', _assignedTech),
            _detailRow(Icons.engineering_outlined, 'Bay', '--'),
            _detailRow(Icons.schedule_outlined, 'Created', _jc.createdDate.isNotEmpty ? _jc.createdDate : _jc.time),
            _detailRow(Icons.update_rounded, 'Last Updated', _jc.lastUpdated.isNotEmpty ? _jc.lastUpdated : _jc.time),
          ]),
          const SizedBox(height: 14),
          _buildWorkItemsSection(),
          const SizedBox(height: 14),

          // Inspection media section
          if (hasData) ...[_buildInspectionMediaSection()],

          const SizedBox(height: 14),
          _section('Job Timeline', [
            _timelineStep(
              'Job Created',
              _jc.createdDate.isNotEmpty ? _jc.createdDate.substring(11, 16) : _jc.time,
              true,
            ),
            _timelineStep(
              'Inspection',
              '--:--',
              _jc.status == JobCardStatus.inProgress ||
                  _jc.status == JobCardStatus.completed ||
                  _jc.status == JobCardStatus.qualityCheck,
            ),
            _timelineStep(
              'Service Work',
              '--:--',
              _jc.status == JobCardStatus.completed || _jc.status == JobCardStatus.qualityCheck,
            ),
            _timelineStep('Ready for Delivery', '--:--', _jc.status == JobCardStatus.completed),
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
              _callCustomer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkItemsSection() {
    ref.watch(advisorWorkItemsRefreshProvider);
    final itemsAsync = ref.watch(advisorWorkItemsProvider(_jc.id));
    final items = itemsAsync.value ?? const <WorkItemResponse>[];
    final techniciansAsync = ref.watch(advisorTechniciansProvider);
    final technicians = techniciansAsync.value ?? const <AdvisorTechnicianResponse>[];

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Work Items',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${items.where((i) => i.status == 'completed').length}/${items.length} done',
              style: const TextStyle(color: AppColors.text3, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: items.map((item) {
              final done = item.status == 'completed';
              final inProgress = item.status == 'inProgress';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Icon(
                      done
                          ? Icons.check_circle_rounded
                          : inProgress
                          ? Icons.play_circle_fill_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 18,
                      color: done
                          ? AppColors.success
                          : inProgress
                          ? AppColors.warning
                          : AppColors.text4,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.description,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.itemType == 'INSPECTION' ? 'Inspection' : 'Work'}'
                            '${item.empName.isNotEmpty ? ' · ${item.empName}' : ' · Unassigned'}',
                            style: const TextStyle(color: AppColors.text3, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    if (item.status == 'pending' && item.empId.isEmpty)
                      SizedBox(
                        height: 30,
                        child: OutlinedButton(
                          onPressed: () => _assignWorkItem(context, item, technicians),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.accent,
                            side: const BorderSide(color: AppColors.accent),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.r8),
                            ),
                          ),
                          child: const Text('Assign', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      )
                    else
                      StatusPill(
                        label: done
                            ? 'Completed'
                            : inProgress
                            ? 'In Progress'
                            : 'Pending',
                        bg: done
                            ? AppColors.successBg
                            : inProgress
                            ? AppColors.warningBg
                            : AppColors.primaryBg,
                        fg: done
                            ? AppColors.success
                            : inProgress
                            ? AppColors.warning
                            : AppColors.primary,
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _assignWorkItem(BuildContext context, WorkItemResponse item,
      List<AdvisorTechnicianResponse> technicians) {
    if (technicians.isEmpty) {
      _toast(context, 'No active technicians available');
      return;
    }
    String empId = technicians.first.empId;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.r24)),
          ),
          padding: const EdgeInsets.all(AppDimensions.s16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Assign work item',
                style: AppTextStyles.rajdhaniTitle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                item.description,
                style: const TextStyle(fontSize: 13, color: AppColors.text3),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: empId,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.primaryBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.r12),
                    borderSide: BorderSide.none,
                  ),
                  labelText: 'Technician',
                ),
                items: technicians.map((t) {
                  return DropdownMenuItem<String>(
                    value: t.empId,
                    child: Text(
                      t.name,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (v) => setSheetState(() => empId = v ?? empId),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r12),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await advisorAssignWorkItem(ref, item.id, empId);
                    if (context.mounted) {
                      _toast(context, 'Technician assigned');
                    }
                  },
                  child: const Text(
                    'Assign Technician',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildFuelLevelDisplay() {
    final fuelLevel = (_hiveData?['fuelLevel'] as num?)?.toInt() ?? 5;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.local_gas_station, size: 14, color: AppColors.text3),
          const SizedBox(width: 9),
          const Text(
            'Level',
            style: TextStyle(fontSize: 13, color: AppColors.text2, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(10, (i) {
              return Container(
                width: 14,
                height: 8,
                margin: const EdgeInsets.only(right: 2),
                decoration: BoxDecoration(
                  color: i < fuelLevel ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(AppDimensions.r2),
                ),
              );
            }),
          ),
          const SizedBox(width: 6),
          Text(
            '$fuelLevel/10',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionMediaSection() {
    final box = Hive.box<dynamic>('inspections');
    final allData = box.values.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();

    final inspectionData = allData.where((m) => m.containsKey('media') && m['jobCardId'] == _jc.id).toList();

    if (inspectionData.isEmpty) {
      return const SizedBox.shrink();
    }

    final widgets = <Widget>[];
    for (final insp in inspectionData) {
      widgets.add(_buildInspectionReport(insp));
    }

    return widgets.isEmpty ? const SizedBox.shrink() : Column(children: widgets);
  }

  Widget _buildInspectionReport(Map<String, dynamic> insp) {
    final statusesRaw = insp['statuses'] as Map<String, dynamic>? ?? {};
    final mediaRaw = insp['media'] as Map<String, dynamic>? ?? {};

    final items = <Widget>[];

    final sections = _getInspectionSections();

    for (final sec in sections) {
      final sectionItems = <Widget>[];
      final secItems = (sec['items'] as List).cast<String>();
      for (var i = 0; i < secItems.length; i++) {
        final itemId = '${sec['id']}_$i';
        final itemName = secItems[i];
        final itemMedia = mediaRaw[itemId] as Map<String, dynamic>?;
        final statusValue = statusesRaw[itemId] as String?;
        final hasMedia =
            itemMedia != null &&
            (((itemMedia['photoPaths'] as List?)?.isNotEmpty ?? false) ||
                ((itemMedia['videoPaths'] as List?)?.isNotEmpty ?? false) ||
                (itemMedia['audioPath'] as String?)?.isNotEmpty == true ||
                (itemMedia['note'] as String?)?.isNotEmpty == true);
        final hasCondition = statusValue != null;

        if (hasCondition || hasMedia) {
          sectionItems.add(_buildInspectionItemCard(itemName: itemName, status: statusValue, media: itemMedia));
        }
      }

      if (sectionItems.isNotEmpty) {
        items.add(const SizedBox(height: 14));
        items.add(_section(sec['label'] as String, sectionItems));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: items);
  }

  Widget _buildInspectionItemCard({required String itemName, String? status, Map<String, dynamic>? media}) {
    final hasPhotos = (media?['photoPaths'] as List?)?.isNotEmpty ?? false;
    final hasVideos = (media?['videoPaths'] as List?)?.isNotEmpty ?? false;
    final audioPath = media?['audioPath'] as String? ?? '';
    final note = media?['note'] as String? ?? '';

    final photoPaths = (media?['photoPaths'] as List?)?.cast<String>() ?? [];
    final videoPaths = (media?['videoPaths'] as List?)?.cast<String>() ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFE),
        borderRadius: BorderRadius.circular(AppDimensions.r10),
        border: Border.all(color: const Color(0xFFE8ECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  itemName,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
              if (status != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'good'
                        ? AppColors.successBg
                        : status == 'fair'
                        ? AppColors.warningBg
                        : AppColors.dangerBg,
                    borderRadius: BorderRadius.circular(AppDimensions.rPill),
                    border: Border.all(
                      color: status == 'good'
                          ? AppColors.success.withValues(alpha: 0.2)
                          : status == 'fair'
                          ? AppColors.warning.withValues(alpha: 0.2)
                          : AppColors.danger.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: status == 'good'
                              ? AppColors.success
                              : status == 'fair'
                              ? AppColors.warning
                              : AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        status == 'good'
                            ? 'Good'
                            : status == 'fair'
                            ? 'Fair'
                            : 'Poor',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: status == 'good'
                              ? AppColors.success
                              : status == 'fair'
                              ? AppColors.warning
                              : AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (hasPhotos) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 64,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: photoPaths.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _showFullImage(context, photoPaths[i]),
                  child: Container(
                    width: 64,
                    height: 64,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppDimensions.r8),
                      border: Border.all(color: const Color(0xFFE4E7EE)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.r7),
                      child: localImage(photoPaths[i], fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (hasVideos) ...[
            const SizedBox(height: 6),
            for (final vp in videoPaths.where((p) => p.isNotEmpty && localFileExists(p))) ...[
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => _VideoDetailPlayer(filePath: vp)));
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(AppDimensions.r8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          vp.split('/').last,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
          if (audioPath.isNotEmpty && localFileExists(audioPath)) ...[
            const SizedBox(height: 6),
            _AudioDetailPlayer(audioPath: audioPath),
          ],
          if (note.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(AppDimensions.r8),
                border: Border.all(color: const Color(0xFFE4E7EE)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_rounded, size: 14, color: AppColors.text3),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(note, style: const TextStyle(fontSize: 12, color: AppColors.text2, height: 1.4)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getInspectionSections() {
    return const [
      {
        'id': 'interior_exterior',
        'label': 'INTERIOR/EXTERIOR',
        'items': [
          'Head Light / Tail Light / Turn Signals',
          'Wiper Blade',
          'Mirror',
          'Emergency Brake Adjustment',
          'Horn Operation',
          'Fuel Tank Cap Gasket',
          'A/C Filter',
          'Seat Belts',
          'Dashboard Lights',
          'Clutch Operation',
        ],
      },
      {
        'id': 'under_vehicle',
        'label': 'UNDER VEHICLE',
        'items': [
          'Shock Absorbers / Suspension',
          'Steering Gear Box',
          'Exhaust Pipes',
          'Engine Oil / Fluid Leaks',
          'Brake Lines',
          'U-Joints',
          'Fuel Lines',
          'Inspect Nuts and Bolts on Body Chassis',
        ],
      },
      {
        'id': 'under_hood',
        'label': 'UNDER HOOD',
        'items': [
          'Fluid Level: Oil / Battery / Power Steering',
          'Engine Air Filter',
          'Drive Belts',
          'Engine Coolant Protection',
          'Cooling System Hoses / Heater Hoses',
          'Radiator Core',
        ],
      },
      {
        'id': 'battery',
        'label': 'BATTERY PERFORMANCE',
        'items': ['Battery Terminal / Cables / Mounting', 'Storage Capacity Test'],
      },
    ];
  }

  void _callCustomer() {
    final phone = _getVal('phoneNumber').replaceAll(RegExp(r'[^\d+]'), '');
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No phone number on file'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    launchUrl(Uri.parse('tel:$phone'), mode: LaunchMode.externalApplication);
  }

  void _showFullImage(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            InteractiveViewer(child: localImage(path, fit: BoxFit.contain)),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.r28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(2)),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...statuses.where((s) => s != _jc.status).map((s) => _statusOption(ctx, s, labels[s]!, colors[s]!)),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.r28)),
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
                  decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(2)),
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
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
    final allData = box.values.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
    final match = allData
        .where(
          (m) =>
              m['type'] == 'vehicle_customer' &&
              (m['id'] == _jc.id || m['vin'] == _jc.id || m['registrationNumber'] == _jc.id),
        )
        .toList();
    for (final m in match) {
      m['status'] = status.name;
      m['lastUpdated'] = updated;
      final key = (m['id'] ?? m['vin'] ?? m['registrationNumber']).toString();
      if (key.isNotEmpty) box.put(key, m);
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
    final allData = box.values.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
    final match = allData
        .where(
          (m) =>
              m['type'] == 'vehicle_customer' &&
              (m['id'] == _jc.id || m['vin'] == _jc.id || m['registrationNumber'] == _jc.id),
        )
        .toList();
    for (final m in match) {
      m['technician'] = technician;
      m['status'] = JobCardStatus.inProgress.name;
      m['lastUpdated'] = updated;
      final key = (m['id'] ?? m['vin'] ?? m['registrationNumber']).toString();
      if (key.isNotEmpty) box.put(key, m);
    }
    setState(() {
      _jc = _jc.copyWith(status: JobCardStatus.inProgress, lastUpdated: updated);
      _assignedTech = technician;
    });
    ref.read(advisorRefreshProvider.notifier).state++;
  }

  Widget _statusOption(BuildContext ctx, JobCardStatus status, String label, Color color) {
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
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.text3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _techOption(BuildContext ctx, String name) {
    final initials = name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').join();
    final isSelected = _assignedTech == name;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => _assignTechnician(name, ctx),
        borderRadius: BorderRadius.circular(AppDimensions.r12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent.withValues(alpha: 0.08) : AppColors.surfaceAlt,
            border: isSelected ? Border.all(color: AppColors.accent.withValues(alpha: 0.3)) : null,
            borderRadius: BorderRadius.circular(AppDimensions.r12),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.navy, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
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
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const Text('Technician', style: TextStyle(fontSize: 11, color: AppColors.text3)),
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

  Widget _headerCard(_StatusStyle s, bool hasData) {
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
          BoxShadow(color: AppColors.navy.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4)),
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
                  borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r2)),
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
                      hasData ? _getVal('customerName') : _jc.customerName,
                      style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
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
              _headerStat('\$--', 'Est. Amount'),
              const SizedBox(width: 24),
              _headerStat(hasData ? _getVal('make') : _jc.vehicleInfo.split(' ').firstOrNull ?? '-', 'Brand'),
              const SizedBox(width: 24),
              _headerStat('--', 'Bay'),
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.3),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w600),
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
          BoxShadow(color: AppColors.navy.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
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
                  borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r2)),
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
          Icon(icon, size: 16, color: AppColors.text3),
          const SizedBox(width: 8),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.text2, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '--' : value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
                decoration: BoxDecoration(color: done ? AppColors.success : AppColors.text4, shape: BoxShape.circle),
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

  Widget _actionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.8)]),
          borderRadius: BorderRadius.circular(AppDimensions.r12),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))],
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

class _VideoDetailPlayer extends StatefulWidget {
  final String filePath;
  const _VideoDetailPlayer({required this.filePath});

  @override
  State<_VideoDetailPlayer> createState() => _VideoDetailPlayerState();
}

class _VideoDetailPlayerState extends State<_VideoDetailPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) return;
    _controller = createVideoController(widget.filePath);
    _controller.initialize().then((_) {
      if (mounted) {
        setState(() => _initialized = true);
        _controller.play();
      }
    });
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    if (!kIsWeb && _initialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(widget.filePath.split('/').last, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ),
      body: Center(
        child: _initialized
            ? AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller))
            : const CircularProgressIndicator(color: AppColors.primary),
      ),
      bottomNavigationBar: _initialized
          ? Container(
              color: Colors.black,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _controller.seekTo(_controller.value.position - const Duration(seconds: 10)),
                    child: const Icon(Icons.replay_10, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      } else {
                        _controller.play();
                      }
                      setState(() {});
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                      child: Icon(
                        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () => _controller.seekTo(_controller.value.position + const Duration(seconds: 10)),
                    child: const Icon(Icons.forward_10, color: Colors.white, size: 28),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

class _AudioDetailPlayer extends StatefulWidget {
  final String audioPath;
  const _AudioDetailPlayer({required this.audioPath});
  @override
  State<_AudioDetailPlayer> createState() => _AudioDetailPlayerState();
}

class _AudioDetailPlayerState extends State<_AudioDetailPlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    try {
      if (_playing) {
        await _player.pause();
        setState(() => _playing = false);
      } else {
        await _player.play(DeviceFileSource(widget.audioPath));
        setState(() => _playing = true);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlay,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.warningBg,
          borderRadius: BorderRadius.circular(AppDimensions.r8),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _playing ? AppColors.warning : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(_playing ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              _playing ? 'Playing...' : 'Play audio note',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _playing ? AppColors.warning : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayPauseButton extends StatefulWidget {
  final String audioPath;
  const _PlayPauseButton({required this.audioPath});

  @override
  State<_PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<_PlayPauseButton> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    try {
      if (_playing) {
        await _player.pause();
        setState(() => _playing = false);
      } else {
        await _player.play(DeviceFileSource(widget.audioPath));
        setState(() => _playing = true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not play audio'), backgroundColor: AppColors.danger));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlay,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: _playing ? AppColors.warning : AppColors.primary, shape: BoxShape.circle),
        child: Icon(_playing ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 20),
      ),
    );
  }
}
