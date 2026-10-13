// D6 · Advisor Inspection prototype (hardest interaction).
//
// Mirrors the production flow (inspection_sheet_view.dart +
// vehicle_body_condition_panel.dart + vehicle_inspection_map.dart):
//   production 5-step workflow indicator (Job Card → Inspect → Estimate →
//   Repair → Deliver, current = Inspect) · section navigation (horizontal
//   chips on compact, vertical rail on medium+) · three-state checkpoint
//   cards with media affordances · the REAL damage map asset with a finding
//   sheet · sticky footer (Notify owner + Review inspection).
//
// CANONICAL RTL EXCEPTION: the vehicle outline never mirrors; every
// surrounding surface does (see `insp.map.rtlNote` when Arabic is active).
import 'dart:async';

import 'package:flutter/material.dart';

import '../../design/prototype_theme.dart';
import '../../design/provisional_tokens.dart';
import '../../fixtures/inspection_fixtures.dart';
import '../../l10n/provisional_strings.dart';
import '../../widgets/proto_primitives.dart';
import '../../widgets/proto_vehicle_map.dart';

class InspectionPrototype extends StatefulWidget {
  final String variant;

  const InspectionPrototype({super.key, required this.variant});

  @override
  State<InspectionPrototype> createState() => _InspectionPrototypeState();
}

class _InspectionPrototypeState extends State<InspectionPrototype> {
  static const _bodyMapId = '_body_map';

  String _sectionId = _bodyMapId;
  Map<String, FixtureItemStatus> _ratings = {};
  List<DamageFindingFixture> _findings = [];
  String? _selectedPartId;
  bool _notifyOwner = true;
  int _exitGuardShown = 0;

  static const _totalCheckpoints = 26;

