import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';

/// Sales leaderboard (O2): service-category rankings with expandable
/// revenue lines. The endpoint carries categories (title + ranked items),
/// not advisor identities — so this ranks *what sells*, never invented
/// salespeople. Per-advisor invoice averages and conversion rates have no
/// endpoint fields and are deferred, not fabricated. Expand/collapse calls
/// the frozen notifier; presentation only.
class TopSalesPage extends ConsumerWidget {
  const TopSalesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = OwnerLocalizations.of(context)!;
    final formatters = AppFormatters.of(context);
    ref.watch(dashboardUiProvider);
    final notifier = ref.read(dashboardUiProvider.notifier);
    final categories = notifier.topSalesCategories;
    final expandedSet = notifier.expandedCategoryIndices;

    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );

    if (categories.isEmpty) {
      return ListView(
        padding: EdgeInsets.fromLTRB(
          context.pagePadding.left,
          AppDimensions.s24,
          context.pagePadding.right,
          AppDimensions.s32,
        ),
        children: [
          EmptyState(
            icon: Icons.leaderboard_outlined,
            message: t.ownerSalesEmpty,
          ),
        ],
      );
    }

    final header = Row(
      children: [
        Expanded(
          child: SectionHeader(
            title: t.ownerSalesHeader,
            padding: EdgeInsets.zero,
          ),
        ),
        StatusPill.neutral(t.ownerSalesCount(categories.length)),
      ],
    );

    Widget card(int i) {
      final cat = categories[i];
      return _CategoryCard(
        category: cat,
        index: i,
        isExpanded: expandedSet.contains(i),
        onToggle: () {
          HapticFeedback.selectionClick();
          notifier.toggleCategory(i);
        },
      );
    }

    // Keep the formatters reference honest: counts stay Latin in both
    // locales (frozen display policy); the pill above already renders it.
    formatters.group(categories.length);

    if (wide) {
      return ListView(
        padding: EdgeInsets.fromLTRB(
          context.pagePadding.left,
          AppDimensions.s16,
          context.pagePadding.right,
          AppDimensions.s32,
        ),
        children: [
          header,
          const SizedBox(height: AppDimensions.s12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimensions.s16,
              mainAxisSpacing: AppDimensions.s16,
              mainAxisExtent: 320,
            ),
            itemBuilder: (_, i) => card(i),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        context.pagePadding.left,
        AppDimensions.s16,
        context.pagePadding.right,
        AppDimensions.s32,
      ),
      itemCount: categories.length + 1,
      separatorBuilder: (_, index) =>
          SizedBox(height: index == 0 ? AppDimensions.s12 : AppDimensions.s10),
      itemBuilder: (_, index) {
        if (index == 0) return header;
        return card(index - 1);
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final TopSalesCategory category;
  final int index;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _CategoryCard({
    required this.category,
    required this.index,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppCard.standard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusCard),
              bottom: Radius.circular(
                isExpanded ? 0 : AppDimensions.radiusCard,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.s16,
                vertical: AppDimensions.s14,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? colors.primary.withValues(alpha: 0.15)
                          : colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: AppTextStyles.mono(
                        color: isExpanded
                            ? colors.primary
                            : colors.onSurfaceVariant,
                      ).copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s12),
                  Expanded(
                    child: Text(
                      category.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isExpanded
                            ? colors.primary
                            : colors.onSurface,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration:
                        AppMotion.resolve(context, AppMotion.fast),
                    child: DirectionalIcon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isExpanded
                          ? colors.primary
                          : colors.onSurfaceVariant,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(
              height: 1,
              color: colors.outlineVariant.withValues(alpha: 0.6),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.s16,
                vertical: AppDimensions.s10,
              ),
              color:
                  colors.surfaceContainerHighest.withValues(alpha: 0.5),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      t.ownerSalesNo,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      t.ownerSalesItem,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    t.ownerSalesRevenue,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            for (var i = 0; i < category.items.length; i++)
              _LeaderRow(
                item: category.items[i],
                stripe: i.isEven,
                isLast: i == category.items.length - 1,
              ),
          ],
        ],
      ),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  final TopSalesItem item;
  final bool stripe;
  final bool isLast;

  const _LeaderRow({
    required this.item,
    required this.stripe,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s16,
        vertical: AppDimensions.s12,
      ),
      decoration: BoxDecoration(
        color: stripe
            ? colors.surface
            : colors.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: isLast
            ? const BorderRadius.vertical(
                bottom: Radius.circular(AppDimensions.radiusCard),
              )
            : BorderRadius.zero,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                '${item.sno}',
                style: AppTextStyles.mono(
                  color: colors.onSurfaceVariant,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Expanded(
            child: Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.s8),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              item.value,
              style: AppTextStyles.mono(color: semantic.success.base)
                  .copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
