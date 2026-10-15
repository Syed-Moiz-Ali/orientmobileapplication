import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/inspection_model.dart';
import 'package:staff_app/features/advisor/inspection_pages/presentation/vehicle_map/vehicle_body_condition_panel.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

import 'inspection_provider.dart';
import 'real_damage_canvas.dart';

/// Phase 08 — Concept A vehicle health report (Archetype 6 output).
///
/// A formal report document: big overall-health score, Mandatory Safety
/// (red) / Recommended (amber) / Good (green) finding groups, damage-pin
/// recap, and one-tap Convert-to-Estimate. Submission, offline queueing,
/// routes and the estimate handoff are byte-identical to the previous
/// composition.
class InspectionPreviewView extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final String jobId;

  const InspectionPreviewView({super.key, required this.onBack, this.jobId = ''});

  @override
  ConsumerState<InspectionPreviewView> createState() =>
      _InspectionPreviewViewState();
}

int _healthScore(InspectionState state) {
  if (state.statuses.isEmpty) return 0;
  var points = 0;
  for (final status in state.statuses.values) {
    points += switch (status) {
      ItemStatus.good => 100,
      ItemStatus.fair => 55,
      ItemStatus.poor => 5,
    };
  }
  return (points / state.statuses.length).round();
}

class _InspectionPreviewViewState extends ConsumerState<InspectionPreviewView> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final pendingSync = ref.watch(advisorPendingSyncCountProvider).valueOrNull;

    final state = ref.watch(inspectionProvider);
    final hasRatings = state.statuses.isNotEmpty;
    final remaining = (state.totalItems - state.completedCount).clamp(
      0,
      state.totalItems,
    );
    final score = _healthScore(state);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: WorkspaceAppBar(
        title: t.advisorHealthTitle,
        subtitle: hasRatings
            ? t.advisorHealthScoredOf(state.completedCount, state.totalItems)
            : t.advisorHealthEmpty,
        showBack: true,
        onBack: _isSubmitting ? null : widget.onBack,
        frosted: !context.isCompact,
        showOfflineStatus: true,
        offlinePendingCount: pendingSync,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Sticky wayfinding anchor: one-row score strip + ONE
            // share/export control row. Findings scroll beneath it.
            _ScoreStrip(score: score, state: state),
            _ShareExportRow(state: state, score: score),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final findings = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (remaining > 0 && hasRatings) ...[
                        _IncompleteNotice(
                          remaining: remaining,
                          onEdit: widget.onBack,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (!hasRatings)
                        EmptyState(
                          icon: Icons.health_and_safety_outlined,
                          title: t.advisorHealthEmpty,
                          message: t.advisorHealthEmptyHint,
                        )
                      else ...[
                        _FindingGroup(
                          status: ItemStatus.poor,
                          state: state,
                          initiallyExpanded: true,
                        ),
                        const SizedBox(height: 10),
                        _FindingGroup(
                          status: ItemStatus.fair,
                          state: state,
                          initiallyExpanded: true,
                        ),
                        const SizedBox(height: 10),
                        _FindingGroup(
                          status: ItemStatus.good,
                          state: state,
                          initiallyExpanded: false,
                        ),
                      ],
                    ],
                  );
                  final rail = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (hasRatings) ...[
                        _DamageRecap(state: state),
                        _LegacyBodySection(state: state),
                      ],
                    ],
                  );
                  // Expanded/large windows: genuine two-col dossier —
                  // score+groups left, recap+legacy actions rail right
                  // (340px). Compact/medium stay a single judgment stream
                  // (recap first). Window class only, never raw widths.
                  final wide = context.isExpanded || context.isLarge;
                  if (wide && hasRatings) {
                    return AppResponsivePage(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Wayfinding without a duplicated H1: the app bar
                          // already titles this dossier.
                          AppBreadcrumbs(
                            items: [
                              AppBreadcrumbItem(
                                label: StaffLocalizations.of(
                                  context,
                                )!.advisorNavJobs,
                                onTap: widget.onBack,
                              ),
                              AppBreadcrumbItem.current(t.advisorHealthTitle),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t.advisorHealthSubtitle,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: findings),
                              const SizedBox(width: 16),
                              SizedBox(width: 340, child: rail),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  }
                  return AppResponsivePage(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppPageHeader(
                          title: t.advisorHealthTitle,
                          subtitle: t.advisorHealthSubtitle,
                          breadcrumbs: [
                            AppBreadcrumbItem(
                              label: StaffLocalizations.of(
                                context,
                              )!.advisorNavJobs,
                              onTap: widget.onBack,
                            ),
                            AppBreadcrumbItem.current(t.advisorHealthTitle),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (hasRatings) ...[
                          _DamageRecap(state: state),
                          const SizedBox(height: 12),
                        ],
                        findings,
                        if (hasRatings) _LegacyBodySection(state: state),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
            _ReportFooter(
              state: state,
              hasRatings: hasRatings,
              isSubmitting: _isSubmitting,
              onConvert: _convertToEstimate,
              onSubmit: _confirmAndSave,
              onBack: widget.onBack,
            ),
          ],
        ),
      ),
    );
  }

  void _convertToEstimate() {
    HapticFeedback.mediumImpact();
    context.push(
      AppRoutes.repairOrder,
      extra: {'onBack': () => context.pop(), 'fromInspection': true},
    );
  }

  Future<void> _confirmAndSave() async {
    final t = StaffLocalizations.of(context)!;
    final confirmed = await showAppConfirmationDialog(
      context,
      title: t.advisorHealthSubmitTitle,
      message: t.advisorHealthSubmitMessage,
      confirmLabel: t.advisorHealthSubmit,
      cancelLabel: t.advisorHealthReviewAgain,
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isSubmitting = true);
    await _saveAndUpdate();
    if (mounted) setState(() => _isSubmitting = false);
  }

  Future<void> _saveAndUpdate() async {
    final notifier = ref.read(inspectionProvider.notifier);
    final currentJobCardId = ref.read(inspectionProvider).jobCardId;
    final result = await notifier.submitInspection();
    if (!context.mounted) return;
    await result.when(
      success: (_) async {
        JobCardEntity? target;
        try {
          final detail = await ref
              .read(advisorRemoteDataSourceProvider)
              .getJobCard(currentJobCardId);
          final status = JobCardStatus.values.firstWhere(
            (s) => s.name == detail.status,
            orElse: () => JobCardStatus.inspected,
          );
          target = JobCardEntity(
            id: detail.id.isNotEmpty ? detail.id : currentJobCardId,
            dbId: detail.dbId,
            customerName: detail.customerName,
            vehicleInfo: detail.vehicleInfo,
            time: detail.time,
            createdDate: detail.createdDate,
            lastUpdated: detail.lastUpdated,
            status: status,
            technician: detail.technician,
            odometer: detail.odometer,
            fuelLevel: detail.fuelLevel,
          );
        } catch (_) {
          // Offline: the inspection is queued and will sync later; we cannot
          // refresh the job card right now.
        }
        if (!mounted) return;
        if (target != null) {
          context.pushReplacement(AppRoutes.advisorJobDetail, extra: target);
        } else {
          widget.onBack();
        }
      },
      failure: (error) async {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      },
    );
  }
}

