import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/presentation/providers/moderation_providers.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';

/// Review inbox (O14): star feed rows with the frozen approve/reject
/// visibility flow. Success is read from provider state (the row leaves the
/// inbox only after the PUT lands); failure keeps the row and toasts.
/// Replies have no endpoint — an explicit note says so instead of a fake
/// composer.
class FeedbackModerationView extends ConsumerWidget {
  const FeedbackModerationView({super.key});

  void _toast(BuildContext context, String msg, {required bool ok}) {
    final ink = context.semanticColors.onPrimary;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              ok
                  ? Icons.check_circle_outline_rounded
                  : Icons.error_outline_rounded,
              color: ink,
              size: AppDimensions.iconSm,
            ),
            const SizedBox(width: AppDimensions.s8),
            Expanded(
              child: Text(
                msg,
                style: TextStyle(color: ink, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor: ok
            ? context.semanticColors.success.base
            : Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _moderate(
    BuildContext context,
    WidgetRef ref,
    String id,
    bool isPublic,
  ) async {
    final t = OwnerLocalizations.of(context)!;
    HapticFeedback.mediumImpact();
    final before =
        ref.read(moderationProvider).pending.map((f) => f.id).toSet();
    await ref.read(moderationProvider.notifier).moderate(id, isPublic);
    if (!context.mounted) return;
    // The row leaves the inbox only when the PUT succeeds — read the
    // outcome from state, never assume it.
    final gone = !ref.read(moderationProvider).pending.any((f) => f.id == id);
    final wasThere = before.contains(id);
    _toast(
      context,
      gone && wasThere ? t.ownerFbDone : t.ownerFbFail,
      ok: gone && wasThere,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final state = ref.watch(moderationProvider);
    final notifier = ref.read(moderationProvider.notifier);

    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: WorkspaceAppBar(
        title: t.ownerFbTitle,
        subtitle: t.ownerFbSubtitle,
        showBack: true,
        showOfflineStatus: true,
        actions: [
          IconButton(
            tooltip: MaterialLocalizations.of(context)
                .refreshIndicatorSemanticLabel,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              HapticFeedback.selectionClick();
              notifier.load();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading && state.pending.isEmpty
            ? const AppSkeleton.page()
            : state.error.isNotEmpty && state.pending.isEmpty
                ? Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(AppDimensions.s20),
                      child: ErrorView(
                        message: state.error,
                        onRetry: notifier.load,
                      ),
                    ),
                  )
                : AppResponsivePage(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                                t.ownerFbNoRespond,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.s12),
                        if (state.pending.isEmpty)
                          EmptyState(
                            icon: Icons.rate_review_outlined,
                            message: t.ownerFbEmpty,
                          )
                        else if (wide)
                          GridView.builder(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            itemCount: state.pending.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: AppDimensions.s12,
                              mainAxisSpacing: AppDimensions.s12,
                              // Fits header + a long comment + dock at 1.3x;
                              // covered by a long-comment overflow test.
                              mainAxisExtent: 300,
                            ),
                            itemBuilder: (_, i) => _ReviewCard(
                              index: i,
                              onModerate: (id, isPublic) =>
                                  _moderate(context, ref, id, isPublic),
                            ),
                          )
                        else
                          for (var i = 0;
                              i < state.pending.length;
                              i++) ...[
                            _ReviewCard(
                              index: i,
                              onModerate: (id, isPublic) =>
                                  _moderate(context, ref, id, isPublic),
                            ),
                            const SizedBox(height: AppDimensions.s12),
                          ],
                        const SizedBox(height: AppDimensions.s32),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _ReviewCard extends ConsumerWidget {
  final int index;
  final Future<void> Function(String id, bool isPublic) onModerate;

  const _ReviewCard({required this.index, required this.onModerate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final review = ref.watch(moderationProvider).pending[index];

    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.s10,
                  vertical: AppDimensions.s4,
                ),
                decoration: BoxDecoration(
                  color: semantic.warning.subtle,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSm),
                  border: Border.all(color: semantic.warning.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: AppDimensions.iconXs,
                      color: semantic.warning.ink,
                    ),
                    const SizedBox(width: 4),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        review.rating,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: semantic.warning.ink,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [
                            FontFeature.tabularFigures()
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.s10),
              Expanded(
                child: Text(
                  review.customerName.isEmpty
                      ? t.ownerFbVerified
                      : review.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  review.date,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.s12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Text(
                '"${review.comment}"',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontStyle: FontStyle.italic,
                  height: 1.35,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.s12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onModerate(review.id, false),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: Text(
                    t.ownerFbReject,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.error,
                    side: BorderSide(
                      color: colors.error.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusButton,
                      ),
                    ),
                    minimumSize: const Size(
                      0,
                      AppDimensions.touchTarget,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.s10),
              Expanded(
                child: PrimaryButton(
                  label: t.ownerFbApprove,
                  icon: Icons.check_rounded,
                  onPressed: () => onModerate(review.id, true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
