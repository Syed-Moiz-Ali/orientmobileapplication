import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/platform/file_ops.dart';
import 'package:staff_app/core/services/audio_recorder_service.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/inspection_model.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/inspection_view_model.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/vehicle_damage_map_model.dart';
import 'package:staff_app/features/advisor/inspection_pages/presentation/vehicle_map/hud_pin_bridge.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

import 'damage_detail_sheet.dart';
import 'inspection_provider.dart';
import 'real_damage_canvas.dart';

// ─── INSPECTION SHEET (SPATIAL HUD) ──────────────────────────────────────────

class InspectionSheetView extends ConsumerStatefulWidget {
  final InspectionCallbacks callbacks;
  const InspectionSheetView({super.key, required this.callbacks});

  @override
  ConsumerState<InspectionSheetView> createState() =>
      _InspectionSheetViewState();
}

class _InspectionSheetViewState extends ConsumerState<InspectionSheetView> {
  int _tab = 0;
  String _selectedSectionId = '';
  bool _ready = false;
  bool _searchOpen = false;
  final TextEditingController _searchCtrl = TextEditingController();
  final Set<String> _expandedSections = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(inspectionProvider.notifier).loadDefaultTemplate();
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final pendingSync = ref.watch(advisorPendingSyncCountProvider).valueOrNull;
    final state = ref.watch(inspectionProvider);

