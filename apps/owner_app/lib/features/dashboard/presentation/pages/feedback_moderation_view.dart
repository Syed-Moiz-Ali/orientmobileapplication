import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/presentation/providers/moderation_providers.dart';

/// P2 (audit): feedback moderation inbox — reviews are not public until
/// approved (backend enforces is_moderated on reads).
class FeedbackModerationView extends ConsumerWidget {
  const FeedbackModerationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(moderationProvider);
    final notifier = ref.read(moderationProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Review Moderation',
          style: TextStyle(color: AppColors.gray900, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.gray700),
            onPressed: notifier.load,
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : state.error.isNotEmpty && state.pending.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.error, style: const TextStyle(color: AppColors.gray500)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: notifier.load, child: const Text('Retry')),
                    ],
                  ),
                )
              : state.pending.isEmpty
                  ? const Center(
                      child: Text('No reviews awaiting moderation',
                          style: TextStyle(color: AppColors.gray400)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: state.pending.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final f = state.pending[i];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.gray200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF3E6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text('${f.rating} \u2605',
                                        style: const TextStyle(
                                            color: Color(0xFFB45309),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      f.customerName.isEmpty ? 'Anonymous' : f.customerName,
                                      style: const TextStyle(
                                          fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gray900),
                                    ),
                                  ),
                                  Text(f.date,
                                      style: const TextStyle(fontSize: 10, color: AppColors.gray400)),
                                ],
                              ),
                              if (f.comment.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(f.comment,
                                    style: const TextStyle(fontSize: 13, color: AppColors.gray700)),
                              ],
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => notifier.moderate(f.id, false),
                                    child: const Text('Reject',
                                        style: TextStyle(color: AppColors.danger)),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => notifier.moderate(f.id, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Approve'),
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
