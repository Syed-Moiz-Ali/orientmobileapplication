// Phase 09 — Repair Order Studio (Archetype 4).
//
// Sibling of the advisor home radar and the job dossier: greeting-style
// compact header (no app-bar bulk), tappable Parts → Labor → Review stepper,
// sticky 32px category mini-headers, 72px home-grammar rows, collapsible
// Mandatory/Optional tiers, sticky money dock and invoice share sheet.
//
// UI-ONLY CONTRACT: prices, VAT projections, discounts and providers are
// frozen. Line totals come from `ServiceLineItem.amount` /
// `PartLineItem.amount`; studio totals come from
// `InspectionState.servicesTotal/partsTotal`; VAT is the statutory 5%
// display projection in `repair_estimate_math.dart`. Nothing here is
// serialized beyond the pre-existing submit payload, and no provider,
// model, datasource, route or Hive contract is altered.

// ignore_for_file: use_build_context_synchronously

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_models/shared_models.dart' as models;
import 'package:staff_app/core/platform/file_ops.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/inspection_model.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/inspection_view_model.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/widgets/repair_estimate_math.dart';
import 'package:staff_app/features/advisor/presentation/widgets/repair_estimate_share_sheet.dart';
import 'package:staff_app/features/advisor/presentation/widgets/repair_price_breakdown_dock.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import 'advisor_assign_tasks_view.dart';
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
  bool _itemsError = false;
  List<String> _pendingServices = [];
  List<String> _pendingParts = [];
  Map<String, dynamic>? _customerData;

  // Presentation-only studio state (never persisted, never sent).
  String _query = '';
  final ScrollController _scroll = ScrollController();
  final GlobalKey _laborKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _loadGeneratedWorkItems(),
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  // P3 (audit): auto-pricing — suggest a rate from historical quotes for the
  // same service name. A convenience, never a blocker. Payload/behavior
  // byte-identical to the previous composition.
  Future<void> _suggestPrice(
    BuildContext context,
    int index,
    ServiceLineItem item,
    InspectionNotifier notifier,
  ) async {
    final name = item.name.trim();
    final t = StaffLocalizations.of(context)!;
    if (name.isEmpty) {
      _toast(t.advisorStudioSelectServicesTitle);
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
            _toast(
              '${models.MoneyAed((rate).toDouble()).format()} · ${data['samples']}',
              icon: Icons.auto_awesome_rounded,
            );
          } else {
            _toast(
              t.advisorStudioNoServices,
              icon: Icons.info_outline_rounded,
            );
          }
        },
        failure: (_) {
          _toast(t.advisorStudioError, icon: Icons.error_outline_rounded);
        },
      );
    } catch (_) {
      // suggestion is a convenience — ignore failures
    }
  }

  Future<void> _loadGeneratedWorkItems() async {
    if (_loadedGeneratedItems || _loadingGeneratedItems) return;
    final state = ref.read(inspectionProvider);
    if (state.jobCardId.trim().isEmpty) return;
    setState(() {
      _loadingGeneratedItems = true;
      _itemsError = false;
    });
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
      if (mounted) setState(() => _itemsError = true);
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

  void _removeService(int index, String name) {
    HapticFeedback.selectionClick();
    final state = ref.read(inspectionProvider);
    final remaining = state.serviceLines
        .asMap()
        .entries
        .where((e) => e.key != index)
        .map((e) => e.value.name)
        .toList();
    ref.read(inspectionProvider.notifier).addServices(remaining);
    _toast(
      StaffLocalizations.of(context)!.advisorStudioRemoved(name),
      icon: Icons.delete_outline_rounded,
    );
  }

  void _removePart(int index, String name) {
    HapticFeedback.selectionClick();
    final state = ref.read(inspectionProvider);
    final remaining = state.partLines
        .asMap()
        .entries
        .where((e) => e.key != index)
        .map((e) => e.value.name)
        .toList();
    ref.read(inspectionProvider.notifier).addParts(remaining);
    _toast(
      StaffLocalizations.of(context)!.advisorStudioRemoved(name),
      icon: Icons.delete_outline_rounded,
    );
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

    final t = StaffLocalizations.of(context)!;
    final pendingSync =
        ref.watch(advisorPendingSyncCountProvider).valueOrNull ?? 0;

    // Stepper progress grammar: Parts → Labor → Review. Position derives
    // from provider-owned lines only (never invented): empty = Parts,
    // one side filled = Labor, both filled = Review.
    final hasParts = state.partLines.isNotEmpty;
    final hasLabor = state.serviceLines.isNotEmpty;
    final stepIndex = !hasParts && !hasLabor
        ? 0
        : (hasParts && hasLabor ? 2 : 1);

    final q = _query.trim().toLowerCase();
    bool matches(String name) =>
        q.isEmpty || name.toLowerCase().contains(q);

    // Flat search filter over provider lines. No grouping: every service
    // stays in Labor, every part in Parts, so a line can never hide inside
    // a collapsed group the advisor did not open.
    final services = <({int index, ServiceLineItem item})>[
      for (var i = 0; i < state.serviceLines.length; i++)
        if (matches(state.serviceLines[i].name))
          (index: i, item: state.serviceLines[i]),
    ];
    final parts = <({int index, PartLineItem item})>[
      for (var i = 0; i < state.partLines.length; i++)
        if (matches(state.partLines[i].name))
          (index: i, item: state.partLines[i]),
    ];
    final noMatch =
        q.isNotEmpty &&
        services.isEmpty &&
        parts.isEmpty &&
        !_loadingGeneratedItems;

    final lineCount = state.serviceLines.length + state.partLines.length;

    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );
    final maxWidth = context.adaptive.pick(
      compact: double.infinity,
      medium: 640.0,
      expanded: 1180.0,
    );

    final studio = _StudioColumn(
      state: state,
      loading: _loadingGeneratedItems,
      hasError: _itemsError,
      query: _query,
      noMatch: noMatch,
      services: services,
      parts: parts,
      onQuery: (v) => setState(() => _query = v),
      onClearQuery: () => setState(() => _query = ''),
      onAddServices: () {
        HapticFeedback.selectionClick();
        setState(() {
          _pendingServices =
              state.serviceLines.map((s) => s.name).toList();
          _showServices = true;
        });
      },
      onAddParts: () {
        HapticFeedback.selectionClick();
        setState(() {
          _pendingParts = state.partLines.map((p) => p.name).toList();
          _showParts = true;
        });
      },
      onSuggest: (index, item) =>
          _suggestPrice(context, index, item, notifier),
      onRemoveService: _removeService,
      onRemovePart: _removePart,
      onRetry: () {
        setState(() {
          _loadedGeneratedItems = false;
        });
        _loadGeneratedWorkItems();
      },
      laborKey: _laborKey,
    );

    final rail = _StudioRail(
      state: state,
      lineCount: lineCount,
      customerName: _getVal('customerName'),
      phone: _getVal('phoneNumber'),
      vehicleLine: _vehicleTitle,
      plate: _plateNumber,
      onConfirm: () => _openPreview(state),
      onAssign: () {
        HapticFeedback.selectionClick();
        final refId = state.jobCardId;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdvisorAssignTasksView(jobCardRef: refId),
          ),
        );
      },
      onShare: () => _openShare(state),
      onMedia: _addPreServiceMedia,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Product exception (home grammar): no WorkspaceAppBar bulk. The
      // greeting header below owns identity + sync pill + actions, so a
      // second title row would duplicate chrome and steal viewport.
      bottomNavigationBar: wide
          ? null
          : RepairPriceBreakdownDock(
              partsTotal: state.partsTotal,
              laborTotal: state.servicesTotal,
              lineCount: lineCount,
              onConfirm: () => _openPreview(state),
            ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: CustomScrollView(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.s20,
                    AppDimensions.s16,
                    AppDimensions.s20,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _StudioGreetingHeader(
                      vehicleLine: _vehicleTitle,
                      customerName: _getVal('customerName'),
                      plate: _plateNumber,
                      pendingSync: pendingSync,
                      fromInspection: widget.fromInspection,
                      onBack: widget.onBack,
                      onReset: () => _confirmReset(notifier),
                      onShare: () => _openShare(state),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.s20,
                    AppDimensions.s12,
                    AppDimensions.s20,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: AppBreadcrumbs(
                      items: [
                        AppBreadcrumbItem(
                          label: t.advisorNavJobs,
                          onTap: widget.onBack,
                        ),
                        AppBreadcrumbItem.current(t.advisorStudioTitle),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.s20,
                    AppDimensions.s12,
                    AppDimensions.s20,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: AppCard.standard(
                      child: AppStepper(
                        steps: [
                          t.advisorStudioStepParts,
                          t.advisorStudioStepLabor,
                          t.advisorStudioStepReview,
                        ],
                        currentIndex: stepIndex,
                        onStepTap: (i) => _onStepTap(i, state),
                      ),
                    ),
                  ),
                ),
                if (wide)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.s20,
                      AppDimensions.s16,
                      AppDimensions.s20,
                      AppDimensions.s24,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: studio),
                          const SizedBox(width: AppDimensions.s24),
                          Expanded(flex: 2, child: rail),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.s20,
                      AppDimensions.s16,
                      AppDimensions.s20,
                      AppDimensions.s24,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          studio,
                          const SizedBox(height: AppDimensions.s16),
                          _EstimateDetailsCard(
                            state: state,
                            onMedia: _addPreServiceMedia,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onStepTap(int index, InspectionState state) {
    HapticFeedback.selectionClick();
    if (index == 2) {
      _openPreview(state);
      return;
    }
    final target = index == 0 ? null : _laborKey;
    final ctx = target?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: AppMotion.resolve(context, AppMotion.standard),
        curve: AppMotion.standardCurve,
        alignment: 0.05,
      );
    } else {
      _scroll.animateTo(
        0,
        duration: AppMotion.resolve(context, AppMotion.standard),
        curve: AppMotion.standardCurve,
      );
    }
  }

  Future<void> _confirmReset(InspectionNotifier notifier) async {
    final t = StaffLocalizations.of(context)!;
    HapticFeedback.mediumImpact();
    final confirmed = await showAppConfirmationDialog(
      context,
      title: t.advisorStudioResetTitle,
      message: t.advisorStudioResetBody,
      confirmLabel: t.advisorStudioResetConfirm,
      cancelLabel: t.advisorStudioResetKeep,
      icon: Icons.restart_alt_rounded,
      destructive: true,
    );
    if (confirmed) {
      notifier.reset();
      _toast(t.advisorStudioResetConfirm, icon: Icons.check_rounded);
    }
  }

  void _openPreview(InspectionState state) {
    final t = StaffLocalizations.of(context)!;
    if (state.serviceLines.isEmpty && state.partLines.isEmpty) {
      HapticFeedback.selectionClick();
      _toast(t.advisorEstimateNoItems, icon: Icons.info_outline_rounded);
      return;
    }
    HapticFeedback.selectionClick();
    context.push(
      AppRoutes.repairOrderPreview,
      extra: {'onBack': () => context.pop()},
    );
  }

  void _openShare(InspectionState state) {
    final t = StaffLocalizations.of(context)!;
    HapticFeedback.selectionClick();
    final data = _invoiceData(state);
    final phone = _getVal('phoneNumber').trim();
    final digits = models.PhoneNumber.normalizeLoose(phone);
    showAppModalSheet<void>(
      context: context,
      builder: (sheetContext) => RepairEstimateShareSheet(
        data: data,
        canShareWhatsApp: digits.isNotEmpty,
        onShareWhatsApp: () {
          Navigator.pop(sheetContext);
          _shareWhatsApp(digits, state);
        },
        onCopyLink: () {
          Navigator.pop(sheetContext);
          Clipboard.setData(
            ClipboardData(text: _estimateLink(state)),
          );
          _toast(
            t.advisorEstimateLinkCopied,
            icon: Icons.link_rounded,
            color: context.semanticColors.success.base,
          );
        },
      ),
    );
  }

  RepairInvoiceData _invoiceData(InspectionState state) {
    final t = StaffLocalizations.of(context)!;
    final brand = ref.read(brandConfigProvider);
    final now = MaterialLocalizations.of(context).formatMediumDate(
      DateTime.now(),
    );
    RepairInvoiceLine serviceLine(ServiceLineItem s) => RepairInvoiceLine(
      name: s.name,
      detail:
          '${s.qty} × ${models.MoneyAed(s.rate).format(arabic: _isArabic())}',
      amount: s.amount,
    );
    RepairInvoiceLine partLine(PartLineItem p) => RepairInvoiceLine(
      name: p.name,
      detail:
          '${p.qty} × ${models.MoneyAed(p.rate).format(arabic: _isArabic())}',
      amount: p.amount,
    );
    return RepairInvoiceData(
      workshopName: brand.appName,
      workshopIcon: brand.icon,
      workshopMeta: _getVal('address'),
      customerName: _getVal('customerName'),
      customerPhone: _getVal('phoneNumber'),
      vehicleLine: _vehicleTitle,
      plate: _plateNumber,
      preparedOn: now,
      groups: [
        RepairInvoiceGroup(
          title: t.advisorStudioTierMandatory,
          lines: [
            for (final s in state.serviceLines)
              if (classifyRepairTier(s.name) == RepairTier.mandatory)
                serviceLine(s),
            for (final p in state.partLines)
              if (classifyRepairTier(p.name) == RepairTier.mandatory)
                partLine(p),
          ],
        ),
        RepairInvoiceGroup(
          title: t.advisorStudioTierOptional,
          lines: [
            for (final s in state.serviceLines)
              if (classifyRepairTier(s.name) == RepairTier.optional)
                serviceLine(s),
            for (final p in state.partLines)
              if (classifyRepairTier(p.name) == RepairTier.optional)
                partLine(p),
          ],
        ),
      ],
      partsTotal: state.partsTotal,
      servicesTotal: state.servicesTotal,
    );
  }

  bool _isArabic() =>
      AppTypography.isArabic(Localizations.maybeLocaleOf(context));

  String _estimateLink(InspectionState state) =>
      'https://orient.workshop/estimates/${state.jobCardId.isEmpty ? 'draft' : state.jobCardId}';

  void _shareWhatsApp(String digits, InspectionState state) {
    final t = StaffLocalizations.of(context)!;
    final totals = RepairEstimateTotals.from(
      partsTotal: state.partsTotal,
      laborTotal: state.servicesTotal,
    );
    final text = Uri.encodeComponent(
      '${t.advisorStudioTitle} · ${models.MoneyAed(totals.total).format()} · ${_estimateLink(state)}',
    );
    HapticFeedback.lightImpact();
    launchUrl(Uri.parse('https://wa.me/$digits?text=$text'));
    _toast(
      t.advisorToastOpeningWhatsApp,
      icon: Icons.chat_outlined,
      color: context.semanticColors.success.base,
    );
  }

  Future<void> _addPreServiceMedia() async {
    final t = StaffLocalizations.of(context)!;
    final choice = await showAppModalSheet<String>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.s16,
              AppDimensions.s8,
              AppDimensions.s16,
              AppDimensions.s12,
            ),
            child: Text(
              t.advisorStudioMedia,
              style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _MediaOption(
            icon: Icons.camera_alt_outlined,
            label: t.advisorStudioMediaCamera,
            value: 'camera',
          ),
          _MediaOption(
            icon: Icons.photo_library_outlined,
            label: t.advisorStudioMediaGallery,
            value: 'gallery',
          ),
          _MediaOption(
            icon: Icons.videocam_outlined,
            label: t.advisorStudioMediaVideo,
            value: 'video',
          ),
          const SizedBox(height: AppDimensions.s12),
        ],
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
        final t2 = StaffLocalizations.of(context)!;
        _toast(
          t2.advisorDispatchError(e.toString()),
          icon: Icons.error_outline_rounded,
          color: Theme.of(context).colorScheme.error,
        );
      }
    }
  }
}