  @override
  void initState() {
    super.initState();
    switch (widget.variant) {
      case 'empty':
        _ratings = {};
        _findings = [];
      case 'complete':
        _ratings = Map.of(completeRatings);
        _findings = List.of(damageFindings);
      default:
        _ratings = Map.of(partialRatings);
        _findings = List.of(damageFindings);
    }
    if (widget.variant == 'exitGuard') {
      WidgetsBinding.instance.addPostFrameCallback((_) => _confirmExit());
    }
    if (widget.variant == 'findingSheet') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _findings.isNotEmpty) _openFindingSheet(existing: _findings.first);
      });
    }
  }

  int get _ratedCount => _ratings.length;
  double get _progress => _ratedCount / _totalCheckpoints;

  void _toggleRating(String itemId, FixtureItemStatus status) {
    setState(() {
      if (_ratings[itemId] == status) {
        _ratings.remove(itemId);
      } else {
        _ratings[itemId] = status;
      }
    });
  }

  void _markSectionGood(InspectionSectionFixture section) {
    setState(() {
      for (var i = 0; i < section.checkpointKeys.length; i++) {
        _ratings.putIfAbsent(checkpointId(section.id, i), () => FixtureItemStatus.good);
      }
    });
  }

  Future<void> _openFindingSheet({DamageFindingFixture? existing, String? partId}) async {
    final selectedPart = partId ?? _selectedPartId ?? existing?.partId ?? 'front_bumper';
    await showProtoSheet<void>(
      context,
      child: _FindingSheet(
        partId: selectedPart,
        partLabel: context.s(partLabelKeys[selectedPart] ?? 'insp.map.selectPart'),
        existing: existing,
        onSave: (finding) {
          setState(() {
            final index = _findings.indexWhere((f) => f.id == finding.id);
            if (index == -1) {
              _findings = [..._findings, finding];
            } else {
              _findings = [..._findings]..[index] = finding;
            }
            _selectedPartId = finding.partId;
          });
        },
        onDelete: existing == null
            ? null
            : () => setState(() {
                  _findings = _findings.where((f) => f.id != existing.id).toList();
                }),
      ),
    );
  }

  Future<void> _confirmExit() async {
    // Only for the exit-guard review variant.
    if (widget.variant != 'exitGuard' || _exitGuardShown > 0) return;
    _exitGuardShown++;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: context.palette.warning, size: 30),
        title: Text(context.s('insp.exit.title')),
        content: Text(context.s('insp.exit.body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.s('insp.exit.stay')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: context.palette.danger),
            onPressed: () => Navigator.pop(context),
            child: Text(context.s('insp.exit.leave')),
          ),
        ],
      ),
    );
  }

  void _openReview() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.preview_outlined, color: context.palette.primary, size: 30),
        title: Text(context.s('insp.review.title')),
        content: Text(context.s('insp.review.body', {
          'done': '$_ratedCount',
          'total': '$_totalCheckpoints',
          'findings': '${_findings.length}',
          'photos': '4',
        })),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.s('common.close')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.s('insp.review.continue')),
          ),
        ],
      ),
    );
  }

  void _openMediaSheet(String itemId) {
    showProtoSheet<void>(
      context,
      child: _MediaSheet(
        title: context.s('insp.media.title'),
        onPick: (source) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text('${context.s('insp.media.title')} · $source')));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final windowClass = context.windowClass;

    final checkpoints = _sectionId == _bodyMapId ? null : inspectionSections.firstWhere((s) => s.id == _sectionId);

    final contentPane = checkpoints == null
        ? (windowClass.isCompact
            // Compact: the map card itself is the section content.
            ? _BodyMapCard(
                findings: _findings,
                conditions: Map.of(partialPartConditions),
                selectedPartId: _selectedPartId,
                onPartTap: (partId) {
                  setState(() => _selectedPartId = partId);
                  _openFindingSheet(partId: partId);
                },
                onFindingTap: (finding) => _openFindingSheet(existing: finding),
                rtlNote: context.isRtl,
              )
            // Medium/expanded: the map lives in the right pane; the section
            // pane carries the instruction, selected part and findings.
            : _BodyMapDetails(
                findings: _findings,
                conditions: Map.of(partialPartConditions),
                selectedPartId: _selectedPartId,
                onAddDamage: (partId) => _openFindingSheet(partId: partId),
                onFindingTap: (finding) => _openFindingSheet(existing: finding),
              ))
        : _CheckpointPane(
            section: checkpoints,
            ratings: _ratings,
            onToggle: _toggleRating,
            onMarkAllGood: () => _markSectionGood(checkpoints),
            onMedia: _openMediaSheet,
          );

    final mapPane = _BodyMapCard(
      findings: _findings,
      conditions: Map.of(partialPartConditions),
      selectedPartId: _selectedPartId,
      onPartTap: (partId) {
        setState(() => _selectedPartId = partId);
        _openFindingSheet(partId: partId);
      },
      onFindingTap: (finding) => _openFindingSheet(existing: finding),
      rtlNote: context.isRtl,
      showFindings: windowClass.isCompact,
    );

    Widget body;
    if (windowClass.isCompact) {
      body = Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(ProtoSpace.s16, ProtoSpace.s12, ProtoSpace.s16, ProtoSpace.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _WorkflowIndicator(progress: _progress, rated: _ratedCount, total: _totalCheckpoints),
                  const SizedBox(height: ProtoSpace.s12),
                  _SectionChipsRail(
                    selectedId: _sectionId,
                    ratings: _ratings,
                    findings: _findings,
                    onSelect: (id) => setState(() => _sectionId = id),
                  ),
                  const SizedBox(height: ProtoSpace.s12),
                  contentPane,
                ],
              ),
            ),
          ),
        ],
      );
    } else if (windowClass.isExpanded) {
      // Three-pane: rail | checkpoints | map+summary.
      body = Padding(
        padding: const EdgeInsets.all(ProtoSpace.s16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 236,
              child: SingleChildScrollView(
                child: _VerticalRail(
                  selectedId: _sectionId,
                  ratings: _ratings,
                  findings: _findings,
                  onSelect: (id) => setState(() => _sectionId = id),
                ),
              ),
            ),
            const SizedBox(width: ProtoSpace.s16),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _WorkflowIndicator(progress: _progress, rated: _ratedCount, total: _totalCheckpoints),
                    const SizedBox(height: ProtoSpace.s12),
                    contentPane,
                  ],
                ),
              ),
            ),
            const SizedBox(width: ProtoSpace.s16),
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [mapPane],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Two-pane at medium: checkpoints | map+summary; rail stays horizontal.
      body = Column(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(ProtoSpace.s16, ProtoSpace.s12, ProtoSpace.s16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WorkflowIndicator(progress: _progress, rated: _ratedCount, total: _totalCheckpoints),
                const SizedBox(height: ProtoSpace.s12),
                _SectionChipsRail(
                  selectedId: _sectionId,
                  ratings: _ratings,
                  findings: _findings,
                  onSelect: (id) => setState(() => _sectionId = id),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(ProtoSpace.s16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(child: contentPane),
                  ),
                  const SizedBox(width: ProtoSpace.s16),
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(child: mapPane),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        ProtoTopBar(
          title: context.s('insp.title'),
          subtitle: context.s('insp.subtitle', {'done': '$_ratedCount', 'total': '$_totalCheckpoints'}),
          onBack: _confirmExit,
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s10, vertical: ProtoSpace.s6),
              decoration: BoxDecoration(
                color: p.primarySubtle,
                borderRadius: BorderRadius.circular(ProtoRadius.pill),
                border: Border.all(color: p.primaryBorder),
              ),
              child: Text(
                '${(_progress * 100).round()}%',
                style: context.types.monoStrong.copyWith(color: p.primary, fontSize: 12),
              ),
            ),
            const SizedBox(width: ProtoSpace.s12),
          ],
        ),
        Expanded(child: body),
        _StickyFooter(
          notifyOwner: _notifyOwner,
          onNotifyChanged: (v) => setState(() => _notifyOwner = v),
          onReview: _openReview,
        ),
      ],
    );
  }
}

/// Production workflow: Job Card → Inspect → Estimate → Repair → Deliver,
/// current step = Inspect (index 1 → "Step 2 of 5").
class _WorkflowIndicator extends StatelessWidget {
  final double progress;
  final int rated;
  final int total;

