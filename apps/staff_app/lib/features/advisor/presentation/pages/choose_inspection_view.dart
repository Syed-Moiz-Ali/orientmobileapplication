import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

import 'inspection_provider.dart';

/// Phase 08 — Concept A package picker (Archetype 6 entry).
///
/// DECISION screen: compare tiers fast, pick one, go. The packages own the
/// viewport — chrome is a slim header + 4px progress + ONE 40px sort row.
/// Unselected tiers stay collapsed (name + meta line only); the selected
/// tier expands to its breakdown + focus areas. One primary CTA (Continue)
/// starts the flow. Starting behaviour (provider reset, job-card link,
/// sheet route with [InspectionCallbacks]) is byte-identical to the
/// previous composition.
class ChooseInspectionView extends ConsumerStatefulWidget {
  final VoidCallback onSelect;
  final VoidCallback onSkip;
  final VoidCallback onBack;
  final String jobId;

  const ChooseInspectionView({
    super.key,
    required this.onSelect,
    required this.onSkip,
    required this.onBack,
    this.jobId = '',
  });

  @override
  ConsumerState<ChooseInspectionView> createState() =>
      _ChooseInspectionViewState();
}

class _InspectionPackage {
  final String nameKey;
  final String descKey;
  final List<String> focusKeys;
  final int sections;
  final int checkpoints;
  final int minutes;
  final IconData icon;
  final bool recommended;
  final String templateName;

  const _InspectionPackage({
    required this.nameKey,
    required this.descKey,
    required this.focusKeys,
    required this.sections,
    required this.checkpoints,
    required this.minutes,
    required this.icon,
    required this.recommended,
    required this.templateName,
  });
}

String _packageName(StaffLocalizations t, _InspectionPackage p) {
  if (p.nameKey == 'quick') return t.advisorPackageQuick;
  if (p.nameKey == 'full') return t.advisorPackageFull;
  return t.advisorPackageSafety;
}

String _packageDesc(StaffLocalizations t, _InspectionPackage p) {
  if (p.nameKey == 'quick') return t.advisorPackageQuickDesc;
  if (p.nameKey == 'full') return t.advisorPackageFullDesc;
  return t.advisorPackageSafetyDesc;
}

String _focusLabel(StaffLocalizations t, String key) {
  switch (key) {
    case 'brakes':
      return t.advisorFocusBrakes;
    case 'engine':
      return t.advisorFocusEngine;
    case 'suspension':
      return t.advisorFocusSuspension;
    default:
      return t.advisorFocusLighting;
  }
}

const _packages = <_InspectionPackage>[
  _InspectionPackage(
    nameKey: 'quick',
    descKey: 'quick',
    focusKeys: ['lighting', 'brakes'],
    sections: 2,
    checkpoints: 20,
    minutes: 10,
    icon: Icons.speed_rounded,
    recommended: false,
    templateName: 'Express Bay Safety Scan',
  ),
  _InspectionPackage(
    nameKey: 'full',
    descKey: 'full',
    focusKeys: ['brakes', 'engine', 'suspension'],
    sections: 5,
    checkpoints: 60,
    minutes: 30,
    icon: Icons.fact_check_outlined,
    recommended: true,
    templateName: 'Comprehensive 24-Point',
  ),
  _InspectionPackage(
    nameKey: 'safety',
    descKey: 'safety',
    focusKeys: ['brakes', 'suspension', 'lighting'],
    sections: 3,
    checkpoints: 35,
    minutes: 20,
    icon: Icons.shield_outlined,
    recommended: false,
    templateName: 'Brake & Suspension Audit',
  ),
];

class _ChooseInspectionViewState extends ConsumerState<ChooseInspectionView> {
  String _selectedTemplate = 'Comprehensive 24-Point';
  int _sort = 0;

  List<_InspectionPackage> get _ordered {
    final list = _packages.toList();
    switch (_sort) {
      case 1:
        list.sort((a, b) => a.minutes.compareTo(b.minutes));
      case 2:
        list.sort((a, b) => b.checkpoints.compareTo(a.checkpoints));
      default:
        list.sort((a, b) {
          if (a.recommended == b.recommended) {
            return _packages.indexOf(a).compareTo(_packages.indexOf(b));
          }
          return a.recommended ? -1 : 1;
        });
    }
    return list;
  }

  _InspectionPackage get _selected =>
      _packages.firstWhere((p) => p.templateName == _selectedTemplate);

