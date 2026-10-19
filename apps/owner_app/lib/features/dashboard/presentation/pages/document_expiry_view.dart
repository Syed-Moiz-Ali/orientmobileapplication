import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';

/// Countdown tone from the real `daysLeft`: crimson at ≤30 days (and when
/// overdue), amber at ≤90, neutral beyond. No renew route exists anywhere in
/// the owner app, so rows carry no CTA — read-only countdowns.
AppStatusColors _toneFor(BuildContext context, int daysLeft) {
  final semantic = context.semanticColors;
  if (daysLeft <= 30) return semantic.danger;
  if (daysLeft <= 90) return semantic.warning;
  return semantic.neutral;
}

/// Compliance ledger (O13): urgency bands, searchable ledger with countdown
/// pills, alert count in the bar. No renew destination exists, so the bell
/// with its placeholder snackbar is replaced by an honest count pill.
class DocumentExpiryView extends ConsumerStatefulWidget {
  const DocumentExpiryView({super.key});

  @override
  ConsumerState<DocumentExpiryView> createState() =>
      _DocumentExpiryViewState();
}

class _DocumentExpiryViewState extends ConsumerState<DocumentExpiryView> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final state = ref.watch(documentExpiryProvider);
    final notifier = ref.read(documentExpiryProvider.notifier);
    final alerts = state.criticalCount + state.urgentCount;

    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );

    return WorkspaceSearchShortcuts(
      onSearch: () => _searchFocus.requestFocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: WorkspaceAppBar(
          title: t.ownerExTitle,
          subtitle: t.ownerExSubtitle,
          showBack: true,
          showOfflineStatus: true,
          actions: [
            if (alerts > 0)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.s16),
                  child: StatusPill.danger(
                    t.ownerExAlerts(alerts),
                    showDot: true,
                  ),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: state.isLoading && state.items.isEmpty
              ? const AppSkeleton.page()
              : AppResponsivePage(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _UrgencyBands(
                        critical: state.criticalCount,
                        urgent: state.urgentCount,
                        watch: state.warningCount,
                      ),
                      const SizedBox(height: AppDimensions.s12),
                      AppSearchField(
                        controller: _searchCtrl,
                        focusNode: _searchFocus,
                        hintText: t.ownerExSearchHint,
                        onChanged: (q) => notifier.onSearch(q),
                        onClear: () {
                          _searchCtrl.clear();
                          notifier.onSearch('');
                        },
                      ),
                      const SizedBox(height: AppDimensions.s12),
                      if (state.filtered.isEmpty)
                        EmptyState(
                          icon: Icons.verified_outlined,
                          message: t.ownerExEmpty,
                        )
                      else if (wide)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.filtered.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppDimensions.s12,
                            mainAxisSpacing: AppDimensions.s12,
                            mainAxisExtent: 132,
                          ),
                          itemBuilder: (_, i) =>
                              _DocumentCard(doc: state.filtered[i]),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusCard,
                            ),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.8),
                            ),
                            boxShadow: AppDimensions.shadowCard,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              for (var i = 0;
                                  i < state.filtered.length;
                                  i++) ...[
                                _DocumentRow(
                                    doc: state.filtered[i]),
                                if (i < state.filtered.length - 1)
                                  Divider(
                                    height: 1,
                                    indent: 64,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant
                                        .withValues(alpha: 0.4),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      const SizedBox(height: AppDimensions.s32),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

/// Urgency bands: critical / urgent / watch counts over frozen getters.
class _UrgencyBands extends StatelessWidget {
  final int critical;
  final int urgent;
  final int watch;

  const _UrgencyBands({
    required this.critical,
    required this.urgent,
    required this.watch,
  });

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final adaptive = context.adaptive;
    final bands = <_Band>[
      _Band(
          label: t.ownerExCritical, count: critical, tone: semantic.danger),
      _Band(label: t.ownerExUrgent, count: urgent, tone: semantic.warning),
      _Band(label: t.ownerExWatch, count: watch, tone: semantic.neutral),
    ];
    return AppAdaptiveGrid(
      columns: 3,
      minChildWidth: 100,
      spacing: adaptive.itemSpacing,
      runSpacing: adaptive.itemSpacing,
      childAspectRatio: adaptive.pick(
        compact: 1.15,
        medium: 1.5,
        expanded: 1.7,
        large: 1.8,
      ),
      children: [
        for (final b in bands)
          Container(
            padding: const EdgeInsets.all(AppDimensions.s12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.8),
              ),
              boxShadow: AppDimensions.shadowCard,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: b.tone.base,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.s6),
                    Expanded(
                      child: Text(
                        b.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    '${b.count}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: b.tone.base,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Band {
  final String label;
  final int count;
  final AppStatusColors tone;

  const _Band({required this.label, required this.count, required this.tone});
}

/// Countdown pill from real days-left: overdue and ≤30 resolve danger,
/// ≤90 warning, beyond neutral.
class _CountdownPill extends StatelessWidget {
  final int daysLeft;

  const _CountdownPill({required this.daysLeft});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final tone = _toneFor(context, daysLeft);
    final label = daysLeft < 0
        ? t.ownerExOverdue(-daysLeft)
        : t.ownerExDaysLeft(daysLeft);
    if (tone == context.semanticColors.danger) {
      return StatusPill.danger(label, showDot: true);
    }
    if (tone == context.semanticColors.warning) {
      return StatusPill.warning(label, showDot: true);
    }
    return StatusPill.neutral(label);
  }
}

class _DocumentRow extends StatelessWidget {
  final DocumentExpiry doc;

  const _DocumentRow({required this.doc});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.s16,
          vertical: AppDimensions.s12,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusSm),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.badge_outlined,
                color: colors.primary,
                size: AppDimensions.iconMd,
              ),
            ),
            const SizedBox(width: AppDimensions.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.employeeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${doc.designation} · ${doc.documentType}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      doc.expiryDate,
                      style: AppTextStyles.mono(
                        color: colors.onSurfaceVariant,
                      ).copyWith(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.s8),
            _CountdownPill(daysLeft: doc.daysLeft),
          ],
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final DocumentExpiry doc;

  const _DocumentCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  doc.employeeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),
              _CountdownPill(daysLeft: doc.daysLeft),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${doc.designation} · ${doc.documentType}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              doc.expiryDate,
              style: AppTextStyles.mono(color: colors.onSurfaceVariant)
                  .copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
