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
import 'package:staff_app/features/advisor/presentation/widgets/vehicle_customer_shared_widgets.dart';
import 'package:staff_app/features/advisor/presentation/widgets/select_brand_sheet.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_workflow_indicator.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_signature_pad.dart';
import 'package:staff_app/features/advisor/data/models/vehicle_customer_model.dart';
import 'scan_vehicle_view.dart';
import 'package:staff_app/features/advisor/inspection_pages/presentation/vehicle_map/vehicle_body_condition_panel.dart';

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
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _fieldKeys = {
    'Customer Name': GlobalKey(),
    'Phone Number': GlobalKey(),
    'Plate Number': GlobalKey(),
    'Make': GlobalKey(),
    'Model': GlobalKey(),
  };
  Map<String, String> _fieldErrors = const {};
  String? _savedJobId;
  bool _savedToServer = false;
  XFile? _registrationDocument;
  XFile? _insuranceDocument;
  final List<String> _jobPhotoPaths = [];
  final List<String> _jobVideoPaths = [];
  String _customerSignaturePath = '';
  String _advisorSignaturePath = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(inspectionProvider.notifier).reset());
    if (widget.bookingId != null && widget.bookingId!.isNotEmpty) {
      Hive.box<dynamic>(
        'inspections',
      ).put('intake_booking_id', widget.bookingId);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final state = ref.watch(vehicleCustomerFormProvider);
    // The keyboard is open when the view insets are non-zero. While typing we
    // hide the bottom action bar so it never covers fields or fights the IME.
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Vehicle & Customer Job Card',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AdvisorWorkflowIndicator(currentStep: 0),
                  const SizedBox(height: 16),
                  // ── Hint text ───────────────────────────────────────────
                  Text(
                    'Type VIN / License Plate / Customer Name. If vehicle is not found, enter new vehicle details below.',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  if (widget.bookingId != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppDimensions.r12),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.event_available_rounded,
                            color: colorScheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Job card from the assigned booking — it will be linked to this job card.',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // ── Search mode (Image 1) ────────────────────────────────
                  _SearchModeSection(
                    state: state,
                    ref: ref,
                    onScanVin: () => _scanAndSetVin(context, ref),
                    onScanQr: () => _scanVehicleQr(context, ref),
                  ),
                  const SizedBox(height: 16),

                  // ── Customer Details (Images 3-5) ────────────────────────
                  _CustomerDetailsSection(
                    state: state,
                    ref: ref,
                    errors: _fieldErrors,
                    fieldKeys: _fieldKeys,
                    onFieldChanged: _clearFieldError,
                  ),

                  // ── Vehicle Details (Images 6-14) ────────────────────────
                  _VehicleDetailsSection(
                    state: state,
                    ref: ref,
                    onScanVin: () => _scanAndSetVin(context, ref),
                    registrationDocumentName: _registrationDocument?.name,
                    insuranceDocumentName: _insuranceDocument?.name,
                    onRegistrationUpload: () => _pickDocument(true),
                    onInsuranceUpload: () => _pickDocument(false),
                    errors: _fieldErrors,
                    fieldKeys: _fieldKeys,
                    onFieldChanged: _clearFieldError,
                  ),

                  // ── Additional Information (Image 15) ────────────────────
                  const SizedBox(height: 16),
                  Text(
                    'Vehicle Body Condition',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const VehicleBodyConditionPanel(
                    embedded: true,
                    showTitle: false,
                  ),
                  const SizedBox(height: 16),

                  _AdditionalInfoSection(
                    state: state,
                    ref: ref,
                    photoPaths: List<String>.from(_jobPhotoPaths),
                    videoPaths: List<String>.from(_jobVideoPaths),
                    hasCustomerSignature: _customerSignaturePath.isNotEmpty,
                    hasAdvisorSignature: _advisorSignaturePath.isNotEmpty,
                    onAddPhotos: _pickJobPhotos,
                    onAddVideo: _pickJobVideo,
                    onRemovePhoto: (i) =>
                        setState(() => _jobPhotoPaths.removeAt(i)),
                    onRemoveVideo: (i) =>
                        setState(() => _jobVideoPaths.removeAt(i)),
                    onCustomerSignature: () => _captureSignature(true),
                    onAdvisorSignature: () => _captureSignature(false),
                  ),
                ],
              ),
            ),
          ),

          // ── NEXT button (a real bar, not an overlay, so it never collides
          // with the keyboard or the last fields) ────────────────────────────
          if (!keyboardOpen)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
              child: SafeArea(
                top: false,
                child: ElevatedButton(
                  onPressed: () async {
                    final formState = ref.read(vehicleCustomerFormProvider);
                    final bodyCondition = ref
                        .read(inspectionProvider)
                        .vehicleBodyConditionPayload;
                    final errors = _validateForm(formState);
                    if (errors.isNotEmpty) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() => _fieldErrors = Map.fromEntries(errors));
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        final firstContext =
                            _fieldKeys[errors.first.key]?.currentContext;
                        if (firstContext != null) {
                          Scrollable.ensureVisible(
                            firstContext,
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeOutCubic,
                            alignment: 0.18,
                          );
                        }
                      });
                      return;
                    }
                    if (_fieldErrors.isNotEmpty) {
                      setState(() => _fieldErrors = const {});
                    }
                    final local = GenericLocalDataSource(
                      Hive.box<dynamic>('inspections'),
                    );
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
                        for (
                          var i = 0;
                          i < formState.jobDescriptions.length;
                          i++
                        )
                          {
                            ...formState.jobDescriptions[i].toJson(),
                            'mediaItemId': 'job-description-${i + 1}',
                          },
                      ],
                      'jobDescriptionMedia': [
                        for (
                          var i = 0;
                          i < formState.jobDescriptions.length;
                          i++
                        ) ...[
                          for (final path
                              in formState.jobDescriptions[i].photoPaths)
                            {
                              'path': path,
                              'itemId': 'job-description-${i + 1}',
                              'type': 'photo',
                            },
                          for (final path
                              in formState.jobDescriptions[i].videoPaths)
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
                      'registrationDocumentPath':
                          _registrationDocument?.path ?? '',
                      'insuranceDocumentPath': _insuranceDocument?.path ?? '',
                      'status': 'inProgress',
                      'createdDate': createdDate,
                      'lastUpdated': createdDate,
                    };
                    await local.save(id, payload);
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
                    // Prefer the server-assigned job card reference once the
                    // intake has synced so the follow-up inspection links to the
                    // exact job card the backend created.
                    var resolvedJobId = id;
                    var savedToServer = false;
                    try {
                      final record = Hive.box<dynamic>('inspections').get(id);
                      if (record is Map) {
                        final ref =
                            (record['jobCardRef'] ??
                                    record['serverJobCardId'] ??
                                    '')
                                .toString();
                        if (ref.isNotEmpty) {
                          resolvedJobId = ref;
                          savedToServer = true;
                        }
                      }
                    } catch (_) {}
                    _savedJobId = resolvedJobId;
                    _savedToServer = savedToServer;
                    ref.read(advisorRefreshProvider.notifier).state++;
                    if (!context.mounted) return;
                    _showInspectionPrompt(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppDimensions.r10),
                      ),
                    ),
                  ),
                  child: const Text(
                    'CREATE JOB CARD',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<MapEntry<String, String>> _validateForm(VehicleCustomerFormState s) {
    final errors = <MapEntry<String, String>>[];
    if (s.customerName.trim().isEmpty) {
      errors.add(
        const MapEntry('Customer Name', 'Please enter the customer name'),
      );
    }
    if (s.phoneNumber.trim().isEmpty) {
      errors.add(
        const MapEntry('Phone Number', 'Please enter a mobile number'),
      );
    } else if (s.phoneNumber.trim().length < 8) {
      errors.add(
        const MapEntry('Phone Number', 'Please enter a valid mobile number'),
      );
    }
    if (s.plateNumber.trim().isEmpty) {
      errors.add(
        const MapEntry('Plate Number', 'Please enter the plate number'),
      );
    }
    if (s.make.trim().isEmpty) {
      errors.add(const MapEntry('Make', 'Please select the vehicle brand'));
    }
    if (s.model.trim().isEmpty) {
      errors.add(const MapEntry('Model', 'Please select the vehicle model'));
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
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                registration
                    ? 'Add registration certificate'
                    : 'Add insurance document',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.pop(context, ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Take a photo'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context, ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Choose from gallery'),
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
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: const Text('Record video'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.video_library_outlined),
              title: const Text('Choose video'),
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
    final title = customer ? 'Customer Signature' : 'Advisor Signature';
    final bytes = await showModalBottomSheet<Uint8List>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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

  void _showInspectionPrompt(BuildContext context) {
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
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.r16),
              ),
              child: Icon(
                _savedToServer
                    ? Icons.cloud_done_outlined
                    : Icons.cloud_upload_outlined,
                color: AppColors.accent,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _savedToServer
                  ? 'Job Card Created & Synced'
                  : 'Job Card Saved Locally',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _savedToServer
                  ? 'Saved to this device and the server.\nWould you like to start the inspection?'
                  : 'The API could not be reached. The job card is safely stored and queued for automatic sync.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.text2,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
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
                icon: const Icon(Icons.search_outlined, size: 20),
                label: const Text(
                  'Add Inspection',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.r14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (context.mounted) context.pop();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text3,
                  side: const BorderSide(color: AppColors.line),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.r14),
                  ),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SEARCH MODE SECTION (Image 1)
// ─────────────────────────────────────────────────────────────────────────────
class _SearchModeSection extends StatelessWidget {
  final VehicleCustomerFormState state;
  final WidgetRef ref;
  final VoidCallback onScanVin;
  final VoidCallback onScanQr;
  const _SearchModeSection({
    required this.state,
    required this.ref,
    required this.onScanVin,
    required this.onScanQr,
  });

  @override
  Widget build(BuildContext context) {
    final localMatches = ref.watch(advisorVehicleMatchesProvider);
    final remoteMatches = ref.watch(advisorRemoteVehicleMatchesProvider);
    final matches = remoteMatches.value ?? localMatches;
    final notifier = ref.read(vehicleCustomerFormProvider.notifier);

    void applyMatch(VehicleMatch m) {
      notifier
        ..setCustomerName(m.customerName)
        ..setPhone(m.phoneNumber)
        ..setEmail(m.email)
        ..setRegistrationNumber(m.registrationNumber)
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
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => ref
                .read(vehicleCustomerFormProvider.notifier)
                .setCustomerSearch(v),
            textInputAction: TextInputAction.search,
            textCapitalization: TextCapitalization.words,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            decoration: InputDecoration(
              hintText: 'Mobile, customer name, plate number, or VIN',
              hintStyle: const TextStyle(color: kHintColor, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: kHintColor, size: 18),
              filled: true,
              fillColor: kFieldBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(AppDimensions.r10),
                ),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
          if (matches.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...matches.map(
              (m) => InkWell(
                onTap: () => applyMatch(m),
                borderRadius: BorderRadius.circular(AppDimensions.r8),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: kTealLight,
                    borderRadius: BorderRadius.circular(AppDimensions.r8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_search_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.customerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: kTextColor,
                              ),
                            ),
                            Text(
                              [
                                m.registrationNumber,
                                m.phoneNumber,
                              ].where((value) => value.isNotEmpty).join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.text3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.add_circle_outline,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'OR',
              style: TextStyle(
                color: AppColors.text3,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // SCAN VIN
          _OutlineButton(
            icon: Icons.qr_code,
            label: 'SCAN VIN',
            onTap: onScanVin,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'OR',
              style: TextStyle(
                color: AppColors.text3,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // SCAN VEHICLE QR CODE
          _OutlineButton(
            icon: Icons.qr_code_scanner,
            label: 'SCAN VEHICLE QR CODE',
            onTap: onScanQr,
          ),
        ],
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OutlineButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _LabeledControl extends StatelessWidget {
  final String label;
  final bool required;
  final Widget child;
  final String? errorText;

  const _LabeledControl({
    required this.label,
    required this.child,
    this.required = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FieldLabel(label, required: required),
      child,
      if (errorText != null) ...[
        const SizedBox(height: 6),
        Text(
          errorText!,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ],
  );
}

/// Uses available width without squeezing controls. Fields share a row only
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

//  CUSTOMER DETAILS (Images 3-5)
// ─────────────────────────────────────────────────────────────────────────────
class _CustomerDetailsSection extends StatelessWidget {
  final VehicleCustomerFormState state;
  final WidgetRef ref;
  final Map<String, String> errors;
  final Map<String, GlobalKey> fieldKeys;
  final ValueChanged<String> onFieldChanged;
  const _CustomerDetailsSection({
    required this.state,
    required this.ref,
    required this.errors,
    required this.fieldKeys,
    required this.onFieldChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Customer Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdvisorToggleTile(
            label: 'B2B Customer',
            value: state.isB2B,
            onChanged: (v) =>
                ref.read(vehicleCustomerFormProvider.notifier).setB2B(v),
          ),
          kGap12,

          FieldLabel('Customer Name', required: true),
          AdvisorTextField(
            key: fieldKeys['Customer Name'],
            hint: 'Customer Name',
            errorText: errors['Customer Name'],
            textCapitalization: TextCapitalization.words,
            onChanged: (v) {
              ref.read(vehicleCustomerFormProvider.notifier).setCustomerName(v);
              if (v.trim().isNotEmpty) onFieldChanged('Customer Name');
            },
          ),
          kGap12,

          FieldLabel('Phone Number', required: true),
          AdvisorTextField(
            key: fieldKeys['Phone Number'],
            hint: 'Phone number',
            errorText: errors['Phone Number'],
            keyboardType: TextInputType.phone,
            // prefixIcon (not prefix) so the country code is ALWAYS visible,
            // not only while the field is focused.
            prefix: _CountryCodePrefix(
              code: PhoneInputField.countries.first.code,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) {
              ref.read(vehicleCustomerFormProvider.notifier).setPhone(v);
              if (v.trim().length >= 8) onFieldChanged('Phone Number');
            },
          ),
          kGap12,

          const FieldLabel('Email Address'),
          AdvisorTextField(
            hint: 'Email',
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) =>
                ref.read(vehicleCustomerFormProvider.notifier).setEmail(v),
          ),
          kGap12,

          const FieldLabel('Customer Group'),
          AdvisorDropdown(
            hint: 'Select Customer Group',
            value: state.customerGroup,
            items: kCustomerGroups,
            onChanged: (v) => ref
                .read(vehicleCustomerFormProvider.notifier)
                .setCustomerGroup(v),
          ),
          kGap12,

          if (state.showMoreCustomer) ...[
            kGap12,
            const FieldLabel('Gender'),
            AdvisorDropdown(
              hint: 'Select Gender',
              value: state.gender,
              items: kGenders,
              onChanged: (v) =>
                  ref.read(vehicleCustomerFormProvider.notifier).setGender(v),
            ),
            kGap12,

            const FieldLabel('Address'),
            AdvisorDropdown(
              hint: 'Address',
              value: state.address,
              items: kAddresses,
              onChanged: (v) =>
                  ref.read(vehicleCustomerFormProvider.notifier).setAddress(v),
            ),
            kGap12,

            const FieldLabel('Tax Number'),
            AdvisorTextField(
              hint: 'Tax Number',
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setTaxNumber(v),
            ),
            kGap12,

            const FieldLabel('Source'),
            AdvisorTextField(
              hint: 'How did you come to know abo...',
              onChanged: (v) =>
                  ref.read(vehicleCustomerFormProvider.notifier).setSource(v),
            ),
          ],

          const SizedBox(height: 8),
          MoreLessLink(
            showMore: state.showMoreCustomer,
            onTap: () => ref
                .read(vehicleCustomerFormProvider.notifier)
                .toggleCustomerMore(),
          ),
        ],
      ),
    );
  }
}

/// Always-visible inline prefix for a text field. Rendered through
/// `prefixIcon` (not `prefix`/`prefixText`, which Flutter hides until the
/// field is focused or has text) so it never disappears while typing.
class _AffixPrefix extends StatelessWidget {
  final String text;
  const _AffixPrefix(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: kTextColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(height: 20, width: 1, color: kBorderColor),
        ],
      ),
    );
  }
}

class _CountryCodePrefix extends StatelessWidget {
  final String code;
  const _CountryCodePrefix({required this.code});

  @override
  Widget build(BuildContext context) => _AffixPrefix(code);
}

class _PlatePrefix extends StatelessWidget {
  final String emirate;
  final String plateCode;
  const _PlatePrefix({required this.emirate, required this.plateCode});

  @override
  Widget build(BuildContext context) => _AffixPrefix('$emirate-$plateCode');
}

// ─────────────────────────────────────────────────────────────────────────────
//  CUSTOMER DETAILS (Images 3-5)
// ─────────────────────────────────────────────────────────────────────────────
class _VehicleDetailsSection extends StatelessWidget {
  final VehicleCustomerFormState state;
  final WidgetRef ref;
  final VoidCallback onScanVin;
  final String? registrationDocumentName;
  final String? insuranceDocumentName;
  final VoidCallback onRegistrationUpload;
  final VoidCallback onInsuranceUpload;
  final Map<String, String> errors;
  final Map<String, GlobalKey> fieldKeys;
  final ValueChanged<String> onFieldChanged;
  const _VehicleDetailsSection({
    required this.state,
    required this.ref,
    required this.onScanVin,
    required this.registrationDocumentName,
    required this.insuranceDocumentName,
    required this.onRegistrationUpload,
    required this.onInsuranceUpload,
    required this.errors,
    required this.fieldKeys,
    required this.onFieldChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Vehicle Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ResponsiveFieldGroup(
            minChildWidth: 150,
            children: [
              _LabeledControl(
                label: 'Emirate',
                child: AdvisorDropdown(
                  hint: 'Select Emirate',
                  value: state.emirate,
                  items: kEmirates,
                  onChanged: (v) => ref
                      .read(vehicleCustomerFormProvider.notifier)
                      .setEmirate(v),
                ),
              ),
              _LabeledControl(
                label: 'Plate Code',
                child: AdvisorTextField(
                  hint: 'A',
                  initialValue: state.plateCode,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                    LengthLimitingTextInputFormatter(4),
                  ],
                  onChanged: (v) => ref
                      .read(vehicleCustomerFormProvider.notifier)
                      .setPlateCode(v),
                ),
              ),
              _LabeledControl(
                label: 'Plate Number',
                required: true,
                child: AdvisorTextField(
                  key: fieldKeys['Plate Number'],
                  hint: '2500',
                  errorText: errors['Plate Number'],
                  initialValue: state.plateNumber,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  // Always-visible Emirate-PlateCode prefix, e.g. "Dubai-A".
                  prefix: (state.emirate.isEmpty && state.plateCode.isEmpty)
                      ? null
                      : _PlatePrefix(
                          emirate: state.emirate,
                          plateCode: state.plateCode,
                        ),
                  onChanged: (v) {
                    ref
                        .read(vehicleCustomerFormProvider.notifier)
                        .setPlateNumber(v);
                    if (v.trim().isNotEmpty) onFieldChanged('Plate Number');
                  },
                ),
              ),
            ],
          ),
          kGap12,

          const FieldLabel('VIN (Chasis number)'),
          AdvisorTextField(
            hint: 'VIN(Chasis number)',
            onChanged: (v) =>
                ref.read(vehicleCustomerFormProvider.notifier).setVin(v),
            suffix: GestureDetector(
              onTap: onScanVin,
              child: const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.qr_code_scanner, color: kHintColor, size: 18),
              ),
            ),
          ),
          kGap12,

          _ResponsiveFieldGroup(
            minChildWidth: 190,
            children: [
              _LabeledControl(
                label: 'Make',
                required: true,
                errorText: errors['Make'],
                child: _BrandSelector(
                  key: fieldKeys['Make'],
                  state: state,
                  ref: ref,
                  errorText: errors['Make'],
                  onSelected: () => onFieldChanged('Make'),
                ),
              ),
              _LabeledControl(
                label: 'Model',
                required: true,
                errorText: errors['Model'],
                child: _ModelSelector(
                  key: fieldKeys['Model'],
                  state: state,
                  ref: ref,
                  errorText: errors['Model'],
                  onSelected: () => onFieldChanged('Model'),
                ),
              ),
              _LabeledControl(
                label: 'Model Year',
                child: _ModelYearSelector(state: state, ref: ref),
              ),
            ],
          ),

          const SizedBox(height: 8),
          MoreLessLink(
            showMore: state.showMoreVehicle,
            onTap: () => ref
                .read(vehicleCustomerFormProvider.notifier)
                .toggleVehicleMore(),
          ),

          if (state.showMoreVehicle) ...[
            kGap12,
            const FieldLabel('Number of Cylinders'),
            AdvisorDropdown(
              hint: 'Number of Cylinders',
              value: state.cylinders,
              items: kCylinders,
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setCylinders(v),
            ),
            kGap12,

            const FieldLabel('Engine Capacity'),
            AdvisorTextField(
              hint: 'Engine Capacity',
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setEngineCapacity(v),
            ),
            kGap12,

            const FieldLabel('Vehicle Color'),
            AdvisorTextField(
              hint: 'Vehicle Color',
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setVehicleColor(v),
            ),
            kGap12,

            const FieldLabel('Fuel Type'),
            AdvisorDropdown(
              hint: 'Select Fuel Type',
              value: state.fuelType,
              items: kFuelTypes,
              onChanged: (v) =>
                  ref.read(vehicleCustomerFormProvider.notifier).setFuelType(v),
            ),
            kGap12,

            const FieldLabel('Engine number'),
            AdvisorTextField(
              hint: 'Engine number',
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setEngineNumber(v),
            ),
            kGap12,

            const FieldLabel('Registration Certificate'),
            _ImageUploadButton(
              label: registrationDocumentName ?? 'Add document',
              selected: registrationDocumentName != null,
              onTap: onRegistrationUpload,
            ),
            kGap12,
          ],

          kGap12,
          const FieldLabel('Job Category'),
          AdvisorDropdown(
            hint: 'Select Job Category',
            value: state.jobCategory,
            items: kJobCategories,
            onChanged: (v) => ref
                .read(vehicleCustomerFormProvider.notifier)
                .setJobCategory(v),
          ),
          // Insurance fields appear directly under Job Category when needed.
          if (state.jobCategory == 'Insurance') ...[
            kGap12,
            const FieldLabel('Insurance Name'),
            AdvisorDropdown(
              hint: 'Insurance Name',
              value: state.insuranceProvider,
              items: kInsuranceProviders,
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setInsuranceProvider(v),
            ),
            kGap12,
            const FieldLabel('LPO Number'),
            AdvisorTextField(
              hint: 'LPO Number',
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setLpoNumber(v),
            ),
            kGap12,
            const FieldLabel('Policy Number'),
            AdvisorTextField(
              hint: 'Policy Number',
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setPolicyNumber(v),
            ),
            kGap12,
            const FieldLabel('Accident Number'),
            AdvisorTextField(
              hint: 'Accident Number',
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setAccidentNumber(v),
            ),
            kGap12,
            const FieldLabel('Insurance Tax Number'),
            AdvisorTextField(
              hint: 'Enter Insurance Tax number',
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setInsuranceTaxNumber(v),
            ),
            kGap12,
            const FieldLabel('Insurance Address'),
            AdvisorTextField(
              hint: 'Insurance Address',
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setInsuranceAddress(v),
            ),
            kGap12,
            const FieldLabel('Insurance Expiry Date'),
            _DateField(
              value: state.insuranceExpiryDate,
              onChanged: (v) => ref
                  .read(vehicleCustomerFormProvider.notifier)
                  .setInsuranceExpiry(v),
            ),
            kGap12,
            const FieldLabel('Insurance Document'),
            _ImageUploadButton(
              label: insuranceDocumentName ?? 'Add document',
              selected: insuranceDocumentName != null,
              onTap: onInsuranceUpload,
            ),
          ],
          kGap12,
          _ResponsiveFieldGroup(
            minChildWidth: 200,
            children: [
              _LabeledControl(
                label: 'Markup Type',
                child: AdvisorTextField(
                  hint: 'Markup Type',
                  onChanged: (v) => ref
                      .read(vehicleCustomerFormProvider.notifier)
                      .setMarkupType(v),
                ),
              ),
              _LabeledControl(
                label: 'Order Type',
                child: AdvisorTextField(
                  hint: 'Order Type',
                  onChanged: (v) => ref
                      .read(vehicleCustomerFormProvider.notifier)
                      .setOrderType(v),
                ),
              ),
            ],
          ),
          // Job Description sits last, right before Additional Information.
          kGap12,
          const FieldLabel('Job Description'),
          _JobDescriptionTable(state: state, ref: ref),
        ],
      ),
    );
  }
}

class _BrandSelector extends StatelessWidget {
  final VehicleCustomerFormState state;
  final WidgetRef ref;
  final String? errorText;
  final VoidCallback onSelected;
  const _BrandSelector({
    super.key,
    required this.state,
    required this.ref,
    required this.errorText,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child: SelectBrandSheet(selected: state.make),
          ),
        );
        if (result != null) {
          ref.read(vehicleCustomerFormProvider.notifier).setMake(result);
          onSelected();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: state.make.isEmpty ? kFieldBg : kTealLight,
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
          border: errorText == null
              ? null
              : Border.all(color: Theme.of(context).colorScheme.error),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                state.make.isEmpty ? 'Select Brand' : state.make,
                style: TextStyle(
                  fontSize: 13,
                  color: state.make.isEmpty ? kHintColor : kTextColor,
                  fontWeight: state.make.isEmpty
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: kHintColor, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ModelSelector extends StatelessWidget {
  final VehicleCustomerFormState state;
  final WidgetRef ref;
  final String? errorText;
  final VoidCallback onSelected;
  const _ModelSelector({
    super.key,
    required this.state,
    required this.ref,
    required this.errorText,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (state.make.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a brand first')),
          );
          return;
        }
        final result = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child: SelectModelSheet(brand: state.make, selected: state.model),
          ),
        );
        if (result != null) {
          ref.read(vehicleCustomerFormProvider.notifier).setModel(result);
          onSelected();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: state.model.isEmpty ? kFieldBg : kTealLight,
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
          border: errorText == null
              ? null
              : Border.all(color: Theme.of(context).colorScheme.error),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                state.model.isEmpty ? 'Select Model' : state.model,
                style: TextStyle(
                  fontSize: 13,
                  color: state.model.isEmpty ? kHintColor : kTextColor,
                  fontWeight: state.model.isEmpty
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: kHintColor, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ModelYearSelector extends StatelessWidget {
  final VehicleCustomerFormState state;
  final WidgetRef ref;
  const _ModelYearSelector({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await showModelYearDialog(context, state.modelYear);
        if (result != null) {
          ref.read(vehicleCustomerFormProvider.notifier).setModelYear(result);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: state.modelYear.isEmpty ? kFieldBg : kTealLight,
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                state.modelYear.isEmpty ? 'Select Model Year' : state.modelYear,
                style: TextStyle(
                  fontSize: 13,
                  color: state.modelYear.isEmpty ? kHintColor : kTextColor,
                  fontWeight: state.modelYear.isEmpty
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: kHintColor, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ImageUploadButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ImageUploadButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        alignment: Alignment.centerLeft,
      ),
      icon: Icon(
        selected ? Icons.check_circle_rounded : Icons.add_a_photo_outlined,
        color: selected ? AppColors.success : AppColors.primary,
      ),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: selected ? AppColors.textPrimary : AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ADDITIONAL INFORMATION (Image 15)
// ─────────────────────────────────────────────────────────────────────────────
class _AdditionalInfoSection extends StatelessWidget {
  final VehicleCustomerFormState state;
  final WidgetRef ref;
  final List<String> photoPaths;
  final List<String> videoPaths;
  final bool hasCustomerSignature;
  final bool hasAdvisorSignature;
  final VoidCallback onAddPhotos;
  final VoidCallback onAddVideo;
  final ValueChanged<int> onRemovePhoto;
  final ValueChanged<int> onRemoveVideo;
  final VoidCallback onCustomerSignature;
  final VoidCallback onAdvisorSignature;

  const _AdditionalInfoSection({
    required this.state,
    required this.ref,
    required this.photoPaths,
    required this.videoPaths,
    required this.hasCustomerSignature,
    required this.hasAdvisorSignature,
    required this.onAddPhotos,
    required this.onAddVideo,
    required this.onRemovePhoto,
    required this.onRemoveVideo,
    required this.onCustomerSignature,
    required this.onAdvisorSignature,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Additional Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldLabel('Odometer Reading(in Kms)'),
          AdvisorTextField(
            hint: 'Odometer (in Kms)',
            keyboardType: TextInputType.number,
            onChanged: (v) =>
                ref.read(vehicleCustomerFormProvider.notifier).setOdometer(v),
          ),
          kGap16,

          // Fuel level slider
          const Text(
            'Fuel level',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: kLabelColor,
            ),
          ),
          const SizedBox(height: 8),
          _FuelLevelSlider(
            value: state.fuelLevel,
            onChanged: (v) =>
                ref.read(vehicleCustomerFormProvider.notifier).setFuelLevel(v),
          ),
          kGap16,

          // Customer Consent toggle
          Container(
            decoration: BoxDecoration(
              color: kFieldBg,
              borderRadius: BorderRadius.all(
                Radius.circular(AppDimensions.r10),
              ),
            ),
            child: AdvisorToggleTile(
              label: 'Customer Consent',
              value: state.customerConsent,
              onChanged: (v) =>
                  ref.read(vehicleCustomerFormProvider.notifier).setConsent(v),
            ),
          ),
          kGap16,

          const FieldLabel('Job Card Photos and Videos'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MediaAddTile(
                  icon: Icons.photo_library_outlined,
                  label: 'Photos',
                  count: photoPaths.length,
                  onTap: onAddPhotos,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MediaAddTile(
                  icon: Icons.videocam_outlined,
                  label: 'Video',
                  count: videoPaths.length,
                  onTap: onAddVideo,
                ),
              ),
            ],
          ),
          if (photoPaths.isNotEmpty || videoPaths.isNotEmpty) ...[
            const SizedBox(height: 12),
            _MediaThumbnailGrid(
              photoPaths: photoPaths,
              videoPaths: videoPaths,
              onRemovePhoto: onRemovePhoto,
              onRemoveVideo: onRemoveVideo,
            ),
          ],
          kGap16,

          const FieldLabel('Digital Signatures'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCustomerSignature,
                  icon: Icon(
                    hasCustomerSignature
                        ? Icons.check_circle_outline
                        : Icons.draw_outlined,
                    size: 18,
                    color: hasCustomerSignature ? AppColors.success : null,
                  ),
                  label: const Text(
                    'Customer',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAdvisorSignature,
                  icon: Icon(
                    hasAdvisorSignature
                        ? Icons.check_circle_outline
                        : Icons.draw_outlined,
                    size: 18,
                    color: hasAdvisorSignature ? AppColors.success : null,
                  ),
                  label: const Text(
                    'Advisor',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _DateField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final initial = DateTime.tryParse(value) ?? DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(1980),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          final month = picked.month.toString().padLeft(2, '0');
          final day = picked.day.toString().padLeft(2, '0');
          onChanged('${picked.year}-$month-$day');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: value.isEmpty ? kFieldBg : kTealLight,
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: kHintColor,
              size: 16,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value.isEmpty ? 'Click to select a date' : value,
                style: TextStyle(
                  fontSize: 13,
                  color: value.isEmpty ? kHintColor : kTextColor,
                  fontWeight: value.isEmpty
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Numbered job-description rows (1, 2, 3, …), each with a rich text editor,
/// a priority selector and an "Add Row" action — matching the client's
/// reference table while staying usable on phones.
class _JobDescriptionTable extends StatelessWidget {
  final VehicleCustomerFormState state;
  final WidgetRef ref;
  const _JobDescriptionTable({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(vehicleCustomerFormProvider.notifier);
    final rows = state.jobDescriptions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < rows.length; index++)
          _row(context, notifier, index, rows[index]),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: notifier.addJobDescriptionRow,
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text('Add another description'),
          ),
        ),
      ],
    );
  }

  Widget _row(
    BuildContext context,
    VehicleCustomerFormNotifier notifier,
    int index,
    JobDescriptionEntry row,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: kFieldBg,
        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
        border: Border.all(color: AppColors.border),
      ),
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
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Job Description',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kTextColor,
                  ),
                ),
              ),
              if (state.jobDescriptions.length > 1)
                IconButton(
                  tooltip: 'Remove row',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => notifier.removeJobDescriptionRow(index),
                  icon: const Icon(Icons.close, size: 18, color: kHintColor),
                ),
            ],
          ),
          const SizedBox(height: 6),
          _RichDescriptionEditor(
            key: ValueKey('job-desc-$index'),
            value: row.description,
            onChanged: (v) =>
                notifier.updateJobDescriptionRow(index, description: v),
          ),
          const SizedBox(height: 8),
          _PrioritySelector(
            value: row.priority,
            onChanged: (v) =>
                notifier.updateJobDescriptionRow(index, priority: v),
          ),
          const SizedBox(height: 10),
          Text('Attachments', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _attachmentButton(
                Icons.add_photo_alternate_outlined,
                'Photos',
                row.photoPaths.length,
                () => _pickPhotos(context, notifier, index),
              ),
              _attachmentButton(
                Icons.video_call_outlined,
                'Video',
                row.videoPaths.length,
                () => _pickVideo(context, notifier, index),
              ),
              _attachmentButton(
                Icons.mic_none_rounded,
                'Audio',
                row.audioPath.isEmpty ? 0 : 1,
                () => _recordAudio(context, notifier, index, row),
              ),
            ],
          ),
          if (row.photoPaths.isNotEmpty || row.videoPaths.isNotEmpty) ...[
            const SizedBox(height: 10),
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
            const SizedBox(height: 8),
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
    );
  }

  Widget _attachmentButton(
    IconData icon,
    String label,
    int count,
    VoidCallback onPressed,
  ) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 18),
    label: Text(count == 0 ? label : '$label ($count)'),
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
    VehicleCustomerFormNotifier notifier,
    int index,
    JobDescriptionEntry row,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => _JobDescriptionAudioDialog(
        itemId: 'job-description-${index + 1}',
        hasExisting: row.audioPath.isNotEmpty,
        onSaved: (path) => notifier.setJobDescriptionAudio(index, path),
      ),
    );
  }

  void _showAttachmentError(BuildContext context, Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Could not add attachment: $error')));
  }
}

class _JobDescriptionAudioDialog extends StatefulWidget {
  final String itemId;
  final bool hasExisting;
  final ValueChanged<String> onSaved;

  const _JobDescriptionAudioDialog({
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
    final colors = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Job description audio'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _recording
                ? 'Recording… $_seconds seconds'
                : widget.hasExisting
                ? 'Record again to replace the current audio.'
                : 'Record a voice note up to 60 seconds.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          IconButton.filled(
            onPressed: _recording ? _stop : _start,
            icon: Icon(_recording ? Icons.stop_rounded : Icons.mic_rounded),
            style: IconButton.styleFrom(
              backgroundColor: _recording ? colors.error : colors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _recording ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _PrioritySelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _PrioritySelector({required this.value, required this.onChanged});

  Color _colorFor(String priority) {
    if (priority.startsWith('Red:')) return AppColors.danger;
    if (priority.startsWith('Yellow:')) return AppColors.warning;
    return AppColors.success;
  }

  String _titleFor(String priority) => priority.split(':').first;

  String _detailFor(String priority) {
    final separator = priority.indexOf(':');
    return separator < 0 ? priority : priority.substring(separator + 1).trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      initialValue: value,
      tooltip: 'Select priority',
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
                      color: _colorFor(priority),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _titleFor(priority),
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
        decoration: const InputDecoration(
          labelText: 'Priority',
          suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _colorFor(value),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
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
/// (bold, italic, bullet list). Formatting is stored as lightweight markdown
/// so it survives the round-trip to the backend and can be rendered later.
class _RichDescriptionEditor extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _RichDescriptionEditor({
    super.key,
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
    final children = <TextSpan>[];
    var cursor = 0;
    for (final match in _pattern.allMatches(raw)) {
      if (match.start > cursor) {
        children.add(TextSpan(text: raw.substring(cursor, match.start)));
      }
      final bold = match.group(1) != null;
      final inner = (bold ? match.group(1) : match.group(2)) ?? '';
      final marker = bold ? '**' : '*';
      final markerStyle = base.copyWith(
        color: (base.color ?? Colors.black).withValues(alpha: 0.30),
        fontWeight: FontWeight.normal,
        fontStyle: FontStyle.normal,
      );
      children.add(TextSpan(text: marker, style: markerStyle));
      children.add(
        TextSpan(
          text: inner,
          style: base.copyWith(
            fontWeight: bold ? FontWeight.w800 : base.fontWeight,
            fontStyle: bold ? base.fontStyle : FontStyle.italic,
          ),
        ),
      );
      children.add(TextSpan(text: marker, style: markerStyle));
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
    return Container(
      decoration: BoxDecoration(
        color: kFieldBg,
        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                _tool(Icons.format_bold, 'Bold', () => _wrapSelection('**')),
                _tool(Icons.format_italic, 'Italic', () => _wrapSelection('*')),
                _tool(Icons.format_list_bulleted, 'Bullet', _toggleBullet),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              style: const TextStyle(
                fontSize: 13,
                color: kTextColor,
                height: 1.5,
              ),
              decoration: const InputDecoration(
                hintText:
                    'Describe the requested work… use the toolbar to bold or add bullet points',
                hintStyle: TextStyle(color: kHintColor, fontSize: 13),
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
      icon: Icon(icon, size: 18, color: kTextColor),
    );
  }
}

class _MediaAddTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;
  const _MediaAddTile({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = count > 0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: kFieldBg,
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: active ? AppColors.primary : kHintColor,
            ),
            const SizedBox(height: 6),
            Text(
              count == 0 ? 'Add $label' : '$label ($count)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: active ? AppColors.primary : kTextColor,
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
            photoPaths[i],
            isVideo: false,
            onRemove: () => onRemovePhoto(i),
          ),
        for (var i = 0; i < videoPaths.length; i++)
          _thumb(
            videoPaths[i],
            isVideo: true,
            onRemove: () => onRemoveVideo(i),
          ),
      ],
    );
  }

  Widget _thumb(
    String path, {
    required bool isVideo,
    required VoidCallback onRemove,
  }) {
    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
            child: isVideo
                ? Container(
                    width: 84,
                    height: 84,
                    color: AppColors.surfaceAlt,
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 30,
                        color: kTextColor,
                      ),
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
                          color: AppColors.surfaceAlt,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: kHintColor,
                          ),
                        )),
          ),
          if (isVideo)
            const Positioned(
              bottom: 4,
              left: 4,
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
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
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
                      color: isFilled ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppDimensions.r2),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => onChanged(value.clamp(1, 10)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                value >= 8
                    ? Icons.local_gas_station
                    : value >= 4
                    ? Icons.local_gas_station
                    : Icons.local_gas_station_outlined,
                color: value >= 4 ? AppColors.warning : AppColors.danger,
                size: 22,
              ),
              Text(
                '$value/10',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: value >= 4 ? AppColors.warning : AppColors.danger,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
