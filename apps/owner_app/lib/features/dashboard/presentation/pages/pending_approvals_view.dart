import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';

/// Executive approvals queue (O8): discount, goodwill and override
/// categories awaiting owner review. The backend exposes categories with
/// counts only — no per-request amounts, no requester/reason/age fields and
/// no approve/reject endpoint exist anywhere in the owner app. Approve /
/// Reject buttons would therefore be fake actions (instant FAIL), so this
/// queue is an honest triage surface: severity-toned rows, live counts, an
/// explicit read-only note, and full state coverage. When a decision
/// endpoint lands, the emerald/crimson dock belongs here.
class PendingApprovalsView extends ConsumerWidget {
  const PendingApprovalsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final state = ref.watch(pendingApprovalsProvider);
    final formatters = AppFormatters.of(context);

    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: WorkspaceAppBar(
        title: t.ownerApTitle,
        subtitle: t.ownerApSubtitle,
        showBack: true,
      ),
      body: SafeArea(
        child: state.isLoading
            ? const AppSkeleton.page()
            : AppResponsivePage(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeroCard(
                      totalPending: state.totalPending,
                      formatters: formatters,
                    ),
                    const SizedBox(height: AppDimensions.s20),
                    if (state.totalPending == 0) ...[
                      EmptyState(
                        icon: Icons.gavel_rounded,
                        message: t.ownerApEmpty,
                      ),
                      const SizedBox(height: AppDimensions.s8),
                      Text(
                        t.ownerApEmptyHint,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ] else ...[
                      Semantics(
                        header: true,
                        child: SectionHeader(title: t.ownerApList),
                      ),
                      const SizedBox(height: AppDimensions.s4),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: AppDimensions.iconXs,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppDimensions.s6),
                          Expanded(
                            child: Text(
                              t.ownerApNoAction,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.s8),
                      if (wide)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.categories.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppDimensions.s12,
                            mainAxisSpacing: AppDimensions.s10,
                            mainAxisExtent: 84,
                          ),
                          itemBuilder: (_, i) => _CategoryRow(
                            category: state.categories[i],
                          ),
                        )
                      else
                        for (final category in state.categories) ...[
                          _CategoryRow(category: category),
                          const SizedBox(height: AppDimensions.s10),
                        ],
                    ],
                    const SizedBox(height: AppDimensions.s32),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Hero: awaiting-review eyebrow over the live request count. Danger tone
/// while work waits, calm primary when clear — theme roles, never bare red
/// without the count beside it.
class _HeroCard extends StatelessWidget {
  final int totalPending;
  final AppFormatters formatters;

  const _HeroCard({required this.totalPending, required this.formatters});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final waiting = totalPending > 0;
    final tone = waiting ? semantic.danger : semantic.success;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.s20),
      decoration: BoxDecoration(
        color: waiting
            ? tone.subtle
            : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: waiting ? tone.border : colors.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: waiting ? tone.base : colors.primary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.gavel_rounded,
              color: context.semanticColors.onPrimary,
              size: 26,
            ),
          ),
          const SizedBox(width: AppDimensions.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.ownerApAwaiting,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    t.ownerApCount(totalPending),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: waiting ? tone.ink : colors.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
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

class _CategoryRow extends StatelessWidget {
  final ApprovalCategory category;

  const _CategoryRow({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasPending = category.count > 0;

    return AppRecordRow(
      // The tint arrives on the frozen entity (adapter-mapped per index),
      // the same data-carries-color class as feed accent dots: chrome and
      // ink resolve theme roles around it.
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: category.iconBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        alignment: Alignment.center,
        child: Icon(category.icon, color: colors.onSurface, size: 22),
      ),
      title: category.title,
      subtitle: category.subtitle,
      status: hasPending
          ? StatusPill.warning('${category.count}', showDot: true)
          : StatusPill.neutral('${category.count}'),
      // No destination exists behind a category: rows are intentionally
      // untappable (no chevron, no-op tap would be a fake affordance).
      onTap: null,
    );
  }
}
