import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/presentation/providers/moderation_providers.dart';

class FeedbackModerationView extends ConsumerWidget {
  const FeedbackModerationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final state = ref.watch(moderationProvider);
    final notifier = ref.read(moderationProvider.notifier);

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
          'Review Moderation',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colorScheme.onSurface),
            onPressed: notifier.load,
          ),
        ],
      ),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : state.error.isNotEmpty && state.pending.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.error, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: notifier.load, child: const Text('Retry')),
                    ],
                  ),
                )
              : state.pending.isEmpty
                  ? Center(
                      child: Text(
                        'All customer reviews have been moderated',
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      itemCount: state.pending.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, i) {
                        final f = state.pending[i];
                        return AppCard(
                          padding: const EdgeInsets.all(16),
                          borderRadius: AppDimensions.r20,
                          color: colorScheme.surface,
                          borderColor: colorScheme.outlineVariant,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(AppDimensions.r8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD97706)),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${f.rating}.0',
                                          style: const TextStyle(
                                            color: Color(0xFFD97706),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      f.customerName.isEmpty ? 'Verified Customer' : f.customerName,
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    f.date,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              if (f.comment.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(AppDimensions.r12),
                                  ),
                                  child: Text(
                                    '"${f.comment}"',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontStyle: FontStyle.italic,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => notifier.moderate(f.id, false),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFFEF4444),
                                      side: const BorderSide(color: Color(0xFFEF4444)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppDimensions.r12),
                                      ),
                                    ),
                                    child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w800)),
                                  ),
                                  const SizedBox(width: 10),
                                  FilledButton(
                                    onPressed: () => notifier.moderate(f.id, true),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppDimensions.r12),
                                      ),
                                    ),
                                    child: const Text('Approve & Publish', style: TextStyle(fontWeight: FontWeight.w800)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