  void _startInspection() {
    HapticFeedback.mediumImpact();
    final ref = this.ref;
    ref.read(inspectionProvider.notifier).reset();
    if (widget.jobId.isNotEmpty) {
      ref.read(inspectionProvider.notifier).setJobCardId(widget.jobId);
    }
    final cb = InspectionCallbacks(
      onBack: () => context.pop(),
      onSaveDraft: () {
        context.pop();
        widget.onSelect();
      },
      onPreview: () {
        context.push(
          AppRoutes.inspectionPreview,
          extra: {
            'onBack': () {
              context.pop();
              widget.onSelect();
            },
          },
        );
      },
    );
    context.push(AppRoutes.inspectionSheet, extra: cb);
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final pendingSync = ref.watch(advisorPendingSyncCountProvider).valueOrNull;
    final ordered = _ordered;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: WorkspaceAppBar(
        title: t.advisorPackageTitle,
        subtitle: t.advisorPackageCheckpoints(_selected.checkpoints),
        showBack: true,
        onBack: widget.onBack,
        frosted: !context.isCompact,
        showOfflineStatus: true,
        offlinePendingCount: pendingSync,
        actions: [
          TextButton(
            onPressed: widget.onSkip,
            child: Text(t.advisorPackageSkip),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Sticky wayfinding anchor: thin selection progress + ONE
            // compare/sort control row. The tier list scrolls beneath it.
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.r4),
              child: LinearProgressIndicator(
                value: 1,
                minHeight: 4,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                padding: const EdgeInsetsDirectional.only(
                  start: 16,
                  end: 16,
                  top: 6,
                  bottom: 2,
                ),
                scrollDirection: Axis.horizontal,
                children: [
                  _SortPill(
                    label: t.advisorPackageSortRecommended,
                    selected: _sort == 0,
                    onTap: () => setState(() => _sort = 0),
                  ),
                  const SizedBox(width: 6),
                  _SortPill(
                    label: t.advisorPackageSortQuickest,
                    selected: _sort == 1,
                    onTap: () => setState(() => _sort = 1),
                  ),
                  const SizedBox(width: 6),
                  _SortPill(
                    label: t.advisorPackageSortThorough,
                    selected: _sort == 2,
                    onTap: () => setState(() => _sort = 2),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AppResponsivePage(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    // Minimal intro — one line; the tiers own the viewport.
                    Text(
                      t.advisorPackageSubtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Tablet/desktop: three tiers side by side; compact
                    // widths stack. Viewport (not the constrained content
                    // box) drives the breakpoint.
                    Builder(
                      builder: (context) {
                        final wide =
                            MediaQuery.sizeOf(context).width >= 1000;
                        if (wide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var i = 0; i < ordered.length; i++) ...[
                                Expanded(
                                  child: _PackageCard(
                                    package: ordered[i],
                                    selected:
                                        ordered[i].templateName ==
                                        _selectedTemplate,
                                    onTap: () => setState(
                                      () => _selectedTemplate =
                                          ordered[i].templateName,
                                    ),
                                  ),
                                ),
                                if (i < ordered.length - 1)
                                  const SizedBox(width: 12),
                              ],
                            ],
                          );
                        }
                        return Column(
                          children: [
                            for (var i = 0; i < ordered.length; i++) ...[
                              _PackageCard(
                                package: ordered[i],
                                selected:
                                    ordered[i].templateName ==
                                    _selectedTemplate,
                                onTap: () => setState(
                                  () => _selectedTemplate =
                                      ordered[i].templateName,
                                ),
                              ),
                              if (i < ordered.length - 1)
                                const SizedBox(height: 10),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _PickerFooter(
              selected: _selected,
              onStart: _startInspection,
            ),
          ],
        ),
      ),
    );
  }
}

class _SortPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Semantics(
          button: true,
          selected: selected,
          label: label,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? colors.primary : colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: selected ? colors.primary : colors.outlineVariant,
              ),
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected ? colors.onPrimary : colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final _InspectionPackage package;
  final bool selected;
  final VoidCallback onTap;

  const _PackageCard({
    required this.package,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      selected: selected,
      expanded: selected,
      label: _packageName(t, package),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? colors.primaryContainer.withValues(alpha: 0.28)
                : colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.r16),
            border: Border.all(
              color: selected ? colors.primary : colors.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: selected
                          ? colors.primary.withValues(alpha: 0.14)
                          : colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppDimensions.r12),
                    ),
                    child: Icon(
                      package.icon,
                      color: selected
                          ? colors.primary
                          : colors.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _packageName(t, package),
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        // Collapsed meta line — always visible for compare.
                        Text(
                          t.advisorPackageCheckpoints(package.checkpoints),
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: selected
                        ? colors.primary
                        : colors.onSurfaceVariant,
                    size: 22,
                  ),
                  Icon(
                    selected
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: colors.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
              if (package.recommended || selected) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (package.recommended)
                      StatusPill.info(t.advisorPackageRecommended),
                    if (selected)
                      StatusPill.success(t.advisorPackageSelected),
                  ],
                ),
              ],
              // Progressive disclosure: breakdown + focus stay hidden
              // until the tier is selected.
              if (selected) ...[
                const SizedBox(height: 10),
                Text(
                  _packageDesc(t, package),
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Chip(
                      icon: Icons.schedule_rounded,
                      label: t.advisorPackageDuration(package.minutes),
                    ),
                    _Chip(
                      icon: Icons.layers_outlined,
                      label: t.advisorPackageSections(package.sections),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  t.advisorPackageFocus,
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final key in package.focusKeys)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppDimensions.r8),
                          border: Border.all(color: colors.outlineVariant),
                        ),
                        child: Text(
                          _focusLabel(t, key),
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimensions.r8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colors.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerFooter extends StatelessWidget {
  final _InspectionPackage selected;
  final VoidCallback onStart;

  const _PickerFooter({required this.selected, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
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
              _packageName(t, selected),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: t.advisorPackageStart,
                icon: Icons.arrow_forward_rounded,
                onPressed: onStart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