// ─── GREETING HEADER (home grammar, pushed variant) ──────────────────────────
// Compact identity row: back + title/context + Synced pill + reset/share.
// No WorkspaceAppBar bulk by the home product exception; breadcrumbs below
// carry the pushed wayfinding instead.
class _StudioGreetingHeader extends StatelessWidget {
  final String vehicleLine;
  final String customerName;
  final String plate;
  final int pendingSync;
  final bool fromInspection;
  final VoidCallback onBack;
  final VoidCallback onReset;
  final VoidCallback onShare;

  const _StudioGreetingHeader({
    required this.vehicleLine,
    required this.customerName,
    required this.plate,
    required this.pendingSync,
    required this.fromInspection,
    required this.onBack,
    required this.onReset,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final contextLine = [
      if (customerName.trim().isNotEmpty) customerName.trim(),
      if (vehicleLine.trim().isNotEmpty) vehicleLine.trim(),
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                onBack();
              },
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              icon: const Icon(Icons.arrow_back_rounded),
              color: colors.onSurfaceVariant,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.advisorStudioTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (contextLine.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.s4),
                    Text(
                      contextLine,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (plate.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.s6),
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
                          plate.toUpperCase(),
                          style: AppTextStyles.mono(color: colors.onSurface),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.s8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                OfflineStatusPill(pendingSyncCount: pendingSync),
                const SizedBox(height: AppDimensions.s8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        onReset();
                      },
                      tooltip: t.advisorStudioReset,
                      icon: const Icon(Icons.restart_alt_rounded),
                      color: colors.onSurfaceVariant,
                    ),
                    IconButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        onShare();
                      },
                      tooltip: t.advisorEstimateShareTitle,
                      icon: const Icon(Icons.ios_share_rounded),
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        if (fromInspection) ...[
          const SizedBox(height: AppDimensions.s12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.s14,
              vertical: AppDimensions.s10,
            ),
            decoration: BoxDecoration(
              color: context.semanticColors.success.subtle,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(
                color: context.semanticColors.success.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: context.semanticColors.success.base,
                  size: AppDimensions.iconSm,
                ),
                const SizedBox(width: AppDimensions.s8),
                Expanded(
                  child: Text(
                    t.advisorStudioFromInspection,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.semanticColors.success.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ─── STUDIO COLUMN (flat Parts + Labor sections) ─────────────────────────────
// One section per category, always fully visible: Parts, then Labor, then
// the Sublet note. The Add action sits at the end of its own section —
// reachable whether the section is empty or already has lines.
class _StudioColumn extends StatelessWidget {
  final InspectionState state;
  final bool loading;
  final bool hasError;
  final String query;
  final bool noMatch;
  final List<({int index, ServiceLineItem item})> services;
  final List<({int index, PartLineItem item})> parts;
  final ValueChanged<String> onQuery;
  final VoidCallback onClearQuery;
  final VoidCallback onAddServices;
  final VoidCallback onAddParts;
  final void Function(int index, ServiceLineItem item) onSuggest;
  final void Function(int index, String name) onRemoveService;
  final void Function(int index, String name) onRemovePart;
  final VoidCallback onRetry;
  final GlobalKey laborKey;

  const _StudioColumn({
    required this.state,
    required this.loading,
    required this.hasError,
    required this.query,
    required this.noMatch,
    required this.services,
    required this.parts,
    required this.onQuery,
    required this.onClearQuery,
    required this.onAddServices,
    required this.onAddParts,
    required this.onSuggest,
    required this.onRemoveService,
    required this.onRemovePart,
    required this.onRetry,
    required this.laborKey,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSearchField(
          hintText: t.advisorActionSearchTitle,
          onChanged: onQuery,
          onClear: onClearQuery,
        ),
        const SizedBox(height: AppDimensions.s16),
        if (loading)
          const _StudioSkeleton()
        else if (hasError &&
            state.serviceLines.isEmpty &&
            state.partLines.isEmpty)
          EmptyState.error(
            message: t.advisorStudioError,
            onRetry: onRetry,
          )
        else if (noMatch)
          EmptyState.noMatch(
            message: t.advisorStudioNoMatch,
            actionLabel: t.advisorActionClose,
            onAction: onClearQuery,
          )
        else ...[
          _CategorySection(
            kind: _CategoryKind.parts,
            lines: parts,
            onAdd: onAddParts,
            row: (entry) => _StudioPartRow(
              index: entry.index,
              item: entry.item,
              onRemove: () => onRemovePart(entry.index, entry.item.name),
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          Container(
            key: laborKey,
            child: _CategorySection(
              kind: _CategoryKind.labor,
              lines: services,
              onAdd: onAddServices,
              row: (entry) => _StudioLaborRow(
                index: entry.index,
                item: entry.item,
                onSuggest: () => onSuggest(entry.index, entry.item),
                onRemove: () =>
                    onRemoveService(entry.index, entry.item.name),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          const _SubletSection(),
        ],
      ],
    );
  }
}

enum _CategoryKind { parts, labor }

class _CategorySection<T> extends StatelessWidget {
  final _CategoryKind kind;
  final List<T> lines;
  final VoidCallback onAdd;
  final Widget Function(T entry) row;

  const _CategorySection({
    required this.kind,
    required this.lines,
    required this.onAdd,
    required this.row,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final title = kind == _CategoryKind.parts
        ? t.advisorStudioCategoryParts
        : t.advisorStudioCategoryLabor;
    final icon = kind == _CategoryKind.parts
        ? Icons.settings_outlined
        : Icons.build_outlined;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 32px section mini-header (sticky when this column scrolls inside
        // the studio CustomScrollView via the parent slivers; fixed 32px
        // geometry here so skeleton and content share one rhythm).
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s12),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          ),
          child: Row(
            children: [
              Icon(icon, size: AppDimensions.iconSm, color: colors.primary),
              const SizedBox(width: AppDimensions.s8),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurfaceVariant,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Text(
                '${lines.length}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.s8),
        if (lines.isEmpty)
          // Empty category states what is missing; the Add action below
          // stays visible so the picker is always one tap away.
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.s8),
            child: Text(
              t.advisorStudioEmptyCategory(title),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          )
        else
          // Home divider-row grammar: 1px dividers, never cards-per-row.
          Column(
            children: [
              for (var i = 0; i < lines.length; i++) ...[
                if (i > 0) Divider(height: 1, color: colors.outlineVariant),
                row(lines[i]),
              ],
            ],
          ),
        // Always visible: the service/part picker stays reachable whether
        // the section is empty or already has lines. Primary-tinted outline
        // so the action reads as a button, not body text.
        SecondaryButton(
          label: t.advisorStudioAddItem(title),
          leadingIcon: Icons.add_rounded,
          foregroundColor: colors.primary,
          borderColor: colors.primary,
          onPressed: onAdd,
        ),
      ],
    );
  }
}

class _SubletSection extends StatelessWidget {
  const _SubletSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s12),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          ),
          child: Row(
            children: [
              Icon(
                Icons.handyman_outlined,
                size: AppDimensions.iconSm,
                color: colors.primary,
              ),
              const SizedBox(width: AppDimensions.s8),
              Expanded(
                child: Text(
                  t.advisorStudioCategorySublet.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurfaceVariant,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.s8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s12,
            vertical: AppDimensions.s14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Text(
            t.advisorStudioSubletHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── ROW PRICING FIELDS (rate + discount %, provider-owned) ─────────────────
// Same writes as the previous composition (`updateXLine` rate /
// discountPct); the frozen `amount` getter keeps owning the math. Compact
// ≥44px fields with localized labels. Controllers use a _dirty guard so
// provider rebuilds (e.g. qty stepper taps) never steal keystrokes.
class _RowPricingFields extends StatefulWidget {
  final double rate;
  final double discountPercent;
  final ValueChanged<double> onRate;
  final ValueChanged<double> onDiscount;

  const _RowPricingFields({
    required this.rate,
    required this.discountPercent,
    required this.onRate,
    required this.onDiscount,
  });

  @override
  State<_RowPricingFields> createState() => _RowPricingFieldsState();
}

class _RowPricingFieldsState extends State<_RowPricingFields> {
  late final TextEditingController _rateCtrl = TextEditingController(
    text: widget.rate.toStringAsFixed(2),
  );
  late final TextEditingController _discCtrl = TextEditingController(
    text: widget.discountPercent.toStringAsFixed(0),
  );
  bool _rateDirty = false;
  bool _discDirty = false;

  @override
  void didUpdateWidget(covariant _RowPricingFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rate != widget.rate && !_rateDirty) {
      _rateCtrl.text = widget.rate.toStringAsFixed(2);
    }
    if (oldWidget.discountPercent != widget.discountPercent && !_discDirty) {
      _discCtrl.text = widget.discountPercent.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _rateCtrl.dispose();
    _discCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: colors.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );

    Widget field({
      required TextEditingController controller,
      required ValueChanged<String> onChanged,
      String? suffixText,
    }) =>
        Container(
          constraints: const BoxConstraints(minHeight: 44),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            decoration: InputDecoration(
              isDense: true,
              suffixText: suffixText,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.s10,
                vertical: AppDimensions.s12,
              ),
            ),
          ),
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.advisorStudioUnitPrice,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: labelStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.s4),
              field(
                controller: _rateCtrl,
                onChanged: (v) {
                  _rateDirty = true;
                  final r = double.tryParse(v);
                  if (r != null) widget.onRate(r);
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.s10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.advisorStudioDiscountPct,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: labelStyle,
              ),
              const SizedBox(height: AppDimensions.s4),
              field(
                controller: _discCtrl,
                suffixText: '%',
                onChanged: (v) {
                  _discDirty = true;
                  final d = double.tryParse(v);
                  if (d != null) widget.onDiscount(d);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── STUDIO ROWS (home row grammar, 72px) ────────────────────────────────────
// Title 15/600 + meta 12 muted LTR + right line-total tabular. Parts add
// stock pill + qty stepper + rate/discount; labor adds hours × rate + tech
// avatar + rate/discount + price suggest. Min-height 72 keeps 1.3x clean.
class _StudioPartRow extends ConsumerWidget {
  final int index;
  final PartLineItem item;
  final VoidCallback onRemove;

  const _StudioPartRow({
    required this.index,
    required this.item,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final arabic = AppTypography.isArabic(Localizations.maybeLocaleOf(context));
    final inStock = inStockFor(item.name);
    final money = models.MoneyAed(item.amount).format(arabic: arabic);
    final unit = models.MoneyAed(item.rate).format(arabic: arabic);

    return Semantics(
      button: false,
      label: '${item.name}, $money',
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 72),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s12,
            vertical: AppDimensions.s12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle(
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s8),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      money,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        fontFeatures: [
                          FontFeature.tabularFigures(),
                        ],
                      ).copyWith(color: colors.onSurface),
                      semanticsLabel:
                          '${t.advisorStudioLineTotal} $money',
                    ),
                  ),
                  IconButton(
                    onPressed: onRemove,
                    tooltip: t.advisorStudioRemoveItem,
                    icon: const Icon(Icons.close_rounded),
                    iconSize: AppDimensions.iconSm,
                    color: colors.onSurfaceVariant,
                    constraints: const BoxConstraints(
                      minWidth: AppDimensions.touchTarget,
                      minHeight: AppDimensions.touchTarget,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.s4),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '${item.qty} × $unit',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                    fontFeatures: const [
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ),
                      const SizedBox(height: AppDimensions.s8),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppDimensions.s8,
                        runSpacing: AppDimensions.s8,
                        children: [
                          if (inStock)
                            StatusPill.success(
                              t.advisorStudioStockIn(stockBayFor(item.name)),
                            )
                          else
                            StatusPill.warning(
                              t.advisorStudioStockOrder(
                                orderEtaFor(item.name),
                              ),
                            ),
                          AppQuantityStepper(
                            value: item.qty.toDouble(),
                            min: 1,
                            max: 99,
                            semanticLabel: t.advisorStudioQuantity,
                            onChanged: (v) => ref
                                .read(inspectionProvider.notifier)
                                .updatePartLine(index, qty: v.toInt()),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.s10),
                      _RowPricingFields(
                        rate: item.rate,
                        discountPercent: item.discountPercent,
                        onRate: (r) => ref
                            .read(inspectionProvider.notifier)
                            .updatePartLine(index, rate: r),
                        onDiscount: (d) => ref
                            .read(inspectionProvider.notifier)
                            .updatePartLine(index, discountPct: d),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}

class _StudioLaborRow extends ConsumerWidget {
  final int index;
  final ServiceLineItem item;
  final VoidCallback onSuggest;
  final VoidCallback onRemove;

  const _StudioLaborRow({
    required this.index,
    required this.item,
    required this.onSuggest,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final arabic = AppTypography.isArabic(Localizations.maybeLocaleOf(context));
    final money = models.MoneyAed(item.amount).format(arabic: arabic);
    final rate = models.MoneyAed(item.rate).format(arabic: arabic);
    final initial = item.name.trim().isEmpty
        ? '?'
        : item.name.trim().substring(0, 1).toUpperCase();

    return Semantics(
      button: false,
      label: '${item.name}, $money',
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 72),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s12,
            vertical: AppDimensions.s12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initial,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.s10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.cardTitle(
                                    color: colors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(
                                    t.advisorStudioLaborDetail(
                                      '${item.qty}h',
                                      rate,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 12,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppDimensions.s8),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              money,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                fontFeatures: [
                                  FontFeature.tabularFigures(),
                                ],
                              ).copyWith(color: colors.onSurface),
                              semanticsLabel:
                                  '${t.advisorStudioLineTotal} $money',
                            ),
                          ),
                          IconButton(
                            onPressed: onRemove,
                            tooltip: t.advisorStudioRemoveItem,
                            icon: const Icon(Icons.close_rounded),
                            iconSize: AppDimensions.iconSm,
                            color: colors.onSurfaceVariant,
                            constraints: const BoxConstraints(
                              minWidth: AppDimensions.touchTarget,
                              minHeight: AppDimensions.touchTarget,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.s8),
                      Row(
                        children: [
                          AppQuantityStepper(
                            value: item.qty.toDouble(),
                            min: 1,
                            max: 99,
                            semanticLabel: t.advisorStudioQuantity,
                            onChanged: (v) => ref
                                .read(inspectionProvider.notifier)
                                .updateServiceLine(index, qty: v.toInt()),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              onSuggest();
                            },
                            tooltip: t.advisorStudioSuggestPrice,
                            icon: const Icon(Icons.auto_awesome_rounded),
                            iconSize: AppDimensions.iconSm,
                            color: colors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.s10),
                      _RowPricingFields(
                        rate: item.rate,
                        discountPercent: item.discountPercent,
                        onRate: (r) => ref
                            .read(inspectionProvider.notifier)
                            .updateServiceLine(index, rate: r),
                        onDiscount: (d) => ref
                            .read(inspectionProvider.notifier)
                            .updateServiceLine(index, discountPct: d),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}

// ─── SKELETON (mirrors 72px row geometry) ────────────────────────────────────
class _StudioSkeleton extends StatelessWidget {
  const _StudioSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSkeleton.text(width: 180),
        const SizedBox(height: AppDimensions.s12),
        AppCard.standard(
          child: Column(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0)
                  const Divider(height: AppDimensions.s24),
                const Row(
                  children: [
                    AppSkeleton.circle(size: 36),
                    SizedBox(width: AppDimensions.s10),
                    Expanded(
                      child: AppSkeleton.textBlock(lines: 2),
                    ),
                    SizedBox(width: AppDimensions.s8),
                    AppSkeleton.text(width: 72),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── STUDIO RAIL (desktop 40%: totals + assign) ──────────────────────────────
class _StudioRail extends StatelessWidget {
  final InspectionState state;
  final int lineCount;
  final String customerName;
  final String phone;
  final String vehicleLine;
  final String plate;
  final VoidCallback onConfirm;
  final VoidCallback onAssign;
  final VoidCallback onShare;
  final VoidCallback onMedia;

  const _StudioRail({
    required this.state,
    required this.lineCount,
    required this.customerName,
    required this.phone,
    required this.vehicleLine,
    required this.plate,
    required this.onConfirm,
    required this.onAssign,
    required this.onShare,
    required this.onMedia,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RepairPriceBreakdownDock(
          partsTotal: state.partsTotal,
          laborTotal: state.servicesTotal,
          lineCount: lineCount,
          onConfirm: onConfirm,
        ),
        const SizedBox(height: AppDimensions.s16),
        AppCard.standard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                title: t.advisorDispatchTechnicianSection,
                subtitle: t.advisorDispatchSubtitle,
                leadingIcon: Icons.engineering_outlined,
              ),
              SecondaryButton(
                label: t.advisorActionAssignTechnician,
                leadingIcon: Icons.assignment_ind_outlined,
                onPressed: onAssign,
              ),
              const SizedBox(height: AppDimensions.s8),
              SecondaryButton(
                label: t.advisorEstimateShareTitle,
                leadingIcon: Icons.ios_share_rounded,
                onPressed: onShare,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.s16),
        _EstimateDetailsCard(state: state, onMedia: onMedia),
      ],
    );
  }
}

// ─── ESTIMATE DETAILS (reference/recommendations/delivery/notify/media) ─────
// Same provider fields as the previous composition; recomposed as a dossier
// section with shared inputs. Controllers live in State (AppTextField owns
// no initialValue) and resync when the provider is reset underneath them.
// Tag and customer requests have no editor here (payload keys stay frozen);
// media uses the shared pre-service picker. No contract change.
class _EstimateDetailsCard extends ConsumerStatefulWidget {
  final InspectionState state;
  final VoidCallback onMedia;

  const _EstimateDetailsCard({required this.state, required this.onMedia});

  @override
  ConsumerState<_EstimateDetailsCard> createState() =>
      _EstimateDetailsCardState();
}

class _EstimateDetailsCardState extends ConsumerState<_EstimateDetailsCard> {
  late final TextEditingController _refCtrl = TextEditingController(
    text: widget.state.referenceNumber,
  );
  late final TextEditingController _recCtrl = TextEditingController(
    text: widget.state.garageRecommendations,
  );

  @override
  void dispose() {
    _refCtrl.dispose();
    _recCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _EstimateDetailsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Resync after a provider reset (both fields cleared at once). Customer
    // requests has no editor here (payload key stays frozen).
    if (widget.state.referenceNumber.isEmpty &&
        widget.state.garageRecommendations.isEmpty) {
      if (_refCtrl.text.isNotEmpty) _refCtrl.clear();
      if (_recCtrl.text.isNotEmpty) _recCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final notifier = ref.read(inspectionProvider.notifier);
    final state = widget.state;
    final delivery = state.estimatedDelivery;
    final deliveryLabel = delivery == null
        ? t.advisorStudioDeliveryPick
        : MaterialLocalizations.of(
            context,
          ).formatMediumDate(delivery);

    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: t.advisorStudioDetails,
            leadingIcon: Icons.description_outlined,
          ),
          AppTextField(
            controller: _refCtrl,
            hint: t.advisorStudioReferenceHint,
            label: t.advisorStudioReference,
            prefixIcon: Icons.numbers_rounded,
            onChanged: notifier.setReferenceNumber,
          ),
          const SizedBox(height: AppDimensions.s12),
          AppTextField(
            controller: _recCtrl,
            hint: t.advisorStudioRecommendationsHint,
            label: t.advisorStudioRecommendations,
            maxLines: 2,
            onChanged: notifier.setGarageRecommendations,
          ),
          const SizedBox(height: AppDimensions.s12),
          Row(
            children: [
              Expanded(
                child: Text(
                  t.advisorStudioDelivery,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.s8),
              SecondaryButton(
                label: deliveryLabel,
                leadingIcon: Icons.event_outlined,
                isExpanded: false,
                onPressed: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate:
                        delivery ?? DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (d != null && context.mounted) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      notifier.setEstimatedDelivery(
                        DateTime(d.year, d.month, d.day, time.hour, time.minute),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s12),
          Row(
            children: [
              Expanded(
                child: Text(
                  t.advisorStudioNotify,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ),
              Switch.adaptive(
                value: state.notifyOwnerSmsEmail,
                onChanged: (_) => notifier.toggleNotifyOwnerSmsEmail(),
              ),
            ],
          ),
          if (state.preServicePhotos.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s12),
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.preServicePhotos.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppDimensions.s8),
                itemBuilder: (_, i) => Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusControl,
                    ),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusControl,
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
          const SizedBox(height: AppDimensions.s12),
          SecondaryButton(
            label: t.advisorStudioMediaAdd,
            leadingIcon: Icons.add_a_photo_outlined,
            onPressed: widget.onMedia,
          ),
        ],
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
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s16,
        vertical: AppDimensions.s4,
      ),
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        child: InkWell(
          onTap: () => Navigator.pop(context, value),
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.s16,
              vertical: AppDimensions.s14,
            ),
            child: Row(
              children: [
                Icon(icon, color: colors.primary, size: AppDimensions.iconMd),
                const SizedBox(width: AppDimensions.s12),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── PICKERS (services / parts) ─────────────────────────────────────────────
// Same provider writes (`addServices`/`addParts`); recomposed in home
// grammar with AppSearchField + 48dp rows + shared empty states.
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    return AppCard.standard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
            ),
            child: Icon(icon, color: colors.primary, size: 21),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.s10,
              vertical: AppDimensions.s6,
            ),
            decoration: BoxDecoration(
              color: selectedCount > 0
                  ? colors.primary
                  : colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            ),
            child: Text(
              t.advisorStudioSelectedCount(selectedCount),
              style: theme.textTheme.labelSmall?.copyWith(
                color: selectedCount > 0
                    ? colors.onPrimary
                    : colors.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
    HapticFeedback.selectionClick();
    widget.notifier.addServices(List.from(widget.selected));
    widget.onBack();
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final items = kServiceList
        .where((s) => s.toLowerCase().contains(_q.toLowerCase()))
        .toList();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: widget.onBack,
        ),
        title: Text(
          t.advisorStudioSelectServicesTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: _SelectionIntro(
              icon: Icons.build_outlined,
              title: t.advisorStudioSelectServicesTitle,
              subtitle: t.advisorStudioSelectServicesSubtitle,
              selectedCount: widget.selected.length,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: AppSearchField(
              hintText: t.advisorStudioSearchServices,
              onChanged: (q) => setState(() => _q = q),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? EmptyState.noMatch(message: t.advisorStudioNoServices)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final s = items[i];
                      final sel = widget.selected.contains(s);
                      return _PickerRow(
                        title: s,
                        selected: sel,
                        icon: Icons.build_outlined,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          widget.onToggle(s);
                          setState(() {});
                        },
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: PrimaryButton(
                label: widget.selected.isEmpty
                    ? t.advisorStudioDone
                    : t.advisorStudioAddSelectedServices,
                icon: Icons.check_rounded,
                onPressed: _confirm,
                isExpanded: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
    HapticFeedback.selectionClick();
    widget.notifier.addParts(List.from(widget.selected));
    widget.onBack();
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final items = kPartList
        .where((p) => p.toLowerCase().contains(_q.toLowerCase()))
        .toList();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: widget.onBack,
        ),
        title: Text(
          t.advisorStudioSelectPartsTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: _SelectionIntro(
              icon: Icons.settings_outlined,
              title: t.advisorStudioSelectPartsTitle,
              subtitle: t.advisorStudioSelectPartsSubtitle,
              selectedCount: widget.selected.length,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: AppSearchField(
              hintText: t.advisorStudioSearchParts,
              onChanged: (q) => setState(() => _q = q),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? EmptyState.noMatch(message: t.advisorStudioNoParts)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final p = items[i];
                      final sel = widget.selected.contains(p);
                      return _PickerRow(
                        title: p,
                        selected: sel,
                        icon: Icons.settings_outlined,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          widget.onToggle(p);
                          setState(() {});
                        },
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: PrimaryButton(
                label: widget.selected.isEmpty
                    ? t.advisorStudioDone
                    : t.advisorStudioAddSelectedParts,
                icon: Icons.check_rounded,
                onPressed: _confirm,
                isExpanded: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  final String title;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerRow({
    required this.title,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.s8),
      child: Material(
        color: selected
            ? colors.primary.withValues(alpha: 0.08)
            : colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          side: BorderSide(
            color: selected ? colors.primary : colors.outlineVariant,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppDimensions.touchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.s14,
                vertical: AppDimensions.s12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: selected
                          ? colors.primary
                          : colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusControl,
                      ),
                    ),
                    child: Icon(
                      selected ? Icons.check_rounded : icon,
                      // FIXED-INK: white glyph on the saturated primary
                      // selected fill; muted ink otherwise.
                      color: selected
                          ? colors.onPrimary
                          : colors.onSurfaceVariant,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          selected
                              ? t.advisorStudioAdded
                              : t.advisorStudioTapToAdd,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: selected
                                ? colors.primary
                                : colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.add_circle_outline_rounded,
                    color: selected ? colors.primary : colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── REVIEW (invoice document + signature + submit) ──────────────────────────
// Same submit payload as the previous composition (services/parts/totals/
// notes/delivery/notify/advisorApproved); recomposed as a formal invoice
// with the shared RepairInvoicePreview + share actions.
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
  bool _submitting = false;

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

  bool _isArabic() =>
      AppTypography.isArabic(Localizations.maybeLocaleOf(context));

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

  Future<void> _captureSignature() async {
    final result = await showAppModalSheet<Uint8List>(
      context: context,
      builder: (_) => const _SignaturePadSheet(),
    );
    if (result == null || !mounted || result.isEmpty) return;
    setState(() => _signatureBytes = result);
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

  RepairInvoiceData _invoiceData(InspectionState state) {
    final t = StaffLocalizations.of(context)!;
    final brand = ref.read(brandConfigProvider);
    final now = MaterialLocalizations.of(
      context,
    ).formatMediumDate(DateTime.now());
    final vehicle =
        '${_getVal('make')} ${_getVal('model')}'.trim().isEmpty
        ? _getVal('vehicleInfo')
        : '${_getVal('make')} ${_getVal('model')}'.trim();
    RepairInvoiceLine serviceLine(ServiceLineItem s) => RepairInvoiceLine(
      name: s.name,
      detail:
          '${s.qty} × ${models.MoneyAed(s.rate).format(arabic: _isArabic())}',
      amount: s.amount,
    );
    RepairInvoiceLine partLine(PartLineItem p) => RepairInvoiceLine(
      name: p.name,
      detail:
          '${p.qty} × ${models.MoneyAed(p.rate).format(arabic: _isArabic())}',
      amount: p.amount,
    );
    return RepairInvoiceData(
      workshopName: brand.appName,
      workshopIcon: brand.icon,
      workshopMeta: _getVal('address'),
      customerName: _getVal('customerName'),
      customerPhone: _getVal('phoneNumber'),
      vehicleLine: vehicle,
      plate: _getVal('registrationNumber'),
      preparedOn: now,
      groups: [
        RepairInvoiceGroup(
          title: t.advisorStudioTierMandatory,
          lines: [
            for (final s in state.serviceLines)
              if (classifyRepairTier(s.name) == RepairTier.mandatory)
                serviceLine(s),
            for (final p in state.partLines)
              if (classifyRepairTier(p.name) == RepairTier.mandatory)
                partLine(p),
          ],
        ),
        RepairInvoiceGroup(
          title: t.advisorStudioTierOptional,
          lines: [
            for (final s in state.serviceLines)
              if (classifyRepairTier(s.name) == RepairTier.optional)
                serviceLine(s),
            for (final p in state.partLines)
              if (classifyRepairTier(p.name) == RepairTier.optional)
                partLine(p),
          ],
        ),
      ],
      partsTotal: state.partsTotal,
      servicesTotal: state.servicesTotal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inspectionProvider);
    final t = StaffLocalizations.of(context)!;
    final pendingSync =
        ref.watch(advisorPendingSyncCountProvider).valueOrNull ?? 0;
    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );

    final doc = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RepairInvoicePreview(data: _invoiceData(state)),
        if (_signatureBytes != null) ...[
          const SizedBox(height: AppDimensions.s12),
          AppCard.outlined(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.advisorEstimateSignatureLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: AppDimensions.s6),
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
    );

    final actions = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard.standard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                title: t.advisorEstimateSignatureTitle,
                leadingIcon: Icons.draw_outlined,
              ),
              SecondaryButton(
                label: _signatureBytes == null
                    ? t.advisorEstimateAddSignature
                    : t.advisorEstimateSigned,
                leadingIcon: _signatureBytes == null
                    ? Icons.draw_outlined
                    : Icons.check_circle_rounded,
                onPressed: _captureSignature,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.s16),
        PrimaryButton(
          label: t.advisorEstimateCreateOrder,
          icon: Icons.send_outlined,
          isLoading: _submitting,
          onPressed: _submitting ? null : () => _submit(state),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: WorkspaceAppBar(
        title: t.advisorEstimateReviewTitle,
        subtitle: _getVal('customerName').isEmpty
            ? t.advisorStudioTitle
            : _getVal('customerName'),
        showBack: true,
        onBack: _submitting ? null : widget.onBack,
        frosted: !context.isCompact,
        showOfflineStatus: true,
        offlinePendingCount: pendingSync,
      ),
      bottomNavigationBar: wide
          ? null
          : SafeArea(
              top: false,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.s16,
                  AppDimensions.s12,
                  AppDimensions.s16,
                  AppDimensions.s12,
                ),
                child: PrimaryButton(
                  label: t.advisorEstimateCreateOrder,
                  icon: Icons.send_outlined,
                  isLoading: _submitting,
                  onPressed: _submitting ? null : () => _submit(state),
                ),
              ),
            ),
      body: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppPageHeader(
              title: t.advisorEstimateReviewTitle,
              subtitle: t.advisorEstimateShareHint,
              breadcrumbs: [
                AppBreadcrumbItem(
                  label: t.advisorNavJobs,
                  onTap: widget.onBack,
                ),
                AppBreadcrumbItem.current(t.advisorEstimateReviewTitle),
              ],
            ),
            const SizedBox(height: AppDimensions.s12),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: doc),
                  const SizedBox(width: AppDimensions.s24),
                  Expanded(flex: 2, child: actions),
                ],
              )
            else ...[
              doc,
              const SizedBox(height: AppDimensions.s16),
              actions,
            ],
            const SizedBox(height: AppDimensions.s24),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(InspectionState state) async {
    final t = StaffLocalizations.of(context)!;
    if (state.jobCardId.isEmpty) {
      _toast(t.advisorEstimateMissingJob, icon: Icons.error_outline_rounded);
      return;
    }
    if (state.serviceLines.isEmpty && state.partLines.isEmpty) {
      _toast(t.advisorEstimateNoItems, icon: Icons.info_outline_rounded);
      return;
    }
    final advisorApproved = await _chooseApprovalMethod();
    if (advisorApproved == null || !context.mounted) return;
    setState(() => _submitting = true);
    try {
      final detail = await ref
          .read(advisorRemoteDataSourceProvider)
          .getJobCard(state.jobCardId);
      final jobCardId = detail.dbId > 0 ? '${detail.dbId}' : state.jobCardId;
      // Frozen submit payload: identical keys/shapes to the previous
      // composition (services/parts/totals/notes/delivery/notify/approval).
      final response = await ref
          .read(advisorRemoteDataSourceProvider)
          .createRepairOrderStrict({
            'jobCardId': jobCardId,
            'services': state.serviceLines
                .map((item) => item.toJson())
                .toList(),
            'parts': state.partLines.map((item) => item.toJson()).toList(),
            'servicesTotal': state.servicesTotal,
            'partsTotal': state.partsTotal,
            'grandTotal': state.grandTotal,
            'tag': state.tag,
            'customerRequests': state.customerRequests,
            'garageRecommendations': state.garageRecommendations,
            'estimatedDelivery': state.estimatedDelivery?.toIso8601String(),
            'notifyOwnerSmsEmail': state.notifyOwnerSmsEmail,
            'advisorApproved': advisorApproved,
          });
      if (!context.mounted) return;
      if (response.id.isEmpty) {
        throw const UnknownException('Repair order was not created');
      }
      _toast(
        advisorApproved
            ? t.advisorEstimateCreated
            : t.advisorEstimateSubmit,
        icon: Icons.check_circle_outline_rounded,
        color: context.semanticColors.success.base,
      );
      ref.read(inspectionProvider.notifier).reset();
      context.go(AppRoutes.advisorDashboard);
    } catch (_) {
      if (!context.mounted) return;
      _toast(t.advisorEstimateCreateFailed, icon: Icons.error_outline_rounded);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<bool?> _chooseApprovalMethod() {
    final t = StaffLocalizations.of(context)!;
    return showAppModalSheet<bool>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.s20,
          AppDimensions.s8,
          AppDimensions.s20,
          AppDimensions.s20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.advisorEstimateApprovalTitle,
              style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppDimensions.s6),
            Text(
              t.advisorEstimateApprovalSubtitle,
              style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.s16),
            _ApprovalMethodTile(
              icon: Icons.handshake_outlined,
              title: t.advisorEstimateApprovalHere,
              subtitle: t.advisorEstimateApprovalHereHint,
              onTap: () => Navigator.pop(sheetContext, true),
            ),
            const SizedBox(height: AppDimensions.s10),
            _ApprovalMethodTile(
              icon: Icons.phone_android_outlined,
              title: t.advisorEstimateApprovalApp,
              subtitle: t.advisorEstimateApprovalAppHint,
              onTap: () => Navigator.pop(sheetContext, false),
            ),
          ],
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
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.s14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusControl,
                  ),
                ),
                child: Icon(icon, color: colors.primary),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              DirectionalIcon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── SIGNATURE PAD (hand-drawn, theme chrome) ────────────────────────────────
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
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.advisorEstimateSignatureTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.s14),
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
                  // FIXED-INK: signature paper stays white in both themes so
                  // the captured PNG keeps black-on-white ink.
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusCard,
                  ),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusCard,
                  ),
                  child: CustomPaint(
                    painter: _SignaturePainter(
                      strokes: _strokes,
                      current: _current,
                      ink: colors.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.s14),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: t.advisorEstimateSignatureClear,
                    leadingIcon: Icons.refresh_rounded,
                    onPressed: () => setState(() {
                      _strokes.clear();
                      _current = [];
                    }),
                  ),
                ),
                const SizedBox(width: AppDimensions.s12),
                Expanded(
                  child: PrimaryButton(
                    label: t.advisorEstimateSignatureUse,
                    icon: Icons.check_rounded,
                    onPressed: _strokes.isEmpty
                        ? null
                        : () async {
                            final bytes = await _renderSignaturePng();
                            if (context.mounted) {
                              Navigator.of(context).pop(bytes);
                            }
                          },
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
    // FIXED-INK: exported signature is black ink on white paper in both
    // themes (document artifact, not themed UI).
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = const Color(0xFFFFFFFF),
    );
    final painter = _SignaturePainter(
      strokes: _strokes,
      current: const [],
      // FIXED-INK: exported signature ink stays black on white paper.
      ink: const Color(0xFF000000),
    );
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
  final Color ink;

  const _SignaturePainter({
    required this.strokes,
    required this.current,
    required this.ink,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ink
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
