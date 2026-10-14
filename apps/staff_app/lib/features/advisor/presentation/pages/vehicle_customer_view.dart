import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/local/sync_providers.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:staff_app/core/platform/file_ops.dart';
import 'package:staff_app/core/services/audio_recorder_service.dart';
import 'inspection_provider.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/providers/vehicle_customer_provider.dart';
import 'package:staff_app/features/advisor/presentation/widgets/select_brand_sheet.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_signature_pad.dart';
import 'package:staff_app/features/advisor/data/models/vehicle_customer_model.dart';
import 'scan_vehicle_view.dart';
import 'package:staff_app/features/advisor/inspection_pages/presentation/vehicle_map/vehicle_body_condition_panel.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Local draft key inside the existing `inspections` Hive box. Drafts are
/// device-local snapshots of the unfinished wizard: they never enter the
/// sync queue — only the final submit enqueues a `SyncOperation`.
const _intakeDraftKey = 'intake_draft_v1';

/// Advisor vehicle/customer intake — an express 4-step wizard studio.
///
/// Deck: 1. Customer contact → 2. Vehicle & plate → 3. Photo capture →
/// 4. Scope & sign-off. Each step validates independently; the wizard
/// autosaves a local draft so an offline drop or interruption never loses
/// progress.
///
/// Route/extra contract (`/vehicle-customer`, extra `{bookingId}`) and the
/// Hive/sync payload are unchanged from the pre-redesign implementation.
class VehicleCustomerView extends ConsumerWidget {
  final String? bookingId;
  const VehicleCustomerView({super.key, this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _Body(bookingId: bookingId);
  }
}

class _Body extends ConsumerStatefulWidget {
  final String? bookingId;
  const _Body({this.bookingId});
  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  int _step = 0;
  final Map<String, GlobalKey> _fieldKeys = {
    'Customer Name': GlobalKey(),
    'Phone Number': GlobalKey(),
    'Plate Number': GlobalKey(),
    'Make': GlobalKey(),
    'Model': GlobalKey(),
  };
  Map<String, String> _fieldErrors = const {};
  bool _isCreatingJobCard = false;
  String? _savedJobId;
  bool _savedToServer = false;
  XFile? _registrationDocument;
  XFile? _insuranceDocument;
  final List<String> _jobPhotoPaths = [];
  final List<String> _jobVideoPaths = [];
  String _customerSignaturePath = '';
  String _advisorSignaturePath = '';
  bool _draftRestored = false;

