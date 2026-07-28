// lib/features/advisor/inspection_pages/repair_order_view.dart

// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/local/sync_providers.dart';
import 'package:hive/hive.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/inspection_model.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/inspection_view_model.dart';
import 'package:staff_app/features/advisor/inspection_pages/presentation/widgets/inspection_widgets.dart';
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
  List<String> _pendingServices = [];
  List<String> _pendingParts = [];
  Map<String, dynamic>? _customerData;

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  void _loadCustomerData() {
    try {
      final box = Hive.box<dynamic>('inspections');
      final all = box.values.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
      final state = ref.read(inspectionProvider);
      final jid = state.jobCardId;
      _customerData = all.cast<Map<String, dynamic>?>().firstWhere(
        (m) => m?['id'] == jid || m?['type'] == 'vehicle_customer',
        orElse: () => null,
      );
    } catch (_) {}
  }

  String _getVal(String key) => _customerData?[key]?.toString() ?? '';

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
          'Repair Order',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => notifier.reset(),
            child: const Text(
              'RESET',
              style: TextStyle(
                color: IC.accent,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
        children: [
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
                            _getVal('phoneNumber'),
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
                            _getVal('registrationNumber').isEmpty
                                ? '${_getVal('make')} ${_getVal('model')}'
                                : _getVal('registrationNumber'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: IC.text1,
                            ),
                          ),
                          Text(
                            _getVal('vin'),
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
                    Text(
                      'Service Advisor',
                      style: TextStyle(fontSize: 11, color: IC.text3),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'swami',
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
                const Text(
                  'Reference Number',
                  style: TextStyle(fontSize: 11, color: IC.text3),
                ),
                const SizedBox(height: 6),
                TextField(
                  onChanged: notifier.setReferenceNumber,
                  style: const TextStyle(fontSize: 13, color: IC.text1),
                  decoration: const InputDecoration(
                    hintText: 'Enter reference number here',
                    hintStyle: TextStyle(fontSize: 13, color: IC.text3),
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Package selection buttons ──────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  [
                        'Choose from Packages',
                        'Maintenance Contract',
                        'Select from History',
                      ]
                      .map(
                        (l) => Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: IC.tealBg,
                            borderRadius: BorderRadius.all(
                              Radius.circular(AppDimensions.r8),
                            ),
                            border: Border.all(color: IC.accent),
                          ),
                          child: Text(
                            l,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: IC.accent,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),

          const SizedBox(height: 12),

          // ── Place of supply ────────────────────────────────────────────
          InfoCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Place Of Supply',
                  style: TextStyle(fontSize: 12, color: IC.text2),
                ),
                Icon(Icons.keyboard_arrow_down, color: IC.text3, size: 18),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── SERVICES section ───────────────────────────────────────────
          _LineItemsCard(
            title: 'SERVICES',
            onAdd: () {
              _pendingServices = state.serviceLines.map((s) => s.name).toList();
              setState(() => _showServices = true);
            },
            children: state.serviceLines
                .asMap()
                .entries
                .map(
                  (e) => _ServiceLineRow(
                    index: e.key,
                    item: e.value,
                    notifier: notifier,
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 12),

          // ── PARTS section ──────────────────────────────────────────────
          _LineItemsCard(
            title: 'PARTS',
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
                          child: Image.file(
                            File(state.preServicePhotos[i]),
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
                SolidBtn(label: '+ ADD', onTap: () {}, small: true),
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

          const SizedBox(height: 16),

          // ── CONTINUE ──────────────────────────────────────────────────
          SolidBtn(
            label: 'CONTINUE',
            onTap: () => context.push(
              AppRoutes.repairOrderPreview,
              extra: {'onBack': () => context.pop()},
            ),
          ),
        ],
      ),
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
  final VoidCallback onAdd;
  final List<Widget> children;
  const _LineItemsCard({
    required this.title,
    required this.onAdd,
    required this.children,
  });

  @override
  Widget build(BuildContext context) => InfoCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: IC.text1,
              ),
            ),
            SolidBtn(label: '+ ADD', onTap: onAdd, small: true),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Apply Discount to all',
              style: TextStyle(fontSize: 11, color: IC.text2),
            ),
            Container(
              width: 36,
              height: 20,
              decoration: BoxDecoration(
                color: IC.stroke,
                borderRadius: BorderRadius.all(
                  Radius.circular(AppDimensions.r10),
                ),
              ),
              padding: const EdgeInsets.all(3),
              alignment: Alignment.centerLeft,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        ...children,
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  SERVICE LINE ROW — with Selling Price column
// ─────────────────────────────────────────────────────────────────────────────
class _ServiceLineRow extends StatelessWidget {
  final int index;
  final ServiceLineItem item;
  final InspectionNotifier notifier;
  const _ServiceLineRow({
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
                onTap: () {},
                child: const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: IC.text3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Column header labels
          Row(
            children: const [
              Expanded(
                child: Text(
                  'Qty',
                  style: TextStyle(fontSize: 9, color: IC.text3),
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Selling Price',
                  style: TextStyle(fontSize: 9, color: IC.text3),
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Disc %',
                  style: TextStyle(fontSize: 9, color: IC.text3),
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Amount',
                  style: TextStyle(fontSize: 9, color: IC.text3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _EditableField(
                  label: '',
                  value: '${item.qty}',
                  onChanged: (v) {
                    final q = int.tryParse(v);
                    if (q != null) notifier.updateServiceLine(index, qty: q);
                  },
                ),
              ),
              const SizedBox(width: 6),
              // ─── Selling Price field ───────────────────────────────────────
              Expanded(
                child: _EditableField(
                  label: '',
                  value: item.rate.toStringAsFixed(2),
                  onChanged: (v) {
                    final r = double.tryParse(v);
                    if (r != null) notifier.updateServiceLine(index, rate: r);
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
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
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AED ${item.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: IC.text1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                onTap: () {},
                child: const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: IC.text3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Column header labels
          Row(
            children: const [
              Expanded(
                child: Text(
                  'Qty',
                  style: TextStyle(fontSize: 9, color: IC.text3),
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Selling Price',
                  style: TextStyle(fontSize: 9, color: IC.text3),
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Disc %',
                  style: TextStyle(fontSize: 9, color: IC.text3),
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Amount',
                  style: TextStyle(fontSize: 9, color: IC.text3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _EditableField(
                  label: '',
                  value: '${item.qty}',
                  onChanged: (v) {
                    final q = int.tryParse(v);
                    if (q != null) notifier.updatePartLine(index, qty: q);
                  },
                ),
              ),
              const SizedBox(width: 6),
              // ─── Selling Price field ───────────────────────────────────────
              Expanded(
                child: _EditableField(
                  label: '',
                  value: item.rate.toStringAsFixed(2),
                  onChanged: (v) {
                    final r = double.tryParse(v);
                    if (r != null) notifier.updatePartLine(index, rate: r);
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
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
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AED ${item.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: IC.text1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  const _EditableField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: 30,
    decoration: BoxDecoration(
      color: IC.canvas,
      borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r6)),
      border: Border.all(color: IC.line),
    ),
    child: TextField(
      controller: TextEditingController(text: value),
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 11, color: IC.text1),
      decoration: const InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  CHOOSE SERVICES VIEW
// ─────────────────────────────────────────────────────────────────────────────
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
      backgroundColor: IC.canvas,
      appBar: AppBar(
        backgroundColor: IC.navy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBack,
        ),
        title: const Text(
          'Choose Services',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: IC.tealBg,
              borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r8)),
            ),
            child: const Icon(Icons.filter_list, color: IC.accent, size: 20),
          ),
          GestureDetector(
            onTap: _confirm,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: IC.accent,
                borderRadius: BorderRadius.all(
                  Radius.circular(AppDimensions.r8),
                ),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SearchField(
              hint: 'Search',
              onChanged: (q) => setState(() => _q = q),
            ),
          ),
          // ── Column headers with Selling Price ──────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: IC.canvas,
              borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r8)),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'SERVICE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: IC.text2,
                    ),
                  ),
                ),
                Text(
                  'SELLING PRICE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: IC.text2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: sel ? IC.tealBg : IC.surface,
                      border: const Border(bottom: BorderSide(color: IC.line)),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: sel ? IC.accent : Colors.transparent,
                            borderRadius: BorderRadius.all(
                              Radius.circular(AppDimensions.r4),
                            ),
                            border: Border.all(
                              color: sel ? IC.accent : IC.stroke,
                              width: 2,
                            ),
                          ),
                          child: sel
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 12,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            s,
                            style: const TextStyle(
                              fontSize: 13,
                              color: IC.text1,
                            ),
                          ),
                        ),
                        // ─── Selling Price value ───────────────────────────────
                        const Text(
                          'AED 0.00',
                          style: TextStyle(
                            fontSize: 12,
                            color: IC.text2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SolidBtn(
              label:
                  'Select ${widget.selected.length} Service${widget.selected.length != 1 ? "s" : ""}',
              onTap: _confirm,
            ),
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
      backgroundColor: IC.canvas,
      appBar: AppBar(
        backgroundColor: IC.navy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBack,
        ),
        title: const Text(
          'Choose Part',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: IC.tealBg,
              borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r8)),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: IC.accent,
              size: 20,
            ),
          ),
          GestureDetector(
            onTap: _confirm,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: IC.accent,
                borderRadius: BorderRadius.all(
                  Radius.circular(AppDimensions.r8),
                ),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SearchField(
              hint: 'Search',
              onChanged: (q) => setState(() => _q = q),
            ),
          ),
          // Column headers — now including SELLING PRICE
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: IC.canvas,
              borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r8)),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'PART INFORMATION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: IC.text2,
                    ),
                  ),
                ),
                Text(
                  'STOCK',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: IC.text2,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'SELLING PRICE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: IC.text2,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'QTY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: IC.text2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: sel ? IC.tealBg : IC.surface,
                      border: const Border(bottom: BorderSide(color: IC.line)),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: sel ? IC.accent : Colors.transparent,
                            borderRadius: BorderRadius.all(
                              Radius.circular(AppDimensions.r4),
                            ),
                            border: Border.all(
                              color: sel ? IC.accent : IC.stroke,
                              width: 2,
                            ),
                          ),
                          child: sel
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 12,
                                )
                              : null,
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
                              const Text(
                                'View Substitutes ▾',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: IC.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          '-',
                          style: TextStyle(fontSize: 11, color: IC.text2),
                        ),
                        const SizedBox(width: 12),
                        // ─── Selling Price value ─────────────────────────────
                        const Text(
                          'AED 0.00',
                          style: TextStyle(
                            fontSize: 12,
                            color: IC.text2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '1',
                          style: TextStyle(fontSize: 12, color: IC.text1),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SolidBtn(
              label: widget.selected.isNotEmpty
                  ? 'Select ${widget.selected.length} Part${widget.selected.length != 1 ? "s" : ""}'
                  : 'Select 0 Part',
              onTap: _confirm,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  REPAIR ORDER PREVIEW
// ─────────────────────────────────────────────────────────────────────────────
class RepairOrderPreviewView extends ConsumerWidget {
  final VoidCallback onBack;
  const RepairOrderPreviewView({super.key, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inspectionProvider);

    return Scaffold(
      backgroundColor: IC.canvas,
      appBar: AppBar(
        backgroundColor: IC.navy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: onBack,
        ),
        title: const Text(
          'Preview',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit, color: IC.accent, size: 14),
            label: const Text(
              'SIGNATURE',
              style: TextStyle(
                color: IC.accent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
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
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_outlined, color: IC.text3, size: 20),
                          Text(
                            'YOUR\nLOGO\nHERE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SWAMI AUTO SERVICES',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: IC.text1,
                            ),
                          ),
                          Text(
                            '--',
                            style: TextStyle(fontSize: 11, color: IC.text2),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 11,
                                color: IC.text3,
                              ),
                              SizedBox(width: 4),
                              // +971 country code
                              Text(
                                '--',
                                style: TextStyle(fontSize: 11, color: IC.text2),
                              ),
                            ],
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 11,
                                color: IC.text3,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '--',
                                style: TextStyle(fontSize: 11, color: IC.text2),
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
                  'Repair Order',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: IC.text1,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: IC.canvas,
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppDimensions.r8),
                    ),
                    border: Border.all(color: IC.line),
                  ),
                  child: Row(
                    children: [
                      _PreviewHeaderCell('CUSTOMER', '--\n--'),
                      _PreviewHeaderCell(
                        'VEHICLE',
                        '--\n--\n--',
                      ),
                      _PreviewHeaderCell(
                        'ESTIMATE',
                        'Apr 5, 2026\n12:59:38\nAmount:\nAED ${state.grandTotal.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
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

          const SizedBox(height: 20),

          _CreateRepairOrderButton(onBack: onBack),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _PreviewHeaderCell extends StatelessWidget {
  final String title;
  final String value;
  const _PreviewHeaderCell(this.title, this.value);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: IC.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: IC.text3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontSize: 10, color: IC.text1, height: 1.4),
          ),
        ],
      ),
    ),
  );
}

class _TableHeader extends StatelessWidget {
  final List<String> cols;
  const _TableHeader(this.cols);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 6),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: IC.line)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            cols[0],
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: IC.text1,
            ),
          ),
        ),
        ...cols
            .skip(1)
            .map(
              (c) => SizedBox(
                width: 70,
                child: Text(
                  c,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: IC.text1,
                  ),
                ),
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(
            cells[0],
            style: const TextStyle(fontSize: 11, color: IC.text1),
          ),
        ),
        ...cells
            .skip(1)
            .map(
              (c) => SizedBox(
                width: 70,
                child: Text(
                  c,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 10, color: IC.text1),
                ),
              ),
            ),
      ],
    ),
  );
}

class _CreateRepairOrderButton extends ConsumerWidget {
  final VoidCallback onBack;
  const _CreateRepairOrderButton({required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final state = ref.read(inspectionProvider);
        final local = GenericLocalDataSource(
          Hive.box<Map<String, dynamic>>('repair_orders'),
        );
        final id = await IdGenerator.nextId('RO');
        await local.save(id, state.toPersistableMap());

        final queue = ref.read(syncQueueProvider);
        final op = SyncOperation(
          id: id,
          entityType: 'repair_order',
          entityId: id,
          changeType: ChangeType.create,
          payload: state.toPersistableMap(),
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );
        await queue.enqueue(op);

        ref.read(syncEngineProvider).syncAll();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Repair Order saved locally'),
              backgroundColor: IC.accent,
              behavior: SnackBarBehavior.floating,
            ),
          );
          onBack();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: IC.navy,
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r10)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              'CREATE REPAIR ORDER',
              style: TextStyle(
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

