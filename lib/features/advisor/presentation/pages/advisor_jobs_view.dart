import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/job_card_entity.dart';
import 'package:orientmobileapplication/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:orientmobileapplication/features/advisor/presentation/widgets/advisor_job_card_row.dart';

class AdvisorJobsListView extends ConsumerStatefulWidget {
  final void Function(JobCardEntity) onJobCard;
  const AdvisorJobsListView({super.key, required this.onJobCard});
  @override
  ConsumerState<AdvisorJobsListView> createState() => _AdvisorJobsListViewState();
}

class _AdvisorJobsListViewState extends ConsumerState<AdvisorJobsListView> {
  final _searchCtrl = TextEditingController();
  final _filterChips = ['All', 'In Progress', 'Completed', 'Pending', 'QC Check', 'Cancelled'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobCards = ref.watch(advisorRecentJobCardsProvider);
    final selectedFilter = ref.watch(_jobsFilterProvider);
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'All Job Cards',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.text2),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppDimensions.r10),
              ),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search by name, plate, or ID...',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.text4),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.text3),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                onChanged: (v) => ref.read(_jobsSearchProvider.notifier).state = v,
              ),
            ),
          ),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _filterChips.map((f) {
                final active = f == selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => ref.read(_jobsFilterProvider.notifier).state = f,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? AppColors.accent : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimensions.rPill),
                        border: Border.all(
                          color: active ? AppColors.accent : AppColors.line,
                        ),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: active ? Colors.white : AppColors.text3,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.accent,
              onRefresh: () async {
                ref.read(advisorRefreshProvider.notifier).state++;
              },
              child: _buildJobList(jobCards, selectedFilter),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobList(List<JobCardEntity> allCards, String filter) {
    final query = ref.watch(_jobsSearchProvider).toLowerCase();
    final filtered = allCards.where((jc) {
      final matchesFilter = filter == 'All' || _statusLabel(jc.status) == filter;
      final matchesSearch = query.isEmpty ||
          jc.id.toLowerCase().contains(query) ||
          jc.customerName.toLowerCase().contains(query) ||
          jc.vehicleInfo.toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 56, color: AppColors.text4.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            const Text(
              'No job cards found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text3),
            ),
            const SizedBox(height: 4),
            Text(
              query.isNotEmpty ? 'Try a different search' : 'Create a new job card to get started',
              style: const TextStyle(fontSize: 13, color: AppColors.text4),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
      itemCount: filtered.length,
      itemBuilder: (_, i) => AdvisorJobCardRow(jc: filtered[i], onTap: widget.onJobCard),
    );
  }

  String _statusLabel(JobCardStatus s) => switch (s) {
    JobCardStatus.inProgress => 'In Progress',
    JobCardStatus.pendingApproval => 'Pending',
    JobCardStatus.completed => 'Completed',
    JobCardStatus.waitingParts => 'Waiting Parts',
    JobCardStatus.qualityCheck => 'QC Check',
    JobCardStatus.cancelled => 'Cancelled',
  };
}

final _jobsSearchProvider = StateProvider<String>((ref) => '');
final _jobsFilterProvider = StateProvider<String>((ref) => 'All');
