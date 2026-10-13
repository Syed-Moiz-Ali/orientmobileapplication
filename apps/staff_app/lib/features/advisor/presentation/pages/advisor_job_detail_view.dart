import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/inspection_pages/presentation/vehicle_map/vehicle_body_condition_panel.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_assign_tasks_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/choose_inspection_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/inspection_provider.dart';
import 'package:staff_app/features/advisor/presentation/pages/repair_order_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/vehicle_delivery_view.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_status.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Job workspace hub: identity header, contextual primary action, then the
/// work / inspection / estimate / history sections. Every action targets the
/// same routes as before; failed loads surface an error with retry.
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
  InspectionSummaryResponse? _inspection;
  bool _hasLocalSubmittedInspection = false;
  bool _detailsError = false;

  String get _detailLookupId => _jc.dbId > 0 ? '${_jc.dbId}' : _jc.id;
  String get _jobCardRef =>
      _details?.id.isNotEmpty == true ? _details!.id : _jc.id;
  bool get _hasCompletedInspection =>
      (_inspection?.found == true && _inspection!.total > 0) ||
      _hasLocalSubmittedInspection;
  bool get _inspectionRequired =>
      !_hasCompletedInspection &&
      _jc.status != JobCardStatus.completed &&
      _jc.status != JobCardStatus.qualityCheckPassed &&
      _jc.status != JobCardStatus.delivered;

  @override
  void initState() {
    super.initState();
    _jc = widget.jc;
    _assignedTech = _jc.technician;
    _loadHiveData();
    _loadDetails();
    _loadInspection();
  }

  Future<void> _loadInspection() async {
    final id = _jc.dbId > 0 ? '${_jc.dbId}' : _detailLookupId;
    if (!RegExp(r'^\d+$').hasMatch(id)) return;
    try {
      final summary = await ref
          .read(advisorRemoteDataSourceProvider)
          .getInspectionByJobCard(id);
      if (!mounted) return;
      setState(() => _inspection = summary);
    } catch (_) {}
  }

  Future<void> _loadDetails() async {
    try {
      final details = await ref
          .read(advisorRemoteDataSourceProvider)
          .getJobCard(_detailLookupId);
      if (!mounted) return;
      setState(() {
        _details = details;
        _detailsError = false;
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
          odometer: details.odometer ?? _jc.odometer,
          fuelLevel: details.fuelLevel.isNotEmpty
              ? details.fuelLevel
              : _jc.fuelLevel,
          status: JobCardStatus.values.firstWhere(
            (status) => status.name == details.status,
            orElse: () => _jc.status,
          ),
        );
      });
    } catch (_) {
      if (mounted) setState(() => _detailsError = true);
    }
    await _loadInspection();
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

      final jobIds = <String>{
        _jc.id,
        _detailLookupId,
        if (_jc.dbId > 0) '${_jc.dbId}',
        if ((_hiveData?['jobCardRef'] ?? '').toString().isNotEmpty)
          _hiveData!['jobCardRef'].toString(),
        if ((_hiveData?['serverJobCardId'] ?? '').toString().isNotEmpty)
          _hiveData!['serverJobCardId'].toString(),
      };
      _hasLocalSubmittedInspection = allData.any((record) {
        final statuses = record['statuses'];
        return jobIds.contains(record['jobCardId']?.toString() ?? '') &&
            statuses is Map &&
            statuses.isNotEmpty;
      });

      if (_hiveData != null && mounted) {
        setState(() {
          _assignedTech = _hiveData!['technician'] as String? ?? _assignedTech;
        });
      }
    } catch (_) {}
  }

  String _getVal(String key) => _hiveData?[key] as String? ?? '';

  String _apiVal(String value, String fallback) =>
      value.isNotEmpty ? value : fallback;

  String get _displayPhone =>
      _apiVal(_details?.phoneNumber ?? '', _getVal('phoneNumber'));

  String get _displayEmail => _apiVal(_details?.email ?? '', _getVal('email'));

  String get _displayPlate {
    final fromApi = _details?.registrationNumber ?? '';
    if (fromApi.isNotEmpty) return fromApi;
    final fromHive = _getVal('registrationNumber');
    if (fromHive.isNotEmpty) return fromHive;
    return '';
  }

  String get _displayOdometer {
    final fromApi = _details?.odometer;
    if (fromApi != null && fromApi > 0) return '$fromApi';
    if (_jc.odometer != null && _jc.odometer! > 0) return '${_jc.odometer}';
    return _getVal('odometerReading');
  }

  String get _displayFuelLevel {
    final fromApi = _details?.fuelLevel ?? '';
    if (fromApi.isNotEmpty) return fromApi;
    if (_jc.fuelLevel.isNotEmpty) return _jc.fuelLevel;
    return _getVal('fuelLevel');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = StaffLocalizations.of(context)!;
    final hasData = _hiveData != null;
    final localBody = _hiveData?['vehicleBodyCondition'];
    final Map<String, dynamic>? bodyCondition =
        _details?.vehicleBodyCondition ??
        (localBody is Map ? Map<String, dynamic>.from(localBody) : null);

    final sections = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _customerSection(t, hasData),
        const SizedBox(height: AppDimensions.s16),
        _vehicleSection(t, hasData),
        if (hasData || (_inspection?.found ?? false)) ...[
          const SizedBox(height: AppDimensions.s16),
          _inspectionSection(t),
        ],
        if (_hasCompletedInspection) ...[
          const SizedBox(height: AppDimensions.s16),
          _workItemsSection(t),
        ],
        const SizedBox(height: AppDimensions.s16),
        _fuelSection(t),
        if (bodyCondition != null) ...[
          const SizedBox(height: AppDimensions.s16),
          _bodyConditionSection(t, bodyCondition),
        ],
        const SizedBox(height: AppDimensions.s16),
        _serviceSection(t),
        if ((_details?.customerRequests ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: AppDimensions.s16),
          _requestsSection(t),
        ],
      ],
    );

    final rail = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _identityHeader(t, hasData),
        const SizedBox(height: AppDimensions.s16),
        _nextStepSection(t),
        const SizedBox(height: AppDimensions.s16),
        _actionsSection(t),
      ],
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppTopBar(title: t.advisorJobDetailsTitle),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadHiveData();
          await _loadDetails();
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1024;
            final content = wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: sections),
                      const SizedBox(width: AppDimensions.s24),
                      SizedBox(width: 380, child: rail),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      rail,
                      const SizedBox(height: AppDimensions.s16),
                      sections,
                    ],
                  );

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                context.pagePadding.left,
                AppDimensions.s16,
                context.pagePadding.right,
                (AppDimensions.s64 + AppDimensions.s24),
              ),
              children: [
                if (_detailsError && _details == null) ...[
                  AppInfoPanel.danger(
                    message: t.advisorJobDetailLoadError,
                    action: TextButton(
                      onPressed: _loadDetails,
                      child: Text(t.advisorActionRefreshJobCard),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.s16),
                ],
                content,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _identityHeader(StaffLocalizations t, bool hasData) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _jc.id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.mono(color: colors.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _apiVal(
                        _details?.vehicleInfo ?? '',
                        hasData
                            ? '${_getVal('make')} ${_getVal('model')}'.trim()
                            : _jc.vehicleInfo,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              advisorStatusPill(t, _jc.status),
            ],
          ),
          const SizedBox(height: AppDimensions.s16),
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: AppDimensions.iconMd,
                color: colors.primary,
              ),
              const SizedBox(width: AppDimensions.s8),
              Expanded(
                child: Text(
                  _apiVal(
                    _details?.customerName ?? '',
                    hasData ? _getVal('customerName') : _jc.customerName,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_displayPlate.isNotEmpty) ...[
                const SizedBox(width: AppDimensions.s8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.s10,
                    vertical: AppDimensions.s4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusControl,
                    ),
                  ),
                  child: Text(
                    _displayPlate.toUpperCase(),
                    style: AppTextStyles.mono(color: colors.onSurface),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _nextStepSection(StaffLocalizations t) {
    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: t.advisorSectionNextStep,
            subtitle: _inspectionRequired
                ? t.advisorNextStepInspectionHint
                : t.advisorNextStepContinueHint,
            leadingIcon: Icons.bolt_rounded,
            padding: const EdgeInsets.only(bottom: AppDimensions.s12),
          ),
          PrimaryButton(
            label: _primaryActionLabel(t),
            icon: _primaryActionIcon,
            onPressed: _runPrimaryAction,
          ),
        ],
      ),
    );
  }

  Widget _actionsSection(StaffLocalizations t) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SecondaryButton(
          label: t.advisorActionCallCustomer,
          leadingIcon: Icons.phone_outlined,
          onPressed: _callCustomer,
        ),
        if (_jc.status == JobCardStatus.completed) ...[
          const SizedBox(height: AppDimensions.s10),
          PrimaryButton(
            label: t.advisorActionDeliverVehicle,
            icon: Icons.check_circle_outline,
            onPressed: _openDelivery,
          ),
        ],
        const SizedBox(height: AppDimensions.s10),
        SecondaryButton(
          label: t.advisorActionRefreshJobCard,
          leadingIcon: Icons.refresh_rounded,
          onPressed: () {
            _loadHiveData();
            _loadDetails();
          },
          foregroundColor: colors.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _section(
    StaffLocalizations t,
    String title,
    IconData icon,
    List<Widget> children, {
    String? subtitle,
  }) {
    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: title,
            subtitle: subtitle,
            leadingIcon: icon,
            padding: const EdgeInsets.only(bottom: AppDimensions.s12),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _customerSection(StaffLocalizations t, bool hasData) => _section(
    t,
    t.advisorSectionCustomerDetails,
    Icons.person_outline_rounded,
    [
      _detailRow(
        Icons.person_outline_rounded,
        t.advisorFieldName,
        _apiVal(
          _details?.customerName ?? '',
          hasData ? _getVal('customerName') : _jc.customerName,
        ),
      ),
      _detailRow(
        Icons.phone_outlined,
        t.advisorFieldPhone,
        _displayPhone.isEmpty ? '--' : _displayPhone,
      ),
      _detailRow(
        Icons.email_outlined,
        t.advisorFieldEmail,
        _displayEmail.isEmpty ? '--' : _displayEmail,
      ),
      if (_apiVal(
        _details?.customerGroup ?? '',
        _getVal('customerGroup'),
      ).isNotEmpty)
        _detailRow(
          Icons.group_outlined,
          t.advisorFieldGroup,
          _apiVal(_details?.customerGroup ?? '', _getVal('customerGroup')),
        ),
    ],
  );

  Widget _vehicleSection(StaffLocalizations t, bool hasData) => _section(
    t,
    t.advisorSectionVehicleDetails,
    Icons.directions_car_outlined,
    [
      _detailRow(
        Icons.directions_car_outlined,
        t.advisorFieldVehicle,
        _apiVal(
          _details?.vehicleInfo ?? '',
          hasData ? '${_getVal('make')} ${_getVal('model')}' : _jc.vehicleInfo,
        ),
      ),
      _detailRow(
        Icons.confirmation_number_outlined,
        t.advisorFieldPlate,
        (_displayPlate.isEmpty ? '--' : _displayPlate).toUpperCase(),
        isMono: true,
      ),
      _detailRow(
        Icons.qr_code_rounded,
        t.advisorFieldVin,
        _apiVal(_details?.vin ?? '', _getVal('vin')),
        isMono: true,
      ),
      if (_apiVal(_details?.modelYear ?? '', _getVal('modelYear')).isNotEmpty)
        _detailRow(
          Icons.calendar_today,
          t.advisorFieldYear,
          _apiVal(_details?.modelYear ?? '', _getVal('modelYear')),
        ),
      if (_apiVal(
        _details?.vehicleColor ?? '',
        _getVal('vehicleColor'),
      ).isNotEmpty)
        _detailRow(
          Icons.color_lens_outlined,
          t.advisorFieldColor,
          _apiVal(_details?.vehicleColor ?? '', _getVal('vehicleColor')),
        ),
      _detailRow(
        Icons.speed_rounded,
        t.advisorFieldOdometer,
        _displayOdometer.isEmpty
            ? '--'
            : t.advisorOdometerValue(_displayOdometer),
        isMono: true,
      ),
    ],
  );

  Widget _fuelSection(StaffLocalizations t) => _section(
    t,
    t.advisorSectionFuelLevel,
    Icons.local_gas_station_outlined,
    [_buildFuelLevelDisplay(t)],
  );

  Widget _bodyConditionSection(
    StaffLocalizations t,
    Map<String, dynamic> bodyCondition,
  ) => _section(
    t,
    t.advisorSectionBodyCondition,
    Icons.car_crash_outlined,
    [
      VehicleBodyConditionPanel(
        readOnly: true,
        embedded: true,
        showTitle: false,
        bodyCondition: bodyCondition,
      ),
    ],
    subtitle: t.advisorBodyConditionHint,
  );

  Widget _serviceSection(StaffLocalizations t) =>
      _section(t, t.advisorSectionServiceInformation, Icons.build_outlined, [
        _detailRow(
          Icons.build_outlined,
          t.advisorFieldServiceType,
          t.advisorServiceTypeInspection,
        ),
        _detailRow(
          Icons.person_outline,
          t.advisorFieldAdvisor,
          t.advisorAdvisorAssigned,
        ),
        if (_assignedTech.isNotEmpty)
          _detailRow(
            Icons.engineering_outlined,
            t.advisorFieldTechnician,
            _assignedTech,
          ),
        _detailRow(
          Icons.schedule_outlined,
          t.advisorFieldCreated,
          _jc.createdDate.isNotEmpty ? _jc.createdDate : _jc.time,
          isMono: true,
        ),
        _detailRow(
          Icons.update_rounded,
          t.advisorFieldLastUpdated,
          _jc.lastUpdated.isNotEmpty ? _jc.lastUpdated : _jc.time,
          isMono: true,
        ),
      ]);

  Widget _requestsSection(StaffLocalizations t) => _section(
    t,
    t.advisorSectionCustomerRequests,
    Icons.chat_bubble_outline_rounded,
    [
      AppMarkdownText(
        _details!.customerRequests.trim(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.45),
      ),
    ],
  );

  Widget _inspectionSection(StaffLocalizations t) {
    final inspection = _inspection;
    if (inspection == null || !inspection.found) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;
    return _section(
      t,
      t.advisorSectionInspectionSummary,
      Icons.fact_check_outlined,
      [
        if (inspection.inspectionRef.isNotEmpty)
          _detailRow(
            Icons.fact_check_outlined,
            t.advisorFieldReference,
            inspection.inspectionRef,
            isMono: true,
          ),
        Row(
          children: [
            Expanded(
              child: _inspectionCount(
                t.advisorInspectionGood,
                inspection.good,
                AppColors.success,
                Icons.check_circle_outline_rounded,
              ),
            ),
            const SizedBox(width: AppDimensions.s8),
            Expanded(
              child: _inspectionCount(
                t.advisorInspectionFair,
                inspection.fair,
                AppColors.warning,
                Icons.error_outline_rounded,
              ),
            ),
            const SizedBox(width: AppDimensions.s8),
            Expanded(
              child: _inspectionCount(
                t.advisorInspectionPoor,
                inspection.poor,
                colors.error,
                Icons.warning_amber_rounded,
              ),
            ),
          ],
        ),
        if (inspection.summary.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.s8),
          Text(
            inspection.summary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _workItemsSection(StaffLocalizations t) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    ref.watch(advisorWorkItemsRefreshProvider);
    final items =
        ref.watch(advisorWorkItemsProvider(_jobCardRef)).value ??
        const <WorkItemResponse>[];
    if (items.isEmpty) return const SizedBox.shrink();
    final done = items.where((i) => i.status == 'completed').length;

    return _section(
      t,
      t.advisorSectionWorkItems,
      Icons.handyman_outlined,
      [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.s4),
            child: Row(
              children: [
                Icon(
                  item.status == 'completed'
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: item.status == 'completed'
                      ? AppColors.success
                      : colors.onSurfaceVariant,
                  size: AppDimensions.iconSm,
                ),
                const SizedBox(width: AppDimensions.s8),
                Expanded(
                  child: Text(
                    item.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: item.status == 'completed'
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
      subtitle:
          '${t.advisorWorkItemsHint} · ${t.advisorWorkItemsProgress(done, items.length)}',
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value, {
    bool isMono = false,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.s10),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppDimensions.iconSm,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: AppDimensions.s10),
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.s10),
          Expanded(
            child: Text(
              value.isEmpty ? '--' : value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: isMono
                  ? AppTextStyles.mono(color: colors.onSurface)
                  : theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelLevelDisplay(StaffLocalizations t) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final fuelLevelValue = _displayFuelLevel;
    final numericFuel = int.tryParse(fuelLevelValue);
    final fuelLevel =
        numericFuel ??
        switch (fuelLevelValue) {
          '1/4' => 3,
          '1/2' => 5,
          '3/4' => 8,
          'Full' => 10,
          _ => 5,
        };
    final fuelLabel = fuelLevelValue.isNotEmpty
        ? fuelLevelValue
        : '$fuelLevel/10';

    return Row(
      children: [
        Icon(
          Icons.local_gas_station_rounded,
          size: AppDimensions.iconSm,
          color: colors.primary,
        ),
        const SizedBox(width: AppDimensions.s10),
        Text(
          t.advisorFieldGaugeLevel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppDimensions.s12),
        Expanded(child: AppLinearProgress(value: fuelLevel / 10, height: 8)),
        const SizedBox(width: AppDimensions.s8),
        Text(fuelLabel, style: AppTextStyles.mono(color: colors.onSurface)),
      ],
    );
  }

  Widget _inspectionCount(
    String label,
    int count,
    Color color,
    IconData icon,
  ) => Container(
    padding: const EdgeInsets.symmetric(vertical: AppDimensions.s10),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
    ),
    child: Column(
      children: [
        Icon(icon, size: AppDimensions.iconMd, color: color),
        const SizedBox(height: 3),
        Text('$count', style: AppTextStyles.bodyStrong(color: color)),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );

  String _primaryActionLabel(StaffLocalizations t) => _inspectionRequired
      ? t.advisorActionAddInspection
      : switch (_jc.status) {
          JobCardStatus.vehicleReceived => t.advisorActionStartInspection,
          JobCardStatus.inspected => t.advisorActionCreateEstimate,
          JobCardStatus.waitingCustomerApproval =>
            t.advisorActionWaitingApproval,
          JobCardStatus.approved => t.advisorActionAssignTechnician,
          JobCardStatus.workAssigned ||
          JobCardStatus.inProgress ||
          JobCardStatus.waitingParts => t.advisorActionReviewWorkItems,
          JobCardStatus.completed ||
          JobCardStatus.qualityCheckPassed => t.advisorActionDeliverVehicle,
          JobCardStatus.delivered => t.advisorStatusDelivered,
          _ => t.advisorActionRefreshJobCard,
        };

  IconData get _primaryActionIcon => _inspectionRequired
      ? Icons.fact_check_outlined
      : switch (_jc.status) {
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
    if (_inspectionRequired) {
      _startInspection();
      return;
    }
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
          SnackBar(
            content: Text(
              StaffLocalizations.of(context)!.advisorVehicleAlreadyDelivered,
            ),
          ),
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
    ).then((_) async {
      _loadHiveData();
      await _loadDetails();
    });
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

  void _callCustomer() {
    final phone = _displayPhone.replaceAll(RegExp(r'[^\d+]'), '');
    if (phone.isNotEmpty) {
      HapticFeedback.lightImpact();
      launchUrl(Uri.parse('tel:$phone'));
    }
  }
}