  const _WorkflowIndicator({required this.progress, required this.rated, required this.total});

  static const _steps = [
    ('insp.wf.jobCard', Icons.person_search_rounded),
    ('insp.wf.inspect', Icons.fact_check_outlined),
    ('insp.wf.estimate', Icons.receipt_long_outlined),
    ('insp.wf.repair', Icons.build_outlined),
    ('insp.wf.deliver', Icons.key_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    const current = 1;
    final wide = !context.windowClass.isCompact;

    return ProtoCard(
      padding: const EdgeInsets.fromLTRB(ProtoSpace.s14, ProtoSpace.s12, ProtoSpace.s14, ProtoSpace.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: p.primarySubtle,
                  borderRadius: BorderRadius.circular(ProtoRadius.control),
                ),
                child: Icon(_steps[current].$2, color: p.primary, size: 20),
              ),
              const SizedBox(width: ProtoSpace.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.s(_steps[current].$1),
                      style: types.cardTitle.copyWith(color: p.textPrimary),
                    ),
                    Text(
                      context.s('insp.wf.description'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: types.metadata.copyWith(color: p.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s10, vertical: 4),
                decoration: BoxDecoration(
                  color: p.primary,
                  borderRadius: BorderRadius.circular(ProtoRadius.pill),
                ),
                child: Text(
                  context.s('insp.step.label', {'n': '${current + 1}', 'total': '${_steps.length}'}),
                  style: types.metadata.copyWith(color: p.textInverse, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: ProtoSpace.s12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                final connectorIndex = i ~/ 2;
                return Expanded(
                  child: AnimatedContainer(
                    duration: ProtoMotion.standard,
                    height: 2.5,
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: connectorIndex < current ? p.primary : p.borderDefault,
                      borderRadius: BorderRadius.circular(ProtoRadius.pill),
                    ),
                  ),
                );
              }
              final index = i ~/ 2;
              final isActive = index == current;
              final isDone = index < current;
              return SizedBox(
                width: wide ? 72 : 46,
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: ProtoMotion.standard,
                      width: 27,
                      height: 27,
                      decoration: BoxDecoration(
                        color: isActive
                            ? p.primary
                            : isDone
                                ? p.primarySubtle
                                : p.surfaceSunken,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDone || isActive ? p.primary : p.borderDefault,
                          width: isActive ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        isDone ? Icons.check_rounded : _steps[index].$2,
                        size: 13,
                        color: isActive
                            ? p.textInverse
                            : isDone
                                ? p.primary
                                : p.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.s(_steps[index].$1),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: types.metadata.copyWith(
                        fontSize: 9.5,
                        color: isActive ? p.primary : p.textMuted,
                        fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: ProtoSpace.s10),
          ProtoProgress(
            value: progress,
            label: context.s('insp.subtitle', {'done': '$rated', 'total': '$total'}),
          ),
        ],
      ),
    );
  }
}

class _SectionChipsRail extends StatelessWidget {
  final String selectedId;
  final Map<String, FixtureItemStatus> ratings;
  final List<DamageFindingFixture> findings;
  final ValueChanged<String> onSelect;

  const _SectionChipsRail({
    required this.selectedId,
    required this.ratings,
    required this.findings,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chip(
            context,
            id: '_body_map',
            label: context.s('insp.rail.bodyMapCount', {
              'inspected': '25',
              'issues': '${findings.length}',
            }),
            icon: Icons.directions_car_filled_rounded,
          ),
          for (final section in inspectionSections) ...[
            const SizedBox(width: ProtoSpace.s8),
            _chip(
              context,
              id: section.id,
              label: '${_shortLabel(context, section)}  ${_rated(section)}/${section.checkpointKeys.length}',
              icon: null,
              done: _rated(section) == section.checkpointKeys.length,
            ),
          ],
        ],
      ),
    );
  }

  String _shortLabel(BuildContext context, InspectionSectionFixture section) {
    final label = context.s(section.labelKey);
    return label.replaceFirst(RegExp(r'^0\d\.\s*'), '');
  }

  int _rated(InspectionSectionFixture section) {
    var count = 0;
    for (var i = 0; i < section.checkpointKeys.length; i++) {
      if (ratings.containsKey(checkpointId(section.id, i))) count++;
    }
    return count;
  }