/// JUDGMENT screen anchor: the score is ONE sticky row (badge + health +
/// coverage + 3 splits inline) so findings own the viewport. The 3-up
/// dossier card was deliberately not cloned here.
class _ScoreStrip extends StatelessWidget {
  final int score;
  final InspectionState state;

  const _ScoreStrip({required this.score, required this.state});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    final good = state.statuses.values
        .where((s) => s == ItemStatus.good)
        .length;
    final fair = state.statuses.values
        .where((s) => s == ItemStatus.fair)
        .length;
    final poor = state.statuses.values
        .where((s) => s == ItemStatus.poor)
        .length;

    final scoreColor = poor > 0
        ? colors.error
        : fair > 0
        ? context.semanticColors.inspectionAdvisory.base
        : context.semanticColors.inspectionPass.base;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Semantics(
        label: t.advisorHealthScore(score),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: scoreColor.withValues(alpha: 0.45),
                  width: 2,
                ),
              ),
              child: Icon(
                poor > 0
                    ? Icons.priority_high_rounded
                    : fair > 0
                    ? Icons.remove_red_eye_outlined
                    : Icons.verified_outlined,
                color: scoreColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                t.advisorHealthScore(score),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: scoreColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _StripSplit(count: good, status: ItemStatus.good),
            const SizedBox(width: 6),
            _StripSplit(count: fair, status: ItemStatus.fair),
            const SizedBox(width: 6),
            _StripSplit(count: poor, status: ItemStatus.poor),
          ],
        ),
      ),
    );
  }
}

class _StripSplit extends StatelessWidget {
  final int count;
  final ItemStatus status;

