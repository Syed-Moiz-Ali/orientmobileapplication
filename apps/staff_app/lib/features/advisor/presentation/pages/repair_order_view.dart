// lib/features/advisor/inspection_pages/repair_order_view.dart

// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:staff_app/core/platform/file_ops.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:hive/hive.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/inspection_model.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/inspection_view_model.dart';
import 'package:staff_app/features/advisor/inspection_pages/presentation/widgets/inspection_widgets.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_workflow_indicator.dart';
import 'inspection_provider.dart';

class RepairOrderView extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final bool fromInspection;

  const RepairOrderView({
    super.key,
    required this.onBack,
    this.fromInspection = false,
  });

  @override
  ConsumerState<RepairOrderView> createState() => _RepairOrderViewState();
}

class _RepairOrderViewState extends ConsumerState<RepairOrderView> {
  bool _showServices = false;
  bool _showParts = false;
  bool _loadingGeneratedItems = false;
  bool _loadedGeneratedItems = false;
  List<String> _pendingServices = [];
  List<String> _pendingParts = [];
  Map<String, dynamic>? _customerData;

  // P3 (audit): auto-pricing — suggest a rate from historical quotes for the
  // same service name. A convenience, never a blocker.
  Future<void> _suggestPrice(
    BuildContext context,
    int index,
    ServiceLineItem item,
    InspectionNotifier notifier,
  ) async {
    final name = item.name.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a service name first')),
      );
      return;
    }
    final client = ref.read(apiClientProvider);
    try {
      final result = await client.get<Map<String, dynamic>>(
        ApiEndpoints.autoPrice,
        queryParams: {'name': name},
        fromJson: (d) => d as Map<String, dynamic>,
      );
      result.when(
        success: (data) {
          final rate = data['suggestedRate'];
          if (rate is num && rate > 0) {
            notifier.updateServiceLine(index, rate: rate.toDouble());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Suggested AED ${rate.toStringAsFixed(2)} (from ${data['samples']} quote(s))',
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No pricing history for this service yet'),
              ),
            );
          }
        },
        failure: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not fetch suggested price')),
          );
        },
      );
    } catch (_) {
      // suggestion is a convenience — ignore failures
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _loadGeneratedWorkItems(),
    );
  }

  Future<void> _loadGeneratedWorkItems() async {
    if (_loadedGeneratedItems || _loadingGeneratedItems) return;
    final state = ref.read(inspectionProvider);
    if (state.jobCardId.trim().isEmpty) return;
    setState(() => _loadingGeneratedItems = true);
    try {
      final remote = ref.read(advisorRemoteDataSourceProvider);
      final detail = await remote.getJobCard(state.jobCardId);
      if (mounted) {
        setState(() => _mergeJobCardDetails(detail));
      } else {
        _mergeJobCardDetails(detail);
      }
      final jobCardRef = detail.id.isNotEmpty ? detail.id : state.jobCardId;
      final items = await remote.getWorkItems(jobCardRef);
      final generatedServices = items
          .where((item) => item.description.trim().isNotEmpty)
          .map(
            (item) => ServiceLineItem(
              name: item.description.trim(),
              qty: item.qty > 0 ? item.qty : 1,
              rate: item.rate,
            ),
          )
          .toList();
      if (!mounted) return;
      ref
          .read(inspectionProvider.notifier)
          .mergeGeneratedServices(generatedServices);
    } catch (_) {
      // The advisor can still add extra work manually if generated work items
      // are temporarily unavailable.
    } finally {
      if (mounted) {
        setState(() {
          _loadedGeneratedItems = true;
          _loadingGeneratedItems = false;
        });
      }
    }
  }

  void _loadCustomerData() {
    try {
      final box = Hive.box<dynamic>('inspections');
      final all = box.values
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
      final state = ref.read(inspectionProvider);
      final jid = state.jobCardId;
      _customerData = all.cast<Map<String, dynamic>?>().firstWhere(
        (m) =>
            m?['id'] == jid ||
            m?['jobCardId'] == jid ||
            m?['bookingId'] == state.bookingId,
        orElse: () => null,
      );
    } catch (_) {}
  }

  String _getVal(String key) => _customerData?[key]?.toString() ?? '';

  String get _vehicleTitle {
    final info = _getVal('vehicleInfo').trim();
    if (info.isNotEmpty) return info;
    return '${_getVal('make')} ${_getVal('model')}'.trim();
  }

  String get _plateNumber => _getVal('registrationNumber').trim();

  void _mergeJobCardDetails(JobCardDetailResponse detail) {
    final current = Map<String, dynamic>.from(_customerData ?? const {});
    void put(String key, String value) {
      if (value.trim().isNotEmpty) current[key] = value;
    }

    put('customerName', detail.customerName);
    put('phoneNumber', detail.phoneNumber);
    put('email', detail.email);
    put('registrationNumber', detail.registrationNumber);
    put('vin', detail.vin);
    put('make', detail.make);
    put('model', detail.model);
    put('modelYear', detail.modelYear);
    put('vehicleColor', detail.vehicleColor);
    put('mileage', detail.mileage);
    put('vehicleInfo', detail.vehicleInfo);
    _customerData = current;
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(inspectionProvider.notifier);
    final state = ref.watch(inspectionProvider);

    if (_showServices) {
      return _ChooseServicesView(
        notifier: notifier,
        selected: _pendingServices,
        onToggle: (s) => setState(() {
          _pendingServices.contains(s)
              ? _pendingServices.remove(s)
              : _pendingServices.add(s);
        }),
        onBack: () => setState(() {
          _showServices = false;
          _pendingServices = [];
        }),
      );
    }

    if (_showParts) {
      return _ChoosePartsView(
        notifier: notifier,
        selected: _pendingParts,
        onToggle: (p) => setState(() {
          _pendingParts.contains(p)
              ? _pendingParts.remove(p)
              : _pendingParts.add(p);
        }),
        onBack: () => setState(() {
          _showParts = false;
          _pendingParts = [];
        }),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: widget.onBack,
        ),
        title: Text(
          'Create Estimate',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _confirmReset(notifier),
            child: Text(
              'Reset',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        children: [
          const SizedBox(height: 12),
          const AdvisorWorkflowIndicator(currentStep: 2),
          const SizedBox(height: 14),
          _EstimateIntro(
            serviceCount: state.serviceLines.length,
            partCount: state.partLines.length,
          ),
          // ── Inspection attached banner ──────────────────────────────────
          if (widget.fromInspection) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: IC.tealBg,
                borderRadius: BorderRadius.all(
                  Radius.circular(AppDimensions.r10),
                ),
                border: Border.all(color: IC.accent),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: IC.accent, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Inspection completed and attached',
                    style: TextStyle(
                      fontSize: 12,
                      color: IC.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // ── Customer / Vehicle info ─────────────────────────────────────
          InfoCard(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer',
                            style: TextStyle(fontSize: 11, color: IC.text3),
                          ),
                          SizedBox(height: 2),
                          Text(
                            _getVal('customerName'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: IC.text1,
                            ),
                          ),
                          Text(
                            [
                              _getVal('phoneNumber'),
                              _getVal('email'),
                            ].where((v) => v.trim().isNotEmpty).join('  |  '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: IC.text2),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vehicle',
                            style: TextStyle(fontSize: 11, color: IC.text3),
                          ),
                          SizedBox(height: 2),
                          Text(
                            _vehicleTitle.isEmpty ? '--' : _vehicleTitle,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: IC.text1,
                            ),
                          ),
                          Text(
                            [
                              if (_plateNumber.isNotEmpty)
                                'Plate $_plateNumber',
                              if (_getVal('vin').isNotEmpty)
                                'VIN ${_getVal('vin')}',
                            ].join('  |  '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: IC.text2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Divider(color: IC.line, height: 1),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        [
                          if (_getVal('modelYear').isNotEmpty)
                            'Year ${_getVal('modelYear')}',
                          if (_getVal('vehicleColor').isNotEmpty)
                            _getVal('vehicleColor'),
                          if (_getVal('mileage').isNotEmpty)
                            '${_getVal('mileage')} km',
                        ].where((v) => v.trim().isNotEmpty).join('  |  '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: IC.text2),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Service Advisor',
                      style: TextStyle(fontSize: 11, color: IC.text3),
                    ),
                    SizedBox(width: 8),
                    // FIX (audit P0): 'swami' was a hardcoded developer name.
                    Text(
                      'You',
                      style: TextStyle(fontSize: 12, color: IC.text1),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.edit_outlined, size: 12, color: IC.text3),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Reference number ───────────────────────────────────────────
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.tag_rounded, size: 18, color: IC.accent),
                    SizedBox(width: 8),
                    Text(
                      'Reference Number',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: IC.text1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  onChanged: notifier.setReferenceNumber,
                  style: const TextStyle(fontSize: 13, color: IC.text1),
                  decoration: InputDecoration(
                    hintText: 'Example: LPO-2026-001',
                    hintStyle: const TextStyle(fontSize: 13, color: IC.text3),
                    filled: true,
                    fillColor: IC.canvas,
                    prefixIcon: const Icon(
                      Icons.numbers_rounded,
                      size: 18,
                      color: IC.text3,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r10),
                      borderSide: const BorderSide(color: IC.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r10),
                      borderSide: const BorderSide(color: IC.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r10),
                      borderSide: const BorderSide(
                        color: IC.accent,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── SERVICES section ───────────────────────────────────────────
          _LineItemsCard(
            title: 'Services',
            subtitle: 'Labour and service charges',
            icon: Icons.build_outlined,
            onAdd: () {
              _pendingServices = state.serviceLines.map((s) => s.name).toList();
              setState(() => _showServices = true);
            },
            children: [
              if (_loadingGeneratedItems)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Loading generated repair items...',
                        style: TextStyle(fontSize: 11, color: IC.text2),
                      ),
                    ],
                  ),
                ),
              ...state.serviceLines.asMap().entries.map(
                (e) => _ServiceLineRow(
                  index: e.key,
                  item: e.value,
                  notifier: notifier,
                  onSuggest: () =>
                      _suggestPrice(context, e.key, e.value, notifier),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── PARTS section ──────────────────────────────────────────────
          _LineItemsCard(
            title: 'Parts',
            subtitle: 'Replacement parts and materials',
            icon: Icons.settings_outlined,
            onAdd: () {
              _pendingParts = state.partLines.map((p) => p.name).toList();
              setState(() => _showParts = true);
            },
            children: state.partLines
                .asMap()
                .entries
                .map(
                  (e) => _PartLineRow(
                    index: e.key,
                    item: e.value,
                    notifier: notifier,
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 12),

          // ── Pre Service Media ──────────────────────────────────────────
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pre Service Media',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: IC.text1,
                      ),
                    ),
                    SolidBtn(
                      label: '+ ADD',
                      onTap: () => _addPreServiceMedia(),
                      small: true,
                    ),
                  ],
                ),
                if (state.preServicePhotos.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 64,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.preServicePhotos.length,
                      itemBuilder: (_, i) => Container(
                        width: 64,
                        height: 64,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(AppDimensions.r8),
                          ),
                          border: Border.all(color: IC.line),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(
                            Radius.circular(AppDimensions.r7),
                          ),
                          child: localImage(
                            state.preServicePhotos[i],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Totals ─────────────────────────────────────────────────────
          InfoCard(
            child: Column(
              children: [
                _TotalRow('Services Total', state.servicesTotal, bold: false),
                const SizedBox(height: 4),
                _TotalRow('Parts Total', state.partsTotal, bold: false),
                const Divider(color: IC.line, height: 16),
                _TotalRow('Total', state.grandTotal, bold: true),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Tag ────────────────────────────────────────────────────────
          InfoCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tag',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: IC.text1,
                  ),
                ),
                SolidBtn(
                  label: '+ ADD',
                  small: true,
                  onTap: () => _showTagDialog(context, notifier, state.tag),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Customer Requests ──────────────────────────────────────────
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Customer Requests/Complaints',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: IC.text1,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: notifier.setCustomerRequests,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 12, color: IC.text1),
                  decoration: InputDecoration(
                    hintText: 'Customer Requests/Complaints',
                    hintStyle: const TextStyle(fontSize: 12, color: IC.text3),
                    filled: true,
                    fillColor: IC.canvas,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppDimensions.r8),
                      ),
                      borderSide: const BorderSide(color: IC.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppDimensions.r8),
                      ),
                      borderSide: const BorderSide(color: IC.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppDimensions.r8),
                      ),
                      borderSide: const BorderSide(
                        color: IC.accent,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Garage recommendations ─────────────────────────────────────
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Garage Recommendations',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: IC.text1,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: notifier.setGarageRecommendations,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 12, color: IC.text1),
                  decoration: InputDecoration(
                    hintText: 'Enter garage recommendations here',
                    hintStyle: const TextStyle(fontSize: 12, color: IC.text3),
                    filled: true,
                    fillColor: IC.canvas,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppDimensions.r8),
                      ),
                      borderSide: const BorderSide(color: IC.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppDimensions.r8),
                      ),
                      borderSide: const BorderSide(color: IC.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppDimensions.r8),
                      ),
                      borderSide: const BorderSide(
                        color: IC.accent,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Estimated delivery ─────────────────────────────────────────
          InfoCard(
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Estimated delivery time',
                    style: TextStyle(
                      fontSize: 13,
                      color: IC.text1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate:
                          state.estimatedDelivery ??
                          DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (t != null) {
                        notifier.setEstimatedDelivery(
                          DateTime(d.year, d.month, d.day, t.hour, t.minute),
                        );
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: IC.canvas,
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppDimensions.r8),
                      ),
                      border: Border.all(color: IC.line),
                    ),
                    child: Text(
                      state.estimatedDelivery != null
                          ? '${state.estimatedDelivery!.day} ${_month(state.estimatedDelivery!.month)}, ${state.estimatedDelivery!.year}  ${_time(state.estimatedDelivery!)}'
                          : 'Select date & time',
                      style: const TextStyle(fontSize: 11, color: IC.text2),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Notify owner ───────────────────────────────────────────────
          InfoCard(
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Notify Owner (SMS & e-mail)?',
                    style: TextStyle(
                      fontSize: 13,
                      color: IC.text1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TealSwitch(
                  value: state.notifyOwnerSmsEmail,
                  onToggle: notifier.toggleNotifyOwnerSmsEmail,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _EstimateFooter(
        total: state.grandTotal,
        enabled: state.serviceLines.isNotEmpty || state.partLines.isNotEmpty,
        onReview: () => _openPreview(state),
      ),
    );
  }

  Future<void> _confirmReset(InspectionNotifier notifier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.restart_alt_rounded),
        title: const Text('Clear this estimate?'),
        content: const Text(
          'All services, parts, pricing and notes entered here will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep Editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear Estimate'),
          ),
        ],
      ),
    );
    if (confirmed == true) notifier.reset();
  }

  void _openPreview(InspectionState state) {
    if (state.serviceLines.isEmpty && state.partLines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one service or part to continue.'),
        ),
      );
      return;
    }
    context.push(
      AppRoutes.repairOrderPreview,
      extra: {'onBack': () => context.pop()},
    );
  }

  Future<void> _addPreServiceMedia() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: IC.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 3.5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: IC.stroke,
                borderRadius: BorderRadius.all(
                  Radius.circular(AppDimensions.r2),
                ),
              ),
            ),
            const Text(
              'Add Pre-Service Media',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: IC.text1,
              ),
            ),
            const SizedBox(height: 16),
            _MediaOption(
              icon: Icons.camera_alt_outlined,
              label: 'Take Photo',
              value: 'camera',
            ),
            _MediaOption(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              value: 'gallery',
            ),
            _MediaOption(
              icon: Icons.videocam_outlined,
              label: 'Record Video',
              value: 'video',
            ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;
    try {
      final picker = ImagePicker();
      if (choice == 'camera') {
        final f = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );
        if (f != null) {
          ref.read(inspectionProvider.notifier).addPreServicePhoto(f.path);
        }
      } else if (choice == 'gallery') {
        final f = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        if (f != null) {
          ref.read(inspectionProvider.notifier).addPreServicePhoto(f.path);
        }
      } else if (choice == 'video') {
        final f = await picker.pickVideo(source: ImageSource.camera);
        if (f != null) {
          ref.read(inspectionProvider.notifier).addPreServicePhoto(f.path);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: IC.red),
        );
      }
    }
  }

  String _month(int m) => [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m - 1];
  String _time(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _EstimateIntro extends StatelessWidget {
  final int serviceCount;
  final int partCount;

  const _EstimateIntro({required this.serviceCount, required this.partCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.12),
            theme.colorScheme.primary.withValues(alpha: 0.035),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(AppDimensions.r12),
            ),
            child: const Icon(
              Icons.request_quote_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Build the customer estimate',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$serviceCount service${serviceCount == 1 ? '' : 's'} · $partCount part${partCount == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EstimateFooter extends StatelessWidget {
  final double total;
  final bool enabled;
  final VoidCallback onReview;

  const _EstimateFooter({
    required this.total,
    required this.enabled,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.outlineVariant)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimate total',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'AED ${total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: onReview,
              icon: Icon(
                enabled ? Icons.preview_outlined : Icons.add_circle_outline,
                size: 19,
              ),
              label: Text(enabled ? 'Review Estimate' : 'Add Estimate Items'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MediaOption({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.pop(context, value),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: IC.canvas,
        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
        border: Border.all(color: IC.line),
      ),
      child: Row(
        children: [
          Icon(icon, color: IC.accent, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: IC.text1,
            ),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  TOTAL ROW
// ─────────────────────────────────────────────────────────────────────────────
class _TotalRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool bold;
  const _TotalRow(this.label, this.amount, {required this.bold});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: bold ? IC.text1 : IC.text2,
          fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
        ),
      ),
      Text(
        'AED ${amount.toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 12,
          color: IC.text1,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  LINE ITEMS CARD (shared for services and parts)
// ─────────────────────────────────────────────────────────────────────────────
class _LineItemsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onAdd;
  final List<Widget> children;
  const _LineItemsCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onAdd,
    required this.children,
  });

  @override
  Widget build(BuildContext context) => InfoCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: IC.tealBg,
                borderRadius: BorderRadius.circular(AppDimensions.r10),
              ),
              child: Icon(icon, size: 19, color: IC.accent),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: IC.text1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: IC.text3),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 17),
              label: const Text('Add'),
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        if (children.isEmpty) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: IC.canvas,
              borderRadius: BorderRadius.circular(AppDimensions.r10),
            ),
            child: Text(
              'No ${title.toLowerCase()} added yet',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: IC.text3),
            ),
          ),
        ],
        ...children,
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  SERVICE LINE ROW — with Selling Price column
// ─────────────────────────────────────────────────────────────────────────────
void _showItemInfo(BuildContext context, String name) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.r14),
      ),
      title: const Text(
        'Line Item',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      content: Text(
        name,
        style: const TextStyle(fontSize: 13, color: AppColors.text2),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

void _showTagDialog(
  BuildContext context,
  InspectionNotifier notifier,
  String currentTag,
) {
  final controller = TextEditingController(text: currentTag);
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.r14),
      ),
      title: const Text(
        'Tag',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Enter a tag (e.g. VIP, Fleet, Insurance)',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (v) {
          notifier.setTag(v.trim());
          Navigator.pop(ctx);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            notifier.setTag(controller.text.trim());
            Navigator.pop(ctx);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

class _ServiceLineRow extends StatelessWidget {
  final int index;
  final ServiceLineItem item;
  final InspectionNotifier notifier;
  final VoidCallback onSuggest;
  const _ServiceLineRow({
    required this.index,
    required this.item,
    required this.notifier,
    required this.onSuggest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: IC.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: IC.accent,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showItemInfo(context, item.name),
                child: const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: IC.text3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _PricingInput(
                  label: 'Quantity',
                  child: _EditableField(
                    label: '',
                    value: '${item.qty}',
                    onChanged: (v) {
                      final q = int.tryParse(v);
                      if (q != null) notifier.updateServiceLine(index, qty: q);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _PricingInput(
                  label: 'Unit price (AED)',
                  trailing: IconButton(
                    onPressed: onSuggest,
                    tooltip: 'Suggest price from history',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.auto_awesome,
                      size: 17,
                      color: IC.accent,
                    ),
                  ),
                  child: _EditableField(
                    label: '',
                    value: item.rate.toStringAsFixed(2),
                    onChanged: (v) {
                      final r = double.tryParse(v);
                      if (r != null) {
                        notifier.updateServiceLine(index, rate: r);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PricingInput(
                  label: 'Discount %',
                  child: _EditableField(
                    label: '',
                    value: item.discountPercent.toStringAsFixed(0),
                    onChanged: (v) {
                      final d = double.tryParse(v);
                      if (d != null) {
                        notifier.updateServiceLine(index, discountPct: d);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _LineAmount(amount: item.amount),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PART LINE ROW — with Selling Price column
// ─────────────────────────────────────────────────────────────────────────────
class _PartLineRow extends StatelessWidget {
  final int index;
  final PartLineItem item;
  final InspectionNotifier notifier;
  const _PartLineRow({
    required this.index,
    required this.item,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: IC.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: IC.accent,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showItemInfo(context, item.name),
                child: const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: IC.text3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _PricingInput(
                  label: 'Quantity',
                  child: _EditableField(
                    label: '',
                    value: '${item.qty}',
                    onChanged: (v) {
                      final q = int.tryParse(v);
                      if (q != null) notifier.updatePartLine(index, qty: q);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _PricingInput(
                  label: 'Unit price (AED)',
                  child: _EditableField(
                    label: '',
                    value: item.rate.toStringAsFixed(2),
                    onChanged: (v) {
                      final r = double.tryParse(v);
                      if (r != null) notifier.updatePartLine(index, rate: r);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PricingInput(
                  label: 'Discount %',
                  child: _EditableField(
                    label: '',
                    value: item.discountPercent.toStringAsFixed(0),
                    onChanged: (v) {
                      final d = double.tryParse(v);
                      if (d != null) {
                        notifier.updatePartLine(index, discountPct: d);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _LineAmount(amount: item.amount),
        ],
      ),
    );
  }
}

class _PricingInput extends StatelessWidget {
  final String label;
  final Widget child;
  final Widget? trailing;

  const _PricingInput({
    required this.label,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                color: IC.text2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
      const SizedBox(height: 5),
      child,
    ],
  );
}

class _LineAmount extends StatelessWidget {
  final double amount;
  const _LineAmount({required this.amount});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: IC.tealBg,
      borderRadius: BorderRadius.circular(AppDimensions.r10),
    ),
    child: Row(
      children: [
        const Text(
          'Line total',
          style: TextStyle(
            fontSize: 11,
            color: IC.text2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          'AED ${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 13,
            color: IC.accent,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

class _EditableField extends StatefulWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  const _EditableField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<_EditableField> {
  // FE-FIX (audit P1): the controller was created inside build() — every
  // rebuild (e.g. auto-pricing a different line) reset this field to its
  // initial value and dropped whatever the user was typing.
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );
  bool _dirty = false;

  @override
  void didUpdateWidget(_EditableField old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && !_dirty) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
    height: 44,
    decoration: BoxDecoration(
      color: IC.canvas,
      borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r6)),
      border: Border.all(color: IC.line),
    ),
    child: TextField(
      controller: _controller,
      onChanged: (v) {
        _dirty = true;
        widget.onChanged(v);
      },
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(
        fontSize: 13,
        color: IC.text1,
        fontWeight: FontWeight.w600,
      ),
      decoration: const InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  CHOOSE SERVICES VIEW
// ─────────────────────────────────────────────────────────────────────────────
class _SelectionIntro extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int selectedCount;

  const _SelectionIntro({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selectedCount,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: IC.surface,
      borderRadius: BorderRadius.circular(AppDimensions.r14),
      border: Border.all(color: IC.line),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: IC.tealBg,
            borderRadius: BorderRadius.circular(AppDimensions.r12),
          ),
          child: Icon(icon, color: IC.accent, size: 21),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: IC.text1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: IC.text3),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: selectedCount > 0 ? IC.accent : IC.canvas,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            '$selectedCount selected',
            style: TextStyle(
              fontSize: 10.5,
              color: selectedCount > 0 ? Colors.white : IC.text2,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}

class _SelectionFooter extends StatelessWidget {
  final String label;
  final VoidCallback onConfirm;

  const _SelectionFooter({required this.label, required this.onConfirm});

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: const Border(top: BorderSide(color: IC.line)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onConfirm,
          icon: const Icon(Icons.check_rounded, size: 20),
          label: Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    ),
  );
}

class _ChooseServicesView extends StatefulWidget {
  final InspectionNotifier notifier;
  final List<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback onBack;
  const _ChooseServicesView({
    required this.notifier,
    required this.selected,
    required this.onToggle,
    required this.onBack,
  });

  @override
  State<_ChooseServicesView> createState() => _ChooseServicesViewState();
}

class _ChooseServicesViewState extends State<_ChooseServicesView> {
  String _q = '';

  void _confirm() {
    widget.notifier.addServices(List.from(widget.selected));
    widget.onBack();
  }

  @override
  Widget build(BuildContext context) {
    final items = kServiceList
        .where((s) => s.toLowerCase().contains(_q.toLowerCase()))
        .toList();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: widget.onBack,
        ),
        title: const Text(
          'Add Services',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        children: [
          _SelectionIntro(
            icon: Icons.build_outlined,
            title: 'Select required services',
            subtitle: 'Pricing can be entered after adding them',
            selectedCount: widget.selected.length,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SearchField(
              hint: 'Search services',
              onChanged: (q) => setState(() => _q = q),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off_rounded,
                    message: 'No services found',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final s = items[i];
                      final sel = widget.selected.contains(s);
                      return GestureDetector(
                        onTap: () {
                          widget.onToggle(s);
                          setState(() {});
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: sel ? IC.tealBg : IC.surface,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.r12,
                            ),
                            border: Border.all(
                              color: sel ? IC.accent : IC.line,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: sel ? IC.accent : IC.canvas,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.r10,
                                  ),
                                ),
                                child: Icon(
                                  sel
                                      ? Icons.check_rounded
                                      : Icons.build_outlined,
                                  color: sel ? Colors.white : IC.text3,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: IC.text1,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      sel ? 'Added to estimate' : 'Tap to add',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: sel ? IC.accent : IC.text3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                sel
                                    ? Icons.check_circle_rounded
                                    : Icons.add_circle_outline_rounded,
                                color: sel ? IC.accent : IC.text3,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          _SelectionFooter(
            label: widget.selected.isEmpty
                ? 'Done'
                : 'Add ${widget.selected.length} Service${widget.selected.length == 1 ? '' : 's'}',
            onConfirm: _confirm,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CHOOSE PARTS VIEW
// ─────────────────────────────────────────────────────────────────────────────
class _ChoosePartsView extends StatefulWidget {
  final InspectionNotifier notifier;
  final List<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback onBack;
  const _ChoosePartsView({
    required this.notifier,
    required this.selected,
    required this.onToggle,
    required this.onBack,
  });

  @override
  State<_ChoosePartsView> createState() => _ChoosePartsViewState();
}

class _ChoosePartsViewState extends State<_ChoosePartsView> {
  String _q = '';

  void _confirm() {
    widget.notifier.addParts(List.from(widget.selected));
    widget.onBack();
  }

  @override
  Widget build(BuildContext context) {
    final items = kPartList
        .where((p) => p.toLowerCase().contains(_q.toLowerCase()))
        .toList();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: widget.onBack,
        ),
        title: const Text(
          'Add Parts',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        children: [
          _SelectionIntro(
            icon: Icons.settings_outlined,
            title: 'Select required parts',
            subtitle: 'Quantity and price can be updated after adding them',
            selectedCount: widget.selected.length,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SearchField(
              hint: 'Search parts',
              onChanged: (q) => setState(() => _q = q),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off_rounded,
                    message: 'No parts found',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final p = items[i];
                      final sel = widget.selected.contains(p);
                      return GestureDetector(
                        onTap: () {
                          widget.onToggle(p);
                          setState(() {});
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: sel ? IC.tealBg : IC.surface,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.r12,
                            ),
                            border: Border.all(
                              color: sel ? IC.accent : IC.line,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: sel ? IC.accent : IC.canvas,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.r10,
                                  ),
                                ),
                                child: Icon(
                                  sel
                                      ? Icons.check_rounded
                                      : Icons.settings_outlined,
                                  color: sel ? Colors.white : IC.text3,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: IC.text1,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      sel ? 'Added to estimate' : 'Tap to add',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: sel ? IC.accent : IC.text3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                sel
                                    ? Icons.check_circle_rounded
                                    : Icons.add_circle_outline_rounded,
                                color: sel ? IC.accent : IC.text3,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          _SelectionFooter(
            label: widget.selected.isEmpty
                ? 'Done'
                : 'Add ${widget.selected.length} Part${widget.selected.length == 1 ? '' : 's'}',
            onConfirm: _confirm,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  REPAIR ORDER PREVIEW
// ─────────────────────────────────────────────────────────────────────────────
class RepairOrderPreviewView extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  const RepairOrderPreviewView({super.key, required this.onBack});

  @override
  ConsumerState<RepairOrderPreviewView> createState() =>
      _RepairOrderPreviewViewState();
}

class _RepairOrderPreviewViewState
    extends ConsumerState<RepairOrderPreviewView> {
  Map<String, dynamic>? _customerData;
  Uint8List? _signatureBytes;

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  void _loadCustomerData() {
    try {
      final box = Hive.box<dynamic>('inspections');
      final all = box.values
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
      final state = ref.read(inspectionProvider);
      final jid = state.jobCardId;
      _customerData = all.cast<Map<String, dynamic>?>().firstWhere(
        (m) => m?['id'] == jid || m?['type'] == 'vehicle_customer',
        orElse: () => null,
      );
    } catch (_) {}
  }

  String _getVal(String key) => _customerData?[key]?.toString() ?? '';

  Future<void> _captureSignature() async {
    final result = await showModalBottomSheet<Uint8List>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _SignaturePadSheet(),
    );
    if (result == null || !mounted) return;
    setState(() {
      _signatureBytes = result;
    });
    // Persist the signature so it can be attached to the repair order later.
    final path = await saveSignatureFile(
      result,
      'signature_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    if (path.isNotEmpty && mounted) {
      try {
        final box = Hive.box<dynamic>('inspections');
        box.put('repair_order_signature', {
          'path': path,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inspectionProvider);
    final brand = ref.watch(brandConfigProvider);
    final now = DateTime.now();
    final customerName = _getVal('customerName');
    final phone = _getVal('phoneNumber');
    final email = _getVal('email');
    final vehicle =
        '${_getVal('make')} ${_getVal('model')}\n${_getVal('registrationNumber')}\n${_getVal('vin')}';

    return Scaffold(
      backgroundColor: IC.canvas,
      appBar: AppBar(
        backgroundColor: IC.navy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBack,
        ),
        title: const Text(
          'Review Estimate',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        actions: [
          TextButton.icon(
            onPressed: _captureSignature,
            icon: Icon(
              _signatureBytes == null
                  ? Icons.draw_outlined
                  : Icons.check_circle_rounded,
              size: 17,
            ),
            label: Text(_signatureBytes == null ? 'Add signature' : 'Signed'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InfoCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        border: Border.all(color: IC.line, width: 2),
                        borderRadius: BorderRadius.all(
                          Radius.circular(AppDimensions.r8),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(brand.icon, color: IC.accent, size: 22),
                          Text(
                            brand.appName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 7,
                              color: IC.text3,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            brand.appName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: IC.text1,
                            ),
                          ),
                          Text(
                            _getVal('address').isEmpty
                                ? 'Auto Garage Services'
                                : _getVal('address'),
                            style: const TextStyle(
                              fontSize: 11,
                              color: IC.text2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone_outlined,
                                size: 11,
                                color: IC.text3,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                phone.isEmpty ? '--' : phone,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: IC.text2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.email_outlined,
                                size: 11,
                                color: IC.text3,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                email.isEmpty ? '--' : email,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: IC.text2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(color: IC.line),
                const SizedBox(height: 8),

                const Text(
                  'Estimate',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: IC.text1,
                    letterSpacing: 0,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: IC.canvas,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    border: Border.all(color: IC.line),
                  ),
                  child: Column(
                    children: [
                      _PreviewDetailRow(
                        icon: Icons.person_outline_rounded,
                        label: 'Customer',
                        value: customerName.isEmpty
                            ? '--'
                            : '$customerName\n$phone',
                      ),
                      const Divider(height: 20, color: IC.line),
                      _PreviewDetailRow(
                        icon: Icons.directions_car_outlined,
                        label: 'Vehicle',
                        value: _getVal('make').isEmpty ? '--' : vehicle,
                      ),
                      const Divider(height: 20, color: IC.line),
                      _PreviewDetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Prepared on',
                        value:
                            '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} at ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: IC.tealBg,
                    borderRadius: BorderRadius.circular(AppDimensions.r10),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Estimate total',
                        style: TextStyle(
                          fontSize: 12,
                          color: IC.text2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'AED ${state.grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: IC.accent,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_signatureBytes != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: IC.canvas,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      border: Border.all(color: IC.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CUSTOMER SIGNATURE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: IC.text3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Image.memory(
                          _signatureBytes!,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          if (state.serviceLines.isNotEmpty) ...[
            InfoCard(
              child: Column(
                children: [
                  _TableHeader(const [
                    'SERVICES',
                    'QTY',
                    'SELLING PRICE',
                    'AMOUNT',
                  ]),
                  ...state.serviceLines.map(
                    (s) => _TableRow([
                      s.name,
                      '${s.qty}.00',
                      'AED ${s.rate.toStringAsFixed(2)}',
                      'AED ${s.amount.toStringAsFixed(2)}',
                    ]),
                  ),
                  const Divider(color: IC.line),
                  _SectionTotal('TOTAL :', state.servicesTotal),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (state.partLines.isNotEmpty) ...[
            InfoCard(
              child: Column(
                children: [
                  _TableHeader(const [
                    'PARTS',
                    'QTY',
                    'SELLING PRICE',
                    'AMOUNT',
                  ]),
                  ...state.partLines.map(
                    (p) => _TableRow([
                      p.name,
                      '${p.qty}.00',
                      'AED ${p.rate.toStringAsFixed(2)}',
                      'AED ${p.amount.toStringAsFixed(2)}',
                    ]),
                  ),
                  const Divider(color: IC.line),
                  _SectionTotal('TOTAL :', state.partsTotal),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SUMMARY',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: IC.text1,
                  ),
                ),
                const SizedBox(height: 10),
                _SummaryRow('SUB TOTAL:', state.grandTotal),
                _SummaryRow('GRAND TOTAL:', state.grandTotal, bold: true),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: _CreateRepairOrderButton(onBack: widget.onBack),
    );
  }
}

/// Minimal hand-drawn signature pad rendered with CustomPaint.
class _SignaturePadSheet extends StatefulWidget {
  const _SignaturePadSheet();

  @override
  State<_SignaturePadSheet> createState() => _SignaturePadSheetState();
}

class _SignaturePadSheetState extends State<_SignaturePadSheet> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _current = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Customer Signature',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onPanStart: (d) => _current = [d.localPosition],
              onPanUpdate: (d) {
                setState(() => _current.add(d.localPosition));
              },
              onPanEnd: (_) {
                setState(() {
                  _strokes.add(List.from(_current));
                  _current = [];
                });
              },
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomPaint(
                    painter: _SignaturePainter(
                      strokes: _strokes,
                      current: _current,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() {
                      _strokes.clear();
                      _current = [];
                    }),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _strokes.isEmpty
                        ? null
                        : () async {
                            final bytes = await _renderSignaturePng();
                            if (context.mounted) {
                              Navigator.of(context).pop(bytes);
                            }
                          },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Use Signature'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _renderSignaturePng() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const width = 800.0;
    const height = 320.0;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = Colors.white,
    );
    final painter = _SignaturePainter(strokes: _strokes, current: const []);
    painter.paint(canvas, const Size(width, height));
    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List() ?? Uint8List(0);
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> current;

  const _SignaturePainter({required this.strokes, required this.current});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      _drawPath(canvas, paint, stroke);
    }
    _drawPath(canvas, paint, current);
  }

  void _drawPath(Canvas canvas, Paint paint, List<Offset> points) {
    if (points.isEmpty) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}

class _PreviewDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _PreviewDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: IC.tealBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: IC.accent),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: IC.text3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: IC.text1,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _TableHeader extends StatelessWidget {
  final List<String> cols;
  const _TableHeader(this.cols);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.only(bottom: 10),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: IC.line)),
    ),
    child: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: IC.tealBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            cols[0] == 'SERVICES'
                ? Icons.build_outlined
                : Icons.settings_outlined,
            color: IC.accent,
            size: 18,
          ),
        ),
        const SizedBox(width: 9),
        Text(
          cols[0][0] + cols[0].substring(1).toLowerCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: IC.text1,
          ),
        ),
      ],
    ),
  );
}

class _TableRow extends StatelessWidget {
  final List<String> cells;
  const _TableRow(this.cells);

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 8),
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: IC.canvas,
      borderRadius: BorderRadius.circular(AppDimensions.r10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cells[0],
          style: const TextStyle(
            fontSize: 12,
            color: IC.text1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            Expanded(
              child: _PreviewPriceValue(label: 'Qty', value: cells[1]),
            ),
            Expanded(
              child: _PreviewPriceValue(label: 'Unit price', value: cells[2]),
            ),
            Expanded(
              child: _PreviewPriceValue(
                label: 'Amount',
                value: cells[3],
                emphasized: true,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _PreviewPriceValue extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const _PreviewPriceValue({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 9.5, color: IC.text3)),
      const SizedBox(height: 2),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          value,
          style: TextStyle(
            fontSize: 11,
            color: emphasized ? IC.accent : IC.text1,
            fontWeight: emphasized ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

class _CreateRepairOrderButton extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  const _CreateRepairOrderButton({required this.onBack});

  @override
  ConsumerState<_CreateRepairOrderButton> createState() =>
      _CreateRepairOrderButtonState();
}

class _CreateRepairOrderButtonState
    extends ConsumerState<_CreateRepairOrderButton> {
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: _submitting
              ? null
              : () async {
                  final state = ref.read(inspectionProvider);
                  if (state.jobCardId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Job Card is missing')),
                    );
                    return;
                  }
                  if (state.serviceLines.isEmpty && state.partLines.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No repair items found. Add extra work or retry after inspection.',
                        ),
                      ),
                    );
                    return;
                  }
                  final advisorApproved = await _chooseApprovalMethod(context);
                  if (advisorApproved == null || !context.mounted) return;
                  setState(() => _submitting = true);
                  try {
                    final detail = await ref
                        .read(advisorRemoteDataSourceProvider)
                        .getJobCard(state.jobCardId);
                    final jobCardId = detail.dbId > 0
                        ? '${detail.dbId}'
                        : state.jobCardId;
                    final response = await ref
                        .read(advisorRemoteDataSourceProvider)
                        .createRepairOrderStrict({
                          'jobCardId': jobCardId,
                          'services': state.serviceLines
                              .map((item) => item.toJson())
                              .toList(),
                          'parts': state.partLines
                              .map((item) => item.toJson())
                              .toList(),
                          'servicesTotal': state.servicesTotal,
                          'partsTotal': state.partsTotal,
                          'grandTotal': state.grandTotal,
                          'tag': state.tag,
                          'customerRequests': state.customerRequests,
                          'garageRecommendations': state.garageRecommendations,
                          'estimatedDelivery': state.estimatedDelivery
                              ?.toIso8601String(),
                          'notifyOwnerSmsEmail': state.notifyOwnerSmsEmail,
                          'advisorApproved': advisorApproved,
                        });
                    if (!context.mounted) return;
                    if (response.id.isEmpty) {
                      throw const UnknownException(
                        'Repair order was not created',
                      );
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          advisorApproved
                              ? 'Estimate approved with the customer'
                              : 'Estimate sent to the customer for approval',
                        ),
                        backgroundColor: IC.accent,
                      ),
                    );
                    ref.read(inspectionProvider.notifier).reset();
                    context.go(AppRoutes.advisorDashboard);
                  } catch (error) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'We could not submit the estimate. Please check your connection and try again.',
                        ),
                      ),
                    );
                  } finally {
                    if (mounted) setState(() => _submitting = false);
                  }
                },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: _submitting ? IC.navy.withValues(alpha: 0.72) : IC.navy,
              borderRadius: BorderRadius.all(
                Radius.circular(AppDimensions.r10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_submitting)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.3,
                      color: Colors.white,
                    ),
                  )
                else
                  const Icon(
                    Icons.send_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                const SizedBox(width: 9),
                Text(
                  _submitting ? 'Submitting Estimate…' : 'Submit Estimate',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _chooseApprovalMethod(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer approval',
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose how the customer will approve this estimate.',
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              _ApprovalMethodTile(
                icon: Icons.handshake_outlined,
                title: 'Customer approved here',
                subtitle:
                    'Use when the customer reviewed and accepted the estimate with you.',
                onTap: () => Navigator.pop(sheetContext, true),
              ),
              const SizedBox(height: 10),
              _ApprovalMethodTile(
                icon: Icons.phone_android_outlined,
                title: 'Send to customer app',
                subtitle:
                    'The job will wait until the customer approves from their account.',
                onTap: () => Navigator.pop(sheetContext, false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApprovalMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ApprovalMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(AppDimensions.r14),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.r14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    ),
  );
}

class _SectionTotal extends StatelessWidget {
  final String label;
  final double amount;
  const _SectionTotal(this.label, this.amount);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: IC.text1,
            ),
          ),
        ),
        Text(
          'AED ${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: IC.text1,
          ),
        ),
      ],
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool bold;
  const _SummaryRow(this.label, this.amount, {this.bold = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: IC.text1,
            ),
          ),
        ),
        Text(
          'AED ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            color: IC.text1,
          ),
        ),
      ],
    ),
  );
}
