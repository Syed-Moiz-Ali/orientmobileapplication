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
    final state = ref.watch(jobCardsProvider);
    final notifier = ref.read(jobCardsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Job Cards',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(AppDimensions.r8),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: notifier.onSearch,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search by customer, job card ID, vehicle...',
                  hintStyle: TextStyle(color: AppColors.gray400, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: AppColors.gray400, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
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
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : RefreshIndicator(
                    onRefresh: notifier.refresh,
                    color: AppColors.primary,
                    child: state.filtered.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 120),
                              Icon(
                                Icons.assignment_outlined,
                                size: 48,
                                color: AppColors.gray400,
                              ),
                              SizedBox(height: 12),
                              Center(
                                child: Text(
                                  'No job cards found',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.gray500,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: state.filtered.length,
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