  const _StripSplit({required this.count, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final semantic = context.semanticColors;
    final ink = status == ItemStatus.good
        ? semantic.inspectionPass.base
        : status == ItemStatus.fair
        ? semantic.inspectionAdvisory.base
        : semantic.inspectionFail.base;

    return Container(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimensions.r12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: ink,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Container(
            width: 20,
            height: 4,
            decoration: BoxDecoration(
              color: ink,
              borderRadius: BorderRadius.circular(AppDimensions.r4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dossier control row: Share copies a short summary, Export copies the
/// full finding detail — both real clipboard payloads, no backend.
class _ShareExportRow extends StatelessWidget {
  final InspectionState state;
  final int score;

  const _ShareExportRow({required this.state, required this.score});

  String _summary(StaffLocalizations t) {
    final good = state.statuses.values
        .where((s) => s == ItemStatus.good)
        .length;
    final fair = state.statuses.values
        .where((s) => s == ItemStatus.fair)
        .length;
    final poor = state.statuses.values
        .where((s) => s == ItemStatus.poor)
        .length;
    return '${t.advisorHealthScore(score)} — '
        '${t.advisorHealthMandatory}: $poor, '
        '${t.advisorHealthRecommended}: $fair, '
        '${t.advisorHealthGoodGroup}: $good';
  }

  String _detail(StaffLocalizations t) {
    final lines = <String>[_summary(t)];
    for (final section in state.sections) {
      for (var i = 0; i < section.items.length; i++) {
        final status = state.statuses['${section.id}_$i'];
        if (status == null) continue;
        lines.add('${section.label} — ${section.items[i]}: ${status.name}');
      }
    }
    return lines.join('\n');
  }

  Future<void> _copy(BuildContext context, String payload) async {
    final t = StaffLocalizations.of(context)!;
    HapticFeedback.selectionClick();
    await Clipboard.setData(ClipboardData(text: payload));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.advisorHealthCopied)));
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 44,
      padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              t.advisorHealthScoredOf(state.completedCount, state.totalItems),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            height: 44,
            child: TextButton.icon(
              onPressed: () => _copy(context, _summary(t)),
              icon: const Icon(Icons.share_outlined, size: 18),
              label: Text(t.advisorHealthShare),
            ),
          ),
          SizedBox(
            height: 44,
            child: TextButton.icon(
              onPressed: () => _copy(context, _detail(t)),
              icon: const Icon(Icons.ios_share_outlined, size: 18),
              label: Text(t.advisorHealthExport),
            ),
          ),
        ],
      ),
    );
  }
}

class _DamageRecap extends StatelessWidget {
  final InspectionState state;

  const _DamageRecap({required this.state});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    // One grammar for every pin: map-authored and intake findings share the
    // same real part ids, so the recap renders them together.
    final total = state.vehiclePartInspections.values
        .expand((p) => p.findings)
        .length;
    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: '${t.advisorHudPinsTitle} · $total',
            leadingIcon: Icons.push_pin_outlined,
          ),
          const SizedBox(height: 8),
          // The recap geometry is LTR-locked inside the canvas and never
          // mirrors in AR RTL (spec §2.2 exception 1). Read-only: pins are
          // managed on the damage-map tab.
          SizedBox(
            height: 200,
            child: RealDamageCanvas(
              inspections: state.vehiclePartInspections,
              editable: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegacyBodySection extends StatefulWidget {
  final InspectionState state;

  const _LegacyBodySection({required this.state});

  @override
  State<_LegacyBodySection> createState() => _LegacyBodySectionState();
}

class _LegacyBodySectionState extends State<_LegacyBodySection> {
  // Legacy intake detail stays collapsed — the dossier groups are the
  // judgment surface; the body panel opens only on explicit intent.
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    var legacyCount = 0;
    widget.state.vehiclePartInspections.forEach((partId, inspection) {
      legacyCount += inspection.findings.length;
    });
    if (legacyCount == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _open = !_open);
          },
          child: Semantics(
            button: true,
            expanded: _open,
            label: StaffLocalizations.of(
              context,
            )!.advisorBodyConditionHint,
            child: Container(
              height: 48,
              padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.r16),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    size: 20,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${StaffLocalizations.of(context)!.advisorBodyConditionHint} · $legacyCount',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _open
                        ? StaffLocalizations.of(
                            context,
                          )!.advisorHealthCollapse
                        : StaffLocalizations.of(context)!.advisorHealthExpand,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Icon(
                    _open
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: colors.onSurfaceVariant,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_open) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.r16),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: const VehicleBodyConditionPanel(
              readOnly: true,
              embedded: true,
              showTitle: false,
            ),
          ),
        ],
      ],
    );
  }
}

