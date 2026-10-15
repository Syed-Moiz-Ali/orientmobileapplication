import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_models/shared_models.dart' as models;
import 'package:url_launcher/url_launcher.dart';

import 'package:staff_app/core/local/sync_providers.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/pending_approval_entity.dart';
import 'package:staff_app/features/advisor/inspection_pages/presentation/vehicle_map/vehicle_body_condition_panel.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_assign_tasks_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/choose_inspection_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/inspection_provider.dart';
import 'package:staff_app/features/advisor/presentation/pages/repair_order_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/vehicle_delivery_view.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_approval_sheet.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_menu_item.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_sheet.dart';
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
    final pendingSync =
        ref.watch(advisorPendingSyncCountProvider).value ?? 0;
    final hasData = _hiveData != null;
    final localBody = _hiveData?['vehicleBodyCondition'];
    final Map<String, dynamic>? bodyCondition =
        _details?.vehicleBodyCondition ??
        (localBody is Map ? Map<String, dynamic>.from(localBody) : null);
    final approvals =
        ref.watch(advisorPendingApprovalsProvider).valueOrNull ??
        const <PendingApprovalEntity>[];
    ref.watch(advisorWorkItemsRefreshProvider);
    final workItems =
        ref.watch(advisorWorkItemsProvider(_jobCardRef)).value ??
        const <WorkItemResponse>[];
    final customerName = _apiVal(
      _details?.customerName ?? '',
      hasData ? _getVal('customerName') : _jc.customerName,
    );
    final jobEstimates = approvals
        .where((a) => a.customerName == customerName)
        .toList();

    // Dossier (60%) + actions/history rail (40%) on expanded viewports;
    // single-column stream with a sticky bottom dock below that.
    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );

    final dossier = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _identityHeader(t, hasData),
        const SizedBox(height: AppDimensions.s16),
        _stagesSection(t),
        const SizedBox(height: AppDimensions.s16),
        _checklistSection(t, bodyCondition, workItems),
        const SizedBox(height: AppDimensions.s16),
        _estimatesSection(t, jobEstimates),
        const SizedBox(height: AppDimensions.s16),
        _invoicesSection(t),
        const SizedBox(height: AppDimensions.s16),
        _notesSection(t),
      ],
    );

    final rail = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _nextStepSection(t),
        const SizedBox(height: AppDimensions.s16),
        _overflowSection(t),
        const SizedBox(height: AppDimensions.s16),
        _activitySection(t),
      ],
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: WorkspaceAppBar(
        title: t.advisorJobDetailsTitle,
        showBack: true,
        onBack: () => Navigator.maybePop(context),
        frosted: !context.isCompact,
        showOfflineStatus: true,
        offlinePendingCount: pendingSync,
      ),
      bottomNavigationBar: wide ? null : _DockBar(
        primaryLabel: _primaryActionLabel(t),
        primaryIcon: _primaryActionIcon,
        onPrimary: _runPrimaryAction,
        onMore: () => _showOverflow(t),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadHiveData();
          await _loadDetails();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            context.pagePadding.left,
            AppDimensions.s16,
            context.pagePadding.right,
            (wide ? AppDimensions.s24 : AppDimensions.s64 + AppDimensions.s24),
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
            AppPageHeader(
              breadcrumbs: [
                AppBreadcrumbItem(
                  label: t.advisorNavJobs,
                  onTap: () => Navigator.maybePop(context),
                ),
                AppBreadcrumbItem.current(_jc.id),
              ],
              title: customerName,
              subtitle: _apiVal(
                _details?.vehicleInfo ?? '',
                hasData
                    ? '${_getVal('make')} ${_getVal('model')}'.trim()
                    : _jc.vehicleInfo,
              ),
              trailing: advisorStatusPill(t, _jc.status),
            ),
            const SizedBox(height: AppDimensions.s20),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: dossier),
                  const SizedBox(width: AppDimensions.s24),
                  Expanded(flex: 2, child: rail),
                ],
              )
            else
              dossier,
          ],
        ),
      ),
    );
  }

  /// Lifecycle position for the six-stage dossier stepper
  /// (Intake → Inspection → Estimate → Repair → QC → Ready).
  int _stageIndex(JobCardStatus status) => switch (status) {
    JobCardStatus.vehicleReceived || JobCardStatus.pending => 0,
    JobCardStatus.inspected => 1,
    JobCardStatus.waitingCustomerApproval ||
    JobCardStatus.pendingApproval ||
    JobCardStatus.awaitingSupervisor ||
    JobCardStatus.approved => 2,
    JobCardStatus.workAssigned ||
    JobCardStatus.inProgress ||
    JobCardStatus.waitingParts => 3,
    JobCardStatus.qualityCheck || JobCardStatus.qualityCheckPassed => 4,
    JobCardStatus.completed || JobCardStatus.delivered => 5,
    // Cancelled leaves the forward path; the neutral status pill carries
    // the terminal state while the stepper rests at the start.
    JobCardStatus.cancelled => 0,
  };

  Widget _identityHeader(StaffLocalizations t, bool hasData) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final vehicle = _apiVal(
      _details?.vehicleInfo ?? '',
      hasData ? '${_getVal('make')} ${_getVal('model')}'.trim() : _jc.vehicleInfo,
    );
    final customer = _apiVal(
      _details?.customerName ?? '',
      hasData ? _getVal('customerName') : _jc.customerName,
    );
    final vin = _apiVal(_details?.vin ?? '', _getVal('vin'));
    final odo = _displayOdometer;

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
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        _jc.id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.mono(color: colors.onSurface),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vehicle,
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
                  customer,
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
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      _displayPlate.toUpperCase(),
                      style: AppTextStyles.mono(color: colors.onSurface),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (vin.isNotEmpty || odo.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s10),
            Wrap(
              spacing: AppDimensions.s16,
              runSpacing: AppDimensions.s4,
              children: [
                if (vin.isNotEmpty)
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      'VIN $vin',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.mono(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                if (odo.isNotEmpty)
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      t.advisorOdometerValue(odo),
                      style: AppTextStyles.mono(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (_displayPhone.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s14),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: t.advisorContactCall,
                    leadingIcon: Icons.phone_outlined,
                    onPressed: _callCustomer,
                  ),
                ),
                const SizedBox(width: AppDimensions.s10),
                Expanded(
                  child: SecondaryButton(
                    label: t.advisorContactWhatsApp,
                    leadingIcon: Icons.chat_outlined,
                    onPressed: _openWhatsApp,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s6),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                _displayPhone,
                style: AppTextStyles.mono(color: colors.onSurfaceVariant),
              ),
            ),
          ],
          if (_displayEmail.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s6),
            Text(
              _displayEmail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
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

  /// Secondary actions live behind a single overflow entry so the dossier
  /// keeps exactly one contextual primary (in the rail card or bottom dock).
  Widget _overflowSection(StaffLocalizations t) {
    return SecondaryButton(
      label: t.advisorActionMore,
      leadingIcon: Icons.more_horiz_rounded,
      onPressed: () => _showOverflow(t),
    );
  }

  void _showOverflow(StaffLocalizations t) {
    final colors = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => AdvisorSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_displayPhone.isNotEmpty) ...[
              AdvisorMenuItem(
                icon: Icons.phone_outlined,
                label: t.advisorActionCallCustomer,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _callCustomer();
                },
              ),
              AdvisorMenuItem(
                icon: Icons.chat_outlined,
                label: t.advisorContactWhatsApp,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openWhatsApp();
                },
              ),
            ],
            if (_jc.status == JobCardStatus.completed)
              AdvisorMenuItem(
                icon: Icons.check_circle_outline,
                label: t.advisorActionDeliverVehicle,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openDelivery();
                },
              ),
            AdvisorMenuItem(
              icon: Icons.refresh_rounded,
              label: t.advisorActionRefreshJobCard,
              onTap: () {
                Navigator.pop(sheetContext);
                _loadHiveData();
                _loadDetails();
              },
            ),
            const SizedBox(height: AppDimensions.s8),
            TextButton(
              onPressed: () => Navigator.pop(sheetContext),
              style: TextButton.styleFrom(
                foregroundColor: colors.onSurfaceVariant,
                minimumSize: const Size(0, AppDimensions.touchTarget),
              ),
              child: Text(t.advisorActionClose),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activitySection(StaffLocalizations t) => _section(
    t,
    t.advisorSectionActivity,
    Icons.history_rounded,
    [
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
      if (_assignedTech.isNotEmpty)
        _detailRow(
          Icons.engineering_outlined,
          t.advisorFieldTechnician,
          _assignedTech,
        ),
    ],
  );

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

  /// Dossier section 1 — Stages: the six-step lifecycle stepper driven by the
  /// live job status. Existing status data only; nothing is invented.
  Widget _stagesSection(StaffLocalizations t) => _section(
    t,
    t.advisorSectionStages,
    Icons.route_outlined,
    [
      // Six lifecycle nodes need ~560px; the fixed-width rail scrolls on
      // compact viewports and reads whole on wide ones. The bound keeps
      // AppStepper's expanded connectors well-defined everywhere.
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 560,
          child: AppStepper(
            steps: [
              t.advisorStageIntake,
              t.advisorStageInspection,
              t.advisorStageEstimate,
              t.advisorStageRepair,
              t.advisorStageQc,
              t.advisorStageReady,
            ],
            currentIndex: _stageIndex(_jc.status),
          ),
        ),
      ),
    ],
    subtitle: _inspectionRequired
        ? t.advisorNextStepInspectionHint
        : t.advisorNextStepContinueHint,
  );

  /// Dossier section 2 — Checklist: inspection outcome, body condition,
  /// work items and the fuel gauge. Only recorded data renders; an empty
  /// checklist is an explicit empty state, never blank space.
  Widget _checklistSection(
    StaffLocalizations t,
    Map<String, dynamic>? bodyCondition,
    List<WorkItemResponse> workItems,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final inspection = _inspection;
    final hasInspection = inspection != null && inspection.found;
    final fuelKnown = _displayFuelLevel.isNotEmpty;
    final hasContent =
        hasInspection ||
        bodyCondition != null ||
        workItems.isNotEmpty ||
        fuelKnown;

    if (!hasContent) {
      return _section(t, t.advisorSectionChecklist, Icons.fact_check_outlined, [
        EmptyState(
          icon: Icons.fact_check_outlined,
          message: t.advisorEmptyChecklist,
        ),
      ]);
    }

    final done = workItems.where((i) => i.status == 'completed').length;
    return _section(
      t,
      t.advisorSectionChecklist,
      Icons.fact_check_outlined,
      [
        if (hasInspection) ...[
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
                  semantic.success.base,
                  Icons.check_circle_outline_rounded,
                ),
              ),
              const SizedBox(width: AppDimensions.s8),
              Expanded(
                child: _inspectionCount(
                  t.advisorInspectionFair,
                  inspection.fair,
                  semantic.warning.base,
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
          const SizedBox(height: AppDimensions.s12),
        ],
        if (bodyCondition != null) ...[
          VehicleBodyConditionPanel(
            readOnly: true,
            embedded: true,
            showTitle: false,
            bodyCondition: bodyCondition,
          ),
          const SizedBox(height: AppDimensions.s12),
        ],
        if (workItems.isNotEmpty) ...[
          for (final item in workItems)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.s4),
              child: Row(
                children: [
                  Icon(
                    item.status == 'completed'
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: item.status == 'completed'
                        ? semantic.success.base
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
          const SizedBox(height: AppDimensions.s4),
          Text(
            t.advisorWorkItemsProgress(done, workItems.length),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.s12),
        ],
        if (fuelKnown) _buildFuelLevelDisplay(t),
      ],
      subtitle: workItems.isNotEmpty
          ? '${t.advisorWorkItemsHint} · ${t.advisorWorkItemsProgress(done, workItems.length)}'
          : null,
    );
  }

  /// Dossier section 3 — Estimates: pending approvals recorded for this
  /// job's customer (same approve/reject persistence as the home radar).
  /// No approvals on record renders an explicit empty state.
  Widget _estimatesSection(
    StaffLocalizations t,
    List<PendingApprovalEntity> jobEstimates,
  ) {
    if (jobEstimates.isEmpty) {
      return _section(t, t.advisorSectionEstimates, Icons.receipt_long_outlined, [
        EmptyState(
          icon: Icons.receipt_long_outlined,
          message: t.advisorEmptyEstimates,
        ),
      ]);
    }
    final money = AppFormatters.of(context);
    return _section(
      t,
      t.advisorSectionEstimates,
      Icons.receipt_long_outlined,
      [
        for (final pa in jobEstimates)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.s8),
            child: AppRecordRow(
              status: StatusPill.warning(
                advisorApprovalTypeLabel(t, pa.approvalType),
              ),
              title: pa.estimateId,
              subtitle: pa.vehicleId,
              metadata: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  money.moneyAED(pa.amount),
                  style: AppTextStyles.mono(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              onTap: () => _onEstimate(pa),
            ),
          ),
      ],
    );
  }

  /// Dossier section 4 — Invoices. No invoice source exists in the advisor
  /// scope, so the section honestly reports its empty state.
  Widget _invoicesSection(StaffLocalizations t) =>
      _section(t, t.advisorSectionInvoices, Icons.request_quote_outlined, [
        EmptyState(
          icon: Icons.request_quote_outlined,
          message: t.advisorEmptyInvoices,
        ),
      ]);

  /// Dossier section 5 — Notes: recorded customer requests, or an explicit
  /// empty state when none were captured.
  Widget _notesSection(StaffLocalizations t) {
    final requests = (_details?.customerRequests ?? '').trim();
    return _section(t, t.advisorSectionNotes, Icons.chat_bubble_outline_rounded, [
      if (requests.isEmpty)
        EmptyState(
          icon: Icons.chat_bubble_outline_rounded,
          message: t.advisorEmptyNotes,
        )
      else
        AppMarkdownText(
          requests,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.45),
        ),
    ]);
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
            child: isMono
                ? Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      value.isEmpty ? '--' : value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: AppTextStyles.mono(color: colors.onSurface),
                    ),
                  )
                : Text(
                    value.isEmpty ? '--' : value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodySmall?.copyWith(
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
    // Phase 07.1: canonical phone normalization from the shared PhoneNumber
    // value object (same digits as the old inline munging, plus a correct
    // country-code prefix for local-format numbers — never rendered text).
    final digits = models.PhoneNumber.normalizeLoose(_displayPhone);
    if (digits.isNotEmpty) {
      HapticFeedback.lightImpact();
      launchUrl(Uri.parse('tel:+$digits'));
    }
  }

  void _openWhatsApp() {
    // Mirrors the home radar's WhatsApp acknowledgement (same copy, same
    // success tone). No new deep-link behavior is introduced here.
    final t = StaffLocalizations.of(context)!;
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: context.semanticColors.success.base,
        behavior: SnackBarBehavior.floating,
        content: Text(t.advisorToastOpeningWhatsApp),
      ),
    );
  }

  void _onEstimate(PendingApprovalEntity pa) {
    final t = StaffLocalizations.of(context)!;
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => AdvisorApprovalSheet(
        pa: pa,
        onApprove: () {
          Navigator.pop(sheetContext);
          _persistApproval(pa, 'approve');
          _toast(
            t.advisorToastApproved(
              advisorApprovalTypeLabel(t, pa.approvalType),
              pa.estimateId,
            ),
            icon: Icons.check_circle_outline,
            color: context.semanticColors.success.base,
          );
        },
        onReject: () {
          Navigator.pop(sheetContext);
          _persistApproval(pa, 'reject');
          _toast(
            t.advisorToastRejected(
              advisorApprovalTypeLabel(t, pa.approvalType),
              pa.estimateId,
            ),
            icon: Icons.undo,
            color: Theme.of(context).colorScheme.primary,
          );
        },
      ),
    );
  }

  void _toast(String msg, {IconData? icon, Color? color}) {
    final ink = context.semanticColors.onPrimary;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: ink, size: AppDimensions.iconSm),
              const SizedBox(width: AppDimensions.s8),
            ],
            Expanded(
              child: Text(
                msg,
                style: TextStyle(color: ink, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor: color ?? Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _persistApproval(PendingApprovalEntity pa, String action) async {
    // Same approval persistence as the home radar (same Hive record, same
    // sync payload) — reused behavior, not a new contract.
    final local = GenericLocalDataSource(Hive.box<dynamic>('inspections'));
    await local.save('approval_${pa.estimateId}', {
      'estimateId': pa.estimateId,
      'customerName': pa.customerName,
      'amount': pa.amount,
      'action': action,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    final queue = ref.read(syncQueueProvider);
    final id = await IdGenerator.nextId('APPR');
    await queue.enqueue(
      SyncOperation(
        id: id,
        entityType: 'approval',
        entityId: pa.estimateId,
        changeType: ChangeType.update,
        payload: {
          'estimateId': pa.estimateId,
          'action': action,
          'customerName': pa.customerName,
          'amount': pa.amount,
        },
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    await ref.read(syncEngineProvider).syncAll();
  }
}

/// Sticky bottom dock for compact/medium viewports: exactly one contextual
/// primary plus a secondary overflow entry. Wide viewports use the rail.
class _DockBar extends StatelessWidget {
  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback onPrimary;
  final VoidCallback onMore;

  const _DockBar({
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimary,
    required this.onMore,
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
          AppDimensions.s12,
        ),
        child: Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: primaryLabel,
                icon: primaryIcon,
                onPressed: onPrimary,
              ),
            ),
            const SizedBox(width: AppDimensions.s10),
            SecondaryButton(
              label: StaffLocalizations.of(context)!.advisorActionMore,
              leadingIcon: Icons.more_horiz_rounded,
              isExpanded: false,
              onPressed: onMore,
            ),
          ],
        ),
      ),
    );
  }
}