    if (_selectedSectionId.isEmpty && state.filteredSections.isNotEmpty) {
      _selectedSectionId = state.filteredSections.first.id;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: WorkspaceAppBar(
        title: t.advisorHudTitle,
        subtitle: t.advisorHudProgress(state.completedCount, state.totalItems),
        showBack: true,
        onBack: widget.callbacks.onBack,
        frosted: !context.isCompact,
        showOfflineStatus: true,
        offlinePendingCount: pendingSync,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // 4px job progress directly under the slim header: the big
            // Inspect card + 5-node stepper were removed from this work
            // surface (they belong on job detail).
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.r4),
              child: LinearProgressIndicator(
                value: state.totalItems == 0
                    ? 0
                    : state.completedCount / state.totalItems,
                minHeight: 4,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
              child: _HudControls(
                tab: _tab,
                damageCount: state.vehiclePartInspections.values
                    .expand((p) => p.findings)
                    .length,
                checksCount: state.completedCount,
                checksTotal: state.totalItems,
                onTab: (i) => setState(() => _tab = i),
                searchOpen: _searchOpen,
                searchCtrl: _searchCtrl,
                onSearchToggle: () {
                  HapticFeedback.selectionClick();
                  if (_searchOpen) {
                    _searchCtrl.clear();
                    ref.read(inspectionProvider.notifier).setGlobalSearch('');
                  }
                  setState(() => _searchOpen = !_searchOpen);
                },
              ),
            ),
            Expanded(
              child: !_ready
                  ? const AppResponsivePage(
                      child: AppSkeleton.listRows(rows: 4),
                    )
                  // Map and checkpoints are SEPARATE full-width tabs at
                  // every width: never side-by-side panes. IndexedStack
                  // preserves each room's scroll, selection and zoom
                  // across tab switches.
                  : IndexedStack(
                      index: _tab,
                      children: [
                        _DamageCanvasTab(state: state),
                        _CheckpointsTab(
                          state: state,
                          selectedSectionId: _selectedSectionId,
                          onSection: (id) =>
                              setState(() => _selectedSectionId = id),
                          expandedSections: _expandedSections,
                          onToggleExpanded: (id) => setState(() {
                            if (_expandedSections.contains(id)) {
                              _expandedSections.remove(id);
                            } else {
                              _expandedSections.add(id);
                            }
                          }),
                        ),
                      ],
                    ),
            ),
            // One docked CTA for the active tab's job (any width).
            _HudFooter(
              callbacks: widget.callbacks,
              tab: _tab,
              onDoneMarking: () => setState(() => _tab = 1),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SHARED DAMAGE FLOWS ───────────────────────────────────────────────────
// One capture/edit pipeline for the damage tab and the pins drawer:
// detail sheet → provider persist (bridge payload unchanged) → voice merge.

void _mergeDamageVoice(
  WidgetRef ref,
  String findingId,
  List<String> photos,
  String voicePath,
) {
  if (voicePath.isEmpty) return;
  final notifier = ref.read(inspectionProvider.notifier);
  final current = ref
      .read(inspectionProvider)
      .media['vehicle-damage:$findingId'];
  notifier.setMedia(
    'vehicle-damage:$findingId',
    (current ?? ItemMedia(photoPaths: photos)).copyWith(audioPath: voicePath),
  );
}

Future<VehicleDamageFinding?> showAddDamageFlow({
  required BuildContext context,
  required WidgetRef ref,
  required String partId,
  required VehiclePartCategory category,
  required Offset normalized,
}) async {
  final result = await showDamageDetailSheet(
    context: context,
    partId: partId,
    category: category,
    normalized: normalized,
  );
  if (result == null) return null;
  ref.read(inspectionProvider.notifier).addVehicleDamageFinding(result.finding);
  _mergeDamageVoice(
    ref,
    result.finding.id,
    result.finding.photos,
    result.voicePath,
  );
  return result.finding;
}

Future<VehicleDamageFinding?> showEditDamageFlow({
  required BuildContext context,
  required WidgetRef ref,
  required VehicleDamageFinding finding,
}) async {
  // The canvas already loaded the definition, so the sync peek resolves
  // without an async gap (stale ids fall back to other).
  final part = VehicleMapLoader.cached?.partById(finding.partId);
  final voice =
      ref
          .read(inspectionProvider)
          .media['vehicle-damage:${finding.id}']
          ?.audioPath ??
      '';
  final result = await showDamageDetailSheet(
    context: context,
    partId: finding.partId,
    category: part?.category ?? VehiclePartCategory.other,
    existing: finding,
    existingVoice: voice,
  );
  if (result == null) return null;
  ref
      .read(inspectionProvider.notifier)
      .updateVehicleDamageFinding(result.finding);
  _mergeDamageVoice(
    ref,
    result.finding.id,
    result.finding.photos,
    result.voicePath,
  );
  return result.finding;
}

/// Pins with content (plus non-default conditions): the one pin grammar
/// shared by the mobile strip, the desktop rail and the chips dock.
Map<String, VehiclePartInspection> pinsEntries(InspectionState state) {
  final entries = <String, VehiclePartInspection>{};
  state.vehiclePartInspections.forEach((partId, inspection) {
    if (inspection.findings.isNotEmpty ||
        inspection.condition != VehiclePartCondition.uninspected) {
      entries[partId] = inspection;
    }
  });
  return entries;
}

int pinsTotal(InspectionState state) =>
    state.vehiclePartInspections.values.expand((p) => p.findings).length;

/// Review sheet (progress + pins + notify + Continue → dossier): the single
/// grading gate, opened from the mobile footer and the desktop left dock.
Future<void> showInspectionReviewSheet(
  BuildContext context,
  WidgetRef ref,
  InspectionCallbacks callbacks,
) {
  HapticFeedback.lightImpact();
  return showAppModalSheet<void>(
    context: context,
    title: StaffLocalizations.of(context)!.advisorHudReview,
    builder: (ctx) => _ReviewSheetBody(callbacks: callbacks),
  );
}

// One compact control row: 40px segmented tabs + icon-expandable search.
// The search field lives only in this row (checks tab); the list below owns
// the viewport instead of competing with a permanent search card.
class _HudControls extends ConsumerWidget {
  final int tab;
  final int damageCount;
  final int checksCount;
  final int checksTotal;
  final ValueChanged<int> onTab;
  final bool searchOpen;
  final TextEditingController searchCtrl;
  final VoidCallback onSearchToggle;

  const _HudControls({
    required this.tab,
    required this.damageCount,
    required this.checksCount,
    required this.checksTotal,
    required this.onTab,
    required this.searchOpen,
    required this.searchCtrl,
    required this.onSearchToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final notifier = ref.read(inspectionProvider.notifier);
    final labels = [
      '${t.advisorHudTabDamage} · $damageCount',
      '${t.advisorHudTabChecks} · $checksCount/$checksTotal',
    ];

    return Semantics(
      label: t.advisorHudTitle,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppDimensions.r12),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < labels.length; i++)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onTab(i);
                        },
                        child: Semantics(
                          button: true,
                          selected: tab == i,
                          label: labels[i],
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: tab == i ? colors.surface : null,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.r8,
                              ),
                              border: tab == i
                                  ? Border.all(color: colors.outlineVariant)
                                  : null,
                            ),
                            child: Text(
                              labels[i],
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: tab == i
                                        ? colors.onSurface
                                        : colors.onSurfaceVariant,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (tab == 1) ...[
            const SizedBox(width: 8),
            if (searchOpen)
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 40,
                  child: AppSearchField(
                    controller: searchCtrl,
                    hintText: t.advisorHudSearchHint,
                    onChanged: notifier.setGlobalSearch,
                    onClear: () {
                      searchCtrl.clear();
                      notifier.setGlobalSearch('');
                    },
                  ),
                ),
              )
            else
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  onPressed: onSearchToggle,
                  tooltip: t.advisorHudSearchHint,
                  style: IconButton.styleFrom(
                    side: BorderSide(color: colors.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r12),
                    ),
                  ),
                  icon: Icon(
                    Icons.search_rounded,
                    color: colors.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
            if (searchOpen)
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  onPressed: onSearchToggle,
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  icon: Icon(
                    Icons.close_rounded,
                    color: colors.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ─── TAB 0: DAMAGE CANVAS ────────────────────────────────────────────────────
//
// CAPTURE screen: eyes on the car. The canvas is full-bleed (no card
// chrome) and owns the viewport; pins float in a collapsible strip that
// stays collapsed until a zone is tapped. Verdict = bottom-sheet kind
// picker, never rings.

class _DamageCanvasTab extends ConsumerStatefulWidget {
  final InspectionState state;

  const _DamageCanvasTab({required this.state});

  @override
  ConsumerState<_DamageCanvasTab> createState() => _DamageCanvasTabState();
}

class _DamageCanvasTabState extends ConsumerState<_DamageCanvasTab> {
  String? _selectedId;
  final TransformationController _zoomCtrl = TransformationController();

  @override
  void dispose() {
    _zoomCtrl.dispose();
    super.dispose();
  }

  /// One selected object, two views: first tap selects the pin (chip on
  /// the canvas + highlighted drawer row), tapping it again opens the
  /// edit sheet. Drawer rows select on tap, edit via their edit button.
  void _selectOrEdit(VehicleDamageFinding finding) {
    if (_selectedId == finding.id) {
      _editFlow(finding);
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _selectedId = finding.id);
  }

  void _resetZoom() {
    HapticFeedback.selectionClick();
    _zoomCtrl.value = Matrix4.identity();
  }

  void _stepZoom(double factor) {
    HapticFeedback.selectionClick();
    final next = (_zoomCtrl.value.getMaxScaleOnAxis() * factor).clamp(1.0, 4.0);
    _zoomCtrl.value = Matrix4.identity()..scaleByDouble(next, next, next, 1);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final total = pinsTotal(state);
    // Wider canvas on expanded/large windows (720), capped at 560 on
    // compact/medium. Window class only — never raw widths.
    final canvasMax = context.adaptive.pick(compact: 560.0, medium: 560.0, expanded: 720.0, large: 720.0);

    return Column(
      children: [
        // Studio title block: title + count + zoom/reset, then legend.
        _MapTitleBlock(
          total: total,
          onZoomIn: () => _stepZoom(1.25),
          onZoomOut: () => _stepZoom(0.8),
          onResetView: _resetZoom,
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: canvasMax),
              child: _MapSurface(
                state: state,
                selectedFindingId: _selectedId,
                zoomController: _zoomCtrl,
                onPartTap: (partId, category, normalized) =>
                    _addFlow(partId, category, normalized),
                onFindingTap: _selectOrEdit,
                onFindingEdit: _editFlow,
              ),
            ),
          ),
        ),
        // Pin chips docked at the canvas bottom: quick select.
        if (total > 0)
          _PinChipsDock(
            state: state,
            selectedFindingId: _selectedId,
            onSelect: _selectOrEdit,
          ),
        _PinsBar(
          state: state,
          onShowList: () => showPinsManager(
            context: context,
            ref: ref,
            state: state,
            selectedFindingId: _selectedId,
            onSelect: _selectOrEdit,
            onEdit: _editFlow,
          ),
        ),
      ],
    );
  }

  Future<void> _addFlow(
    String partId,
    VehiclePartCategory category,
    Offset normalized,
  ) async {
    HapticFeedback.mediumImpact();
    final finding = await showAddDamageFlow(
      context: context,
      ref: ref,
      partId: partId,
      category: category,
      normalized: normalized,
    );
    if (finding != null && mounted) {
      setState(() => _selectedId = finding.id);
    }
  }

  Future<void> _editFlow(VehicleDamageFinding finding) async {
    HapticFeedback.selectionClick();
    await showEditDamageFlow(context: context, ref: ref, finding: finding);
  }
}

/// Studio title block: "Damage map · N" + 48dp zoom/reset controls,
/// then the severity legend row. Flat surface above the sunken canvas.
class _MapTitleBlock extends StatelessWidget {
  final int total;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetView;