class _FindingGroup extends StatefulWidget {
  final ItemStatus status;
  final InspectionState state;
  final bool initiallyExpanded;

  const _FindingGroup({
    required this.status,
    required this.state,
    this.initiallyExpanded = true,
  });

  @override
  State<_FindingGroup> createState() => _FindingGroupState();
}

class _FindingGroupState extends State<_FindingGroup> {
  late bool _open;

  @override
  void initState() {
    super.initState();
    _open = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final semantic = context.semanticColors;
    final status = widget.status;
    final state = widget.state;

    final entries = <({String section, String item, int attachments})>[];
    for (final section in state.sections) {
      for (var i = 0; i < section.items.length; i++) {
        final itemId = '${section.id}_$i';
        if (state.statuses[itemId] != status) continue;
        final media = state.media[itemId];
        entries.add(
          (
            section: section.label,
            item: section.items[i],
            attachments:
                (media?.photoPaths.length ?? 0) +
                (media?.videoPaths.length ?? 0) +
                ((media?.audioPath.isNotEmpty ?? false) ? 1 : 0) +
                ((media?.note.isNotEmpty ?? false) ? 1 : 0),
          ),
        );
      }
    }
    if (entries.isEmpty) return const SizedBox.shrink();

    final tone = status == ItemStatus.poor
        ? semantic.danger
        : status == ItemStatus.fair
        ? semantic.warning
        : semantic.success;
    final title = status == ItemStatus.poor
        ? t.advisorHealthMandatory
        : status == ItemStatus.fair
        ? t.advisorHealthRecommended
        : t.advisorHealthGoodGroup;
    final icon = status == ItemStatus.poor
        ? Icons.priority_high_rounded
        : status == ItemStatus.fair
        ? Icons.build_outlined
        : Icons.check_circle_outline_rounded;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        border: Border.all(color: tone.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status header verdict (never rings): tap toggles the group.
          // Mandatory + Recommended ship expanded; Good ships collapsed.
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _open = !_open);
            },
            child: Semantics(
              button: true,
              expanded: _open,
              label: '$title ${entries.length}',
              child: Container(
                height: 48,
                color: Colors.transparent,
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: tone.base,
                        borderRadius: BorderRadius.circular(AppDimensions.r8),
                      ),
                      child: Icon(
                        icon,
                        // FIXED-INK: white glyph on the saturated status fill.
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '$title · ${entries.length}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: tone.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _open
                          ? t.advisorHealthCollapse
                          : t.advisorHealthExpand,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Icon(
                      _open
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: colors.onSurfaceVariant,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_open) ...[
            const SizedBox(height: 6),
            for (final e in entries)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: tone.subtle.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppDimensions.r12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.item,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          e.section,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (e.attachments > 0)
                          Text(
                            t.advisorHealthAttachments(e.attachments),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
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
                      status == ItemStatus.poor
                          ? t.advisorHudRingFail
                          : status == ItemStatus.fair
                          ? t.advisorHudRingCaution
                          : t.advisorHudRingPass,
                      style: TextStyle(
                        color: tone.ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _IncompleteNotice extends StatelessWidget {
  final int remaining;
  final VoidCallback onEdit;

  const _IncompleteNotice({required this.remaining, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: colors.secondaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppDimensions.r12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: colors.onSecondaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              t.advisorHealthRemaining(remaining),
              style: TextStyle(
                color: colors.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: onEdit,
            child: Text(t.advisorHealthBackEdit),
          ),
        ],
      ),
    );
  }
}

class _ReportFooter extends StatelessWidget {
  final InspectionState state;
  final bool hasRatings;
  final bool isSubmitting;
  final VoidCallback onConvert;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const _ReportFooter({
    required this.state,
    required this.hasRatings,
    required this.isSubmitting,
    required this.onConvert,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              hasRatings
                  ? t.advisorHealthReady(state.statuses.length)
                  : t.advisorHealthEmptyHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            // One primary verb (Convert) + one secondary verb (Submit):
            // always side-by-side, never two stacked full-width primaries.
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: t.advisorHealthConvert,
                    icon: Icons.request_quote_outlined,
                    onPressed: !hasRatings || isSubmitting ? null : onConvert,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SecondaryButton(
                    label: isSubmitting
                        ? t.advisorHealthSubmitting
                        : t.advisorHealthSubmit,
                    leadingIcon: Icons.cloud_upload_outlined,
                    onPressed: !hasRatings || isSubmitting ? null : onSubmit,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: isSubmitting ? null : onBack,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(t.advisorHealthBackEdit),
            ),
          ],
        ),
      ),
    );
  }
}
