import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_vehicle_checkin_view.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_job_card_row.dart';

class AdvisorJobsListView extends ConsumerStatefulWidget {
  final void Function(JobCardEntity) onJobCard;
  const AdvisorJobsListView({super.key, required this.onJobCard});
  @override
  ConsumerState<AdvisorJobsListView> createState() =>
      _AdvisorJobsListViewState();
}

class _AdvisorJobsListViewState extends ConsumerState<AdvisorJobsListView> {
  final _searchCtrl = TextEditingController();
  final _filterChips = [
    'All',
    'In Progress',
    'Completed',
    'Pending',
    'QC Check',
    'Cancelled',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobCardsAsync = ref.watch(advisorRecentJobCardsProvider);
    final jobCards = jobCardsAsync.value ?? const <JobCardEntity>[];
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
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.text4,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: AppColors.text3,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                onChanged: (v) =>
                    ref.read(_jobsSearchProvider.notifier).state = v,
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
                    onTap: () =>
                        ref.read(_jobsFilterProvider.notifier).state = f,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: active ? AppColors.accent : AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.rPill,
                        ),
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
    final bookingsAsync = ref.watch(advisorAssignedBookingsProvider);
    final bookings = bookingsAsync.value ?? const <AdvisorBookingResponse>[];
    final showBookings =
        query.isEmpty && filter == 'All' && bookings.isNotEmpty;

    final filtered = allCards.where((jc) {
      final matchesFilter =
          filter == 'All' || _statusLabel(jc.status) == filter;
      final matchesSearch =
          query.isEmpty ||
          jc.id.toLowerCase().contains(query) ||
          jc.customerName.toLowerCase().contains(query) ||
          jc.vehicleInfo.toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();

    if (filtered.isEmpty && !showBookings) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 56,
              color: AppColors.text4.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            const Text(
              'No job cards found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.text3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              query.isNotEmpty
                  ? 'Try a different search'
                  : 'Create a new job card to get started',
              style: const TextStyle(fontSize: 13, color: AppColors.text4),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
      itemCount: filtered.length + (showBookings ? bookings.length + 1 : 0),
      itemBuilder: (_, i) {
        if (showBookings && i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.event_available_rounded,
                        size: 18,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Assigned Bookings',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${bookings.length}',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap to start intake when the customer arrives',
                    style: TextStyle(fontSize: 12, color: AppColors.text3),
                  ),
                  const SizedBox(height: 10),
                  ...bookings
                      .take(4)
                      .map(
                        (b) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              context.push(
                                AppRoutes.vehicleCustomer,
                                extra: {'bookingId': '${b.id}'},
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.directions_car_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${b.serviceType} · ${b.vehicleName}',
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${b.customerName} · ${b.bookingDate}',
                                          style: const TextStyle(
                                            color: AppColors.text3,
                                            fontSize: 11.5,
                                          ),
                                        ),
                                        if (b.status.toLowerCase() ==
                                            'confirmed') ...[
                                          const SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: SizedBox(
                                              height: 32,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.accent,
                                                  foregroundColor: Colors.white,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          AppDimensions.r8,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          AdvisorVehicleCheckinView(
                                                            bookingId:
                                                                '${b.id}',
                                                            customerName:
                                                                b.customerName,
                                                            vehicleInfo:
                                                                b.vehicleName,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: const Text(
                                                  'Check In',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 18,
                                    color: AppColors.text3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          );
        }
        final index = showBookings ? i - 1 - bookings.length : i;
        if (index < 0 || index >= filtered.length) {
          return const SizedBox.shrink();
        }
        return AdvisorJobCardRow(jc: filtered[index], onTap: widget.onJobCard);
      },
    );
  }

  String _statusLabel(JobCardStatus s) => switch (s) {
    JobCardStatus.inProgress => 'In Progress',
    JobCardStatus.pendingApproval => 'Pending',
    JobCardStatus.completed => 'Completed',
    JobCardStatus.waitingParts => 'Waiting Parts',
    JobCardStatus.qualityCheck => 'QC Check',
    JobCardStatus.cancelled => 'Cancelled',
    JobCardStatus.pending => 'Pending',
    JobCardStatus.awaitingSupervisor => 'Awaiting Supervisor',
    JobCardStatus.vehicleReceived => 'Vehicle Received',
    JobCardStatus.waitingCustomerApproval => 'Waiting Customer Approval',
    JobCardStatus.delivered => 'Delivered',
    JobCardStatus.qualityCheckPassed => 'QC Passed',
  };
}

final _jobsSearchProvider = StateProvider<String>((ref) => '');
final _jobsFilterProvider = StateProvider<String>((ref) => 'All');