  const _MapTitleBlock({
    required this.total,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetView,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 4, top: 4),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_car_outlined,
                size: 20,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${t.advisorHudTabDamage} · $total',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _StudioControl(
                tooltip: t.advisorDamageZoomIn,
                icon: Icons.add_rounded,
                onTap: onZoomIn,
              ),
              _StudioControl(
                tooltip: t.advisorDamageZoomOut,
                icon: Icons.remove_rounded,
                onTap: onZoomOut,
              ),
              _StudioControl(
                tooltip: t.advisorDamageResetView,
                icon: Icons.center_focus_strong_rounded,
                onTap: onResetView,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: _MapLegend(),
          ),
        ],
      ),
    );
  }
}

class _StudioControl extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  const _StudioControl({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        tooltip: tooltip,
        icon: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 22,
        ),
      ),
    );
  }
}

/// Pin chips docked at the canvas bottom: severity dot + part label,
/// tap to select (shared selection with canvas pins + drawer rows).
class _PinChipsDock extends StatelessWidget {
  final InspectionState state;
  final String? selectedFindingId;
  final ValueChanged<VehicleDamageFinding> onSelect;

  const _PinChipsDock({
    required this.state,
    required this.selectedFindingId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final entries = pinsEntries(state);
    final findings = [
      for (final entry in entries.entries) ...entry.value.findings,
    ];

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: ListView.separated(
        padding: const EdgeInsetsDirectional.only(
          start: 12,
          end: 12,
          top: 8,
          bottom: 8,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: findings.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) => _PinChip(
          finding: findings[i],
          selected: selectedFindingId == findings[i].id,
          onTap: () => onSelect(findings[i]),
        ),
      ),
    );
  }
}

/// The pins bar: collapsed summary + Show list (drawer/sheet, never a
/// side pane).
class _PinsBar extends StatelessWidget {
  final InspectionState state;
  final VoidCallback onShowList;