  static const _totalSteps = 4;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(inspectionProvider.notifier).reset());
    if (widget.bookingId != null && widget.bookingId!.isNotEmpty) {
      try {
        Hive.box<dynamic>(
          'inspections',
        ).put('intake_booking_id', widget.bookingId);
      } catch (_) {}
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreDraft());
  }

  bool get _hasUnsavedChanges {
    final s = ref.read(vehicleCustomerFormProvider);
    return s.customerName.trim().isNotEmpty ||
        s.phoneNumber.trim().isNotEmpty ||
        s.plateNumber.trim().isNotEmpty ||
        s.make.isNotEmpty ||
        s.model.isNotEmpty ||
        s.vin.trim().isNotEmpty ||
        _registrationDocument != null ||
        _insuranceDocument != null ||
        _jobPhotoPaths.isNotEmpty ||
        _jobVideoPaths.isNotEmpty ||
        _customerSignaturePath.isNotEmpty ||
        _advisorSignaturePath.isNotEmpty ||
        s.jobDescriptions.any((r) => r.description.trim().isNotEmpty);
  }

  int _completedSections(VehicleCustomerFormState s) {
    var done = 0;
    if (s.customerName.trim().isNotEmpty && s.phoneNumber.trim().length >= 8) {
      done++;
    }
    if (s.plateNumber.trim().isNotEmpty &&
        s.make.isNotEmpty &&
        s.model.isNotEmpty) {
      done++;
    }
    if (_registrationDocument != null ||
        _insuranceDocument != null ||
        _jobPhotoPaths.isNotEmpty ||
        _jobVideoPaths.isNotEmpty) {
      done++;
    }
    if (s.jobDescriptions.any((r) => r.description.trim().isNotEmpty)) done++;
    if (_customerSignaturePath.isNotEmpty ||
        _advisorSignaturePath.isNotEmpty) {
      done++;
    }
    return done;
  }

  // ── Draft save / resume (local Hive only, never synced) ───────────────────

  void _saveDraft() {
    try {
      final s = ref.read(vehicleCustomerFormProvider);
      Hive.box<dynamic>('inspections').put(
        _intakeDraftKey,
        buildIntakeDraft(
          s,
          _step,
          jobPhotoPaths: _jobPhotoPaths,
          jobVideoPaths: _jobVideoPaths,
          customerSignaturePath: _customerSignaturePath,
          advisorSignaturePath: _advisorSignaturePath,
          registrationDocumentPath: _registrationDocument?.path ?? '',
          insuranceDocumentPath: _insuranceDocument?.path ?? '',
        ),
      );
    } catch (_) {}
  }

  void _clearDraft() {
    try {
      Hive.box<dynamic>('inspections').delete(_intakeDraftKey);
    } catch (_) {}
  }

  void _restoreDraft() {
    if (!mounted || _draftRestored) return;
    _draftRestored = true;
    Map<String, dynamic>? draft;
    try {
      final raw = Hive.box<dynamic>('inspections').get(_intakeDraftKey);
      if (raw is Map) draft = Map<String, dynamic>.from(raw);
    } catch (_) {}
    if (draft == null || draft.isEmpty) return;
    // Never clobber a caller-provided booking link with a stale draft step
    // that already produced a job card; a draft is only a starting point.
    if (_hasUnsavedChanges) return;
    final notifier = ref.read(vehicleCustomerFormProvider.notifier);
    applyIntakeDraftToForm(notifier, draft);
    final photos = (draft['jobPhotoPaths'] as List? ?? const [])
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toList();
    final videos = (draft['jobVideoPaths'] as List? ?? const [])
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toList();
    setState(() {
      _step = (draft!['step'] as num?)?.toInt().clamp(0, _totalSteps - 1) ?? 0;
      _jobPhotoPaths
        ..clear()
        ..addAll(photos.where((p) => File(p).existsSync()));
      _jobVideoPaths
        ..clear()
        ..addAll(videos.where((p) => File(p).existsSync()));
      final customerSig = (draft['customerSignaturePath'] ?? '').toString();
      final advisorSig = (draft['advisorSignaturePath'] ?? '').toString();
      if (customerSig.isNotEmpty && File(customerSig).existsSync()) {
        _customerSignaturePath = customerSig;
      }
      if (advisorSig.isNotEmpty && File(advisorSig).existsSync()) {
        _advisorSignaturePath = advisorSig;
      }
    });
    final t = StaffLocalizations.of(context);
    if (t != null && _hasUnsavedChanges && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.advisorIntakeWizardDraftRestored)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = StaffLocalizations.of(context)!;
    final state = ref.watch(vehicleCustomerFormProvider);
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final pendingSync =
        ref.watch(advisorPendingSyncCountProvider).value ?? 0;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final stepLabels = [
      t.advisorIntakeStepCustomer,
      t.advisorIntakeStepVehicle,
      t.advisorIntakeStepMedia,
      t.advisorIntakeStepSignature,
    ];

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard(t);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: WorkspaceAppBar(
          title: t.advisorIntakeTitle,
          subtitle: t.advisorIntakeWizardStepOf(_step + 1, _totalSteps),
          showBack: true,
          onBack: () => _handleBack(t),
          frosted: !context.isCompact,
          showOfflineStatus: true,
          offlinePendingCount: pendingSync,
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              if (widget.bookingId != null) ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.pagePadding.left,
                    AppDimensions.s12,
                    context.pagePadding.right,
                    0,
                  ),
                  child: AppInfoPanel.primary(
                    icon: Icons.event_available_rounded,
                    message: t.advisorIntakeLinkedBooking,
                  ),
                ),
              ],
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.pagePadding.left,
                  AppDimensions.s12,
                  context.pagePadding.right,
                  AppDimensions.s4,
                ),
                child: _progressZone(t, stepLabels),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 1024;
                    final deck = AnimatedSwitcher(
                      duration: reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 250),
                      child: KeyedSubtree(
                        key: ValueKey(_step),
                        child: _deckScroll(t, state),
                      ),
                    );
                    if (!wide) return deck;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: deck),
                        const SizedBox(width: AppDimensions.s24),
                        SizedBox(
                          width: 340,
                          child: SingleChildScrollView(
                            padding: EdgeInsetsDirectional.only(
                              end: context.pagePadding.right,
                              bottom: AppDimensions.s24,
                            ),
                            child: _summary(t, state),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              if (!keyboardOpen) _actionBar(t),
            ],
          ),
        ),
      ),
    );
  }

  /// Journey progress: the full tappable stepper where it fits (≥600 px),
  /// a slim linear progress on compact widths where four labeled nodes would
  /// squeeze past their minimum (verified overflow at 390 px under fallback
  /// fonts and 1.3× text scaling). The app-bar subtitle always names the
  /// exact `Step X of 4` position, so nothing is lost on compact.
  Widget _progressZone(StaffLocalizations t, List<String> stepLabels) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return AppStepper(
            steps: stepLabels,
            currentIndex: _step,
            onStepTap: _onStepTap,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.advisorIntakeWizardStepOf(_step + 1, _totalSteps),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.s6),
            AppLinearProgress(
              value: (_step + 1) / _totalSteps,
              label: stepLabels[_step],
              showPercentage: false,
            ),
          ],
        );
      },
    );
  }

  Widget _deckScroll(StaffLocalizations t, VehicleCustomerFormState s) {
    return SingleChildScrollView(
      key: const PageStorageKey('intake-deck'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        context.pagePadding.left,
        AppDimensions.s12,
        context.pagePadding.right,
        AppDimensions.s24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _deckHeader(t),
          const SizedBox(height: AppDimensions.s16),
          ..._stepCards(t, s),
        ],
      ),
    );
  }

  Widget _deckHeader(StaffLocalizations t) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final titles = [
      t.advisorIntakeWizardContactTitle,
      t.advisorIntakeWizardVehicleTitle,
      t.advisorIntakeWizardCaptureTitle,
      t.advisorIntakeWizardSignoffTitle,
    ];
    final subs = [
      t.advisorIntakeWizardContactSub,
      t.advisorIntakeWizardVehicleSub,
      t.advisorIntakeWizardCaptureSub,
      t.advisorIntakeWizardSignoffSub,
    ];
    final icons = [
      Icons.person_search_rounded,
      Icons.directions_car_outlined,
      Icons.photo_camera_outlined,
      Icons.draw_outlined,
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          ),
          child: Icon(icons[_step], color: colors.onPrimary, size: 24),
        ),
        const SizedBox(width: AppDimensions.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.advisorIntakeWizardStepOf(_step + 1, _totalSteps),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                titles[_step],
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subs[_step],
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _stepCards(StaffLocalizations t, VehicleCustomerFormState s) {
    switch (_step) {
      case 0:
        return [
          _DeckCard(
            title: t.advisorIntakeFindTitle,
            subtitle: t.advisorIntakeFindSub,
            child: _FindExistingRecord(
              state: s,
              ref: ref,
              onScanVin: () => _scanAndSetVin(context, ref),
              onScanQr: () => _scanVehicleQr(context, ref),
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          _DeckCard(
            title: t.advisorIntakeSectionCustomer,
            subtitle: t.advisorIntakeSectionCustomerSub,
            child: _customerFields(t, s),
          ),
        ];
      case 1:
        return [
          _DeckCard(
            title: t.advisorIntakeSectionVehicle,
            subtitle: t.advisorIntakeSectionVehicleSub,
            child: _vehicleFields(t, s),
          ),
        ];
      case 2:
        return [
          _DeckCard(
            title: t.advisorIntakeSectionMedia,
            subtitle: t.advisorIntakeSectionMediaSub,
            child: _mediaFields(t, s),
          ),
          const SizedBox(height: AppDimensions.s16),
          _DeckCard(
            title: t.advisorIntakeSectionBody,
            subtitle: t.advisorIntakeSectionBodySub,
            child: const VehicleBodyConditionPanel(
              embedded: true,
              showTitle: false,
            ),
          ),
        ];
      default:
        return [
          _DeckCard(
            title: t.advisorIntakeSectionJob,
            subtitle: t.advisorIntakeSectionJobSub,
            child: _jobFields(t, s),
          ),
          const SizedBox(height: AppDimensions.s16),
          _DeckCard(
            title: t.advisorIntakeSectionSignature,
            subtitle: t.advisorIntakeSectionSignatureSub,
            child: _signatureFields(t),
          ),
          const SizedBox(height: AppDimensions.s16),
          if (context.adaptive.isCompact) _summary(t, s),
        ];
    }
  }

  // ── Step field groups ─────────────────────────────────────────────────────

  Widget _customerFields(StaffLocalizations t, VehicleCustomerFormState s) {
    final notifier = ref.read(vehicleCustomerFormProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ToggleRow(
          label: t.advisorIntakeB2B,
          value: s.isB2B,
          onChanged: notifier.setB2B,
        ),
        const SizedBox(height: AppDimensions.s16),
        AppFormField(
          label: t.advisorIntakeCustomerName,
          isRequired: true,
          errorText: _fieldErrors['Customer Name'],
          child: _IntakeField(
            key: _fieldKeys['Customer Name'],
            initialValue: s.customerName,
            hint: t.advisorIntakeCustomerNameHint,
            textCapitalization: TextCapitalization.words,
            onChanged: (v) {
              notifier.setCustomerName(v);
              if (v.trim().isNotEmpty) _clearFieldError('Customer Name');
            },
          ),
        ),
        const SizedBox(height: AppDimensions.s16),
        AppFormField(
          label: t.advisorIntakePhone,
          isRequired: true,
          errorText: _fieldErrors['Phone Number'],
          child: _IntakeField(
            key: _fieldKeys['Phone Number'],
            initialValue: s.phoneNumber,
            hint: t.advisorIntakePhoneHint,
            keyboardType: TextInputType.phone,
            isIdentifier: true,
            prefix: _AffixPrefix(phoneCountries.first.code),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) {
              notifier.setPhone(v);
              if (v.trim().length >= 8) _clearFieldError('Phone Number');
            },
          ),
        ),
        const SizedBox(height: AppDimensions.s16),
        AppFormField(
          label: t.advisorIntakeEmail,
          isOptional: true,
          child: _IntakeField(
            initialValue: s.email,
            hint: t.advisorIntakeEmailHint,
            keyboardType: TextInputType.emailAddress,
            isIdentifier: true,
            onChanged: notifier.setEmail,
          ),
        ),
        const SizedBox(height: AppDimensions.s16),
        AppFormField(
          label: t.advisorIntakeCustomerGroup,
          child: AppDropdownButton(
            value: s.customerGroup,
            hint: t.advisorIntakeCustomerGroupHint,
            items: kCustomerGroups,
            onChanged: (v) => notifier.setCustomerGroup(v),
          ),
        ),
        if (s.showMoreCustomer) ...[
          const SizedBox(height: AppDimensions.s16),
          AppFormField(
            label: t.advisorIntakeGender,
            child: AppDropdownButton(
              value: s.gender,
              hint: t.advisorIntakeGenderHint,
              items: kGenders,
              onChanged: (v) => notifier.setGender(v),
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          AppFormField(
            label: t.advisorIntakeAddress,
            child: AppDropdownButton(
              value: s.address,
              hint: t.advisorIntakeAddressHint,
              items: kAddresses,
              onChanged: (v) => notifier.setAddress(v),
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          AppFormField(
            label: t.advisorIntakeTaxNumber,
            isOptional: true,
            child: _IntakeField(
              initialValue: s.taxNumber,
              hint: t.advisorIntakeTaxNumber,
              onChanged: notifier.setTaxNumber,
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          AppFormField(
            label: t.advisorIntakeSource,
            isOptional: true,
            child: _IntakeField(
              initialValue: s.source,
              hint: t.advisorIntakeSourceHint,
              onChanged: notifier.setSource,
            ),
          ),
        ],
        _MoreLessLink(
          showMore: s.showMoreCustomer,
          moreLabel: t.advisorIntakeShowMore,
          lessLabel: t.advisorIntakeShowLess,
          onTap: notifier.toggleCustomerMore,
        ),
      ],
    );
  }

  Widget _vehicleFields(StaffLocalizations t, VehicleCustomerFormState s) {
    final notifier = ref.read(vehicleCustomerFormProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _UaePlateField(
          state: s,
          notifier: notifier,
          plateError: _fieldErrors['Plate Number'],
          plateKey: _fieldKeys['Plate Number']!,
          onPlateChanged: () => _clearFieldError('Plate Number'),
        ),
        const SizedBox(height: AppDimensions.s16),
        AppFormField(
          label: t.advisorIntakeVin,
          isOptional: true,
          child: _IntakeField(
            initialValue: s.vin,
            hint: t.advisorIntakeVinHint,
            isIdentifier: true,
            textCapitalization: TextCapitalization.characters,
            suffixIcon: IconButton(
              tooltip: t.advisorIntakeScanVin,
              onPressed: () => _scanAndSetVin(context, ref),
              icon: const Icon(Icons.qr_code_scanner, size: 18),
            ),
            onChanged: notifier.setVin,
          ),
        ),
        const SizedBox(height: AppDimensions.s16),
        _ResponsiveFieldGroup(
          minChildWidth: 190,
          children: [
            AppFormField(
              label: t.advisorIntakeMake,
              isRequired: true,
              errorText: _fieldErrors['Make'],
              child: _SelectorField(
                key: _fieldKeys['Make'],
                value: s.make,
                hint: t.advisorIntakeMakeHint,
                errorText: _fieldErrors['Make'],
                onTap: () => _pickBrand(s),
              ),
            ),
            AppFormField(
              label: t.advisorIntakeModel,
              isRequired: true,
              errorText: _fieldErrors['Model'],
              child: _SelectorField(
                key: _fieldKeys['Model'],
                value: s.model,
                hint: t.advisorIntakeModelHint,
                errorText: _fieldErrors['Model'],
                onTap: () => _pickModel(t, s),
              ),
            ),
            AppFormField(
              label: t.advisorIntakeModelYear,
              isOptional: true,
              child: _SelectorField(
                value: s.modelYear,
                hint: t.advisorIntakeModelYearHint,
                icon: Icons.keyboard_arrow_down_rounded,
                onTap: () => _pickModelYear(s),
              ),
            ),
          ],
        ),
        _MoreLessLink(
          showMore: s.showMoreVehicle,
          moreLabel: t.advisorIntakeShowMore,
          lessLabel: t.advisorIntakeShowLess,
          onTap: notifier.toggleVehicleMore,
        ),
        if (s.showMoreVehicle) ...[
          const SizedBox(height: AppDimensions.s16),
          AppFormField(
            label: t.advisorIntakeCylinders,
            child: AppDropdownButton(
              value: s.cylinders,
              hint: t.advisorIntakeCylindersHint,
              items: kCylinders,
              onChanged: (v) => notifier.setCylinders(v),
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          AppFormField(
            label: t.advisorIntakeEngineCapacity,
            isOptional: true,
            child: _IntakeField(
              initialValue: s.engineCapacity,
              hint: t.advisorIntakeEngineCapacity,
              onChanged: notifier.setEngineCapacity,
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          AppFormField(
            label: t.advisorIntakeVehicleColor,
            isOptional: true,
            child: _IntakeField(
              initialValue: s.vehicleColor,
              hint: t.advisorIntakeVehicleColor,
              onChanged: notifier.setVehicleColor,
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          AppFormField(
            label: t.advisorIntakeFuelType,
            child: AppDropdownButton(
              value: s.fuelType,
              hint: t.advisorIntakeFuelTypeHint,
              items: kFuelTypes,
              onChanged: (v) => notifier.setFuelType(v),
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          AppFormField(
            label: t.advisorIntakeEngineNumber,
            isOptional: true,
            child: _IntakeField(
              initialValue: s.engineNumber,
              hint: t.advisorIntakeEngineNumber,
              isIdentifier: true,
              onChanged: notifier.setEngineNumber,
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          AppFormField(
            label: t.advisorIntakeRegistrationCertificate,
            isOptional: true,
            child: AppMediaUploadShell(
              label: _registrationDocument?.name ?? t.advisorIntakeAddDocument,
              helperText: '',
              icon: Icons.badge_outlined,
              onTap: () => _pickDocument(true),
            ),
          ),
        ],
      ],
    );
  }

  Widget _mediaFields(StaffLocalizations t, VehicleCustomerFormState s) {
    final notifier = ref.read(vehicleCustomerFormProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (s.jobCategory == 'Insurance') ...[
          AppFormField(
            label: t.advisorIntakeInsuranceDocument,
            isOptional: true,
            child: AppMediaUploadShell(
              label: _insuranceDocument?.name ?? t.advisorIntakeAddDocument,
              helperText: '',
              icon: Icons.shield_outlined,
              onTap: () => _pickDocument(false),
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
        ],
        AppFormField(
          label: t.advisorIntakeOdometer,
          isOptional: true,
          child: _IntakeField(
            initialValue: s.odometerReading,
            hint: t.advisorIntakeOdometerHint,
            keyboardType: TextInputType.number,
            isIdentifier: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: notifier.setOdometer,
          ),
        ),
        const SizedBox(height: AppDimensions.s16),
        AppFormField(
          label: t.advisorIntakeFuelLevel,
          child: _FuelLevelSlider(
            value: s.fuelLevel,
            onChanged: notifier.setFuelLevel,
          ),
        ),
        const SizedBox(height: AppDimensions.s16),
        _ToggleRow(
          label: t.advisorIntakeCustomerConsent,
          value: s.customerConsent,
          onChanged: notifier.setConsent,
        ),
        const SizedBox(height: AppDimensions.s16),
        AppFormField(
          label: t.advisorIntakeJobMedia,
          child: Row(
            children: [
              Expanded(
                child: _MediaAddTile(
                  icon: Icons.photo_library_outlined,
                  label: t.advisorIntakePhotos,
                  addLabel: t.advisorIntakeAddLabel(t.advisorIntakePhotos),
                  count: _jobPhotoPaths.length,
                  onTap: _pickJobPhotos,
                ),
              ),
              const SizedBox(width: AppDimensions.s10),
              Expanded(
                child: _MediaAddTile(
                  icon: Icons.videocam_outlined,
                  label: t.advisorIntakeVideo,
                  addLabel: t.advisorIntakeAddLabel(t.advisorIntakeVideo),
                  count: _jobVideoPaths.length,
                  onTap: _pickJobVideo,
                ),
              ),
            ],
          ),
        ),
        if (_jobPhotoPaths.isNotEmpty || _jobVideoPaths.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.s12),
          _MediaThumbnailGrid(
            photoPaths: _jobPhotoPaths,
            videoPaths: _jobVideoPaths,
            onRemovePhoto: (i) => setState(() => _jobPhotoPaths.removeAt(i)),
            onRemoveVideo: (i) => setState(() => _jobVideoPaths.removeAt(i)),
          ),
        ],
      ],
    );
  }

  Widget _jobFields(StaffLocalizations t, VehicleCustomerFormState s) {
    final notifier = ref.read(vehicleCustomerFormProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFormField(
          label: t.advisorIntakeJobCategory,
          child: AppDropdownButton(
            value: s.jobCategory,
            hint: t.advisorIntakeJobCategoryHint,
            items: kJobCategories,
            onChanged: (v) => notifier.setJobCategory(v),
          ),
        ),
        if (s.jobCategory == 'Insurance') ...[
          const SizedBox(height: AppDimensions.s16),
          AppFormField(
            label: t.advisorIntakeInsuranceName,
            child: AppDropdownButton(
              value: s.insuranceProvider,
              hint: t.advisorIntakeInsuranceNameHint,
              items: kInsuranceProviders,
              onChanged: (v) => notifier.setInsuranceProvider(v),
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          AppFormField(
            label: t.advisorIntakeLpoNumber,
            isOptional: true,
            child: _IntakeField(
              initialValue: s.lpoNumber,
              hint: t.advisorIntakeLpoNumber,
              onChanged: notifier.setLpoNumber,
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          AppFormField(
            label: t.advisorIntakePolicyNumber,
            isOptional: true,
            child: _IntakeField(
              initialValue: s.policyNumber,
              hint: t.advisorIntakePolicyNumber,
              onChanged: notifier.setPolicyNumber,
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          AppFormField(
            label: t.advisorIntakeAccidentNumber,
            isOptional: true,
            child: _IntakeField(
              initialValue: s.accidentNumber,
              hint: t.advisorIntakeAccidentNumber,
              onChanged: notifier.setAccidentNumber,
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          AppFormField(
            label: t.advisorIntakeInsuranceTaxNumber,
            isOptional: true,
            child: _IntakeField(
              initialValue: s.insuranceTaxNumber,
              hint: t.advisorIntakeInsuranceTaxHint,
              onChanged: notifier.setInsuranceTaxNumber,
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          AppFormField(
            label: t.advisorIntakeInsuranceAddress,
            isOptional: true,
            child: _IntakeField(
              initialValue: s.insuranceAddress,
              hint: t.advisorIntakeInsuranceAddress,
              onChanged: notifier.setInsuranceAddress,
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          AppFormField(
            label: t.advisorIntakeInsuranceExpiry,
            isOptional: true,
            child: AppDateSelectorShell(
              value: s.insuranceExpiryDate,
              onTap: () async {
                final initial =
                    DateTime.tryParse(s.insuranceExpiryDate) ?? DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: initial,
                  firstDate: DateTime(1980),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  final month = picked.month.toString().padLeft(2, '0');
                  final day = picked.day.toString().padLeft(2, '0');
                  notifier.setInsuranceExpiry(
                    '${picked.year}-$month-$day',
                  );
                }
              },
            ),
          ),
        ],
        const SizedBox(height: AppDimensions.s16),
        _ResponsiveFieldGroup(
          minChildWidth: 200,
          children: [
            AppFormField(
              label: t.advisorIntakeMarkupType,
              isOptional: true,
              child: _IntakeField(
                initialValue: s.markupType,
                hint: t.advisorIntakeMarkupType,
                onChanged: notifier.setMarkupType,
              ),
            ),
            AppFormField(
              label: t.advisorIntakeOrderType,
              isOptional: true,
              child: _IntakeField(
                initialValue: s.orderType,
                hint: t.advisorIntakeOrderType,
                onChanged: notifier.setOrderType,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.s16),
        AppFormField(
          label: t.advisorIntakeJobDescription,
          child: _JobDescriptionTable(state: s, ref: ref),
        ),
      ],
    );
  }

  Widget _signatureFields(StaffLocalizations t) {
    final hasCustomer = _customerSignaturePath.isNotEmpty;
    final hasAdvisor = _advisorSignaturePath.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SignatureRow(
          label: t.advisorIntakeSignatureCustomer,
          captured: hasCustomer,
          capturedLabel: t.advisorIntakeSignatureCaptured,
          redoLabel: t.advisorIntakeSignatureRedo,
          onCapture: () => _captureSignature(true),
        ),
        const SizedBox(height: AppDimensions.s12),
        _SignatureRow(
          label: t.advisorIntakeSignatureAdvisor,
          captured: hasAdvisor,
          capturedLabel: t.advisorIntakeSignatureCaptured,
          redoLabel: t.advisorIntakeSignatureRedo,
          onCapture: () => _captureSignature(false),
        ),
      ],
    );
  }

  Widget _summary(StaffLocalizations t, VehicleCustomerFormState s) {
    final done = _completedSections(s);
    return AppFormPanel(
      title: t.advisorIntakeSummaryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppLinearProgress(
            value: done / 5,
            label: t.advisorIntakeSummaryProgress(done, 5),
            showPercentage: false,
          ),
          const SizedBox(height: AppDimensions.s16),
          _SummaryRow(
            icon: Icons.person_outline_rounded,
            title: t.advisorIntakeSummaryCustomer,
            value: s.customerName.trim().isEmpty
                ? t.advisorIntakeSummaryNoName
                : s.customerName,
            secondary: s.phoneNumber.isEmpty
                ? null
                : '${phoneCountries.first.code} ${s.phoneNumber}',
            empty: s.customerName.trim().isEmpty,
          ),
          const SizedBox(height: AppDimensions.s12),
          _SummaryRow(
            icon: Icons.directions_car_outlined,
            title: t.advisorIntakeSummaryVehicle,
            value: [s.make, s.model].where((e) => e.isNotEmpty).join(' '),
            secondary: s.registrationNumber.isEmpty
                ? null
                : s.registrationNumber,
            empty: s.make.isEmpty && s.model.isEmpty,
          ),
          if (done == 0) ...[
            const SizedBox(height: AppDimensions.s16),
            Text(
              t.advisorIntakeSummaryEmpty,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionBar(StaffLocalizations t) {
    final last = _step == _totalSteps - 1;
    return AppActionBar(
      sticky: true,
      secondary: [
        if (_step > 0)
          AppButton.secondary(
            label: t.advisorIntakeWizardBack,
            leadingIcon: Icons.arrow_back_rounded,
            isExpanded: context.adaptive.isCompact,
            onPressed: _isCreatingJobCard ? null : () => _goTo(_step - 1),
          ),
      ],
      primary: last
          ? AppButton.primary(
              label: _isCreatingJobCard
                  ? t.advisorIntakeActionCreating
                  : t.advisorIntakeActionCreate,
              icon: Icons.add_task_rounded,
              isLoading: _isCreatingJobCard,
              isExpanded: context.adaptive.isCompact,
              onPressed: _isCreatingJobCard ? null : () => _create(t),
            )
          : AppButton.primary(
              label: t.advisorIntakeWizardNext,
              icon: Icons.arrow_forward_rounded,
              isExpanded: context.adaptive.isCompact,
              onPressed: () => _advance(t),
            ),
    );
  }

  // ── Wizard navigation ─────────────────────────────────────────────────────

  void _onStepTap(int index) {
    if (index == _step) return;
    final t = StaffLocalizations.of(context)!;
    if (index < _step) {
      _goTo(index);
      return;
    }
    // Forward jumps must clear every intermediate gate in order.
    for (var s = _step; s < index; s++) {
      if (!_validateStep(s, ref.read(vehicleCustomerFormProvider), t)) {
        setState(() => _step = s);
        _saveDraft();
        _scrollToFirstError();
        return;
      }
    }
    _goTo(index);
  }

  void _advance(StaffLocalizations t) {
    final s = ref.read(vehicleCustomerFormProvider);
    if (!_validateStep(_step, s, t)) {
      _scrollToFirstError();
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    _goTo(_step + 1);
  }

  void _goTo(int index) {
    setState(() {
      _step = index.clamp(0, _totalSteps - 1);
      if (_fieldErrors.isNotEmpty) _fieldErrors = const {};
    });
    _saveDraft();
  }

  /// Validates a single deck step. Steps without required fields always pass;
  /// the final submit still runs the full form validation.
  bool _validateStep(
    int step,
    VehicleCustomerFormState s,
    StaffLocalizations t,
  ) {
    final errors = <MapEntry<String, String>>[];
    if (step == 0) {
      if (s.customerName.trim().isEmpty) {
        errors.add(MapEntry('Customer Name', t.advisorIntakeErrCustomerName));
      }
      if (s.phoneNumber.trim().isEmpty) {
        errors.add(MapEntry('Phone Number', t.advisorIntakeErrPhone));
      } else if (s.phoneNumber.trim().length < 8) {
        errors.add(MapEntry('Phone Number', t.advisorIntakeErrPhoneValid));
      }
    } else if (step == 1) {
      if (s.plateNumber.trim().isEmpty) {
        errors.add(MapEntry('Plate Number', t.advisorIntakeErrPlate));
      }
      if (s.make.trim().isEmpty) {
        errors.add(MapEntry('Make', t.advisorIntakeErrMake));
      }
      if (s.model.trim().isEmpty) {
        errors.add(MapEntry('Model', t.advisorIntakeErrModel));
      }
    }
    if (errors.isNotEmpty) {
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() => _fieldErrors = Map.fromEntries(errors));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.advisorIntakeWizardBlocked)),
      );
      return false;
    }
    if (_fieldErrors.isNotEmpty) {
      setState(() => _fieldErrors = const {});
    }
    return true;
  }

  void _scrollToFirstError() {
    if (_fieldErrors.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final firstContext = _fieldKeys[_fieldErrors.keys.first]?.currentContext;
      if (firstContext != null) {
        Scrollable.ensureVisible(
          firstContext,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          alignment: 0.18,
        );
      }
    });
  }

  // ── Pickers ─────────────────────────────────────────────────────────────────

  Future<void> _pickBrand(VehicleCustomerFormState s) async {
    final result = await showSelectBrandSheet(
      context: context,
      selected: s.make.isEmpty ? null : s.make,
    );
    if (result != null) {
      ref.read(vehicleCustomerFormProvider.notifier).setMake(result);
      _clearFieldError('Make');
      _clearFieldError('Model');
    }
  }

  Future<void> _pickModel(
    StaffLocalizations t,
    VehicleCustomerFormState s,
  ) async {
    if (s.make.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.advisorIntakeSelectBrandFirst)),
      );
      return;
    }
    final result = await showSelectModelSheet(
      context: context,
      brand: s.make,
      selected: s.model.isEmpty ? null : s.model,
    );
    if (result != null) {
      ref.read(vehicleCustomerFormProvider.notifier).setModel(result);
      _clearFieldError('Model');
    }
  }

  Future<void> _pickModelYear(VehicleCustomerFormState s) async {
    final result = await showModelYearDialog(context, s.modelYear);
    if (result != null) {
      ref.read(vehicleCustomerFormProvider.notifier).setModelYear(result);
    }
  }

  // ── Validation ──────────────────────────────────────────────────────────────

  List<MapEntry<String, String>> _validateForm(
    VehicleCustomerFormState s,
    StaffLocalizations t,
  ) {
    final errors = <MapEntry<String, String>>[];
    if (s.customerName.trim().isEmpty) {
      errors.add(MapEntry('Customer Name', t.advisorIntakeErrCustomerName));
    }
    if (s.phoneNumber.trim().isEmpty) {
      errors.add(MapEntry('Phone Number', t.advisorIntakeErrPhone));
    } else if (s.phoneNumber.trim().length < 8) {
      errors.add(MapEntry('Phone Number', t.advisorIntakeErrPhoneValid));
    }
    if (s.plateNumber.trim().isEmpty) {
      errors.add(MapEntry('Plate Number', t.advisorIntakeErrPlate));
    }
    if (s.make.trim().isEmpty) {
      errors.add(MapEntry('Make', t.advisorIntakeErrMake));
    }
    if (s.model.trim().isEmpty) {
      errors.add(MapEntry('Model', t.advisorIntakeErrModel));
    }
    return errors;
  }

  void _clearFieldError(String field) {
    if (!_fieldErrors.containsKey(field)) return;
    setState(() {
      final updated = Map<String, String>.from(_fieldErrors)..remove(field);
      _fieldErrors = updated;
    });
  }

  Future<void> _handleBack(StaffLocalizations t) async {
    if (_step > 0) {
      _goTo(_step - 1);
      return;
    }
    if (_hasUnsavedChanges) {
      await _confirmDiscard(t);
    } else if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _confirmDiscard(StaffLocalizations t) async {
    final leave = await showAppConfirmationDialog(
      context,
      title: t.advisorIntakeDiscardTitle,
      message: t.advisorIntakeDiscardBody,
      confirmLabel: t.advisorIntakeDiscardConfirm,
      cancelLabel: t.advisorIntakeDiscardCancel,
      icon: Icons.delete_outline_rounded,
      destructive: true,
    );
    if (leave && mounted) {
      _clearDraft();
      Navigator.of(context).pop();
    }
  }

  // ── Save ────────────────────────────────────────────────────────────────────

  Future<void> _create(StaffLocalizations t) async {
    final formState = ref.read(vehicleCustomerFormProvider);
    final bodyCondition = ref
        .read(inspectionProvider)
        .vehicleBodyConditionPayload;
    final errors = _validateForm(formState, t);
    if (errors.isNotEmpty) {
      FocusManager.instance.primaryFocus?.unfocus();
      // Jump back to the deck holding the first invalid field so the error
      // is visible instead of stranded on another step.
      final first = errors.first.key;
      final targetStep = (first == 'Customer Name' || first == 'Phone Number')
          ? 0
          : 1;
      setState(() {
        _fieldErrors = Map.fromEntries(errors);
        _step = targetStep;
      });
      _scrollToFirstError();
      return;
    }
    if (_fieldErrors.isNotEmpty) {
      setState(() => _fieldErrors = const {});
    }
    setState(() => _isCreatingJobCard = true);
    try {
      final local = GenericLocalDataSource(Hive.box<dynamic>('inspections'));
      final id = await IdGenerator.nextId('JC');
      _savedJobId = id;
      final now = DateTime.now();
      final createdDate =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      final payload = {
        'id': id,
        'type': 'vehicle_customer',
        'bookingId': widget.bookingId ?? '',
        'customerName': formState.customerName,
        'phoneNumber': formState.phoneNumber,
        'email': formState.email,
        'isB2B': formState.isB2B,
        'customerGroup': formState.customerGroup,
        'gender': formState.gender,
        'address': formState.address,
        'taxNumber': formState.taxNumber,
        'source': formState.source,
        'emirate': formState.emirate,
        'plateCode': formState.plateCode,
        'plateNumber': formState.plateNumber,
        'vin': formState.vin,
        'make': formState.make,
        'model': formState.model,
        'modelYear': formState.modelYear,
        'registrationNumber': formState.registrationNumber,
        'cylinders': formState.cylinders,
        'engineCapacity': formState.engineCapacity,
        'vehicleColor': formState.vehicleColor,
        'fuelType': formState.fuelType,
        'engineNumber': formState.engineNumber,
        'jobCategory': formState.jobCategory,
        'markupType': formState.markupType,
        'orderType': formState.orderType,
        'jobDescription': formState.jobDescription,
        'jobDescriptions': [
          for (var i = 0; i < formState.jobDescriptions.length; i++)
            {
              ...formState.jobDescriptions[i].toJson(),
              'mediaItemId': 'job-description-${i + 1}',
            },
        ],
        'jobDescriptionMedia': [
          for (var i = 0; i < formState.jobDescriptions.length; i++) ...[
            for (final path in formState.jobDescriptions[i].photoPaths)
              {
                'path': path,
                'itemId': 'job-description-${i + 1}',
                'type': 'photo',
              },
            for (final path in formState.jobDescriptions[i].videoPaths)
              {
                'path': path,
                'itemId': 'job-description-${i + 1}',
                'type': 'video',
              },
            if (formState.jobDescriptions[i].audioPath.isNotEmpty)
              {
                'path': formState.jobDescriptions[i].audioPath,
                'itemId': 'job-description-${i + 1}',
                'type': 'audio',
              },
          ],
        ],
        'insuranceProvider': formState.insuranceProvider,
        'insuranceTaxNumber': formState.insuranceTaxNumber,
        'insuranceAddress': formState.insuranceAddress,
        'policyNumber': formState.policyNumber,
        'lpoNumber': formState.lpoNumber,
        'accidentNumber': formState.accidentNumber,
        'insuranceExpiryDate': formState.insuranceExpiryDate,
        'vehicleBodyCondition': bodyCondition,
        'jobPhotoPaths': List<String>.from(_jobPhotoPaths),
        'jobVideoPaths': List<String>.from(_jobVideoPaths),
        'customerSignaturePath': _customerSignaturePath,
        'advisorSignaturePath': _advisorSignaturePath,
        'odometerReading': formState.odometerReading,
        'fuelLevel': formState.fuelLevel,
        'customerConsent': formState.customerConsent,
        'registrationDocumentPath': _registrationDocument?.path ?? '',
        'insuranceDocumentPath': _insuranceDocument?.path ?? '',
        'status': 'inProgress',
        'createdDate': createdDate,
        'lastUpdated': createdDate,
      };
      await local.save(id, payload);
      // The job card is safe locally; the draft has served its purpose.
      _clearDraft();
      final queue = ref.read(syncQueueProvider);
      await queue.enqueue(
        SyncOperation(
          id: id,
          entityType: 'vehicle_customer',
          entityId: id,
          changeType: ChangeType.create,
          payload: payload,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      await ref.read(syncEngineProvider).syncAll();
      var resolvedJobId = id;
      var savedToServer = false;
      try {
        final record = Hive.box<dynamic>('inspections').get(id);
        if (record is Map) {
          final serverRef =
              (record['jobCardRef'] ?? record['serverJobCardId'] ?? '')
                  .toString();
          if (serverRef.isNotEmpty) {
            resolvedJobId = serverRef;
            savedToServer = true;
          }
        }
      } catch (_) {}
      _savedJobId = resolvedJobId;
      _savedToServer = savedToServer;
      ref.read(advisorRefreshProvider.notifier).state++;
      if (!mounted) return;
      _showInspectionPrompt(t);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.advisorIntakeSaveFailed),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isCreatingJobCard = false);
    }
  }

  void _showInspectionPrompt(StaffLocalizations t) {
    final colors = Theme.of(context).colorScheme;
    final semantic = context.semanticColors;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusSheet),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.s24,
          AppDimensions.s16,
          AppDimensions.s24,
          AppDimensions.s32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppDimensions.s20),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: (_savedToServer
                        ? semantic.success.base
                        : semantic.info.base)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
              ),
              child: Icon(
                _savedToServer
                    ? Icons.cloud_done_outlined
                    : Icons.cloud_upload_outlined,
                color: _savedToServer
                    ? semantic.success.base
                    : semantic.info.base,
                size: 28,
              ),
            ),
            const SizedBox(height: AppDimensions.s12),
            PendingSyncChip(
              state: _savedToServer
                  ? SyncChipState.synced
                  : SyncChipState.queued,
              label: _savedToServer
                  ? t.advisorIntakeStatusSent
                  : t.advisorIntakeStatusQueued,
            ),
            const SizedBox(height: AppDimensions.s16),
            Text(
              _savedToServer
                  ? t.advisorIntakeSyncedTitle
                  : t.advisorIntakeLocalTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.s8),
            Text(
              _savedToServer
                  ? t.advisorIntakeSyncedBody
                  : t.advisorIntakeLocalBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppDimensions.s24),
            AppButton.primary(
              label: t.advisorIntakeAddInspection,
              icon: Icons.search_outlined,
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(inspectionProvider.notifier).reset();
                final jobId = _savedJobId ?? '';
                ref.read(inspectionProvider.notifier).setJobCardId(jobId);
                final callbacks = InspectionCallbacks(
                  onBack: () {
                    ref.read(advisorRefreshProvider.notifier).state++;
                    context.pop();
                  },
                  onSaveDraft: () {
                    ref.read(advisorRefreshProvider.notifier).state++;
                    context.pop();
                    context.pop();
                  },
                  onPreview: () {
                    context.push(
                      AppRoutes.inspectionPreview,
                      extra: {'onBack': () => context.pop(), 'jobId': jobId},
                    );
                  },
                );
                context.push(AppRoutes.inspectionSheet, extra: callbacks);
              },
            ),
            const SizedBox(height: AppDimensions.s10),
            AppButton.secondary(
              label: t.advisorIntakeSkip,
              onPressed: () {
                Navigator.pop(ctx);
                if (context.mounted) context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Media / signatures ──────────────────────────────────────────────────────

  Future<void> _scanAndSetVin(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScanVehicleView(scanMode: 'VIN')),
    );
    if (result != null && mounted) {
      ref.read(vehicleCustomerFormProvider.notifier).setVin(result);
    }
  }

  Future<void> _scanVehicleQr(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScanVehicleView(scanMode: 'QR')),
    );
    if (result != null && mounted) {
      ref
          .read(vehicleCustomerFormProvider.notifier)
          .setRegistrationNumber(result);
    }
  }

  Future<void> _pickDocument(bool registration) async {
    final t = StaffLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.s16,
            AppDimensions.s4,
            AppDimensions.s16,
            AppDimensions.s20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                registration
                    ? t.advisorIntakeAddRegistration
                    : t.advisorIntakeAddInsurance,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppDimensions.s14),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.pop(context, ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(t.advisorIntakeTakePhoto),
              ),
              const SizedBox(height: AppDimensions.s8),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context, ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(t.advisorIntakeChooseGallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 86,
      maxWidth: 2200,
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (registration) {
        _registrationDocument = picked;
      } else {
        _insuranceDocument = picked;
      }
    });
  }

  Future<String> _persistPickedFile(XFile file, String prefix) async {
    final directory = await getApplicationDocumentsDirectory();
    final extension = file.name.contains('.')
        ? file.name.split('.').last
        : 'bin';
    final destination =
        '${directory.path}/${prefix}_${DateTime.now().microsecondsSinceEpoch}.$extension';
    return persistMediaFile(file.path, destination);
  }

  Future<void> _pickJobPhotos() async {
    final files = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (files.isEmpty) return;
    final paths = <String>[];
    for (final file in files) {
      paths.add(await _persistPickedFile(file, 'job_photo'));
    }
    if (mounted) setState(() => _jobPhotoPaths.addAll(paths));
  }

  Future<void> _pickJobVideo() async {
    final t = StaffLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: Text(t.advisorIntakeRecordVideo),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.video_library_outlined),
              title: Text(t.advisorIntakeChooseVideo),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    final file = await ImagePicker().pickVideo(
      source: source,
      maxDuration: const Duration(minutes: 3),
    );
    if (file == null) return;
    final path = await _persistPickedFile(file, 'job_video');
    if (mounted) setState(() => _jobVideoPaths.add(path));
  }

  Future<void> _captureSignature(bool customer) async {
    final t = StaffLocalizations.of(context)!;
    final title = customer
        ? t.advisorIntakeSignatureCustomerTitle
        : t.advisorIntakeSignatureAdvisorTitle;
    final bytes = await showModalBottomSheet<Uint8List>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusSheet),
        ),
      ),
      builder: (_) => AdvisorSignaturePad(title: title),
    );
    if (bytes == null || bytes.isEmpty || !mounted) return;
    final path = await saveSignatureFile(
      bytes,
      '${customer ? 'customer' : 'advisor'}_signature_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    if (!mounted || path.isEmpty) return;
    setState(() {
      if (customer) {
        _customerSignaturePath = path;
      } else {
        _advisorSignaturePath = path;
      }
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Intake draft snapshot (pure, unit-testable; Hive IO stays in [_BodyState])
// ─────────────────────────────────────────────────────────────────────────────

/// Serializes the unfinished wizard into a plain map for the local draft.
Map<String, dynamic> buildIntakeDraft(
  VehicleCustomerFormState s,
  int step, {
  List<String> jobPhotoPaths = const [],
  List<String> jobVideoPaths = const [],
  String customerSignaturePath = '',
  String advisorSignaturePath = '',
  String registrationDocumentPath = '',
  String insuranceDocumentPath = '',
}) => {
  'version': 1,
  'step': step,
  'customerSearch': s.customerSearch,
  'isB2B': s.isB2B,
  'customerName': s.customerName,
  'phoneNumber': s.phoneNumber,
  'email': s.email,
  'customerGroup': s.customerGroup,
  'gender': s.gender,
  'address': s.address,
  'taxNumber': s.taxNumber,
  'source': s.source,
  'emirate': s.emirate,
  'plateCode': s.plateCode,
  'plateNumber': s.plateNumber,
  'registrationNumber': s.registrationNumber,
  'vin': s.vin,
  'make': s.make,
  'model': s.model,
  'modelYear': s.modelYear,
  'cylinders': s.cylinders,
  'engineCapacity': s.engineCapacity,
  'vehicleColor': s.vehicleColor,
  'fuelType': s.fuelType,
  'engineNumber': s.engineNumber,
  'jobCategory': s.jobCategory,
  'markupType': s.markupType,
  'orderType': s.orderType,
  'insuranceProvider': s.insuranceProvider,
  'insuranceTaxNumber': s.insuranceTaxNumber,
  'insuranceAddress': s.insuranceAddress,
  'policyNumber': s.policyNumber,
  'lpoNumber': s.lpoNumber,
  'accidentNumber': s.accidentNumber,
  'insuranceExpiryDate': s.insuranceExpiryDate,
  'odometerReading': s.odometerReading,
  'fuelLevel': s.fuelLevel,
  'customerConsent': s.customerConsent,
  'jobPhotoPaths': List<String>.from(jobPhotoPaths),
  'jobVideoPaths': List<String>.from(jobVideoPaths),
  'customerSignaturePath': customerSignaturePath,
  'advisorSignaturePath': advisorSignaturePath,
  'registrationDocumentPath': registrationDocumentPath,
  'insuranceDocumentPath': insuranceDocumentPath,
};

/// Restores provider-owned draft fields. Media paths are returned to the
/// caller through the same map keys (the state owns those lists).
void applyIntakeDraftToForm(
  VehicleCustomerFormNotifier notifier,
  Map<String, dynamic> draft,
) {
  String str(String key) => (draft[key] ?? '').toString();
  notifier
    ..setCustomerSearch(str('customerSearch'))
    ..setB2B(draft['isB2B'] == true)
    ..setCustomerName(str('customerName'))
    ..setPhone(str('phoneNumber'))
    ..setEmail(str('email'))
    ..setCustomerGroup(str('customerGroup'))
    ..setGender(str('gender'))
    ..setAddress(str('address'))
    ..setTaxNumber(str('taxNumber'))
    ..setSource(str('source'))
    ..setEmirate(str('emirate'))
    ..setPlateCode(str('plateCode'))
    ..setPlateNumber(str('plateNumber'))
    ..setRegistrationNumber(str('registrationNumber'))
    ..setVin(str('vin'))
    ..setMake(str('make'))
    ..setModel(str('model'))
    ..setModelYear(str('modelYear'))
    ..setCylinders(str('cylinders'))
    ..setEngineCapacity(str('engineCapacity'))
    ..setVehicleColor(str('vehicleColor'))
    ..setFuelType(str('fuelType'))
    ..setEngineNumber(str('engineNumber'))
    ..setJobCategory(
      str('jobCategory').isEmpty ? 'Regular' : str('jobCategory'),
    )
    ..setMarkupType(str('markupType'))
    ..setOrderType(str('orderType'))
    ..setInsuranceProvider(str('insuranceProvider'))
    ..setInsuranceTaxNumber(str('insuranceTaxNumber'))
    ..setInsuranceAddress(str('insuranceAddress'))
    ..setPolicyNumber(str('policyNumber'))
    ..setLpoNumber(str('lpoNumber'))
    ..setAccidentNumber(str('accidentNumber'))
    ..setInsuranceExpiry(str('insuranceExpiryDate'))
    ..setOdometer(str('odometerReading'))
    ..setConsent(draft['customerConsent'] == true);
  final fuel = (draft['fuelLevel'] as num?)?.toInt();
  if (fuel != null) notifier.setFuelLevel(fuel);
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shared intake building blocks
// ─────────────────────────────────────────────────────────────────────────────

/// Deck card: the wizard's unit of composition. Unlike the old collapsible
/// sections, decks are always open and carry a flat title row — the stepper
/// owns progress, the card owns its fields.
class _DeckCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _DeckCard({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.s16),
          child,
        ],
      ),
    );
  }
}

/// UAE plate capture: emirate selector + code letter + number rendered as one
/// LTR plate identity. The composed `registrationNumber` stays mirrored-safe
/// because every identifier renders with an explicit LTR direction.
class _UaePlateField extends StatelessWidget {
  final VehicleCustomerFormState state;
  final VehicleCustomerFormNotifier notifier;
  final String? plateError;
  final GlobalKey plateKey;
  final VoidCallback onPlateChanged;

  const _UaePlateField({
    required this.state,
    required this.notifier,
    required this.plateError,
    required this.plateKey,
    required this.onPlateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Plate preview strip: the composed identity, always LTR.
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s14,
            vertical: AppDimensions.s10,
          ),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.credit_card_rounded,
                size: 18,
                color: colors.primary,
              ),
              const SizedBox(width: AppDimensions.s10),
              Expanded(
                child: Text(
                  s.registrationNumber.isEmpty
                      ? t.advisorIntakePlateNumberHint
                      : s.registrationNumber,
                  textDirection: TextDirection.ltr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.mono(color: colors.primary).copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.s12),
        _ResponsiveFieldGroup(
          minChildWidth: 150,
          children: [
            AppFormField(
              label: t.advisorIntakeEmirate,
              child: AppDropdownButton(
                value: s.emirate,
                hint: t.advisorIntakeEmirateHint,
                items: kEmirates,
                onChanged: (v) => notifier.setEmirate(v),
              ),
            ),
            AppFormField(
              label: t.advisorIntakePlateCode,
              child: _IntakeField(
                initialValue: s.plateCode,
                hint: t.advisorIntakePlateCodeHint,
                textCapitalization: TextCapitalization.characters,
                isIdentifier: true,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                  LengthLimitingTextInputFormatter(4),
                ],
                onChanged: notifier.setPlateCode,
              ),
            ),
            AppFormField(
              label: t.advisorIntakePlateNumber,
              isRequired: true,
              errorText: plateError,
              child: _IntakeField(
                key: plateKey,
                initialValue: s.plateNumber,
                hint: t.advisorIntakePlateNumberHint,
                keyboardType: TextInputType.number,
                isIdentifier: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                prefix: (s.emirate.isEmpty && s.plateCode.isEmpty)
                    ? null
                    : _AffixPrefix('${s.emirate}-${s.plateCode}'),
                onChanged: (v) {
                  notifier.setPlateNumber(v);
                  if (v.trim().isNotEmpty) onPlateChanged();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Text field that adapts the shared [AppTextField] to the intake's
/// `initialValue`-driven form state by owning a controller internally.
class _IntakeField extends StatefulWidget {
  final String? initialValue;
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final Widget? prefix;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool isIdentifier;

  const _IntakeField({
    super.key,
    this.initialValue,
    required this.hint,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.prefix,
    this.suffixIcon,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.isIdentifier = false,
  });

  @override
  State<_IntakeField> createState() => _IntakeFieldState();
}

class _IntakeFieldState extends State<_IntakeField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void didUpdateWidget(covariant _IntakeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final incoming = widget.initialValue ?? '';
    if (incoming != _controller.text) {
      _controller.text = incoming;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: _controller,
      hint: widget.hint,
      onChanged: widget.onChanged,
      keyboardType: widget.keyboardType,
      prefix: widget.prefix,
      suffixIcon: widget.suffixIcon,
      inputFormatters: widget.inputFormatters,
      textCapitalization: widget.textCapitalization,
      isIdentifier: widget.isIdentifier,
    );
  }
}

/// Tap-to-select field trigger (brand/model/year) styled like an input.
class _SelectorField extends StatelessWidget {
  final String value;
  final String hint;
  final String? errorText;
  final IconData icon;
  final VoidCallback onTap;

  const _SelectorField({
    super.key,
    required this.value,
    required this.hint,
    this.errorText,
    this.icon = Icons.chevron_right_rounded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasValue = value.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.s16,
          vertical: AppDimensions.s12,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          border: Border.all(
            color: errorText != null ? colors.error : colors.outline,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue ? value : hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: hasValue
                      ? colors.onSurface
                      : colors.onSurfaceVariant.withValues(alpha: 0.7),
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Icon(icon, size: 20, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

/// Always-visible inline prefix (country dial code / plate prefix).
class _AffixPrefix extends StatelessWidget {
  final String text;
  const _AffixPrefix(this.text);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 14, end: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Container(height: 20, width: 1, color: colors.outline),
        ],
      ),
    );
  }
}

class _MoreLessLink extends StatelessWidget {
  final bool showMore;
  final String moreLabel;
  final String lessLabel;
  final VoidCallback onTap;

  const _MoreLessLink({
    required this.showMore,
    required this.moreLabel,
    required this.lessLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: TextButton(
        onPressed: onTap,
        child: Text(showMore ? lessLabel : moreLabel),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onChanged != null;
    return Semantics(
      toggled: value,
      enabled: enabled,
      child: InkWell(
        onTap: enabled ? () => onChanged!(!value) : null,
        borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s14,
            vertical: AppDimensions.s6,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              IgnorePointer(
                child: Switch.adaptive(
                  value: value,
                  onChanged: enabled ? onChanged : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignatureRow extends StatelessWidget {
  final String label;
  final bool captured;
  final String capturedLabel;
  final String redoLabel;
  final VoidCallback onCapture;

  const _SignatureRow({
    required this.label,
    required this.captured,
    required this.capturedLabel,
    required this.redoLabel,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    return AppCard.subtle(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s14,
        vertical: AppDimensions.s12,
      ),
      child: Row(
        children: [
          Icon(
            captured ? Icons.check_circle_rounded : Icons.draw_outlined,
            color: captured ? semantic.success.base : colors.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (captured)
                  Text(
                    capturedLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: semantic.success.base,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          AppButton.secondary(
            label: captured ? redoLabel : label,
            isExpanded: false,
            height: 40,
            leadingIcon: captured ? Icons.refresh_rounded : Icons.draw_outlined,
            onPressed: onCapture,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? secondary;
  final bool empty;

  const _SummaryRow({
    required this.icon,
    required this.title,
    required this.value,
    this.secondary,
    this.empty = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colors.onSurfaceVariant),
        const SizedBox(width: AppDimensions.s10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? '—' : value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: empty ? colors.onSurfaceVariant : colors.onSurface,
                ),
              ),
              if (secondary != null && secondary!.isNotEmpty)
                Text(
                  secondary!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Uses available width without squeezing controls: fields share a row only
/// when every child can retain a practical input width; otherwise they stack.
class _ResponsiveFieldGroup extends StatelessWidget {
  static const double _spacing = 10;

  final List<Widget> children;
  final double minChildWidth;

  const _ResponsiveFieldGroup({
    required this.children,
    this.minChildWidth = 180,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final requiredWidth =
          (minChildWidth * children.length) +
          (_spacing * (children.length - 1));
      if (constraints.maxWidth < requiredWidth) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              children[index],
              if (index != children.length - 1)
                const SizedBox(height: _spacing),
            ],
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < children.length; index++) ...[
            Expanded(child: children[index]),
            if (index != children.length - 1) const SizedBox(width: _spacing),
          ],
        ],
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Find existing record
// ─────────────────────────────────────────────────────────────────────────────

class _FindExistingRecord extends StatelessWidget {
  final VehicleCustomerFormState state;
  final WidgetRef ref;
  final VoidCallback onScanVin;
  final VoidCallback onScanQr;
  const _FindExistingRecord({
    required this.state,
    required this.ref,
    required this.onScanVin,
    required this.onScanQr,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final localMatches = ref.watch(advisorVehicleMatchesProvider);
    final remoteMatches = ref.watch(advisorRemoteVehicleMatchesProvider);
    final matches = remoteMatches.value ?? localMatches;
    final notifier = ref.read(vehicleCustomerFormProvider.notifier);

    void applyMatch(VehicleMatch m) {
      notifier
        ..setCustomerName(m.customerName)
        ..setPhone(m.phoneNumber)
        ..setEmail(m.email)
        ..setVin(m.vin)
        ..setMake(m.make)
        ..setModel(m.model);
      if (m.emirate.isNotEmpty ||
          m.plateCode.isNotEmpty ||
          m.plateNumber.isNotEmpty) {
        notifier
          ..setEmirate(m.emirate)
          ..setPlateCode(m.plateCode)
          ..setPlateNumber(m.plateNumber);
      }
      if (m.registrationNumber.isNotEmpty) {
        notifier.setRegistrationNumber(m.registrationNumber);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSearchField(
          hintText: t.advisorIntakeFindHint,
          onChanged: notifier.setCustomerSearch,
        ),
        if (matches.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.s12),
          for (final m in matches)
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.s6),
              child: AppCard.interactive(
                onTap: () => applyMatch(m),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.s12,
                  vertical: AppDimensions.s10,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_search_outlined,
                      size: 18,
                      color: colors.primary,
                    ),
                    const SizedBox(width: AppDimensions.s10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.customerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            [m.registrationNumber, m.phoneNumber]
                                .where((v) => v.isNotEmpty)
                                .join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.ltr,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.add_circle_outline,
                      size: 18,
                      color: colors.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
        const SizedBox(height: AppDimensions.s12),
        LayoutBuilder(
          builder: (context, constraints) {
            final buttons = [
              AppButton.secondary(
                label: t.advisorIntakeScanVin,
                leadingIcon: Icons.document_scanner_outlined,
                onPressed: onScanVin,
              ),
              AppButton.secondary(
                label: t.advisorIntakeScanQr,
                leadingIcon: Icons.qr_code_scanner,
                onPressed: onScanQr,
              ),
            ];
            if (constraints.maxWidth < 380) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buttons.first,
                  const SizedBox(height: AppDimensions.s10),
                  buttons.last,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: buttons.first),
                const SizedBox(width: AppDimensions.s10),
                Expanded(child: buttons.last),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Job description table
// ─────────────────────────────────────────────────────────────────────────────

class _JobDescriptionTable extends StatelessWidget {
  final VehicleCustomerFormState state;
  final WidgetRef ref;
  const _JobDescriptionTable({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final notifier = ref.read(vehicleCustomerFormProvider.notifier);
    final rows = state.jobDescriptions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < rows.length; index++)
          _row(context, t, notifier, index, rows[index]),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: notifier.addJobDescriptionRow,
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: Text(t.advisorIntakeAddDescription),
          ),
        ),
      ],
    );
  }

  Widget _row(
    BuildContext context,
    StaffLocalizations t,
    VehicleCustomerFormNotifier notifier,
    int index,
    JobDescriptionEntry row,
  ) {
    final colors = Theme.of(context).colorScheme;
    return AppCard.subtle(
      padding: const EdgeInsets.all(AppDimensions.s12),
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.s8),
                Expanded(
                  child: Text(
                    t.advisorIntakeJobDescription,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (state.jobDescriptions.length > 1)
                  IconButton(
                    tooltip: t.advisorIntakeRemoveRow,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => notifier.removeJobDescriptionRow(index),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.s6),
            _RichDescriptionEditor(
              key: ValueKey('job-desc-$index'),
              hint: t.advisorIntakeDescriptionHint,
              boldTooltip: t.advisorIntakeBold,
              italicTooltip: t.advisorIntakeItalic,
              bulletTooltip: t.advisorIntakeBullet,
              value: row.description,
              onChanged: (v) =>
                  notifier.updateJobDescriptionRow(index, description: v),
            ),
            const SizedBox(height: AppDimensions.s8),
            _PrioritySelector(
              label: t.advisorIntakePriority,
              tooltip: t.advisorIntakeSelectPriority,
              value: row.priority,
              onChanged: (v) =>
                  notifier.updateJobDescriptionRow(index, priority: v),
            ),
            const SizedBox(height: AppDimensions.s10),
            Text(
              t.advisorIntakeAttachments,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: AppDimensions.s6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _attachmentButton(
                  t,
                  Icons.add_photo_alternate_outlined,
                  t.advisorIntakePhotos,
                  row.photoPaths.length,
                  () => _pickPhotos(context, notifier, index),
                ),
                _attachmentButton(
                  t,
                  Icons.video_call_outlined,
                  t.advisorIntakeVideo,
                  row.videoPaths.length,
                  () => _pickVideo(context, notifier, index),
                ),
                _attachmentButton(
                  t,
                  Icons.mic_none_rounded,
                  t.advisorIntakeAudio,
                  row.audioPath.isEmpty ? 0 : 1,
                  () => _recordAudio(context, t, notifier, index, row),
                ),
              ],
            ),
            if (row.photoPaths.isNotEmpty || row.videoPaths.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.s10),
              _MediaThumbnailGrid(
                photoPaths: row.photoPaths,
                videoPaths: row.videoPaths,
                onRemovePhoto: (i) =>
                    notifier.removeJobDescriptionMedia(index, 'photo', i),
                onRemoveVideo: (i) =>
                    notifier.removeJobDescriptionMedia(index, 'video', i),
              ),
            ],
            if (row.audioPath.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.s8),
              InputChip(
                avatar: const Icon(Icons.audiotrack_rounded, size: 18),
                label: Text(
                  row.audioPath.split(RegExp(r'[/\\]')).last,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onDeleted: () =>
                    notifier.removeJobDescriptionMedia(index, 'audio', 0),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _attachmentButton(
    StaffLocalizations t,
    IconData icon,
    String label,
    int count,
    VoidCallback onPressed,
  ) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 18),
    label: Text(
      count == 0 ? label : t.advisorIntakeCount(label, count),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );

  Future<String> _persistAttachment(XFile file, String prefix) async {
    final dir = await getApplicationDocumentsDirectory();
    final dot = file.path.lastIndexOf('.');
    final extension = dot < 0 ? '' : file.path.substring(dot);
    return persistMediaFile(
      file.path,
      '${dir.path}/${prefix}_${DateTime.now().microsecondsSinceEpoch}$extension',
    );
  }

  Future<void> _pickPhotos(
    BuildContext context,
    VehicleCustomerFormNotifier notifier,
    int index,
  ) async {
    try {
      final files = await ImagePicker().pickMultiImage(imageQuality: 85);
      final paths = <String>[];
      for (final file in files) {
        paths.add(await _persistAttachment(file, 'job_description_photo'));
      }
      notifier.addJobDescriptionPhotos(index, paths);
    } catch (error) {
      if (context.mounted) _showAttachmentError(context, error);
    }
  }

  Future<void> _pickVideo(
    BuildContext context,
    VehicleCustomerFormNotifier notifier,
    int index,
  ) async {
    try {
      final file = await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (file == null) return;
      notifier.addJobDescriptionVideo(
        index,
        await _persistAttachment(file, 'job_description_video'),
      );
    } catch (error) {
      if (context.mounted) _showAttachmentError(context, error);
    }
  }

  void _recordAudio(
    BuildContext context,
    StaffLocalizations t,
    VehicleCustomerFormNotifier notifier,
    int index,
    JobDescriptionEntry row,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => _JobDescriptionAudioDialog(
        title: t.advisorIntakeAudioTitle,
        itemId: 'job-description-${index + 1}',
        hasExisting: row.audioPath.isNotEmpty,
        onSaved: (path) => notifier.setJobDescriptionAudio(index, path),
      ),
    );
  }

  void _showAttachmentError(BuildContext context, Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          StaffLocalizations.of(
            context,
          )!.advisorIntakeAttachmentError('$error'),
        ),
      ),
    );
  }
}

class _JobDescriptionAudioDialog extends StatefulWidget {
  final String title;
  final String itemId;
  final bool hasExisting;
  final ValueChanged<String> onSaved;

  const _JobDescriptionAudioDialog({
    required this.title,
    required this.itemId,
    required this.hasExisting,
    required this.onSaved,
  });

  @override
  State<_JobDescriptionAudioDialog> createState() =>
      _JobDescriptionAudioDialogState();
}

class _JobDescriptionAudioDialogState
    extends State<_JobDescriptionAudioDialog> {
  final AudioRecorderService _recorder = AudioRecorderService();
  Timer? _timer;
  bool _recording = false;
  int _seconds = 0;

  @override
  void dispose() {
    _timer?.cancel();
    if (_recording) _recorder.stopRecording();
    super.dispose();
  }

  Future<void> _start() async {
    final permission = await Permission.microphone.request();
    if (!permission.isGranted) return;
    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/audio_${widget.itemId}_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final started = await _recorder.startRecording(path);
    if (!started || !mounted) return;
    setState(() {
      _recording = true;
      _seconds = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_recording) return;
      setState(() => _seconds++);
      if (_seconds >= 60) _stop();
    });
  }

  Future<void> _stop() async {
    _timer?.cancel();
    final path = await _recorder.stopRecording();
    if (!mounted) return;
    setState(() => _recording = false);
    if (path != null && path.isNotEmpty) {
      widget.onSaved(path);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _recording
                ? t.advisorIntakeAudioRecording(_seconds)
                : widget.hasExisting
                ? t.advisorIntakeAudioReplace
                : t.advisorIntakeAudioPrompt,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.s18),
          IconButton.filled(
            onPressed: _recording ? _stop : _start,
            icon: Icon(_recording ? Icons.stop_rounded : Icons.mic_rounded),
            style: IconButton.styleFrom(
              backgroundColor: _recording ? colors.error : colors.primary,
              foregroundColor: _recording
                  ? colors.onError
                  : colors.onPrimary,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _recording ? null : () => Navigator.pop(context),
          child: Text(SharedCoreL10n.of(context).commonCancel),
        ),
      ],
    );
  }
}

class _PrioritySelector extends StatelessWidget {
  final String label;
  final String tooltip;
  final String value;
  final ValueChanged<String> onChanged;

  const _PrioritySelector({
    required this.label,
    required this.tooltip,
    required this.value,
    required this.onChanged,
  });

  Color _colorFor(String priority, AppSemanticColors semantic) {
    if (priority.startsWith('Red:')) return semantic.danger.base;
    if (priority.startsWith('Yellow:')) return semantic.warning.base;
    return semantic.success.base;
  }

  String _detailFor(String priority) {
    final separator = priority.indexOf(':');
    return separator < 0 ? priority : priority.substring(separator + 1).trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semanticColors;
    return PopupMenuButton<String>(
      initialValue: value,
      tooltip: tooltip,
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 340),
      onOpened: () => FocusManager.instance.primaryFocus?.unfocus(),
      onSelected: onChanged,
      itemBuilder: (context) => kJobPriorities
          .map(
            (priority) => PopupMenuItem<String>(
              value: priority,
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _colorFor(priority, semantic),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          priority.split(':').first,
                          style: theme.textTheme.labelLarge,
                        ),
                        Text(
                          _detailFor(priority),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (priority == value)
                    Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
            ),
          )
          .toList(),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _colorFor(value, semantic),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppDimensions.s10),
            Expanded(
              child: Text(
                _detailFor(value),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small rich-text editor for the job description with a formatting toolbar
/// (bold, italic, bullet list). Formatting is stored as lightweight markdown.
class _RichDescriptionEditor extends StatefulWidget {
  final String hint;
  final String boldTooltip;
  final String italicTooltip;
  final String bulletTooltip;
  final String value;
  final ValueChanged<String> onChanged;
  const _RichDescriptionEditor({
    super.key,
    required this.hint,
    required this.boldTooltip,
    required this.italicTooltip,
    required this.bulletTooltip,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_RichDescriptionEditor> createState() => _RichDescriptionEditorState();
}

/// Paints markdown emphasis (bold/italic) while keeping the raw offsets intact,
/// so the caret never drifts. Markers stay in the text but are dimmed.
class _MarkdownEditingController extends TextEditingController {
  _MarkdownEditingController({super.text});

  static final RegExp _pattern = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*');

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final raw = text;
    final base = style ?? const TextStyle();
    final dimmed = base.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
    );
    final children = <TextSpan>[];
    var cursor = 0;
    for (final match in _pattern.allMatches(raw)) {
      if (match.start > cursor) {
        children.add(TextSpan(text: raw.substring(cursor, match.start)));
      }
      final bold = match.group(1) != null;
      final inner = (bold ? match.group(1) : match.group(2)) ?? '';
      final marker = bold ? '**' : '*';
      children.add(TextSpan(text: marker, style: dimmed));
      children.add(
        TextSpan(
          text: inner,
          style: base.copyWith(
            fontWeight: bold ? FontWeight.w800 : base.fontWeight,
            fontStyle: bold ? base.fontStyle : FontStyle.italic,
          ),
        ),
      );
      children.add(TextSpan(text: marker, style: dimmed));
      cursor = match.end;
    }
    if (cursor < raw.length) {
      children.add(TextSpan(text: raw.substring(cursor)));
    }
    return TextSpan(style: base, children: children);
  }
}

class _RichDescriptionEditorState extends State<_RichDescriptionEditor> {
  late final _MarkdownEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _MarkdownEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _RichDescriptionEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  void _emit() => widget.onChanged(_controller.text);

  void _wrapSelection(String marker) {
    final text = _controller.text;
    final selection = _controller.selection;
    if (!selection.isValid || selection.isCollapsed) {
      final at = selection.isValid ? selection.start : text.length;
      _controller.value = TextEditingValue(
        text: text.substring(0, at) + marker + marker + text.substring(at),
        selection: TextSelection.collapsed(offset: at + marker.length),
      );
    } else {
      final selected = text.substring(selection.start, selection.end);
      final wrapped =
          selected.length >= marker.length * 2 &&
          selected.startsWith(marker) &&
          selected.endsWith(marker);
      final replacement = wrapped
          ? selected.substring(marker.length, selected.length - marker.length)
          : '$marker$selected$marker';
      _controller.value = TextEditingValue(
        text:
            text.substring(0, selection.start) +
            replacement +
            text.substring(selection.end),
        selection: TextSelection.collapsed(
          offset: selection.start + replacement.length,
        ),
      );
    }
    _emit();
  }

  void _toggleBullet() {
    final text = _controller.text;
    final selection = _controller.selection;
    final at = selection.isValid ? selection.start : text.length;
    final lineStart = text.lastIndexOf('\n', at > 0 ? at - 1 : 0) + 1;
    final rawEnd = text.indexOf('\n', at);
    final lineEnd = rawEnd == -1 ? text.length : rawEnd;
    final line = text.substring(lineStart, lineEnd);
    final newLine = line.startsWith('• ')
        ? line.substring(2)
        : (line.trim().isEmpty ? '• ' : '• $line');
    _controller.value = TextEditingValue(
      text: text.substring(0, lineStart) + newLine + text.substring(lineEnd),
      selection: TextSelection.collapsed(offset: lineStart + newLine.length),
    );
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.s4,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.outline)),
            ),
            child: Row(
              children: [
                _tool(
                  Icons.format_bold,
                  widget.boldTooltip,
                  () => _wrapSelection('**'),
                ),
                _tool(
                  Icons.format_italic,
                  widget.italicTooltip,
                  () => _wrapSelection('*'),
                ),
                _tool(
                  Icons.format_list_bulleted,
                  widget.bulletTooltip,
                  _toggleBullet,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.s12,
              vertical: AppDimensions.s6,
            ),
            child: TextField(
              controller: _controller,
              maxLines: null,
              minLines: 4,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              textCapitalization: TextCapitalization.sentences,
              scrollPadding: const EdgeInsets.only(bottom: 180),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              onChanged: (_) => _emit(),
              style: TextStyle(
                fontSize: 13,
                color: colors.onSurface,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tool(IconData icon, String tooltip, VoidCallback onTap) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 18,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _MediaAddTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String addLabel;
  final int count;
  final VoidCallback onTap;
  const _MediaAddTile({
    required this.icon,
    required this.label,
    required this.addLabel,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final active = count > 0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
      child: Container(
        constraints: const BoxConstraints(minHeight: AppDimensions.touchTarget),
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.s14),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          border: Border.all(
            color: active ? colors.primary : colors.outline,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: active ? colors.primary : colors.onSurfaceVariant,
            ),
            const SizedBox(height: AppDimensions.s6),
            Text(
              count == 0 ? addLabel : '$label ($count)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: active ? colors.primary : colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaThumbnailGrid extends StatelessWidget {
  final List<String> photoPaths;
  final List<String> videoPaths;
  final ValueChanged<int> onRemovePhoto;
  final ValueChanged<int> onRemoveVideo;
  const _MediaThumbnailGrid({
    required this.photoPaths,
    required this.videoPaths,
    required this.onRemovePhoto,
    required this.onRemoveVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var i = 0; i < photoPaths.length; i++)
          _thumb(
            context,
            photoPaths[i],
            isVideo: false,
            onRemove: () => onRemovePhoto(i),
          ),
        for (var i = 0; i < videoPaths.length; i++)
          _thumb(
            context,
            videoPaths[i],
            isVideo: true,
            onRemove: () => onRemoveVideo(i),
          ),
      ],
    );
  }

  Widget _thumb(
    BuildContext context,
    String path, {
    required bool isVideo,
    required VoidCallback onRemove,
  }) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
            child: isVideo
                ? Container(
                    width: 84,
                    height: 84,
                    color: colors.surfaceContainerLow,
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 30,
                      color: colors.onSurface,
                    ),
                  )
                : (File(path).existsSync()
                      ? Image.file(
                          File(path),
                          width: 84,
                          height: 84,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 84,
                          height: 84,
                          color: colors.surfaceContainerLow,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: colors.onSurfaceVariant,
                          ),
                        )),
          ),
          if (isVideo)
            const Positioned(
              bottom: 4,
              left: 4,
              // FIXED-INK: legibility glyph over user video thumbnails.
              child: Icon(
                Icons.videocam,
                size: 14,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
              ),
            ),
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: colors.error,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 12, color: colors.onError),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FuelLevelSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _FuelLevelSlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final semantic = context.semanticColors;
    final low = value < 4;
    final ink = low ? semantic.danger.base : semantic.warning.base;
    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(10, (i) {
              final isFilled = i < value;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(i + 1),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    height: 28,
                    decoration: BoxDecoration(
                      color: isFilled ? colors.primary : colors.outline,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: AppDimensions.s8),
        GestureDetector(
          onTap: () => onChanged(value.clamp(1, 10)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_gas_station, color: ink, size: 22),
              Text(
                '$value/10',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
