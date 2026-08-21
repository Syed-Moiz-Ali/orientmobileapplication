import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_providers.dart';

class PendingApprovalsView extends ConsumerStatefulWidget {
  const PendingApprovalsView({super.key});

  @override
  ConsumerState<PendingApprovalsView> createState() => _PendingApprovalsViewState();
}

class _PendingApprovalsViewState extends ConsumerState<PendingApprovalsView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final state = ref.watch(pendingApprovalsProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Pending Authorizations',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: state.totalPending > 0
                          ? const Color(0xFFEF4444).withValues(alpha: 0.08)
                          : colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppDimensions.r24),
                      border: Border.all(
                        color: state.totalPending > 0
                            ? const Color(0xFFEF4444).withValues(alpha: 0.25)
                            : colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: state.totalPending > 0
                                ? const Color(0xFFEF4444)
                                : colorScheme.primary,
                            borderRadius: BorderRadius.circular(AppDimensions.r16),
                          ),
                          child: const Icon(
                            Icons.gavel_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Awaiting Owner Approval',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${state.totalPending} Requests Pending',
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: state.totalPending > 0
                                      ? const Color(0xFFEF4444)
                                      : colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'APPROVAL CATEGORIES',
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _CategoryItem(category: state.categories[i]),
                  ),
                ],
              ),
            ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final ApprovalCategory category;

  const _CategoryItem({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderRadius: AppDimensions.r20,
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: category.iconBg,
              borderRadius: BorderRadius.circular(AppDimensions.r14),
            ),
            child: Icon(category.icon, color: colorScheme.onSurface, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  category.subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          StatusPill(
            label: '${category.count}',
            bg: category.count > 0
                ? colorScheme.primary.withValues(alpha: 0.12)
                : colorScheme.surfaceContainerLow,
            fg: category.count > 0 ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant, size: 20),
        ],
      ),
    );
  }
}