  const _PinsBar({required this.state, required this.onShowList});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final total = pinsTotal(state);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onShowList();
          },
          child: Semantics(
            button: true,
            label: '${t.advisorHudPinsTitle} $total',
            child: Container(
              height: 48,
              padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
              color: Colors.transparent,
              child: Row(
                children: [
                  Icon(
                    Icons.push_pin_outlined,
                    size: 20,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      total == 0
                          ? t.advisorHudNoPins
                          : '${t.advisorHudPinsTitle} · $total',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    child: Text(
                      t.advisorHudShowPins,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: colors.onSurfaceVariant,
                    size: 22,
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

/// Pin manager: bottom sheet on compact/medium, right end-drawer on
/// expanded/large (Esc closes). Never a side pane.
Future<void> showPinsManager({
  required BuildContext context,
  required WidgetRef ref,
  required InspectionState state,
  required String? selectedFindingId,
  required ValueChanged<VehicleDamageFinding> onSelect,
  required ValueChanged<VehicleDamageFinding> onEdit,
}) {
  final t = StaffLocalizations.of(context)!;
  final total = pinsTotal(state);
  final list = _PinsList(
    selectedFindingId: selectedFindingId,
    onSelect: (f) {
      onSelect(f);
      // Selection reflects under the drawer; it stays open for auditing.
    },
    onEdit: onEdit,
  );
  if (context.isExpanded || context.isLarge) {
    final colors = Theme.of(context).colorScheme;
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, _, __) => Align(
        alignment: AlignmentDirectional.centerEnd,
        child: SizedBox(
          width: 360,
          height: double.infinity,
          child: Material(
            color: colors.surface,
            borderRadius: const BorderRadiusDirectional.only(
              topStart: Radius.circular(AppDimensions.r16),
              bottomStart: Radius.circular(AppDimensions.r16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Focus(
              autofocus: true,
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.escape) {
                  Navigator.of(dialogContext).pop();
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 56,
                    padding: const EdgeInsetsDirectional.only(
                      start: 16,
                      end: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: colors.outlineVariant),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${t.advisorHudPinsTitle} · $total',
                            style: Theme.of(dialogContext).textTheme.labelLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                          ),
                        ),
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: IconButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(),
                            tooltip: MaterialLocalizations.of(
                              dialogContext,
                            ).closeButtonTooltip,
                            icon: const Icon(Icons.close_rounded, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: list),
                ],
              ),
            ),
          ),
        ),
      ),
      transitionBuilder: (context, animation, _, child) => SlideTransition(
        position:
            Tween<Offset>(
              begin: Directionality.of(context) == TextDirection.rtl
                  ? const Offset(-1, 0)
                  : const Offset(1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: child,
      ),
    );
  }
  return showAppModalSheet<void>(
    context: context,
    title: '${t.advisorHudPinsTitle} · $total',
    builder: (_) => list,
  );
}

/// Full-bleed capture surface: the vector car fills a sunken studio
/// canvas (a different room from the flat items list) with a floating
/// hint and a severity legend. The pin count lives on the studio
/// toolbar — never as a floating square.
class _MapSurface extends StatelessWidget {
  final InspectionState state;
  final String? selectedFindingId;
  final TransformationController zoomController;
  final void Function(
    String partId,
    VehiclePartCategory category,
    Offset normalized,
  )
  onPartTap;
  final ValueChanged<VehicleDamageFinding> onFindingTap;
  final ValueChanged<VehicleDamageFinding> onFindingEdit;

  const _MapSurface({
    required this.state,
    required this.selectedFindingId,
    required this.zoomController,
    required this.onPartTap,
    required this.onFindingTap,
    required this.onFindingEdit,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final empty = pinsTotal(state) == 0;

    // Sunken studio tone: panels read as car paint on both themes and on
    // web-wide canvases instead of washing out on bare white. The title
    // block above carries title + legend; the canvas keeps a first-run
    // coachmark only while zero pins exist.
    return Container(
      color: context.semanticColors.surfaceSunken,
      child: Stack(
        children: [
          Positioned.fill(
            // The map geometry is LTR-locked inside the canvas and never
            // mirrors in AR RTL (spec §2.2 exception 1).
            child: RealDamageCanvas(
              inspections: state.vehiclePartInspections,
              selectedFindingId: selectedFindingId,
              transformationController: zoomController,
              onPartTap: (part, normalized) =>
                  onPartTap(part.id, part.category, normalized),
              onFindingTap: onFindingTap,
              onFindingEdit: onFindingEdit,
            ),
          ),
          if (empty)
            PositionedDirectional(
              top: 8,
              start: 12,
              end: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(AppDimensions.r12),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Text(
                  t.advisorHudCanvasHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Canvas legend: frozen severity grammar (blue minor, amber moderate,
/// crimson severe) shared with zones, pins and pills.
class _MapLegend extends StatelessWidget {
  const _MapLegend();

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final semantic = context.semanticColors;
    final entries = [
      (
        semantic.damageMinor,
        damageSeverityLabel(t, VehicleDamageSeverity.minor),
      ),
      (
        semantic.damageModerate,
        damageSeverityLabel(t, VehicleDamageSeverity.moderate),
      ),
      (
        semantic.damageSevere,
        damageSeverityLabel(t, VehicleDamageSeverity.major),
      ),
    ];

    return Semantics(
      label: t.advisorHudLegendTitle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(AppDimensions.r8),
          border: Border.all(color: colors.outlineVariant),
        ),
        // Wrap: narrow 320px viewports fold to two lines instead of
        // overflowing a fixed Row.
        child: Wrap(
          spacing: 10,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (var i = 0; i < entries.length; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: entries[i].$1.base,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    entries[i].$2,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}


/// One managed damage pin: part label, kind + severity pill, photo
/// thumbnail when present, 48dp edit/delete. Delete confirms inline
/// (two-step inside the row, never a blind one-tap destroy).
class _DamagePinRow extends StatefulWidget {
  final String partId;
  final VehicleDamageFinding finding;
  final bool selected;
  final VoidCallback? onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DamagePinRow({
    required this.partId,
    required this.finding,
    this.selected = false,
    this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_DamagePinRow> createState() => _DamagePinRowState();
}

class _DamagePinRowState extends State<_DamagePinRow> {
  bool _confirming = false;

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final finding = widget.finding;
    final tone = damageSeverityTone(context.semanticColors, finding.severity);
    final meta = [
      damageKindLabel(t, finding.damageType),
      if (finding.damageLocation.isNotEmpty)
        damageSizeLabel(t, finding.damageLocation),
      if (finding.note.isNotEmpty) finding.note,
    ].join(' · ');

    final selected = widget.selected;
    return GestureDetector(
      onTap: widget.onSelect == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              widget.onSelect!();
            },
      child: Semantics(
        button: widget.onSelect != null,
        selected: selected,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsetsDirectional.only(start: 12),
          decoration: BoxDecoration(
            color: selected
                ? colors.primary.withValues(alpha: 0.10)
                : colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppDimensions.r12),
            border: Border.all(
              color: selected ? colors.primary : colors.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (finding.photos.isNotEmpty)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 10),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppDimensions.r8),
                          border: Border.all(color: colors.outlineVariant),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimensions.r8),
                          child: localImage(
                            finding.photos.first,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 10),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: tone.base.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          damageKindIcon(finding.damageType),
                          color: tone.base,
                          size: 20,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          damagePartLabel(t, widget.partId),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          meta,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: tone.base.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      damageSeverityLabel(t, finding.severity),
                      style: TextStyle(
                        color: tone.ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        widget.onEdit();
                      },
                      tooltip: t.advisorDamageEdit,
                      icon: Icon(
                        Icons.edit_outlined,
                        color: colors.onSurfaceVariant,
                        size: 22,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        setState(() => _confirming = !_confirming);
                      },
                      tooltip: t.advisorHudDeletePin,
                      icon: Icon(
                        _confirming
                            ? Icons.close_rounded
                            : Icons.delete_outline_rounded,
                        color: colors.error,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              if (_confirming)
                Container(
                  padding: const EdgeInsetsDirectional.only(
                    start: 0,
                    end: 8,
                    top: 0,
                    bottom: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.advisorDamageDeleteTitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colors.error,
                              ),
                        ),
                      ),
                      SizedBox(
                        height: 48,
                        child: TextButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            widget.onDelete();
                          },
                          child: Text(t.advisorDamageDelete),
                        ),
                      ),
                      SizedBox(
                        height: 48,
                        child: TextButton(
                          onPressed: () => setState(() => _confirming = false),
                          child: Text(
                            MaterialLocalizations.of(context).cancelButtonLabel,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── TAB 1: CHECKPOINTS WITH RINGS + EVIDENCE DOCK ────────────────────────────
//
// Scroll-room layout: a 36px snap chips strip, then the list owns the
// viewport. The section mini-header (32px) sticks inside the list via
// slivers instead of consuming a separate card above it.

class _CheckpointsTab extends ConsumerWidget {
  final InspectionState state;
  final String selectedSectionId;
  final ValueChanged<String> onSection;
  final Set<String> expandedSections;
  final ValueChanged<String> onToggleExpanded;

  const _CheckpointsTab({
    required this.state,
    required this.selectedSectionId,
    required this.onSection,
    required this.expandedSections,
    required this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final notifier = ref.read(inspectionProvider.notifier);
    final sections = state.filteredSections;

    final active = sections.firstWhere(
      (s) => s.id == selectedSectionId,
      orElse: () => sections.isNotEmpty
          ? sections.first
          : const InspectionSection(id: '', label: '', items: []),
    );

    var completed = 0;
    for (var i = 0; i < active.items.length; i++) {
      if (state.statuses.containsKey('${active.id}_$i')) completed++;
    }
    final remaining = active.items.length - completed;
    // Completed sections collapse to one summary bar (re-expandable).
    final collapsed =
        remaining == 0 &&
        active.items.isNotEmpty &&
        !expandedSections.contains(active.id);

    final body = Column(
      children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsetsDirectional.only(start: 12, end: 12),
            scrollDirection: Axis.horizontal,
            itemCount: sections.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (ctx, i) {
              final sec = sections[i];
              final isSelected = sec.id == active.id;
              var rated = 0;
              for (var k = 0; k < sec.items.length; k++) {
                if (state.statuses.containsKey('${sec.id}_$k')) rated++;
              }
              return Center(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSection(sec.id);
                  },
                  child: Semantics(
                    button: true,
                    selected: isSelected,
                    label: '${sec.label} $rated/${sec.items.length}',
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primary
                            : colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.outlineVariant,
                        ),
                      ),
                      child: Text(
                        '${sec.label} · $rated/${sec.items.length}',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: isSelected
                                  ? colors.onPrimary
                                  : colors.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: active.items.isEmpty
              ? _NoMatch()
              : CustomScrollView(
                  slivers: [
                    if (active.id.isNotEmpty)
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _MiniSectionHeader(
                          label: active.label,
                          remaining: remaining,
                          onMarkAllPass: remaining > 0
                              ? () {
                                  HapticFeedback.lightImpact();
                                  for (
                                    var i = 0;
                                    i < active.items.length;
                                    i++
                                  ) {
                                    final itemId = '${active.id}_$i';
                                    if (!state.statuses.containsKey(itemId)) {
                                      notifier.setStatus(
                                        itemId,
                                        ItemStatus.good,
                                      );
                                    }
                                  }
                                }
                              : null,
                        ),
                      ),
                    if (collapsed)
                      SliverToBoxAdapter(
                        child: _CollapsedSectionBar(
                          label: active.label,
                          count: active.items.length,
                          onExpand: () => onToggleExpanded(active.id),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, idx) => Padding(
                              padding: EdgeInsets.only(
                                bottom: idx < active.items.length - 1 ? 8 : 0,
                              ),
                              child: _CheckpointCard(
                                itemId: '${active.id}_$idx',
                                itemName: active.items[idx],
                                index: idx + 1,
                              ),
                            ),
                            childCount: active.items.length,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
    // Expanded/large windows: content caps at 960 centered instead of
    // stretching full-bleed. Window class only — never raw widths.
    if (context.isExpanded || context.isLarge) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: body,
        ),
      );
    }
    return body;
  }
}

/// 32px sticky mini-header living inside the list.
class _MiniSectionHeader extends SliverPersistentHeaderDelegate {
  final String label;
  final int remaining;
  final VoidCallback? onMarkAllPass;

  const _MiniSectionHeader({
    required this.label,
    required this.remaining,
    required this.onMarkAllPass,
  });

  @override
  double get minExtent => 32;

  @override
  double get maxExtent => 32;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 32,
      padding: const EdgeInsetsDirectional.only(start: 12, end: 4),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              remaining == 0
                  ? '$label · ${t.advisorHudSectionDone}'
                  : '$label · ${t.advisorHudSectionRemaining(remaining)}',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onMarkAllPass != null)
            SizedBox(
              height: 32,
              child: TextButton(
                onPressed: onMarkAllPass,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(48, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(t.advisorHudMarkAllPass),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _MiniSectionHeader oldDelegate) =>
      oldDelegate.label != label || oldDelegate.remaining != remaining;
}

class _CollapsedSectionBar extends StatelessWidget {
  final String label;
  final int count;
  final VoidCallback onExpand;

  const _CollapsedSectionBar({
    required this.label,
    required this.count,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final ink = context.semanticColors.inspectionPass.base;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onExpand();
        },
        child: Semantics(
          button: true,
          expanded: false,
          label: label,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: ink.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimensions.r12),
              border: Border.all(color: ink.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: ink, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$label · $count',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: colors.onSurfaceVariant,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoMatch extends ConsumerWidget {
  const _NoMatch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = StaffLocalizations.of(context)!;
    return Center(
      child: EmptyState.noMatch(
        message: t.advisorHudNoMatch,
        actionLabel: t.advisorHudClear,
        onAction: () {
          HapticFeedback.selectionClick();
          ref.read(inspectionProvider.notifier).setGlobalSearch('');
        },
      ),
    );
  }
}

class _CheckpointCard extends ConsumerStatefulWidget {
  final String itemId;
  final String itemName;
  final int index;

  const _CheckpointCard({
    required this.itemId,
    required this.itemName,
    required this.index,
  });

  @override
  ConsumerState<_CheckpointCard> createState() => _CheckpointCardState();
}

class _CheckpointCardState extends ConsumerState<_CheckpointCard> {
  bool _dockOpen = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final state = ref.watch(inspectionProvider);
    final notifier = ref.read(inspectionProvider.notifier);
    final status = state.statuses[widget.itemId];
    final media = state.media[widget.itemId];
    final evidenceCount =
        (media?.photoPaths.length ?? 0) +
        (media?.videoPaths.length ?? 0) +
        ((media?.audioPath.isNotEmpty ?? false) ? 1 : 0) +
        ((media?.note.isNotEmpty ?? false) ? 1 : 0);

    final ringColor = status == ItemStatus.good
        ? context.semanticColors.inspectionPass.base
        : status == ItemStatus.fair
        ? context.semanticColors.inspectionAdvisory.base
        : status == ItemStatus.poor
        ? context.semanticColors.inspectionFail.base
        : null;

    // Items-pane grammar: flat card on the default surface; severity
    // lives in the verdict segmented control + a 3px left accent only —
    // cards never borrow map-pin shapes or status fills.
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r12),
        border: Border.all(color: colors.outlineVariant),
      ),
      // Severity accent: a 3px bar pinned to the card's leading edge.
      // (A non-uniform Border + borderRadius crashes paint, so the bar
      // is a separate fill, not a border side.)
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 3,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: ringColor ?? Colors.transparent,
                borderRadius: BorderRadius.circular(AppDimensions.r4),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: (ringColor ?? colors.onSurfaceVariant)
                              .withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${widget.index}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: ringColor ?? colors.onSurfaceVariant,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.itemName,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (evidenceCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.attachment_rounded,
                                size: 12,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$evidenceCount',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: colors.primary,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (status != null)
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: IconButton(
                            onPressed: () =>
                                notifier.setStatus(widget.itemId, null),
                            tooltip: StaffLocalizations.of(
                              context,
                            )!.advisorHudResetGrade,
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.refresh_rounded,
                              color: colors.onSurfaceVariant,
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Compact grading rings: 48px segmented control inline in the
                  // card header — emerald / amber / crimson. No tiny radios.
                  Row(
                    children: [
                      _GradeRing(
                        status: ItemStatus.good,
                        selected: status == ItemStatus.good,
                        onTap: () => notifier.setStatus(
                          widget.itemId,
                          status == ItemStatus.good ? null : ItemStatus.good,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _GradeRing(
                        status: ItemStatus.fair,
                        selected: status == ItemStatus.fair,
                        onTap: () => notifier.setStatus(
                          widget.itemId,
                          status == ItemStatus.fair ? null : ItemStatus.fair,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _GradeRing(
                        status: ItemStatus.poor,
                        selected: status == ItemStatus.poor,
                        onTap: () => notifier.setStatus(
                          widget.itemId,
                          status == ItemStatus.poor ? null : ItemStatus.poor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _dockOpen = !_dockOpen);
                    },
                    child: Semantics(
                      button: true,
                      expanded: _dockOpen,
                      label: StaffLocalizations.of(
                        context,
                      )!.advisorHudDockTitle,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: evidenceCount > 0
                              ? colors.primary.withValues(alpha: 0.08)
                              : colors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppDimensions.r8),
                          border: Border.all(
                            color: evidenceCount > 0
                                ? colors.primary.withValues(alpha: 0.3)
                                : colors.outlineVariant,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _dockOpen
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: 20,
                              color: colors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                StaffLocalizations.of(
                                  context,
                                )!.advisorHudDockTitle,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (evidenceCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  '$evidenceCount',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: colors.primary,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.attach_file_rounded,
                              size: 18,
                              color: evidenceCount > 0
                                  ? colors.primary
                                  : colors.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_dockOpen) ...[
                    const SizedBox(height: 8),
                    _EvidenceDock(
                      itemId: widget.itemId,
                      itemName: widget.itemName,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradeRing extends StatelessWidget {
  // Card wrappers: Container > IntrinsicHeight > Row[bar, Expanded > Column].
  final ItemStatus status;
  final bool selected;
  final VoidCallback onTap;

  const _GradeRing({
    required this.status,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final semantic = context.semanticColors;

    final base = status == ItemStatus.good
        ? semantic.inspectionPass.base
        : status == ItemStatus.fair
        ? semantic.inspectionAdvisory.base
        : semantic.inspectionFail.base;
    final label = status == ItemStatus.good
        ? t.advisorHudRingPass
        : status == ItemStatus.fair
        ? t.advisorHudRingCaution
        : t.advisorHudRingFail;
    final icon = status == ItemStatus.good
        ? Icons.check_rounded
        : status == ItemStatus.fair
        ? Icons.priority_high_rounded
        : Icons.close_rounded;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          // 48px segmented control inline in the card header.
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: selected ? base : colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppDimensions.r8),
              border: Border.all(
                color: selected ? base : colors.outlineVariant,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      // FIXED-INK: white ring glyph on the saturated status
                      // fill keeps contrast in both themes by construction.
                      color: selected ? Colors.white : base,
                      width: 2,
                    ),
                    color: selected ? base : Colors.transparent,
                  ),
                  child: Icon(
                    icon,
                    size: 13,
                    // FIXED-INK: white icon on the saturated status fill.
                    color: selected ? Colors.white : base,
                  ),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      // FIXED-INK: white label on the saturated status fill.
                      color: selected ? Colors.white : colors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

// ─── VOICE + PHOTO DOCK ──────────────────────────────────────────────────────

class _EvidenceDock extends ConsumerStatefulWidget {
  final String itemId;
  final String itemName;

  const _EvidenceDock({required this.itemId, required this.itemName});

  @override
  ConsumerState<_EvidenceDock> createState() => _EvidenceDockState();
}

class _EvidenceDockState extends ConsumerState<_EvidenceDock> {
  bool _recording = false;
  bool _playing = false;
  int _seconds = 0;
  Timer? _timer;
  bool _micDenied = false;
  bool _cameraDenied = false;
  bool _galleryDenied = false;
  bool _photoError = false;
  final AudioRecorderService _recorder = AudioRecorderService();
  AudioPlayer? _player;

  @override
  void dispose() {
    _timer?.cancel();
    _player?.dispose();
    super.dispose();
  }

  Future<void> _toggleRecord() async {
    final notifier = ref.read(inspectionProvider.notifier);
    if (_recording) {
      _timer?.cancel();
      final path = await _recorder.stopRecording();
      setState(() => _recording = false);
      if (path != null && path.isNotEmpty) {
        notifier.setAudio(widget.itemId, path);
      }
      return;
    }
    final permission = await Permission.microphone.request();
    if (!permission.isGranted) {
      setState(() => _micDenied = true);
      return;
    }
    setState(() => _micDenied = false);
    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/audio_${widget.itemId}_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final started = await _recorder.startRecording(path);
    if (!started) {
      setState(() => _photoError = true);
      return;
    }
    setState(() {
      _recording = true;
      _seconds = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_recording) return;
      setState(() => _seconds++);
      if (_seconds >= 60) _toggleRecord();
    });
  }

  Future<void> _togglePlay(String audioPath) async {
    if (_playing) {
      await _player?.stop();
      setState(() => _playing = false);
      return;
    }
    try {
      _player ??= AudioPlayer();
      await _player!.play(DeviceFileSource(audioPath));
      setState(() => _playing = true);
      _player!.onPlayerComplete.first.then((_) {
        if (mounted) setState(() => _playing = false);
      });
    } catch (_) {
      if (mounted) setState(() => _playing = false);
    }
  }

  Future<void> _pickPhoto({required bool fromCamera}) async {
    final t = StaffLocalizations.of(context)!;
    setState(() {
      _photoError = false;
    });
    final permission = await (fromCamera
        ? Permission.camera.request()
        : Permission.photos.request());
    if (!permission.isGranted) {
      setState(() {
        if (fromCamera) {
          _cameraDenied = true;
        } else {
          _galleryDenied = true;
        }
      });
      return;
    }
    setState(() {
      if (fromCamera) {
        _cameraDenied = false;
      } else {
        _galleryDenied = false;
      }
    });
    try {
      final file = await ImagePicker().pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (file == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final ext = file.path.contains('.')
          ? '.${file.path.split('.').last}'
          : '';
      final dest =
          '${dir.path}/photo_${DateTime.now().millisecondsSinceEpoch}$ext';
      final saved = await persistMediaFile(file.path, dest);
      ref.read(inspectionProvider.notifier).addPhoto(widget.itemId, saved);
    } catch (_) {
      if (mounted) {
        setState(() => _photoError = true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.advisorHudPhotoError)));
      }
    }
  }

  void _showNoteDialog(String existing) {
    final colors = Theme.of(context).colorScheme;
    final t = StaffLocalizations.of(context)!;
    final ctrl = TextEditingController(text: existing);
    showAppModalSheet<void>(
      context: context,
      title: widget.itemName,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl,
              maxLines: 4,
              autofocus: true,
              style: TextStyle(fontSize: 13, color: colors.onSurface),
              decoration: InputDecoration(
                hintText: t.advisorHudAddNote,
                filled: true,
                fillColor: colors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.r12),
                  borderSide: BorderSide(color: colors.outlineVariant),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: MaterialLocalizations.of(context).saveButtonLabel,
                onPressed: () {
                  ref
                      .read(inspectionProvider.notifier)
                      .setNote(widget.itemId, ctrl.text.trim());
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final notifier = ref.read(inspectionProvider.notifier);
    final media = ref.watch(inspectionProvider).media[widget.itemId];
    final audioPath = media?.audioPath ?? '';
    final photos = media?.photoPaths ?? const <String>[];
    final hasNote = (media?.note.isNotEmpty ?? false);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimensions.r12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Voice row: idle / recording / saved+play / permission-denied.
          if (_micDenied)
            _DeniedRow(
              title: t.advisorHudMicDenied,
              hint: t.advisorHudMicDeniedHint,
              onRetry: () => setState(() => _micDenied = false),
            )
          else
            Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Semantics(
                    button: true,
                    label: _recording
                        ? t.advisorHudVoiceRecording(_seconds)
                        : audioPath.isEmpty
                        ? t.advisorHudVoiceIdle
                        : t.advisorHudVoiceSaved,
                    child: GestureDetector(
                      onTap: _toggleRecord,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        decoration: BoxDecoration(
                          color: _recording ? colors.error : colors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _recording ? Icons.stop_rounded : Icons.mic_rounded,
                          // FIXED-INK: white glyph on saturated action fill.
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _recording
                        ? t.advisorHudVoiceRecording(_seconds)
                        : audioPath.isEmpty
                        ? t.advisorHudVoiceIdle
                        : t.advisorHudVoiceSaved,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                if (audioPath.isNotEmpty && !_recording) ...[
                  SizedBox(
                    height: 48,
                    child: TextButton.icon(
                      onPressed: () => _togglePlay(audioPath),
                      icon: Icon(
                        _playing
                            ? Icons.stop_rounded
                            : Icons.play_arrow_rounded,
                        size: 20,
                      ),
                      label: Text(t.advisorHudVoicePlay),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      onPressed: () => notifier.setAudio(widget.itemId, ''),
                      tooltip: t.advisorHudVoiceDelete,
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: colors.error,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          const SizedBox(height: 10),
          // Photo grid with camera/gallery tiles, thumbs + retry states.
          if (_cameraDenied)
            _DeniedRow(
              title: t.advisorHudCameraDenied,
              hint: t.advisorHudCameraDeniedHint,
              onRetry: () => setState(() => _cameraDenied = false),
            )
          else if (_galleryDenied)
            _DeniedRow(
              title: t.advisorHudGalleryDenied,
              hint: t.advisorHudGalleryDeniedHint,
              onRetry: () => setState(() => _galleryDenied = false),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PhotoTile(
                  icon: Icons.camera_alt_outlined,
                  onTap: () => _pickPhoto(fromCamera: true),
                ),
                _PhotoTile(
                  icon: Icons.photo_library_outlined,
                  onTap: () => _pickPhoto(fromCamera: false),
                ),
                for (var i = 0; i < photos.length; i++)
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppDimensions.r8),
                          border: Border.all(color: colors.outlineVariant),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimensions.r8),
                          child: localImage(photos[i], fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: -8,
                        right: -8,
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: GestureDetector(
                            onTap: () => notifier.removePhoto(widget.itemId, i),
                            child: Container(
                              decoration: const BoxDecoration(
                                // FIXED-INK: scrim + white glyph over user
                                // photo content (non-theme media overlay).
                                color: Colors.black87,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (_photoError)
                  GestureDetector(
                    onTap: () => _pickPhoto(fromCamera: true),
                    child: Semantics(
                      button: true,
                      label: t.advisorHudPhotoRetry,
                      child: Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.errorContainer.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(AppDimensions.r8),
                          border: Border.all(color: colors.error),
                        ),
                        child: Icon(
                          Icons.refresh_rounded,
                          color: colors.error,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 6),
          SizedBox(
            height: 44,
            child: TextButton.icon(
              onPressed: () => _showNoteDialog(media?.note ?? ''),
              icon: Icon(
                Icons.edit_note_rounded,
                size: 18,
                color: hasNote ? colors.primary : colors.onSurfaceVariant,
              ),
              label: Text(
                hasNote ? (media?.note ?? '') : t.advisorHudAddNote,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _PhotoTile({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Semantics(
        button: true,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.r8),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Icon(icon, color: colors.onSurfaceVariant, size: 24),
        ),
      ),
    );
  }
}

class _DeniedRow extends StatelessWidget {
  final String title;
  final String hint;
  final VoidCallback onRetry;

  const _DeniedRow({
    required this.title,
    required this.hint,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppDimensions.r12),
        border: Border.all(color: colors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.block_rounded, color: colors.error, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  hint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              onRetry();
            },
            child: Text(t.advisorHudOpenSettings),
          ),
        ],
      ),
    );
  }
}

// ─── STICKY FOOTER ───────────────────────────────────────────────────────────

// Bottom dock, fixed once: ONE primary CTA whose verb matches the active
// tab's job — damage tab marks damage (Done marking → checkpoints), checks
// tab grades checkpoints (Review → dossier). The notify toggle lives in
// the Review sheet (secondary); the offline pill already in the header is
// the single queued-state announcement.
class _HudFooter extends ConsumerWidget {
  final InspectionCallbacks callbacks;
  final int tab;
  final VoidCallback onDoneMarking;

  const _HudFooter({
    required this.callbacks,
    required this.tab,
    required this.onDoneMarking,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: tab == 0
              ? PrimaryButton(
                  label: t.advisorHudDoneMarking,
                  icon: Icons.check_rounded,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onDoneMarking();
                  },
                )
              : PrimaryButton(
                  label: t.advisorHudReview,
                  icon: Icons.preview_outlined,
                  onPressed: () => _openReviewSheet(context, ref),
                ),
        ),
      ),
    );
  }

  Future<void> _openReviewSheet(BuildContext context, WidgetRef ref) =>
      showInspectionReviewSheet(context, ref, callbacks);
}

class _ReviewSheetBody extends ConsumerWidget {
  final InspectionCallbacks callbacks;

  const _ReviewSheetBody({required this.callbacks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final state = ref.watch(inspectionProvider);
    final notifier = ref.read(inspectionProvider.notifier);
    final pins = state.vehiclePartInspections.values
        .expand((p) => p.findings)
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.advisorHudProgress(state.completedCount, state.totalItems),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (pins > 0) ...[
            const SizedBox(height: 4),
            Text(
              '${t.advisorHudPinsTitle} · $pins',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Switch.adaptive(
                value: state.notifyOwner,
                onChanged: (_) {
                  HapticFeedback.selectionClick();
                  notifier.toggleNotifyOwner();
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.advisorHudNotifyOwner,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: t.advisorHudContinue,
            icon: Icons.arrow_forward_rounded,
            onPressed: () {
              Navigator.pop(context);
              callbacks.onPreview();
            },
          ),
        ],
      ),
    );
  }
}

/// The full pins management list (select/edit/delete rows) for the pins
/// drawer/sheet. It watches the provider itself: drawer routes are built
/// once, so a captured snapshot would go stale after edits/deletes.
class _PinsList extends ConsumerWidget {
  final String? selectedFindingId;
  final ValueChanged<VehicleDamageFinding> onSelect;
  final ValueChanged<VehicleDamageFinding> onEdit;

  const _PinsList({
    required this.selectedFindingId,
    required this.onSelect,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final state = ref.watch(inspectionProvider);
    final notifier = ref.read(inspectionProvider.notifier);
    final entries = pinsEntries(state);
    final total = pinsTotal(state);

    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            t.advisorHudNoPinsHint,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '${t.advisorHudPinsTitle} · $total',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        for (final entry in entries.entries)
          for (final f in entry.value.findings)
            _DamagePinRow(
              partId: entry.key,
              finding: f,
              selected: selectedFindingId == f.id,
              onSelect: () => onSelect(f),
              onEdit: () => onEdit(f),
              onDelete: () =>
                  notifier.removeVehicleDamageFinding(entry.key, f.id),
            ),
      ],
    );
  }
}


/// One docked pin chip: severity dot + part short label. Numbers live
/// on the canvas pins only, so dock order never disagrees with them.
class _PinChip extends StatelessWidget {
  final VehicleDamageFinding finding;
  final bool selected;
  final VoidCallback onTap;

  const _PinChip({
    required this.finding,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final tone = damageSeverityTone(context.semanticColors, finding.severity);

    return Semantics(
      button: true,
      selected: selected,
      label:
          '${damagePartLabel(t, finding.partId)} — ${damageSeverityLabel(t, finding.severity)}',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          height: 36,
          padding: const EdgeInsetsDirectional.only(start: 10, end: 10),
          decoration: BoxDecoration(
            color: selected
                ? colors.primary.withValues(alpha: 0.14)
                : colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: selected ? colors.primary : colors.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: tone.base,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  damagePartLabel(t, finding.partId),
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
