import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Advisor vehicle check-in: a focused two-step wizard that records the
/// odometer, fuel level, notes and any existing damage before the job card is
/// handed to inspection.
///
/// Submit contract is unchanged (`checkInVehicleResult` + pushReplacement to
/// the advisor job detail with the same `JobCardEntity`).
class AdvisorVehicleCheckinView extends ConsumerStatefulWidget {
  final String bookingId;
  final String customerName;
  final String vehicleInfo;

  const AdvisorVehicleCheckinView({
    super.key,
    required this.bookingId,
    required this.customerName,
    required this.vehicleInfo,
  });

  @override
  ConsumerState<AdvisorVehicleCheckinView> createState() =>
      _AdvisorVehicleCheckinViewState();
}

class _AdvisorVehicleCheckinViewState
    extends ConsumerState<AdvisorVehicleCheckinView> {
  int _step = 0;
  final _odometerCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _fuelLevel = '1/4';
  final List<String> _damages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _odometerCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _addDamage(String area) {
    final t = StaffLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: Text(t.advisorCheckInDamageTitle(area)),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            decoration: InputDecoration(hintText: t.advisorCheckInDamageHint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(SharedCoreL10n.of(context).commonCancel),
            ),
            FilledButton(
              onPressed: () {
                if (ctrl.text.trim().isNotEmpty) {
                  setState(() => _damages.add('$area: ${ctrl.text.trim()}'));
                }
                Navigator.pop(context);
              },
              child: Text(t.advisorCheckInAdd),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    final t = StaffLocalizations.of(context)!;
    setState(() => _isLoading = true);
    try {
      final remote = ref.read(advisorRemoteDataSourceProvider);
      final odo = int.tryParse(_odometerCtrl.text.trim()) ?? 0;
      final result = await remote.checkInVehicleResult(widget.bookingId, {
        'odometer': odo,
        'fuelLevel': _fuelLevel,
        'existingDamages': _damages.join(', '),
        'notes': _notesCtrl.text.trim(),
      });
      if (!mounted) return;
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.advisorCheckInSuccess)),
        );
        context.pushReplacement(
          AppRoutes.advisorJobDetail,
          extra: JobCardEntity(
            id: '${result.jobCardId}',
            dbId: result.jobCardId,
            customerName: widget.customerName,
            vehicleInfo: widget.vehicleInfo,
            time: '',
            createdDate: '',
            lastUpdated: '',
            status: JobCardStatus.vehicleReceived,
            odometer: odo,
            fuelLevel: _fuelLevel,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.advisorCheckInFailed)),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.advisorCheckInError('$e'))),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AppTopBar(
              title: t.advisorCheckInTitle,
              onBack: _step == 0
                  ? null
                  : () => setState(() => _step = 0),
            ),
            Expanded(
              child: AppPageFrame(
                scrollable: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppInfoPanel.primary(
                      icon: Icons.directions_car_outlined,
                      title: widget.customerName.isEmpty
                          ? widget.vehicleInfo
                          : widget.customerName,
                      message: widget.vehicleInfo,
                    ),
                    const SizedBox(height: AppDimensions.s20),
                    AppStepProgress(
                      currentStep: _step,
                      steps: [
                        AppProgressStep(
                          label: t.advisorCheckInStepDetails,
                          icon: Icons.speed_rounded,
                        ),
                        AppProgressStep(
                          label: t.advisorCheckInStepCondition,
                          icon: Icons.fact_check_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.s24),
                    if (_step == 0) _buildDetailsStep(t) else _buildDamageStep(t),
                  ],
                ),
              ),
            ),
            AppActionBar(
              sticky: true,
              isLoading: _isLoading,
              secondary: [
                if (_step == 1)
                  AppButton.secondary(
                    label: t.advisorCheckInBack,
                    leadingIcon: Icons.arrow_back_rounded,
                    isExpanded: context.adaptive.isCompact,
                    onPressed: () => setState(() => _step = 0),
                  ),
              ],
              primary: AppButton.primary(
                label: _step == 0
                    ? t.advisorCheckInNext
                    : t.advisorCheckInComplete,
                icon: _step == 0
                    ? Icons.arrow_forward_rounded
                    : Icons.check_rounded,
                isLoading: _isLoading,
                isExpanded: context.adaptive.isCompact,
                onPressed: _step == 0
                    ? () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        setState(() => _step = 1);
                      }
                    : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsStep(StaffLocalizations t) {
    return AppFormPanel(
      title: t.advisorCheckInSectionDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFormField(
            label: t.advisorCheckInOdometer,
            isRequired: true,
            child: AppTextField(
              controller: _odometerCtrl,
              hint: t.advisorCheckInOdometerHint,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              prefixIcon: Icons.speed_rounded,
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          AppFormField(
            label: t.advisorCheckInFuel,
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: '1/4', label: Text('1/4')),
                  ButtonSegment(value: '1/2', label: Text('1/2')),
                  ButtonSegment(value: '3/4', label: Text('3/4')),
                  ButtonSegment(value: 'Full', label: Text('Full')),
                ],
                selected: {_fuelLevel},
                showSelectedIcon: false,
                onSelectionChanged: (set) =>
                    setState(() => _fuelLevel = set.first),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          AppFormField(
            label: t.advisorCheckInNotes,
            isOptional: true,
            child: AppTextField(
              controller: _notesCtrl,
              hint: t.advisorCheckInNotesHint,
              maxLines: 3,
              minLines: 3,
              textInputAction: TextInputAction.newline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDamageStep(StaffLocalizations t) {
    final areas = <String>[
      t.advisorCheckInFront,
      t.advisorCheckInRear,
      t.advisorCheckInLeft,
      t.advisorCheckInRight,
      t.advisorCheckInRoof,
    ];
    return AppFormPanel(
      title: t.advisorCheckInSectionDamage,
      subtitle: t.advisorCheckInSectionDamageSub,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 520 ? 3 : 2;
              return GridView.count(
                shrinkWrap: true,
                crossAxisCount: columns,
                mainAxisSpacing: AppDimensions.s10,
                crossAxisSpacing: AppDimensions.s10,
                childAspectRatio: 2.6,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final area in areas)
                    OutlinedButton(
                      onPressed: () => _addDamage(area),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, AppDimensions.touchTarget),
                      ),
                      child: Text(
                        area,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppDimensions.s20),
          if (_damages.isEmpty)
            EmptyState(
              icon: Icons.verified_outlined,
              message: t.advisorCheckInEmptyDamages,
            )
          else ...[
            for (var i = 0; i < _damages.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.s8),
                child: AppCard.subtle(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.s14,
                    vertical: AppDimensions.s8,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.report_problem_outlined,
                        size: 18,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: AppDimensions.s10),
                      Expanded(
                        child: Text(
                          _damages[i],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      IconButton(
                        tooltip: t.advisorCheckInRemoveDamage,
                        onPressed: () => setState(() => _damages.removeAt(i)),
                        icon: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
