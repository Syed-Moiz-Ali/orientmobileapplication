import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/job_cards/presentation/providers/job_card_providers.dart';
import 'package:owner_app/features/job_cards/presentation/widgets/filter_chip_bar.dart';
import 'package:owner_app/features/job_cards/presentation/widgets/job_card_tile.dart';

class JobCardsListView extends ConsumerStatefulWidget {
  const JobCardsListView({super.key});

  @override
  ConsumerState<JobCardsListView> createState() => _JobCardsListViewState();
}

class _JobCardsListViewState extends ConsumerState<JobCardsListView> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final state = ref.watch(jobCardsProvider);
    final notifier = ref.read(jobCardsProvider.notifier);

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
          'Job Card Register',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppDimensions.r16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: notifier.onSearch,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search by customer, job card ID, vehicle...',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  prefixIcon: Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          FilterChipBar(
            activeFilter: state.activeFilter,
            onFilterChanged: notifier.setFilter,
          ),
          Expanded(
            child: state.isLoading
                ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
                : RefreshIndicator(
                    onRefresh: notifier.refresh,
                    color: colorScheme.primary,
                    child: state.filtered.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 80),
                              EmptyState(
                                message: 'No matching job cards found in the system.',
                                title: 'No Job Cards',
                                icon: Icons.assignment_outlined,
                              ),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                            itemCount: state.filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (_, i) {
                              final jc = state.filtered[i];
                              return JobCardTile(
                                jobCard: jc,
                                onViewDetails: () {
                                  ref
                                      .read(selectedJobCardProvider.notifier)
                                      .state = jc;
                                  context.push('/job-cards/detail');
                                },
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