  Widget _chip(
    BuildContext context, {
    required String id,
    required String label,
    required IconData? icon,
    bool done = false,
  }) {
    final p = context.palette;
    final selected = id == selectedId;
    return Material(
      color: selected ? p.primary : p.surface,
      borderRadius: BorderRadius.circular(ProtoRadius.pill),
      child: InkWell(
        onTap: () => onSelect(id),
        borderRadius: BorderRadius.circular(ProtoRadius.pill),
        hoverColor: selected ? p.primaryHover : p.hover,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s12, vertical: ProtoSpace.s8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ProtoRadius.pill),
            border: Border.all(
              color: selected
                  ? p.primary
                  : done
                      ? p.successBorder
                      : p.borderDefault,
            ),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: selected ? Colors.white : p.textSecondary),
                const SizedBox(width: ProtoSpace.s6),
              ] else if (done && !selected) ...[
                Icon(Icons.check_circle_rounded, size: 14, color: p.success),
                const SizedBox(width: ProtoSpace.s6),
              ],
              Text(
                label,
                style: context.types.label.copyWith(
                  fontSize: 12,
                  color: selected ? Colors.white : p.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerticalRail extends StatelessWidget {
  final String selectedId;
  final Map<String, FixtureItemStatus> ratings;
  final List<DamageFindingFixture> findings;
  final ValueChanged<String> onSelect;

  const _VerticalRail({
    required this.selectedId,
    required this.ratings,
    required this.findings,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;

    Widget item({
      required String id,
      required String label,
      required String meta,
      IconData? icon,
      bool done = false,
    }) {
      final selected = id == selectedId;
      return Padding(
        padding: const EdgeInsets.only(bottom: ProtoSpace.s8),
        child: Material(
          color: selected ? p.selected : p.surface,
          borderRadius: BorderRadius.circular(ProtoRadius.card),
          child: InkWell(
            onTap: () => onSelect(id),
            borderRadius: BorderRadius.circular(ProtoRadius.card),
            hoverColor: p.hover,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s12, vertical: ProtoSpace.s12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ProtoRadius.card),
                border: Border.all(color: selected ? p.primaryBorder : p.borderDefault),
              ),
              child: Row(
                children: [
                  Icon(
                    icon ?? (done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded),
                    size: 17,
                    color: selected
                        ? p.primary
                        : done
                            ? p.success
                            : p.textDisabled,
                  ),
                  const SizedBox(width: ProtoSpace.s10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: types.label.copyWith(
                            color: selected ? p.primary : p.textSecondary,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(meta, style: types.metadata.copyWith(color: p.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        item(
          id: '_body_map',
          label: context.s('insp.rail.bodyMap'),
          meta: context.s('insp.map.summary', {'parts': '25', 'findings': '${findings.length}'}),
          icon: Icons.directions_car_filled_rounded,
        ),
        for (final section in inspectionSections)
          item(
            id: section.id,
            label: context.s(section.labelKey),
            meta: '${_rated(section)}/${section.checkpointKeys.length}',
            done: _rated(section) == section.checkpointKeys.length,
          ),
      ],
    );
  }

  int _rated(InspectionSectionFixture section) {
    var count = 0;
    for (var i = 0; i < section.checkpointKeys.length; i++) {
      if (ratings.containsKey(checkpointId(section.id, i))) count++;
    }
    return count;
  }
}

class _CheckpointPane extends StatelessWidget {
  final InspectionSectionFixture section;
  final Map<String, FixtureItemStatus> ratings;
  final void Function(String itemId, FixtureItemStatus status) onToggle;
  final VoidCallback onMarkAllGood;
  final void Function(String itemId) onMedia;

  const _CheckpointPane({
    required this.section,
    required this.ratings,
    required this.onToggle,
    required this.onMarkAllGood,
    required this.onMedia,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    final rated = List.generate(section.checkpointKeys.length, (i) => checkpointId(section.id, i))
        .where(ratings.containsKey)
        .length;
    final remaining = section.checkpointKeys.length - rated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.s(section.labelKey),
                    style: types.cardTitle.copyWith(color: p.textPrimary, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    remaining == 0 ? context.s('insp.sec.allDone') : context.s('insp.sec.remaining', {'n': '$remaining'}),
                    style: types.metadata.copyWith(
                      color: remaining == 0 ? p.success : p.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (remaining > 0)
              OutlinedButton.icon(
                onPressed: onMarkAllGood,
                icon: const Icon(Icons.done_all_rounded, size: 16),
                label: Text(context.s('insp.sec.allGood')),
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 42)),
              ),
          ],
        ),
        const SizedBox(height: ProtoSpace.s10),
        for (var i = 0; i < section.checkpointKeys.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == section.checkpointKeys.length - 1 ? 0 : ProtoSpace.s10),
            child: _CheckpointCard(
              index: i + 1,
              itemId: checkpointId(section.id, i),
              label: context.s(section.checkpointKeys[i]),
              status: ratings[checkpointId(section.id, i)],
              media: checkpointMedia[checkpointId(section.id, i)],
              onToggle: onToggle,
              onMedia: onMedia,
            ),
          ),
      ],
    );
  }
}

class _CheckpointCard extends StatelessWidget {
  final int index;
  final String itemId;
  final String label;
  final FixtureItemStatus? status;
  final CheckpointMediaFixture? media;
  final void Function(String itemId, FixtureItemStatus status) onToggle;
  final void Function(String itemId) onMedia;

  const _CheckpointCard({
    required this.index,
    required this.itemId,
    required this.label,
    required this.status,
    required this.media,
    required this.onToggle,
    required this.onMedia,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    final tone = switch (status) {
      FixtureItemStatus.good => p.success,
      FixtureItemStatus.fair => p.warning,
      FixtureItemStatus.poor => p.danger,
      null => p.textMuted,
    };
    final mediaCount = media?.total ?? 0;

    return Container(
      padding: const EdgeInsets.all(ProtoSpace.s14),
      decoration: BoxDecoration(
        color: status == null ? p.surface : Color.alphaBlend(tone.withValues(alpha: 0.03), p.surface),
        borderRadius: BorderRadius.circular(ProtoRadius.card),
        border: Border.all(color: status == null ? p.borderDefault : tone.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: status == null ? p.surfaceSunken : tone.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$index',
                  style: types.metadata.copyWith(
                    color: status == null ? p.textMuted : tone,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: ProtoSpace.s10),
              Expanded(
                child: Text(
                  label,
                  style: types.bodyStrong.copyWith(color: p.textPrimary, height: 1.35),
                ),
              ),
              if (mediaCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s8, vertical: 3),
                  decoration: BoxDecoration(
                    color: p.primarySubtle,
                    borderRadius: BorderRadius.circular(ProtoRadius.pill),
                    border: Border.all(color: p.primaryBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.attachment_rounded, size: 12, color: p.primary),
                      const SizedBox(width: 3),
                      Text(
                        '$mediaCount',
                        style: types.metadata.copyWith(color: p.primary, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: ProtoSpace.s12),
          Row(
            children: [
              for (final value in FixtureItemStatus.values) ...[
                Expanded(
                  child: _ConditionButton(
                    label: switch (value) {
                      FixtureItemStatus.good => context.s('insp.item.good'),
                      FixtureItemStatus.fair => context.s('insp.item.fair'),
                      FixtureItemStatus.poor => context.s('insp.item.poor'),
                    },
                    icon: switch (value) {
                      FixtureItemStatus.good => Icons.check_circle_outline_rounded,
                      FixtureItemStatus.fair => Icons.error_outline_rounded,
                      FixtureItemStatus.poor => Icons.cancel_outlined,
                    },
                    activeColor: switch (value) {
                      FixtureItemStatus.good => p.success,
                      FixtureItemStatus.fair => p.warning,
                      FixtureItemStatus.poor => p.danger,
                    },
                    selected: status == value,
                    onTap: () => onToggle(itemId, value),
                  ),
                ),
                if (value != FixtureItemStatus.poor) const SizedBox(width: ProtoSpace.s8),
              ],
            ],
          ),
          const SizedBox(height: ProtoSpace.s10),
          Row(
            children: [
              Tooltip(
                message: context.s('insp.media.title'),
                child: InkWell(
                  onTap: () => onMedia(itemId),
                  borderRadius: BorderRadius.circular(ProtoRadius.sm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s6, vertical: ProtoSpace.s6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          mediaCount > 0 ? Icons.inventory_2_rounded : Icons.add_photo_alternate_outlined,
                          size: 14,
                          color: mediaCount > 0 ? p.primary : p.textMuted,
                        ),
                        const SizedBox(width: ProtoSpace.s6),
                        Text(
                          mediaCount > 0
                              ? context.s('insp.item.mediaCount', {'n': '$mediaCount'})
                              : context.s('insp.item.addMedia'),
                          style: types.metadata.copyWith(
                            color: mediaCount > 0 ? p.primary : p.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              if (status != null)
                Text(
                  context.s('insp.item.evaluated'),
                  style: types.metadata.copyWith(color: tone, fontWeight: FontWeight.w700),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConditionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color activeColor;
  final bool selected;
  final VoidCallback onTap;

  const _ConditionButton({
    required this.label,
    required this.icon,
    required this.activeColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ProtoRadius.control),
        child: AnimatedContainer(
          duration: ProtoMotion.fast,
          curve: ProtoMotion.enter,
          height: ProtoSpace.touchTarget,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? activeColor : p.surfaceSunken,
            borderRadius: BorderRadius.circular(ProtoRadius.control),
            border: Border.all(color: selected ? Colors.transparent : p.borderDefault),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: selected ? Colors.white : p.textMuted),
              const SizedBox(width: ProtoSpace.s6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.types.label.copyWith(
                    fontSize: 12.5,
                    color: selected ? Colors.white : p.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Body-map section content for medium/expanded: instruction, the currently
/// selected part with its condition, and the findings list. The interactive
/// map itself lives in the dedicated right pane.
class _BodyMapDetails extends StatelessWidget {
  final List<DamageFindingFixture> findings;
  final Map<String, String> conditions;
  final String? selectedPartId;
  final void Function(String partId) onAddDamage;
  final void Function(DamageFindingFixture finding) onFindingTap;

  const _BodyMapDetails({
    required this.findings,
    required this.conditions,
    required this.selectedPartId,
    required this.onAddDamage,
    required this.onFindingTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    final partId = selectedPartId ?? findings.firstOrNull?.partId;
    final condition = partId == null ? null : conditions[partId];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Instruction lives with the map itself (right pane); repeating it
        // here would duplicate the same sentence twice on one screen.
        ProtoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (partId == null)
                Text(
                  context.s('insp.map.selectPart'),
                  style: types.bodySmall.copyWith(color: p.textMuted),
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.s(partLabelKeys[partId] ?? partId),
                        style: types.cardTitle.copyWith(color: p.textPrimary),
                      ),
                    ),
                    ProtoStatusPill(
                      label: condition == null
                          ? context.s('insp.map.legendUninspected')
                          : condition == 'good'
                              ? context.s('insp.map.legendGood')
                              : condition == 'minor'
                                  ? context.s('insp.map.legendMinor')
                                  : context.s('insp.map.legendMajor'),
                      tone: switch (condition) {
                        'good' => ProtoTone.success,
                        'minor' => ProtoTone.warning,
                        'major' => ProtoTone.danger,
                        _ => ProtoTone.neutral,
                      },
                      compact: true,
                    ),
                  ],
                ),
                const SizedBox(height: ProtoSpace.s12),
                SizedBox(
                  height: ProtoSpace.touchTarget,
                  child: FilledButton.icon(
                    onPressed: () => onAddDamage(partId),
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 17),
                    label: Text(context.s('insp.map.addDamage')),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: ProtoSpace.s12),
        ProtoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.s('insp.map.findings', {'n': '${findings.length}'}),
                style: types.cardTitle.copyWith(color: p.textPrimary),
              ),
              const SizedBox(height: ProtoSpace.s6),
              if (findings.isEmpty)
                Text(
                  context.s('insp.map.instruction'),
                  style: types.caption.copyWith(color: p.textMuted),
                ),
              for (var i = 0; i < findings.length; i++) ...[
                const SizedBox(height: ProtoSpace.s8),
                InkWell(
                  onTap: () => onFindingTap(findings[i]),
                  borderRadius: BorderRadius.circular(ProtoRadius.sm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: findings[i].severity == FixtureSeverity.major ? p.danger : p.warning,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${i + 1}',
                            style: types.metadata.copyWith(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: ProtoSpace.s10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${context.s(partLabelKeys[findings[i].partId] ?? '')} · '
                                '${context.s(findings[i].type.labelKey)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: types.bodyStrong.copyWith(color: p.textPrimary, fontSize: 13),
                              ),
                              Text(
                                context.s(findings[i].severity.labelKey),
                                style: types.metadata.copyWith(
                                  color: findings[i].severity == FixtureSeverity.major ? p.danger : p.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ProtoDirIcon(Icons.chevron_right_rounded, size: 16, color: p.textDisabled),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BodyMapCard extends StatelessWidget {
  final List<DamageFindingFixture> findings;
  final Map<String, String> conditions;
  final String? selectedPartId;
  final void Function(String partId) onPartTap;
  final void Function(DamageFindingFixture finding) onFindingTap;
  final bool rtlNote;

  /// Compact keeps the tappable finding list inside the map card; at medium+
  /// the dedicated findings card next to the map already owns that list.
  final bool showFindings;

  const _BodyMapCard({
    required this.findings,
    required this.conditions,
    required this.selectedPartId,
    required this.onPartTap,
    required this.onFindingTap,
    required this.rtlNote,
    this.showFindings = true,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    final good = conditions.values.where((c) => c == 'good').length;
    final minor = conditions.values.where((c) => c == 'minor').length;
    final major = conditions.values.where((c) => c == 'major').length;

    return ProtoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.s('insp.map.title'),
            style: types.cardTitle.copyWith(color: p.textPrimary, fontSize: 16),
          ),
          const SizedBox(height: ProtoSpace.s4),
          Text(
            context.s('insp.map.instruction'),
            style: types.caption.copyWith(color: p.textMuted, height: 1.45),
          ),
          const SizedBox(height: ProtoSpace.s12),
          FutureBuilder<ProtoVehicleMapDefinition>(
            future: ProtoVehicleMapLoader.load(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const AspectRatio(
                  aspectRatio: 1,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
                );
              }
              return AspectRatio(
                aspectRatio: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: p.surfaceSubtle,
                    borderRadius: BorderRadius.circular(ProtoRadius.card),
                    border: Border.all(color: p.borderDefault),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(ProtoSpace.s8),
                    // The base illustration is a square bitmap: clip its
                    // corners so the dark-theme light panel reads deliberate.
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(ProtoRadius.control),
                      child: ProtoVehicleMapImage(
                        definition: snapshot.data!,
                        partConditions: conditions,
                        selectedPartId: selectedPartId,
                        markers: [
                          for (var i = 0; i < findings.length; i++)
                            ProtoMapMarker(
                              partId: findings[i].partId,
                              label: '${i + 1}',
                              nx: findings[i].nx,
                              ny: findings[i].ny,
                              major: findings[i].severity == FixtureSeverity.major,
                            ),
                        ],
                        onPartTap: (part) => onPartTap(part.id),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: ProtoSpace.s12),
          Wrap(
            spacing: ProtoSpace.s14,
            runSpacing: ProtoSpace.s8,
            children: [
              _legend(context, context.s('insp.map.legendGood'), p.success),
              _legend(context, context.s('insp.map.legendMinor'), p.warning),
              _legend(context, context.s('insp.map.legendMajor'), p.danger),
              _legend(context, context.s('insp.map.legendUninspected'), p.textDisabled),
            ],
          ),
          if (rtlNote) ...[
            const SizedBox(height: ProtoSpace.s10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.translate_rounded, size: 14, color: p.textMuted),
                const SizedBox(width: ProtoSpace.s6),
                Expanded(
                  child: Text(
                    context.s('insp.map.rtlNote'),
                    style: types.caption.copyWith(color: p.textMuted, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: ProtoSpace.s12),
          Divider(height: 1, color: p.borderSubtle),
          const SizedBox(height: ProtoSpace.s10),
          Text(
            context.s('insp.map.summary', {'parts': '25', 'findings': '${findings.length}'}),
            style: types.bodyStrong.copyWith(color: p.textPrimary, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            context.s('insp.map.summaryCounts',
                {'good': '$good', 'minor': '$minor', 'major': '$major'}),
            style: types.metadata.copyWith(color: p.textMuted),
          ),
          if (showFindings)
            for (var i = 0; i < findings.length; i++) ...[
              const SizedBox(height: ProtoSpace.s8),
              InkWell(
                onTap: () => onFindingTap(findings[i]),
                borderRadius: BorderRadius.circular(ProtoRadius.sm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: findings[i].severity == FixtureSeverity.major ? p.danger : p.warning,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${i + 1}',
                          style: types.metadata.copyWith(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: ProtoSpace.s8),
                      Expanded(
                        child: Text(
                          '${context.s(partLabelKeys[findings[i].partId] ?? '')} · '
                          '${context.s(findings[i].type.labelKey)} (${context.s(findings[i].severity.labelKey)})',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: types.bodySmall.copyWith(color: p.textSecondary),
                        ),
                      ),
                      ProtoDirIcon(Icons.chevron_right_rounded, size: 16, color: p.textDisabled),
                    ],
                  ),
                ),
              ),
            ],
        ],
      ),
    );
  }

  Widget _legend(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: ProtoSpace.s6),
        Text(
          label,
          style: context.types.metadata.copyWith(color: context.palette.textSecondary, fontSize: 11.5),
        ),
      ],
    );
  }
}

class _StickyFooter extends StatelessWidget {
  final bool notifyOwner;
  final ValueChanged<bool> onNotifyChanged;
  final VoidCallback onReview;

  const _StickyFooter({
    required this.notifyOwner,
    required this.onNotifyChanged,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.borderDefault)),
        boxShadow: ProtoElevation.surface,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(ProtoSpace.s16, ProtoSpace.s8, ProtoSpace.s16, ProtoSpace.s10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final notifyRow = Row(
                children: [
                  Icon(Icons.notifications_none_rounded, size: 19, color: p.primary),
                  const SizedBox(width: ProtoSpace.s8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.s('insp.footer.notify'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: types.label.copyWith(color: p.textPrimary, fontSize: 12.5),
                        ),
                        Text(
                          context.s('insp.footer.notifySub'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: types.metadata.copyWith(color: p.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Switch(value: notifyOwner, onChanged: onNotifyChanged),
                ],
              );
              final reviewButton = SizedBox(
                height: ProtoSpace.touchTarget,
                child: FilledButton.icon(
                  onPressed: onReview,
                  icon: const Icon(Icons.preview_outlined, size: 18),
                  label: Text(context.s('insp.footer.review')),
                ),
              );
              // Phones: the primary action gets its own full-width row under
              // the notify control, keeping >=48 px targets and unwrapped copy.
              if (constraints.maxWidth < 480) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    notifyRow,
                    const SizedBox(height: ProtoSpace.s6),
                    reviewButton,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: notifyRow),
                  const SizedBox(width: ProtoSpace.s12),
                  reviewButton,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MediaSheet extends StatelessWidget {
  final String title;
  final void Function(String source) onPick;

  const _MediaSheet({required this.title, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final options = [
      (context.s('insp.media.camera'), Icons.camera_alt_outlined),
      (context.s('insp.media.gallery'), Icons.photo_library_outlined),
      (context.s('insp.media.video'), Icons.videocam_outlined),
      (context.s('insp.media.audio'), Icons.mic_rounded),
      (context.s('insp.media.note'), Icons.edit_note_rounded),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(ProtoSpace.s20, ProtoSpace.s8, ProtoSpace.s20, ProtoSpace.s24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: context.types.sectionTitle.copyWith(color: p.textPrimary)),
          const SizedBox(height: ProtoSpace.s16),
          Row(
            children: [
              for (var i = 0; i < options.length; i++) ...[
                Expanded(
                  child: InkWell(
                    onTap: () => onPick(options[i].$1),
                    borderRadius: BorderRadius.circular(ProtoRadius.card),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: ProtoSpace.s12),
                      decoration: BoxDecoration(
                        color: p.surfaceSubtle,
                        borderRadius: BorderRadius.circular(ProtoRadius.card),
                        border: Border.all(color: p.borderDefault),
                      ),
                      child: Column(
                        children: [
                          Icon(options[i].$2, size: 19, color: p.textPrimary),
                          const SizedBox(height: 4),
                          Text(
                            options[i].$1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.types.metadata.copyWith(color: p.textMuted, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (i < options.length - 1) const SizedBox(width: ProtoSpace.s8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _FindingSheet extends StatefulWidget {
  final String partId;
  final String partLabel;
  final DamageFindingFixture? existing;
  final void Function(DamageFindingFixture finding) onSave;
  final VoidCallback? onDelete;

  const _FindingSheet({
    required this.partId,
    required this.partLabel,
    this.existing,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<_FindingSheet> createState() => _FindingSheetState();
}

class _FindingSheetState extends State<_FindingSheet> {
  late FixtureDamageType _type = widget.existing?.type ?? FixtureDamageType.scratch;
  late FixtureSeverity _severity = widget.existing?.severity ?? FixtureSeverity.minor;
  late FixtureActionRec _action = widget.existing?.action ?? FixtureActionRec.repair;
  late final TextEditingController _location =
      TextEditingController(text: widget.existing?.location ?? '');
  late final TextEditingController _note = TextEditingController(text: widget.existing?.note ?? '');

  @override
  void dispose() {
    _location.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(ProtoSpace.s20, ProtoSpace.s8, ProtoSpace.s20, ProtoSpace.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.partLabel, style: types.sectionTitle.copyWith(color: p.textPrimary)),
            const SizedBox(height: ProtoSpace.s4),
            Text(
              context.s('insp.finding.title'),
              style: types.metadata.copyWith(color: p.textMuted),
            ),
            const SizedBox(height: ProtoSpace.s16),
            _label(context, context.s('insp.finding.type')),
            DropdownButtonFormField<FixtureDamageType>(
              initialValue: _type,
              items: [
                for (final value in FixtureDamageType.values)
                  DropdownMenuItem(value: value, child: Text(context.s(value.labelKey))),
              ],
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: ProtoSpace.s14),
            _label(context, context.s('insp.finding.severity')),
            Row(
              children: [
                for (final value in FixtureSeverity.values) ...[
                  Expanded(
                    child: _ConditionButton(
                      label: context.s(value.labelKey),
                      icon: switch (value) {
                        FixtureSeverity.minor => Icons.error_outline_rounded,
                        FixtureSeverity.moderate => Icons.warning_amber_rounded,
                        FixtureSeverity.major => Icons.cancel_outlined,
                      },
                      activeColor: switch (value) {
                        FixtureSeverity.minor => p.warning,
                        FixtureSeverity.moderate => p.warning,
                        FixtureSeverity.major => p.danger,
                      },
                      selected: _severity == value,
                      onTap: () => setState(() => _severity = value),
                    ),
                  ),
                  if (value != FixtureSeverity.major) const SizedBox(width: ProtoSpace.s8),
                ],
              ],
            ),
            const SizedBox(height: ProtoSpace.s14),
            _label(context, context.s('insp.finding.location')),
            TextField(
              controller: _location,
              decoration: InputDecoration(hintText: widget.partLabel),
            ),
            const SizedBox(height: ProtoSpace.s14),
            _label(context, context.s('insp.finding.note')),
            TextField(controller: _note, maxLines: 3),
            const SizedBox(height: ProtoSpace.s14),
            _label(context, context.s('insp.finding.action')),
            DropdownButtonFormField<FixtureActionRec>(
              initialValue: _action,
              items: [
                for (final value in FixtureActionRec.values)
                  DropdownMenuItem(value: value, child: Text(context.s(value.labelKey))),
              ],
              onChanged: (v) => setState(() => _action = v ?? _action),
            ),
            const SizedBox(height: ProtoSpace.s18),
            SizedBox(
              height: ProtoSpace.touchTarget,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onSave(DamageFindingFixture(
                    id: widget.existing?.id ?? 'VDF-${DateTime.now().millisecondsSinceEpoch}',
                    partId: widget.existing?.partId ?? widget.partId,
                    type: _type,
                    severity: _severity,
                    location: _location.text.trim(),
                    note: _note.text.trim(),
                    action: _action,
                    nx: widget.existing?.nx ?? 0.5,
                    ny: widget.existing?.ny ?? 0.5,
                  ));
                },
                icon: const Icon(Icons.check_rounded, size: 18),
                label: Text(context.s('insp.finding.save')),
              ),
            ),
            if (widget.onDelete != null) ...[
              const SizedBox(height: ProtoSpace.s8),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onDelete!();
                },
                style: TextButton.styleFrom(foregroundColor: p.danger),
                child: Text(context.s('insp.finding.delete')),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: ProtoSpace.s6),
        child: Text(
          text,
          style: context.types.label.copyWith(color: context.palette.textSecondary),
        ),
      );
}
